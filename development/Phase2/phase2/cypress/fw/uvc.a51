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
;; Copyright 2003, Cypress Semiconductor Corporation
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
public		CSInterfaceDscr,CSInterfaceDscrEND,CSVSInterfaceDscr,CSVSInterfaceDscrEND

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
;;;;; configuration descriptor (Standard)
db	09H ; 0 bLength 1 Descriptor size in bytes (09h)
db	02H ; 1 bDescriptorType 1 The constant CONFIGURATION (02h)
db  (HighSpeedConfigDscrEnd-HighSpeedConfigDscr) mod 256 ;; Total Length (LSB)
db  (HighSpeedConfigDscrEnd-HighSpeedConfigDscr)  /  256 ;; Total Length (MSB); 2 wTotalLength 2 The number of bytes in the configuration descriptor and all of its subordinate descriptors
db	02H; 4 bNumInterfaces 1 Number of interfaces in the configuration (will be chaneged when CDC is merged in it ) at the moment 2 interfaces 1 control and 1 streaming
db	01H; 5 bConfigurationValue 1 Identifier for Set Configuration and GetConfiguration requests
db	00H; 6 iConfiguration 1 Index of string descriptor for the configuration
db	80H; 7 bmAttributes 1 Self/bus power and remote wakeup settings
db	0FAH; 8 bMaxPower 1 Bus power required in units of 2 mA (USB 2.0) or 8mA (SuperSpeed).

;------------------------------------------

;;;;Interfae association descriptor
db	08H; 0 bLength 1 Descriptor size in bytes (08h)
db	0BH; 1 bDescriptorType 1 The constant Interface Association (0Bh)
db	00H; 2 bFirstInterface 1 Number identifying the first interface associated with the function
db	02H ; 3 bInterfaceCount 1 The number of contiguous interfaces associated with the function 
db	0EH; 4 bFunctionClass 1 Class code
db	03H; 5 bFunctionSubClass 1 Subclass code
db	00H; 6 bFunctionProtocol 1 Protocol code
db	00H; 8 iFunction 1 Index of string descriptor for the function

;------------------------------------------

; The interface descriptor (standerd)
db	09H; 0 bLength 1 Descriptor size in bytes (09h)
db	04H; 1 bDescriptorType 1 The constant Interface (04h)
db	00H; 2 bInterfaceNumber 1 Number identifying this interface
db	00H; 3 bAlternateSetting 1 A number that identifies a descriptor with alternate settings for this bInterfaceNumber.
db	00H; 4 bNumEndpoints 1 Number of endpoints used by this interface (excluding endpoint 0). This number is 0 or 1 depending on whether the optional status interrupt endpoint is present.
db	0EH; 5 bInterfaceClass 1 Class code 
db	01H; 6 bInterfaceSubclass 1 Subclass code
db	01H; 7 bInterfaceProtocol 1 Protocol code
db	00H; 8 iInterface 1 Index of string descriptor for the interface

;------------------------------------------
CSInterfaceDscr:
; calss specific interface descriptor
db  0DH; bLength 	1 	Number 	Size of this descriptor, in bytes: 12+n 
db	24H; bDescriptorType 	1 	Constant 	CS_INTERFACE descriptor type 
db	01H; bDescriptorSubType 	1 	Constant 	VC_HEADER descriptor subtype 
db  05H 
db  01H  ; bcdUVC 	2 	BCD 	Video Device Class Specification release number in binary-coded decimal. (i.e. 2.10 is 210H and 1.50 is 150H) 
db  (CSInterfaceDscrEnd-CSInterfaceDscr) mod 256 ;; Total Length (LSB)
db  (CSInterfaceDscrEnd-CSInterfaceDscr)  /  256 ;; Total Length (MSB);; wTotalLength 	2 	Number 	Total number of bytes returned for the class-specific VideoControl interface descriptor. Includes the combined length of this descriptor header and all Unit and Terminal descriptors. 
db     80H 
db     0C3H 
db     0C9H 
db     01H  ; dwClockFrequency 	4 	Number 	Use of this field has been deprecated. The device clock frequency in Hz. This will specify the units used for the time information fields in the Video 
;Payload Headers of the primary data stream and format.  The dwClockFrequency field of the Video Probe and Commit control replaces this descriptor field. A value for this field shall be chosen such 
;that the primary or default function of the device will be available to host software that implements Version 1.0 of this specification. 
db     01H  ; bInCollection 	1 	Number 	The number of VideoStreaming interfaces in the Video Interface Collection to which this VideoControl interface belongs: n 
db     01H; baInterfaceNr(1) 	1 	Number 	Interface number of the first  VideoStreaming interface in the Collection 


;------------------------------------------

; Input terminal desciptor
db	08H; 0  bLength  1  Number  Size of this descriptor, in bytes: 8 (+ x)
db	24H; 1  bDescriptorType  1  Constant  CS_INTERFACE descriptor type
db	02H; 2  bDescriptorSubtype  1  Constant  VC_INPUT_TERMINAL descriptor subtype
db	01H; 3  bTerminalID  1  Constant  A non-zero constant that uniquely identifies  the Terminal within the video function. This  value is used in all requests to address this  Terminal.
db 	00H
db 	02H; 4  wTerminalType  2  Constant  Constant that characterizes the type of  Terminal. See Appendix B, "Terminal Types".
db	00H; 6  bAssocTerminal  1  Constant  ID of the Output Terminal to which this Input  Terminal is associated, or zero (0) if no such  association exists.
db	00H; 7  iTerminal  1  Index  Index of a string descriptor, describing the Input Terminal.
; …  …  …  …  Depending on the Terminal type, certain Input  Terminal descriptors have additional fields.  The descriptors for these special Terminal  types are described in separate sections  
;specific to those Terminals, and in  accompanying documents.

;------------------------------------------

; output terminal descriptor
db	09H; 0  bLength  1  Number  Size of this descriptor, in bytes: 9 (+ x)
db	24H; 1  bDescriptorType  1  Constant  CS_INTERFACE descriptor type
db	03H; 2  bDescriptorSubtype  1  Constant  VC_OUTPUT_TERMINAL descriptor  subtype
db	02H; 3  bTerminalID  1  Constant  A non-zero constant that uniquely identifies the Terminal within the video function. This value is used in all requests to address this  Terminal.
db	01H
db	01H; 4  wTerminalType  2  Constant  Constant that characterizes the type of Terminal. See Appendix B, "Terminal  Types".
db	00H; 6  bAssocTerminal  1  Constant  Constant, identifying the Input Terminal to  which this Output Terminal is associated, or  zero (0) if no such association exists.
db	01H; 7  bSourceID  1  Constant  ID of the Unit or Terminal to which this Terminal is connected.
db	00H; 8  iTerminal  1  Index  Index of a string descriptor, describing the  Output Terminal.
; …  …  …  …  Depending on the Terminal type, certain  Output Terminal descriptors have additional  fields. The descriptors for these special  Terminal types are described in  accompanying documents.
CSInterfaceDscrEND:


;------------------------------------------
;====================================================
; VS Interface Descriptor (Standard)
db	09H; 0  bLength  1  Number  Size of this descriptor, in bytes: 9
db	04H; 1  bDescriptorType  1  Constant  INTERFACE descriptor type
db	01H; 2  bInterfaceNumber  1  Number  Number of the interface. A zero-based value  identifying the index in the array of concurrent  interfaces supported by this configuration.
db	00H; 3  bAlternateSetting  1  Number  Value used to select this alternate setting for  the interface identified in the prior field.
db	00H; 4  bNumEndpoints  1  Number  Number of endpoints used by this interface  (excluding endpoint 0).
db	0EH; 5  bInterfaceClass  1  Class  CC_VIDEO. Video Interface Class code  (assigned by the USB). See section A.1,  "Video Interface Class Code".
db	02H; 6  bInterfaceSubClass  1  subclass  SC_VIDEOSTREAMING. Video interface  subclass code (assigned by this specification).  See section A.2, "Video Interface Subclass  Codes".
db	1; 7  bInterfaceProtocol  1  Protocol  Must be set to PC_PROTOCOL_15. according to specs should be 1 but every example i looked its value is 0
db	00H; 8  iInterface  1  Index  Index of a string descriptor that describes this  interface.

;------------------------------------------
CSVSInterfaceDscr:
; VS Interface Descriptors (Class-Specific)
db	0EH; 0 bLength 1 Number Size of this descriptor, in bytes: 13+(p*n.
db	24H; 1 bDescriptorType 1 Constant CS_INTERFACE descriptor type
db	01H; 2 bDescriptorSubtype 1 Constant VS_INPUT_HEADER descriptor subtype
db	01H; 3 bNumFormats 1 Number Number of video payload Format descriptors following for this interface (excluding video Frame descriptors): p
db  (CSVSInterfaceDscrEnd-CSVSInterfaceDscr) mod 256 ;; Total Length (LSB)
db  (CSVSInterfaceDscrEnd-CSVSInterfaceDscr)  /  256 ;; Total Length (MSB); 4 wTotalLength 2 Number Total number of bytes returned for the class-specific VideoStreaming interface descriptors including this header descriptor.
db	82H; 6 bEndpointAddress 1 Endpoint The address of the isochronous or bulk endpoint used for video data. The address is encoded as follows: D7: Direction 1 = IN endpoint D6..4: Reserved, set to zero. D3..0: The endpoint number, determined by the designer. (endpoint 2)
db	00H; 7 bmInfo 1 Bitmap Indicates the capabilities of this VideoStreaming interface: D0: Dynamic Format Change supported D7..1: Reserved, set to zero.
db	02H; 8 bTerminalLink 1 Constant The terminal ID of the Output Terminal to which the video endpoint of this interface is connected.
db	00H; 9 bStillCaptureMethod 1 Number Method of still image capture supported as described in section 2.4.2.4, "Still Image Capture": 0: None (Host software will not support any form of still image capture) 1: Method 1 2: Method 2 3: Method 3
db	00H; 10 bTriggerSupport 1 Number Specifies if hardware triggering is supported through this interface 0: Not supported 1: Supported
db	00H; 11 bTriggerUsage 1 Number Specifies how the host software shall respond to a hardware trigger interrupt event from this interface. This is ignored if the bTriggerSupport field is zero. 0: 
;Initiate still image capture 1: General purpose button event. Host driver will notify client application of button press and button release events
db	01H; 12  bControlSize  1  Number  Size of each bmaControls(x) field, in  bytes: n
db	00H; 13  bmaControls(1)  n  Bitmap  For bits D3..0, a bit set to 1 indicates that  the named field is supported by the Video  Probe and Commit Control when  bFormatIndex is 1: D0: wKeyFrameRate 
;D1: wPFrameRate D2: wCompQuality D3: wCompWindowSize For bits D5..4, a bit set to 1 indicates that  the named control is supported by the  device when bFormatIndex is 1: D4: Generate Key Frame D5: 
;Update Frame Segment D6..(n*8-1): Reserved, set to zero *Note* going forward from version 1.5 the  proper means to detect whether a field is  supported by Probe & Commit is to issue a  
;VS_PROBE_CONTROL(GET_CUR).
; :
; :
; :
; 13+(p*n-n) bmaControls(p)  n  Bitmap  For bits D3..0, a bit set to 1 indicates that  the named field is supported by the Video  Probe and Commit Control when bFormatIndex is p: D0: wKeyFrameRate 
;D1: wPFrameRate D2: wCompQuality D3: wCompWindowSize For bits D5..4, a bit set to 1 indicates that  the named control is supported by the  device when bFormatIndex is p: D4: Generate Key Frame D5: 
;Update Frame Segment D6..(n*8-1): Reserved, set to zero *Note* D0-D3 are deprecated. Going  forward from version 1.5 the proper means  to detect whether a field is supported by  Probe & Commit is 
;to issue a  VS_PROBE_CONTROL(GET_CUR).

;-------------------------------

; Motion-JPEG Video Format Descriptor
db	0BH; 0  bLength  1  Number  Size of this Descriptor, in bytes: 11
db	24H; 1  bDescriptorType  1  Constant  CS_INTERFACE Descriptor type.
db	06H; 2  bDescriptorSubtype  1  Constant  VS_FORMAT_MJPEG Descriptor  subtype
db	01H; 3  bFormatIndex  1  Number  Index of this Format Descriptor
db	01H; 4  bNumFrameDescriptors  1  Number  Number of Frame Descriptors  following that correspond to this format
db	01H; 5  bmFlags  1  Number  Specifies characteristics of this format D0: FixedSizeSamples. 1 = Yes All other bits are reserved for future  use and shall be reset to zero.
db	01H; 6  bDefaultFrameIndex  1  Number  Optimum Frame Index (used to select  resolution) for this stream
db	00H; 7  bAspectRatioX  1  Number  The X dimension of the picture aspect  ratio.
db	00H; 8  bAspectRatioY  1  Number  The Y dimension of the picture aspect  ratio.
db	00H; 9  bmInterlaceFlags  1  Bitmap  Specifies interlace information. If the  scanning mode control in the Camera  Terminal is supported for this stream, this field should reflect the field 
;format  used in interlaced mode. (Top field in PAL is field 1, top field in  NTSC is field 2.): D0: Interlaced stream or variable. 1 =Yes D1: Fields per frame. 0= 2 fields, 1 = 1  field D2: Field 1 
;first. 1 = Yes D3: Reserved D5..4: Field pattern 00 = Field 1 only  01 = Field 2 only 10 = Regular pattern of fields 1 and 2 11 = Random pattern of fields 1 and 2 D7..6: Reserved. Do not use.
db	00H; 10  bCopyProtect  1  Boolean  Specifies if duplication of the video  stream should be restricted: 0: No restrictions 1: Restrict duplication


CSVSInterfaceDscrEND:
;-------------------------------

; Motion-JPEG Video Frame Descriptor
db	26H;0  bLength  1  Number  Size of this descriptor in bytes when  bFrameIntervalType is 0: 38 Size of this descriptor in bytes when  bFrameIntervalType > 0: 26+(4*n)
db	24H; 1  bDescriptorType  1  Constant  CS_INTERFACE Descriptor type
db	07H; 2  bDescriptorSubtype  1  Constant  VS_FRAME_MJPEG Descriptor  subtype
db	01H; 3  bFrameIndex  1  Number  Index of this Frame Descriptor
db	02H; 4  bmCapabilities  1  Number  D0: Still image supported Specifies whether still images are  supported at this frame setting. This is only applicable for VS interfaces with  an IN video 
;endpoint using Still  Image Capture Method 1, and should  be set to 0 in all other cases. D1: Fixed frame-rate Specifies whether the device provides  a fixed frame rate on a stream  associated with 
;this frame descriptor.  Set to 1 if fixed rate is enabled;  otherwise, set to 0. D7..2: Reserved, set to 0.
db	0B0H
db	00H; 5  wWidth  2  Number  Width of decoded bitmap frame in  pixels (176)

db	90H
db	00H; 7  wHeight  2  Number  Height of decoded bitmap frame in  pixels (144)

db	00H
db	0ECH
db	0DH
db	00H; 9  dwMinBitRate  4  Number  Specifies the minimum bit rate at  default compression quality and longest frame interval in Units of bps at which the data can be transmitted.

db	00H
db	0ECH
db	0DH
db	00H; 13  dwMaxBitRate  4  Number  Specifies the maximum bit rate at  default compression quality and shortest frame interval in Units of bps at which the data can be transmitted.

db	80H
db	94H
db	00H
db	00H; 17  dwMaxVideoFrameBufferSize 4  Number  Use of this field has been deprecated.Specifies the maximum number of bytes for a video (or still image) frame the compressor will produce.  The 
;dwMaxVideoFrameSize field of the Video Probe and Commit control  replaces this descriptor field. A value for this field shall be chosen for  compatibility with host software that implements an 
;earlier version of this specification.

db	2AH
db	2CH
db	0AH
db	00H; 21  dwDefaultFrameInterval  4  Number  Specifies the frame interval the device would like to indicate for use as a default. This must be a valid frame interval described in the fields below.

db	00H; 25  bFrameIntervalType  1  Number  Indicates how the frame interval can be programmed: 0: Continuous frame interval 1..255: The number of discrete frameintervals supported (n) ( i am using 
;descrete frameinterval )

db	2AH
db	2CH
db	0AH
db	00H; 21  dwFrameInterval

db	2AH
db	2CH
db	0AH
db	00H

db	00H
db	00H
db	00H
db	00H

;-----------------------

; Color Matching Descriptor

db	06H; 0  bLength  1  Constant  6
db	24H; 1  bDescriptorType  1  Number  CS_INTERFACE type
db	0DH; 2  bDescriptorSubtype  1  Number  VS_COLORFORMAT
db	00H; 3  bColorPrimaries  1  Number  This defines the color primaries  and the reference white. 0: Unspecified (Image characteristics unknown) 1: BT.709, sRGB (default) 2: BT.470-2 (M) 3: 
;BT.470-2 (B, G) 4: SMPTE 170M 5: SMPTE 240M 6-255: Reserved
db	00H; 4  bTransferCharacteristics  1  Number  This field defines the opto-electronic transfer characteristic of  the source picture also called the  gamma function. 0: Unspecified (Image  
;characteristics unknown)  1: BT.709 (default) 2: BT.470-2 M 3: BT.470-2 B, G 4: SMPTE 170M 5: SMPTE 240M 6: Linear (V = Lc) 7: sRGB (very similar to BT.709) 8-255: Reserved
db	00H; 5  bMatrixCoefficients  1  Number  Matrix used to compute luma and  chroma values from the color  primaries. 0: Unspecified (Image  characteristics unknown) 1: BT. 709 2: FCC 3: BT.470-2 B, 
;G 4: SMPTE 170M (BT.601,  default) 5: SMPTE 240M 6-255: Reserved

;;=====================
; VS Interface Descriptor (Standard)
db	09H; 0  bLength  1  Number  Size of this descriptor, in bytes: 9
db	04H; 1  bDescriptorType  1  Constant  INTERFACE descriptor type
db	01H; 2  bInterfaceNumber  1  Number  Number of the interface. A zero-based value  identifying the index in the array of concurrent  interfaces supported by this configuration.
db	01H; 3  bAlternateSetting  1  Number  Value used to select this alternate setting for  the interface identified in the prior field.
db	01H; 4  bNumEndpoints  1  Number  Number of endpoints used by this interface  (excluding endpoint 0).
db	0EH; 5  bInterfaceClass  1  Class  CC_VIDEO. Video Interface Class code  (assigned by the USB). See section A.1,  "Video Interface Class Code".
db	02H; 6  bInterfaceSubClass  1  subclass  SC_VIDEOSTREAMING. Video interface  subclass code (assigned by this specification).  See section A.2, "Video Interface Subclass  Codes".
db	01H; 7  bInterfaceProtocol  1  Protocol  Must be set to PC_PROTOCOL_15.
db	00H; 8  iInterface  1  Index  Index of a string descriptor that describes this  interface.


;;=====================




;------------------------

; endpoint descriptor (BULK)
db	07H; 0  bLength  1  Number  Size of this descriptor, in bytes: 7
db	DSCR_ENDPNT; 1  bDescriptorType  1  Constant  ENDPOINT descriptor type
db	88H; 2  bEndpointAddress  1  Endpoint  The address of the endpoint on the USB device described by this descriptor. The  address is encoded as follows: D7: Direction 0 = OUT endpoint 1 = IN 
;endpoint D6..4: Reserved, reset to zero D3..0: The endpoint number, determined by  the designer
db	ET_BULK; 3  bmAttributes  1  Bitmap  D1..0: Transfer type (set to 10 = Bulk) All other bits are reserved.

db	00H;
db	02H; 4  wMaxPacketSize  2  Number  Maximum packet size this endpoint is  capable of sending or receiving when this  configuration is selected. (512 at the moment)

db	01H; 6  bInterval  1  Number  Interval for polling endpoint for data  transfers. For high-speed bulk OUT endpoints, the  bInterval must specify the maximum NAK  rate of the endpoint. A value of 
;0 indicates  the endpoint never NAKs. Other values  indicate at most 1 NAK each bInterval number of microframes. This value must be in the range from 0 to 255.



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
      
