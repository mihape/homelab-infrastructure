# Homelab Infrastructure – saját üzemeltetési labor

> **English summary:** Personal Proxmox VE homelab documenting Linux, networking, virtualization, Windows Server learning, incident response and monitoring. The detailed documentation is in Hungarian. Planned projects are clearly distinguished from completed work.

Saját Proxmox VE-alapú laborom, ahol Linuxot, Windows Servert, virtualizációt, hálózatokat és szolgáltatásüzemeltetést gyakorlok. A hangsúly nem a telepített alkalmazások számán, hanem a **hibakeresésen, az ellenőrizhető megoldásokon és a dokumentáción** van.

Egy kisvállalkozásnál Windows-kliensgépeket és mindennapi IT-feladatokat is támogatok, emellett mérnökinformatikus-asszisztens képzésen tanulok. **Ez a repó a saját homelabomról szól**, nem a munkáltatóm infrastruktúrájáról vagy vállalati AD-üzemeltetői gyakorlatról.

## Mivel foglalkozom a laborban?

| Terület | Dokumentált technológiák és feladatok |
| --- | --- |
| Virtualizáció | Proxmox VE, LXC, VM-ek, USB passthrough |
| Hálózat és távoli elérés | ImmortalWrt, DNS/DHCP-hibakeresés, Tailscale |
| Belső szolgáltatások | AdGuard Home, Vaultwarden, reverse proxy, Gotify |
| Okosotthon | Home Assistant OS, Zigbee2MQTT és MQTT |
| Média és tárhely | Jellyfin, fájlrendszer- és thin-pool-hibakeresés |
| Monitorozás | LXC IPv4-figyelő, Gotify-értesítések, systemd timer |
| Windows Server | VM 124 telepítve; az Active Directory beállítása **még nem kezdődött el** |

A táblázat nem élő szolgáltatásleltár, és nem jelent vállalati magas rendelkezésre állású környezetet.

## Incidensek, dokumentáció és kód

- [Incidensnapló](docs/incidents/README.md) – dátumozott esetek, tünetek, beavatkozások, ellenőrzés és nyitott kérdések.
- [Tömeges LXC IPv4-ütközés](docs/incidents/2026-09-lxc-ip-conflicts.md) – hibakeresés Windows-kliens, DHCP és konténerinterfészek között.
- [Proxmox IP Watch](docs/monitoring/proxmox-ip-watch.md) – Gotify-riasztások, systemd-időzítő, ellenőrzés és korlátok.
- [IP Watch Bash-script](scripts/proxmox-ip-watch.sh) és [szimulált tesztek](tests/test-ip-watch.sh) – **még nem telepített fejlesztési változat**, amely eltér az éles Proxmoxon futó scripttől.
- [Proxmox-tárhelyhiba](docs/incidents/2026-08-23-proxmox-storage-full.md) és [Jellyfin-helyreállítás](docs/incidents/2026-08-29-thin-pool-jellyfin.md) – az infrastruktúra és az alkalmazás helyreállását külön ellenőriztem.
- [Windows Server / AD-labor](docs/labs/windows-server-ad.md) – telepített VM és egyértelműen **tervezettként** jelölt AD-gyakorlatok.

## Hogyan közelítek meg egy hibát?

1. Felmérem a hibát, a felhasználói hatást és az érintett rendszereket.
2. Rögzítem a releváns címeket, útvonalakat, tárhelyadatokat, naplókat és időpontokat.
3. Megkülönböztetem a bizonyítékot a feltételezéstől; lehetőség szerint egyszerre egy dolgon változtatok.
4. A rendszer mellett az érintett alkalmazás tényleges működését is ellenőrzöm.
5. Dokumentálom a nyitott kérdéseket, és visszatérő hibánál monitorozást vagy reprodukálható laborgyakorlatot készítek.

## Következő lépések

- [ ] A Proxmoxon futó IP Watch összevetése a verziókezelt változattal; ellenőrzött bevezetés.
- [ ] Anonimizált hálózati ábra és időponttal megjelölt VM/LXC-leltár.
- [ ] **Izolált** Windows Server AD DS/DNS és Windows-kliens labor, később OU/GPO és PowerShell-gyakorlatokkal.
- [ ] Valódi, dokumentált mentés-visszaállítási próba.
- [ ] Root fájlrendszer és thin pool kapacitásriasztása.

## Nyilvános repó és biztonság

Nem kerülnek ide jelszavak, tokenek, VPN-kulcsok, ügyfél- és munkáltatói adatok, teljes mentések vagy szerkesztetlen céges konfigurációk. A munkatapasztalatomat és a saját homelabban végzett gyakorlatot külön kezelem. A tervezett feladat nem befejezett eredmény, és egy sikeres újraindítás önmagában nem bizonyított gyökérok.

Egyes dokumentációs és fejlesztési feladatokhoz AI-eszközöket is használok. A ténylegesen kipróbált megoldásokat és a fejlesztési terveket külön jelölöm.
