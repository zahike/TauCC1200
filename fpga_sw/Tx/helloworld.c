/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "SCCB.h"
#define START_FREQ   0x100
#define TX
//#define RX
#define Tx_wait 0xffff
#define Tx_Pkt_size 124
#define Rx_Pkt_size 124

u32 *APB = XPAR_APB_M_0_BASEADDR;
u32 *CC1200 = XPAR_APB_M_1_BASEADDR;
//u32 *DDS = XPAR_APB_M_1_BASEADDR;

int writeSCCB (int WriteData);
int write4readSCCB (int WriteData);
int readSCCB (int WriteData);
void Camera_init();
void cfg_VGA_60fps();
void cfg_advanced_awb();

void ResetCC1200();

int writeSCC120 (int add, int data);
int readSCC120 (int add);
int writeLCC120 (int add, int data);
int readLCC120 (int add);

void TxCC1200_init(int Pkt_size);
void RxCC1200_init(int Pkt_size);

int main()
{
	int freq;
	int Hdata,Ldata,CamID;
	int loop;
	int Data,data;
	int Add1,Add2;
	int pll = 0;
    init_platform();

    xil_printf("Hello World\n\r");
	sleep(1);

	xil_printf("===== Set Up Transmitter =====\n\r");
    xil_printf("Reset CC1200\n\r");
    ResetCC1200();

    xil_printf("Configure CC1200\n\r");
    TxCC1200_init(Tx_Pkt_size);

    CC1200[4] = 4;        // switch to command mode
    xil_printf("set chip to Tx\n\r");
    CC1200[2] = 0x350000; // set chip to Tx
    CC1200[0] = 1;
	loop = 1;
	while (loop)
	{
		loop = CC1200[1];
	};

    CC1200[2] = 0x3d0000;  // check if module in Tx
    data = 0;
    while ((data != 0x20) && (data != 0x10))
    {
		CC1200[0] = 1;
		loop = 1;
		while (loop)
		{
			loop = CC1200[1];
		};
		data = CC1200[3] & 0xf0;
		if ((data != 0x20) && (data != 0x10))
		{
			xil_printf("Chip is not set\n\r");
		}
    }
    if (data == 0x20){
	xil_printf("Switch to Tx seccesfuly in Tx\n\r");
    } else if (data == 0x10){
	xil_printf("Switch to Rx seccesfuly in Rx\n\r");
    }

    CC1200[11] = Tx_wait; // Tx Pkt Size
    CC1200[9] = Tx_Pkt_size; // Tx Pkt Size
   	CC1200[0] = 2; // Enable Tx

	xil_printf("===== Set Up Camera =====\n\r");
    APB[5] = START_FREQ; // set SCCB clock to ~200Khz
	freq = 1000000/(START_FREQ*20);
	xil_printf("frequency %d \n\r",freq);

	APB[7] = 0x0;    	// set Camera reset
	usleep(100);
	APB[7] = 0x1;    	// Clear Camera reset
	usleep(100);
								// Read Camarea ID
	write4readSCCB(0x78300a00);
	Hdata = readSCCB(0x78300a00);
	write4readSCCB(0x78300b00);
	Ldata = readSCCB(0x78300b00);

	CamID = (Hdata << 8) + Ldata;
	if (CamID == 0x5640) {
		xil_printf("Camera ID correct :):) Read %x \n\r",CamID);
	} else {
		xil_printf("Camera ID incorrect :(:(  Read %x \n\r",CamID);
	}

	//[1]=0 System input clock from pad; Default read = 0x11
	writeSCCB(0x78310311);
	//[7]=1 Software reset; [6]=0 Software power down; Default=0x02
	writeSCCB(0x78300882);

	usleep(1000);

	Camera_init();
	//Stay in power down
	usleep(1000);
					///// set mode to 640x480
    xil_printf("set mode to 640x480\n\r");
	//[7]=0 Software reset; [6]=1 Software power down; Default=0x02
	writeSCCB(0x78300842);

	cfg_VGA_60fps();

	//[7]=0 Software reset; [6]=0 Software power down; Default=0x02
	writeSCCB(0x78300802);

    				///// set awb to AWB_ADVANCED
    xil_printf("set awb to AWB_ADVANCED\n\r");
	writeSCCB(0x78300842);

	cfg_advanced_awb();

	//[7]=0 Software reset; [6]=0 Software power down; Default=0x02
	writeSCCB(0x78300802);

    xil_printf("GoodBye World\n\r");

    cleanup_platform();
    return 0;
}
