# ImmortalWrt-frissítés – átmeneti internetkimaradás

**Dátum:** 2026-08-31 (CEST)  
**Érintett rendszer:** Xiaomi AX3600 router.  
**Állapot:** Az internetkapcsolat további kézi beavatkozás nélkül visszatért; az átmeneti hiba oka ismeretlen.

## Rögzített megfigyelések

A router kezdetben ImmortalWrt 24.10.4-et, `qualcommax/ipq807x` célplatformot és 6.6.110-es kernelt jelentett. A 24.10.6-ra frissítés sikeres volt. Utána a LAN elérhető maradt, de az internet átmenetileg nem működött. Az útválasztás, WAN és DNS későbbi ellenőrzésekor a kapcsolat már visszatért, további kézi beavatkozás nélkül. Egy későbbi megfigyelés már 25.12.1-es verziót rögzített; ennek pontos frissítési dátuma ebből az esetből nem állapítható meg.

## Frissítés utáni ellenőrzés

```sh
cat /etc/openwrt_release
ubus call system board
ip -4 route
ubus call network.interface.wan status
logread | tail -n 100
```

Csomagfrissítés előtt az **éppen telepített firmware** csomagkezelőjét kell ellenőrizni: a későbbi 25.12.1-es rendszerben `apk` használatos. Legyen kompatibilis konfigurációs mentés; frissítés után WAN, LAN, DHCP, DNS és távoli elérés ellenőrzése szükséges.
