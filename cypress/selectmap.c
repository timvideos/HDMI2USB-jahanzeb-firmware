#include <fx2regs.h>
#include <delay.h>
#include <makestuff.h>
#include "defs.h"

// Bound signals with FPGA
#define PROG_B PD0
#define DONE   PD1
#define CSI_B  PD2
#define INIT_B PD5
#define CCLK   PD6
#define SUSPEND_F PD7

#define LED6   PB0
#define M2     PB1
#define VS2    PB2
#define M0     PB3
#define RDWR_B PB4
#define M1     PB5
#define VS0    PB6
#define VS1    PB7

// Micro-controller modes
#define WAIT_MODE       0xA1
#define PORT_MODE       0xA2
#define CONF_F_MODE     0xA7

// Micro-controller commands
// FPGA configuration
#define PROG_DONE    0xAB
#define PROG_ERROR   0xAC
#define INIT_B_LOW   0xB0
#define DONE_LOW     0xB2
#define F_NOT_READY  0xB3

static uint32 m_fpgaFileLen = 0;

bool smapIsProgPending(void) {
	return (m_fpgaFileLen != 0);
}

void smapProgBegin(uint32 fileLen) {
	m_fpgaFileLen = fileLen;
}

uint8 smapProgExecute(void) {
	uint8 fpgaStatus = PROG_ERROR;

	// Switch port B to being GPIO
	SYNCDELAY; IFCONFIG = (bmIFCLKSRC | bm3048MHZ | bmIFCLKOE | bmPORTS);
	
	// Configure ports
	OED = 0xC5; // set PD0/2/6/7 as outputs, the rest as inputs
	OEA = 0xFF; // set port A as outputs (SelectMAP data bus)
	OEB = 0xFF; // set port B as outputs

	SUSPEND_F = 0;  // do not suspend the FPGA
	PROG_B = 0;     // reset the FPGA
	RDWR_B = 1;     // leave write mode disabled for now
	CSI_B = 1;      // deassert FPGA chip select for now

	CCLK  = 0;     // set CCLK low
	
	M2    = 1;    // M2 = 1 for SelectMap mode 
	M1    = 1;    // M1 = 1 for SelectMap mode
	M0    = 0;    // M0 = 0 for SelectMap mode
	
	delay(500); // 500ms
	while (INIT_B != 0) {}; // wait for INIT_B to go low
	PROG_B = 1;             // PROG_B back up
	while (INIT_B != 1) {}; // Wait for INIT_B to do the same
	RDWR_B = 0; // select write mode
	CSI_B = 0;  // assert chip select
	delay(500);
	if (DONE == 1) {
		fpgaStatus = F_NOT_READY;
		goto cleanup;
	}

	while ( m_fpgaFileLen > 0 ) { 
		xdata BYTE i;
		xdata BYTE bytes;
		while ( EP01STAT & bmEP1OUTBSY );
		bytes = EP1OUTBC;
		for ( i = 0; i < bytes; ++i ) {
			IOA = EP1OUTBUF[i]; // output the byte on port A
			CCLK = 0;     // tick the clock (low)
			LED6 = 1;     // flash the LED, why not?
			CCLK = 1;     // tick the clock (high)
			LED6 = 0;     // keep flashing this LED
		}
		m_fpgaFileLen -= bytes;
		if ( (INIT_B == 0) & (DONE == 0) ) {
			fpgaStatus = INIT_B_LOW; // Init_B unexpectedly low
			LED6 = 1; // turn LED off
			goto cleanup;
		}
		EP1OUTBC = 0x00;
	}
	if (DONE == 1) {
		// Keep the SOFT_RESET active for the time being
		OEA = 0x00; // Port A as input
		
		CSI_B = 1;  // release chip select
		RDWR_B = 1; // release write mode
		// Set ports as input to avoid conflicts with application just
		// downloaded
		OEB = 0x00; // Port B as input
		OED = 0x81; // Port D as input save for PROG_B and SUSPEND_F
		fpgaStatus = PROG_DONE;
	} else {
		fpgaStatus = DONE_LOW;
	}

cleanup:
	SYNCDELAY; IFCONFIG = (bmIFCLKSRC | bm3048MHZ | bmIFCLKOE | bmFIFOS);
	return fpgaStatus;
}
