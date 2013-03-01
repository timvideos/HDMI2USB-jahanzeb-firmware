;;-----------------------------------------------------------------------------
;;   File:      dscr.a51
;;   Contents:  This file contains descriptor data tables.
;;
;; $Archive: /USB/Examples/FX2LP/hid_kb/dscr.a51 $
;; $Date: 5/27/04 1:25p $
;; $Revision: 2 $
;;
;;
;;-----------------------------------------------------------------------------
;; Copyright 2003H  Cypress Semiconductor Corporation
;;-----------------------------------------------------------------------------
;;-----------------------------------------------------------------------------
   
DSCR_DEVICE   equ   1   ;; Descriptor type: Device
DSCR_CONFIG   equ   2   ;; Descriptor type: Configuration
DSCR_STRING   equ   3   ;; Descriptor type: String
DSCR_INTRFC   equ   4   ;; Descriptor type: Interface
DSCR_ENDPNT   equ   5   ;; Descriptor type: Endpoint
DSCR_DEVQUAL  equ   6   ;; Descriptor type: Device Qualifier

DSCR_DEVICE_LEN   equ   18
DSCR_CONFIG_LEN   equ    9
DSCR_INTRFC_LEN   equ    9
DSCR_ENDPNT_LEN   equ    7
DSCR_DEVQUAL_LEN  equ   10

ET_CONTROL   equ   0   ;; Endpoint type: Control
ET_ISO       equ   1   ;; Endpoint type: Isochronous
ET_BULK      equ   2   ;; Endpoint type: Bulk
ET_INT       equ   3   ;; Endpoint type: Interrupt

public       DeviceDscr, DeviceQualDscr, HighSpeedConfigDscr, FullSpeedConfigDscr, StringDscr,UserDscr
; public 		VSUserDscrEnd
;public		CSInterfaceDscr, CSInterfaceDscrEND, CSVSInterfaceDscr, CSVSInterfaceDscrEND

DSCR   SEGMENT   CODE PAGE

;;-----------------------------------------------------------------------------
;; Global Variables
;;-----------------------------------------------------------------------------
      rseg DSCR      ;; locate the descriptor table in on-part memory.

DeviceDscr:   

db	12H	; 0 bLength 1 Descriptor size in bytes (12h)
db	01H	; 1 bDescriptorType 1 The constant DEVICE (01h)
db	00H; 2 bcdUSB 2 USB specification release number (BCD)
db	02H; 2 bcdUSB 2 USB specification release number (BCD)
db	0EFH; 4 bDeviceClass 1 Class code
db	02H; 5 bDeviceSubclass 1 Subclass code
db 	01H; 6 bDeviceProtocol 1 Protocol Code
db  64 ; 7 bMaxPacketSize0 1 Maximum packet size for endpoint zero
dw  9AFBH; 8 idVendor 2 Vendor ID
dw  9AFBH; 10 idProduct 2 Product ID
dw  0100H; 12 bcdDevice 2 Device release number (BCD)
db 	02H; 14 iManufacturer 1 Index of string descriptor for the manufacturer
db	01H; 15 iProduct 1 Index of string descriptor for the product
db 	00H; 16 iSerialNumber 1 Index of string descriptor for the serial number
db	01H; 17 bNumConfigurations 1 Number of possible configurations 


DeviceQualDscr:

db   0AH	; 0 bLength 1 Descriptor size in bytes (0Ah)
db   06H; 1 bDescriptorType 1 The constant DEVICE_QUALIFIER (06h)
db   00H
db   02H ; 2 bcdUSB 2 USB specification release number (BCD)
db   0EFH ; 4 bDeviceClass 1 Class code
db   02H ; 5 bDeviceSubclass 1 Subclass code
db   01H ; 6 bDeviceProtocol 1 Protocol Code
db   40H ; 7 bMaxPacketSize0 1 Maximum packet size for endpoint zero
db   01H ; 8 bNumConfigurations 1 Number of possible configurations
db   00H; 9 Reserved 1 For future use

HighSpeedConfigDscr:  

;;/* Configuration descriptor */
db    09H                           ;;/* Descriptor size */
db 	DSCR_CONFIG        ;/* Configuration descriptor type */
db    0C6h
db    00H                       ;/* Length of this descriptor and all sub descriptors */
db    02H                            ;/* Number of interfaces */
db    01H                            ;/* Configuration number */
db    00H                            ;/* COnfiguration string index */
db    80H                            ;/* Config characteristics - bus powered */
db    0FAH                            ;/* Max power consumption of device (in 2mA unit) : 500mA */

; ;/* Interface association descriptor */
db    08H                            ;/* Descriptor size */
db 0Bh       ;/* Interface association descr type */
db    00H                            ;/* I/f number of first video control i/f */
db    02H                            ;/* Number of video streaming i/f */
db    0EH                            ;/* CC_VIDEO : Video i/f class code */
db    03H                            ;/* SC_VIDEO_INTERFACE_COLLECTION : subclass code */
db    00H                            ;/* Protocol : not used */
db    00H                            ;/* String desc index for interface */

; ;/* Standard video control interface descriptor */
db    09H                            ;/* Descriptor size */
db DSCR_INTRFC         ;/* Interface descriptor type */
db    00H                            ;/* Interface number */
db    00H                            ;/* Alternate setting number */
db    01H                            ;/* Number of end points */
db    0EH                            ;/* CC_VIDEO : Interface class */
db    01H                            ;/* CC_VIDEOCONTROL : Interface sub class */
db    00H                            ;/* Interface protocol code */
db    00H                            ;/* Interface descriptor string index */

; ;/* Class specific VC interface header descriptor */
db    0DH                            ;/* Descriptor size */
db    24H                            ;/* Class Specific I/f header descriptor type */
db    01H                            ;/* Descriptor sub type : VC_HEADER */
db    00H 
db    01H                       ;/* Revision of class spec : 1.0 */
db    50H 
db    00H                       ;/* Total size of class specific descriptors (till output terminal) */
db    00H 
db    6CH 
db    0DCH 
db    02H             ;/* Clock frequency : 48MHz */
db    01H                            ;/* Number of streaming interfaces */
db    01H                            ;/* Video streaming I/f 1 belongs to VC i/f */

; ;/* Input (camera) terminal descriptor */
db    12H                            ;/* Descriptor size */
db    24H                            ;/* Class specific interface desc type */
db    02H                            ;/* Input Terminal Descriptor type */
db    01H                            ;/* ID of this terminal */
db    01H 
db    02H                       ;/* Camera terminal type */
db    00H                            ;/* No association terminal */
db    00H                            ;/* String desc index : not used */
db    00H 
db    00H                       ;/* No optical zoom supported */
db    00H 
db    00H                       ;/* No optical zoom supported */
db    00H 
db    00H                       ;/* No optical zoom supported */
db    03H                            ;/* Size of controls field for this terminal : 3 bytes */
db    00H 
db    00H 
db    00H                  ;/* No controls supported */

; ;/* Processing unit descriptor */
db    0CH                            ;/* Descriptor size */
db    24H                            ;/* Class specific interface desc type */
db    05H                            ;/* Processing unit descriptor type */
db    02H                            ;/* ID of this terminal */
db    01H                            ;/* Source ID : 1 : conencted to input terminal */
db    00H 
db    40H                       ;/* Digital multiplier */
db    03H                            ;/* Size of controls field for this terminal : 3 bytes */
db    00H 
db    00H 
db    00H                  ;/* No controls supported */
db    00H                            ;/* String desc index : not used */

; ;/* Extension unit descriptor */
db    1CH                            ;/* Descriptor size */
db    24H                            ;/* Class specific interface desc type */
db    06H                            ;/* Extension unit descriptor type */
db    03H                            ;/* ID of this terminal */
db    0FFH 
db    0FFH 
db    0FFH 
db    0FFH             ;/* 16 byte GUID */
db    0FFH 
db    0FFH 
db    0FFH 
db    0FFH 
db    0FFH 
db    0FFH 
db    0FFH 
db    0FFH 
db    0FFH 
db    0FFH 
db    0FFH 
db    0FFH 
db    00H                            ;/* Number of controls in this terminal */
db    01H                            ;/* Number of input pins in this terminal */
db    02H                            ;/* Source ID : 2 : connected to proc unit */
db    03H                            ;/* Size of controls field for this terminal : 3 bytes */
db    00H 
db    00H 
db    00H                  ;/* No controls supported */
db    00H                            ;/* String desc index : not used */

; ;/* Output terminal descriptor */
db    09H                            ;/* Descriptor size */
db    24H                            ;/* Class specific interface desc type */
db    03H                            ;/* Output terminal descriptor type */
db    04H                            ;/* ID of this terminal */
db    01H 
db    01H                       ;/* USB Streaming terminal type */
db    00H                            ;/* No association terminal */
db    03H                            ;/* Source ID : 3 : connected to extn unit */
db    00H                            ;/* String desc index : not used */

;  ;/* Video control status interrupt endpoint descriptor */
db    07H                            ;/* Descriptor size */
db DSCR_ENDPNT         ;/* Endpoint descriptor type */
db 81H;CY_FX_EP_CONTROL_STATUSH         ;/* Endpoint address and description */
db ET_INT;CY_U3P_USB_EP_INTRH              ;/* Interrupt end point type */
db    40H 
db    00H                       ;/* Max packet size = 64 bytes */
db    08H                            ;/* Servicing interval : 8ms */

; ;/* Class specific interrupt endpoint descriptor */
db    05H                            ;/* Descriptor size */
db    25H                            ;/* Class specific endpoint descriptor type */
db ET_INT;CY_U3P_USB_EP_INTRH              ;/* End point sub type */
db    40H 
db    00H                       ;/* Max packet size = 64 bytes */

; ;/* Standard video streaming interface descriptor (alternate setting 0) */
db    09H                            ;/* Descriptor size */
db DSCR_INTRFC;CY_U3P_USB_INTRFC_DESCRH         ;/* Interface descriptor type */
db    01H                            ;/* Interface number */
db    00H                            ;/* Alternate setting number */
db    00H                            ;/* Number of end points : zero bandwidth */
db    0EH                            ;/* Interface class : CC_VIDEO */
db    02H                            ;/* Interface sub class : CC_VIDEOSTREAMING */
db    00H                            ;/* Interface protocol code : undefined */
db    00H                            ;/* Interface descriptor string index */

;   ;/* Class-specific video streaming input header descriptor */
db    0EH                            ;/* Descriptor size */
db    24H                            ;/* Class-specific VS i/f type */
db    01H                            ;/* Descriptotor subtype : input header */
db    01H                            ;/* 1 format desciptor follows */
db    19H 
db    00H                       ;/* Total size of class specific VS descr */
db 	86H;CY_FX_EP_ISO_VIDEOH              ;/* EP address for ISO video data */
db    00H                            ;/* No dynamic format change supported */
db    04H                            ;/* Output terminal ID : 4 */
db    01H                            ;/* Still image capture method 1 supported */
db    01H                            ;/* Hardware trigger supported for still image */
db    00H                            ;/* Hardware to initiate still image capture */
db    01H                            ;/* Size of controls field : 1 byte */
db    00H                            ;/* D2 : Compression quality supported */

;  ;/* Class specific VS format descriptor */
db    0BH                            ;/* Descriptor size */
db    24H                            ;/* Class-specific VS i/f type */
db    06H                            ;/* Descriptotor subtype : VS_FORMAT_MJPEG */
db    01H                            ;/* Format desciptor index */
db    01H                            ;/* 1 Frame desciptor follows */
db    01H                            ;/* Uses fixed size samples */
db    01H                            ;/* Default frame index is 1 */
db    00H                            ;/* Non interlaced stream not reqd. */
db    00H                            ;/* Non interlaced stream not reqd. */
db    00H                            ;/* Non interlaced stream */
db    00H                            ;/* CopyProtect: duplication unrestricted */

;  ;/* Class specific VS frame descriptor */
db    1EH                            ;/* Descriptor size */
db    24H                            ;/* Class-specific VS I/f Type */
db    07H                            ;/* Descriptotor subtype : VS_FRAME_MJPEG */
db    01H                            ;/* Frame desciptor index */
db    00H                            ;/* Still image capture method not supported */

;db    0B0H ;lsb
;db    00H   ;msb                    ;/* Width of the frame : 176 */
; db    90H ;lsb
; db    00H  ;msb                     ;/* Height of the frame : 144 */

db    00H ;lsb
db    04H   ;msb                    ;/* Width of the frame : 176 */
db    00H ;lsb
db    03H  ;msb                     ;/* Height of the frame : 144 */

db    00H 
db    0C0H 
db    5DH 
db    00H             ;/* Min bit rate bits/s */

db    00H 
db    0C0H 
db    5DH 
db    00H             ;/* Min bit rate bits/s */

db    00H

db    58H 


db    02H 
db    00H             ;/* Maximum video or still frame size in bytes */

;00 0A 2C 2A
; db    2AH 
; db    2CH 
; db    0AH 
; db    00H             ;/* Default frame interval */


;00 02 8B 0A
db    0AH 
db    8BH 
db    02H 
db    00H             ;/* Default frame interval */

db    01H                            ;/* Frame interval type : No of discrete intervals */

;db    2AH 
;db    2CH 
; db    0AH 
; db    00H             ;/* Frame interval 3 */

db    0AH 
db    8BH 
db    02H 
db    00H            ;/* Frame interval */

;  ;/* Standard video streaming interface descriptor (Alternate Setting 1) */
db    09H                            ;/* Descriptor size */
db DSCR_INTRFC;CY_U3P_USB_INTRFC_DESCRH         ;/* Interface descriptor type */
db    01H                            ;/* Interface number */
db    01H                            ;/* Alternate setting number */
db    01H                            ;/* Number of end points : 1 ISO EP */
db    0EH                            ;/* Interface class : CC_VIDEO */
db    02H                            ;/* Interface sub class : CC_VIDEOSTREAMING */
db    00H                            ;/* Interface protocol code : Undefined */
db    00H                            ;/* Interface descriptor string index */

;   ;/* Endpoint descriptor for ISO streaming video data */
db   	07H                            ;/* Descriptor size */
db	DSCR_ENDPNT;CY_U3P_USB_ENDPNT_DESCRH         ;/* Endpoint descriptor type */
db	86H;CY_FX_EP_ISO_VIDEOH              ;/* Endpoint address and description */
db    	05H                            ;/* ISO End point : Async */
;db    	02H                            ;/* Bulk End point : Async */
db	00H;CY_FX_EP_ISO_VIDEO_PKT_SIZE_LH   ;/* 1 transaction per microframe */
db	02H;CY_FX_EP_ISO_VIDEO_PKT_SIZE_HH   ;/* CY_FX_EP_ISO_VIDEO_PKT_SIZE max bytes */
db    	1                            ;/* Servicing interval for data transfers */
;; Endpoint Descriptor
;      db   DSCR_ENDPNT_LEN      ;; Descriptor length
;      db   DSCR_ENDPNT          ;; Descriptor type
;      db   86H                  ;; Endpoint number, and direction
;      db   ET_BULK              ;; Endpoint type
;      db   00H                  ;; Maximum packet size (LSB)
;      db   02H                  ;; Maximum packet size (MSB)
;      db   0H                  ;; Polling interval

HighSpeedConfigDscrEnd:   

db    00h               ;; pad

FullSpeedConfigDscr:   

FullSpeedConfigDscrEnd:   

      db    00h               ;; pad
StringDscr:

StringDscr0:   
      db   StringDscr0End-StringDscr0      ;; String descriptor length
      db   DSCR_STRING
      db   09H,04H
StringDscr0End:

StringDscr1:   
      db   StringDscr1End-StringDscr1      ;; String descriptor length
      db   DSCR_STRING
      db   'H',00
      db   'D',00
      db   'M',00
      db   'I',00
      db   '2',00
      db   'U',00
      db   'S',00
      db   'B',00
StringDscr1End:

StringDscr2:   
      db   StringDscr2End-StringDscr2      ;; Descriptor length
      db   DSCR_STRING
      db   'J',00
      db   'A',00
      db   'N',00
      db   'I',00
StringDscr2End:

db 0

UserDscr:      
      dw   0000H
      end
      
