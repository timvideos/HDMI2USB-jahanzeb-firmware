#!/bin/bash

SCRIPT="$(readlink -f ${BASH_SOURCE[0]})"
SCRIPT_PATH="$(dirname $SCRIPT)"

set -x
set -e

if echo $LD_LIBRARY_PATH | grep -q "Xilinx"; then
	echo "Can't run inside Xilinx environment."
	exit 1
fi

MAKESTUFF_DIR=$SCRIPT_PATH/makestuff
if [ ! -d $MAKESTUFF_DIR ]; then
	sudo apt-get install build-essential libreadline-dev libusb-1.0-0-dev python-yaml
	(
		cd $SCRIPT_PATH
		wget -qO- http://makestuff.eu/bil | tar zxf -
	)
fi

# Get and compile flcli
FLCLI_DIR=$MAKESTUFF_DIR/apps/flcli
if [ ! -d $FLCLI_DIR ]; then (
	cd $MAKESTUFF_DIR/apps
	../scripts/msget.sh makestuff/flcli
) fi
FLCLI_BIN=$FLCLI_DIR/lin.x64/rel/flcli
if [ ! -x $FLCLI_BIN ]; then (
	cd $FLCLI_DIR
	make deps
	make
) fi

# Get and compile fx2loader
FX2LOAD_DIR=$MAKESTUFF_DIR/apps/fx2loader
if [ ! -d $FX2LOAD_DIR ]; then (
	cd $MAKESTUFF_DIR/apps
	../scripts/msget.sh makestuff/fx2loader
) fi
FX2LOAD_BIN=$FX2LOAD_DIR/lin.x64/rel/fx2loader
if [ ! -x $FX2LOAD_BIN ]; then (
	cd $FX2LOAD_DIR
	make deps
	make
) fi

# Build the xsvf file
XSVF=$SCRIPT_PATH/../build/hdmi2usb.xsvf
if [ ! -e build/hdmi2usb.bit ]; then
	echo "Please build the FPGA firmware by typing 'make'"
	exit 1
fi
rm $XSVF || true
(
	cd $SCRIPT_PATH/..
	. /opt/Xilinx/14.7/ISE_DS/settings64.sh
	make xsvf
)
[ -e $XVSF ]

HEX=$SCRIPT_PATH/../cypress/output/hdmi2usb.hex
if [ ! -e $HEX ]; then
	echo "Please build the Cypress firmware by going into the 'cypress' directory and typing 'make'"
	exit 1
fi

# DEVICE=1443:0007 # Atlys with Digilent firmware
DEVICE=04b4:8613 # Unconfigured Cypress chip

echo "Loading FPGALink onto board."
$FLCLI_BIN -v 1d50:602b:0002 -i $DEVICE

echo "Loading HDMI2USB FPGA firmware." 
$FLCLI_BIN -v 1d50:602b:0002 -p J:D0D2D3D4:$XSVF

echo "Loading HDMI2USB Cypress firmware."
$FX2LOAD_BIN -v 1d50:602b $HEX ram
