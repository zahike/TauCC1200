/*
 * cfg_VGA_60fps.c
 *
 *  Created on: 28 баев„ 2021
 *      Author: Owner
 */

void cfg_VGA_60fps ()
	{//640 x 480 binned, RAW10, MIPISCLK=560M, SCLK=56Mz, PCLK=56M
		//PLL1 configuration
		//[7:4]=0010 System clock divider /2, [3:0]=0001 Scale divider for MIPI /1
		writeSCCB(0x78303521);
		//[7:0]=70 PLL multiplier
		writeSCCB(0x78303646);
		//[4]=0 PLL root divider /1, [3:0]=5 PLL pre-divider /1.5
		writeSCCB(0x78303705);
		//[5:4]=01 PCLK root divider /2, [3:2]=00 SCLK2x root divider /1, [1:0]=01 SCLK root divider /2
		writeSCCB(0x78310811);

		//[6:4]=001 PLL charge pump, [3:0]=1010 MIPI 10-bit mode
		writeSCCB(0x7830341A);

		//[3:0]=0 X address start high byte
		writeSCCB(0x78380000); //, (0 >> 8) & 0x0F);
		//[7:0]=0 X address start low byte
		writeSCCB(0x78380100); //, 0 & 0xFF);
		//[2:0]=0 Y address start high byte
		writeSCCB(0x78380200); //, (4 >> 8) & 0x07);
		//[7:0]=0 Y address start low byte
		writeSCCB(0x78380304); //, 4 & 0xFF);

		//[3:0] X address end high byte
		writeSCCB(0x78380405); //, (1309 >> 8) & 0x0F); 0x51d
		//[7:0] X address end low byte
		writeSCCB(0x7838051D); //, 1309 & 0xFF);
		//[2:0] Y address end high byte
		writeSCCB(0x78380605); //, (1298 >> 8) & 0x07); 0x512
		//[7:0] Y address end low byte
		writeSCCB(0x78380712); //, 1298 & 0xFF);

		//[3:0]=0 timing hoffset high byte
		writeSCCB(0x78381000); //, (0 >> 8) & 0x0F);
		//[7:0]=0 timing hoffset low byte
		writeSCCB(0x78381100); //, 0 & 0xFF);
		//[2:0]=0 timing voffset high byte
		writeSCCB(0x78381200); //, (0 >> 8) & 0x07);
		//[7:0]=0 timing voffset low byte
		writeSCCB(0x78381300); //, 0 & 0xFF);

		//[3:0] Output horizontal width high byte
		writeSCCB(0x78380802); //, (640 >> 8) & 0x0F); 0x280
		//[7:0] Output horizontal width low byte
		writeSCCB(0x78380980); //, 640 & 0xFF);
		//[2:0] Output vertical height high byte
		writeSCCB(0x78380a01); //, (480 >> 8) & 0x7F); 0x1E0
		//[7:0] Output vertical height low byte
		writeSCCB(0x78380be0); //, 480 & 0xFF);

		//HTS line exposure time in # of pixels
//		writeSCCB(0x78380c, (1896 >> 8) & 0x1F);
//		writeSCCB(0x78380d, 1896 & 0xFF);
		writeSCCB(0x78380c05); //, (1422 >> 8) & 0x1F); 0x58E
		writeSCCB(0x78380d8E); //, 1422 & 0xFF);
		//VTS frame exposure time in # lines
		writeSCCB(0x78380e02); //, (656 >> 8) & 0xFF); 0x290
//		writeSCCB(0x78380f90); //, 656 & 0xFF);
		writeSCCB(0x78380f95); //, 656 & 0xFF);

		//[7:4]=0x3 horizontal odd subsample increment, [3:0]=0x1 horizontal even subsample increment
		writeSCCB(0x78381431);
		//[7:4]=0x3 vertical odd subsample increment, [3:0]=0x1 vertical even subsample increment
		writeSCCB(0x78381531);

		//[2]=0 ISP mirror, [1]=0 sensor mirror, [0]=1 horizontal binning
		writeSCCB(0x78382101);

		//little MIPI shit: global timing unit, period of PCLK in ns * 2(depends on # of lanes)
		writeSCCB(0x784837, 36); // 1/56M*2

		//Undocumented anti-green settings
		writeSCCB(0x78361800); // Removes vertical lines appearing under bright light
		writeSCCB(0x78361259);
		writeSCCB(0x78370864);
		writeSCCB(0x78370952);
		writeSCCB(0x78370c03);

		//[7:4]=0x0 Formatter RAW, [3:0]=0x0 BGBG/GRGR
		writeSCCB(0x78430000);
		//[2:0]=0x3 Format select ISP RAW (DPC)
		writeSCCB(0x78501f03);
	};


