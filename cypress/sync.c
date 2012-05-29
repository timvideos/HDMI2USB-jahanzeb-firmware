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
#include <fx2regs.h>
#include <fx2macros.h>
#include <delay.h>
#include <makestuff.h>
#include "sync.h"
#include "defs.h"

static bool m_enabled = false;

void syncSetEnabled(bool enable) {
	if ( enable ) {
		// EP6OUT & EP8IN now handled by firmware, so no FIFOs
		SYNCDELAY; EP6FIFOCFG = 0x00;
		SYNCDELAY; EP8FIFOCFG = 0x00;
		m_enabled = true;
	} else {
		// EP6OUT & EP8IN now connected to Slave FIFOs, so AUTOOUT & AUTOIN respectively
		SYNCDELAY; EP6FIFOCFG = bmAUTOOUT;
		SYNCDELAY; EP8FIFOCFG = bmAUTOIN;
		m_enabled = false;
	}
}

bool syncIsEnabled(void) {
	return m_enabled;
}

void syncExecute(void) {
	if ( !(EP2468STAT & bmEP2EMPTY) ) {
		// EP2 is not empty (host sent us a packet)
		if  ( !(EP2468STAT & bmEP4FULL) ) {
			// EP4 is not full (we can send host a packet)
			xdata uint16 numBytes = MAKEWORD(EP2BCH, EP2BCL);
			xdata uint16 i;
			for ( i = 0; i < numBytes; i++ ) {
				if ( EP2FIFOBUF[i] >= 'a' && EP2FIFOBUF[i] <= 'z' ) {
					EP4FIFOBUF[i] = EP2FIFOBUF[i] & 0xDF;
				} else {
					EP4FIFOBUF[i] = EP2FIFOBUF[i];
				}
			}
			SYNCDELAY; EP4BCH = MSB(numBytes);  // Initiate send of the copied data
			SYNCDELAY; EP4BCL = LSB(numBytes);
			SYNCDELAY; OUTPKTEND = bmSKIP | 2;  // Acknowledge receipt of this packet
		}
	}

	if ( !(EP2468STAT & bmEP6EMPTY) ) {
		// EP6 is not empty (host sent us a packet)
		if  ( !(EP2468STAT & bmEP8FULL) ) {
			// EP8 is not full (we can send host a packet)
			xdata uint16 numBytes = MAKEWORD(EP6BCH, EP6BCL);
			xdata uint16 i;
			for ( i = 0; i < numBytes; i++ ) {
				if ( EP6FIFOBUF[i] >= 'a' && EP6FIFOBUF[i] <= 'z' ) {
					EP8FIFOBUF[i] = EP6FIFOBUF[i] & 0xDF;
				} else {
					EP8FIFOBUF[i] = EP6FIFOBUF[i];
				}
			}
			SYNCDELAY; EP8BCH = MSB(numBytes);  // Initiate send of the copied data
			SYNCDELAY; EP8BCL = LSB(numBytes);
			SYNCDELAY; OUTPKTEND = bmSKIP | 6;  // Acknowledge receipt of this packet
		}
	}
}
