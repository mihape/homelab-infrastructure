# Tailscale online, de az IPv4/LAN-szolgáltatások nem elérhetők

**Időszak:** 2026-08-25–31 (CEST)  
**Érintett rendszer:** Proxmox, Tailscale, LXC-hálózat, ImmortalWrt/dnsmasq.  
**Állapot:** Az elérés helyreállt, a kiváltó ok nem bizonyított.

## Tünetek

A Proxmox Tailscale-ben online volt, a 100.x címe válaszolt, a helyi IPv4-szolgáltatásokat azonban távolról nem lehetett elérni. A vizsgálat érintette az alhálózati útválasztást, IPv4-forwardingot és SSH-t. Egy későbbi ellenőrzésnél egy vendég `eth0` interfészén nem volt IPv4-cím. A rögzített forgalomban a DHCPDISCOVER kérésre nem érkezett ajánlat. A dnsmasq újraindítása után az elérés visszatért, de az ajánlat hiányának pontos oka nem derült ki.

A routeren beállított DHCP-foglalás **nem ugyanaz**, mint a vendégen beállított statikus IP-cím. Nem bizonyított, hogy ez az eset ugyanabból az okból történt, mint a szeptemberi tömeges IP-címhalmozás.

## Hasznos ellenőrzések

Proxmox host:

```bash
tailscale status
sysctl net.ipv4.ip_forward
pct config 101
pct exec 101 -- ip -4 -br addr
pct exec 101 -- ip -4 route
```

ImmortalWrt:

```sh
/etc/init.d/dnsmasq status
logread | grep -Ei 'DHCPDISCOVER|DHCPOFFER|DHCPACK|DHCPDECLINE' | tail -n 100
cat /tmp/dhcp.leases
```

Ismétlődéskor, lehetőség szerint **újraindítás előtt** érdemes rögzíteni az időpontokat, MAC-címeket, foglalásokat, DHCP-ajánlatokat és az útválasztási állapotot.
