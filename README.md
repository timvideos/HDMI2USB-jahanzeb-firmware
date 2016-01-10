
# Use [HDMI2USB-misoc-firmware](https://github.com/timvideos/HDMI2USB-misoc-firmware)

**This firmware is obsolete and now read-only.**

This firmware has been replaced by the
[HDMI2USB-misoc-firmware](https://github.com/timvideos/HDMI2USB-misoc-firmware).
This repository is kept around for historical reasons. It was original developed by
[Jahanzeb Ahmad](https://github.com/jahanzeb) using hand coded VHDL/Verilog and with
cores from [OpenCores](OpenCores.org) and the
[Xilinx LogiCORE IP Core Generator](http://www.xilinx.com/ise/products/coregen_overview.pdf).

Further history of this firmware can be found in the
[HDMI2USB-jahanzeb-firmware-history](https://github.com/timvideos/HDMI2USB-jahanzeb-firmware-history)
repository.

# HDMI2USB - A HDMI/DVI Capturing Solution

HDMI2USB is a device to capture HDMI and DVI (and Displayport with cheap active
adapters) and send it on USB port as UVC video. The device attaches computer as
a standard webcam so there is no need of installing additional drivers.

More information about the device can be found in the
[wiki @ https://github.com/timvideos/HDMI2USB/wiki](https://github.com/timvideos/HDMI2USB/wiki).

# Firmware

This repository contains the **source code** for the various firmware in the
HDMI2USB. More information on the firmware required by the HDMI2USB
can be found on the
[Firmware in the wiki](https://github.com/timvideos/HDMI2USB/wiki/Firmware)

**Prebuilt** firmware suitable for loading on devices can be found in the
[HDMI2USB-firmware-prebuilt repository](https://github.com/timvideos/HDMI2USB-firmware-prebuilt)

A Developer's Guide to the functionality, design and source code can be found at:
https://docs.google.com/document/d/1sEhcLmseSLfqr2kH5UtSyMhg5yaNTnCkdNkSvA_ayq4/pub

# Building

## Prerequisites

 * Xilinx WebPack 14.2 - Needed for building FPGA firmware.
 * sdcc > ???? - Needed for building Cypress USB firmware.

## Building

FIXME: Add instructions here
```
make
```

## Loading

FIXME: Add instructions here

