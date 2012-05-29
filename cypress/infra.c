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

static uint8 currentConfiguration;  // Current configuration
static uint8 alternateSetting = 0;  // Alternate settings

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
	*alt = alternateSetting;
	return true;
}

// Called when a Set Interface command is received
//
uint8 handle_set_interface(uint8 ifc, uint8 alt) {
	alternateSetting = alt;
	return true;
}
