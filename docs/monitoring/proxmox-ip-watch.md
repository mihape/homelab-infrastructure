# Proxmox IP Watch – üzemeltetési leírás

**Bevezetés:** 2026-09-19. Ezen a napon a ténylegesen futó scriptet is megkaptam ellenőrzésre. A GitHubon tárolt változat **továbbfejlesztési javaslat, még nem lett telepítve**.

## Cél és működés

A [tömeges LXC IPv4-ütközés](../incidents/2026-09-lxc-ip-conflicts.md) után a Proxmox hoston futó figyelő ellenőrzi a futó konténerek `eth0` interfészének IPv4-címeit. Jelzi a hiányzó vagy többes címzést, illetve ha a megvizsgált konténerek közül kettő azonos IPv4-et használ. **Nem javít és nem indít újra automatikusan**.

## A Proxmoxon igazolt telepítés

| Összetevő | Elérési út vagy beállítás |
| --- | --- |
| Élő script | `/usr/local/sbin/proxmox-ip-watch.sh` |
| Token | `/etc/proxmox-ip-watch/token` (csak root; **nem kerül Gitbe**) |
| Állapot | `/var/lib/proxmox-ip-watch/status` |
| Szolgáltatás | `proxmox-ip-watch.service`, oneshot |
| Időzítő | `proxmox-ip-watch.timer`, ötpercenként |
| Értesítés | Gotify alkalmazástoken; állapotváltozás és helyreállás jelzése |

Az élő fájl **a scripten belül** tartalmaz egy helyi Gotify-URL-t, a tokent külön fájlból olvassa. Kihagyja a `net0` alatt `ip=manual` beállítású konténereket, a `pct list` kimenetét process substitution útján dolgozza fel. `set -uo pipefail` beállítással, egymás utáni `pct exec` hívásokkal működik; az állapotot csak sikeres Gotify-küldés után menti. A megosztott fájl **nem tartalmazta a tokent**.

Az eredeti, `OnUnitActiveSec` alapú időzítőnél `NEXT: -` jelent meg. Ezt `OnCalendar=*-*-* *:00/5:00` ütemezésre cseréltük; utána a következő futási időt a felhasználó megerősítette. A sikeresen befejezett oneshot szolgáltatás `inactive (dead)` állapota normális: a kilépési eredményt **és** a timer következő időpontját is ellenőrizni kell.

## GitHubon verziókezelt, javasolt változat

A [`scripts/proxmox-ip-watch.sh`](../../scripts/proxmox-ip-watch.sh) egy **hordozhatóbb, külön fejlesztett változat**, nem azonos az igazoltan futó hostfájllal. Külső, root által kezelt `GOTIFY_URL`-konfigurációt, `flock` alapú futási zárolást, `timeout` alapú konténerenkénti időkorlátot és sikertelen konténerlista-lekérdezés esetére külön hibakezelést ad hozzá. Fontos eltérés: ez a verzió jelenleg **az `ip=manual` beállítású futó konténereket is ellenőrzi**; bevezetés előtt át kell gondolni, mely vendégek tartoznak a figyelésbe.

A [szimulált tesztek](../../tests/test-ip-watch.sh) kipróbálják a normál állapotot, a hiányzó/többszörös/ütköző IP-címeket, a helyreállást, az elérhetetlen vendéget, a hibás konténerlistát és a sikertelen értesítést. A GitHub Actions Bash-szintaxis-, működési és ShellCheck-ellenőrzése 2026-09-19-én **sikeresen lefutott**, miután a tesztindítást javítottuk. **Ez nem bizonyítja a valódi Proxmox- és Gotify-kapcsolat működését.**

A repóban lévő változatot **nem állítom be élesként**. Telepítése előtt biztonsági másolatot kell készíteni a futó fájlról, áttekinteni a működésbeli eltéréseket, kontrolláltan kipróbálni, végül ellenőrizni az időzítőt.

Csak a saját hoston létrehozandó konfigurációs példa (nem valós cím vagy titok):

```bash
# /etc/proxmox-ip-watch/config – root tulajdon, 600-as jogosultság
GOTIFY_URL='https://your-gotify.example/message'
```

A token továbbra is a `/etc/proxmox-ip-watch/token` fájlban marad, 600-as jogosultsággal. **Egyik helyi fájl sem kerül a repóba.**

## Ellenőrző parancsok

```bash
bash -n scripts/proxmox-ip-watch.sh
bash tests/test-ip-watch.sh
systemctl status proxmox-ip-watch.service --no-pager
systemctl status proxmox-ip-watch.timer --no-pager
systemctl list-timers --all proxmox-ip-watch.timer
journalctl -u proxmox-ip-watch.service -n 50 --no-pager
```

Egy korai éles futás mérési adata: körülbelül **20 másodperc tényleges futási idő, 19,5 CPU-másodperc és 121 MiB maximális memóriafoglalás**. A sok `pct exec` hívás később optimalizálást indokolhat.

## Hibakeresés és korlátok

- Gotify HTTP 401 esetén ellenőrizni kell, hogy **alkalmazástoken** került-e a fájlba; a tokent tilos kiírni vagy publikálni.
- A kezdeti telepítés helyi HTTP-t használt; ahol lehetséges, hitelesített HTTPS-végpont javasolt.
- Timer-módosítás után `systemctl daemon-reload`, az időzítő újraindítása és a `NEXT` oszlop ellenőrzése szükséges.
- Az állapotfájl az **azonos hibajelentéseket** szűri, nem garantál egyetlen értesítést egy változó állapotú incidens alatt.
- Csak a futó vendégek `eth0` interfésze szerepel: más LAN-eszközök, további interfészek és időszakos DHCP-hibák kimaradhatnak.
- Ha a Gotify nem érhető el, ezen keresztül a figyelő sem tud riasztani. Külön heartbeat/független monitor későbbi feladat.

## Következő feladat

A javasolt viselkedésbeli eltérések áttekintése az éles script cseréje előtt; DHCPDECLINE-események figyelése a hiba korábbi észleléséhez; ellenőrzött hiba–riasztás–helyreállás teszt dokumentálása.
