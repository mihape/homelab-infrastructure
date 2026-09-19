# Windows Server / Active Directory gyakorlólabor – folyamatban

**Utoljára jelzett állapot:** 2026-09-19. **Környezet:** Proxmox VM 124.

## Ami már elkészült

A Windows Server telepítve van a 124-es VM-ben; ez egy saját Active Directory-tanulólabor kezdete. **Az AD DS telepítését és a tartományvezérlő kialakítását még nem kezdtem el; tartomány, OU-k, GPO-k, DNS-integráció és tartományba léptetett kliens még nincs a laborban.** Ez saját laborgyakorlat, nem vállalati AD-üzemeltetési tapasztalat.

## Tervezett lépések – még nem elvégzett feladatok

1. Az operációs rendszer verziójának, frissítéseinek, licenc-/értékelési állapotának, VM-mentésének és erőforrásainak ellenőrzése.
2. **Külön lab-alhálózat vagy más módon izolált teszthálózat** kialakítása az AD-hez kapcsolódó DNS/DHCP előtt. Teszt-DHCP nem kerülhet a háztartási LAN-ra, és a háztartási DNS-t sem szabad véletlenül átirányítani.
3. Kiszámítható labor-IP-cím és DNS-névtér megtervezése.
4. AD DS és DNS beállítása, teszt-tartományvezérlő telepítése és állapotellenőrzése.
5. Teszt Windows-kliens tartományba léptetése; OU-k, felhasználók, csoportok és korlátozott GPO létrehozása.
6. Biztonságosan előidézhető DNS-, bejelentkezési vagy GPO-hiba reprodukálása; naplók, diagnózis, javítás és ellenőrzés dokumentálása.
7. PowerShell-parancsok és saját teszteredmények hozzáadása, anonimizált képernyőképekkel.

## Minden kész lépéshez szükséges bizonyíték

- Anonimizált hálózati/VM-ábra és rövid architektúradöntés.
- Verziók, tesztcélok, ténylegesen futtatott parancsok, várt és mért eredmények.
- DNS/AD állapotellenőrzések, **kipróbált** visszaállítás – nem pusztán egy snapshot neve.
- Legalább egy hibajegy jellegű esettanulmány és rövid üzemeltetési útmutató.

**Publikálási szabály:** Valós jelszó, tartománytitok, azonosítható felhasználó vagy céges belső környezet nem kerül a repóba. A tervezett munkát nem tüntetem fel befejezettként.
