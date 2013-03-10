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

// BYTE valuesArray[26]=    
// {
	// 0x00,0x00,                       /* bmHint : No fixed parameters */
    // 0x01,                            /* Use 1st Video format index */
    // 0x01,                            /* Use 1st Video frame index */
    // 0x2A,0x2C,0x0A,0x00,             /* Desired frame interval in 100ns */
    // 0x00,0x00,                       /* Key frame rate in key frame/video frame units */
    // 0x01,0x00,                       /* PFrame rate in PFrame / key frame units */
    // 0x00,0x00,                       /* Compression quality control */
    // 0x00,0x00,                       /* Window size for average bit rate */
    // 0x00,0x00,                       /* Internal video streaming i/f latency in ms */
    // 0x00,0x80,0x0C,0x00,    //00 0C 80 00       /* Max video frame size in bytes (800KB) */
    // 0x00,0x02,0x00,0x00              /* No. of bytes device can rx in single payload (512) */

// };
BYTE valuesArray[26]=    
{
	0x01,0x00,                       /* bmHint : No fixed parameters */
    0x01,                            /* Use 1st Video format index */
    0x01,                            /* Use 1st Video frame index */
    0x2A,0x2C,0x0A,0x00,             /* Desired frame interval in 100ns */
	
    0x01,0x00,                       /* Key frame rate in key frame/video frame units */
    0x01,0x00,                       /* PFrame rate in PFrame / key frame units */
    0x00,0x00,                       /* Compression quality control */
    0xf0,0x00,                       /* Window size for average bit rate */
	
    0x02,0x00,                       /* Internal video streaming i/f latency in ms */
    // 0x00,0x00,0x48,0x00,   			/* Max video frame size in bytes*/
    0x00,0x00,0x90,0x00,   			/* Max video frame size in bytes*/
	
    0x00,0x02,0x00,0x00              /* No. of bytes device can rx in single payload (512) */

};
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


   // Initialize Global States
   Sleep = FALSE;               // Disable sleep mode
   Rwuen = FALSE;               // Disable remote wakeup
   Selfpwr = FALSE;            // Disable self powered
   GotSUD = FALSE;               // Clear "Got setup data" flag

   

   //==========================================================

EP2CFG = 0xA2;                //out 512 bytes, 2x, bulk
SYNCDELAY; 
EP6CFG = 0xE2;                // in 512 bytes, 2x, bulk
//EP6CFG = 0xD2;                // in 512 bytes, 2x, iso (11 01 00 10)


SYNCDELAY;         
EP4CFG = 0xE2;                // in 512 bytes, 2x, bulk
SYNCDELAY;                     
EP8CFG = 0x02;                //clear valid bit
SYNCDELAY;   

IFCONFIG = 0xE3; //1110 0011 
SYNCDELAY;

FIFOPINPOLAR = 0x00;
SYNCDELAY;
PINFLAGSAB = 0x00;			// FLAGA - EP6FF
SYNCDELAY;
PINFLAGSCD = 0x00;			// FLAGD - EP2EF
SYNCDELAY;
PORTACFG |= 0x80; // port A configuration reg
SYNCDELAY;

SYNCDELAY;
FIFORESET = 0x80;             // activate NAK-ALL to avoid race conditions
SYNCDELAY;                    // see TRM section 15.14
FIFORESET = 0x02;             // reset, FIFO 2
SYNCDELAY;                    // 
FIFORESET = 0x04;             // reset, FIFO 4
SYNCDELAY;                    // 
FIFORESET = 0x06;             // reset, FIFO 6
SYNCDELAY;                    // 
FIFORESET = 0x08;             // reset, FIFO 8
SYNCDELAY;                    // 
FIFORESET = 0x00;             // deactivate NAK-ALL

SYNCDELAY;                    // 
EP2FIFOCFG = 0x10;            // AUTOOUT=1, WORDWIDE=0
SYNCDELAY;                    // 
EP4FIFOCFG = 0x0C;            // AUTOIN=1, ZEROLENIN=1, WORDWIDE=0
SYNCDELAY;  

EP6FIFOCFG = 0x0C;            // AUTOIN=1, ZEROLENIN=1, WORDWIDE=0
SYNCDELAY;
EP8FIFOCFG = 0x00; // disabled
SYNCDELAY;


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
	// PORTACFG = 0x00; // 
	// SYNCDELAY;

	// OEA = 0xFF;
	// IOA = 0x00; 
	
	
	// OED = 0xFF;
	// IOD = 0x00;
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
   length = 26;//SETUPDAT[7];
	if ((SETUPDAT[1]==GET_CUR)|(SETUPDAT[1]==GET_MIN)|(SETUPDAT[1]==GET_MAX))
	{	
		for (i=0;i<length-1;i++)
		EP0BUF[i] = valuesArray[i];
		EP0BCH = 0;
		EP0BCL = length;//SETUPDAT[7];	
		

	}
	else 
	{
		// for (i=0;i<length;i++)
		// valuesArray[i]=EP0BUF[i];
			
		EP0BCH = 0; // ACK
        EP0BCL = 0; // ACK 
		
		SYNCDELAY;
		FIFORESET = 0x80;             // activate NAK-ALL to avoid race conditions
		SYNCDELAY;                    // see TRM section 15.14
		FIFORESET = 0x02;             // reset, FIFO 2
		SYNCDELAY;                    // 
		FIFORESET = 0x04;             // reset, FIFO 4
		SYNCDELAY;                    // 
		FIFORESET = 0x06;             // reset, FIFO 6
		SYNCDELAY;                    // 
		FIFORESET = 0x08;             // reset, FIFO 8
		SYNCDELAY;                    // 
		FIFORESET = 0x00;             // deactivate NAK-ALL
		SYNCDELAY;
        

	}

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


