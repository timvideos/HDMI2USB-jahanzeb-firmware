
#include "uvc.h"

#include <fx2regs.h>
#include <fx2macros.h>
#include <setupdat.h>
#include <eputils.h>
#include <delay.h>
#define SYNCDELAY SYNCDELAY4


BYTE valuesArray[26]=
{
    0x01,0x00,                       /* bmHint : No fixed parameters */
    0x01,                            /* Use 1st Video format index */
    0x01,                            /* Use 1st Video frame index */
    0x2A,0x2C,0x0A,0x00,             /* Desired frame interval in 100ns */

    0x00,0x00,                       /* Key frame rate in key frame/video frame units */
    0x00,0x00,                       /* PFrame rate in PFrame / key frame units */
    0x00,0x00,                       /* Compression quality control */
    0x00,0x00,                       /* Window size for average bit rate */

    0x05,0x00,                       /* Internal video streaming i/f latency in ms */

    0x00,0x20,0x1C,0x00,            /* Max video frame size in bytes*/
    0x00,0x04,0x00,0x00              /* No. of bytes device can rx in single payload (1024) */
};

BYTE fps[2][4] = {{0x2A,0x2C,0x0A,0x00},{0x54,0x58,0x14,0x00}}; // 15 ,7
BYTE frameSize[2][4] = {{0x00,0x00,0x18,0x00},{0x00,0x20,0x1C,0x00}};// Dvi , HDMI

BOOL handleUVCCommand(BYTE cmd) {
    int i;

    switch(cmd) {

    case CLEAR_FEATURE:                  // *** Clear Feature
        // FIXME: WTF is 0x21 !?
        if (SETUPDAT[0] != 0x21)
		    return FALSE;

        EP0BCH = 0;
        EP0BCL = 26;
        SYNCDELAY;
        while(EP0CS & bmEPBUSY);
        while (EP0BCL != 26);

        valuesArray[2] = EP0BUF[2]; // formate
        valuesArray[3] = EP0BUF[3];        // frame

        // fps
        valuesArray[4] = fps[EP0BUF[2]-1][0];
        valuesArray[5] = fps[EP0BUF[2]-1][1];
        valuesArray[6] = fps[EP0BUF[2]-1][2];
        valuesArray[7] = fps[EP0BUF[2]-1][3];

        valuesArray[18] = frameSize[EP0BUF[3]-1][0];
        valuesArray[19] = frameSize[EP0BUF[3]-1][1];
        valuesArray[20] = frameSize[EP0BUF[3]-1][2];
        valuesArray[21] = frameSize[EP0BUF[3]-1][3];

        EP0BCH = 0; // ACK
        EP0BCL = 0; // ACK
		return TRUE;

    case UVC_GET_CUR:
    case UVC_GET_MIN:
    case UVC_GET_MAX:
        SUDPTRCTL = 0x01;
        for (i=0;i<26;i++)
            EP0BUF[i] = valuesArray[i];
        EP0BCH = 0x00;
        SYNCDELAY;
        EP0BCL = 26;
        return TRUE;

    // FIXME: What do these do????
    // case UVC_SET_CUR:
    // case UVC_GET_RES:
    // case UVC_GET_LEN:
    // case UVC_GET_INFO:

    // case UVC_GET_DEF:
    // FIXME: Missing this case causes the following errors
    // uvcvideo: UVC non compliance - GET_DEF(PROBE) not supported. Enabling workaround.
    // Unhandled Vendor Command: 87

    default:
        return FALSE;
    }
}

// --------------------
// From hdmi2usb.c
//static BYTE   Configuration;      // Current configuration
//static BYTE   AlternateSetting = 0;   // Alternate settings
BYTE   Configuration;      // Current configuration
BYTE   AlternateSetting = 0;   // Alternate settings
//---------------------


BYTE handle_get_configuration(){
    return(Configuration);            // Handled by user code
}

BOOL handle_set_configuration(BYTE cfg){
    Configuration = SETUPDAT[2];   //cfg;
    return(TRUE);            // Handled by user code
}

BOOL handle_get_interface(BYTE ifc, BYTE* alt_ifc){
    /*
    if ( ifc == 0 ) {
		*alt_ifc = 0;
		return TRUE;
	}*/
    
    *alt_ifc = AlternateSetting;
    //EP0BUF[0] = AlternateSetting;
    //EP0BCH = 0;
    //EP0BCL = 1;
    return(TRUE);            // Handled by user code
}

BOOL handle_set_interface(BYTE ifc,BYTE alt_ifc){
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
/*

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

// From hdmi2usb/cypress/hdmi2usb.c
// ----------------------------------------------------------------------------

BYTE   Configuration;      // Current configuration
BYTE   AlternateSetting = 0;   // Alternate settings

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

		if (valuesArray[3] == 1) // Frame DVI // not implemented because Atlys does not support the HPD
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
		SYNCDELAY; FIFORESET = 0;        // Release "NAK all"
		SYNCDELAY; EP2FIFOCFG = 0x10;    // Auto

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

// From examples/bulkloop/bulkloop.c
// ----------------------------------------------------------------------------

// this firmware only supports 0,0
BOOL handle_get_interface(BYTE ifc, BYTE* alt_ifc) {
 printf ( "Get Interface\n" );
 if (ifc==0) {*alt_ifc=0; return TRUE;} else { return FALSE;}
}
BOOL handle_set_interface(BYTE ifc, BYTE alt_ifc) {
 printf ( "Set interface %d to alt: %d\n" , ifc, alt_ifc );

 if (ifc==0&&alt_ifc==0) {
    // SEE TRM 2.3.7
    // reset toggles
    RESETTOGGLE(0x02);
    RESETTOGGLE(0x86);
    // restore endpoints to default condition
    RESETFIFO(0x02);
    EP2BCL=0x80;
    SYNCDELAY;
    EP2BCL=0X80;
    SYNCDELAY;
    RESETFIFO(0x86);
    return TRUE;
 } else
    return FALSE;
}

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

// From hdmi2usb/cypress/hdmi2usb.c
// ----------------------------------------------------------------------------
BOOL DR_GetConfiguration(void)   // Called when a Get Configuration command is received
{
   EP0BUF[0] = Configuration;
   EP0BCH = 0;
   EP0BCL = 1;
   return(TRUE);            // Handled by user code
}

BOOL DR_SetConfiguration(void)   // Called when a Set Configuration command is received
{

   Configuration = SETUPDAT[2];
   return(TRUE);            // Handled by user code
}

// From examples/bulkloop/bulkloop.c
// ----------------------------------------------------------------------------

// get/set configuration
BYTE handle_get_configuration() {
 return 1;
 }
BOOL handle_set_configuration(BYTE cfg) {
 return cfg==1 ? TRUE : FALSE; // we only handle cfg 1
}

*/

