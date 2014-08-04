/*
*  Copyright (c) 2014, Ajit Mathew <ajitmathew04@gmail.com>
*
*  Licenced under Apache 2.0
*/

#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <sys/time.h>
#include <unistd.h>
#include <termios.h>

/* Number of bytes recieved*/
#define N_BYTES 14

/* Index of byte in Debug_arr */
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

/* Non blocking IO Enable/Disable */
#define NB_ENABLE 1
#define NB_DISABLE 0

/* Enable to display raw data. */
//#define PRINT_RAW_DATA

/* Credits : wallyk @ stackoverflow */
int set_interface_attribs(int fd, int speed, int parity)
{
	struct termios tty;

	memset(&tty, 0, sizeof(tty));
	if (tcgetattr(fd, &tty) != 0) {
		perror("tcgetattr");
		return -1;
	}

	cfsetospeed(&tty, speed);
	cfsetispeed(&tty, speed);

	tty.c_cflag = (tty.c_cflag & ~CSIZE) | CS8;     /* 8-bit chars */
	/* Disable IGNBRK for mismatched speed tests; otherwise receive
	 * break as \000 chars */
	tty.c_iflag &= ~IGNBRK;         /* disable break processing */
	tty.c_lflag = 0;                /* no signaling chars, no echo,
					   no canonical processing */
	tty.c_oflag = 0;                /* no remapping, no delays */
	tty.c_cc[VMIN]  = 0;            /* read doesn't block */
	tty.c_cc[VTIME] = 5;            /* 5 seconds read timeout */

	tty.c_iflag &= ~(IXON | IXOFF | IXANY); /* shut off xon/xoff ctrl */

	tty.c_cflag |= (CLOCAL | CREAD);/* ignore modem controls */
	/* enable reading */
	tty.c_cflag &= ~(PARENB | PARODD);      /* shut off parity */
	tty.c_cflag |= parity;
	tty.c_cflag &= ~CSTOPB;
	tty.c_cflag &= ~CRTSCTS;

	if (tcsetattr(fd, TCSANOW, &tty) != 0) {
		perror("tcsetattr");
		return -1;
	}
	return 0;
}

void set_blocking(int fd, int should_block)
{
	struct termios tty;

	memset(&tty, 0, sizeof(tty));
	if (tcgetattr(fd, &tty) != 0) {
		perror("tggetattr");
		return;
	}

	tty.c_cc[VMIN] = should_block ? 1 : 0;
	tty.c_cc[VTIME] = 10;            /* read timeout */

	if (tcsetattr(fd, TCSANOW, &tty) != 0)
		printf("error %d setting term attributes\n", errno);
}

static int kbhit(void)
{
	struct timeval tv;
	fd_set fds;

	tv.tv_sec = 0;
	tv.tv_usec = 0;
	FD_ZERO(&fds);
	FD_SET(STDIN_FILENO, &fds); /* STDIN_FILENO is 0 */
	select(STDIN_FILENO+1, &fds, NULL, NULL, &tv);
	return FD_ISSET(STDIN_FILENO, &fds);
}

static void nonblock(int state)
{
	struct termios ttystate;

	tcgetattr(STDIN_FILENO, &ttystate);

	if (state == NB_ENABLE) {
		ttystate.c_lflag &= ~ICANON;
		ttystate.c_cc[VMIN] = 1;
	} else if (state == NB_DISABLE) {
		ttystate.c_lflag |= ICANON;
	}

	tcsetattr(STDIN_FILENO, TCSANOW, &ttystate);
}


static void clear_screen(void)
{
	const char *CLEAR_SCREEN_ANSI = "\e[1;1H\e[2J";

	write(STDOUT_FILENO, CLEAR_SCREEN_ANSI, 12);
}

static char option_selected(void)
{
	char c;
	int key_hit = 0;

	nonblock(NB_ENABLE);
	while (!key_hit) {
		usleep(1);
		key_hit = kbhit();
		if (key_hit != 0) {
			c = fgetc(stdin);
			if (c == '1' || c == '2' || c == 'q')
				key_hit = 1;
			else {
				key_hit = 0;
				printf("\nInvalid Input\n");
				printf(" To select press [1/2/q]: ");
				fflush(stdout);
			}
		}

	}
	nonblock(NB_DISABLE);
	printf("\n");
	return c;
}

char print_welcome(void)
{
	clear_screen();
	printf("**************FPGA FIRMWARE DEBUGGER*************\n");
	printf("Chose your device\n");
	printf("\n1-HDMI2USB\n");
	printf("\n2-HDMI2ETHERNET\n");
	printf("\nq-QUIT\n");
	printf("\nTo select press [1/2/q]: ");
	fflush(stdout);
	return option_selected();
}

int open_port(void)
{
	char portname[20];
	int fd;

	printf("\n");
	printf("Portname of selected device: ");
	fflush(stdout);

	scanf("%s", portname);
	fd = open(portname, O_RDWR | O_NOCTTY | O_SYNC);
	if (fd < 0) {
		printf("error %d opening %s: %s\n",
			errno, portname, strerror(errno));
		return fd;
	}

	/* set speed to 9600 bps, 8n1 (no parity) */
	set_interface_attribs(fd, B9600, 0);

	/*set no blocking */
	set_blocking(fd, 0);

	return fd;

}

void parse_and_print(unsigned char debug_arr[])
{
	unsigned int resX, resY, frame_size;
	unsigned char enc_q;

	printf("\033[2J\033[1;1H");
	if ((debug_arr[STATE_i] >> 6 && 1) == 1)
		printf("HDMI 0 is connected\n");
	else
		printf("HDMI 0 is not connected\n");


	if ((debug_arr[STATE_i] >> 5 && 1) == 1)
		printf("HDMI 1 is connected\n");
	else
		printf("HDMI 1 is not connected\n");


	if (debug_arr[IN_FRAME_i] == 0) {
		printf("\n***CONNECT INPUT SOURCE***\n\n\n");
		printf("Press ENTER to return\n\n");
		printf("\033[2J\033[1;1H");
		return;
	}

	printf("Output Format: ");
	if ((debug_arr[STATE_i] >> 4 & 1) == 1)
		printf("JPEG\n");
	else
		printf("RAW\n");


	printf("Selected Source: ");
	if ((debug_arr[STATE_i] >> 3 & 1) == 0
			&& (debug_arr[STATE_i] >> 3 & 1) == 0)
		printf("HDMI 0\n");

	else if ((debug_arr[STATE_i] >> 3 & 1) == 0
			&& (debug_arr[STATE_i] >> 3 & 1) == 1)
		printf("HDMI 1\n");

	else
		printf("Test Pattern\n");

	printf("Encoding Quality: ");
	enc_q = debug_arr[STATE_i]&3;
	if (enc_q == 0)
		printf("100%%\n");
	else if (enc_q == 1)
		printf("85%%\n");
	else if (enc_q == 2)
		printf("75%%\n");
	else if (enc_q == 3)
		printf("50%%\n");


	resX = 0;
	resX = debug_arr[RESX1_i];
	resX = (resX << 8) | debug_arr[RESX2_i];

	resY = 0;
	resY = debug_arr[RESY1_i];
	resY = (resY << 8) | debug_arr[RESY2_i];
	printf("Input Resolution: %ux%u\n", resX, resY);

	printf("Input Frame Rate: %hhu fps\n", debug_arr[IN_FRAME_i]);

	if (debug_arr[OUT_FRAME_i] - 1 <= 0) {
		printf("Output Frame Rate: 0 fps\n");
		printf("\n***START/RESTART USB STREAMING***\n\n");
		printf("\n");
		printf("Press ENTER to return");
		printf("\n\n");
		printf("\033[2J\033[1;1H");
		return;
	}

	printf("Output Frame Rate: %hhu fps\n", debug_arr[OUT_FRAME_i]-1);
	printf("Frame Write Time: %hhu ms\n", debug_arr[WRITE_TIME_i]);

	printf("Frame Processing Time: %hhu ms\n", debug_arr[PROC_TIME_i]);

	printf("No. of Frames Dropped: %hhu fps\n", debug_arr[FRAME_DROP_i]);

	frame_size = debug_arr[SIZE3_i];
	frame_size = frame_size << 8 | debug_arr[SIZE2_i];
	frame_size = frame_size << 8 | debug_arr[SIZE1_i];
	printf("Frame Size: %f Mbytes\n", frame_size * 8.0 / 1024 / 1024);
	printf("\n");
	printf("Press ENTER to return");
	fflush(stdout);
}

int main()
{
	while (1) {
		char usb_or_eth = print_welcome();

		if (usb_or_eth == '1') {
			clear_screen();
			printf("Chose Debugging Output Method\n");
			printf("\n1- CDC\n");
			printf("\n2- UART\n");
			printf("\nq- Return\n");
			printf("\nTo select press [1/2/q]: ");
			fflush(stdout);

			char cdcORuart = option_selected();

			if (cdcORuart == 'q')
				print_welcome();
			else{
				int fd = open_port();

				if (fd < 0)
					return 0;
				unsigned char buf[100];
				unsigned char start = 0XAA;
				int index;
				unsigned char debug_arr[16];

				if (cdcORuart == '1') {
					while (!kbhit()) {
						write(fd, "DS", 2);
						if (read(fd, buf, 100) < 0)
							perror("read");
						parse_and_print(buf);
						sleep(1);
					}
					getchar();
					close(fd);
				} else if (cdcORuart == '2') {
					while (!kbhit()) {
						index = 1;

						while (buf[0] != start) {
							if (read(fd, buf, 100) < 0)
								perror("read");
						}

						while (index < N_BYTES) {
							read(fd, buf, 10);
#ifdef PRINT_RAW_DATA
							/* RAW DATA FROM FPGA */
							/* printf("%d %hhu\n",index,buf[0]); */
#endif
							debug_arr[index] = buf[0];
							index = index + 1;
						}
						parse_and_print(debug_arr);
					}
					getchar();
					close(fd);
				}
			}
		} else if (usb_or_eth == '2') {
			clear_screen();
			printf("Packets are on their way....feature coming soon\n");
			printf("Press ENTER to return\n");
			while (!kbhit())
				;
			getchar();
		} else {
			printf("Thank You\n");
			printf("TimVideos - World wide Leader in Live Event Streaming\n");
			return 0;
		}
		getchar();
	}


}
