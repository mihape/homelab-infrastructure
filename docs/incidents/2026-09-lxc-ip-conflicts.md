# LXC IPv4-címhalmozódás és IP-ütközések

**Időszak:** 2026-09-18–19 (CEST)  
**Érintett rendszer:** Proxmox VE, Debian LXC-k, ImmortalWrt DHCP, LAN-kliensek.  
**Utoljára igazolt állapot:** A szolgáltatások helyreálltak; a kiváltó ok **nem ismert**.

## Hatás

Egy Windows laptop duplikált DHCP-címet jelzett, majd APIPA-tartományú (169.254.x.x) IPv4-címet kapott. IPv6-on az internet részben működött, de a helyi IPv4-elérés és a Microsoft Teams hibázott. Egyes Xiaomi-eszközök is elvesztették a kapcsolatot. A probléma nem egyetlen konténerre korlátozódott.

## Bizonyítékok

Több futó LXC `eth0` interfészén **több tucat dinamikus IPv4-cím** halmozódott fel egyszerre; egyes címek több vendégen is előfordultak. A router szomszédtáblája a laptop ütköző címét a Nginx Proxy Manager konténer MAC-címéhez rendelte, pedig annak másik IP-cím volt fenntartva.

| Konténer | IPv4-címek száma az eth0 interfészen | Beavatkozás és ellenőrzés |
| --- | ---: | --- |
| CT 109, Vaultwarden | 88 | Statikus IPv4, újraindítás; utána egy cím |
| CT 111, Homepage | 82 | Újraindítás DHCP-vel; utána egy cím |
| CT 115, Grafana | 80 | Újraindítás DHCP-vel; utána egy cím |
| CT 118, Cinephage | 0 | Újraindítás; IPv4 visszatért |
| CT 120, ErsatzTV | 0 | Újraindítás; IPv4 visszatért |
| CT 121, Zigbee2MQTT | 84 | Statikus IPv4, újraindítás; utána egy cím |
| CT 122, Bazarr | 83 | Újraindítás DHCP-vel; utána egy cím |
| CT 123, reverse proxy | Több mint 80 | Statikus IPv4, újraindítás; utána egy cím |

A számok **incidens közben készült pillanatképek**, nem aktuális konfigurációs leltár. A CT 109, 121 és 123 vendégoldali statikus címet kapott; a többi érintett konténer DHCP-n maradt.

A router naplóiban egy konténernél egymást követő DHCPACK és DHCPDECLINE események jelentek meg. Egy nem érintett telefon rövid DHCP-címmegújítási csomagrögzítésében a várt router válaszolt, de ez **nem volt elegendő** egy időszakosan működő idegen DHCP-szerver kizárására. A vizsgált vendégeken a systemd-networkd az `eth0` interfészt *unmanaged* állapotúnak mutatta; a két hálózatkezelő közti konfliktus **nem bizonyított ok**.

## Helyreállítás és ellenőrzés

A laptop átmenetileg a normál DHCP-kiosztáson kívüli, akkor szabadnak tűnő statikus IPv4-címet kapott. A konténereket ezután egyenként ellenőriztük és javítottuk. Az érintett vendégekben egy IPv4 maradt vagy visszatért a hiányzó cím. Az érintett Xiaomi-eszközök a helyreállítás és saját újraindítás után újra csatlakoztak; **a routert ehhez nem indítottuk újra**.

Az eset után Proxmox/Gotify-figyelő készült: [IP Watch üzemeltetési leírás](../monitoring/proxmox-ip-watch.md).

Az újraindítás a megfigyelt állapotot javította, de **nem bizonyítja**, hogy az eredeti kiváltó ok megszűnt. A laptop átmeneti statikus beállítását akkor kell visszaállítani DHCP-re, ha a kiosztás egészséges, és az új címen nincs ütközés.

## Nem módosító diagnosztika ismétlődéskor

Proxmoxon:

```bash
pct list
pct config 121
pct exec 121 -- ip -o -4 addr show dev eth0
pct exec 121 -- ps aux
pct exec 121 -- journalctl -b --no-pager
```

ImmortalWrt-n:

```sh
uci show dhcp.lan
cat /tmp/dhcp.leases
logread | grep -Ei 'DHCPACK|DHCPDECLINE|DHCPNAK|DHCPOFFER' | tail -n 100
# Csomagrögzítés az érintett kliens valódi címmegújítása közben:
tcpdump -ni br-lan -e -vvv 'udp port 67 or udp port 68'
```

**Az első ütközést** érdemes rögzíteni: időpont, MAC-címek, DHCP-szerverazonosítók, kiosztott címek és vendégállapotok – lehetőleg még újraindítás előtt. Ellenőrizni kell a vendégoldali hálózatkezelést, a Proxmox-konfigurációt és a hálózaton elérhető DHCP-szervereket.

## Nyitott feladatok

- Az első reprodukálható címhalmozódás és a teljes DHCP-forgalom rögzítése.
- MAC-címek, foglalások és szándékos vagy véletlen statikus címek ellenőrzése.
- A figyelő működésének ellenőrzése DHCP-címmegújításkor is, nem csak újraindítás után.
- A laptop DHCP-beállításának, illetve a hálózat és tárhely függőségeinek újbóli ellenőrzése.
- Titkok és belső konfigurációk távol tartása a publikus repótól.
