<img src="assets/images/KSE_side_shot.png" width="750">


# Femtofox &nbsp;&nbsp;&nbsp;<sub><sub>The tiny, low power Linux Meshtastic node
**Femtofox is a Linux-based mesh development platform - a Raspberry Pi sized computer with onboard LoRa radio, capable of being run with only 0.3w, making it *ideal* for solar powered nodes.**

The Luckfox Pico Mini is the postage stamp sized heart of the Femtofox - a compact and power efficient Linux board, running a customized version of Ubuntu. Femtofox is an expansion of the Luckfox's capabilities, utilizing a custom PCB with a 30db LoRa radio (over 6x the transmit power of a RAK Wisblock or Heltec V3) to create a power efficient, tiny and highly capable Meshtastic Linux node.

- [Features](#features)
- Specifications - coming soon
- [Supported hardware](https://github.com/femtofox/femtofox/wiki/Supported-Hardware)
- [Installation guide](https://github.com/femtofox/femtofox/wiki/Getting-Started)
- How to order - coming soon
- [DIY instructions](https://github.com/femtofox/Femtofox_Community_Hardware)
- [USB configuration tool](https://github.com/femtofox/femtofox/wiki/USB-Config-Tool) 

### Features
* Tiny size (63x54mm for Femtofox, 65x30mm for the Smol Edition). Equivalent to a standard Raspberry Pi hat and Pi Zero respectively.
* Power efficient (~0.27-0.4w average, depending on radio and mesh congestion)
* Full Linux CLI (Ubuntu) via our pre-built Foxbuntu image
* Meshtastic native client support via SPI
* USB host support - attach USB peripherals
* USB wifi support
* RTC support for timekeeping

**Accomplished:**
- [x] Meshtastic native client controlling a LoRa radio (see [supported hardware](supported_hardware.md))
- [x] WIFI over USB (see [supported hardware](supported_hardware.md))
- [x] Ethernet over USB (see [supported hardware](supported_hardware.md))
- [x] Ethernet over pins (see *Networking* below and wiring diagram at bottom of page)
- [x] UART communications with Meshtastic nodes (2 pin pairs) such as RAK Wisblock
- [x] USB serial communications with Meshtastic nodes (see [supported hardware](supported_hardware.md))
- [x] USB mass storage
- [x] Real time clock (RTC) support (see [supported hardware](supported_hardware.md))
- [x] Activity LED disabled. User LED will blink for 5 seconds when boot is complete
- [x] Short pressing the "BOOT" button toggles wifi, 2-5 second press triggers reboot, 5+ second press shuts system down
- [x] Ability to reconfigure wifi via USB flash drive
- [x] Meshtasticd to run LoRa radio over SPI (accomplished, updated image and instructions coming soon)
- [x] Allow editing of config files by plugging in thumb drive
- [x] Ability to activate or deactivate WIFI via Meshtastic admin
 
> [!NOTE]
> The information on this page is given without warranty or guarantee. Links to vendors of products are for informational purposes only.
> Meshtastic® is a registered trademark of Meshtastic LLC. Meshtastic software components are released under various licenses, see GitHub for details. No warranty is provided - use at your own risk.
<!--stackedit_data:
eyJoaXN0b3J5IjpbMTE3Mjg3OTE0N119
-->
