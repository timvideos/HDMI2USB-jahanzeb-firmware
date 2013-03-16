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
#include "../../prog.h"

// Default TDO=PD0, TDI=PD1, TMS=PD2 & TCK=PD3. In reality this is overwritten
// at runtime by jtagPatch().
#define JTAG_PORT 3
#define TDO_BIT 0
#define TDI_BIT 1
#define TMS_BIT 2
#define TCK_BIT 3

// Addressable bits on Port A, C or D for the four JTAG lines (named after the FPGA pins they
// connect to). TDO is an input, the rest are outputs.
sbit at (0x80 + 16*JTAG_PORT + TDO_BIT) TDO; // Port bit to use for TDO
sbit at (0x80 + 16*JTAG_PORT + TDI_BIT) TDI; // Port bit to use for TDI
sbit at (0x80 + 16*JTAG_PORT + TMS_BIT) TMS; // Port bit to use for TMS
sbit at (0x80 + 16*JTAG_PORT + TCK_BIT) TCK; // Port bit to use for TCK

// Macros for NeroJTAG implementation
#define ENDPOINT_SIZE 64

// Error codes for jtagCsvfPlay(void);
#define ERROR_CSVF_FAILED_COMPARE 1
#define ERROR_CSVF_BAD_COMMAND    2

// Kick off a shift operation. Next time jtagExecuteShift() runs, it will execute the shift.
void jtagShiftBegin(uint32 numBits, ProgOp progOp, uint8 flagByte);

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

#endif
