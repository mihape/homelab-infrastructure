# Incident register

This register captures hands-on troubleshooting in a Proxmox VE homelab. Events are historical snapshots, **not** a verified current inventory or evidence that every root cause is fixed.

| Date (CEST) | Case | Last verified state |
| --- | --- | --- |
| 2026-08-09 | [Zigbee2MQTT / USB passthrough](2026-08-09-zigbee2mqtt-usb.md) | Configuration adjusted; end-to-end recovery not verified |
| 2026-08-10 | [AdGuard filesystem pressure](2026-08-10-adguard-rootfs.md) | Working after rootfs expansion |
| 2026-08-23 | [Proxmox storage exhaustion](2026-08-23-proxmox-storage-full.md) | Guests brought back in stages; further recovery needed |
| 2026-08-25–31 | [Tailscale and IPv4/DHCP availability](2026-08-25-tailscale-dhcp.md) | Access restored; trigger unconfirmed |
| 2026-08-29 | [Thin pool and Jellyfin database](2026-08-29-thin-pool-jellyfin.md) | VMs and Jellyfin Next Up recovered; Intro Skipper unresolved |
| 2026-08-31 | [ImmortalWrt upgrade](2026-08-31-immortalwrt-upgrade.md) | Internet returned; transient cause unknown |
| 2026-09-18–19 | [Mass LXC IPv4 conflicts](2026-09-lxc-ip-conflicts.md) | Services recovered; initiating cause unknown |
| 2026-09-19 | [Backups filling Proxmox root](2026-09-19-proxmox-backup-space.md) | Storage pressure identified; cleanup not verified |

See [Proxmox IP Watch](../monitoring/proxmox-ip-watch.md) for the preventive monitor introduced after the September incident.

## Incident documentation principles

- Separate observed symptoms, evidence, remediation, verification and unresolved hypotheses.
- Never treat restarting a guest as proof of a permanent fix.
- Record where evidence ended rather than inventing a resolution.
- Do not publish full device inventories, live credentials, private keys, Gotify tokens or unredacted logs.

A separate historical observation: SMB/X-plore access timed out on 2026-08-10, but the container identity and resolution were not established well enough for a full case study.
