/*
 * cfg_advanced_awb.c
 *
 *  Created on: 28 баев„ 2021
 *      Author: Owner
 */

void cfg_advanced_awb ()
{
	// Enable Advanced AWB
	writeSCCB(0x78340600);
	writeSCCB(0x78519204);
	writeSCCB(0x785191f8);
	writeSCCB(0x78518d26);
	writeSCCB(0x78518f42);
	writeSCCB(0x78518e2b);
	writeSCCB(0x78519042);
	writeSCCB(0x78518bd0);
	writeSCCB(0x78518cbd);
	writeSCCB(0x78518718);
	writeSCCB(0x78518818);
	writeSCCB(0x78518956);
	writeSCCB(0x78518a5c);
	writeSCCB(0x7851861c);
	writeSCCB(0x78518150);
	writeSCCB(0x78518420);
	writeSCCB(0x78518211);
	writeSCCB(0x78518300);
	writeSCCB(0x78500103);

};
