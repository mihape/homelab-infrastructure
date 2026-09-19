# ImmortalWrt firmware upgrade: temporary Internet loss

**Date:** 2026-08-31 (CEST)  
**Scope:** Xiaomi AX3600 router.  
**Status:** Connectivity returned without the proposed corrective commands; transient cause unknown.

## Recorded observations

The router initially reported ImmortalWrt 24.10.4, target qualcommax/ipq807x and kernel 6.6.110. The user confirmed a successful move to 24.10.6. LAN remained accessible after the upgrade, while Internet was temporarily unavailable. Later tests of routing, WAN and DNS were successful; the user reported connectivity had returned without running the suggested repair commands. A later observation reports 25.12.1, but the exact upgrade date is not established by this case.

## Post-upgrade checklist

    cat /etc/openwrt_release
    ubus call system board
    ip -4 route
    ubus call network.interface.wan status
    logread | tail -n 100

Check the package manager on the **installed** firmware before updating packages; the later 25.12.1 system uses apk. Keep a compatible configuration backup and verify WAN, LAN, DHCP, DNS and remote access after upgrade.
