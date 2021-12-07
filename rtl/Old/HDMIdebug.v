`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.08.2021 14:07:48
// Design Name: 
// Module Name: HDMIdebug
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


module HDMIdebug(
input Txclk,
input Rxclk,
input rstn,
output PixelClk,

input SelHDMI,

output [23:0] Out_pData ,
output        Out_pVSync,
output        Out_pHSync,
output        Out_pVDE  ,

output        Mem_Read,

input         TxFraimSync,
input  [23:0] TxMem_Data ,

input         RxFraimSync,
input  [23:0] RxMem_Data

    );
wire clk;
   BUFGMUX_CTRL BUFGMUX_CTRL_inst (
      .O(clk),   // 1-bit output: Clock output
      .I0(Txclk), // 1-bit input: Clock input (S=0)
      .I1(Rxclk), // 1-bit input: Clock input (S=1)
      .S(SelHDMI)    // 1-bit input: Clock select
   );
assign PixelClk = clk;

wire        FraimSync = (SelHDMI) ? RxFraimSync : TxFraimSync ;
wire [23:0] Mem_Data  = (SelHDMI) ? RxMem_Data  : TxMem_Data  ;

reg [31:0] Vsync_counter;
reg [15:0] Hsync_counter;
reg [15:0] Line_counter;
reg        Reg_VSync;
reg        Reg_HSync;
reg        activeData;
reg        Reg_pVDE;
reg        Reg_MemRead;

///////////////////////////////////////////////////////
/////////////// HDMI control Signals //////////////////
///////////////////////////////////////////////////////
always @(posedge clk or negedge rstn) 
    if (!rstn) Vsync_counter <= 32'd419999;
     else if (Vsync_counter == 32'd419999) Vsync_counter <= 32'h00000000;
     else Vsync_counter <= Vsync_counter + 1;
always @(posedge clk or negedge rstn) 
    if (!rstn) Reg_VSync <= 1'b1;
     else if (Vsync_counter == 32'd419999) Reg_VSync <= 1'b0;
     else if (Vsync_counter == 32'd1599) Reg_VSync <= 1'b1;
	 
always @(posedge clk or negedge rstn) 
    if (!rstn) Hsync_counter <= 16'd799;
     else if (Vsync_counter == 32'd419999) Hsync_counter <= 16'h0000;
     else if (Hsync_counter == 16'd799) Hsync_counter <= 16'h0000;
     else Hsync_counter <= Hsync_counter + 1;
always @(posedge clk or negedge rstn) 
    if (!rstn) Reg_HSync <= 1'b1;
     else if (Hsync_counter == 16'd799) Reg_HSync <= 1'b0;
     else if (Hsync_counter == 16'd95) Reg_HSync <= 1'b1;

always @(posedge clk or negedge rstn) 
    if (!rstn) Line_counter <= 16'h0000;
     else if (Vsync_counter == 32'h00000000) Line_counter <= 16'h0000;
     else if (Hsync_counter == 16'h0000) Line_counter <= Line_counter + 1;

always @(posedge clk or negedge rstn) 
    if (!rstn) activeData <= 1'b0;
     else if (Reg_HSync && (Line_counter == 16'd35)) activeData <= 1'b1;
     else if (Reg_HSync && (Line_counter == 16'd515)) activeData <= 1'b0;

always @(posedge clk or negedge rstn) 
    if (!rstn) Reg_pVDE <= 1'b0;
     else if (activeData && (Hsync_counter == 16'd143)) Reg_pVDE <= 1'b1;
     else if (activeData && (Hsync_counter == 16'd783)) Reg_pVDE <= 1'b0;
/////////////// END HDMI control Signals //////////////////

always @(posedge clk or negedge rstn) 
    if (!rstn) Reg_MemRead <= 1'b0;
     else if (activeData && (Hsync_counter == 16'd143)) Reg_MemRead <= 1'b1;
     else if (activeData && (Hsync_counter == 16'd783)) Reg_MemRead <= 1'b0;

reg [19:0] Reg_Read_Men_add;
always @(posedge clk or negedge rstn)
    if (!rstn) Reg_Read_Men_add <= 20'h00000;
     else if (!Reg_VSync) Reg_Read_Men_add <= 20'h00000;
     else if (Reg_pVDE) Reg_Read_Men_add <= Reg_Read_Men_add + 1;

reg Line_odd;
always @(posedge clk or negedge rstn)
    if (!rstn) Line_odd <= 1'b0;
     else if (Vsync_counter == 32'h00000000) Line_odd <= FraimSync;    
     else if ((Hsync_counter == 16'd783) && activeData) Line_odd <= ~Line_odd;    
     
wire [23:0] Inc_Mem_Data;
assign Inc_Mem_Data  [7:0] = (Mem_Data  [7:4] != 4'h0) ? {Mem_Data  [7:3],3'b111} : Mem_Data  [7:0];
assign Inc_Mem_Data [15:8] = (Mem_Data[15:12] != 4'h0) ? {Mem_Data[15:11],3'b111} : Mem_Data [15:8];
assign Inc_Mem_Data[23:16] = (Mem_Data[23:20] != 4'h0) ? {Mem_Data[23:19],3'b111} : Mem_Data[23:16];
   
assign Out_pData  =  (Reg_pVDE && (Reg_Read_Men_add[0] == Line_odd)) ? Inc_Mem_Data : 24'h000000 ;                
assign Out_pVSync =  Reg_VSync ;
assign Out_pHSync =  Reg_HSync ;
assign Out_pVDE   =  Reg_pVDE  ;

assign Mem_Read = Reg_MemRead;


endmodule
