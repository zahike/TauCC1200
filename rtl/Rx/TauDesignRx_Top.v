`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2021 08:12:35 AM
// Design Name: 
// Module Name: TauDesignRx_Top
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


module TauDesignRx_Top(
input  sysclk,
input [3:0] btn,

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

  output      hdmi_tx_clk_n   ,
  output      hdmi_tx_clk_p   ,
  output [2:0]hdmi_tx_data_n  ,
  output [2:0]hdmi_tx_data_p  ,
  
//  input  SCLKe,
//  input  MOSIe,
//  output MISOe,
//  input  CS_ne,

//  input  SCLKd,
//  input  MOSId,
//  output MISOd,
//  input  CS_nd,

//  input  SCLKc,
//  input  MOSIc,
//  output MISOc,
//  input  CS_nc,
inout [2:1] jb_p,
inout [2:1] jb_n,

  output SCLKb,
  output MOSIb,
  input  MISOb,
  output CS_nb

  
    );

wire rstn = ~btn[0];    

/////////////////////////////////////////////////////////// 
/////////////// TauDesignRx_BD Block design ///////////////
/////////////////////////////////////////////////////////// 
wire [3:0] GPIO_OutEn;		//output [3:0] GPIO_OutEn_0;
wire [3:0] GPIO_Out;		//output [3:0] GPIO_Out_0;
wire [3:0] GPIO_In;		//input [3:0] GPIO_In_0;

wire  SCLK_1;		//output  SCLK_0;
wire  MOSI_1;		//output  MOSI_0;
wire  MISO_1; 		//input  MISO_0;
wire  CS_n_1;		//output  CS_n_0;
    
TauDesignRx_BD TauDesignRx_BD_inst
(
.sysclk(sysclk),        //input  sysclk
.ext_reset_in(rstn),        //input  ext_reset_in
.CS_n_0(CS_n_0),		//input [3:0] CS_n_0
.CS_n_1(CS_n_1),        //output  CS_n_1
.DDR_addr(DDR_addr),        //inout [14:0] DDR_addr
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
.GPIO_In_0   (GPIO_In),        //input [3:0] GPIO_In_0
.GPIO_OutEn_0(GPIO_OutEn),        //output [3:0] GPIO_OutEn_0
.GPIO_Out_0  (GPIO_Out),        //output [3:0] GPIO_Out_0
.MISO_0(MISO_0),        //output [3:0] MISO_0
.MISO_1(MISO_1),        //input  MISO_1
.MOSI_0(MOSI_0),        //input [3:0] MOSI_0
.MOSI_1(MOSI_1),        //output  MOSI_1
.SCLK_0(SCLK_0),        //input [3:0] SCLK_0
.SCLK_1(SCLK_1),        //output  SCLK_1
.TMDS_Clk_n_0 (hdmi_tx_clk_n ),        //output  TMDS_Clk_n_0
.TMDS_Clk_p_0 (hdmi_tx_clk_p ),        //output  TMDS_Clk_p_0
.TMDS_Data_n_0(hdmi_tx_data_n),        //output [2:0] TMDS_Data_n_0
.TMDS_Data_p_0(hdmi_tx_data_p)        //output [2:0] TMDS_Data_p_0
);
    

assign jb_p[1] = (GPIO_OutEn[0]) ? GPIO_Out[0] : 1'bz;
assign jb_n[1] = (GPIO_OutEn[1]) ? GPIO_Out[1] : 1'bz;
assign jb_p[2] = (GPIO_OutEn[2]) ? GPIO_Out[2] : 1'bz;
assign jb_n[2] = (GPIO_OutEn[3]) ? GPIO_Out[3] : 1'bz;
assign GPIO_In = {jb_n[2],jb_p[2],jb_n[1],jb_p[1]};

assign SCLKb = SCLK_1;
assign MOSIb = MOSI_1;
assign CS_nb = CS_n_1;

assign MISO_1 = MISOb;
    
    
/*
wire [3:0] SCLK;
wire [3:0] MOSI;
wire [3:0] MISO;
wire [3:0] CS_n;
    
TauDesignRx_BD TauDesignRx_BD_inst
(
.sysclk(sysclk),        //input  sysclk
.TMDS_Clk_n_0 (hdmi_tx_clk_n ),		//output  TMDS_Clk_n
.TMDS_Clk_p_0 (hdmi_tx_clk_p ),        //output  TMDS_Clk_p
.TMDS_Data_n_0(hdmi_tx_data_n),        //output [2:0] TMDS_Data_n
.TMDS_Data_p_0(hdmi_tx_data_p),        //output [2:0] TMDS_Data_p

.SCLK_0(SCLK),   //  input  SCLK,
.MOSI_0(MOSI),   //  input  MOSI,
.MISO_0(MISO),   //  output MISO,
.CS_n_0(CS_n)   //  input  CS_n
);    

assign SCLK[0] = SCLKe;         //   input  SCLKe,
assign MOSI[0] = MOSIe;         //   input  MOSIe,
assign MISOe = MISO[0];         //   output MISOe,
assign CS_n[0] = CS_ne;         //   input  CS_ne,
                 // 
assign SCLK[1] = SCLKd;         //   input  SCLKd,
assign MOSI[1] = MOSId;         //   input  MOSId,
assign MISOd = MISO[1];         //   output MISOd,
assign CS_n[1] = CS_nd;         //   input  CS_nd,
                 // 
assign SCLK[2] = SCLKc;         //   input  SCLKc,
assign MOSI[2] = MOSIc;         //   input  MOSIc,
assign MISOc = MISO[2];         //   output MISOc,
assign CS_n[2] = CS_nc;         //   input  CS_nc,
                 
assign SCLK[3] = SCLKb;         //   input  SCLKb,
assign MOSI[3] = MOSIb;         //   input  MOSIb,
assign MISOb = MISO[3];         //   output MISOb,
assign CS_n[3] = CS_nb;         //   input  CS_nb
*/
endmodule
