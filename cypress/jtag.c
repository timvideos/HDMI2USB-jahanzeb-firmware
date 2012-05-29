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
#include "jtag.h"
#include "prom.h"
#include "defs.h"
#include "debug.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
// NeroJTAG Stuff
////////////////////////////////////////////////////////////////////////////////////////////////////

static xdata uint32 m_numBits = 0UL;
static xdata uint8 m_flagByte = 0x00;

// JTAG-clock the supplied byte into TDI, LSB first.
//
// Lifted from:
//   http://ixo-jtag.svn.sourceforge.net/viewvc/ixo-jtag/usb_jtag/trunk/device/c51/hw_nexys.c
//
static void shiftOut(uint8 c) {
	/* Shift out byte c:
	 *
	 * 8x {
	 *   Output least significant bit on TDI
	 *   Raise TCK
	 *   Shift c right
	 *   Lower TCK
	 * }
	 */
	
	(void)c; /* argument passed in DPL */
	
	_asm
		mov  A,DPL
		;; Bit0
		rrc  A
		mov  _TDI,C
		setb _TCK
		;; Bit1
		rrc  A
		clr  _TCK
		mov  _TDI,C
		setb _TCK
		;; Bit2
		rrc  A
		clr  _TCK
		mov  _TDI,C
		setb _TCK
		;; Bit3
		rrc  A
		clr  _TCK
		mov  _TDI,C
		setb _TCK
		;; Bit4
		rrc  A
		clr  _TCK
		mov  _TDI,C
		setb _TCK
		;; Bit5
		rrc  A
		clr  _TCK
		mov  _TDI,C
		setb _TCK
		;; Bit6
		rrc  A
		clr  _TCK
		mov  _TDI,C
		setb _TCK
		;; Bit7
		rrc  A
		clr  _TCK
		mov  _TDI,C
		setb _TCK
		nop
		clr  _TCK
	_endasm;
}

// JTAG-clock all 512 bytes from the EP2 FIFO buffer
//
static void blockShiftOut(void) {
	_asm
		mov    r0, #0
		mov    dpl, #_EP2FIFOBUF
		mov    dph, #(_EP2FIFOBUF >> 8)
		movx   a, @dptr
	bsoLoop:
		rrc    a
		mov    _TDI, c
		setb   _TCK
		rrc    a
		clr    _TCK
		mov    _TDI, c
		setb   _TCK
		rrc    a
		clr    _TCK
		mov    _TDI, c
		setb   _TCK
		rrc    a
		clr    _TCK
		mov    _TDI, c
		setb   _TCK
		rrc    a
		clr    _TCK
		mov    _TDI, c
		setb   _TCK
		rrc    a
		clr    _TCK
		mov    _TDI, c
		setb   _TCK
		rrc    a
		clr    _TCK
		mov    _TDI, c
		setb   _TCK
		rrc    a
		clr    _TCK
		mov    _TDI, c
		setb   _TCK
		inc    dptr
		movx   a, @dptr
		clr    _TCK

		nop
		nop
		nop

		rrc    a
		mov    _TDI, c
		setb   _TCK
		rrc    a
		clr    _TCK
		mov    _TDI, c
		setb   _TCK
		rrc    a
		clr    _TCK
		mov    _TDI, c
		setb   _TCK
		rrc    a
		clr    _TCK
		mov    _TDI, c
		setb   _TCK
		rrc    a
		clr    _TCK
		mov    _TDI, c
		setb   _TCK
		rrc    a
		clr    _TCK
		mov    _TDI, c
		setb   _TCK
		rrc    a
		clr    _TCK
		mov    _TDI, c
		setb   _TCK
		rrc    a
		clr    _TCK
		mov    _TDI, c
		setb   _TCK
		inc    dptr
		movx   a, @dptr
		clr    _TCK

		djnz   r0, bsoLoop
	_endasm;
}

// JTAG-clock the supplied byte into TDI, MSB first. Return the byte clocked out of TDO.
//
// Lifted from:
//   http://ixo-jtag.svn.sourceforge.net/viewvc/ixo-jtag/usb_jtag/trunk/device/c51/hw_nexys.c
//
static uint8 shiftInOut(uint8 c) {
	/* Shift out byte c, shift in from TDO:
	 *
	 * 8x {
	 *   Read carry from TDO
	 *   Output least significant bit on TDI
	 *   Raise TCK
	 *   Shift c right, append carry (TDO) at left
	 *   Lower TCK
	 * }
	 * Return c.
	 */
	
	(void)c; /* argument passed in DPL */
	
	_asm
		mov  A, DPL

		;; Bit0
		mov  C, _TDO
		rrc  A
		mov  _TDI, C
		setb _TCK
		clr  _TCK
		;; Bit1
		mov  C, _TDO
		rrc  A
		mov  _TDI, C
		setb _TCK
		clr  _TCK
		;; Bit2
		mov  C, _TDO
		rrc  A
		mov  _TDI, C
		setb _TCK
		clr  _TCK
		;; Bit3
		mov  C, _TDO
		rrc  A
		mov  _TDI, C
		setb _TCK
		clr  _TCK
		;; Bit4
		mov  C, _TDO
		rrc  A
		mov  _TDI, C
		setb _TCK
		clr  _TCK
		;; Bit5
		mov  C, _TDO
		rrc  A
		mov  _TDI, C
		setb _TCK
		clr  _TCK
		;; Bit6
		mov  C, _TDO
		rrc  A
		mov  _TDI, C
		setb _TCK
		clr  _TCK
		;; Bit7
		mov  C, _TDO
		rrc  A
		mov  _TDI, C
		setb _TCK
		nop
		clr  _TCK
		
		mov  DPL, A
		ret
	_endasm;

	/* return value in DPL */

	return c;
}

// Kick off a shift operation. Next time jtagExecuteShift() runs, it will execute the shift.
//
void jtagShiftBegin(uint32 numBits, uint8 flagByte) {
	m_numBits = numBits;
	m_flagByte = flagByte;
}

// See if a shift operation is pending
//
bool jtagIsShiftPending(void) {
	return (m_numBits != 0);
}

// The minimum number of bytes necessary to store x bits
//
#define bitsToBytes(x) ((x>>3) + (x&7 ? 1 : 0))

// Actually execute the shift operation initiated by jtagBeginShift(). This is done in a
// separate method because vendor commands cannot read & write to bulk endpoints.
//
void jtagShiftExecute(void) {
	// Are there any JTAG send/receive operations to execute?
	if ( (m_flagByte & bmSENDMASK) == bmSENDDATA ) {
		if ( m_flagByte & bmNEEDRESPONSE ) {
			// The host is giving us data, and is expecting a response (xdr)
			xdata uint16 bitsRead, bitsRemaining, bytesRead, bytesRemaining;
			xdata uint8 *inPtr, *outPtr;
			while ( m_numBits ) {
				while ( EP2468STAT & bmEP2EMPTY );  // Wait for some EP2OUT data
				while ( EP2468STAT & bmEP4FULL );   // Wait for space for EP4IN data
				bitsRead = (m_numBits >= (ENDPOINT_SIZE<<3)) ? ENDPOINT_SIZE<<3 : m_numBits;
				bytesRead = MAKEWORD(EP2BCH, EP2BCL);
				if ( bytesRead != bitsToBytes(bitsRead) ) {
					// Protocol violation - give up
					#ifdef DEBUG
						usartSendString("Protocol violation - giving up!\r");
					#endif
					m_numBits = 0UL;
					break;
				}

				inPtr = EP2FIFOBUF;
				outPtr = EP4FIFOBUF;
				if ( bitsRead == m_numBits ) {
					// This is the last chunk
					xdata uint8 tdoByte, tdiByte, leftOver, i;
					bitsRemaining = (bitsRead-1) & 0xFFF8;        // Now an integer number of bytes
					leftOver = (uint8)(bitsRead - bitsRemaining); // How many bits in last byte (1-8)
					bytesRemaining = (bitsRemaining>>3);
					while ( bytesRemaining-- ) {
						*outPtr++ = shiftInOut(*inPtr++);
					}
					tdiByte = *inPtr++;  // Now do the bits in the final byte
					tdoByte = 0x00;
					i = 1;
					while ( i && leftOver ) {
						leftOver--;
						if ( (m_flagByte & bmISLAST) && !leftOver ) {
							TMS = 1; // Exit Shift-DR state on next clock
						}
						TDI = tdiByte & 1;
						tdiByte >>= 1;
						if ( TDO ) {
							tdoByte |= i;
						}
						TCK = 1;
						TCK = 0;
						i <<= 1;
					}
					*outPtr = tdoByte;
				} else {
					// This is not the last chunk
					bytesRemaining = (bitsRead>>3);
					while ( bytesRemaining-- ) {
						*outPtr++ = shiftInOut(*inPtr++);
					}
				}
				SYNCDELAY; EP4BCH = MSB(bytesRead);  // Initiate send of the copied data
				SYNCDELAY; EP4BCL = LSB(bytesRead);
				SYNCDELAY; OUTPKTEND = bmSKIP | 2;   // Acknowledge receipt of this packet
				m_numBits -= bitsRead;
			}
		} else {
			// The host is giving us data, but does not need a response (xdn)
			xdata uint16 bitsRead, bitsRemaining, bytesRead, bytesRemaining;
			while ( m_numBits ) {
				while ( EP2468STAT & bmEP2EMPTY );  // Wait for some EP2OUT data
				bitsRead = (m_numBits >= (ENDPOINT_SIZE<<3)) ? ENDPOINT_SIZE<<3 : m_numBits;
				bytesRead = MAKEWORD(EP2BCH, EP2BCL);
				if ( bytesRead != bitsToBytes(bitsRead) ) {
					// Protocol violation - give up
					#ifdef DEBUG
						usartSendString("Protocol violation - giving up!\r");
					#endif
					m_numBits = 0UL;
					break;
				}

				if ( bitsRead == m_numBits ) {
					// This is the last chunk
					xdata uint8 tdiByte, leftOver, i;
					inPtr = EP2FIFOBUF;
					bitsRemaining = (bitsRead-1) & 0xFFF8;        // Now an integer number of bytes
					leftOver = (uint8)(bitsRead - bitsRemaining); // How many bits in last byte (1-8)
					bytesRemaining = (bitsRemaining>>3);
					while ( bytesRemaining-- ) {
						shiftOut(*inPtr++);
					}
					tdiByte = *inPtr;  // Now do the bits in the final byte
					i = 1;
					while ( i && leftOver ) {
						leftOver--;
						if ( (m_flagByte & bmISLAST) && !leftOver ) {
							TMS = 1; // Exit Shift-DR state on next clock
						}
						TDI = tdiByte & 1;
						tdiByte >>= 1;
						TCK = 1;
						TCK = 0;
						i <<= 1;
					}
				} else {
					// This is not the last chunk, so we've to 512 bytes to shift
					blockShiftOut();
				}
				SYNCDELAY; OUTPKTEND = bmSKIP | 2;   // Acknowledge receipt of this packet
				m_numBits -= bitsRead;
			}
		}
	} else {
		if ( m_flagByte & bmNEEDRESPONSE ) {
			// The host is not giving us data, but is expecting a response (x0r)
			xdata uint16 bitsRead, bitsRemaining, bytesRead, bytesRemaining;
			xdata uint8 tdiByte;
			if ( (m_flagByte & bmSENDMASK) == bmSENDZEROS ) {
				tdiByte = 0x00;
			} else {
				tdiByte = 0xFF;
			}
			while ( m_numBits ) {
				while ( EP2468STAT & bmEP4FULL );   // Wait for space for EP4IN data
				bitsRead = (m_numBits >= (ENDPOINT_SIZE<<3)) ? ENDPOINT_SIZE<<3 : m_numBits;
				bytesRead = bitsToBytes(bitsRead);

				outPtr = EP4FIFOBUF;
				if ( bitsRead == m_numBits ) {
					// This is the last chunk
					xdata uint8 tdoByte, leftOver, i;
					bitsRemaining = (bitsRead-1) & 0xFFF8;        // Now an integer number of bytes
					leftOver = (uint8)(bitsRead - bitsRemaining); // How many bits in last byte (1-8)
					bytesRemaining = (bitsRemaining>>3);
					while ( bytesRemaining-- ) {
						*outPtr++ = shiftInOut(tdiByte);
					}
					tdoByte = 0x00;
					i = 1;
					TDI = tdiByte & 1;
					while ( i && leftOver ) {
						leftOver--;
						if ( (m_flagByte & bmISLAST) && !leftOver ) {
							TMS = 1; // Exit Shift-DR state on next clock
						}
						if ( TDO ) {
							tdoByte |= i;
						}
						TCK = 1;
						TCK = 0;
						i <<= 1;
					}
					*outPtr = tdoByte;
				} else {
					// This is not the last chunk
					bytesRemaining = (bitsRead>>3);
					while ( bytesRemaining-- ) {
						*outPtr++ = shiftInOut(tdiByte);
					}
				}
				SYNCDELAY; EP4BCH = MSB(bytesRead);  // Initiate send of the data
				SYNCDELAY; EP4BCL = LSB(bytesRead);
				m_numBits -= bitsRead;
			}
		} else {
			// The host is not giving us data, and does not need a response (x0n)
			xdata uint32 bitsRemaining, bytesRemaining;
			xdata uint8 tdiByte, leftOver;
			if ( (m_flagByte & bmSENDMASK) == bmSENDZEROS ) {
				tdiByte = 0x00;
			} else {
				tdiByte = 0xFF;
			}
			bitsRemaining = (m_numBits-1) & 0xFFFFFFF8;    // Now an integer number of bytes
			leftOver = (uint8)(m_numBits - bitsRemaining); // How many bits in last byte (1-8)
			bytesRemaining = (bitsRemaining>>3);
			while ( bytesRemaining-- ) {
				shiftOut(tdiByte);
			}
			TDI = tdiByte & 1;
			while ( leftOver ) {
				leftOver--;
				if ( (m_flagByte & bmISLAST) && !leftOver ) {
					TMS = 1; // Exit Shift-DR state on next clock
				}
				TCK = 1;
				TCK = 0;
			}
			m_numBits = 0UL;
		}
	}
}

// Transition the JTAG state machine to another state: clock "transitionCount" bits from
// "bitPattern" into TMS, LSB-first.
//
void jtagClockFSM(uint32 bitPattern, uint8 transitionCount) {
	while ( transitionCount-- ) {
		TCK = 0;
		TMS = bitPattern & 1;
		bitPattern >>= 1;
		TCK = 1;
	}
	TCK = 0;
}

// Keep TMS and TDI as they are, and clock the JTAG state machine "numClocks" times.
// This is tuned to be as close to 2us per clock as possible (500kHz).
//
void jtagClocks(uint32 numClocks) {
	_asm
		mov r2, dpl
		mov r3, dph
		mov r4, b
		mov r5, a
	jcLoop:
		; TCK is high for 12 cycles (1us):
		setb _TCK              ; 1 cycle
		nop                    ; 1 cycle
		nop                    ; 1 cycle
		nop                    ; 1 cycle
		nop                    ; 1 cycle
		nop                    ; 1 cycle
		nop                    ; 1 cycle
		nop                    ; 1 cycle
		nop                    ; 1 cycle
		nop                    ; 1 cycle
		nop                    ; 1 cycle
		nop                    ; 1 cycle

		; TCK is low for 12 cycles (1us):
		clr _TCK               ; 1 cycle
		nop                    ; 1 cycle
		nop                    ; 1 cycle
		nop                    ; 1 cycle
		nop                    ; 1 cycle
		nop                    ; 1 cycle
		nop                    ; 1 cycle
		dec r2                 ; 1 cycle
		cjne r2, #255, jcLoop  ; 4 cycles

		; The high-order bytes introduce some jitter:
		dec r3
		cjne r3, #255, jcLoop
		dec r4
		cjne r4, #255, jcLoop
		dec r5
		cjne r5, #255, jcLoop
	_endasm;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// CSVF Player Stuff
////////////////////////////////////////////////////////////////////////////////////////////////////

// XSVF commands (from xapp503 appendix B)
typedef enum {
	XCOMPLETE    = 0x00,
	XTDOMASK     = 0x01,
	XSIR         = 0x02,
	XSDR         = 0x03,
	XRUNTEST     = 0x04,
	XREPEAT      = 0x07,
	XSDRSIZE     = 0x08,
	XSDRTDO      = 0x09,
	XSETSDRMASKS = 0x0A,
	XSDRINC      = 0x0B,
	XSDRB        = 0x0C,
	XSDRC        = 0x0D,
	XSDRE        = 0x0E,
	XSDRTDOB     = 0x0F,
	XSDRTDOC     = 0x10,
	XSDRTDOE     = 0x11,
	XSTATE       = 0x12,
	XENDIR       = 0x13,
	XENDDR       = 0x14,
	XSIR2        = 0x15,
	XCOMMENT     = 0x16,
	XWAIT        = 0x17,
} Command;

// TAP states (from xapp503 appendix B)
typedef enum {
	TAPSTATE_TEST_LOGIC_RESET = 0x00,
	TAPSTATE_RUN_TEST_IDLE    = 0x01,
	TAPSTATE_SELECT_DR        = 0x02,
	TAPSTATE_CAPTURE_DR       = 0x03,
	TAPSTATE_SHIFT_DR         = 0x04,
	TAPSTATE_EXIT1_DR         = 0x05,
	TAPSTATE_PAUSE_DR         = 0x06,
	TAPSTATE_EXIT2_DR         = 0x07,
	TAPSTATE_UPDATE_DR        = 0x08,
	TAPSTATE_SELECT_IR        = 0x09,
	TAPSTATE_CAPTURE_IR       = 0x0A,
	TAPSTATE_SHIFT_IR         = 0x0B,
	TAPSTATE_EXIT1_IR         = 0x0C,
	TAPSTATE_PAUSE_IR         = 0x0D,
	TAPSTATE_EXIT2_IR         = 0x0E,
	TAPSTATE_UPDATE_IR        = 0x0F
} TAPState;

// "Member" variables to store the state of the compression algorithm.
static bool m_isReadingChunk;
static xdata uint32 m_count;

// Read the length (of the chunk or the zero run). A short block (<256 bytes) length is encoded in a
// single byte. If that single byte is zero, we know it's a medium block (256-65535 bytes), so read
// in the next two bytes as a big-endian uint16. If that is zero, we know it's a long block (65536-
// 4294967295 bytes), so read in the next four bytes as a big-endian uint32.
//
static uint32 readLength(void) {
	xdata uint32 len = promPeekByte();
	promNextByte();
	if ( !len ) {
		len = promPeekByte();
		promNextByte();
		len <<= 8;
		len |= promPeekByte();
		promNextByte();
	}
	if ( !len ) {
		len = promPeekByte();
		promNextByte();
		len <<= 8;
		len |= promPeekByte();
		promNextByte();
		len <<= 8;
		len |= promPeekByte();
		promNextByte();
		len <<= 8;
		len |= promPeekByte();
		promNextByte();
	}
	return len;
}

// Get the next byte from the uncompressed stream. Uses m_count & m_isReadingChunk to keep state.
//
static uint8 getNextByte(void) {
	if ( m_isReadingChunk ) {
		// We're in the middle of reading a chunk.
		if ( m_count ) {
			// There are still some bytes to copy verbatim into the uncompressed stream.
			xdata uint8 thisByte;
			m_count--;
			thisByte = promPeekByte();
			promNextByte();
			return thisByte;
		} else {
			// We're at the end of this chunk; there will now be some zeros to insert into the
			// uncompressed stream.
			m_count = readLength();
			m_isReadingChunk = false;
			return getNextByte();
		}
	} else {
		// We're in the middle of a run of zeros.
		if ( m_count ) {
			// There are still some zero bytes to write to the uncompressed stream.
			m_count--;
			return 0x00;
		} else {
			// We're at the end of this run of zeros; there will now be a chunk of data to be copied
			// verbatim over to the uncompressed stream.
			m_count = readLength();
			m_isReadingChunk = true;
			return getNextByte();
		}
	}
}

// Initialise the CSVF reader
//
void jtagCsvfInit(void) {
	promNextByte();  // Skip header byte
	m_count = readLength();
	m_isReadingChunk = true;
}

// Get big-endian uint16 from the stream
//
static uint16 getWord(void) {
	xdata uint16 value;
	value = getNextByte();
	value <<= 8;
	value |= getNextByte();
	return value;
}

// Get big-endian uint32 from the stream
//
static uint32 getLong(void) {
	xdata uint32 value;
	value = getNextByte();
	value <<= 8;
	value |= getNextByte();
	value <<= 8;
	value |= getNextByte();
	value <<= 8;
	value |= getNextByte();
	return value;
}

// Shift out "numBits" bits from the CSVF stream. If "isLast", exit Shift-DR on the final bit.
//
static void shiftOutCsvf(uint32 numBits, bool isLast) {
	xdata uint32 bitsRemaining = (numBits-1) & 0xFFFFFFF8;    // Now an integer number of bytes
	xdata uint8 leftOver = (uint8)(numBits - bitsRemaining);  // How many bits in last byte (1-8)
	xdata uint32 bytesRemaining = (bitsRemaining>>3);
	xdata uint8 tdiByte, i;
	while ( bytesRemaining-- ) {
		shiftOut(getNextByte());
	}
	tdiByte = getNextByte();  // Now do the bits in the final byte
	i = 1;
	while ( i && leftOver ) {
		leftOver--;
		if ( isLast && !leftOver ) {
			TMS = 1; // Exit Shift-DR state on next clock
		}
		TDI = tdiByte & 1;
		tdiByte >>= 1;
		TCK = 1;
		TCK = 0;
		i <<= 1;
	}
}

// Play the uncompressed CSVF stream into the JTAG port.
//
uint8 jtagCsvfPlay(void) {
	xdata uint8 returnCode = 0;
	xdata uint8 thisByte;
	xdata uint32 numBytes;
	xdata uint8 *ptr;
	xdata uint8 i;
	xdata uint32 xsdrSize = 0;
	xdata uint16 xruntest = 0;
	xdata uint8 tdoMask[CSVF_BUF_SIZE];
	jtagClockFSM(0x0000001F, 6);  // Go to Run-Test/Idle
	thisByte = getNextByte();
	while ( thisByte != XCOMPLETE ) {
		switch ( thisByte ) {
		case XTDOMASK:
			numBytes = bitsToBytes(xsdrSize);
			ptr = tdoMask;
			while ( numBytes-- ) {
				*ptr++ = getNextByte();
			}
			break;

		case XRUNTEST:
			getNextByte();  // Ignore the MSW (realistically will it ever be nonzero?)
			getNextByte();
			xruntest = getWord();
			break;

		case XSIR:
			jtagClockFSM(0x00000003, 4);
			shiftOutCsvf(getNextByte(), true);
			jtagClockFSM(0x00000001, 2);
			if ( xruntest ) {
				jtagClocks(xruntest);
			}
			break;

		case XSDRSIZE:
			xsdrSize = getLong();
			break;

		case XSDRTDO: {
			xdata uint32 bitsRemaining = (xsdrSize-1) & 0xFFFFFFF8;    // Now an int number of bytes
			xdata uint8 leftOver = (uint8)(xsdrSize - bitsRemaining);  // No bits in last byte (1-8)
			xdata uint8 tdoByte, tdiByte, expectedByte, i, lastIndex;
			jtagClockFSM(0x00000001, 3);
			numBytes = (bitsRemaining>>3);
			i = 0;
			while ( numBytes-- ) {
				tdoByte = shiftInOut(getNextByte());
				expectedByte = getNextByte();
				if ( (tdoByte & tdoMask[i]) != (expectedByte & tdoMask[i]) ) {
					returnCode = ERROR_CSVF_FAILED_COMPARE;
					goto cleanup;
				}
				i++;
			}
			lastIndex = i;
			tdiByte = getNextByte();  // Now do the bits in the final byte
			expectedByte = getNextByte();
			tdoByte = 0x00;
			i = 1;
			while ( i && leftOver ) {
				leftOver--;
				if ( !leftOver ) {
					TMS = 1; // Exit Shift-DR state on next clock
				}
				TDI = tdiByte & 1;
				tdiByte >>= 1;
				if ( TDO ) {
					tdoByte |= i;
				}
				TCK = 1;
				TCK = 0;
				i <<= 1;
			}
			if ( (tdoByte & tdoMask[lastIndex]) != (expectedByte & tdoMask[lastIndex]) ) {
				returnCode = ERROR_CSVF_FAILED_COMPARE;
				goto cleanup;
			}
			jtagClockFSM(0x00000001, 2);
			if ( xruntest ) {
				jtagClocks(xruntest);
			}
			break;
		}

		case XSDR:
			jtagClockFSM(0x00000001, 3);
			shiftOutCsvf(xsdrSize, true);
			jtagClockFSM(0x00000001, 2);
			if ( xruntest ) {
				jtagClocks(xruntest);
			}
			break;

		default:
			returnCode = ERROR_CSVF_BAD_COMMAND;
			goto cleanup;
		}
		thisByte = getNextByte();
	}
cleanup:
	return returnCode;
}

// Enable or disable the JTAG lines (i.e drive them or tristate them)
//
void jtagSetEnabled(bool enabled) {
	if ( enabled ) {
		JTAG_OE |= (bmTDI | bmTMS | bmTCK);
	} else {
		JTAG_OE &= ~(bmTDI | bmTMS | bmTCK);
	}
}		
