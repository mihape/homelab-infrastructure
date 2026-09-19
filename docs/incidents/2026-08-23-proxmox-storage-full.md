# Proxmox-tárhely betelése és sikertelen LXC-indítások

**Dátum:** 2026-08-23 (CEST)  
**Érintett rendszer:** Proxmox host, helyi mentések, local-lvm thin pool, Jellyfin és más konténerek.  
**Állapot:** A host és a vendégek helyreállítása több lépésben történt; később további vizsgálat kellett.

## Mi történt?

Több LXC nem indult. A local-lvm thin pool telítettségét, valamint fájlrendszer- és I/O-hibákat észleltünk. Régebbi helyi mentésarchívumok is körülbelül 59–60 GB-ot foglaltak. Egyes régi archívumok eltávolítása után lett szabad hely a host fájlrendszerén, de nem minden vendég indult el azonnal. A Jellyfin CT 106 futását később sikerült megerősíteni.

**Két külön tárhelyterületet kell megkülönböztetni:** a `/var/lib/vz/dump` alatti mentések a host fájlrendszerét foglalják; a local-lvm thin pool telítettsége ettől különálló kérdés. A mentésfájlok törlése nem feltétlenül szabadít fel blokkokat a thin poolban. Az I/O-hiba önmagában nem bizonyít fizikai lemezhibát.

## Ellenőrző parancsok

```bash
df -h /
pvesm status
lvs -a -o lv_name,lv_size,data_percent,metadata_percent,lv_attr
pvesm list local --content backup
pct list
journalctl -k -n 150 --no-pager
```

Snapshot vagy vendégadat törlése előtt a mentéseket és a tényleges tárhely-hozzárendeléseket is ellenőrizni kell. A konténer elindulása után az alkalmazás és adatbázisa külön ellenőrzendő. [Későbbi Jellyfin-helyreállítás](2026-08-29-thin-pool-jellyfin.md).
