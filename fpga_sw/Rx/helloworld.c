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
#include "CC1200.h"

//#define TX
#define RX
#define Tx_Pkt_size 126
#define Rx_Pkt_size 126
#define Cor_Thre 20
u32 *CC1200 = XPAR_APB_M_0_BASEADDR;

void ResetCC1200();

int writeSCC120 (int add, int data);
int readSCC120 (int add);
int writeLCC120 (int add, int data);
int readLCC120 (int add);

void TxCC1200_init(int Pkt_size);
void RxCC1200_init(int Pkt_size);

int main()
{
	int loop;
	int data;
	int Link;
	int busy;

    init_platform();

    xil_printf("Hello World\n\r");

    ResetCC1200();

#ifdef TX
    TxCC1200_init(Tx_Pkt_size);
#endif
#ifdef RX
	RxCC1200_init(Rx_Pkt_size);
#endif

    xil_printf("Read normal registers\n\r");

    usleep(100);

    for (int i=0;i<0x30;i++)
    {
    	data = (readSCC120(i) & 0xff);
    	xil_printf("                  0x%04x   0x%02x \n\r",i,data);
    }


    for (int i=0x2F00;i<0x2FFF;i++)
    {
    	data = (readLCC120(i) & 0xff);
    	xil_printf("                  0x%04x   0x%02x \n\r",i,data);
    }


    CC1200[4] = 4;        // switch to command mode
#ifdef TX
    xil_printf("set chip to Tx\n\r");
    CC1200[2] = 0x350000; // set chip to Tx
#endif
#ifdef RX
    xil_printf("set chip to Rx\n\r");
    CC1200[2] = 0x340000; // set chip to Rx
#endif
    CC1200[0] = 1;
	loop = 1;
	while (loop)
	{
		loop = CC1200[1];
	};
	    CC1200[12] = Cor_Thre; // Rx Pkt Size
	    CC1200[10] = Rx_Pkt_size + 2; // Rx Pkt Size
	    CC1200[0] = 4; // Enable Rx

//    CC1200[2] = 0x3d0000;  // check if module in Tx
//    data = 0;
//    while ((data != 0x20) && (data != 0x10))
//    {
//		CC1200[0] = 1;
//		loop = 1;
//		while (loop)
//		{
//			loop = CC1200[1];
//		};
//		data = CC1200[3] & 0xf0;
//		if ((data != 0x20) && (data != 0x10))
//		{
//			xil_printf("Chip is not set\n\r");
//		}
//    }
//    if (data == 0x20){
//	xil_printf("Switch to Tx seccesfuly in Tx\n\r");
//    } else if (data == 0x10){
//	xil_printf("Switch to Rx seccesfuly in Rx\n\r");
//    }
//
//#ifdef TX
//    CC1200[9] = Tx_Pkt_size; // Tx Pkt Size
//   	CC1200[0] = 2; // Enable Tx
//	MEM[0] = 1;		// send data from FIFO
//#endif
//#ifdef RX
//    CC1200[12] = Cor_Thre; // Rx Pkt Size
//    CC1200[10] = Rx_Pkt_size + 2; // Rx Pkt Size
//    CC1200[0] = 4; // Enable Rx
//#endif
while (1){
	busy = 1;
	while (busy == 1){
		busy = CC1200[1];
	}
	data = CC1200[13];
	Link = data-81;
	if (Link == -209){
		xil_printf("Link is Down \r\n");
	} else {
		xil_printf("RF = %d DBm\t",Link);
	}

	sleep (1);
}
    xil_printf("GoodBye World\n\r");

    cleanup_platform();
    return 0;
}
