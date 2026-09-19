# Thin pool tárhelyfelszabadítás és Jellyfin-adatbázis helyreállítása

**Dátum:** 2026-08-29 (CEST)  
**Érintett rendszer:** Proxmox local-lvm, HAOS/PhysioVision VM-ek, Jellyfin LXC.  
**Állapot:** A VM-ek és a Jellyfin Next Up funkciója helyreállt; az Intro Skipper az utolsó ellenőrzéskor még hibás volt.

## Megfigyelt helyreállítás

A thin pool foglaltsága a tisztítás előtt körülbelül 92% volt, LXC TRIM után 74,46%, VM TRIM után pedig 70,08%. Ezek adott pillanatban mért értékek, nem jelentenek garanciát a későbbi kapacitásra. A HAOS és a PhysioVision VM korábban I/O-hibás állapotba került, később ismét futottak.

A Jellyfin fő SQLite-adatbázisa sérült volt. A helyreállítás **másolaton** történt; az újraépített adatbázis átment az `integrity_check` ellenőrzésen, a Jellyfin elindult, a Next Up visszatért. Ettől különállóan az Intro Skipper DLL `System.BadImageFormatException / Bad IL format` hibát adott; a bővítmény hibájának végleges javítását **nem igazoltuk**.

## Biztonságos eljárás

```bash
pvesm status
lvs -a -o lv_name,lv_size,data_percent,metadata_percent,lv_attr
qm list
pct list
journalctl -k -n 100 --no-pager
```

TRIM előtt ellenőrizni kell az alatta lévő tárolót és fájlrendszert, valamint a thin pool **adat- és metaadat-foglaltságát**. SQLite-sérülésnél a szolgáltatás leállítása, adatbázismásolat készítése, a másolat helyreállítása és a `PRAGMA integrity_check` után az alkalmazás viselkedését is ellenőrizni kell. Adatmódosítás előtt visszaállítási pont szükséges.

**Következő feladat:** Az Intro Skipper verziójának és működésének ellenőrzése; kapacitásriasztások és kipróbált visszaállítási eljárás.
