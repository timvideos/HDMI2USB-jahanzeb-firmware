//-----------------------------------------------------------------------------
//   File:      fw.c
//   Contents:   Firmware frameworks task dispatcher and device request parser
//            source.
//
// indent 3.  NO TABS!
//
//   Copyright (c) 1997 AnchorChips, Inc. All rights reserved
//-----------------------------------------------------------------------------
#include "fx2.h"
#include "fx2regs.h"
#include "fx2sdly.h"
//-----------------------------------------------------------------------------
// Random Macros
//-----------------------------------------------------------------------------
#define   min(a,b) (((a)<(b))?(a):(b))
#define   max(a,b) (((a)>(b))?(a):(b))

#define SET_LINE_CODING (0x20)
#define GET_LINE_CODING (0x21)
#define SET_CONTROL_STATE (0x22)

//-----------------------------------------------------------------------------
// Constants
//-----------------------------------------------------------------------------
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
volatile BOOL   GotSUD;
BOOL      Rwuen;
BOOL      Selfpwr;
volatile BOOL   Sleep;                  // Sleep mode enable flag
int i;
BYTE Len;
BYTE xdata LineCode[7] = {0x60,0x09,0x00,0x00,0x00,0x00,0x08};
//extern void Serial0Init();

WORD   pDeviceDscr;   // Pointer to Device Descriptor; Descriptors may be moved
WORD   pDeviceQualDscr;
WORD   pHighSpeedConfigDscr;
WORD   pFullSpeedConfigDscr;   
WORD   pConfigDscr;
WORD   pOtherConfigDscr;   
WORD   pStringDscr;   

BYTE valuesArray[26]=    
{
	0x00,0x00,                       /* bmHint : No fixed parameters */
    0x01,                            /* Use 1st Video format index */
    0x01,                            /* Use 1st Video frame index */
//    0x2A,0x2C,0x0A,0x00,             /* Desired frame interval in 100ns */
    0x0A,0x8B,0x02,0x00,             /* Desired frame interval in 100ns */ //00 02 8B 0A
    0x00,0x00,                       /* Key frame rate in key frame/video frame units */
    0x00,0x00,                       /* PFrame rate in PFrame / key frame units */
    0x00,0x00,                       /* Compression quality control */
    0x00,0x00,                       /* Window size for average bit rate */
    0xF0,0x00,                       /* Internal video streaming i/f latency in ms */
//    0x00,0x90,0x01,0x00,  //00 01 90 00           /* Max video frame size in bytes (100KB) */
    0x00,0x40,0x06,0x00,    //00 06 40 00       /* Max video frame size in bytes (400KB) */
    0x00,0x02,0x00,0x00              /* No. of bytes device can rx in single payload */
//    0x00,0x00,0xBA,0x6F              /* No. of bytes device can rx in single payload */
};

//-----------------------------------------------------------------------------
// Prototypes
//-----------------------------------------------------------------------------
void SetupCommand(void);
void TD_Init(void);
void TD_Poll(void);
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

//-----------------------------------------------------------------------------
// Code
//-----------------------------------------------------------------------------

// Task dispatcher
void main(void)
{
   DWORD   i;
   WORD   offset;
   DWORD   DevDescrLen;
   DWORD   j=0;
   WORD   IntDescrAddr;
   WORD   ExtDescrAddr;

   // Initialize Global States
   Sleep = FALSE;               // Disable sleep mode
   Rwuen = FALSE;               // Disable remote wakeup
   Selfpwr = FALSE;            // Disable self powered
   GotSUD = FALSE;               // Clear "Got setup data" flag

   // Initialize user device
   TD_Init();

   // The following section of code is used to relocate the descriptor table. 
   // Since the SUDPTRH and SUDPTRL are assigned the address of the descriptor 
   // table, the descriptor table must be located in on-part memory.
   // The 4K demo tools locate all code sections in external memory.
   // The descriptor table is relocated by the frameworks ONLY if it is found 
   // to be located in external memory.
   pDeviceDscr = (WORD)&DeviceDscr;
   pDeviceQualDscr = (WORD)&DeviceQualDscr;
   pHighSpeedConfigDscr = (WORD)&HighSpeedConfigDscr;
   pFullSpeedConfigDscr = (WORD)&FullSpeedConfigDscr;
   pStringDscr = (WORD)&StringDscr;

   if (EZUSB_HIGHSPEED())
   {
      pConfigDscr = pHighSpeedConfigDscr;
      pOtherConfigDscr = pFullSpeedConfigDscr;
   }
   else
   {
      pConfigDscr = pFullSpeedConfigDscr;
      pOtherConfigDscr = pHighSpeedConfigDscr;
   }

   if ((WORD)&DeviceDscr & 0xe000)
   {
      IntDescrAddr = INTERNAL_DSCR_ADDR;
      ExtDescrAddr = (WORD)&DeviceDscr;
      DevDescrLen = (WORD)&UserDscr - (WORD)&DeviceDscr + 2;
      for (i = 0; i < DevDescrLen; i++)
         *((BYTE xdata *)IntDescrAddr+i) = 0xCD;
      for (i = 0; i < DevDescrLen; i++)
         *((BYTE xdata *)IntDescrAddr+i) = *((BYTE xdata *)ExtDescrAddr+i);
      pDeviceDscr = IntDescrAddr;
      offset = (WORD)&DeviceDscr - INTERNAL_DSCR_ADDR;
      pDeviceQualDscr -= offset;
      pConfigDscr -= offset;
      pOtherConfigDscr -= offset;
      pHighSpeedConfigDscr -= offset;
      pFullSpeedConfigDscr -= offset;
      pStringDscr -= offset;
   }

   EZUSB_IRQ_ENABLE();            // Enable USB interrupt (INT2)
   EZUSB_ENABLE_RSMIRQ();            // Wake-up interrupt

   INTSETUP |= (bmAV2EN | bmAV4EN);     // Enable INT 2 & 4 autovectoring

   USBIE |= bmSUDAV | bmSUTOK | bmSUSP | bmURES | bmHSGRANT;   // Enable selected interrupts
   EA = 1;                  // Enable 8051 interrupts

   #ifndef NO_RENUM
   // Note: at full speed, high speed hosts may take 5 sec to detect device
   EZUSB_Discon(TRUE); // Renumerate
   #endif

   CKCON = (CKCON&(~bmSTRETCH)) | FW_STRETCH_VALUE; // Set stretch to 0 (after renumeration)

   // clear the Sleep flag.
   Sleep = FALSE;

   // Task Dispatcher
   while(TRUE)               // Main Loop
   {
      if(GotSUD)            // Wait for SUDAV
      {
         SetupCommand();          // Implement setup command
           GotSUD = FALSE;            // Clear SUDAV flag
      }

      // Poll User Device
      // NOTE: Idle mode stops the processor clock.  There are only two
      // ways out of idle mode, the WAKEUP pin, and detection of the USB
      // resume state on the USB bus.  The timers will stop and the
      // processor will not wake up on any other interrupts.
      if (Sleep)
          {
          if(TD_Suspend())
              { 
              Sleep = FALSE;            // Clear the "go to sleep" flag.  Do it here to prevent any race condition between wakeup and the next sleep.
              do
                  {
                    EZUSB_Susp();         // Place processor in idle mode.
                  }
                while(!Rwuen && EZUSB_EXTWAKEUP());
                // Must continue to go back into suspend if the host has disabled remote wakeup
                // *and* the wakeup was caused by the external wakeup pin.
                
             // 8051 activity will resume here due to USB bus or Wakeup# pin activity.
             EZUSB_Resume();   // If source is the Wakeup# pin, signal the host to Resume.      
             TD_Resume();
              }   
          }
      TD_Poll();
   }
}

// Device request parser
void SetupCommand(void)
{
   void   *dscr_ptr;

   if ((SETUPDAT[0]==UVC_SET_INTERFACE)|(SETUPDAT[0]==UVC_GET_INTERFACE)|(SETUPDAT[0]==UVC_SET_ENDPOINT)|(SETUPDAT[0]==UVC_GET_ENDPOINT))
   {
   //length = 26;//SETUPDAT[7];
	if ((SETUPDAT[1]==GET_CUR)|(SETUPDAT[1]==GET_MIN)|(SETUPDAT[1]==GET_MAX))
	{	
		for (i=0;i<=25;i++)
		EP0BUF[i] = valuesArray[i];
		EP0BCH = 0;
		EP0BCL = 26;//SETUPDAT[7];	
		

	}
	else 
	{
		// if (SETUPDAT[3]==2)
			// IOA = 0xFF;
		
		EP0BCH = 0; // ACK
        EP0BCL = 0; // ACK
	}

  
   }
   else
   switch(SETUPDAT[1])
   {


    	case SET_LINE_CODING:

        	Len = 7;
			EUSB = 0 ;
			SUDPTRCTL = 0x01;
			EP0BCL = 0x00;
            SUDPTRCTL = 0x00;
			EUSB = 1;
			
	        while (EP0BCL != Len);
			SYNCDELAY;
    	    for (i=0;i<Len;i++)
			LineCode[i] = EP0BUF[i];
            //Serial0Init();
		break;


		case GET_LINE_CODING:
            
		    SUDPTRCTL = 0x01;
			Len = 7;
			for (i=0;i<Len;i++)
			EP0BUF[i] = LineCode[i];

			EP0BCH = 0x00;
			SYNCDELAY;
			EP0BCL = Len;
            SYNCDELAY;
			while (EP0CS & 0x02);
            SUDPTRCTL = 0x00;
		break;

       case SET_CONTROL_STATE:
       break;


      case SC_GET_DESCRIPTOR: 
                 // *** Get Descriptor
      SUDPTRCTL = 0x01;
         if(DR_GetDescriptor())
            switch(SETUPDAT[3])         
            {
               case GD_DEVICE:            // Device
                  SUDPTRH = MSB(pDeviceDscr);
                  SUDPTRL = LSB(pDeviceDscr);
                  break;
               case GD_DEVICE_QUALIFIER:            // Device Qualifier
                  SUDPTRH = MSB(pDeviceQualDscr);
                  SUDPTRL = LSB(pDeviceQualDscr);
                  break;
               case GD_CONFIGURATION:         // Configuration
                  SUDPTRH = MSB(pConfigDscr);
                  SUDPTRL = LSB(pConfigDscr);
                  break;
               case GD_OTHER_SPEED_CONFIGURATION:  // Other Speed Configuration
                  // fx2bug - need to support multi other configs
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
// fx2bug                  EP0BUF[0] = EPIO[EPID(SETUPDAT[4])].cntrl & bmEPSTALL;

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
// fx2bug                     EZUSB_UNSTALL_EP( EPID(SETUPDAT[4]) );
// fx2bug                     EZUSB_RESET_DATA_TOGGLE( SETUPDAT[4] );
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
                  else
                     EZUSB_STALL_EP0();   // Stall End Point 0
                  break;
               case FT_ENDPOINT:         // End Point
// fx2bug                  if(SETUPDAT[2] == 0)
// fx2bug                     EZUSB_STALL_EP( EPID(SETUPDAT[4]) );
// fx2bug                  else
                     EZUSB_STALL_EP0();    // Stall End Point 0
                  break;
            }
         break;
      default:                     // *** Invalid Command
         if(DR_VendorCmnd())
            EZUSB_STALL_EP0();            // Stall End Point 0
   }



   // Acknowledge handshake phase of device request
   // Required for rev C does not effect rev B
// TGE fx2bug   EP0CS |= bmBIT1; 
    EP0CS |= bmHSNAK;
}

// Wake-up interrupt handler
void resume_isr(void) interrupt WKUP_VECT
{
   EZUSB_CLEAR_RSMIRQ();
}
