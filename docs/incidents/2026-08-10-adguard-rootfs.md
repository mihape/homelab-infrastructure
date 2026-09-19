# AdGuard Home: LXC root filesystem pressure

**Date:** 2026-08-10 (CEST)  
**Scope:** AdGuard Home CT 107, DNS availability.  
**Status:** Service recovered following filesystem expansion; initiating growth pattern not established.

## Evidence

The LXC was running but AdGuard and IPv4 connectivity were not functioning normally. Its 2 GB root filesystem was nearly full. After increasing it to 6 GB, the service worked again; approximately 1.8 GB was in use. The observation supports a storage-capacity problem but does not prove the full filesystem was the sole cause of missing IPv4.

## Read-only checks

    pct config 107
    pct exec 107 -- df -h /
    pct exec 107 -- du -xhd1 /opt /usr /var 2>/dev/null
    pct exec 107 -- ip -4 -br addr
    pct exec 107 -- systemctl --failed

Review retention and disk usage before deleting query logs or configuration. DNS is an infrastructure dependency: document how clients behave if CT 107 is unavailable.
