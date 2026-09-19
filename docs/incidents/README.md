# Incidensnapló

Ez a napló a Proxmox VE homelabban végzett valós hibakereséseket foglalja össze. Az esetek **korabeli állapotokat** mutatnak: nem jelentenek naprakész eszközleltárt, és nem minden hiba kiváltó oka bizonyított.

| Dátum (CEST) | Eset | Utoljára igazolt állapot |
| --- | --- | --- |
| 2026-08-09 | [Zigbee2MQTT / USB-eszköz átadása](2026-08-09-zigbee2mqtt-usb.md) | Konfiguráció módosítva; a teljes helyreállás nincs igazolva |
| 2026-08-10 | [AdGuard tárhelyprobléma](2026-08-10-adguard-rootfs.md) | A fájlrendszer bővítése után működött |
| 2026-08-23 | [Proxmox-tárhely betelése](2026-08-23-proxmox-storage-full.md) | A vendégek fokozatosan indultak; további helyreállításra volt szükség |
| 2026-08-25–31 | [Tailscale és IPv4/DHCP elérés](2026-08-25-tailscale-dhcp.md) | Elérés helyreállt; a kiváltó ok nem bizonyított |
| 2026-08-29 | [Thin pool és Jellyfin-adatbázis](2026-08-29-thin-pool-jellyfin.md) | VM-ek és Next Up helyreálltak; Intro Skipper nyitva maradt |
| 2026-08-31 | [ImmortalWrt-frissítés](2026-08-31-immortalwrt-upgrade.md) | Internet visszatért; az átmeneti hiba oka ismeretlen |
| 2026-09-18–19 | [Tömeges LXC IPv4-ütközések](2026-09-lxc-ip-conflicts.md) | Szolgáltatások helyreálltak; a kiinduló ok ismeretlen |
| 2026-09-19 | [Mentések miatt megtelt Proxmox root](2026-09-19-proxmox-backup-space.md) | Tárhelyprobléma azonosítva; a takarítás nincs igazolva |

A szeptemberi incidens után készült figyelőről: [Proxmox IP Watch üzemeltetési leírás](../monitoring/proxmox-ip-watch.md).

## Dokumentálási elvek

- A tüneteket, bizonyítékokat, beavatkozásokat, ellenőrzést és feltételezéseket külön írom le.
- Egy konténer újraindítása önmagában nem bizonyítja a tartós javítást.
- Ha nem ismert a hiba oka vagy a végső állapot, ezt egyértelműen jelölöm.
- Jelszó, token, privát kulcs, részletes belső leltár és szerkesztetlen napló nem kerül nyilvános repóba.

További megfigyelés: 2026-08-10-én az SMB/X-plore kapcsolat időtúllépéssel hibázott, de a konténer és a végső megoldás nem volt kellően igazolt egy külön esettanulmányhoz.
