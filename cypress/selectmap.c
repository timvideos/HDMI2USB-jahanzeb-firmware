#include <fx2regs.h>
#include <delay.h>
#include <makestuff.h>
#include "defs.h"

#undef bmDONE

// Bound signals with FPGA
#define INIT PD5
#define bmINIT bmBIT5
#define DONE PD1
#define bmDONE bmBIT1

#define PROG   PD0
#define bmPROG bmBIT0
#define CSI    PD2
#define bmCSI  bmBIT2
#define CCLK   PD6
#define bmCCLK bmBIT6
#define RDWR   PB4
#define bmRDWR bmBIT4
#define M0     PB3
#define bmM0   bmBIT3
#define M1     PB5
#define bmM1   bmBIT5
#define M2     PB1
#define bmM2   bmBIT1
#define VS0    PB6
#define bmVS0  bmBIT6
#define VS1    PB7
#define bmVS1  bmBIT7
#define VS2    PB2
#define bmVS2  bmBIT2

// Micro-controller commands
// FPGA configuration
#define PROG_DONE  0xAB
#define PROG_ERROR 0xAC
#define INIT_LOW   0xB0
#define DONE_LOW   0xB2
#define NOT_READY  0xB3

uint8 portAccess(uint8 portSelect, uint8 mask, uint8 ddrWrite, uint8 portWrite);

uint8 tryReset(void) {
	xdata uint8 response = 0x42;
#ifdef DIRECT_RESET
	// Assert PROG
	PROG = 0;     // assert PROG to put FPGA in initialisation mode
	OED &= ~(bmINIT | bmDONE);  // INIT & DONE inputs
	OED |= bmPROG;  // PROG output; asserted

	// Wait for INIT to assert
	while ( INIT );  // wait for FPGA to acknowledge PROG assert

	// Deassert PROG
	PROG = 1;             // deassert PROG

	// Wait for INIT to deassert
	while ( !INIT );  // wait for FPGA to acknowledge PROG deassert

	// Ensure FPGA is ready:
	if ( DONE == 1 ) {
		response = 0x23;
	}
#else
	xdata uint8 tempByte;
	
	// Assert PROG, wait for INIT assert
	do {
		tempByte = portAccess(
			3,
			(bmPROG | bmINIT | bmDONE),  // mask
			bmPROG,                      // ddr
			0x00                         // port
		);
	} while ( tempByte & bmINIT );

	// Deassert PROG, wait for INIT deassert
	do {
		tempByte = portAccess(
			3,
			(bmPROG | bmINIT | bmDONE),  // mask
			bmPROG,                      // ddr
			bmPROG                       // port
		);
	} while ( !(tempByte & bmINIT) );

	// Ensure FPGA is ready:
	if ( tempByte & bmDONE ) {
		response = 0x23;
	}
#endif
	return response;
}

static uint32 m_fpgaFileLen = 0;

bool smapIsProgPending(void) {
	return (m_fpgaFileLen != 0);
}

void smapProgBegin(uint32 fileLen) {
	m_fpgaFileLen = fileLen;
}

uint8 smapProgExecute(void) {
	uint8 fpgaStatus = PROG_ERROR;

#ifdef INIT_SELECTMAP
	// Port B config (won't take effect until FIFO mode is disabled
	OEB = (bmRDWR | bmM0 | bmM1 | bmM2);
	M2   = 1;      // M2 = 1 for SelectMap mode 
	M1   = 1;      // M1 = 1 for SelectMap mode
	M0   = 0;      // M0 = 0 for SelectMap mode
	RDWR = 0;      // assert write mode

	// Port D config
	CSI = 0;       // assert FPGA chip select
	OED |= bmCSI;

	delay(500);

	// Put FPGA in config mode (tri-state I/Os)
	PROG = 0;     // assert PROG to put FPGA in initialisation mode
	OED &= ~(bmINIT | bmDONE);  // INIT & DONE inputs
	OED |= bmPROG;  // PROG output; asserted
	while ( INIT != 0 );  // wait for FPGA to acknowledge PROG assert

	// Now that FPGA is in config mode, we can disabale FIFO mode
	SYNCDELAY; IFCONFIG = (bmIFCLKSRC | bm3048MHZ | bmIFCLKOE | bmPORTS);
	
	// CCLK output: low
	CCLK = 0;      // set CCLK low
	OED |= bmCCLK;

	// Set port A as outputs (SelectMAP data bus)
	OEA = 0xFF;

	// Deassert PROG. FPGA samples M[2:0], VS[2:0] here.
	PROG = 1;             // deassert PROG
	while ( INIT != 1 );  // wait for FPGA to acknowledge PROG deassert

	// Ensure FPGA is ready:
	if ( DONE == 1 ) {
		fpgaStatus = NOT_READY;
		goto cleanup;
	}
#endif

	while ( m_fpgaFileLen > 0 ) { 
		xdata BYTE i;
		xdata BYTE bytes;
		while ( EP01STAT & bmEP1OUTBSY );
		bytes = EP1OUTBC;
		for ( i = 0; i < bytes; ++i ) {
			IOA = EP1OUTBUF[i]; // output the byte on port A
			CCLK = 0;     // tick the clock (low)
			CCLK = 1;     // tick the clock (high)
		}
		m_fpgaFileLen -= bytes;
		//if ( (INIT == 0) & (DONE == 0) ) {
		//	fpgaStatus = INIT_LOW; // INIT unexpectedly low
		//	goto cleanup;
		//}
		EP1OUTBC = 0x00;
	}
	//if ( DONE == 1 ) {
	//	fpgaStatus = PROG_DONE;
	//} else {
	//	fpgaStatus = DONE_LOW;
	//}

cleanup:
#ifdef INIT_SELECTMAP
	OEA = 0x00; // Port A as input
	OED &= ~bmCCLK; // tri-state CCLK
	SYNCDELAY; IFCONFIG = (bmIFCLKSRC | bm3048MHZ | bmIFCLKOE | bmFIFOS);
#endif
	return fpgaStatus;
}
