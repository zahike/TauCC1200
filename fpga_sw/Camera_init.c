/*
 * Camera_init.c
 *
 *  Created on: 28 баев„ 2021
 *      Author: Owner
 */

void Camera_init ()
{
		//[7]=0 Software reset; [6]=1 Software power down; Default=0x02
		writeSCCB(0x78300842);
		//[1]=1 System input clock from PLL; Default read = 0x11
		writeSCCB(0x78310303);
		//[3:0]=0000 MD2P,MD2N,MCP,MCN input; Default=0x00
		writeSCCB(0x78301700);
		//[7:2]=000000 MD1P,MD1N, D3:0 input; Default=0x00
		writeSCCB(0x78301800);
		//[6:4]=001 PLL charge pump, [3:0]=1000 MIPI 8-bit mode
		writeSCCB(0x78303418);

		//              +----------------+        +------------------+         +---------------------+        +---------------------+
		//XVCLK         | PRE_DIV0       |        | Mult (4+252)     |         | Sys divider (0=16)  |        | MIPI divider (0=16) |
		//+-------+-----> 3037[3:0]=0001 +--------> 3036[7:0]=0x38   +---------> 3035[7:4]=0001      +--------> 3035[3:0]=0001      |
		//12MHz   |     | / 1            | 12MHz  | * 56             | 672MHz  | / 1                 | 672MHz | / 1                 |
		//        |     +----------------+        +------------------+         +----------+----------+        +----------+----------+
		//        |                                                                       |                              |
		//        |                                                                       |                      MIPISCLK|672MHz
		//        |                                                                       |                              |
		//        |     +----------------+        +------------------+         +----------v----------+        +----------v----------+
		//        |     | PRE_DIVSP      |        | R_DIV_SP         |         | PLL R divider       |        | MIPI PHY            | MIPI_CLK
		//        +-----> 303d[5:4]=01   +--------> 303d[2]=0 (+1)   |         | 3037[4]=1 (+1)      |        |                     +------->
		//              | / 1.5          |  8MHz  | / 1              |         | / 2                 |        | / 2                 | 336MHz
		//              +----------------+        +---------+--------+         +----------+----------+        +---------------------+
		//                                                  |                             |
		//                                                  |                             |
		//                                                  |                             |
		//              +----------------+        +---------v--------+         +----------v----------+        +---------------------+
		//              | SP divider     |        | Mult             |         | BIT div (MIPI 8/10) |        | SCLK divider        | SCLK
		//              | 303c[3:0]=0x1  +<-------+ 303b[4:0]=0x19   |         | 3034[3:0]=0x8)      +----+---> 3108[1:0]=01 (2^)   +------->
		//              | / 1            | 200MHz | * 25             |         | / 2                 |    |   | / 2                 | 84MHz
		//              +--------+-------+        +------------------+         +----------+----------+    |   +---------------------+
		//                       |                                                        |               |
		//                       |                                                        |               |
		//                       |                                                        |               |
		//              +--------v-------+                                     +----------v----------+    |   +---------------------+
		//              | R_SELD5 div    | ADCCLK                              | PCLK div            |    |   | SCLK2x divider      |
		//              | 303d[1:0]=001  +------->                             | 3108[5:4]=00 (2^)   |    +---> 3108[3:2]=00 (2^)   +------->
		//              | / 1            | 200MHz                              | / 1                 |        | / 1                 | 168MHz
		//              +----------------+                                     +----------+----------+        +---------------------+
		//                                                                                |
		//                                                                                |
		//                                                                                |
		//                                                                     +----------v----------+        +---------------------+
		//                                                                     | P divider (* #lanes)| PCLK   | Scale divider       |
		//                                                                     | 3035[3:0]=0001      +--------> 3824[4:0]           |
		//                                                                     | / 1                 | 168MHz | / 2                 |
		//                                                                     +---------------------+        +---------------------+

		//PLL1 configuration
		//[7:4]=0001 System clock divider /1, [3:0]=0001 Scale divider for MIPI /1
		writeSCCB(0x78303511);
		//[7:0]=56 PLL multiplier
		writeSCCB(0x78303638);
		//[4]=1 PLL root divider /2, [3:0]=1 PLL pre-divider /1
		writeSCCB(0x78303711);
		//[5:4]=00 PCLK root divider /1, [3:2]=00 SCLK2x root divider /1, [1:0]=01 SCLK root divider /2
		writeSCCB(0x78310801);
		//PLL2 configuration
		//[5:4]=01 PRE_DIV_SP /1.5, [2]=1 R_DIV_SP /1, [1:0]=00 DIV12_SP /1
		writeSCCB(0x78303D10);
		//[4:0]=11001 PLL2 multiplier DIV_CNT5B = 25
		writeSCCB(0x78303B19);

		writeSCCB(0x7836302e);
		writeSCCB(0x7836310e);
		writeSCCB(0x783632e2);
		writeSCCB(0x78363323);
		writeSCCB(0x783621e0);
		writeSCCB(0x783704a0);
		writeSCCB(0x7837035a);
		writeSCCB(0x78371578);
		writeSCCB(0x78371701);
		writeSCCB(0x78370b60);
		writeSCCB(0x7837051a);
		writeSCCB(0x78390502);
		writeSCCB(0x78390610);
		writeSCCB(0x7839010a);
		writeSCCB(0x78373102);
		//VCM debug mode
		writeSCCB(0x78360037);
		writeSCCB(0x78360133);
		//System control register changing not recommended
		writeSCCB(0x78302d60);
		//??
		writeSCCB(0x78362052);
		writeSCCB(0x78371b20);
		//?? DVP
		writeSCCB(0x78471c50);

		writeSCCB(0x783a1343);
		writeSCCB(0x783a1800);
		writeSCCB(0x783a19f8);
		writeSCCB(0x78363513);
		writeSCCB(0x78363606);
		writeSCCB(0x78363444);
		writeSCCB(0x78362201);
		writeSCCB(0x783c0134);
		writeSCCB(0x783c0428);
		writeSCCB(0x783c0598);
		writeSCCB(0x783c0600);
		writeSCCB(0x783c0708);
		writeSCCB(0x783c0800);
		writeSCCB(0x783c091c);
		writeSCCB(0x783c0a9c);
		writeSCCB(0x783c0b40);

		//[7]=1 color bar enable, [3:2]=00 eight color bar
		writeSCCB(0x78503d00);
		//[2]=1 ISP vflip, [1]=1 sensor vflip
		writeSCCB(0x78382046);

		//[7:5]=010 Two lane mode, [4]=0 MIPI HS TX no power down, [3]=0 MIPI LP RX no power down, [2]=1 MIPI enable, [1:0]=10 Debug mode; Default=0x58
		writeSCCB(0x78300e45);
		//[5]=0 Clock free running, [4]=1 Send line short packet, [3]=0 Use lane1 as default, [2]=1 MIPI bus LP11 when no packet; Default=0x04
		writeSCCB(0x78480014);
		writeSCCB(0x78302e08);
		//[7:4]=0x3 YUV422, [3:0]=0x0 YUYV
		//{0x430030},
		//[7:4]=0x6 RGB565, [3:0]=0x0 {b[4:0],g[5:3],g[2:0],r[4:0]}
		writeSCCB(0x7843006f);
		writeSCCB(0x78501f01);

		writeSCCB(0x78471303);
		writeSCCB(0x78440704);
		writeSCCB(0x78440e00);
		writeSCCB(0x78460b35);
		//[1]=0 DVP PCLK divider manual control by 0x3824[4:0]
		writeSCCB(0x78460c20);
		//[4:0]=1 SCALE_DIV=INT(3824[4:0]/2)
		writeSCCB(0x78382401);

		//MIPI timing
		//		writeSCCB(0x78480510); //LPX global timing select=auto
		//		writeSCCB(0x78481800); //hs_prepare + hs_zero_min ns
		//		writeSCCB(0x78481996);
		//		writeSCCB(0x78482A00); //hs_prepare + hs_zero_min UI
		//
		//		writeSCCB(0x78482400); //lpx_p_min ns
		//		writeSCCB(0x78482532);
		//		writeSCCB(0x78483000); //lpx_p_min UI
		//
		//		writeSCCB(0x78482600); //hs_prepare_min ns
		//		writeSCCB(0x78482732);
		//		writeSCCB(0x78483100); //hs_prepare_min UI

		//[7]=1 LENC correction enabled, [5]=1 RAW gamma enabled, [2]=1 Black pixel cancellation enabled, [1]=1 White pixel cancellation enabled, [0]=1 Color interpolation enabled
		writeSCCB(0x78500007);
		//[7]=0 Special digital effects, [5]=0 scaling, [2]=0 UV average disabled, [1]=1 Color matrix enabled, [0]=1 Auto white balance enabled
		writeSCCB(0x78500103);

};
