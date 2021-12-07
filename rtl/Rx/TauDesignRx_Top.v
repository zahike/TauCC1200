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

  output      hdmi_tx_clk_n   ,
  output      hdmi_tx_clk_p   ,
  output [2:0]hdmi_tx_data_n  ,
  output [2:0]hdmi_tx_data_p  ,
  
  input  SCLKe,
  input  MOSIe,
  output MISOe,
  input  CS_ne,

  input  SCLKd,
  input  MOSId,
  output MISOd,
  input  CS_nd,

  input  SCLKc,
  input  MOSIc,
  output MISOc,
  input  CS_nc,

  input  SCLKb,
  input  MOSIb,
  output MISOb,
  input  CS_nb
  
    );

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
                 // 
assign SCLK[3] = SCLKb;         //   input  SCLKb,
assign MOSI[3] = MOSIb;         //   input  MOSIb,
assign MISOb = MISO[3];         //   output MISOb,
assign CS_n[3] = CS_nb;         //   input  CS_nb

endmodule
