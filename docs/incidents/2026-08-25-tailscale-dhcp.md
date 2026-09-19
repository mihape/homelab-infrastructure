# Tailscale reachable while IPv4/LAN access failed

**Period:** 2026-08-25–31 (CEST)  
**Scope:** Proxmox, Tailscale, LXC network, ImmortalWrt/dnsmasq.  
**Status:** Access restored; initiating cause not proven.

## Symptoms

The Proxmox host was shown online in Tailscale and its 100.x address responded, but reaching local IPv4 services remotely failed. Investigation included subnet routing, IPv4 forwarding and SSH access. A later check found a guest without an eth0 IPv4 address. During the observed capture its DHCPDISCOVER did not receive an offer. The user confirmed access returned after a dnsmasq restart; the precise condition preventing an offer was not established.

A router-side reservation is not the same as a static address set inside the guest. These events should not be assumed to have the same root cause as the later September mass IPv4 accumulation.

## Useful checks

Proxmox host:

    tailscale status
    sysctl net.ipv4.ip_forward
    pct config 101
    pct exec 101 -- ip -4 -br addr
    pct exec 101 -- ip -4 route

ImmortalWrt:

    /etc/init.d/dnsmasq status
    logread | grep -Ei 'DHCPDISCOVER|DHCPOFFER|DHCPACK|DHCPDECLINE' | tail -n 100
    cat /tmp/dhcp.leases

If recurrence allows, preserve timestamps, MAC/reservation mapping, offers and routing state **before** restarting services.
