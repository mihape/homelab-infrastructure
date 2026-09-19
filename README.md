# Homelab Infrastructure

A practical Proxmox VE homelab for Linux, Windows Server learning, virtualization, networking, service operations and incident response. The focus is on **troubleshooting, repeatable checks and clear documentation**, not counting installed applications.

I support Windows clients and day-to-day IT needs in a small-business environment while studying Engineering Information Technology. This repository records my **personal lab work**, not my employer's infrastructure, customer data or enterprise AD experience.

## What is here

| Area | Documented lab work |
| --- | --- |
| Virtualization | Proxmox VE, Linux containers (LXC), VMs, USB passthrough |
| Routing and remote access | ImmortalWrt, DNS/DHCP troubleshooting, Tailscale |
| Internal services | AdGuard Home, Vaultwarden, reverse proxy, Gotify |
| Smart home | Home Assistant OS, Zigbee2MQTT and MQTT |
| Media and storage | Jellyfin, filesystem and thin-pool troubleshooting |
| Monitoring | Proxmox LXC IPv4 watcher, Gotify alerts, systemd timer |
| Windows Server | VM 124 installed; Active Directory configuration **not started** |

This is not a live service inventory or a claim of production high availability. Historical observations and currently deployed configurations may differ.

## Evidence and operational documentation

- [Incident register](docs/incidents/README.md): dated cases, recorded symptoms, actions, verification and unresolved questions.
- [Mass LXC IPv4 conflicts](docs/incidents/2026-09-lxc-ip-conflicts.md): tracing a duplicate-address symptom across clients, DHCP and guest interfaces.
- [Proxmox IP Watch runbook](docs/monitoring/proxmox-ip-watch.md): notification path, timer verification and limits.
- [Portable IP Watch revision](scripts/proxmox-ip-watch.sh) and [mocked tests](tests/test-ip-watch.sh): versioned **proposed** implementation; not yet verified identical to the running host script.
- [Proxmox storage incident](docs/incidents/2026-08-23-proxmox-storage-full.md) and [Jellyfin follow-up](docs/incidents/2026-08-29-thin-pool-jellyfin.md): infrastructure and application recovery are separate validation steps.
- [Windows Server / AD lab](docs/labs/windows-server-ad.md): installed VM and explicitly **planned**, not completed, AD exercises.

## Troubleshooting approach

1. Establish user impact and the scope of the failure.
2. Capture relevant addresses, routes, storage usage, service state, logs and timestamps.
3. Separate observed evidence from hypotheses; change one component at a time where practical.
4. Validate both infrastructure and the affected application.
5. Record remaining uncertainty and turn recurring symptoms into monitoring or a reproducible lab.

## Next milestones

- [ ] Compare the live IP Watch file with the portable version, review secrets and perform controlled rollout.
- [ ] Capture a sanitized lab diagram and a point-in-time VM/LXC inventory.
- [ ] Build an **isolated** Windows Server AD DS/DNS + Windows client lab; then document actual OU/GPO and PowerShell exercises.
- [ ] Perform and document a real backup **restore test**.
- [ ] Add capacity alerting for the root filesystem and the thin pool.

## Public-repository safety

No credentials, VPN keys, real user or customer data, full backups or unredacted company configurations belong here. Company support experience and personal homelab work are distinct. Lab plans are not described as achievements, and a successful restart is not automatically proof of a root cause.

Documentation and some scripts were developed with AI assistance and verified through hands-on operations or explicitly labeled as proposals.
