# Bluetooth Devices

The following MAC addresses of bluetooth devices are used:

- Headset Device: `28:9A:4B:78:80:84` Name: Arctis Nova 7
- Keyboard Device: `F1:A7:8F:1A:2F:00` Name: Defy BLE - 1
- Mouse Device: `DC:73:72:2D:82:7E` Name: MX Anywhere 3S

You can connect to them by

```shell
rofi-bluetooth
```

or with the `bluetoothctl` utility

```shell
bluetoothctl
power on
pair on
scan on
devices
connect <MAC-address> # to connect to a device already paired.
trust <MAC-address> # To trust a new device.
pair <MAC-address> # To pair a device
```

## How to Pair

Press the bluetooth button on the Arctis Headset long to go into pairing mode
again (?): Then do inside `bluetoothctl`:

```shell
connect 28:9A:4B:78:80:84
trust 28:9A:4B:78:80:84
pair 28:9A:4B:78:80:84
```
