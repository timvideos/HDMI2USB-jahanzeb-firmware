/*
 * Copyright (C) 2009-2012 Chris McClelland
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
#ifndef JTAG_H
#define JTAG_H

#include <makestuff.h>

// Addressable bits on Port D for the four JTAG lines (named after the FPGA pins they connect to)
// TDO is an input, the rest are outputs.
sbit at (0xA0 + 16*JTAG_PORT + TDO_BIT) TDO; // Port D0
sbit at (0xA0 + 16*JTAG_PORT + TDI_BIT) TDI; // Port D2
sbit at (0xA0 + 16*JTAG_PORT + TMS_BIT) TMS; // Port D3
sbit at (0xA0 + 16*JTAG_PORT + TCK_BIT) TCK; // Port D4

// Equivalent bitmasks for OED and IOD.
#define bmTDO (1<<TDO_BIT)
#define bmTDI (1<<TDI_BIT)
#define bmTMS (1<<TMS_BIT)
#define bmTCK (1<<TCK_BIT)
#define bmJTAG (bmTDO|bmTDI|bmTMS|bmTCK)

#if JTAG_PORT == 0
	#define JTAG_OE OEC
#elif JTAG_PORT == 1
	#define JTAG_OE OED
#else
	#error Unsupported JTAG_PORT
#endif

// Macros for NeroJTAG implementation
#define ENDPOINT_SIZE 512
#define bmNEEDRESPONSE (1<<0)
#define bmISLAST       (1<<1)
#define bmSENDZEROS    (0<<2)
#define bmSENDONES     (1<<2)
#define bmSENDDATA     (2<<2)
#define bmSENDMASK     (3<<2)

// Error codes for jtagCsvfPlay(void);
#define ERROR_CSVF_FAILED_COMPARE 1
#define ERROR_CSVF_BAD_COMMAND    2

// Kick off a shift operation. Next time jtagExecuteShift() runs, it will execute the shift.
void jtagShiftBegin(uint32 numBits, uint8 flagByte);

// Return true if there's a shift operation pending
bool jtagIsShiftPending(void);

// Actually execute the shift operation initiated by jtagBeginShift(). This is done in a
// separate method because vendor commands cannot read & write to bulk endpoints.
void jtagShiftExecute(void);

// Transition the JTAG state machine to another state: clock "transitionCount" bits from
// "bitPattern" into TMS, LSB-first.
void jtagClockFSM(uint32 bitPattern, uint8 transitionCount);

// Keep TMS and TDI as they are, and clock the JTAG state machine "numClocks" times.
void jtagClocks(uint32 numClocks);

// Initialise the CSVF reader (assume previous call to promStartRead(addr) to position the EEPROM
// reader at the start of the CSVF stream).
void jtagCsvfInit(void);

// Play the CSVF stream into the JTAG lines.
uint8 jtagCsvfPlay(void);

// Enable or disable JTAG mode (i.e, drive the JTAG lines or not)
void jtagSetEnabled(bool enabled);

#endif
