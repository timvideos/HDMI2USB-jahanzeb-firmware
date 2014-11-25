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
; ///    POSSIBILITY OF SUCH DAMAGE.
; ///
; ///  * http://opensource.org/licenses/MIT
; ///  * http://copyfree.org/licenses/mit/license.txt
; ///
; //////////////////////////////////////////////////////////////////////////////

        DSCR_DEVICE        =    1        ;; Descriptor type: Device
        DSCR_CONFIG        =    2        ;; Descriptor type: Configuration
        DSCR_STRING        =    3        ;; Descriptor type: String
        DSCR_INTRFC        =    4        ;; Descriptor type: Interface
        DSCR_ENDPNT        =    5        ;; Descriptor type: Endpoint
        DSCR_DEVQUAL       =    6        ;; Descriptor type: Device Qualifier

        DSCR_DEVICE_LEN    =   18
        DSCR_CONFIG_LEN    =    9
        DSCR_INTRFC_LEN    =    9
        DSCR_ENDPNT_LEN    =    7
        DSCR_DEVQUAL_LEN   =   10

        ET_CONTROL         =    0        ;; Endpoint type: Control
        ET_ISO             =    1        ;; Endpoint type: Isochronous
        ET_BULK            =    2        ;; Endpoint type: Bulk
        ET_INT             =    3        ;; Endpoint type: Interrupt

;public       DeviceDscr, DeviceQualDscr, HighSpeedConfigDscr, FullSpeedConfigDscr, StringDscr,UserDscr,vsheader,vsheaderend

;        DSCR   SEGMENT   CODE PAGE

;;-----------------------------------------------------------------------------
;; Global Variables
;;-----------------------------------------------------------------------------
;        rseg DSCR                        ;; locate the descriptor table in on-part memory.

DeviceDscr:

        .db 0x12                         ;  0 bLength 1 Descriptor size in bytes (12h)
        .db 0x01                         ;  1 bDescriptorType 1 The constant DEVICE (01h)
        .db 0x00                         ;  2 bcdUSB 2 USB specification release number (BCD)
        .db 0x02                         ;  2 bcdUSB 2 USB specification release number (BCD)
        .db 0xEF                         ;  4 bDeviceClass 1 Class code
        .db 0x02                         ;  5 bDeviceSubclass 1 Subclass code
        .db 0x01                         ;  6 bDeviceProtocol 1 Protocol Code
        .db 64                           ;  7 bMaxPacketSize0 1 Maximum packet size for endpoint zero
        .dw 0x9AFB                       ;  8 idVendor 2 Vendor ID ; temp vid need to register with usb.org
        .dw 0x9AFB                       ; 10 idProduct 2 Product ID ; temp pid need to changes
        .dw 0x0100                       ; 12 bcdDevice 2 Device release number (BCD)
        .db 0x02                         ; 14 iManufacturer 1 Index of string descriptor for the manufacturer
        .db 0x01                         ; 15 iProduct 1 Index of string descriptor for the product
        .db 0x01                         ; 16 iSerialNumber 1 Index of string descriptor for the serial number
        .db 0x01                         ; 17 bNumConfigurations 1 Number of possible configurations

DeviceQualDscr:

        .db 0x0A                         ; 0 bLength 1 Descriptor size in bytes (0Ah)
        .db 0x06                         ; 1 bDescriptorType 1 The constant DEVICE_QUALIFIER (06h)
        .db 0x00
        .db 0x02                         ; 2 bcdUSB 2 USB specification release number (BCD)
        .db 0xEF                         ; 4 bDeviceClass 1 Class code
        .db 0x02                         ; 5 bDeviceSubclass 1 Subclass code
        .db 0x01                         ; 6 bDeviceProtocol 1 Protocol Code
        .db 0x40                         ; 7 bMaxPacketSize0 1 Maximum packet size for endpoint zero
        .db 0x01                         ; 8 bNumConfigurations 1 Number of possible configurations
        .db 0x00                         ; 9 Reserved 1 For future use

HighSpeedConfigDscr:

        ;;/* Configuration descriptor */
        .db DSCR_CONFIG_LEN              ;; Descriptor length
        .db DSCR_CONFIG                  ;; Descriptor type
        .db <(HighSpeedConfigDscrEnd - HighSpeedConfigDscr) ;; Total Length (LSB)
        .db >(HighSpeedConfigDscrEnd - HighSpeedConfigDscr) ;; Total Length (MSB)
        .db 0x04                         ;/* Number of interfaces */
        .db 0x01                         ;/* Configuration number */
        .db 0x01                         ;/* COnfiguration string index */
        .db 0xA0                         ;/* Config characteristics - bus powered */
        .db 0xFA                         ;/* Max power consumption of device (in 2mA unit) : 500mA */

;;;;;;;;;;;;;;;;; UVC ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;/* Interface association descriptor */
        .db 0x08                         ;/* Descriptor size */
        .db 0x0B                         ;/* Interface association descr type */
        .db 0x00                         ;/* I/f number of first video control i/f */
        .db 0x02                         ;/* Number of video streaming i/f */
        .db 0x0E                         ;/* CC_VIDEO : Video i/f class code */
        .db 0x03                         ;/* SC_VIDEO_INTERFACE_COLLECTION : subclass code */
        .db 0x00                         ;/* Protocol : not used */
        .db 0x01                         ;/* String desc index for interface */

        ;/* Standard video control interface descriptor */
        .db 0x09                         ;/* Descriptor size */
        .db DSCR_INTRFC                  ;/* Interface descriptor type */
        .db 0x00                         ;/* Interface number */
        .db 0x00                         ;/* Alternate setting number */
        .db 0x00                         ;/* Number of end points */
        .db 0x0E                         ;/* CC_VIDEO : Interface class */
        .db 0x01                         ;/* CC_VIDEOCONTROL : Interface sub class */
        .db 0x00                         ;/* Interface protocol code */
        .db 0x00                         ;/* Interface descriptor string index */

        ;/* Class specific VC interface header descriptor */
        .db 0x0D                         ;/* Descriptor size */
        .db 0x24                         ;/* Class Specific I/f header descriptor type */
        .db 0x01                         ;/* Descriptor sub type : VC_HEADER */
        .db 0x00,0x01                    ;/* Revision of class spec : 1.0 */
        .db 0x50,0x00                    ;/* Total size of class specific descriptors (till output terminal) */
        .db 0x00,0x6C,0xDC,0x02          ;/* Clock frequency : 48MHz */
        .db 0x01                         ;/* Number of streaming interfaces */
        .db 0x01                         ;/* Video streaming I/f 1 belongs to VC i/f */

        ;/* Input (camera) terminal descriptor */
        .db 0x12                         ;/* Descriptor size */
        .db 0x24                         ;/* Class specific interface desc type */
        .db 0x02                         ;/* Input Terminal Descriptor type */
        .db 0x01                         ;/* ID of this terminal */
        .db 0x01,0x02                    ;/* Camera terminal type */
        .db 0x00                         ;/* No association terminal */
        .db 0x00                         ;/* String desc index : not used */
        .db 0x00,0x00                    ;/* No optical zoom supported */
        .db 0x00,0x00                    ;/* No optical zoom supported */
        .db 0x00,0x00                    ;/* No optical zoom supported */
        .db 0x03                         ;/* Size of controls field for this terminal : 3 bytes */
        .db 0x00,0x00,0x00               ;/* No controls supported */

        ;/* Processing unit descriptor */
        .db 0x0C                         ;/* Descriptor size */
        .db 0x24                         ;/* Class specific interface desc type */
        .db 0x05                         ;/* Processing unit descriptor type */
        .db 0x02                         ;/* ID of this terminal */
        .db 0x01                         ;/* Source ID : 1 : conencted to input terminal */
        .db 0x00,0x00                    ;/* Digital multiplier */
        .db 0x03                         ;/* Size of controls field for this terminal : 3 bytes */
        .db 0x00,0x00,0x00               ;/* No controls supported */
        .db 0x00                         ;/* String desc index : not used */

        ;/* Extension unit descriptor */
        .db 0x1C                         ;/* Descriptor size */
        .db 0x24                         ;/* Class specific interface desc type */
        .db 0x06                         ;/* Extension unit descriptor type */
        .db 0x03                         ;/* ID of this terminal */
        .db 0xFF,0xFF,0xFF,0xFF          ;/* 16 byte GUID */
        .db 0xFF,0xFF,0xFF,0xFF
        .db 0xFF,0xFF,0xFF,0xFF
        .db 0xFF,0xFF,0xFF,0xFF
        .db 0x00                         ;/* Number of controls in this terminal */
        .db 0x01                         ;/* Number of input pins in this terminal */
        .db 0x02                         ;/* Source ID : 2 : connected to proc unit */
        .db 0x03                         ;/* Size of controls field for this terminal : 3 bytes */
        .db 0x00,0x00,0x00               ;/* No controls supported */
        .db 0x00                         ;/* String desc index : not used */

        ;/* Output terminal descriptor */
        .db 0x09                         ;/* Descriptor size */
        .db 0x24                         ;/* Class specific interface desc type */
        .db 0x03                         ;/* Output terminal descriptor type */
        .db 0x04                         ;/* ID of this terminal */
        .db 0x01,0x01                    ;/* USB Streaming terminal type */
        .db 0x00                         ;/* No association terminal */
        .db 0x03                         ;/* Source ID : 3 : connected to extn unit */
        .db 0x00                         ;/* String desc index : not used */


        ;/* Standard video streaming interface descriptor (alternate setting 0) */
        .db 0x09                         ;/* Descriptor size */
        .db DSCR_INTRFC                  ;/* Interface descriptor type */
        .db 0x01                         ;/* Interface number */
        .db 0x00                         ;/* Alternate setting number */
        .db 0x00                         ;/* Number of end points : zero bandwidth */
        .db 0x0E                         ;/* Interface class : CC_VIDEO */
        .db 0x02                         ;/* Interface sub class : CC_VIDEOSTREAMING */
        .db 0x00                         ;/* Interface protocol code : undefined */
        .db 0x00                         ;/* Interface descriptor string index */

vsheader:
        ;/* Class-specific video streaming input header descriptor */
        .db 0x0F                         ;/* Descriptor size */
        .db 0x24                         ;/* Class-specific VS i/f type */
        .db 0x01                         ;/* Descriptotor subtype : input header */
        .db 0x02                         ;/* 2 format desciptor follows */
        .db <(vsheaderend-vsheader)      ;; Total Length (LSB)
        .db >(vsheaderend-vsheader)      ;; Total Length (MSB)
        .db 0x86                         ;/* EP address for BULK video data */
        .db 0x00                         ;/* No dynamic format change supported */
        .db 0x04                         ;/* Output terminal ID : 4 */
        .db 0x01                         ;/* Still image capture method 1 supported */
        .db 0x01                         ;/* Hardware trigger supported for still image */
        .db 0x00                         ;/* Hardware to initiate still image capture */
        .db 0x01                         ;/* Size of controls field : 1 byte */
        .db 0x00                         ;/* D2 : Compression quality supported */
        .db 0x00                         ;/* D2 : Compression quality supported */

        ;;;;;;;;;;;;;; MJPEG ;;;;;;;;;;;;;

        ;/* Class specific VS format descriptor */
        .db 0x0B                         ;/* Descriptor size */
        .db 0x24                         ;/* Class-specific VS i/f type */
        .db 0x06                         ;/* Descriptotor subtype : VS_FORMAT_MJPEG */
        .db 0x01                         ;/* Format desciptor index */
        .db 0x02                         ;/* 2 Frame desciptor follows */
        .db 0x01                         ;/* Uses fixed size samples */
        .db 0x01                         ;/* Default frame index is 1 */
        .db 0x00                         ;/* Non interlaced stream not reqd. */
        .db 0x00                         ;/* Non interlaced stream not reqd. */
        .db 0x00                         ;/* Non interlaced stream */
        .db 0x00                         ;/* CopyProtect: duplication unrestricted */

        ;/* Class specific VS frame descriptor */       1
        .db 0x1E                         ;/* Descriptor size */
        .db 0x24                         ;/* Class-specific VS I/f Type */
        .db 0x07                         ;/* Descriptotor subtype : VS_FRAME_MJPEG */
        .db 0x01                         ;/* Frame desciptor index */
        .db 0x02                         ;/* Still image capture method not supported */
        .db 0x00,0x04                    ;/* Width of the frame : 1024 */
        .db 0x00,0x03                    ;/* Height of the frame : 768 */
        .db 0x00,0x00,0x00,0x0E          ;/* Min bit rate bits/s */
        .db 0x00,0x00,0x00,0x0E          ;/* max bit rate bits/s */
        .db 0x00,0x00,0x18,0x00          ;/* Maximum video or still frame size in bytes */
        .db 0x2A,0x2C,0x0A,0x00          ;/* Default frame interval */
        .db 0x01                         ;/* Frame interval type : No of discrete intervals */
        .db 0x2A,0x2C,0x0A,0x00          ;/* Frame interval 1 */

        ;/* Class specific VS frame descriptor */       2
        .db 0x1E                         ;/* Descriptor size */
        .db 0x24                         ;/* Class-specific VS I/f Type */
        .db 0x07                         ;/* Descriptotor subtype : VS_FRAME_MJPEG */
        .db 0x02                         ;/* Frame desciptor index */
        .db 0x02                         ;/* Still image capture method not supported */
        .db 0x00,0x05                    ;/* Width of the frame : 1280 */
        .db 0xD0,0x02                    ;/* Height of the frame : 720 */
        .db 0x00,0x00,0x00,0x0E          ;/* Min bit rate bits/s */
        .db 0x00,0x00,0x00,0x0E          ;/* max bit rate bits/s */
        .db 0x00,0x20,0x1C,0x00          ;/* Maximum video or still frame size in bytes */
        .db 0x2A,0x2C,0x0A,0x00          ;/* Default frame interval */
        .db 0x01                         ;/* Frame interval type : No of discrete intervals */
        .db 0x2A,0x2C,0x0A,0x00          ;/* Frame interval 1 */


        ; VS Color Matching Descriptor Descriptor
        .db 0x06                         ; (6 bytes)
        .db 0x24                         ; (Video Streaming Interface)
        .db 0x0D                         ; (Color Matching)
        .db 0x01                         ; (BT.709, sRGB)
        .db 0x01                         ; (BT.709)
        .db 0x04                         ; (SMPTE 170M)


        ;;;;;;;;;;;;;;;;;;;; YUY2 ;;;;;;;;;;;;;;;;;;;;;;;;

        ;/* Class specific VS format descriptor */
        .db 0x1B                         ; /* Descriptor size */
        .db 0x24                         ; /* Class-specific VS I/f Type */
        .db 0x04                         ; /* Subtype : uncompressed format I/F */
        .db 0x02                         ; /* Format desciptor index (only one format is supported) */
        .db 0x02                         ; /* number of frame descriptor followed */
        .db 0x59,0x55,0x59,0x32          ; /* GUID, globally unique identifier used to identify streaming-encoding format: YUY2  */
        .db 0x00,0x00,0x10,0x00
        .db 0x80,0x00,0x00,0xAA
        .db 0x00,0x38,0x9B,0x71
        .db 0x10                         ;/* Number of bits per pixel used to specify color in the decoded video frame. 0 if not applicable: 10 bit per pixel */
        .db 0x01                         ;/* Optimum Frame Index for this stream: 1 */
        .db 0x00                         ;/* X dimension of the picture aspect ratio: Non-interlaced in progressive scan */
        .db 0x00                         ;/* Y dimension of the pictuer aspect ratio: Non-interlaced in progressive scan*/
        .db 0x00                         ;/* Interlace Flags: Progressive scanning, no interlace */
        .db 0x00                         ;/* duplication of the video stream restriction: 0 - no restriction */

        ; Frame descriptors 1
        .db 0x1E                         ;/* Descriptor size */
        .db 0x24                         ;/* Class-specific VS I/f Type */
        .db 0x05                         ;/* Descriptotor subtype uncompressed frame I/F  */
        .db 0x01                         ;/* Frame desciptor index */
        .db 0x02                         ;/* Still image capture method not supported */
        .db 0x00,0x04                    ;/* Width of the frame : 1024 */
        .db 0x00,0x03                    ;/* Height of the frame : 768 */
        .db 0x00,0x00,0x00,0x0E          ;/* Min bit rate bits/s */
        .db 0x00,0x00,0x00,0x0E          ;/* max bit rate bits/s */
        .db 0x00,0x00,0x18,0x00          ;/* Maximum video or still frame size in bytes */
        .db 0x54,0x58,0x14,0x00          ;/* Default frame interval */
        .db 0x01                         ;/* Frame interval type : No of discrete intervals */
        .db 0x54,0x58,0x14,0x00          ;/* Frame interval 3 */


        ; Frame descriptors 2
        .db 0x1E                         ;/* Descriptor size */
        .db 0x24                         ;/* Class-specific VS I/f Type */
        .db 0x05                         ;/* Descriptotor subtype uncompressed frame I/F  */
        .db 0x02                         ;/* Frame desciptor index */
        .db 0x02                         ;/* Still image capture method not supported */
        .db 0x00,0x05                    ;/* Width of the frame : 1280 */
        .db 0xD0,0x02                    ;/* Height of the frame : 720 */
        .db 0x00,0x00,0x00,0x0E          ;/* Min bit rate bits/s */
        .db 0x00,0x00,0x00,0x0E          ;/* max bit rate bits/s */
        .db 0x00,0x20,0x1C,0x00          ;/* Maximum video or still frame size in bytes */
        .db 0x54,0x58,0x14,0x00          ;/* Default frame interval */
        .db 0x01                         ;/* Frame interval type : No of discrete intervals */
        .db 0x54,0x58,0x14,0x00          ;/* Frame interval 3 */

        ; VS Color Matching Descriptor Descriptor
        .db 0x06                         ; (6 bytes)
        .db 0x24                         ; (Video Streaming Interface)
        .db 0x0D                         ; (Color Matching)
        .db 0x01                         ; (BT.709, sRGB)
        .db 0x01                         ; (BT.709)
        .db 0x04                         ; (SMPTE 170M)


vsheaderend:

        ;/* Standard video streaming interface descriptor (alternate setting 1) */
        .db 0x09                         ;/* Descriptor size */
        .db DSCR_INTRFC                  ;/* Interface descriptor type */
        .db 0x01                         ;/* Interface number */
        .db 0x01                         ;/* Alternate setting number */
        .db 0x01                         ;/* Number of end points  */
        .db 0x0E                         ;/* Interface class : CC_VIDEO */
        .db 0x02                         ;/* Interface sub class : CC_VIDEOSTREAMING */
        .db 0x00                         ;/* Interface protocol code : undefined */
        .db 0x00                         ;/* Interface descriptor string index */

        ;/* Endpoint descriptor for streaming video data */
        .db 0x07                         ;/* Descriptor size */
        .db DSCR_ENDPNT                  ;/* Endpoint descriptor type */
        .db 0x86                         ;/* Endpoint address and description */
        .db ET_ISO                       ;/* Bulk Endpoint */
        .db 0x00
        .db 0x04                         ;/* 1024 Bytes Maximum Packet Size. */
        .db 0x01                         ;/* Servicing interval for data transfers */


        ;;;;;;;;;;;;;;;;;;;;;;;;;; CDC ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        .db 0x08                         ; 0 bLength 1 Descriptor size in bytes (08h)
        .db 0x0B                         ; 1 bDescriptorType 1 The constant Interface Association (0Bh)
        .db 0x02                         ; 2 bFirstInterface 1 Number identifying the first interface associated with the function
        .db 0x02                         ; 3 bInterfaceCount 1 The number of contiguous interfaces associated with the function
        .db 0x02                         ; 4 bFunctionClass 1 Class code
        .db 0x00                         ; 5 bFunctionSubClass 1 Subclass code
        .db 0x01                         ; 6 bFunctionProtocol 1 Protocol code
        .db 0x01                         ; 8 iFunction 1 Index of string descriptor for the function

        .db DSCR_INTRFC_LEN              ; Descriptor length
        .db DSCR_INTRFC                  ; Descriptor type
        .db 0x02                         ; Zero-based index of this interface
        .db 0x00                         ; Alternate setting
        .db 0x01                         ; Number of end points
        .db 0x02                         ; Interface class
        .db 0x02                         ; Interface sub class
        .db 0x01                         ; Interface protocol code class
        .db 0x01                         ; Interface descriptor string index

        ;; Header Functional Descriptor
        .db 0x05                         ; Descriptor Size in Bytes (5)
        .db 0x24                         ; CS_Interface
        .db 0x00                         ; Header Functional Descriptor
        .dw 0x1001                       ; bcdCDC

        ;; Union Functional Descriptor
        .db 0x05                         ; Descriptor Size in Bytes (5)
        .db 0x24                         ; CS_Interface
        .db 0x06                         ; Union Functional Descriptor
        .db 0x02                         ; bMasterInterface
        .db 0x03                         ; bSlaveInterface0

        ;; CM Functional Descriptor
        .db 0x05                         ; Descriptor Size in Bytes (5)
        .db 0x24                         ; CS_Interface
        .db 0x01                         ; CM Functional Descriptor
        .db 0x00                         ; bmCapabilities
        ; .db 0x03                         ; bmCapabilities
        .db   0x03                       ; bDataInterface

        ;; ACM Functional Descriptor
        .db 0x04                         ; Descriptor Size in Bytes (5)
        .db 0x24                         ; CS_Interface
        .db 0x02                         ; Abstarct Control Management Functional Desc
        .db 0x02                         ; bmCapabilities
        ; .db 0x07                         ; bmCapabilities

        ;; EP1 Descriptor
        .db DSCR_ENDPNT_LEN              ; Descriptor length
        .db DSCR_ENDPNT                  ; Descriptor type
        .db 0x81                         ; Endpoint number, and direction
        .db ET_INT                       ; Endpoint type
        .db 0x10                         ; Maximum packet size (LSB)
        .db 0x00                         ; Max packet size (MSB)
        .db 0x11                         ; Polling interval


        ;; Virtual COM Port Data Interface Descriptor
        .db DSCR_INTRFC_LEN              ; Descriptor length
        .db DSCR_INTRFC                  ; Descriptor type
        .db 3                            ; Zero-based index of this interface
        .db 0                            ; Alternate setting
        .db 2                            ; Number of end points
        .db 0x0A                         ; Interface class
        .db 0x00                         ; Interface sub class
        .db 0x00                         ; Interface protocol code class
        .db 1                            ; Interface descriptor string index

        ;; EP4 Descriptor
        .db DSCR_ENDPNT_LEN              ; Descriptor length
        .db DSCR_ENDPNT                  ; Descriptor type
        .db 0x84                         ; Endpoint number, and direction
        .db ET_BULK                      ; Endpoint type
        .db 0x00                         ; Maximum packet size (LSB)
        .db 0x02                         ; Max packet size (MSB)
        .db 0x00                         ; Polling interval

        ;; EP2OUT Descriptor
        .db DSCR_ENDPNT_LEN              ; Descriptor length
        .db DSCR_ENDPNT                  ; Descriptor type
        .db 0x02                         ; Endpoint number, and direction
        .db ET_BULK                      ; Endpoint type
        .db 0x00                         ; Maximum packet size (LSB)
        .db 0x02                         ; Max packet size (MSB)
        .db 0x00                         ; Polling interval

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
HighSpeedConfigDscrEnd:

        .db 0x00                         ;; pad

FullSpeedConfigDscr:
FullSpeedConfigDscrEnd:

        .db 0x00                         ;; pad

StringDscr:

StringDscr0:
        .db StringDscr0End-StringDscr0   ;; String descriptor length
        .db DSCR_STRING
        .db 0x09,0x04
StringDscr0End:

StringDscr1:
        .db StringDscr1End-StringDscr1   ;; String descriptor length
        .db DSCR_STRING
        .db 'H',00
        .db 'D',00
        .db 'M',00
        .db 'I',00
        .db '2',00
        .db 'U',00
        .db 'S',00
        .db 'B',00
StringDscr1End:

StringDscr2:
        .db StringDscr2End-StringDscr2   ;; Descriptor length
        .db DSCR_STRING
        .db 'J',00
        .db 'A',00
        .db 'N',00
        .db 'I',00
StringDscr2End:

        .db 0

UserDscr:
        .dw 0x0000
