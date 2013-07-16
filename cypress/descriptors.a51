;
; Copyright (C) 2009 Ubixum, Inc.
;
; Copyright (C) 2009-2012 Chris McClelland
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU Lesser General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU Lesser General Public License for more details.
;
; You should have received a copy of the GNU Lesser General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;
; this is a the default 
; full speed and high speed 
; descriptors found in the TRM
; change however you want but leave 
; the descriptor pointers so the setupdat.c file works right 

.module DEV_DSCR 

.include "date.inc"

; descriptor types
; same as setupdat.h
DSCR_DEVICE_TYPE=1
DSCR_CONFIG_TYPE=2
DSCR_STRING_TYPE=3
DSCR_INTERFACE_TYPE=4
DSCR_ENDPOINT_TYPE=5
DSCR_DEVQUAL_TYPE=6

; for the repeating interfaces
DSCR_INTERFACE_LEN=9
DSCR_ENDPOINT_LEN=7

; endpoint types
ENDPOINT_TYPE_CONTROL=0
ENDPOINT_TYPE_ISO=1
ENDPOINT_TYPE_BULK=2
ENDPOINT_TYPE_INT=3

LEN=(highspd_dscr_realend-_highspd_dscr)
LEN_LE=((LEN&0x00FF)<<8)+(LEN>>8)
VID_LE=((VID&0x00FF)<<8)+(VID>>8)
PID_LE=((PID&0x00FF)<<8)+(PID>>8)
DID_LE=((DID&0x00FF)<<8)+(DID>>8)

	.globl _dev_dscr, _dev_qual_dscr, _highspd_dscr, _fullspd_dscr, _dev_strings, _dev_strings_end

; These need to be in code memory. If they aren't you'll have to
; manully copy them somewhere in code memory otherwise SUDPTRH:L
; don't work right

	.area DSCR_AREA (CODE)

; DEVICE DESCRIPTOR
_dev_dscr:
	.db    dev_dscr_end-_dev_dscr         ; bLength
	.db    DSCR_DEVICE_TYPE               ; bDescriptorType
	.dw    0x0002                         ; bcdUSB          (2.0)
	.db    0x00                           ; bDeviceClass    (Defined at Interface level)
	.db    0x00                           ; bDeviceSubClass (Defined at Interface level)
	.db    0x00                           ; bDeviceProtocol (Defined at Interface level)
	.db    64                             ; bMaxPacketSize0 (EP0)
	.dw    VID_LE                         ; idVendor
	.dw    PID_LE                         ; idProduct
	.dw    DID_LE                         ; bcdDevice
	.db    1                              ; iManufacturer
	.db    2                              ; iProduct
	.db    0                              ; iSerial
	.db    1                              ; bNumConfigurations
dev_dscr_end:

; CONFIGURATION DESCRIPTOR
_highspd_dscr:
	.db    highspd_dscr_end-_highspd_dscr ; bLength
	.db    DSCR_CONFIG_TYPE               ; bDescriptorType
	.dw    LEN_LE                         ; wTotalLength
	.db    1                              ; bNumInterfaces
	.db    1                              ; bConfigurationValue
	.db    0                              ; iConfiguration (string index)
	.db    0x80                           ; bmAttributes (bus powered, no wakeup)
	.db    250                            ; MaxPower 500mA
highspd_dscr_end:

; INTERFACE DESCRIPTOR
	.db    DSCR_INTERFACE_LEN             ; bLength
	.db    DSCR_INTERFACE_TYPE            ; bDescriptorType
	.db    0                              ; bInterfaceNumber
	.db    0                              ; bAlternateSetting
	.db    4                              ; bNumEndpoints
	.db    0xff                           ; bInterfaceClass
	.db    0x00                           ; bInterfaceSubClass
	.db    0x00                           ; bInterfaceProtocol
	.db    0                              ; iInterface (string index)

; EP1OUT
	.db    DSCR_ENDPOINT_LEN              ; bLength
	.db    DSCR_ENDPOINT_TYPE             ; bDescriptorType
	.db    0x01                           ; bEndpointAddress (0x01 = EP1OUT)
	.db    ENDPOINT_TYPE_BULK             ; bmAttributes
	.db    0x00                           ; wMaxPacketSize LSB
	.db    0x02                           ; wMaxPacketSize MSB (0x0200 = 512 bytes, but buffer is only 64 bytes)
	.db    0x00                           ; bInterval

; EP1IN
	.db    DSCR_ENDPOINT_LEN              ; bLength
	.db    DSCR_ENDPOINT_TYPE             ; bDescriptorType
	.db    0x81                           ; bEndpointAddress (0x81 = EP1IN)
	.db    ENDPOINT_TYPE_BULK             ; bmAttributes
	.db    0x00                           ; wMaxPacketSize LSB
	.db    0x02                           ; wMaxPacketSize MSB (0x0200 = 512 bytes, but buffer is only 64 bytes)
	.db    0x00                           ; bInterval

; EP2OUT
	.db    DSCR_ENDPOINT_LEN              ; bLength
	.db    DSCR_ENDPOINT_TYPE             ; bDescriptorType
	.db    0x02                           ; bEndpointAddress
	.db    ENDPOINT_TYPE_BULK             ; bmAttributes
	.db    0x00                           ; wMaxPacketSize LSB
	.db    0x02                           ; wMaxPacketSize MSB (0x0200 = 512 bytes)
	.db    0x00                           ; bInterval

; EP4OUT
;	.db    DSCR_ENDPOINT_LEN              ; bLength
;	.db    DSCR_ENDPOINT_TYPE             ; bDescriptorType
;	.db    0x04                           ; bEndpointAddress
;	.db    ENDPOINT_TYPE_BULK             ; bmAttributes
;	.db    0x00                           ; wMaxPacketSize LSB
;	.db    0x02                           ; wMaxPacketSize MSB (0x0200 = 512 bytes)
;	.db    0x00                           ; bInterval

; EP6IN
	.db    DSCR_ENDPOINT_LEN              ; bLength
	.db    DSCR_ENDPOINT_TYPE             ; bDescriptorType
	.db    0x86                           ; bEndpointAddress
	.db    ENDPOINT_TYPE_BULK             ; bmAttributes
	.db    0x00                           ; wMaxPacketSize LSB
	.db    0x02                           ; wMaxPacketSize MSB (0x0200 = 512 bytes)
	.db    0x00                           ; bInterval

; EP8IN
;	.db    DSCR_ENDPOINT_LEN              ; bLength
;	.db    DSCR_ENDPOINT_TYPE             ; bDescriptorType
;	.db    0x88                           ; bEndpointAddress
;	.db    ENDPOINT_TYPE_BULK             ; bmAttributes
;	.db    0x00                           ; wMaxPacketSize LSB
;	.db    0x02                           ; wMaxPacketSize MSB (0x0200 = 512 bytes)
;	.db    0x00                           ; bInterval

highspd_dscr_realend:

_dev_qual_dscr:
	.db    dev_qualdscr_end-_dev_qual_dscr  ; bLength
	.db    DSCR_DEVQUAL_TYPE                ; bDescriptorType
	.dw    0x0002                           ; bcdUSB          (2.0)
	.db    0x00                             ; bDeviceClass    (Defined at Interface level)
	.db    0x00                             ; bDeviceSubClass (Defined at Interface level)
	.db    0x00                             ; bDeviceProtocol (Defined at Interface level)
	.db    64                               ; bMaxPacketSize0 (EP0)
	.db    1                                ; bNumConfigurations
	.db    0                                ; bReserved
dev_qualdscr_end:


.even
_fullspd_dscr:
	.db    fullspd_dscr_end-_fullspd_dscr      ; Descriptor length
	.db    DSCR_CONFIG_TYPE
	; can't use .dw because byte order is different
	.db    (fullspd_dscr_realend-_fullspd_dscr) % 256 ; total length of config lsb
	.db    (fullspd_dscr_realend-_fullspd_dscr) / 256 ; total length of config msb
	.db    1                         ; n interfaces
	.db    1                         ; config number
	.db    0                         ; config string
	.db    0x80                      ; attrs = bus powered, no wakeup
	.db    0x32                      ; max power = 100ma
fullspd_dscr_end:

; all the interfaces next 
; NOTE the default TRM actually has more alt interfaces
; but you can add them back in if you need them.
; here, we just use the default alt setting 1 from the trm
	.db    DSCR_INTERFACE_LEN
	.db    DSCR_INTERFACE_TYPE
	.db    0                         ; index
	.db    0                         ; alt setting idx
	.db    1                         ; n endpoints    
	.db    0xff                      ; class
	.db    0xff
	.db    0xff
	.db    0                         ; string index    

; The sole endpoint:
	.db    DSCR_ENDPOINT_LEN
	.db    DSCR_ENDPOINT_TYPE
	.db    0x06                      ; 0x82 = EP2IN, 0x02 = EP2OUT
	.db    ENDPOINT_TYPE_BULK        ; type
	.db    0x00                      ; max packet LSB
	.db    0x02                      ; max packet size=512 bytes
	.db    0x00                      ; polling interval
fullspd_dscr_realend:

	.even
_dev_strings:
_string0:
	.db    string0end-_string0       ; len
	.db    DSCR_STRING_TYPE
	.db    0x09, 0x04                ; 0x0409 is the language code for English.
string0end:

string1:
	.db    string1end-string1
	.db    DSCR_STRING_TYPE
	.ascii 'M'
	.db    0
	.ascii 'a'
	.db    0
	.ascii 'k'
	.db    0
	.ascii 'e'
	.db    0
	.ascii 'S'
	.db    0
	.ascii 't'
	.db    0
	.ascii 'u'
	.db    0
	.ascii 'f'
	.db    0
	.ascii 'f'
	.db    0
string1end:

string2:
	.db    string2end-string2
	.db    DSCR_STRING_TYPE
	.ascii 'F'
	.db    0
	.ascii 'P'
	.db    0
	.ascii 'G'
	.db    0
	.ascii 'A'
	.db    0
	.ascii 'L'
	.db    0
	.ascii 'i'
	.db    0
	.ascii 'n'
	.db    0
	.ascii 'k'
	.db    0
	.ascii '/'
	.db    0
	.ascii 'F'
	.db    0
	.ascii 'X'
	.db    0
	.ascii '2'
	.db    0
	.ascii ' '
	.db    0
	.db    ((DATE>>(7*4))&0xF) + 48
	.db    0
	.db    ((DATE>>(6*4))&0xF) + 48
	.db    0
	.db    ((DATE>>(5*4))&0xF) + 48
	.db    0
	.db    ((DATE>>(4*4))&0xF) + 48
	.db    0
	.db    ((DATE>>(3*4))&0xF) + 48
	.db    0
	.db    ((DATE>>(2*4))&0xF) + 48
	.db    0
	.db    ((DATE>>(1*4))&0xF) + 48
	.db    0
	.db    (DATE&0xF) + 48
	.db    0
string2end:

_dev_strings_end:
	.dw 0x0000                       ; in case you wanted to look at memory between _dev_strings and _dev_strings_end
