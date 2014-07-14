-- //////////////////////////////////////////////////////////////////////////////
-- /// Copyright (c) 2014, Ajit Mathew <ajitmathew04@gmail.com>
-- /// All rights reserved.
-- ///
-- // Redistribution and use in source and binary forms, with or without modification, 
-- /// are permitted provided that the following conditions are met:
-- ///
-- ///  * Redistributions of source code must retain the above copyright notice, 
-- ///    this list of conditions and the following disclaimer.
-- ///  * Redistributions in binary form must reproduce the above copyright notice, 
-- ///    this list of conditions and the following disclaimer in the documentation and/or 
-- ///    other materials provided with the distribution.
-- ///
-- ///    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
-- ///    EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
-- ///    OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT 
-- ///    SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
-- ///    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
-- ///    LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
-- ///    PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
-- ///    WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
-- ///    ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
-- ///   POSSIBILITY OF SUCH DAMAGE.
-- ///
-- ///
-- ///  * http://opensource.org/licenses/MIT
-- ///  * http://copyfree.org/licenses/mit/license.txt
-- ///
-- //////////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <errno.h>
#include <termios.h>
#include <unistd.h>
#include <fcntl.h>
#include<string.h>

#define N_BYTES 14
#define STATE_i 1
#define RESX1_i 2
#define RESX2_i 3
#define RESY1_i 4
#define RESY2_i 5
#define IN_FRAME_i 6
#define OUT_FRAME_i 7
#define WRITE_TIME_i 8
#define PROC_TIME_i 9
#define FRAME_DROP_i 10
#define SIZE3_i 11
#define SIZE2_i 12
#define SIZE1_i 13

int
set_interface_attribs (int fd, int speed, int parity)
{
        struct termios tty;
        memset (&tty, 0, sizeof tty);
        if (tcgetattr (fd, &tty) != 0)
        {
                printf ("error %d from tcgetattr\n", errno);
                return -1;
        }

        cfsetospeed (&tty, speed);
        cfsetispeed (&tty, speed);

        tty.c_cflag = (tty.c_cflag & ~CSIZE) | CS8;     // 8-bit chars
        // disable IGNBRK for mismatched speed tests; otherwise receive break
        // as \000 chars
        tty.c_iflag &= ~IGNBRK;         // disable break processing
        tty.c_lflag = 0;                // no signaling chars, no echo,
                                        // no canonical processing
        tty.c_oflag = 0;                // no remapping, no delays
        tty.c_cc[VMIN]  = 0;            // read doesn't block
        tty.c_cc[VTIME] = 5;            // 0.5 seconds read timeout

        tty.c_iflag &= ~(IXON | IXOFF | IXANY); // shut off xon/xoff ctrl

        tty.c_cflag |= (CLOCAL | CREAD);// ignore modem controls,
                                        // enable reading
        tty.c_cflag &= ~(PARENB | PARODD);      // shut off parity
        tty.c_cflag |= parity;
        tty.c_cflag &= ~CSTOPB;
        tty.c_cflag &= ~CRTSCTS;

        if (tcsetattr (fd, TCSANOW, &tty) != 0)
        {
                printf ("error %d from tcsetattr\n", errno);
                return -1;
        }
        return 0;
}

void
set_blocking (int fd, int should_block)
{
        struct termios tty;
        memset (&tty, 0, sizeof tty);
        if (tcgetattr (fd, &tty) != 0)
        {
                printf ("error %d from tggetattr\n", errno);
                return;
        }

        tty.c_cc[VMIN]  = should_block ? 1 : 0;
        tty.c_cc[VTIME] = 10;            // 0.5 seconds read timeout

        if (tcsetattr (fd, TCSANOW, &tty) != 0)
                printf ("error %d setting term attributes\n", errno);
}


int main()
{
	char *portname = "/dev/ttyUSB0";
		
	int fd = open (portname, O_RDWR | O_NOCTTY | O_SYNC);
	if (fd < 0)
	{
		printf ("error %d opening %s: %s\n", errno, portname, strerror (errno));
		return;
	}

	set_interface_attribs (fd, B9600, 0);  // set speed to 115,200 bps, 8n1 (no parity)
	set_blocking (fd, 0);                // set no blocking

	//write (fd, "hello!\n", 7);           // send 7 character greeting

	usleep ((7 + 25) * 100);             // sleep enough to transmit the 7 plus
	// receive 25:  approx 100 uS per char transmit
	unsigned char buf [100];
	unsigned char start=0XAA;
	int n;
	int index;
	unsigned char debug_arr[16];
	unsigned int resX,resY,frame_size;
	while(1)
	{
		index=1;
		n = read (fd, buf, 100);  // read up to 100 characters if ready to read
		while (buf[0]!=start)read(fd,buf,100);
		while(index<14)
		{	
			read(fd,buf,100);
	//		printf("%d %hhu\n",index,buf[0]);    //RAW DATA from FPGA
			debug_arr[index]=buf[0];
			index=index+1;
		}
		if ((debug_arr[STATE_i]>>6 && 1)==1)
			printf("HDMI 0 is connected\n");
		else
			printf("HDMI 0 is not connected \n");

		
		if ((debug_arr[STATE_i]>>5 && 1)==1)
			printf("HDMI 1 is connected\n");
		else
			printf("HDMI 1 is not connected \n");

		
		printf("Output Format: ");
		if ((debug_arr[STATE_i]>>4 & 1)==1)
			printf("JPEG\n");
		else
			printf("RAW\n");

		
		printf("Selected Source: ");
		if ((debug_arr[STATE_i]>>3 & 1)==0&&(debug_arr[STATE_i]>>3&1)==0)
			printf("HDMI 0\n");
		else if ((debug_arr[STATE_i]>>3 & 1)==0&&(debug_arr[STATE_i]>>3&1)==1)
			printf("HDMI 1\n");
		else
			printf("Test Pattern\n");

		printf("Encoding Quality: ");
		unsigned char enc_q=debug_arr[STATE_i]&3;
		if(enc_q==0)
			printf("100%%\n");
		else if(enc_q ==1)
			printf("85%%\n");
		else if(enc_q == 2)
			printf("75%%\n");
		else if (enc_q == 3)
			printf("50%%\n");
		

		resX=0;
		resX = debug_arr[RESX1_i];
		resX = (resX<<8)|debug_arr[RESX2_i];
//		printf("%u\n",resX);

		resY = 0;
		resY = debug_arr[RESY1_i];
		resY = (resY<<8)|debug_arr[RESY2_i];
		printf("Input Resolution: %ux%u\n",resX,resY);
		
		printf("Input Frame Rate: %hhu fps\n",debug_arr[IN_FRAME_i]);

		printf("Output Frame Rate: %hhu fps\n",debug_arr[OUT_FRAME_i]);

		printf("Frame Write Time: %hhu ms\n", debug_arr[WRITE_TIME_i]);

		printf("Frame Processing Time: %hhu ms\n", debug_arr[PROC_TIME_i]);

		printf("No. of Frames Dropped: %hhu fps \n", debug_arr[FRAME_DROP_i]);

		frame_size=debug_arr[SIZE3_i];
		frame_size=frame_size<<8|debug_arr[SIZE2_i];
		frame_size=frame_size<<8|debug_arr[SIZE1_i];
		printf("Frame Size: %f Mbytes\n",frame_size*8.0/1024/1024);
		printf("\n");
		printf("*********************************************");
		printf("\n\n");


	}

}
