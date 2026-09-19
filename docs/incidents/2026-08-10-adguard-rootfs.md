# AdGuard Home – betelő LXC-fájlrendszer

**Dátum:** 2026-08-10 (CEST)  
**Érintett rendszer:** AdGuard Home, CT 107; DNS-elérhetőség.  
**Állapot:** Fájlrendszer-bővítés után a szolgáltatás helyreállt; a tárhelynövekedés oka nem lett tisztázva.

## Bizonyítékok

Az LXC futott, de az AdGuard és az IPv4-elérés nem működött megfelelően. A 2 GB-os root fájlrendszere csaknem megtelt. A méret 6 GB-ra növelése után a szolgáltatás ismét működött, körülbelül 1,8 GB foglalással. Ez a tárhelykapacitás problémáját támasztja alá, de önmagában nem bizonyítja, hogy a hiányzó IPv4-címet kizárólag ez okozta.

## Nem módosító ellenőrzések

```bash
pct config 107
pct exec 107 -- df -h /
pct exec 107 -- du -xhd1 /opt /usr /var 2>/dev/null
pct exec 107 -- ip -4 -br addr
pct exec 107 -- systemctl --failed
```

Naplók és konfiguráció törlése előtt vizsgálandó a foglalás és a megőrzési beállítás. A DNS a teljes hálózat függősége: külön dokumentálni kell, mi történik a kliensekkel a CT 107 kiesésekor.
