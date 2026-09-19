# Zigbee2MQTT LXC: USB device reassignment

**Date:** 2026-08-09 (CEST)  
**Scope:** Proxmox CT 121, USB serial passthrough, Zigbee2MQTT, Home Assistant.  
**Status:** Configuration adjusted; end-to-end recovery not verified.

## Symptoms and evidence

After moving a USB radio between physical ports, the Zigbee2MQTT LXC could run while its web interface was unavailable. Troubleshooting involved serial device paths and passthrough. The setup also used a Sonoff multiprotocol Zigbee/Thread radio; do not assume every serial path referred to the same physical adapter.

## Diagnostics

Run on the Proxmox host:

    pct config 121
    ls -l /dev/serial/by-id/ /dev/ttyUSB* /dev/ttyACM* 2>/dev/null
    pct exec 121 -- ip -4 -br addr
    pct exec 121 -- journalctl -u zigbee2mqtt -n 100 --no-pager

Match the actual adapter's persistent USB identity to the configured serial port. Confirm the radio, broker connection, frontend and device messages before declaring recovery. USB passthrough changes should be tested following a host reboot.

**Unresolved:** The available record does not establish a durable final recovery; avoid claiming one.
