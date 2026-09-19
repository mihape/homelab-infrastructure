# Zigbee2MQTT LXC – USB-eszköz áthelyezése

**Dátum:** 2026-08-09 (CEST)  
**Érintett rendszer:** Proxmox CT 121, USB soros eszköz átadása, Zigbee2MQTT, Home Assistant.  
**Állapot:** Konfiguráció módosítva; a teljes körű helyreállás nincs igazolva.

## Tünetek és megfigyelések

Az USB-rádió másik fizikai portra helyezése után a Zigbee2MQTT konténer futhatott úgy, hogy a webes felülete nem volt elérhető. A vizsgálat az eszközútvonalakra és az USB-átadásra is kiterjedt. Sonoff Zigbee/Thread multiprotokollos rádió is része volt a környezetnek; nem feltételezhető, hogy minden soros útvonal ugyanahhoz a fizikai adapterhez tartozott.

## Diagnosztika

A Proxmox hoston:

```bash
pct config 121
ls -l /dev/serial/by-id/ /dev/ttyUSB* /dev/ttyACM* 2>/dev/null
pct exec 121 -- ip -4 -br addr
pct exec 121 -- journalctl -u zigbee2mqtt -n 100 --no-pager
```

A konfigurált soros portot a tényleges adapter tartós USB-azonosítójával kell egyeztetni. A helyreállás előtt külön ellenőrizendő a rádió, az MQTT broker, a webes felület és az eszközüzenetek működése. Az USB-átadást host-újraindítás után is célszerű tesztelni.

**Nyitott kérdés:** A rendelkezésre álló feljegyzés nem igazol tartós, teljes helyreállást.
