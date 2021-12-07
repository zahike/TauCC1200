`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2021 07:48:47 AM
// Design Name: 
// Module Name: RxSyncPic
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


module RxSyncPic(
input clk,
input rstn,

output PixelClk,

input HVsync  ,
input HMemRead,
input pVDE    ,
output [23:0] HDMIdata

    );

reg [2:0] Cnt_Div_Clk;
always @(posedge clk or negedge rstn)
    if (!rstn) Cnt_Div_Clk <= 3'b000;
     else if (Cnt_Div_Clk == 3'b100) Cnt_Div_Clk <= 3'b000;
     else Cnt_Div_Clk <= Cnt_Div_Clk + 1;
reg Reg_Div_Clk;
always @(posedge clk or negedge rstn)
    if (!rstn) Reg_Div_Clk <= 1'b0;
     else if (Cnt_Div_Clk == 3'b000)  Reg_Div_Clk <= 1'b1;
     else if (Cnt_Div_Clk == 3'b010)  Reg_Div_Clk <= 1'b0;

   BUFG BUFG_inst (
      .O(PixelClk), // 1-bit output: Clock output
      .I(Reg_Div_Clk)  // 1-bit input: Clock input
   );

reg DelHMemRead;
always @(posedge clk or negedge rstn) 
    if (!rstn) DelHMemRead<= 1'b0;
    else DelHMemRead <= HMemRead;
reg [3:0] Gdata;
always @(posedge clk or negedge rstn)
    if (!rstn) Gdata <= 4'h0;
     else if (!HVsync) Gdata <= 4'h0;
     else if ((Cnt_Div_Clk == 3'b000) && HMemRead) Gdata <= Gdata + 1;
reg [3:0] Bdata;
always @(posedge clk or negedge rstn)
    if (!rstn) Bdata <= 4'h0;
     else if (!HVsync) Bdata <= 4'h0;
     else if (DelHMemRead && !HMemRead) Bdata <= Bdata + 1;
reg [3:0] Rdata;
always @(posedge clk or negedge rstn)
    if (!rstn) Rdata <= 4'hf;
     else if (!HVsync) Rdata <= 4'hf;
     else if ((DelHMemRead && !HMemRead) && (Bdata == 4'hf)) Rdata <= Rdata - 1;

assign HDMIdata = {Rdata,4'h0,Bdata,4'h0,Gdata,4'h0};    
endmodule
