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

extern BYTE xdata LineCode[7] ;

BYTE   Configuration;      // Current configuration
BYTE   AlternateSetting;   // Alternate settings

void display_product(void);
void TD_Poll(void);


//-----------------------------------------------------------------------------
// Task Dispatcher hooks
//   The following hooks are called by the task dispatcher.
//-----------------------------------------------------------------------------
BOOL DR_SetConfiguration();

   
   // BYTE TxByte0,RxByte0;
   // BYTE TxByte1,RxByte1;

 
// BYTE  ReadByteS0 (void)   // Copy the recieved Byte from SBUF to the variable RxByte0
// {
    
         // RI = 0;           // with reg320 syntax but same address

	 // RxByte0 = SBUF0;   //RxByte;

	 // return RxByte0;

// }

// void WriteByteS0(char ch)  // Send the data recieved from USB through SBUF0
// {   
   	
	// while (TI == 0) ;
	// TI = 0 ;
	// SBUF0 = ch ;
	
// }


// void  Serial0Init () // serial UART 0 with Timer 2 in mode 1 or high speed baud rate generator
// {
	        
    	    // UART230 &= 0x03;

		// if ((LineCode[0] == 0x60) && (LineCode[1] == 0x09 ))	  // 2400

		// {
    		// SCON0  = 0x5A;		    //	Set Serial Mode = 1, Recieve enable bit = 1
			// T2CON  = 0x34;		    //	Int1 is detected on falling edge, Enable Timer0, Set Timer overflow Flag
			// RCAP2H = 0xFD;	     	//  Set TH2 value for timer2 
			// RCAP2L = 0x90;  		//	baud rate is set to 2400 baud
			// TH2    = RCAP2H;		//  Upper 8 bit of 16 bit counter to FF
			// TL2    = RCAP2L;		//  value of the lower 8 bits of timer set to baud rate

		// }
   // else if ((LineCode[0] == 0xC0) && (LineCode[1] == 0x12 ))	  // 4800

		// {
    		// SCON0  = 0x5A;		    //	Set Serial Mode = 1, Recieve enable bit = 1
			// T2CON  = 0x34;		    //	Int1 is detected on falling edge, Enable Timer0, Set Timer overflow Flag
			// RCAP2H = 0xFE;	     	//  Set TH2 value for timer2 
			// RCAP2L = 0xC8;  		//	baud rate is set to 4800 baud
			// TH2    = RCAP2H;		//  Upper 8 bit of 16 bit counter to FF
			// TL2    = RCAP2L;		//  value of the lower 8 bits of timer set to baud rate

		// }
		// else if ((LineCode[0] == 0x80) && (LineCode[1] == 0x25 ))	  // 9600

		// {
    		// SCON0  = 0x5A;		    //	Set Serial Mode = 1, Recieve enable bit = 1
			// T2CON  = 0x34;		    //	Int1 is detected on falling edge, Enable Timer0, Set Timer overflow Flag
			// RCAP2H = 0xFF;	     	//  Set TH2 value for timer2 
			// RCAP2L = 0x64;  		//	baud rate is set to 9600 baud
			// TH2    = RCAP2H;		//  Upper 8 bit of 16 bit counter to FF
			// TL2    = RCAP2L;		//  value of the lower 8 bits of timer set to baud rate

		// }
		// else if ((LineCode[0] == 0x00) && (LineCode[1] == 0x4B ))	  // 19200

		// {
    		// SCON0  = 0x5A;		    //	Set Serial Mode = 1, Recieve enable bit = 1
			// T2CON  = 0x34;		    //	Int1 is detected on falling edge, Enable Timer0, Set Timer overflow Flag
			// RCAP2H = 0xFF;	     	//  Set TH2 value for timer2 
			// RCAP2L = 0xB2;  		//	baud rate is set to 19200 baud
			// TH2    = RCAP2H;		//  Upper 8 bit of 16 bit counter to FF
			// TL2    = RCAP2L;		//  value of the lower 8 bits of timer set to baud rate

		// }
		// else if ((LineCode[0] == 0x80) && (LineCode[1] == 0x70 ))	  // 28800

		// {
    		// SCON0  = 0x5A;		    //	Set Serial Mode = 1, Recieve enable bit = 1
			// T2CON  = 0x34;		    //	Int1 is detected on falling edge, Enable Timer0, Set Timer overflow Flag
			// RCAP2H = 0xFF;	     	//  Set TH2 value for timer2 
			// RCAP2L = 0xCC;  		//	baud rate is set to 28800 baud
			// TH2    = RCAP2H;		//  Upper 8 bit of 16 bit counter to FF
			// TL2    = RCAP2L;		//  value of the lower 8 bits of timer set to baud rate

		// }
		// else if ((LineCode[0] == 0x00) && (LineCode[1] == 0x96 ))	  // 38400

		// {
    		// SCON0  = 0x5A;		    //	Set Serial Mode = 1, Recieve enable bit = 1
			// T2CON  = 0x34;		    //	Int1 is detected on falling edge, Enable Timer0, Set Timer overflow Flag
			// RCAP2H = 0xFF;	     	//  Set TH2 value for timer2 
			// RCAP2L = 0xD9;  		//	baud rate is set to 38400 baud
			// TH2    = RCAP2H;		//  Upper 8 bit of 16 bit counter to FF
			// TL2    = RCAP2L;		//  value of the lower 8 bits of timer set to baud rate

		// }
		// else if ((LineCode[0] == 0x00) && (LineCode[1] == 0xE1 ))	  // 57600

		// {
    		// SCON0  = 0x5A;		    //	Set Serial Mode = 1, Recieve enable bit = 1
			// T2CON  = 0x34;		    //	Int1 is detected on falling edge, Enable Timer0, Set Timer overflow Flag
			// RCAP2H = 0xFF;	     	//  Set TH2 value for timer2 
			// RCAP2L = 0xE6;  		//	baud rate is set to 57600 baud
			// TH2    = RCAP2H;		//  Upper 8 bit of 16 bit counter to FF
			// TL2    = RCAP2L;		//  value of the lower 8 bits of timer set to baud rate

		// }
	
       // else if ((LineCode[0] == 0x00) && (LineCode[1] == 0x84 ))	  // 230400 
		// {
		     // PCON |= 0X80;
    	    // UART230 |= 0x03;
		    
		// }
			// else //if ((LineCode[0] == 0x21) && (LineCode[1] == 0x20 ))	  // 115200 (LineCode[0] == 0x00) && (LineCode[1] == 0xC2 ))

		// {

		   // SCON0  = 0x5A;		    //	Set Serial Mode = 1, Recieve enable bit = 1
			// T2CON  = 0x34;	
		   // RCAP2L = 0xF3; 
           // RCAP2H = 0xFF; 
		   // TH2    = RCAP2H;		//  Upper 8 bit of 16 bit counter to FF
			// TL2    = RCAP2L;		//  value of the lower 8 bits of timer set to baud rate*/


		    
		// }
       

// }




void TD_Init(void)             // Called once at startup
{
   
   //==========================================================

EP2CFG = 0xA2;                //out 512 bytes, 2x, bulk
SYNCDELAY; 
//EP6CFG = 0xE2;                // in 512 bytes, 2x, bulk
EP6CFG = 0xD2;                // in 512 bytes, 2x, iso 1101  
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
//  EP6FIFOCFG = 0x4C;            //INFM1=1 AUTOIN=1, ZEROLENIN=1, WORDWIDE=0
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
// PA.3	UVC(not FIFO)	M8
//	WAKEUPCS &= 0xFD;
//	OEA |= 0x08;
// IOA = IOA & 0x0F7; //1111 0111
//	IOA |= 0x08; //1111 0111


// OED = 0xFF;
// IOD = 0xFF; 
//==========================================================   


}

void TD_Poll(void)             // Called repeatedly while the device is idle
{
  
  // Serial State Notification that has to be sent periodically to the host

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

//// recieving the data from the USB Host and send it out through UART

  // if (!(EP1OUTCS & 0x02)) // Check if EP1OUT is available

  // { 
	// int bcl,i;
	// bcl=EP1OUTBC;
	// for(i=0;i<bcl;i++)
    	// WriteByteS0(EP1OUTBUF[i]);
  	// EP1OUTBC = 0x04;
  // }

//// recieve the data from UART and send it out to the USB Host

  // if((EP2468STAT & bmEP8EMPTY))   // check if EP8 is empty
  // { 
   
   	 // if (RI)
	 // {
	 	 // EP8FIFOBUF [0] = ReadByteS0();
		 // EP8BCH = 0;    
                 // SYNCDELAY;   
                 // EP8BCL = 1; 
                 // SYNCDELAY;   
    
	 // }
  
  // }

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
		// if (AlternateSetting == 1)
			// IOA = 0xFF;
		// else 
			// IOA = 0x00;
   
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
void ISR_Ep1out(void) interrupt 0
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
