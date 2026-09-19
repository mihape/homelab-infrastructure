# Proxmox IP Watch – üzemeltetési dokumentáció

**Üzembe helyezés:** 2026. szeptember 19.  
**Cél:** A korábbi [LXC IP-ütközéses incidens](../incidents/2026-09-lxc-ip-conflicts.md) után a rendellenes IPv4-címzés korai észlelése.

## Működés

A Proxmox hoston futó script ötpercenként ellenőrzi a futó LXC-k `eth0` interfészét. Riaszt, ha egy vizsgált konténernek nincs IPv4-címe, több IPv4-címet kapott, vagy a vizsgált konténerek között címütközés található. Az értesítések Gotifyra érkeznek. **A figyelő nem indít újra konténert, és nem módosít hálózati beállítást.**

## Telepített változat

| Összetevő | Beállítás |
| --- | --- |
| Script | `/usr/local/sbin/proxmox-ip-watch.sh` |
| Gotify-token | `/etc/proxmox-ip-watch/token` – csak root olvashatja; nem kerül Gitbe |
| Állapotfájl | `/var/lib/proxmox-ip-watch/status` |
| Systemd service | `proxmox-ip-watch.service` (`Type=oneshot`) |
| Systemd timer | `proxmox-ip-watch.timer`, ötpercenként |
| Ütemezés | `OnCalendar=*-*-* *:00/5:00` |

A telepített script helyi hálózati Gotify-címet használ, a tokent külön fájlból olvassa, és kihagyja a `net0` alatt `ip=manual` beállítású konténereket. A problémák szövegét az állapotfájlban tárolja: változatlan jelentésnél nem küld új üzenetet, sikeres helyreállásnál külön értesít. Sikertelen Gotify-küldéskor nem írja felül az előző állapotot.

### Az időzítő beállításának tanulsága

A kezdeti, `OnUnitActiveSec=5min` beállítás mellett a `systemctl list-timers` kimenetében `NEXT: -` szerepelt. A naptári időzítésre váltás után a következő futás időpontja megjelent. Az egyedi ellenőrzés sikeres lefutása **nem helyettesíti** az időzítő állapotának vizsgálatát.

## Verziókezelt fejlesztési változat

A [`scripts/proxmox-ip-watch.sh`](../../scripts/proxmox-ip-watch.sh) a működő megoldás **külön fejlesztett, még nem telepített változata**. A jelenlegi hostfájlt nem cseréltem le vele.

A repóban található változat külső konfigurációból olvassa a Gotify URL-jét, `flock` segítségével kizárja az átfedő futásokat, `timeout` időkorlátot állít az egyes `pct` lekérdezésekre, és külön kezeli a sikertelen konténerlista-lekérdezést. **Működésbeli eltérés:** az `ip=manual` konfigurációjú futó vendégeket is ellenőrzi, ezért bevezetés előtt a figyelési szabályt egyeztetni kell a valódi vendégkonfigurációval.

A [tesztscript](../../tests/test-ip-watch.sh) szimulált Proxmox- és Gotify-kimeneteken ellenőrzi a normál állapotot, a hiányzó/többszörös/ütköző IP-címeket, a helyreállást és a sikertelen lekérdezéseket vagy értesítéseket. A GitHub Actions ellenőrzései (Bash-szintaxis, szimulált működési tesztek, ShellCheck) 2026. szeptember 19-én sikeresen lefutottak. **A CI nem helyettesíti a valódi hoston végzett tesztet.**

Példa a kizárólag hoston tárolandó konfigurációra:

```bash
# /etc/proxmox-ip-watch/config – root tulajdon, chmod 600
GOTIFY_URL='https://your-gotify.example/message'
```

A valódi Gotify-token nem része a repónak. Az új verzió telepítése előtt menteni kell az aktuális scriptet, ellenőrizni a működésbeli eltéréseket és kontrolláltan tesztelni a riasztást.

## Ellenőrzés és hibakeresés

```bash
# A repóban:
bash -n scripts/proxmox-ip-watch.sh
bash tests/test-ip-watch.sh

# A Proxmox hoston:
systemctl status proxmox-ip-watch.service --no-pager
systemctl status proxmox-ip-watch.timer --no-pager
systemctl list-timers --all proxmox-ip-watch.timer
journalctl -u proxmox-ip-watch.service -n 50 --no-pager
```

Sikeres oneshot futás után az `inactive (dead)` állapot normális. A service kilépési eredményét és a timer `NEXT` időpontját együtt kell ellenőrizni. Egy korai futás körülbelül **20 másodpercet, 19,5 CPU-másodpercet és 121 MiB csúcsmemóriát** igényelt; a sok `pct exec` hívás később optimalizálható.

**HTTP 401** esetén ellenőrizni kell, hogy a tokenfájl a Gotify *alkalmazás*-tokenjét tartalmazza-e. A token tartalmát nem szabad naplózni vagy közzétenni. A kezdeti telepítés helyi HTTP-t használ; ahol megoldható, hitelesített HTTPS-végpont célszerű.

## Korlátok és következő feladatok

A figyelő csak a futó konténerek `eth0` interfészét látja. Más LAN-eszközök, további interfészek és rövid DHCP-hibák kimaradhatnak. Ha maga a Gotify nem érhető el, ezen az útvonalon nem érkezik riasztás.

- [ ] A verziókezelt script kontrollált kipróbálása és az éles változattal való egyeztetése.
- [ ] DHCPDECLINE-események korai figyelése.
- [ ] Független heartbeat a figyelő vagy a Gotify kiesésének jelzésére.
- [ ] Dokumentált hiba–riasztás–helyreállás teszt.
