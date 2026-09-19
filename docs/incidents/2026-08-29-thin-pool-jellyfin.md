# Thin-pool reclamation and Jellyfin database recovery

**Date:** 2026-08-29 (CEST)  
**Scope:** Proxmox local-lvm, HAOS/PhysioVision VMs, Jellyfin LXC.  
**Status:** VMs and Jellyfin Next Up returned; Intro Skipper remained unresolved at last check.

## Observed recovery

Thin-pool usage was approximately 92% before cleanup, around 74.46% after LXC TRIM and around 70.08% after VM TRIM. These are point-in-time observations, not future capacity guarantees. HAOS and PhysioVision had experienced I/O-error states and later ran again.

Jellyfin's main SQLite database was malformed. Recovery was performed on a copy; the rebuilt database passed integrity_check, Jellyfin started and Next Up returned. Separately, Intro Skipper's DLL raised System.BadImageFormatException / Bad IL format. Its underlying plugin failure was **not** confirmed repaired.

## Safe workflow

    pvesm status
    lvs -a -o lv_name,lv_size,data_percent,metadata_percent,lv_attr
    qm list
    pct list
    journalctl -k -n 100 --no-pager

Verify backing storage and filesystem support before TRIM; check data **and metadata** pool consumption. For SQLite corruption: stop the service, copy the database, recover the copy, run PRAGMA integrity_check, then validate application behavior. Maintain a restore point before changing data.

**Follow-up:** Confirm plugin version and Intro Skipper health; implement capacity alerts and a tested restore procedure.
