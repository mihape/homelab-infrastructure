# Enterprise Home Lab & Infrastructure Portfolio

Welcome to my central infrastructure documentation repository. This document outlines the architecture, networking, and service deployment of my high-availability Proxmox VE home lab environment, built to enterprise security standards.

## Hardware Specifications
*   **Hypervisor Host:** Dell OptiPlex 7000 (Intel Core i5-12500)
*   **Core Router:** Xiaomi AX3600 running custom Immortal OpenWrt firmware
*   **Environment:** Proxmox Virtual Environment (PVE)

##  Virtualization & Services Topology
Services are logically separated based on resource demands and security profiles, utilizing a mix of lightweight Linux Containers (LXC - Debian) and full Virtual Machines (VM).

###  Core Infrastructure, Security & Routing
*   **Tailscale (Debian LXC):** Decentralized, Zero-Trust mesh VPN for secure remote administration.
*   **AdGuard Home (LXC):** Network-wide ad blocking and local DNS resolution.
*   **Nginx-UI (LXC):** Centralized Reverse Proxy handling internal routing and SSL termination.
*   **Vaultwarden (LXC):** Self-hosted, encrypted password management.
*   **Dashboards:** Homepage & Heimdall-Dashboard for unified service access.

###  Productivity, Cloud & Custom Apps
*   **ownCloud (VM):** Isolated file hosting and synchronization.
*   **Paperless-ngx (LXC):** Automated, OCR-powered document management system.
*   **PhysioVision (VM - Docker):** Custom-developed, private AI/Computer Vision application running in an isolated Docker environment.

###  Smart Home & Automation
*   **Home Assistant OS (VM):** Core automation hub with Google Home Backup integration.
*   **IoT Protocols:** MQTT Broker (Mosquitto), Zigbee2MQTT.
*   **Local AI:** Piper & Whisper for private, on-premise voice processing.

###  Media & Content Delivery
*   **Jellyfin & ErsatzTV (LXC):** Local media streaming and custom IPTV channel generation.
*   **Automation Stack (LXC):** qBittorrent, Sonarr, Radarr, Prowlarr, Overseerr, Bazarr.

###  Monitoring & Alerting
*   **Uptime Kuma (LXC):** Real-time status tracking and latency monitoring.
*   **Gotify (LXC):** Self-hosted push notification server linked with Uptime Kuma for instant Telegram alerts on service degradation.
*   **Grafana (LXC):** Deployed for future advanced metric visualization.
*   **Alpine-IT-Tools (LXC):** Lightweight container for rapid network troubleshooting.

##  Network Security & Segmentation (OpenWrt)
The network architecture adheres to enterprise security standards, implementing strict zone-based firewalling on the OpenWrt core router (Xiaomi AX3600):
*   **Air-Gapped IoT Zone:** Smart devices (IoT Interface `192.168.10.1/24`) are explicitly denied WAN (Internet) access via OpenWrt Zone Forwards (`IoT => REJECT`).
*   **Microsegmentation & ACLs:** Traffic from the isolated IoT zone to the main LAN is tightly controlled using port-specific forwarding rules (e.g., permitting only TCP 1883 for MQTT traffic and UDP 5353 for NestMini mDNS).
*   **Secrets Management:** All sensitive configurations and credentials are managed via `.env` files and explicitly excluded from version control via `.gitignore`.

##  Future Roadmap & Continuous Integration
- [ ] Migrate current OpenWrt zone-based isolation to strict 802.1Q VLAN tagging across the switch and Proxmox host (CCNA 2 SRWE objective).
- [ ] Transition manual configuration deployments to **Ansible** playbooks.
- [ ] Integrate **Jira Service Management** workflows for ticketing and change-management tracking of the lab.

---
> * **Development Note:** The core logic and boilerplate for specific automation scripts and configurations within this repository were rapidly prototyped utilizing AI-assisted tooling, with manual architectural oversight, testing, and deployment by the author.*
