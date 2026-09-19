# Proxmox IP Watch

**Deployed:** 2026-09-19. This is an operational record, not a copy of the live script.

## Purpose

Following the [mass LXC IPv4 conflict](../incidents/2026-09-lxc-ip-conflicts.md), a host-side check monitors the IPv4 addresses on `eth0` of running LXC guests. It reports zero or multiple IPv4 addresses and duplicates among inspected containers. It does not automatically repair or restart them. Other LAN devices and deliberately IPv6-only guests are outside its reliable detection scope.

## Deployment record

| Component | Location or setting |
| --- | --- |
| Script | `/usr/local/sbin/proxmox-ip-watch.sh` |
| Token | `/etc/proxmox-ip-watch/token` (root-only; **do not commit**) |
| State | `/var/lib/proxmox-ip-watch/status` |
| Service | `proxmox-ip-watch.service`, oneshot |
| Timer | `proxmox-ip-watch.timer`, every five minutes |
| Notifications | Gotify application token; send on changed problem report and recovery |

The timer originally displayed `NEXT: -` with `OnUnitActiveSec`. It was changed to `OnCalendar=*-*-* *:00/5:00`, and the operator confirmed that a next execution was scheduled. A completed oneshot service normally reads `inactive (dead)`; inspect its result as well as the timer.

## Verification

```bash
systemctl status proxmox-ip-watch.service --no-pager
systemctl status proxmox-ip-watch.timer --no-pager
systemctl list-timers --all proxmox-ip-watch.timer
journalctl -u proxmox-ip-watch.service -n 50 --no-pager
systemctl start proxmox-ip-watch.service
```

An early run took approximately 20 seconds wall time, 19.5 CPU-seconds and 121 MiB peak memory. Repeated `pct exec` calls may need optimization as guest count grows.

## Troubleshooting and limitations

- HTTP 401 from Gotify: check whether the stored token is the **application** token and whether the shell accidentally captured a pasted command. Never print or publish the token.
- Confirm Gotify network reachability and service listener; prefer a verified HTTPS endpoint rather than plain LAN HTTP where practical.
- Check token file permissions with `stat -c '%a %U %G' /etc/proxmox-ip-watch/token`.
- After timer edits run `systemctl daemon-reload`, restart the timer and inspect `NEXT`.
- The state file suppresses identical reports, **not** every message throughout an evolving incident.
- A successful check cannot notify if Gotify is down; a separate heartbeat/external monitor is a future improvement.

## Follow-up

Version the verified live script in `scripts/` after checking it for secrets and run ShellCheck. Consider monitoring DHCPDECLINE events to capture the start of the problem. This page does not pretend the exact host script is already in Git.