#!/usr/bin/env bash
# Proposed portable version. Compare with the deployed host script before installation.
set -euo pipefail

CONFIG_FILE="${IP_WATCH_CONFIG:-/etc/proxmox-ip-watch/config}"
TOKEN_FILE="${IP_WATCH_TOKEN_FILE:-/etc/proxmox-ip-watch/token}"
STATE_DIR="${IP_WATCH_STATE_DIR:-/var/lib/proxmox-ip-watch}"

# A local, root-controlled configuration file sets GOTIFY_URL.
if [[ -r "$CONFIG_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
fi
: "${GOTIFY_URL:?Set GOTIFY_URL in the local configuration file}"
[[ "$GOTIFY_URL" == http://* || "$GOTIFY_URL" == https://* ]] || {
    echo 'GOTIFY_URL must begin with http:// or https://' >&2
    exit 1
}
[[ -s "$TOKEN_FILE" ]] || { echo 'Missing Gotify application token' >&2; exit 1; }

install -d -m 700 "$STATE_DIR"
exec 9>"$STATE_DIR/lock"
flock -n 9 || exit 0

# If the pct inventory fails, do not silently record a healthy state.
if ! ct_list=$(pct list); then
    echo 'Cannot list LXC guests' >&2
    exit 1
fi

problems=()
declare -A owners=()
while IFS= read -r ct; do
    [[ -n "$ct" ]] || continue
    if ! config=$(timeout 12s pct config "$ct"); then
        problems+=("CT $ct: cannot read configuration")
        continue
    fi
    hostname=$(awk -F ': ' '$1=="hostname" {print $2; exit}' <<<"$config")
    hostname=${hostname:-unknown}
    # This monitor intentionally checks eth0 in all running guests.
    if ! addresses=$(timeout 12s pct exec "$ct" -- ip -o -4 addr show dev eth0); then
        problems+=("CT $ct ($hostname): cannot inspect eth0")
        continue
    fi
    mapfile -t ips < <(awk '$3=="inet" {print $4}' <<<"$addresses")
    case ${#ips[@]} in
        0) problems+=("CT $ct ($hostname): no IPv4 on eth0") ;;
        1) ;;
        *) problems+=("CT $ct ($hostname): ${#ips[@]} IPv4 addresses: ${ips[*]}") ;;
    esac
    for cidr in "${ips[@]}"; do
        ip=${cidr%%/*}
        if [[ -n "${owners[$ip]:-}" ]]; then
            problems+=("Duplicate IPv4 $ip on CT ${owners[$ip]} and CT $ct")
        else
            owners[$ip]=$ct
        fi
    done
done < <(awk 'NR>1 && $2=="running" {print $1}' <<<"$ct_list" | sort -n)

if (("${#problems[@]}" == 0)); then
    current=OK
else
    current=$(printf '%s\n' "${problems[@]}")
fi
previous=$(cat "$STATE_DIR/status" 2>/dev/null || true)
[[ "$current" != "$previous" ]] || exit 0
if [[ -z "$previous" && "$current" == OK ]]; then
    printf '%s\n' OK >"$STATE_DIR/status"
    echo 'Baseline: no LXC IPv4 anomalies found'
    exit 0
fi

if [[ "$current" == OK ]]; then
    title='Proxmox: IPv4 status recovered'
    message='All inspected running LXCs now have one IPv4 address on eth0, without inter-LXC duplication.'
    priority=5
else
    title='Proxmox: LXC IPv4 anomaly'
    message=$current
    priority=8
fi

# Persist only after successful Gotify delivery; failures are retried at the next run.
if curl --fail --silent --show-error --connect-timeout 5 --max-time 15 \
    -o /dev/null -H "X-Gotify-Key: $(cat "$TOKEN_FILE")" \
    --data-urlencode "title=$title" --data-urlencode "message=$message" \
    --data-urlencode "priority=$priority" "$GOTIFY_URL"; then
    printf '%s\n' "$current" >"$STATE_DIR/status"
    printf '%s\n%s\n' "$title" "$message"
else
    echo 'Gotify delivery failed; status not updated' >&2
    exit 1
fi
