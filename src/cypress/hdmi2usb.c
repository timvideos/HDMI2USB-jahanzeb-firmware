#pragma NOIV               // Do not generate interrupt vectors
//-----------------------------------------------------------------------------
//   File:      bulkloop.c
//   Contents:   Hooks required to implement USB peripheral function.
//
//   Copyright (c) 2000 Cypress Semiconductor All rights reserved
//-----------------------------------------------------------------------------
#include "fx2.h"
#include "fx2regs.h"
#include "fx2sdly.h"			// SYNCDELAY macro


extern BOOL   GotSUD;         // Received setup data flag
extern BOOL   Sleep;
extern BOOL   Rwuen;
extern BOOL   Selfpwr;
extern BYTE valuesArray[26];

BYTE   Configuration;      // Current configuration
BYTE   AlternateSetting = 0;   // Alternate settings

void TD_Poll(void);


//-----------------------------------------------------------------------------
// Task Dispatcher hooks
//   The following hooks are called by the task dispatcher.
//-----------------------------------------------------------------------------
BOOL DR_SetConfiguration();

void TD_Init(void)             // Called once at startup
{
	// Return FIFO setings back to default just in case previous firmware messed with them.
	SYNCDELAY; PINFLAGSAB   = 0x00;
	SYNCDELAY; PINFLAGSCD   = 0x00;
	SYNCDELAY; FIFOPINPOLAR = 0x00;
	
	// Global settings
	//SYNCDELAY; REVCTL = 0x03;
	SYNCDELAY; CPUCS  = ((CPUCS & ~bmCLKSPD) | bmCLKSPD1);  // 48MHz
	SYNCDELAY; IFCONFIG = 0xE3; //1110 0011 
	
	// EP1OUT & EP1IN
	SYNCDELAY; EP1OUTCFG = 0x00;
	SYNCDELAY; EP1INCFG  = 0xA0;
	
	// VALID DIR TYPE1 TYPE0 SIZE 0 BUF1 BUF0
	SYNCDELAY; EP2CFG = 0xA2;
	SYNCDELAY; EP4CFG = 0xE2;
	SYNCDELAY; EP6CFG = 0xDA;//1101 1010
	SYNCDELAY; EP8CFG = 0x00;
	
	// 0 INFM1 OEP1 AUTOOUT AUTOIN ZEROLENIN 0 WORDWIDE
	SYNCDELAY; EP2FIFOCFG = 0x10;  // Auto
	SYNCDELAY; EP4FIFOCFG = 0x0C;
	SYNCDELAY; EP6FIFOCFG = 0x0C;
	SYNCDELAY; EP8FIFOCFG = 0x00;
	
	SYNCDELAY; EP4AUTOINLENH = 0x02;
	SYNCDELAY; EP4AUTOINLENL = 0x00;
	SYNCDELAY; EP6AUTOINLENH = 0x04;
	SYNCDELAY; EP6AUTOINLENL = 0x00;
	
	SYNCDELAY; REVCTL = 0x03; // REVCTL.0 and REVCTL.1 set to 1
	SYNCDELAY; FIFORESET = 0x80; // Reset the FIFO
	SYNCDELAY; FIFORESET = 0x82;
	SYNCDELAY; FIFORESET = 0x84;
	SYNCDELAY; FIFORESET = 0x86;
	SYNCDELAY; FIFORESET = 0x00;


}

void TD_Poll(void)             // Called repeatedly while the device is idle
{

/*
if (!(EP1INCS & 0x02))      // check if EP1IN is available
  {
	EP1INBUF[0] = 0x0A;       // if it is available, then fill the first 10 bytes of the buffer with 
	EP1INBUF[1] = 0x20;       // appropriate data. 
	EP1INBUF[2] = 0x00;
	EP1INBUF[3] = 0x00;
	EP1INBUF[4] = 0x00;
	EP1INBUF[5] = 0x00;
	EP1INBUF[6] = 0x00;
	EP1INBUF[7] = 0x02;
	EP1INBUF[8] = 0x00;
	EP1INBUF[9] = 0x00;
	EP1INBC = 10;            // manually commit once the buffer is filled
  }
*/

}

BOOL TD_Suspend(void)          // Called before the device goes into suspend mode
{
   return(TRUE);
}

BOOL TD_Resume(void)          // Called after the device resumes
{
   return(TRUE);
}

//-----------------------------------------------------------------------------
// Device Request hooks
//   The following hooks are called by the end point 0 device request parser.
//-----------------------------------------------------------------------------

BOOL DR_GetDescriptor(void)
{
   return(TRUE);
}

BOOL DR_SetConfiguration(void)   // Called when a Set Configuration command is received
{  

   Configuration = SETUPDAT[2];
   return(TRUE);            // Handled by user code
}

BOOL DR_GetConfiguration(void)   // Called when a Get Configuration command is received
{
   EP0BUF[0] = Configuration;
   EP0BCH = 0;
   EP0BCL = 1;
   return(TRUE);            // Handled by user code
}

BOOL DR_SetInterface(void)       // Called when a Set Interface command is received
{
   AlternateSetting = SETUPDAT[2];
	
	
	if (AlternateSetting == 1)
	{	
		//while ( !(EP2468STAT & bmEP2EMPTY) );  // Wait while FIFO remains "not empty" (i.e while busy)
		SYNCDELAY; EP2FIFOCFG = 0x00;          // Disable AUTOOUT
		SYNCDELAY; FIFORESET = bmNAKALL;       // NAK all OUT packets from host
		SYNCDELAY; FIFORESET = 2;              // Advance EP2 buffers to CPU domain			

		SYNCDELAY; 
		EP2FIFOBUF[0] = 'U';			
		EP2FIFOBUF[1] = 'F';
		EP2FIFOBUF[2] = 'U';		
		EP2FIFOBUF[3] = 'V';	
		EP2FIFOBUF[4] = 'U';		
		
		if (valuesArray[2] == 1) // Formate MJPEG 
		{
			EP2FIFOBUF[5] = 'J';		
		} else { // Formate RAW 
			EP2FIFOBUF[5] = 'R';				
		}
		
		EP2FIFOBUF[6] = 'U';	
		
		if (valuesArray[3] == 1) // Frame DVI // not implemented bz Atlys doesnot support the HPD
		{
			EP2FIFOBUF[7] = 'D';
		} else { // Frame HDMI
		
			EP2FIFOBUF[7] = 'H';
		}
		
		
		// turn on USB
		EP2FIFOBUF[8] = 'U';		
		EP2FIFOBUF[9] = 'N';	
		
		SYNCDELAY; EP2BCH = 0;
		SYNCDELAY; EP2BCL = 10;
		
		SYNCDELAY; OUTPKTEND = 0x82;     // Skip uncommitted second packet
		SYNCDELAY; FIFORESET = 0;              // Release "NAK all"
		SYNCDELAY; EP2FIFOCFG = 0x10;  // Auto	

		// reset UVC fifo
		SYNCDELAY; FIFORESET = 0x80;
		SYNCDELAY; FIFORESET = 0x06;
		SYNCDELAY; FIFORESET = 0x00;
	}

   return(TRUE);            // Handled by user code
}

BOOL DR_GetInterface(void)       // Called when a Set Interface command is received
{
   EP0BUF[0] = AlternateSetting;
   EP0BCH = 0;
   EP0BCL = 1;
   return(TRUE);            // Handled by user code
}

BOOL DR_GetStatus(void)
{
   return(TRUE);
}

BOOL DR_ClearFeature(void)
{
   return(TRUE);
}

BOOL DR_SetFeature(void)
{
   return(TRUE);
}

BOOL DR_VendorCmnd(void)
{
   return(TRUE);
}

//-----------------------------------------------------------------------------
// USB Interrupt Handlers
//   The following functions are called by the USB interrupt jump table.
//-----------------------------------------------------------------------------

// Setup Data Available Interrupt Handler


void ISR_Sudav(void) interrupt 0
{
   
   GotSUD = TRUE;            // Set flag
   EZUSB_IRQ_CLEAR();
   USBIRQ = bmSUDAV;         // Clear SUDAV IRQ
}

// Setup Token Interrupt Handler
void ISR_Sutok(void) interrupt 0
{
   EZUSB_IRQ_CLEAR();
   USBIRQ = bmSUTOK;         // Clear SUTOK IRQ
}

void ISR_Sof(void) interrupt 0
{
   EZUSB_IRQ_CLEAR();
   USBIRQ = bmSOF;            // Clear SOF IRQ
}

void ISR_Ures(void) interrupt 0
{
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
   
   EZUSB_IRQ_CLEAR();
   USBIRQ = bmURES;         // Clear URES IRQ
}

void ISR_Susp(void) interrupt 0
{
    Sleep = TRUE;
   EZUSB_IRQ_CLEAR();
   USBIRQ = bmSUSP;
  
}

void ISR_Highspeed(void) interrupt 0
{
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

   EZUSB_IRQ_CLEAR();
   USBIRQ = bmHSGRANT;
}

void ISR_Ep0ack(void) interrupt 0
{
}
void ISR_Stub(void) interrupt 0
{
}
void ISR_Ep0in(void) interrupt 0
{
}
void ISR_Ep0out(void) interrupt 0
{
}
void ISR_Ep1in(void) interrupt 0
{
}
void ISR_Ep1out(void) interrupt 0// Places first byte of EP1 OUT buffer in SBUF0
{


}
void ISR_Ep2inout(void) interrupt 0
{
}
void ISR_Ep4inout(void) interrupt 0
{

}
void ISR_Ep6inout(void) interrupt 0
{
}
void ISR_Ep8inout(void) interrupt 0
{
}
void ISR_Ibn(void) interrupt 0
{
}
void ISR_Ep0pingnak(void) interrupt 0
{
}
void ISR_Ep1pingnak(void) interrupt 0
{
}
void ISR_Ep2pingnak(void) interrupt 0
{
}
void ISR_Ep4pingnak(void) interrupt 0
{
}
void ISR_Ep6pingnak(void) interrupt 0
{
}
void ISR_Ep8pingnak(void) interrupt 0
{
}
void ISR_Errorlimit(void) interrupt 0
{
}
void ISR_Ep2piderror(void) interrupt 0
{
}
void ISR_Ep4piderror(void) interrupt 0
{
}
void ISR_Ep6piderror(void) interrupt 0
{
}
void ISR_Ep8piderror(void) interrupt 0
{
}
void ISR_Ep2pflag(void) interrupt 0
{
}
void ISR_Ep4pflag(void) interrupt 0
{
}
void ISR_Ep6pflag(void) interrupt 0
{
}
void ISR_Ep8pflag(void) interrupt 0
{
}
void ISR_Ep2eflag(void) interrupt 0
{
}
void ISR_Ep4eflag(void) interrupt 0
{
}
void ISR_Ep6eflag(void) interrupt 0
{
}
void ISR_Ep8eflag(void) interrupt 0
{
}
void ISR_Ep2fflag(void) interrupt 0
{
}
void ISR_Ep4fflag(void) interrupt 0
{
}
void ISR_Ep6fflag(void) interrupt 0
{
}
void ISR_Ep8fflag(void) interrupt 0
{
}
void ISR_GpifComplete(void) interrupt 0
{
}
void ISR_GpifWaveform(void) interrupt 0
{
}
