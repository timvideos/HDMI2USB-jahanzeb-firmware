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
#include <eputils.h>
#include <delay.h>
#include <makestuff.h>
#include "defs.h"

static uint8 currentConfiguration;  // Current configuration

//#define SYNCDELAY() SYNCDELAY4

// Called when a Set Configuration command is received
//
uint8 handle_set_configuration(uint8 cfg) {
	currentConfiguration = cfg;
	return true;  // Handled by user code
}

// Called when a Get Configuration command is received
//
uint8 handle_get_configuration() {
	return currentConfiguration;
}

// Called when a Get Interface command is received
//
uint8 handle_get_interface(uint8 ifc, uint8 *alt) {
	if ( ifc == 0 ) {
		*alt = 0;
		return true;
	} else {
		return false;
	}
}

// Called when a Set Interface command is received
//
uint8 handle_set_interface(uint8 ifc, uint8 alt) {
	if ( ifc == 0 && alt == 0 ) {
		RESETTOGGLE(0x01);
		RESETTOGGLE(0x81);
		RESETTOGGLE(0x02);
		RESETTOGGLE(0x86);
		return true;
	} else {
		return false;
	}
}
