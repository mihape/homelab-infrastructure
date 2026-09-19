# Proxmox root filesystem filled by local backups

**Date:** 2026-09-19 (CEST)  
**Scope:** Proxmox local backup storage, nas/nas2 storage availability.  
**Status:** Capacity pressure identified; deletion and service recovery unverified in the available record.

## Evidence

The root filesystem was reported full (68 GB total) and /var accounted for approximately 62 GB. The backup directory /var/lib/vz/dump held around 60 GB of archives; the journal was smaller. Inode consumption was low, so this was a **block-capacity** issue rather than inode exhaustion. The external nas and nas2 stores were unavailable at the check. local and local-lvm consumption must be diagnosed independently.

Removing two older backups was proposed, but their actual removal was not confirmed in the record. Do not describe that remediation as completed.

## Safe checks

    df -h /
    du -xhd1 /var/lib/vz /var/log 2>/dev/null
    pvesm status
    pvesm list local --content backup
    cat /etc/pve/storage.cfg
    find /var/lib/vz/dump -maxdepth 1 -type f -printf '%TY-%Tm-%Td %10s %f\n' | sort

Before deleting backups, confirm retention, another **tested** restore point and the configured scheduled backup destination. Investigate why nas/nas2 were unavailable; configure alerts for root and thin-pool usage.
