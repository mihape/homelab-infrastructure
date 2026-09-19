# Proxmox IP Watch

**Introduced:** 2026-09-19. The operator supplied the live script for review on this date; the versioned script is a **proposed revision, not yet deployed**.

## Purpose

Following the [mass LXC IPv4 conflict](../incidents/2026-09-lxc-ip-conflicts.md), a host-side check monitors IPv4 addresses on `eth0` of running LXC guests. It reports zero or multiple IPv4 addresses and duplicates among inspected containers. It does not automatically repair or restart them.

## Confirmed host deployment

| Component | Location or setting |
| --- | --- |
| Live script | `/usr/local/sbin/proxmox-ip-watch.sh` |
| Token | `/etc/proxmox-ip-watch/token` (root-only; **do not commit**) |
| State | `/var/lib/proxmox-ip-watch/status` |
| Service | `proxmox-ip-watch.service`, oneshot |
| Timer | `proxmox-ip-watch.timer`, every five minutes |
| Notifications | Gotify application token; alert on changed problem report and recovery |

The live file sets a local LAN Gotify URL **inside the script**, reads the application token from its separate local file, skips containers whose `net0` has `ip=manual`, and queries `pct list` through process substitution. It uses `set -uo pipefail`, sequential `pct exec` calls and state changes only on successful Gotify delivery. The operator posted the file, **not the token**.

The original timer displayed `NEXT: -` with `OnUnitActiveSec`. It was changed to `OnCalendar=*-*-* *:00/5:00`, and the operator confirmed a next execution was scheduled. A completed oneshot service normally reads `inactive (dead)`; inspect its result **and** the timer.

## Version-controlled proposed revision

[`scripts/proxmox-ip-watch.sh`](../../scripts/proxmox-ip-watch.sh) is a **portable revision**, distinct from the verified live host file. It adds a root-controlled external `GOTIFY_URL` configuration, `flock` to avoid overlapping runs, bounded per-guest calls using `timeout`, and explicit handling of failed guest inventory. Unlike the live version it currently inspects all running guests, including any configured with `ip=manual`; review the monitoring policy before deploying.

[Mock tests](../../tests/test-ip-watch.sh) exercise normal state, duplicate/multiple/missing IPs, recovery, an inaccessible guest, inventory errors and a failed notification. GitHub Actions passed its Bash syntax, mocked behavior and ShellCheck steps on 2026-09-19 after fixing the test runner to invoke Bash explicitly. **This CI run did not validate the live Proxmox environment or real Gotify delivery.**

The repository script is **not** advertised as running on the host. Before deployment, back up the live file, review the behavioral differences and configuration, run a controlled test, and verify the timer. Never copy a public example over an operational script without an explicit rollout.

Local-only configuration example (not a real address or secret):

```bash
# /etc/proxmox-ip-watch/config — root-owned, mode 600
GOTIFY_URL='https://your-gotify.example/message'
```

The token stays at `/etc/proxmox-ip-watch/token` with mode 600. Neither file belongs in Git.

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
- Only running guests and their `eth0` are checked: other LAN hosts, other interfaces and intermittent DHCP failures are not covered.
- Gotify cannot alert through itself if Gotify is down; independent heartbeat monitoring is future work.

## Follow-up

Review the proposed behavioral changes before switching the live file. Monitor repeated DHCPDECLINE events to identify early symptoms, and document a controlled failure-and-recovery alert test.
