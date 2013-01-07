//-----------------------------------------------------------------------------
//   File:      fw.c
//   Contents:  Firmware frameworks task dispatcher and device request parser
//
// $Archive: /USB/Examples/FX2LP/bulkext/fw.c $
// $Date: 3/23/05 2:53p $
// $Revision: 8 $
//
//
//-----------------------------------------------------------------------------
// Copyright 2003, Cypress Semiconductor Corporation
//-----------------------------------------------------------------------------
#include "fx2.h"
#include "fx2regs.h"
//#include "syncdly.h"            // SYNCDELAY macro

//-----------------------------------------------------------------------------
// Constants
//-----------------------------------------------------------------------------
#define DELAY_COUNT   0x9248*8L  // Delay for 8 sec at 24Mhz, 4 sec at 48
#define _IFREQ  24000            // IFCLK constant for Synchronization Delay
#define _CFREQ  24000            // CLKOUT constant for Synchronization Delay
//#define	_SCYCL	1


//-----------------------------------------------------------------------------
// Random Macros
//-----------------------------------------------------------------------------
#define   min(a,b) (((a)<(b))?(a):(b))
#define   max(a,b) (((a)>(b))?(a):(b))

#include "fx2sdly.h"
//----------------------------------------------------------------------------
//	UVC definations
//----------------------------------------------------------------------------
#define 	UVC_SET_INTERFACE		0x21	// SET_Interface : UVC
#define 	UVC_GET_INTERFACE		0xA1	// GET_Interface : UVC

#define 	UVC_SET_ENDPOINT		0x22	// SET_ENDPOINT : UVC
#define 	UVC_GET_ENDPOINT		0xA2	// GET_ENDPOINT : UVC


#define RC_UNDEFINED  	0x00
#define SET_CUR  		0x01
#define SET_CUR_ALL 	0x11
#define GET_CUR  		0x81 // 1
#define GET_MIN  		0x82 //
#define GET_MAX  		0x83 // 2
#define GET_RES  		0x84
#define GET_LEN  		0x85
#define GET_INFO  		0x86
#define GET_DEF			0x87
#define GET_CUR_ALL  	0x91
#define GET_MIN_ALL  	0x92
#define GET_MAX_ALL  	0x93
#define GET_RES_ALL  	0x94
#define GET_DEF_ALL  	0x97


//-----------------------------------------------------------------------------
// Global Variables
//-----------------------------------------------------------------------------
volatile  BOOL   GotSUD;
BOOL      Rwuen;
BOOL      Selfpwr;
volatile BOOL   Sleep;                  // Sleep mode enable flag

WORD   pDeviceDscr;   // Pointer to Device Descriptor; Descriptors may be moved
WORD   pDeviceQualDscr;
WORD   pHighSpeedConfigDscr;
WORD   pFullSpeedConfigDscr;   
WORD   pConfigDscr;
WORD   pOtherConfigDscr;   
WORD   pStringDscr;   
WORD   pUserDscr;   
WORD   pVSUserDscr;   

BYTE valuesArray[48];

//-----------------------------------------------------------------------------
// Prototypes
//-----------------------------------------------------------------------------
void SetupCommand(void);
//void TD_Init(void);
//void TD_Poll(void);
BOOL TD_Suspend(void);
BOOL TD_Resume(void);

BOOL DR_GetDescriptor(void);
BOOL DR_SetConfiguration(void);
BOOL DR_GetConfiguration(void);
BOOL DR_SetInterface(void);
BOOL DR_GetInterface(void);
BOOL DR_GetStatus(void);
BOOL DR_ClearFeature(void);
BOOL DR_SetFeature(void);
BOOL DR_VendorCmnd(void);

// this table is used by the epcs macro 
const char code  EPCS_Offset_Lookup_Table[] =
{
   0,    // EP1OUT
   1,    // EP1IN
   2,    // EP2OUT
   2,    // EP2IN
   3,    // EP4OUT
   3,    // EP4IN
   4,    // EP6OUT
   4,    // EP6IN
   5,    // EP8OUT
   5,    // EP8IN
};

// macro for generating the address of an endpoint's control and status register (EPnCS)
#define epcs(EP) (EPCS_Offset_Lookup_Table[(EP & 0x7E) | (EP > 128)] + 0xE6A1)

//-----------------------------------------------------------------------------
// Code
//-----------------------------------------------------------------------------
// unsigned char code LEDSegTabel[] = 
// {
    // 0x44, 0xf5, 0x1c, 0x94, 0xa5,
	// 0x86, 0x06, 0xf4, 0x04, 0x84, 
	// 0x24, 0x07, 0x4e, 0x15, 0x0e, 0x2e};
#define SHRCLK 4
#define LATCLK 5
#define SDI    6
// void CY_IOInit(void)
// {
    // OEA = 0x0f;
	// IOA = 0x0f;
// }

void DelayMs(void)
{
   unsigned long t = 40000;
   while(t--);
}
/*
void DispLeds(unsigned short value)
{
    unsigned char Bitcnt = 16;
	
	IOE &= ~(1 << LATCLK);
	for (Bitcnt = 0; Bitcnt < 16; Bitcnt++)
	{
	    IOE &= ~(1 << SHRCLK);
		(value&0x8000)?(IOE |= (1 << SDI)):(IOE &= ~(1 << SDI));
		IOE |= (1 << SHRCLK);
		value <<= 1;
	}
	IOE |= (1 << LATCLK);
}
*/
unsigned short xdata ExtMem[0x4000] _at_ 0x4000;
void ExtMemTest(void)
{
	unsigned short counter = 0;

    for (;counter < 0x4000; counter++)
	{
	    ExtMem[counter] = counter;
	}
	counter = 0;
	for (;counter < 0x4000; counter++)
	{
		if (counter != ExtMem[counter])
		{
		    while(1)
			{
				IOB ^= 0XFF;
				DelayMs();
			}
		}
	}
}
//[YourCompany]%DeviceDesc%=CyLoad, USB\VID_04B4&PID_0084
// Task dispatcher
void main(void)
{
//   DWORD   i;
//   WORD   offset;
//   DWORD   DevDescrLen;
   DWORD   j=0;
//   WORD   IntDescrAddr;
//   WORD   ExtDescrAddr;


valuesArray[0] = 0; //db	00H
valuesArray[1] = 0;// db	00H ;bmHint 	

valuesArray[2] = 1;// db	01H ;bFormatIndex
valuesArray[3] = 1;// db	01H ;bFrameIndex

valuesArray[4] = 0x2A;// db	2AH
valuesArray[5] = 0x2c;// db	2CH
valuesArray[6] = 0x0A;// db	0AH
valuesArray[7] = 0;// db	00H; dwFrameInterval

valuesArray[8] = 0;// db	00H 
valuesArray[9] = 0;// db	00H ; wKeyFrameRate

valuesArray[10] = 0;// db	00H
valuesArray[11] = 0;// db	00H ; wPFrameRate

valuesArray[12] = 0x3D;// db	01H
valuesArray[13] = 0;// db	00H ; wCompQuality

valuesArray[14] = 0;// db	16
valuesArray[15] = 0;// db	00H ;wCompWindowSize

valuesArray[16] = 0;// db	50
valuesArray[17] = 0;// db	00H ;wDelay

valuesArray[18] = 0;//0x80;// db	80H //00
valuesArray[19] = 0x60;//0x94;// db	94H //60H
valuesArray[20] = 0x09;//0;// db	00H  //09H
valuesArray[21] = 0;// db	00H; //00 17  dwMaxVideoFrameBufferSize 4  Number  Use of this field has been deprecated.Specifies the maximum number of bytes for a video (or still image) frame the compressor will produce.  The 
// ;dwMaxVideoFrameSize field of the Video Probe and Commit control  replaces this descriptor field. A value for this field shall be chosen for  compatibility with host software that implements an 
// ;earlier version of this specification.

valuesArray[22] = 0x0;//0;// db	00H //f4
valuesArray[23] = 0x0;//;// db	02H //0B ; 
valuesArray[24] = 0;// db	00H
valuesArray[25] = 0;// db	00H ;dwMaxPayloadTransferSize

// // ; 2 DC 6C 00 48Mhz
valuesArray[26] = 0;// db	00H
valuesArray[27] = 0x6C;// db	6CH
valuesArray[28] = 0xDC;// db	0DCH
valuesArray[29] = 2;// db	02H ; dwClockFrequency

valuesArray[30] = 0;// db 00H ; bmFramingInfo

valuesArray[31] = 2;// db	2 ; bPreferedVersion
valuesArray[32] = 0;// db	0 ; bMinVersion
valuesArray[33] = 0;// db	0 ; bMaxVersion
valuesArray[34] = 1;// db	1; bUsage
valuesArray[35] = 8;// db	8;bBitDepthLuma
valuesArray[36] = 0;// db	0; bmSettings
valuesArray[37] = 1;// db	1; bMaxNumberOfRefFramesPlus1
valuesArray[38] = 0;// db	0;
valuesArray[39] = 0;// db	0;bmRateControlModes

valuesArray[40] = 0;// db	0
valuesArray[41] = 0;// db	0
valuesArray[42] = 0;// db	0
valuesArray[43] = 0;// db	0
valuesArray[44] = 0;// db	0
valuesArray[45] = 0;// db	0
valuesArray[46] = 0;// db	0
valuesArray[47] = 0;// db	0; bmLayoutPerStream



   // Initialize Global States
   Sleep = FALSE;               // Disable sleep mode
   Rwuen = FALSE;               // Disable remote wakeup
   Selfpwr = FALSE;            // Disable self powered
   GotSUD = FALSE;               // Clear "Got setup data" flag

   

   //==========================================================
	IFCONFIG = 0xE3; //1111 0011; // use IFCLK pin driven by internal logic (5MHz to 48MHz)
	// use slave FIFO interface pins driven sync by external master
	// inverted clock IFCONFIG.4
	SYNCDELAY;
	REVCTL = 0x03; // (i am confused about this reg OUTPKTEND and INPKTEND need to test which configuaration works)
	SYNCDELAY;
	INPKTEND = 0; //
	SYNCDELAY;
	OUTPKTEND = 0;
	SYNCDELAY;
	
	FIFOPINPOLAR = 0x3F; // set all slave FIFO interface pins as active high 
	SYNCDELAY;	
		
	
	EP2CFG = 0xA2; // Out/bulk/512/double // 1010 0010
	SYNCDELAY;
	EP4CFG = 0xE2; // In/bulk/512/double // 1110 0010
	SYNCDELAY;
	EP6CFG = 0xE2; // In/bulk/512/double // 1110 0010
	SYNCDELAY;
	EP8CFG = 0x00; // Disable
	SYNCDELAY;
	EP1OUTCFG = 0;       // Disable
	SYNCDELAY;
	EP1INCFG = 0;        // Disable
	SYNCDELAY;	
	
	// ============================================================================
	

	
	EP2FIFOCFG = 0x0E; //0000 1110 AUTOOUT=1, AUTOIN=1, ZEROLEN=1, WORDWIDE=0
	EP4FIFOCFG = 0x0E; //0000 1110 
	EP6FIFOCFG = 0x0E; //0000 1110 

	
	//===============================================================================
	EP2AUTOINLENH = 0x02; // EZ-USB automatically commits data in 512-byte chunks
	SYNCDELAY;
	EP2AUTOINLENL = 0x00;
	SYNCDELAY;
	
	EP4AUTOINLENH = 0x02; // EZ-USB automatically commits data in 512-byte chunks
	SYNCDELAY;
	EP4AUTOINLENL = 0x00;
	SYNCDELAY;
	
	EP6AUTOINLENH = 0x02; // EZ-USB automatically commits data in 512-byte chunks
	SYNCDELAY;
	EP6AUTOINLENL = 0x00;
	SYNCDELAY;
	
	
	//==============================================================================
	// ==== no programble flags
	// EP2FIFOPFH = 0x80; 
	// SYNCDELAY; // 
	// EP2FIFOPFL = 0x00;	
	// SYNCDELAY; // 

	// EP4FIFOPFH = 0x80; 
	// SYNCDELAY; // 
	// EP4FIFOPFL = 0x00;	
	// SYNCDELAY; // 

	// EP6FIFOPFH = 0x80; 
	// SYNCDELAY; // 
	// EP6FIFOPFL = 0x00;	
	// SYNCDELAY; // 
	
	//===============================================================================
	// Flag FLAGA=PF, FLAGB=FF, FLAGC=EF, FLAGD=EP2PF (Actual FIFO is selected by FIFOADR[0,1] pins)
	PINFLAGSAB = 0x00; 
	SYNCDELAY; // 
	
	PINFLAGSCD = 0x00; // 
	SYNCDELAY;

	//============================================================================
	FIFORESET = 0x80; // reset all FIFOs
	SYNCDELAY;
	FIFORESET = 0x82;
	SYNCDELAY;
	FIFORESET = 0x84;
	SYNCDELAY;
	FIFORESET = 0x86;
	SYNCDELAY;
	FIFORESET = 0x88;
	SYNCDELAY;
	FIFORESET = 0x00;
	SYNCDELAY; // this defines the external interface to be the following:


	//==============================================================================
	PORTACFG = 0x00; // 
	SYNCDELAY;

	OEA = 0xFF;
	IOA = 0x00; 
   //==========================================================

   
   // Initialize user device
   // TD_Init();
	// CY_IOInit();
   // The following section of code is used to relocate the descriptor table. 
   // The frameworks uses SUDPTRH and SUDPTRL to automate the SETUP requests
   // for descriptors.  These registers only work with memory locations
   // in the EZ-USB internal RAM.  Therefore, if the descriptors are located
   // in external RAM, they must be copied to in internal RAM.  
   // The descriptor table is relocated by the frameworks ONLY if it is found 
   // to be located in external memory.
   pDeviceDscr = (WORD)&DeviceDscr;
   pDeviceQualDscr = (WORD)&DeviceQualDscr;
   pHighSpeedConfigDscr = (WORD)&HighSpeedConfigDscr;
   pFullSpeedConfigDscr = (WORD)&FullSpeedConfigDscr;
   pStringDscr = (WORD)&StringDscr;
   pUserDscr = (WORD)&UserDscr;
   //pVSUserDscr = (WORD) & VSUserDscr;



   // Is the descriptor table in external RAM (> 16Kbytes)?  If yes,
   // then relocate.
   // Note that this code only checks if the descriptors START in 
   // external RAM.  It will not work if the descriptor table spans
   // internal and external RAM.
/*   if ((WORD)&DeviceDscr & 0xC000)
   {
      // first, relocate the descriptors
      IntDescrAddr = INTERNAL_DSCR_ADDR;
      ExtDescrAddr = (WORD)&DeviceDscr;
      DevDescrLen = (WORD)&UserDscr - (WORD)&DeviceDscr + 2;
      for (i = 0; i < DevDescrLen; i++)
         *((BYTE xdata *)IntDescrAddr+i) = *((BYTE xdata *)ExtDescrAddr+i);

      // update all of the descriptor pointers
      pDeviceDscr = IntDescrAddr;
      offset = (WORD)&DeviceDscr - INTERNAL_DSCR_ADDR;
      pDeviceQualDscr -= offset;
      pConfigDscr -= offset;
      pOtherConfigDscr -= offset;
      pHighSpeedConfigDscr -= offset;
      pFullSpeedConfigDscr -= offset;
      pStringDscr -= offset;
   }
*/
   EZUSB_IRQ_ENABLE();            // Enable USB interrupt (INT2)
   EZUSB_ENABLE_RSMIRQ();            // Wake-up interrupt

   INTSETUP |= (bmAV2EN | bmAV4EN);     // Enable INT 2 & 4 autovectoring

   USBIE |= bmSUDAV | bmSUTOK | bmSUSP | bmURES | bmHSGRANT;   // Enable selected interrupts
   EA = 1;                  // Enable 8051 interrupts
#ifndef NO_RENUM
   // Renumerate if necessary.  Do this by checking the renum bit.  If it
   // is already set, there is no need to renumerate.  The renum bit will
   // already be set if this firmware was loaded from an eeprom.
   if(!(USBCS & bmRENUM))
   {
       EZUSB_Discon(TRUE);   // renumerate
   }
#endif

   // unconditionally re-connect.  If we loaded from eeprom we are
   // disconnected and need to connect.  If we just renumerated this
   // is not necessary but doesn't hurt anything
   USBCS &=~bmDISCON;

   CKCON = (CKCON&(~bmSTRETCH)) | FW_STRETCH_VALUE; // Set stretch

   // clear the Sleep flag.
   Sleep = FALSE;
   GotSUD = FALSE;          // Clear SETUP flag

   // Task Dispatcher
   while(TRUE)               // Main Loop
   {
      // Poll User Device
      //TD_Poll();
      // Check for pending SETUP
      if(GotSUD)
      {
         SetupCommand();          // Implement setup command
         GotSUD = FALSE;          // Clear SETUP flag
      }

      // check for and handle suspend.
      // NOTE: Idle mode stops the processor clock.  There are only two
      // ways out of idle mode, the WAKEUP pin, and detection of the USB
      // resume state on the USB bus.  The timers will stop and the
      // processor will not wake up on any other interrupts.
      if (Sleep)
      {
         if(TD_Suspend())
         { 
            Sleep = FALSE;     // Clear the "go to sleep" flag.  Do it here to prevent any race condition between wakeup and the next sleep.
            do
            {
               EZUSB_Susp();         // Place processor in idle mode.
            }
            while(!Rwuen && EZUSB_EXTWAKEUP());
            // above.  Must continue to go back into suspend if the host has disabled remote wakeup
            // *and* the wakeup was caused by the external wakeup pin.

            // 8051 activity will resume here due to USB bus or Wakeup# pin activity.
            EZUSB_Resume();   // If source is the Wakeup# pin, signal the host to Resume.      
            TD_Resume();
         }   
      }

   }
}

BOOL HighSpeedCapable()
{
   // this function determines if the chip is high-speed capable.
   // FX2 and FX2LP are high-speed capable. FX1 is not - it does
   // not have a high-speed transceiver.

   if (GPCR2 & bmFULLSPEEDONLY)
      return FALSE;
   else
      return TRUE;
}   

// Device request parser
void SetupCommand(void)
{
   void   *dscr_ptr;
   BYTE    i,length;

   if ((SETUPDAT[0]==UVC_SET_INTERFACE)|(SETUPDAT[0]==UVC_GET_INTERFACE)|(SETUPDAT[0]==UVC_SET_ENDPOINT)|(SETUPDAT[0]==UVC_GET_ENDPOINT))
   {
   length = 0x1A;//SETUPDAT[7];
	if ((SETUPDAT[1]==GET_CUR)|(SETUPDAT[1]==GET_MIN)|(SETUPDAT[1]==GET_MAX))
	{	
		for (i=0;i<length;i++)
		EP0BUF[i] = valuesArray[i];
		EP0BCH = 0;
		EP0BCL = length;//SETUPDAT[7];	
		

	}
	else if ((SETUPDAT[1]==SET_CUR)|(SETUPDAT[1]==GET_INFO))
	{
		for (i=0;i<length;i++)
		valuesArray[i]=EP0BUF[i];
		
		EP0BUF[0] = 0;
		EP0BUF[1] = 0;
		EP0BCH = 0;
		EP0BCL = 2;		
	}
	else
	EZUSB_STALL_EP0();
		// IOA = 0xFF; 
   
   }
   else
   switch(SETUPDAT[1])
   {
	  
      case SC_GET_DESCRIPTOR:                  // *** Get Descriptor
         if(DR_GetDescriptor())
            switch(SETUPDAT[3])         
            {
               case GD_DEVICE:            // Device
			   IOA = 0x00;
                  SUDPTRH = MSB(pDeviceDscr);
                  SUDPTRL = LSB(pDeviceDscr);
                  break;
               case GD_DEVICE_QUALIFIER:            // Device Qualifier
			   	  // only retuen a device qualifier if this is a high speed
				  // capable chip.
			   	  if (HighSpeedCapable())
				  {
	                  SUDPTRH = MSB(pDeviceQualDscr);
	                  SUDPTRL = LSB(pDeviceQualDscr);
				  }
				  else
				  {
					  EZUSB_STALL_EP0();
				  }
				  break;
               case GD_CONFIGURATION:         // Configuration
                  SUDPTRH = MSB(pConfigDscr);
                  SUDPTRL = LSB(pConfigDscr);
                  break;
               case GD_OTHER_SPEED_CONFIGURATION:  // Other Speed Configuration
                  SUDPTRH = MSB(pOtherConfigDscr);
                  SUDPTRL = LSB(pOtherConfigDscr);
                  break;
               case GD_STRING:            // String
                  if(dscr_ptr = (void *)EZUSB_GetStringDscr(SETUPDAT[2]))
                  {
                     SUDPTRH = MSB(dscr_ptr);
                     SUDPTRL = LSB(dscr_ptr);
                  }
                  else 
                     EZUSB_STALL_EP0();   // Stall End Point 0
                  break;
               default:            // Invalid request
                  EZUSB_STALL_EP0();      // Stall End Point 0
            }
         break;
      case SC_GET_INTERFACE:                  // *** Get Interface
         DR_GetInterface();
         break;
      case SC_SET_INTERFACE:                  // *** Set Interface
         DR_SetInterface();
         break;
      case SC_SET_CONFIGURATION:               // *** Set Configuration
         DR_SetConfiguration();
         break;
      case SC_GET_CONFIGURATION:               // *** Get Configuration
         DR_GetConfiguration();
         break;
      case SC_GET_STATUS:                  // *** Get Status
         if(DR_GetStatus())
            switch(SETUPDAT[0])
            {
               case GS_DEVICE:            // Device
                  EP0BUF[0] = ((BYTE)Rwuen << 1) | (BYTE)Selfpwr;
                  EP0BUF[1] = 0;
                  EP0BCH = 0;
                  EP0BCL = 2;
                  break;
               case GS_INTERFACE:         // Interface
                  EP0BUF[0] = 0;
                  EP0BUF[1] = 0;
                  EP0BCH = 0;
                  EP0BCL = 2;
                  break;
               case GS_ENDPOINT:         // End Point
                  EP0BUF[0] = *(BYTE xdata *) epcs(SETUPDAT[4]) & bmEPSTALL;
                  EP0BUF[1] = 0;
                  EP0BCH = 0;
                  EP0BCL = 2;
                  break;
               default:            // Invalid Command
                  EZUSB_STALL_EP0();      // Stall End Point 0
            }
         break;
      case SC_CLEAR_FEATURE:                  // *** Clear Feature
         if(DR_ClearFeature())
            switch(SETUPDAT[0])
            {
               case FT_DEVICE:            // Device
                  if(SETUPDAT[2] == 1)
                     Rwuen = FALSE;       // Disable Remote Wakeup
                  else
                     EZUSB_STALL_EP0();   // Stall End Point 0
                  break;
               case FT_ENDPOINT:         // End Point
                  if(SETUPDAT[2] == 0)
                  {
                     *(BYTE xdata *) epcs(SETUPDAT[4]) &= ~bmEPSTALL;
                     EZUSB_RESET_DATA_TOGGLE( SETUPDAT[4] );
                  }
                  else
                     EZUSB_STALL_EP0();   // Stall End Point 0
                  break;
            }
         break;
      case SC_SET_FEATURE:                  // *** Set Feature
         if(DR_SetFeature())
            switch(SETUPDAT[0])
            {
               case FT_DEVICE:            // Device
                  if(SETUPDAT[2] == 1)
                     Rwuen = TRUE;      // Enable Remote Wakeup
                  else if(SETUPDAT[2] == 2)
                     // Set Feature Test Mode.  The core handles this request.  However, it is
                     // necessary for the firmware to complete the handshake phase of the
                     // control transfer before the chip will enter test mode.  It is also
                     // necessary for FX2 to be physically disconnected (D+ and D-)
                     // from the host before it will enter test mode.
                     break;
                  else
                     EZUSB_STALL_EP0();   // Stall End Point 0
                  break;
               case FT_ENDPOINT:         // End Point
                  *(BYTE xdata *) epcs(SETUPDAT[4]) |= bmEPSTALL;
                  break;
               default:
                  EZUSB_STALL_EP0();      // Stall End Point 0
            }
         break;
      default:                     // *** Invalid Command
         if(DR_VendorCmnd())
            EZUSB_STALL_EP0();            // Stall End Point 0
   }

   // Acknowledge handshake phase of device request
   EP0CS |= bmHSNAK;
}

// Wake-up interrupt handler
void resume_isr(void) interrupt WKUP_VECT
{
   EZUSB_CLEAR_RSMIRQ();
}


