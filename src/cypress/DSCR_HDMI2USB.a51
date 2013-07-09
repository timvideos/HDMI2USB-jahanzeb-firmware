; //////////////////////////////////////////////////////////////////////////////
; /// Copyright (c) 2013, Jahanzeb Ahmad
; /// All rights reserved.
; ///
; /// Redistribution and use in source and binary forms, with or without modification, 
; /// are permitted provided that the following conditions are met:
; ///
; ///  * Redistributions of source code must retain the above copyright notice, 
; ///    this list of conditions and the following disclaimer.
; ///  * Redistributions in binary form must reproduce the above copyright notice, 
; ///    this list of conditions and the following disclaimer in the documentation and/or 
; ///    other materials provided with the distribution.
; ///
; ///    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
; ///    EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
; ///    OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT 
; ///    SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
; ///    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
; ///    LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
; ///    PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
; ///    WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
; ///    ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
; ///   POSSIBILITY OF SUCH DAMAGE.
; ///
; ///
; ///  * http://opensource.org/licenses/MIT
; ///  * http://copyfree.org/licenses/mit/license.txt
; ///
; //////////////////////////////////////////////////////////////////////////////
   
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

public       DeviceDscr, DeviceQualDscr, HighSpeedConfigDscr, FullSpeedConfigDscr, StringDscr,UserDscr,vsheader,vsheaderend

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
	dw  9AFBH; 8 idVendor 2 Vendor ID ; temp vid need to register with usb.org 
	dw  9AFBH; 10 idProduct 2 Product ID ; temp pid need to changes 
	dw  0100H; 12 bcdDevice 2 Device release number (BCD)
	db 	02H; 14 iManufacturer 1 Index of string descriptor for the manufacturer
	db	01H; 15 iProduct 1 Index of string descriptor for the product
	db 	01H; 16 iSerialNumber 1 Index of string descriptor for the serial number
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
	db   DSCR_CONFIG_LEN               			;; Descriptor length
	db   DSCR_CONFIG                  			;; Descriptor type
	db   (HighSpeedConfigDscrEnd-HighSpeedConfigDscr) mod 256 ;; Total Length (LSB)
	db   (HighSpeedConfigDscrEnd-HighSpeedConfigDscr)  /  256 ;; Total Length (MSB)
	db    04H                            ;/* Number of interfaces */
	db    01H                            ;/* Configuration number */
	db    01H                            ;/* COnfiguration string index */
	db    10100000b                      ;/* Config characteristics - bus powered */
	db    0FAH                           ;/* Max power consumption of device (in 2mA unit) : 500mA */

;;;;;;;;;;;;;;;;; UVC ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
    ;/* Interface association descriptor */
    db 08H                           ;/* Descriptor size */
    db 0Bh      					 ;/* Interface association descr type */
    db 00H                           ;/* I/f number of first video control i/f */
    db 02H                           ;/* Number of video streaming i/f */
    db 0EH                           ;/* CC_VIDEO : Video i/f class code */
    db 03H                           ;/* SC_VIDEO_INTERFACE_COLLECTION : subclass code */
    db 00H                           ;/* Protocol : not used */
    db 01H                           ;/* String desc index for interface */

    ;/* Standard video control interface descriptor */
    db 09H                           ;/* Descriptor size */
    db DSCR_INTRFC  				 ;/* Interface descriptor type */
    db 00H                           ;/* Interface number */
    db 00H                           ;/* Alternate setting number */
    db 00H                           ;/* Number of end points */
    db 0EH                           ;/* CC_VIDEO : Interface class */
    db 01H                           ;/* CC_VIDEOCONTROL : Interface sub class */
    db 00H                           ;/* Interface protocol code */
    db 00H                           ;/* Interface descriptor string index */

    ;/* Class specific VC interface header descriptor */
    db 0DH                           ;/* Descriptor size */
    db 24H                           ;/* Class Specific I/f header descriptor type */
    db 01H                           ;/* Descriptor sub type : VC_HEADER */
    db 00H,01H                      ;/* Revision of class spec : 1.0 */
    db 50H,00H                      ;/* Total size of class specific descriptors (till output terminal) */
    db 00H,6CH,0DCH,02H            ;/* Clock frequency : 48MHz */
    db 01H                           ;/* Number of streaming interfaces */
    db 01H                           ;/* Video streaming I/f 1 belongs to VC i/f */

    ;/* Input (camera) terminal descriptor */
    db 12H                           ;/* Descriptor size */
    db 24H                           ;/* Class specific interface desc type */
    db 02H                           ;/* Input Terminal Descriptor type */
    db 01H                           ;/* ID of this terminal */
    db 01H,02H                      ;/* Camera terminal type */
    db 00H                           ;/* No association terminal */
    db 00H                           ;/* String desc index : not used */
    db 00H,00H                      ;/* No optical zoom supported */
    db 00H,00H                      ;/* No optical zoom supported */
    db 00H,00H                      ;/* No optical zoom supported */
    db 03H                           ;/* Size of controls field for this terminal : 3 bytes */
    db 00H,00H,00H                 ;/* No controls supported */

    ;/* Processing unit descriptor */
    db 0CH                           ;/* Descriptor size */
    db 24H                           ;/* Class specific interface desc type */
    db 05H                           ;/* Processing unit descriptor type */
    db 02H                           ;/* ID of this terminal */
    db 01H                           ;/* Source ID : 1 : conencted to input terminal */
    db 00H,00H                      ;/* Digital multiplier */
    db 03H                           ;/* Size of controls field for this terminal : 3 bytes */
    db 00H,00H,00H                 ;/* No controls supported */
    db 00H                           ;/* String desc index : not used */

    ;/* Extension unit descriptor */
    db 1CH                           ;/* Descriptor size */
    db 24H                           ;/* Class specific interface desc type */
    db 06H                           ;/* Extension unit descriptor type */
    db 03H                           ;/* ID of this terminal */
    db 0FFH,0FFH,0FFH,0FFH            ;/* 16 byte GUID */
    db 0FFH,0FFH,0FFH,0FFH
    db 0FFH,0FFH,0FFH,0FFH
    db 0FFH,0FFH,0FFH,0FFH
    db 00H                           ;/* Number of controls in this terminal */
    db 01H                           ;/* Number of input pins in this terminal */
    db 02H                           ;/* Source ID : 2 : connected to proc unit */
    db 03H                           ;/* Size of controls field for this terminal : 3 bytes */
    db 00H,00H,00H                 ;/* No controls supported */
    db 00H                           ;/* String desc index : not used */

    ;/* Output terminal descriptor */
    db 09H                           ;/* Descriptor size */
    db 24H                           ;/* Class specific interface desc type */
    db 03H                           ;/* Output terminal descriptor type */
    db 04H                           ;/* ID of this terminal */
    db 01H,01H                      ;/* USB Streaming terminal type */
    db 00H                           ;/* No association terminal */
    db 03H                           ;/* Source ID : 3 : connected to extn unit */
    db 00H                           ;/* String desc index : not used */


    ;/* Standard video streaming interface descriptor (alternate setting 0) */
    db 09H                           ;/* Descriptor size */
    DB DSCR_INTRFC					 ;/* Interface descriptor type */
    db 01H                           ;/* Interface number */
    db 00H                           ;/* Alternate setting number */
    db 00H                           ;/* Number of end points : zero bandwidth */
    db 0EH                           ;/* Interface class : CC_VIDEO */
    db 02H                           ;/* Interface sub class : CC_VIDEOSTREAMING */
    db 00H                           ;/* Interface protocol code : undefined */
    db 00H                           ;/* Interface descriptor string index */
	
vsheader:
    ;/* Class-specific video streaming input header descriptor */
    db 0FH                           ;/* Descriptor size */
    db 24H                           ;/* Class-specific VS i/f type */
    db 01H                           ;/* Descriptotor subtype : input header */
    db 02H                           ;/* 2 format desciptor follows */	
	db   (vsheaderend-vsheader) mod 256 ;; Total Length (LSB)
	db   (vsheaderend-vsheader)  /  256 ;; Total Length (MSB)	
    DB 86H             				 ;/* EP address for BULK video data */
    db 00H                           ;/* No dynamic format change supported */
    db 04H                           ;/* Output terminal ID : 4 */
    db 01H                           ;/* Still image capture method 1 supported */
    db 01H                           ;/* Hardware trigger supported for still image */
    db 00H                           ;/* Hardware to initiate still image capture */
    db 01H                           ;/* Size of controls field : 1 byte */
    db 00H                           ;/* D2 : Compression quality supported */
    db 00H                           ;/* D2 : Compression quality supported */

	
	;;;;;;;;;;;;;; MJPEG ;;;;;;;;;;;;;	
	
	;/* Class specific VS format descriptor */
    db 0BH                           ;/* Descriptor size */
    db 24H                           ;/* Class-specific VS i/f type */
    db 06H                           ;/* Descriptotor subtype : VS_FORMAT_MJPEG */
    db 01H                           ;/* Format desciptor index */
    db 02H                           ;/* 2 Frame desciptor follows */
    db 01H                           ;/* Uses fixed size samples */
    db 01H                           ;/* Default frame index is 1 */
    db 00H                           ;/* Non interlaced stream not reqd. */
    db 00H                           ;/* Non interlaced stream not reqd. */
    db 00H                           ;/* Non interlaced stream */
    db 00H                           ;/* CopyProtect: duplication unrestricted */
    
	;/* Class specific VS frame descriptor */	1
	db 1EH                           ;/* Descriptor size */
    db 24H                           ;/* Class-specific VS I/f Type */
    db 07H                           ;/* Descriptotor subtype : VS_FRAME_MJPEG */
    db 01H                           ;/* Frame desciptor index */
    db 02H                           ;/* Still image capture method not supported */
    db 00H,04H                       ;/* Width of the frame : 1024 */
    db 00H,03H                       ;/* Height of the frame : 768 */
    db 00H,00H,00H,0EH  			 ;/* Min bit rate bits/s */
    db 00H,00H,00H,0EH   			 ;/* max bit rate bits/s */
    db 00H,00H,18H,00H     			 ;/* Maximum video or still frame size in bytes */
    db 2AH,2CH,0AH,00H               ;/* Default frame interval */
    db 01H                           ;/* Frame interval type : No of discrete intervals */
    db 2AH,2CH,0AH,00H            	 ;/* Frame interval 1 */
	
	;/* Class specific VS frame descriptor */	2
	db 1EH                           ;/* Descriptor size */
    db 24H                           ;/* Class-specific VS I/f Type */
    db 07H                           ;/* Descriptotor subtype : VS_FRAME_MJPEG */
    db 02H                           ;/* Frame desciptor index */
    db 02H                           ;/* Still image capture method not supported */
    db 00H,05H                       ;/* Width of the frame : 1280 */
    db 0D0H,02H                       ;/* Height of the frame : 720 */
    db 00H,00H,00H,0EH  			 ;/* Min bit rate bits/s */
    db 00H,00H,00H,0EH   			 ;/* max bit rate bits/s */
    db 00H,20H,1CH,00H     			 ;/* Maximum video or still frame size in bytes */
    db 2AH,2CH,0AH,00H               ;/* Default frame interval */
    db 01H                           ;/* Frame interval type : No of discrete intervals */
    db 2AH,2CH,0AH,00H            	 ;/* Frame interval 1 */
	
	
	; VS Color Matching Descriptor Descriptor
	db 06H ; (6 bytes)
	db 24H ; (Video Streaming Interface)
	db 0DH ; (Color Matching)
	db 01H ; (BT.709, sRGB)
	db 01H ; (BT.709)
	db 04H ; (SMPTE 170M)		
	

	;;;;;;;;;;;;;;;;;;;; YUY2 ;;;;;;;;;;;;;;;;;;;;;;;;

	;/* Class specific VS format descriptor */
	db 1BH                          ; /* Descriptor size */
	db 24H                          ; /* Class-specific VS I/f Type */
	db 04H                          ; /* Subtype : uncompressed format I/F */
	db 02H                          ; /* Format desciptor index (only one format is supported) */
	db 02H                          ; /* number of frame descriptor followed */
	db 59H,55H,59H,32H           	; /* GUID, globally unique identifier used to identify streaming-encoding format: YUY2  */       
	db 00H,00H,10H,00H
	db 80H,00H,00H,0AAH  
	db 00H,38H,9BH,71H       
	db 10H                           ;/* Number of bits per pixel used to specify color in the decoded video frame. 0 if not applicable: 10 bit per pixel */
	db 01H                           ;/* Optimum Frame Index for this stream: 1 */
	db 00H                           ;/* X dimension of the picture aspect ratio: Non-interlaced in progressive scan */
	db 00H                           ;/* Y dimension of the pictuer aspect ratio: Non-interlaced in progressive scan*/
	db 00H                           ;/* Interlace Flags: Progressive scanning, no interlace */
	db 00H                           ;/* duplication of the video stream restriction: 0 - no restriction */

	; Frame descriptors 1
	db 1EH                           ;/* Descriptor size */
	db 24H                           ;/* Class-specific VS I/f Type */
	db 05H                           ;/* Descriptotor subtype uncompressed frame I/F  */
	db 01H                           ;/* Frame desciptor index */
	db 02H                           ;/* Still image capture method not supported */
	db 00H,04H                       ;/* Width of the frame : 1024 */
	db 00H,03H                       ;/* Height of the frame : 768 */
	db 00H,00H,00H,0EH  			 ;/* Min bit rate bits/s */
	db 00H,00H,00H,0EH  			 ;/* max bit rate bits/s */
	db 00H,00H,18H,00H   			 ;/* Maximum video or still frame size in bytes */
	db 54H,58H,14H,00H  			 ;/* Default frame interval */
	db 01H                           ;/* Frame interval type : No of discrete intervals */
	db 54H,58H,14H,00H   			 ;/* Frame interval 3 */


	; Frame descriptors 2
	db 1EH                           ;/* Descriptor size */
    db 24H                           ;/* Class-specific VS I/f Type */
    db 05H                           ;/* Descriptotor subtype uncompressed frame I/F  */
    db 02H                           ;/* Frame desciptor index */
    db 02H                           ;/* Still image capture method not supported */
    db 00H,05H                       ;/* Width of the frame : 1280 */
    db 0D0H,02H                       ;/* Height of the frame : 720 */
	db 00H,00H,00H,0EH  			 ;/* Min bit rate bits/s */
	db 00H,00H,00H,0EH  			 ;/* max bit rate bits/s */
	db 00H,20H,1CH,00H   			 ;/* Maximum video or still frame size in bytes */
	db 54H,58H,14H,00H  			 ;/* Default frame interval */
	db 01H                           ;/* Frame interval type : No of discrete intervals */
	db 54H,58H,14H,00H   			 ;/* Frame interval 3 */
	
	; VS Color Matching Descriptor Descriptor
	db 06H ; (6 bytes)
	db 24H ; (Video Streaming Interface)
	db 0DH ; (Color Matching)
	db 01H ; (BT.709, sRGB)
	db 01H ; (BT.709)
	db 04H ; (SMPTE 170M)
	
	
vsheaderend:

    ;/* Standard video streaming interface descriptor (alternate setting 1) */
    db 09H                ;/* Descriptor size */
    DB DSCR_INTRFC        ;/* Interface descriptor type */
    db 01H                ;/* Interface number */
    db 01H                ;/* Alternate setting number */
    db 01H                ;/* Number of end points  */
    db 0EH                ;/* Interface class : CC_VIDEO */
    db 02H                ;/* Interface sub class : CC_VIDEOSTREAMING */
    db 00H                ;/* Interface protocol code : undefined */
    db 00H                ;/* Interface descriptor string index */

    ;/* Endpoint descriptor for streaming video data */
    db 07H              ;/* Descriptor size */
    db DSCR_ENDPNT 		;/* Endpoint descriptor type */
    db 86H            	;/* Endpoint address and description */
    db ET_ISO			;/* Bulk Endpoint */
    db 00H
    db 04H              ;/* 1024 Bytes Maximum Packet Size. */
    db 01H              ;/* Servicing interval for data transfers */


	;;;;;;;;;;;;;;;;;;;;;;;;;; CDC ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	db	08H			; 0 bLength 1 Descriptor size in bytes (08h)
	db	0BH			; 1 bDescriptorType 1 The constant Interface Association (0Bh)
	db	02H			; 2 bFirstInterface 1 Number identifying the first interface associated with the function
	db	02H 		; 3 bInterfaceCount 1 The number of contiguous interfaces associated with the function 
	db	02H			; 4 bFunctionClass 1 Class code
	db	00H			; 5 bFunctionSubClass 1 Subclass code
	db	01H			; 6 bFunctionProtocol 1 Protocol code
	db	01H			; 8 iFunction 1 Index of string descriptor for the function

	
	db   DSCR_INTRFC_LEN    ; Descriptor length
	db   DSCR_INTRFC        ; Descriptor type
	db   02H                ; Zero-based index of this interface
	db   00H                ; Alternate setting
	db   01H                ; Number of end points
	db   02H                ; Interface class
	db   02H                ; Interface sub class
	db   01H                ; Interface protocol code class
	db   01H                ; Interface descriptor string index

	;; Header Functional Descriptor
	db   05H				; Descriptor Size in Bytes (5)
	db   24H				; CS_Interface
	db   00H				; Header Functional Descriptor
	dw   1001H				; bcdCDC

	;; Union Functional Descriptor
	db   05H				; Descriptor Size in Bytes (5)
	db   24H				; CS_Interface
	db   06H				; Union Functional Descriptor
	db   02H				; bMasterInterface
	db   03H				; bSlaveInterface0

	;; CM Functional Descriptor
	db   05H				; Descriptor Size in Bytes (5)
	db   24H				; CS_Interface
	db   01H				; CM Functional Descriptor
	db   00H				; bmCapabilities
	; db   03H				; bmCapabilities
	db   03H				; bDataInterface
	
	;; ACM Functional Descriptor
	db   04H				; Descriptor Size in Bytes (5)
	db   24H				; CS_Interface
	db   02H				; Abstarct Control Management Functional Desc
	db   02H				; bmCapabilities
	; db   07H				; bmCapabilities





	;; EP1 Descriptor
	db   DSCR_ENDPNT_LEN    ; Descriptor length
	db   DSCR_ENDPNT        ; Descriptor type
	db   81H                ; Endpoint number, and direction
	db   ET_INT             ; Endpoint type
	db   10H                ; Maximum packet size (LSB)
	db   00H                ; Max packet size (MSB)
	db   11H               ; Polling interval


	;; Virtual COM Port Data Interface Descriptor
	db   DSCR_INTRFC_LEN    ; Descriptor length
	db   DSCR_INTRFC        ; Descriptor type
	db   3                  ; Zero-based index of this interface
	db   0                  ; Alternate setting
	db   2                  ; Number of end points
	db   0AH                ; Interface class
	db   00H                ; Interface sub class
	db   00H                ; Interface protocol code class
	db   1                  ; Interface descriptor string index
	
	;; EP4 Descriptor
	db   DSCR_ENDPNT_LEN    ; Descriptor length
	db   DSCR_ENDPNT        ; Descriptor type
	db   84H                ; Endpoint number, and direction
	db   ET_BULK            ; Endpoint type
	db   00H                ; Maximum packet size (LSB)
	db   02H                ; Max packet size (MSB)
	db   00H                ; Polling interval

	;; EP2OUT Descriptor
	db   DSCR_ENDPNT_LEN    ; Descriptor length
	db   DSCR_ENDPNT        ; Descriptor type
	db   02H                ; Endpoint number, and direction
	db   ET_BULK            ; Endpoint type
	db   00H                ; Maximum packet size (LSB)
	db   02H                ; Max packet size (MSB)
	db   00H                ; Polling interval

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
      
