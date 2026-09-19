# Proxmox IP Watch

**Deployed:** 2026-09-19. The live host script and the versioned example are **not yet verified identical**.

## Purpose

Following the [mass LXC IPv4 conflict](../incidents/2026-09-lxc-ip-conflicts.md), a host-side check monitors IPv4 addresses on `eth0` of running LXC guests. It reports zero or multiple IPv4 addresses and duplicates among inspected containers. It does not automatically repair or restart them.

## Deployment record

| Component | Location or setting |
| --- | --- |
| Live script | `/usr/local/sbin/proxmox-ip-watch.sh` |
| Token | `/etc/proxmox-ip-watch/token` (root-only; **do not commit**) |
| State | `/var/lib/proxmox-ip-watch/status` |
| Service | `proxmox-ip-watch.service`, oneshot |
| Timer | `proxmox-ip-watch.timer`, every five minutes |
| Notifications | Gotify application token; alert on changed problem report and recovery |

The original timer displayed `NEXT: -` using `OnUnitActiveSec`. It was changed to `OnCalendar=*-*-* *:00/5:00`, and the operator confirmed a next execution was scheduled. A completed oneshot service normally reads `inactive (dead)`; inspect its result **and** the timer.

## Version-controlled proposed revision

[`scripts/proxmox-ip-watch.sh`](../../scripts/proxmox-ip-watch.sh) is a **portable, not-yet-deployed revision**. It adds an explicit configuration file, non-overlapping execution via `flock`, bounded per-guest `pct` calls, error reporting and state persistence only after successful Gotify delivery. [Mock tests](../../tests/test-ip-watch.sh) exercise normal state, duplicate/multiple/missing IPs, recovery, an inaccessible guest, inventory errors and a failed notification.

The repository script is intentionally **not advertised as running on the host**. Compare against the host file before any deployment; create a backup, inspect config, run a single controlled test, and only then consider replacing the live version.

Local-only configuration example (not a real address or secret):

```bash
# /etc/proxmox-ip-watch/config, chmod 600, root-owned
GOTIFY_URL='https://your-gotify.example/message'
```

The token remains in `/etc/proxmox-ip-watch/token` with mode 600. Neither file belongs in Git.

## Verification

```bash
bash -n scripts/proxmox-ip-watch.sh
bash tests/test-ip-watch.sh
systemctl status proxmox-ip-watch.service --no-pager
systemctl status proxmox-ip-watch.timer --no-pager
systemctl list-timers --all proxmox-ip-watch.timer
journalctl -u proxmox-ip-watch.service -n 50 --no-pager
```

An early live run took approximately **20 seconds wall time, 19.5 CPU-seconds and 121 MiB peak memory**. Repeated `pct exec` calls may need optimization as guest count grows.

## Troubleshooting and limitations

- HTTP 401 from Gotify: check whether the file contains the **application** token; never print or publish it.
- The initial deployment used local HTTP; prefer a trusted HTTPS endpoint where practical.
- After timer edits: `systemctl daemon-reload`, restart the timer, inspect `NEXT`.
- The state file suppresses **identical reports**, not every notification throughout an evolving incident.
- This checks only running guests and their `eth0`: other LAN hosts, other interfaces, intentionally IPv6-only services and intermittent DHCP failures are not covered.
- When Gotify itself is down, this watcher cannot alert through Gotify. Independent heartbeat monitoring is future work.

## Follow-up

Obtain the actual host script (without any token) and compare it against the versioned proposal. Monitor repeated DHCPDECLINE events to identify early symptoms. Document a controlled failure-and-recovery alert test.
