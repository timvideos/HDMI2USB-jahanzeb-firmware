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
#include <makestuff.h>

static xdata uint8 currentByte;

// Wait for the I2C interface to complete the current send or receive operation. Return true if
// there was a bus error, else return false if the operation completed successfully.
//
static bool promWaitForDone(void) {
	xdata uint8 i;
	while ( !((i = I2CS) & bmDONE) );  // Poll the done bit
	if ( i & bmBERR ) {
		return true;
	} else {
		return false;
	}
}	

// Wait for the I2C interface to complete the current send operation. Return true if there was a
// bus error or the slave failed to acknowledge receipt of the byte, else return false if the
// operation completed successfully.
//
static bool promWaitForAck(void) {
	xdata uint8 i;
	while ( !((i = I2CS) & bmDONE) );  // Poll the done bit
	if ( i & bmBERR ) {
		return true;
	} else if ( !(i & bmACK) ) {
		return true;
	} else {
		return false;
	}
}

// Peek the current byte
//
uint8 promPeekByte() {
	return currentByte;
}

// Read the next EEPROM byte so it can be peeked.
//
bool promNextByte(void) {
	
	// Now get the actual data
	//
	if ( promWaitForDone() ) {
		return true;
	}
	currentByte = I2DAT;
	
	return false;
}

// Start a read operation at the specified address. The first byte is read so it can be peeked.
//
bool promStartRead(uint16 addr) {
	xdata uint8 i;

	// Wait for I2C idle
	//
	while ( I2CS & bmSTOP );

	// Send the WRITE command
	//
	I2CS = bmSTART;
	I2DAT = 0xA2;  // Write I2C address byte (WRITE)
	if ( promWaitForAck() ) {
		return true;
	}
	
	// Send the address, MSB first
	//
	I2DAT = MSB(addr);  // Write MSB of address
	if ( promWaitForAck() ) {
		return true;
	}
	I2DAT = LSB(addr);  // Write LSB of address
	if ( promWaitForAck() ) {
		return true;
	}

	// Send the READ command
	//
	I2CS = bmSTART;
	I2DAT = 0xA3;  // Write I2C address byte (READ)
	if ( promWaitForDone() ) {
		return true;
	}

	// Read dummy byte
	//
	i = I2DAT;

	return promNextByte();
}

// Stop the current read operation.
//
bool promStopRead(void) {
	xdata uint8 i;
	// Wait for current operation to finish
	//
	if ( promWaitForDone() ) {
		return true;
	}

	// Terminate the read operation and get last byte
	//
	I2CS = bmLASTRD;
	i = I2DAT;
	if ( promWaitForDone() ) {
		return true;
	}
	I2CS = bmSTOP;

	return false;
}

// Read "length" bytes from address "addr" in the attached EEPROM, and write them to RAM at "buf".
//
bool promRead(uint16 addr, uint8 length, xdata uint8 *buf) {
	xdata uint8 i;
	
	// Wait for I2C idle
	//
	while ( I2CS & bmSTOP );

	// Send the WRITE command
	//
	I2CS = bmSTART;
	I2DAT = 0xA2;  // Write I2C address byte (WRITE)
	if ( promWaitForAck() ) {
		return true;
	}
	
	// Send the address, MSB first
	//
	I2DAT = MSB(addr);  // Write MSB of address
	if ( promWaitForAck() ) {
		return true;
	}
	I2DAT = LSB(addr);  // Write LSB of address
	if ( promWaitForAck() ) {
		return true;
	}

	// Send the READ command
	//
	I2CS = bmSTART;
	I2DAT = 0xA3;  // Write I2C address byte (READ)
	if ( promWaitForDone() ) {
		return true;
	}

	// Read dummy byte
	//
	i = I2DAT;
	if ( promWaitForDone() ) {
		return true;
	}

	// Now get the actual data
	//
	for ( i = 0; i < (length-1); i++ ) {
		buf[i] = I2DAT;
		if ( promWaitForDone() ) {
			return true;
		}
	}

	// Terminate the read operation and get last byte
	//
	I2CS = bmLASTRD;
	if ( promWaitForDone() ) {
		return true;
	}
	buf[i] = I2DAT;
	if ( promWaitForDone() ) {
		return true;
	}
	I2CS = bmSTOP;
	i = I2DAT;

	return false;
}

// Read "length" bytes from RAM at "buf", and write them to the attached EEPROM at address "addr".
//
bool promWrite(uint16 addr, uint8 length, const xdata uint8 *buf) {
	xdata uint8 i;

	// Wait for I2C idle
	//
	while ( I2CS & bmSTOP );

	// Send the WRITE command
	//
	I2CS = bmSTART;
	I2DAT = 0xA2;  // Write I2C address byte (WRITE)
	if ( promWaitForAck() ) {
		return true;
	}

	// Send the address, MSB first
	//
	I2DAT = MSB(addr);  // Write MSB of address
	if ( promWaitForAck() ) {
		return true;
	}
	I2DAT = LSB(addr);  // Write LSB of address
	if ( promWaitForAck() ) {
		return true;
	}

	// Write the data
	//
	for ( i = 0; i < length; i++ ) {
		I2DAT = *buf++;
		if ( promWaitForDone() ) {
			return true;
		}
	}
	I2CS |= bmSTOP;

	// Wait for I2C idle
	//
	while ( I2CS & bmSTOP );

	do {
		I2CS = bmSTART;
		I2DAT = 0xA2;  // Write I2C address byte (WRITE)
		if ( promWaitForDone() ) {
			return true;
		}
		I2CS |= bmSTOP;
		while ( I2CS & bmSTOP );
	} while ( !(I2CS & bmACK) );
	
	return false;
}
