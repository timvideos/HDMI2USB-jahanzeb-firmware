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
#include <makestuff.h>
#include "progOffsets.h"

const uint16 *xdata classList[] = {tdoList, tdiList, tmsList, tckList, ioaList};

// Base address of JTAG code
void jtagClockFSM(uint32 bitPattern, uint8 transitionCount);

void livePatch(uint8 patchClass, uint8 newByte) {
	xdata uint8 *xdata const codeBase = (xdata uint8 *)jtagClockFSM;
	xdata uint16 thisOffset;
	const uint16 *xdata ptr = classList[patchClass];
	thisOffset = *ptr++;
	while ( thisOffset ) {
		*(codeBase + thisOffset) = newByte;
		thisOffset = *ptr++;
	}	
}

void jtagPatch(
	uint8 tdoPort, uint8 tdoBit,  // port and bit for TDO
	uint8 tdiPort, uint8 tdiBit,  // port and bit for TDI
	uint8 tmsPort, uint8 tmsBit,  // port and bit for TMS
	uint8 tckPort, uint8 tckBit   // port and bit for TCK
) {
	xdata uint8 *xdata const codeBase = (xdata uint8 *)jtagClockFSM;
	xdata uint16 thisOffset;
	const uint16 *xdata ptr;

	ptr = tdoList;
	thisOffset = *ptr++;
	while ( thisOffset ) {
		//*(codeBase + thisOffset) = 0x11;
		*(codeBase + thisOffset) = 0x80 + (tdoPort << 4) + tdoBit;
		thisOffset = *ptr++;
	}

	ptr = tdiList;
	thisOffset = *ptr++;
	while ( thisOffset ) {
		//*(codeBase + thisOffset) = 0x22;
		*(codeBase + thisOffset) = 0x80 + (tdiPort << 4) + tdiBit;
		thisOffset = *ptr++;
	}

	ptr = tmsList;
	thisOffset = *ptr++;
	while ( thisOffset ) {
		//*(codeBase + thisOffset) = 0x33;
		*(codeBase + thisOffset) = 0x80 + (tmsPort << 4) + tmsBit;
		thisOffset = *ptr++;
	}

	ptr = tckList;
	thisOffset = *ptr++;
	while ( thisOffset ) {
		//*(codeBase + thisOffset) = 0x44;
		*(codeBase + thisOffset) = 0x80 + (tckPort << 4) + tckBit;
		thisOffset = *ptr++;
	}
}
