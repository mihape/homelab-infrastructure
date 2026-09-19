#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/bin" "$TMP/state"
cat > "$TMP/bin/pct" <<'MOCK'
#!/usr/bin/env bash
set -e
case "$1" in
  list)
    [[ "${CASE:-}" != list_fail ]] || exit 42
    printf 'VMID Status Lock Name\n101 running - alpha\n102 running - beta\n'
    ;;
  config) printf 'hostname: %s\n' "guest-$2" ;;
  exec)
    [[ "${CASE:-}" != inspect_fail || "$2" != 102 ]] || exit 2
    if [[ "$2" == 101 ]]; then
      printf '2: eth0    inet 10.10.0.11/24 scope global eth0\n'
      [[ "${CASE:-}" != multi ]] || printf '2: eth0    inet 10.10.0.12/24 scope global eth0\n'
    else
      [[ "${CASE:-}" != none ]] || exit 0
      addr=10.10.0.12
      [[ "${CASE:-}" != duplicate ]] || addr=10.10.0.11
      printf '2: eth0    inet %s/24 scope global eth0\n' "$addr"
    fi
    ;;
  *) exit 43 ;;
esac
MOCK
cat > "$TMP/bin/curl" <<'MOCK'
#!/usr/bin/env bash
printf 'sent\n' >>"$CALLS"
[[ "${FAIL_CURL:-}" != 1 ]]
MOCK
chmod +x "$TMP/bin/pct" "$TMP/bin/curl"
printf 'GOTIFY_URL=http://example.invalid/message\n' > "$TMP/config"
printf 'test-token\n' > "$TMP/token"
export PATH="$TMP/bin:$PATH" CALLS="$TMP/calls" IP_WATCH_CONFIG="$TMP/config" IP_WATCH_TOKEN_FILE="$TMP/token" IP_WATCH_STATE_DIR="$TMP/state"
# GitHub Contents API stores new files without an executable bit; invoke Bash explicitly.
watch() { bash "$ROOT/scripts/proxmox-ip-watch.sh" >/dev/null 2>&1; }
count() { [[ -f "$CALLS" ]] && wc -l < "$CALLS" || echo 0; }
assert_count() { [[ "$(count)" == "$1" ]] || { echo "FAIL: expected $1 messages, got $(count)"; exit 1; }; }
CASE=normal watch; assert_count 0
CASE=normal watch; assert_count 0
CASE=multi watch; assert_count 1
CASE=multi watch; assert_count 1
CASE=normal watch; assert_count 2
CASE=duplicate watch; assert_count 3
CASE=none watch; assert_count 4
CASE=inspect_fail watch; assert_count 5
CASE=list_fail; export CASE; if watch; then echo 'FAIL: pct list failure hidden'; exit 1; fi; assert_count 5
CASE=normal; FAIL_CURL=1; export FAIL_CURL; if watch; then echo 'FAIL: curl failure hidden'; exit 1; fi; assert_count 6; unset FAIL_CURL
CASE=normal watch; assert_count 7
[[ "$(cat "$TMP/state/status")" == OK ]] || { echo 'FAIL: unexpected final status'; exit 1; }
printf '%s\n' 'PASS: baseline, dedup, recovery, multi-IP, duplicate-IP, no-IP, inaccessible guest, inventory failure, delivery retry'
