# Homelab Infrastructure

A practical Proxmox VE homelab used to develop Linux, virtualization, networking, service operations and incident-response skills. This repository documents **observed operations, diagnostics, recovery actions and unfinished investigations**; it is not a claim of production high availability or an enterprise-certified security architecture.

## Platform and services

| Area | Tools and workloads documented |
| --- | --- |
| Virtualization | Proxmox VE, Linux containers (LXC) and VMs |
| Routing and remote access | Xiaomi AX3600 running ImmortalWrt, DHCP/DNS troubleshooting, Tailscale |
| Internal services | AdGuard Home, Vaultwarden, reverse proxy, Gotify |
| Smart home | Home Assistant OS, Zigbee2MQTT and MQTT |
| Media | Jellyfin and related automation services |
| Monitoring | Gotify and a custom Proxmox LXC IPv4 watcher |

This table summarizes technologies encountered in the documented lab. It is **not** a live configuration inventory, statement of continuous availability or exhaustive service list.

## Operational documentation

- [Incident register](docs/incidents/README.md): dated cases with the **last confirmed outcome**, diagnostics and outstanding questions.
- [Mass LXC IPv4 accumulation and DHCP conflicts](docs/incidents/2026-09-lxc-ip-conflicts.md): investigation, impact, measured guest address counts and staged remediation.
- [Proxmox IP Watch](docs/monitoring/proxmox-ip-watch.md): Gotify alerting, a systemd timer, verification commands and monitor limitations.
- [Proxmox storage exhaustion](docs/incidents/2026-08-23-proxmox-storage-full.md) and [thin-pool/Jellyfin recovery](docs/incidents/2026-08-29-thin-pool-jellyfin.md): capacity analysis and application integrity.
- [Tailscale/DHCP incident](docs/incidents/2026-08-25-tailscale-dhcp.md): distinguishing overlay reachability from guest IPv4 availability.

## Operating approach

1. Identify **impact** and capture reproducible evidence (logs, leases, addresses, capacity, timestamps).
2. Distinguish an **observation** from a hypothesis about the root cause.
3. Apply changes to one service or container at a time where feasible.
4. Verify both infrastructure state **and** application behavior.
5. Document unresolved issues and add monitoring where the incident exposed an observability gap.

Examples in the incident documents are **diagnostic references**, not scripts to run blindly against another environment. Some incidents were recovered operationally while their initiating causes remain unknown.

## Development roadmap

- [ ] Capture and version the verified live Proxmox IP Watch script without secrets.
- [ ] Add a monitored restore test and documented backup retention policy.
- [ ] Add root-filesystem and thin-pool capacity alerting.
- [ ] Inventory service roles, network segmentation and VM/LXC resources from the *current* configuration.
- [ ] Introduce ShellCheck and small reproducible automation where appropriate.

## Scope and security

This is a **public** repository. Do not commit access tokens, VPN keys, credentials, full backup archives, private security-sensitive configuration or unredacted service logs. Historical dates, guests and addresses are not guaranteed current.

Documentation and some automation were developed with AI assistance and reviewed through hands-on troubleshooting; the incident records distinguish user-confirmed results from unverified outcomes.
