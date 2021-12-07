/*
 * CC1200_functions.c
 *
 *  Created on: 7 בדצמ× 2021
 *      Author: Owner
 */

#include "CC1200.h"

void ResetCC1200()
{
	int loop;
	int data;

    CC1200[6] = 1;		// Hard Reset chip
    CC1200[7] = 0;
    usleep(100);
    CC1200[7] = 1;
    CC1200[5] = 16;

    CC1200[4] = 4;        // switch to command mode
    CC1200[2] = 0x300000; // Soft Reset chip
    CC1200[0] = 1;
	loop = 1;
	while (loop)
	{
		loop = CC1200[1];
	};

    CC1200[2] = 0x3d0000;  // check if module in reset
    data = 0;
    while (data != 0x0f)
    {
		CC1200[0] = 1;
		loop = 1;
		while (loop)
		{
			loop = CC1200[1];
		};
		data = CC1200[3] & 0xff;
		if (data != 0x0f) {
			xil_printf("Chip not set\n\r");
		}
    }

    xil_printf("Chip reset succesfuly \n\r");

}

