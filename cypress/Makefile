#
# Copyright (C) 2009-2012 Chris McClelland
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# To build the firmware you will need:
#   SDCC from http://sdcc.sourceforge.net
#   fx2lib from http://fx2lib.wiki.sourceforge.net
#
# To build without CSVF & FPGA bootstrap from EEPROM
#   make
#
# To build a firmware suitable for loading from EEPROM, with CSVF & FPGA bootstrap
#   make FLAGS="-DEEPROM -DBOOT"
#   sudo make eeprom
#
TARGET := firmware
FX2LIBDIR := ../../../../3rd/fx2lib
LIBS := -L$(FX2LIBDIR)/lib fx2.lib
INCS := -I sdcc -I$(FX2LIBDIR)/include -I../../../../common
MAKESTUFF_TODAY_DATE := $(shell date +%Y%m%d)

CC_SRCS := $(shell ls *.c)
AS_SRCS := $(shell ls *.a51)
CC_OBJS := $(CC_SRCS:%.c=%.rel)
AS_OBJS := $(AS_SRCS:%.a51=%.rel)
CC := sdcc
AS := asx8051
CCFLAGS := -DDATE=0x$(MAKESTUFF_TODAY_DATE) -mmcs51 --code-size 0x1e00 --xram-loc 0xe000 --xram-size 0x0200 -Wl"-b DSCR_AREA=0x1e00" -Wl"-b INT2JT=0x1f00" $(FLAGS)
#CCFLAGS := -DDATE=0x$(MAKESTUFF_TODAY_DATE) -mmcs51 --code-size 0x3e00 --xram-loc 0xe000 --xram-size 0x0200 -Wl"-b DSCR_AREA=0x3e00" -Wl"-b INT2JT=0x3f00" $(FLAGS)

VID := 1D50
PID := 602B
DID := 0002

all: date.inc progOffsets.h $(TARGET).hex

$(TARGET).hex: $(CC_OBJS) $(AS_OBJS) $(TARGET).rel
	$(CC) $(CCFLAGS) -o $@ $+ $(LIBS)

%.rel: %.c
	$(CC) $(CCFLAGS) -c --disable-warning 85 $(INCS) $?

%.rel: %.a51
	$(AS) -logs $?

progOffsets.h: prog.rel
	cat prog.lst | ./lstParse.pl > progOffsets.h

date.inc:
	echo DATE=0x$(MAKESTUFF_TODAY_DATE) > $@
	echo VID=0x$(VID) >> $@
	echo PID=0x$(PID) >> $@
	echo DID=0x$(DID) >> $@

firmware.c: $(FX2LIBDIR)/fw/fw.c
	cp $(FX2LIBDIR)/fw/fw.c firmware.c

clean: FORCE
	rm -f *.iic *.asm *.hex *.lnk *.lst *.map *.mem *.rel *.rst *.sym firmware.c progOffsets.h date.inc

FORCE:
