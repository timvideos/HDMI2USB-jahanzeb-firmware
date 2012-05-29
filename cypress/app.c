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
#include <setupdat.h>
#include <makestuff.h>
#include "../../vendorCommands.h"
#include "prom.h"
#include "jtag.h"
#include "sync.h"
#include "defs.h"
#include "debug.h"

// Function declarations
void fifoSendPromData(uint32 bytesToSend);

// General-purpose diagnostic code, for debugging. See CMD_GET_DIAG_CODE vendor command.
xdata uint8 m_diagnosticCode = 0;

// Called once at startup
//
void mainInit(void) {

	xdata uint8 thisByte = 0xFF;
	xdata uint16 blockSize;

	// This is only necessary for cases where you want to load firmware into the RAM of an FX2 that
	// has already loaded firmware from an EEPROM. It should definitely be removed for firmwares
	// which are themselves to be loaded from EEPROM.
#ifndef EEPROM
	RENUMERATE_UNCOND();
#endif

	// Return FIFO setings back to default just in case previous firmware messed with them.
	SYNCDELAY; PINFLAGSAB = 0x00;
	SYNCDELAY; PINFLAGSCD = 0x00;
	SYNCDELAY; FIFOPINPOLAR = 0x00;

	// Global settings
	SYNCDELAY; REVCTL = (bmDYN_OUT | bmENH_PKT);
	SYNCDELAY; CPUCS = bmCLKSPD1;  // 48MHz

	// Drive IFCLK at 48MHz, enable slave FIFOs
	SYNCDELAY; IFCONFIG = (bmIFCLKSRC | bm3048MHZ | bmIFCLKOE | bmFIFOS);

	// EP2OUT & EP4IN are handled by firmware, EP6OUT & EP8IN connect to Slave FIFOs
	SYNCDELAY; EP2CFG = (bmVALID | bmBULK | bmBUF2X);
	SYNCDELAY; EP4CFG = (bmVALID | bmBULK | bmBUF2X | bmDIR);
	SYNCDELAY; EP6CFG = (bmVALID | bmBULK | bmBUF2X);
	SYNCDELAY; EP8CFG = (bmVALID | bmBULK | bmBUF2X | bmDIR);

	// Reset all the FIFOs
	SYNCDELAY; FIFORESET = bmNAKALL;
	SYNCDELAY; FIFORESET = bmNAKALL | 2;  // reset EP2
	SYNCDELAY; FIFORESET = bmNAKALL | 4;  // reset EP4
	SYNCDELAY; FIFORESET = bmNAKALL | 6;  // reset EP6
	SYNCDELAY; FIFORESET = bmNAKALL | 8;  // reset EP8
	SYNCDELAY; FIFORESET = 0x00;

	// Arm the OUT buffers. Done twice because they're double-buffered
	SYNCDELAY; OUTPKTEND = bmSKIP | 2;  // EP2OUT
	SYNCDELAY; OUTPKTEND = bmSKIP | 2;
	SYNCDELAY; OUTPKTEND = bmSKIP | 6;  // EP6OUT
	SYNCDELAY; OUTPKTEND = bmSKIP | 6;

	// EP2OUT & EP4IN handled by firmware, so no FIFOs
	SYNCDELAY; EP2FIFOCFG = 0x00;
	SYNCDELAY; EP4FIFOCFG = 0x00;

	// EP6OUT & EP8IN need to be synchronised anyway, so no FIFOs yet
	SYNCDELAY; EP6FIFOCFG = 0x00;
	SYNCDELAY; EP8FIFOCFG = 0x00;

	// Auto-commit 512-byte packets from EP8IN (master may commit early by asserting PKTEND)
	SYNCDELAY; EP8AUTOINLENH = 0x02;
	SYNCDELAY; EP8AUTOINLENL = 0x00;
	
	// Turbo I2C
	I2CTL |= bm400KHZ;

	// Port lines...
	IOD = 0x00;
	OED = 0x00;
	IOC = 0x00;
	OEC = 0x00;

	// Disable JTAG mode by default (i.e don't drive JTAG pins)
	jtagSetEnabled(false);

#ifdef BOOT
	promStartRead(0x0000);
	if ( promPeekByte() == 0xC2 ) {
		promNextByte();    // VID(L)
		promNextByte();    // VID(H)
		promNextByte();    // PID(L)
		promNextByte();    // PID(H)
		promNextByte();    // DID(L)
		promNextByte();    // DID(H)
		promNextByte();    // Config byte
		
		promNextByte();    // Length(H)
		thisByte = promPeekByte();
		while ( !(thisByte & 0x80) ) {
			blockSize = thisByte;
			blockSize <<= 8;
			
			promNextByte();  // Length(L)
			blockSize |= promPeekByte();
			
			blockSize += 2;  // Space taken by address
			while ( blockSize-- ) {
				promNextByte();
			}
			
			promNextByte();  // Length(H)
			thisByte = promPeekByte();
		}
		promNextByte();    // Length(L)
		promNextByte();    // Address(H)
		promNextByte();    // Address(L)
		promNextByte();    // Last byte
		promNextByte();    // First byte after the end of the firmware
	}
	jtagSetEnabled(true);
	jtagCsvfInit();
	m_diagnosticCode = jtagCsvfPlay();
	jtagSetEnabled(false);
	blockSize = promPeekByte();
	promNextByte();
	blockSize <<= 8;
	blockSize |= promPeekByte();
	promNextByte();
	if ( blockSize ) {
		fifoSendPromData(blockSize);
	}
	promStopRead();
#endif

#ifdef DEBUG
	usartInit();
	usartSendString("MakeStuff FPGALink/FX2 v1.0\r");
#endif
}

// Called repeatedly while the device is idle
//
void mainLoop(void) {
	// If there is a JTAG shift operation pending, execute it now.
	if ( jtagIsShiftPending() ) {
		jtagShiftExecute();
	} else if ( syncIsEnabled() ) {
		syncExecute();
	}
}

xdata uint8 pcPins;
xdata uint8 pdPins;
xdata uint8 pcDDR;
xdata uint8 pdDDR;
void maskC(void) {
	pcDDR &= ~bmJTAG;          // cannot alter JTAG lines
	pcDDR |= (OEC & bmJTAG);   // current state
	pcPins &= ~bmJTAG;         // cannot alter JTAG lines
	pcPins |= (IOC & bmJTAG);  // current state
}
void maskD(void) {
	pdDDR &= ~bmJTAG;          // cannot alter JTAG lines
	pdDDR |= (OED & bmJTAG);   // current state
	pdPins &= ~bmJTAG;         // cannot alter JTAG lines
	pdPins |= (IOD & bmJTAG);  // current state
}
typedef void (*MaskFunc)(void);
const MaskFunc maskFunc[] = {maskC, maskD};

// Called when a vendor command is received
//
uint8 handleVendorCommand(uint8 cmd) {
	switch(cmd) {

	// Set various mode bits, or fetch status information
	//
	case CMD_MODE_STATUS:
		if ( SETUP_TYPE == (REQDIR_HOSTTODEVICE | REQTYPE_VENDOR) ) {
			xdata uint16 wBits = SETUP_VALUE();
			xdata uint16 wMask = SETUP_INDEX();
			if ( wMask & MODE_SYNC ) {
				// Sync mode does a loopback, so endpoints can be sync'd with the host software
				syncSetEnabled(wBits & MODE_SYNC ? true : false);
			} else if ( wMask & MODE_JTAG ) {
				// When in JTAG mode, the JTAG lines are driven; tristate otherwise
				jtagSetEnabled(wBits & MODE_JTAG ? true : false);
			}
		} else {
			// Get STATUS: return the diagnostic byte
			while ( EP0CS & bmEPBUSY );
			EP0BUF[0] = 'N';                     // Magic bytes (my cat's name)
			EP0BUF[1] = 'E';
			EP0BUF[2] = 'M';
			EP0BUF[3] = 'I';
			EP0BUF[4] = m_diagnosticCode;        // Last operation diagnostic code
			EP0BUF[5] = (IOA & bmBIT2) ? 0 : 1;  // Flags
			EP0BUF[6] = 0x24;                    // NeroJTAG endpoints
			EP0BUF[7] = 0x68;                    // CommFPGA endpoints
			EP0BUF[8] = 0x00;                    // Reserved
			EP0BUF[9] = 0x00;                    // Reserved
			EP0BUF[10] = 0x00;                   // Reserved
			EP0BUF[11] = 0x00;                   // Reserved
			EP0BUF[12] = 0x00;                   // Reserved
			EP0BUF[13] = 0x00;                   // Reserved
			EP0BUF[14] = 0x00;                   // Reserved
			EP0BUF[15] = 0x00;                   // Reserved
			EP0BCH = 0;
			SYNCDELAY;
			EP0BCL = 16;
		}
		return true;

	// Clock data into and out of the JTAG chain. Reads from EP2OUT and writes to EP4IN.
	//
	case CMD_JTAG_CLOCK_DATA:
		if ( SETUP_TYPE == (REQDIR_HOSTTODEVICE | REQTYPE_VENDOR) ) {
			EP0BCL = 0x00;                                     // Allow host transfer in
			while ( EP0CS & bmEPBUSY );                        // Wait for data
			jtagShiftBegin(*((uint32 *)EP0BUF), SETUPDAT[2]);  // Init numBits & flagByte
			return true;
			// Now that numBits & flagByte are set, this operation will continue in mainLoop()...
		}
		break;
		
	// Clock an (up to) 32-bit pattern LSB-first into TMS to change JTAG TAP states
	//
	case CMD_JTAG_CLOCK_FSM:
		if ( SETUP_TYPE == (REQDIR_HOSTTODEVICE | REQTYPE_VENDOR) ) {
			EP0BCL = 0x00;                                   // Allow host transfer in
			while ( EP0CS & bmEPBUSY );                      // Wait for data
			jtagClockFSM(*((uint32 *)EP0BUF), SETUPDAT[2]);  // Bit pattern, transitionCount
			return true;
		}
		break;
		
	// Execute a number of JTAG clocks.
	//
	case CMD_JTAG_CLOCK:
		if ( SETUP_TYPE == (REQDIR_HOSTTODEVICE | REQTYPE_VENDOR) ) {
			jtagClocks(*((uint32 *)(SETUPDAT+2)));
			return true;
		}
		break;

	// Set various mode bits, or fetch status information
	//
	case CMD_PORT_IO:
		if ( SETUP_TYPE == (REQDIR_DEVICETOHOST | REQTYPE_VENDOR) ) {
			pdPins = SETUPDAT[2];  // wValue low byte
			pcPins = SETUPDAT[3];  // wValue high byte
			pdDDR = SETUPDAT[4];   // wIndex low byte
			pcDDR = SETUPDAT[5];   // wIndex high byte
			(*maskFunc[JTAG_PORT])();
			OED = pdDDR;
			OEC = pcDDR;
			IOD = pdPins;
			IOC = pcPins;

			// Get the state of the port D & B lines:
			while ( EP0CS & bmEPBUSY );
			EP0BUF[0] = IOD;
			EP0BUF[1] = IOC;
			EP0BCH = 0;
			SYNCDELAY;
			EP0BCL = 2;
			return true;
		}
		break;
		
	// Command to talk to the EEPROM
	//
	case CMD_READ_WRITE_EEPROM:
		if ( SETUP_TYPE == (REQDIR_DEVICETOHOST | REQTYPE_VENDOR) ) {
			// It's an IN operation - read from prom and send to host
			xdata uint16 address = SETUP_VALUE();
			xdata uint16 length = SETUP_LENGTH();
			xdata uint16 chunkSize;
			xdata uint8 i;
			while ( length ) {
				while ( EP0CS & bmEPBUSY );
				chunkSize = length < EP0BUF_SIZE ? length : EP0BUF_SIZE;
				for ( i = 0; i < chunkSize; i++ ) {
					EP0BUF[i] = 0x23;
				}
				promRead(address, chunkSize, EP0BUF);
				EP0BCH = 0;
				SYNCDELAY;
				EP0BCL = chunkSize;
				address += chunkSize;
				length -= chunkSize;
			}
		} else if ( SETUP_TYPE == (REQDIR_HOSTTODEVICE | REQTYPE_VENDOR) ) {
			// It's an OUT operation - read from host and send to prom
			xdata uint16 address = SETUP_VALUE();
			xdata uint16 length = SETUP_LENGTH();
			xdata uint16 chunkSize;
			while ( length ) {
				EP0BCL = 0x00; // allow pc transfer in
				while ( EP0CS & bmEPBUSY ); // wait for data
				chunkSize = EP0BCL;
				promWrite(address, chunkSize, EP0BUF);
				address += chunkSize;
				length -= chunkSize;
			}
		}
		return true;
	}
	return false;  // unrecognised command
}

// Compose a packet to send on the EP6 FIFO, and commit it.
//
void fifoSendPromData(uint32 bytesToSend) {
	
	xdata uint16 i, chunkSize;
	xdata uint8 thisByte;

	while ( bytesToSend ) {
		chunkSize = (bytesToSend >= 512) ? 512 : (uint16)bytesToSend;

		while ( !(EP2468STAT & bmEP6EMPTY) );  // Wait while FIFO remains "not empty" (i.e while busy)

		SYNCDELAY; EP6FIFOCFG = 0x00;          // Disable AUTOOUT
		SYNCDELAY; FIFORESET = bmNAKALL;       // NAK all OUT packets from host
		SYNCDELAY; FIFORESET = 6;              // Advance EP6 buffers to CPU domain	

		for ( i = 0; i < chunkSize; i++ ) {
			EP6FIFOBUF[i] = promPeekByte();      // Compose packet to send to EP6 FIFO
			promNextByte();
		}
		SYNCDELAY; EP6BCH = MSB(chunkSize);    // Commit newly-sourced packet to FIFO
		SYNCDELAY; EP6BCL = LSB(chunkSize);
	
		SYNCDELAY; OUTPKTEND = bmSKIP | 6;     // Skip uncommitted second packet
		bytesToSend -= chunkSize;

		SYNCDELAY; FIFORESET = 0;              // Release "NAK all"
		SYNCDELAY; EP6FIFOCFG = bmAUTOOUT;     // Enable AUTOOUT again
	}
}
