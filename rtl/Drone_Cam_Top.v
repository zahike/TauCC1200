`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.08.2021 20:09:36
// Design Name: 
// Module Name: Drone_Cam_Top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Drone_Cam_Top(
// Zync signals
inout [14:0] DDR_addr,
inout [2:0] DDR_ba,
inout  DDR_cas_n,
inout  DDR_ck_n,
inout  DDR_ck_p,
inout  DDR_cke,
inout  DDR_cs_n,
inout [3:0] DDR_dm,
inout [31:0] DDR_dq,
inout [3:0] DDR_dqs_n,
inout [3:0] DDR_dqs_p,
inout  DDR_odt,
inout  DDR_ras_n,
inout  DDR_reset_n,
inout  DDR_we_n,
inout  FIXED_IO_ddr_vrn,
inout  FIXED_IO_ddr_vrp,
inout [53:0] FIXED_IO_mio,
inout  FIXED_IO_ps_clk,
inout  FIXED_IO_ps_porb,
inout  FIXED_IO_ps_srstb,

// MIPI Signal 
input  dphy_clk_lp_n,
input  dphy_clk_lp_p,
input [1:0] dphy_data_hs_n,
input [1:0] dphy_data_hs_p,
input [1:0] dphy_data_lp_n,
input [1:0] dphy_data_lp_p,
input  dphy_hs_clock_clk_n,
input  dphy_hs_clock_clk_p,

output [0:0] cam_gpio_tri_io,
inout cam_iic_scl_io,
inout cam_iic_sda_io,

  output      hdmi_tx_clk_n   ,
  output      hdmi_tx_clk_p   ,
  output [2:0]hdmi_tx_data_n  ,
  output [2:0]hdmi_tx_data_p  ,
  input       sys_clock       ,
  input  [3:0] sw,
  input  [3:0] btn,
  output [3:0] led, //[0] }]; #IO_L23P_T3_35 Sch=led[0]  
  output led5_b,    // }]; #IO_L20P_T3_13 Sch=led5_b
  output led5_g,    // }]; #IO_L19P_T3_13 Sch=led5_g
  output led5_r,    // }]; #IO_L18N_T2_13 Sch=led5_r
  output led6_b,    // }]; #IO_L8P_T1_AD10P_35 Sch=led6_b
  output led6_g,    // }]; #IO_L6N_T0_VREF_35 Sch=led6_g
  output led6_r,    // }]; #IO_L18P_T2_34 Sch=led6_r

output SCLKb,
output MOSIb,
input  MISOb,
output CS_nb,

output SCLKc,
output MOSIc,
input  MISOc,
output CS_nc,

output SCLKd,
output MOSId,
input  MISOd,
output CS_nd,

output SCLKe,
output MOSIe,
input  MISOe,
output CS_ne,

  output [3:0] ja_p,
  output [3:0] ja_n
//  output [4:1] jb_p,
//  output [4:1] jb_n,
//  output [4:1] jc_p,
//  output [4:1] jc_n,
//  inout  [4:1] jd_n,
//  inout  [4:1] jd_p,
//  output [8:1] je
    );


/////////////////////////////////////////////////////////
/////////////////      Drone Cam BD       ///////////////
/////////////////////////////////////////////////////////
//Outputs
wire ILA_clk;
wire rstn;               // output [0:0]rstn;
//wire RxByteClkHS;             // output RxByteClkHS;
wire [0:0] GPIO_0_0_tri_o;		//output [0:0] GPIO_0_0_tri_o;
wire [0:0] GPIO_0_0_tri_t;		//output [0:0] GPIO_0_0_tri_t;
wire IIC_0_0_scl_o;		//output  IIC_0_0_scl_o;
wire IIC_0_0_scl_t;		//output  IIC_0_0_scl_t;
wire IIC_0_0_sda_o;		//output  IIC_0_0_sda_o;
wire IIC_0_0_sda_t;		//output  IIC_0_0_sda_t;

wire GPIO_0;          //  output GPIO_0;
wire sccb_clk_0;      //  output sccb_clk_0;
wire sccb_clk_en_0;   //  output sccb_clk_en_0;
wire sccb_data_en_0;  //  output sccb_data_en_0;
wire sccb_data_out_0; //  output sccb_data_out_0;

//Inputs
wire [0:0] GPIO_0_0_tri_i;		//input [0:0] GPIO_0_0_tri_i;
wire IIC_0_0_scl_i       ;		//input  IIC_0_0_scl_i;
wire IIC_0_0_sda_i       ;		//input  IIC_0_0_sda_i;
wire sccb_data_in_0      ;           //  input sccb_data_in_0;

wire DDS_CSn_0;          //   output DDS_CSn_0;
wire [7:0]DDS_DataIn_0;   //   input [7:0]DDS_DataIn_0;
wire [7:0]DDS_DataOut_0; //   output [7:0]DDS_DataOut_0;
wire DDS_IOup_0;         //   output DDS_IOup_0;
wire DDS_PCLK_0;         //   output DDS_PCLK_0;
wire DDS_RWn_0;          //   output DDS_RWn_0;
wire DDS_ReadEn_0;       //   output DDS_ReadEn_0;
wire DDS_Ref;            //   output DDS_Ref;

wire [5:0]Trans0Data;    // output [5:0]Trans0Data;
wire [5:0]Trans1Data;    // output [5:0]Trans1Data;
wire [5:0]Trans2Data;    // output [5:0]Trans2Data;
wire [5:0]Trans3Data;    // output [5:0]Trans3Data;

wire [1:0]FraimSel;   //  input [1:0]FraimSel;
wire SelHDMI;         //  input SelHDMI;
wire SelStat;         //  input SelStat;

wire [3:0] SCLK;
wire [3:0] MOSI;
wire [3:0] MISO;
wire [3:0] CS_n;
    
Drone_Cam_BD Drone_Cam_BD_inst
(
.DDR_addr(DDR_addr),		//inout [14:0] DDR_addr
.DDR_ba(DDR_ba),        //inout [2:0] DDR_ba
.DDR_cas_n(DDR_cas_n),        //inout  DDR_cas_n
.DDR_ck_n(DDR_ck_n),        //inout  DDR_ck_n
.DDR_ck_p(DDR_ck_p),        //inout  DDR_ck_p
.DDR_cke(DDR_cke),        //inout  DDR_cke
.DDR_cs_n(DDR_cs_n),        //inout  DDR_cs_n
.DDR_dm(DDR_dm),        //inout [3:0] DDR_dm
.DDR_dq(DDR_dq),        //inout [31:0] DDR_dq
.DDR_dqs_n(DDR_dqs_n),        //inout [3:0] DDR_dqs_n
.DDR_dqs_p(DDR_dqs_p),        //inout [3:0] DDR_dqs_p
.DDR_odt(DDR_odt),        //inout  DDR_odt
.DDR_ras_n(DDR_ras_n),        //inout  DDR_ras_n
.DDR_reset_n(DDR_reset_n),        //inout  DDR_reset_n
.DDR_we_n(DDR_we_n),        //inout  DDR_we_n
.FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),        //inout  FIXED_IO_ddr_vrn
.FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),        //inout  FIXED_IO_ddr_vrp
.FIXED_IO_mio(FIXED_IO_mio),        //inout [53:0] FIXED_IO_mio
.FIXED_IO_ps_clk(FIXED_IO_ps_clk),        //inout  FIXED_IO_ps_clk
.FIXED_IO_ps_porb(FIXED_IO_ps_porb),        //inout  FIXED_IO_ps_porb
.FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),        //inout  FIXED_IO_ps_srstb

.sys_clock      (sys_clock),
.FCLK_CLK2_0    (ILA_clk),
.rstn           (rstn),   //output [0:0]rstn;

// Cammera outputs
.dphy_clk_lp_n(dphy_clk_lp_n),        //input  dphy_clk_lp_n
.dphy_clk_lp_p(dphy_clk_lp_p),        //input  dphy_clk_lp_p
.dphy_data_hs_n(dphy_data_hs_n),        //input [1:0] dphy_data_hs_n
.dphy_data_hs_p(dphy_data_hs_p),        //input [1:0] dphy_data_hs_p
.dphy_data_lp_n(dphy_data_lp_n),        //input [1:0] dphy_data_lp_n
.dphy_data_lp_p(dphy_data_lp_p),        //input [1:0] dphy_data_lp_p
.dphy_hs_clock_clk_n(dphy_hs_clock_clk_n),        //input  dphy_hs_clock_clk_n
.dphy_hs_clock_clk_p(dphy_hs_clock_clk_p),        //input  dphy_hs_clock_clk_p
// Cammera SCCB
.GPIO_0         (GPIO_0         ),    //  output GPIO_0;
.sccb_clk_0     (sccb_clk_0     ),    //  output sccb_clk_0;
.sccb_clk_en_0  (sccb_clk_en_0  ),    //  output sccb_clk_en_0;
.sccb_data_en_0 (sccb_data_en_0 ),    //  output sccb_data_en_0;
.sccb_data_in_0 (sccb_data_in_0 ),    //  input sccb_data_in_0;
.sccb_data_out_0(sccb_data_out_0),    //  output sccb_data_out_0;

.Mem_cont       (sw             ),    // input [3:0]Mem_cont;
.FraimSel(FraimSel),        //  input [1:0]FraimSel;
.SelHDMI (SelHDMI ),         //  input SelHDMI;
.SelStat (SelStat ),         //  input SelStat;

.DDS_CSn_0     (DDS_CSn_0    ),      //   output DDS_CSn_0;
.DDS_DataIn_0  (DDS_DataIn_0 ),      //   input [7:0]DDS_DataIn_0;
.DDS_DataOut_0 (DDS_DataOut_0),      //   output [7:0]DDS_DataOut_0;
.DDS_IOup_0    (DDS_IOup_0   ),      //   output DDS_IOup_0;
.DDS_PCLK_0    (DDS_PCLK_0   ),      //   output DDS_PCLK_0;
.DDS_RWn_0     (DDS_RWn_0    ),      //   output DDS_RWn_0;
.DDS_ReadEn_0  (DDS_ReadEn_0 ),      //   output DDS_ReadEn_0;
.DDS_Ref       (DDS_Ref      ),      //   output DDS_Ref;

.TMDS_Clk_n_0 (hdmi_tx_clk_n ),   //   output TMDS_Clk_n_0;
.TMDS_Clk_p_0 (hdmi_tx_clk_p ),   //   output TMDS_Clk_p_0;
.TMDS_Data_n_0(hdmi_tx_data_n),   //   output [2:0]TMDS_Data_n_0;
.TMDS_Data_p_0(hdmi_tx_data_p),   //   output [2:0]TMDS_Data_p_0;

.SCLK_0(SCLK),
.MOSI_0(MOSI),
.MISO_0(MISO),
.CS_n_0(CS_n),
 
.Trans0Data    (Trans0Data),  //  output [5:0]Trans0Data;
.Trans1Data    (Trans1Data),  //  output [5:0]Trans1Data;
.Trans2Data    (Trans2Data),  //  output [5:0]Trans2Data;
.Trans3Data    (Trans3Data)   //  output [5:0]Trans3Data;

  );

assign cam_gpio_tri_io = GPIO_0; 
assign cam_iic_scl_io  = (sccb_clk_en_0) ? sccb_clk_0 : 1'b1;
assign cam_iic_sda_io = (~sccb_data_en_0) ? sccb_data_out_0 : 1'bz;
assign sccb_data_in_0 = cam_iic_sda_io;

reg [3:0] Devbtn [1:0];
always @(posedge ILA_clk or negedge rstn)  
    if (!rstn) begin
           Devbtn[0] <= 4'h0; 
           Devbtn[1] <= 4'h0; 
                end
     else begin 
           Devbtn[0] <= btn; 
           Devbtn[1] <= Devbtn[0];
            end                
reg [19:0] debuncer;
always @(posedge ILA_clk or negedge rstn)
    if (!rstn) debuncer <= 20'hFFFFF;
     else if (Devbtn[1] != Devbtn[0]) debuncer <= 20'h00000;
     else if (debuncer == 20'hFFFFF) debuncer <= 20'hFFFFF;
     else debuncer <= debuncer + 1;

reg [1:0] FraimSelCount;
always @(posedge ILA_clk or negedge rstn)
    if (!rstn) FraimSelCount <= 2'b00;
     else if (debuncer != 20'hFFFFF) FraimSelCount <= FraimSelCount;
     else if (Devbtn[0][0] && ~Devbtn[0][1]) FraimSelCount <= FraimSelCount + 1;   
assign FraimSel = FraimSelCount;   //  input [1:0]FraimSel;
reg  SelHDMICount;
always @(posedge ILA_clk or negedge rstn)
    if (!rstn) SelHDMICount <= 1'b0;
     else if (debuncer != 20'hFFFFF) SelHDMICount <= SelHDMICount;
     else if (Devbtn[0][2] && ~Devbtn[1][2]) SelHDMICount <= SelHDMICount + 1;   
assign SelHDMI = SelHDMICount;   //  input [1:0]FraimSel;
reg  SelStatCount;
always @(posedge ILA_clk or negedge rstn)
    if (!rstn) SelStatCount <= 1'b0;
     else if (debuncer != 20'hFFFFF) SelStatCount <= SelStatCount;
     else if (Devbtn[0][3] && ~Devbtn[1][3]) SelStatCount <= SelStatCount + 1;   
assign SelStat = SelStatCount;   //  input [1:0]FraimSel;

assign led[0] = FraimSelCount[0]; //[0] }]; #IO_L23P_T3_35 Sch=led[0]  
assign led[1] = FraimSelCount[1]; //[0] }]; #IO_L23P_T3_35 Sch=led[0]  
assign led[2] = SelHDMICount; //[0] }]; #IO_L23P_T3_35 Sch=led[0]  
assign led[3] = SelStatCount; //[0] }]; #IO_L23P_T3_35 Sch=led[0]  

     
/*
 assign je[8] = DDS_Ref;
 assign jc_p[3] = (btn[0]) ? 1'b1 : ~rstn; // reset
 assign jc_n[1] = 1'b0;  // PowerDown
 assign jc_n[3] = DDS_IOup_0;  // IO_update
 assign jc_p[2] = DDS_CSn_0;  // CSB
 assign jc_p[4] = DDS_RWn_0;  // RWn
 assign jc_n[2] = DDS_PCLK_0;  // PCLK
 assign jc_n[4] = 1'b1;  // PAR
 assign jd_p[1] = (!DDS_ReadEn_0) ? DDS_DataOut_0[7] : 1'bz;   
 assign jd_p[3] = (!DDS_ReadEn_0) ? DDS_DataOut_0[6] : 1'bz;   
 assign jd_n[1] = (!DDS_ReadEn_0) ? DDS_DataOut_0[5] : 1'bz;   
 assign jd_n[3] = (!DDS_ReadEn_0) ? DDS_DataOut_0[4] : 1'bz;   
 assign jd_p[2] = (!DDS_ReadEn_0) ? DDS_DataOut_0[3] : 1'bz;   
 assign jd_p[4] = (!DDS_ReadEn_0) ? DDS_DataOut_0[2] : 1'bz;   
 assign jd_n[2] = (!DDS_ReadEn_0) ? DDS_DataOut_0[1] : 1'bz;   
 assign jd_n[4] = (!DDS_ReadEn_0) ? DDS_DataOut_0[0] : 1'bz;   

 assign DDS_DataIn_0[7] = jd_p[1];
 assign DDS_DataIn_0[6] = jd_p[3];
 assign DDS_DataIn_0[5] = jd_n[1];
 assign DDS_DataIn_0[4] = jd_n[3];
 assign DDS_DataIn_0[3] = jd_p[2];
 assign DDS_DataIn_0[2] = jd_p[4];
 assign DDS_DataIn_0[1] = jd_n[2];
 assign DDS_DataIn_0[0] = jd_n[4];
 */

assign SCLKb = SCLK[0];
assign MOSIb = MOSI[0];
assign MISO[0] = MISOb;
assign CS_nb = CS_n[0];

assign SCLKc = SCLK[1];
assign MOSIc = MOSI[1];
assign MISO[1] = MISOc;
assign CS_nc = CS_n[1];

assign SCLKd = SCLK[2];
assign MOSId = MOSI[2];
assign MISO[2] = MISOd;
assign CS_nd = CS_n[2];

assign SCLKe = SCLK[3];
assign MOSIe = MOSI[3];
assign MISO[3] = MISOe;
assign CS_ne = CS_n[3];


//assign jb_p[1] = Trans0Data[0];
//assign jb_n[1] = Trans0Data[1];
//assign jb_p[2] = Trans0Data[2];
//assign jb_n[2] = Trans0Data[3];
//assign jb_p[3] = Trans0Data[4];
//assign jb_n[3] = Trans0Data[5];
//assign jb_p[4] = 1'b0;
//assign jb_n[4] = 1'b0;

//assign jc_n[1] = Trans1Data[0];
//assign jc_p[1] = Trans1Data[1];
//assign jc_n[2] = Trans1Data[2];
//assign jc_p[2] = Trans1Data[3];
//assign jc_n[3] = Trans1Data[4];
//assign jc_p[3] = Trans1Data[5];
//assign jc_n[4] = 1'b0;
//assign jc_p[4] = 1'b0;

//assign jd_p[1] = Trans2Data[0];
//assign jd_n[1] = Trans2Data[1];
//assign jd_p[2] = Trans2Data[2];
//assign jd_n[2] = Trans2Data[3];
//assign jd_p[3] = Trans2Data[4];
//assign jd_n[3] = Trans2Data[5];
//assign jd_p[4] = 1'b0;
//assign jd_n[4] = 1'b0;

//assign je  [1] = Trans3Data[0];
//assign je  [2] = Trans3Data[1];
//assign je  [3] = Trans3Data[2];
//assign je  [4] = Trans3Data[3];
//assign je  [5] = Trans3Data[4];
//assign je  [6] = Trans3Data[5];
//assign je  [7] = 1'b0;
//assign je  [8] = 1'b0;
 
 
endmodule
