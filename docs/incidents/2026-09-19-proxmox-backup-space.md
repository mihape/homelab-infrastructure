# Helyi mentések miatt megtelt a Proxmox root fájlrendszere

**Dátum:** 2026-09-19 (CEST)  
**Érintett rendszer:** Proxmox helyi mentéstárolója, nas/nas2 elérhetőség.  
**Állapot:** A tárhelyproblémát azonosítottam; a mentések törléséről és a végleges helyreállásról nincs rögzített utóellenőrzés.

## Bizonyítékok

A root fájlrendszer megtelt (összesen 68 GB), a `/var` körülbelül 62 GB-ot foglalt. A `/var/lib/vz/dump` mentéskönyvtár körülbelül 60 GB archívumot tartalmazott; a journal kisebb volt. Az inode-foglaltság alacsony maradt, tehát **nem inode-, hanem blokkkapacitási** problémáról volt szó. A `nas` és `nas2` külső tárolók ekkor nem voltak elérhetők. A `local` és `local-lvm` foglaltsága külön vizsgálandó.

Két régebbi mentés eltávolítása szerepelt a hibaelhárítási tervben. A végrehajtást és az utána mért szabad helyet nem rögzítettem, ezért a javítást nyitott feladatként kezelem.

## Biztonságos ellenőrzések

```bash
df -h /
du -xhd1 /var/lib/vz /var/log 2>/dev/null
pvesm status
pvesm list local --content backup
cat /etc/pve/storage.cfg
find /var/lib/vz/dump -maxdepth 1 -type f -printf '%TY-%Tm-%Td %10s %f\n' | sort
```

Mentés törlése előtt ellenőrizni kell a megőrzési szabályt, egy másik **kipróbált** visszaállítási lehetőséget és az ütemezett mentések célhelyét. Kivizsgálandó a nas/nas2 elérhetetlensége; indokolt a root fájlrendszer és a thin pool kapacitásriasztása.
