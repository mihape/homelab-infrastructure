# LXC IPv4 accumulation and address conflicts

**Incident window:** 2026-09-18–19 (CEST)  
**Scope:** Proxmox VE, Debian LXCs, ImmortalWrt DHCP, LAN clients  
**Last verified state:** Services restored; initiating trigger **unknown**.

## Impact

A Windows laptop reported a duplicate DHCP address and subsequently fell back to an APIPA (169.254.x.x) IPv4 address; some IPv6 Internet connectivity still worked. LAN IPv4 access and Microsoft Teams were impaired. Some Xiaomi devices also lost connectivity. The problem affected more than a single container.

## Evidence

Multiple running LXC interfaces simultaneously accumulated **dozens of dynamic IPv4 addresses**, sometimes including addresses also present on another guest. The router's neighbor entry associated the laptop's conflicting address with the MAC of the Nginx Proxy Manager container, despite that container having a different intended reservation. Examples recorded during the investigation:

| Guest | IPv4 addresses on eth0 before intervention | Response |
| --- | ---: | --- |
| CT 109, Vaultwarden | 88 | Configure static IPv4; restart; one address after |
| CT 111, Homepage | 82 | Restart under DHCP; one address after |
| CT 115, Grafana | 80 | Restart under DHCP; one address after |
| CT 118, Cinephage | 0 | Restart; IPv4 restored |
| CT 120, ErsatzTV | 0 | Restart; IPv4 restored |
| CT 121, Zigbee2MQTT | 84 | Configure static IPv4; restart; one address after |
| CT 122, Bazarr | 83 | Restart under DHCP; one address after |
| CT 123, reverse proxy | More than 80 | Configure static IPv4; restart; one address after |

The guest counts are **incident snapshots**, not a present-day CMDB. CT 109, 121 and 123 received static guest addressing; other affected guests remained on DHCP.

Router-side logs showed repeated DHCPACK followed by DHCPDECLINE for a container. A short packet capture of an unaffected phone's renewal showed a response from the intended router, but it was **too brief to exclude** an intermittent rogue DHCP server. In examined guests, systemd-networkd reported eth0 as *unmanaged*; the proposed dual-network-manager explanation was not proven.

## Recovery and validation

The laptop was temporarily assigned an unused-at-the-time address outside the normal dynamic pool to regain LAN connectivity. Containers were then inspected and remediated one by one. Each affected guest returned to one IPv4 on eth0 or obtained a missing address. Xiaomi devices reconnected following the cleanup and device restart; **the router was not rebooted for this recovery**.

A Proxmox/Gotify monitor was added following the incident: [IP Watch runbook](../monitoring/proxmox-ip-watch.md).

Restarts corrected observed state but do **not** establish the root cause was eliminated. The laptop's temporary static setting should be removed once DHCP is verified healthy and its replacement address checked for conflicts.

## Read-only triage if it recurs

On Proxmox:

```bash
pct list
pct config 121
pct exec 121 -- ip -o -4 addr show dev eth0
pct exec 121 -- ps aux
pct exec 121 -- journalctl -b --no-pager
```

On ImmortalWrt:

```sh
uci show dhcp.lan
cat /tmp/dhcp.leases
logread | grep -Ei 'DHCPACK|DHCPDECLINE|DHCPNAK|DHCPOFFER' | tail -n 100
# Capture traffic during an affected client's actual renewal:
tcpdump -ni br-lan -e -vvv 'udp port 67 or udp port 68'
```

Record the **earliest** duplication, MAC addresses, DHCP server identifiers, assigned addresses, guest state and timestamps *before* restarting affected containers. Inspect guest network-manager and Proxmox network settings and audit DHCP servers. Do not infer an initiating defect from the restoration action alone.

## Open follow-up

- Capture the first reproducible address accumulation and full DHCP trace.
- Check MAC-to-reservation mapping and intentional versus accidental static addresses.
- Verify monitor behavior after lease renewals, not just after restarts.
- Recheck laptop DHCP configuration and storage/network dependencies.
- Keep sensitive configuration and credentials out of the public repository.
