# Proxmox storage exhaustion and failed guest startups

**Date:** 2026-08-23 (CEST)  
**Scope:** Proxmox host, local backup storage, local-lvm thin pool, Jellyfin and other LXCs.  
**Status:** Host/guest startup recovered in stages; later follow-up required.

## What happened

Several LXCs failed to start. The local-lvm thin pool was reported full, and filesystem/I/O errors appeared. Old local backup archives also occupied roughly 59–60 GB. Removing selected older archives recovered host filesystem space, but not every guest started immediately. Jellyfin CT 106 was subsequently confirmed running.

These observations cover **two distinct capacity domains**: backup files under /var/lib/vz/dump consume the host filesystem; local-lvm thin-pool usage is separate. Freeing host backup space does not necessarily free thin-pool blocks. I/O errors alone do not prove that a physical disk is defective.

## Verification checklist

    df -h /
    pvesm status
    lvs -a -o lv_name,lv_size,data_percent,metadata_percent,lv_attr
    pvesm list local --content backup
    pct list
    journalctl -k -n 150 --no-pager

Check backups and live storage mapping before deleting snapshots or guest data. Validate application/database health after a guest starts. See the [follow-up](2026-08-29-thin-pool-jellyfin.md).
