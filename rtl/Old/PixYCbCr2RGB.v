`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.09.2021 22:15:58
// Design Name: 
// Module Name: PixYCbCr2RGB
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


module PixYCbCr2RGB(
input  wire clk ,
input  wire rstn,

input [14:0] YCbCrData,
output [23:0] RGBdata
    );

localparam GYCONST = 256;
localparam BYCONST = 256;
localparam RYCONST = 256;

localparam GCBCONST  = 88;
localparam BCB1CONST = 256;
localparam BCBCONST  = 198;
localparam RCBCONST  = 0;

localparam GCRCONST  = 183;
localparam BCRCONST  = 0;
localparam RCR1CONST = 256;
localparam RCRCONST  = 103;

//localparam GYCONST = 32;
//localparam BYCONST = 32;
//localparam RYCONST = 32;

//localparam GCBCONST  = 11;
//localparam BCB1CONST = 32;
//localparam BCBCONST  = 25;
//localparam RCBCONST  = 0;

//localparam GCRCONST  = 23;
//localparam BCRCONST  = 0;
//localparam RCR1CONST = 32;
//localparam RCRCONST  = 13;

wire signed [8:0] oY  = {1'b0,YCbCrData[ 4: 0],3'b000} - 9'h000;
wire signed [8:0] oCb = {1'b0,YCbCrData[ 9: 5],3'b000} - 9'h080;
wire signed [8:0] oCr = {1'b0,YCbCrData[14:10],3'b000} - 9'h080;

reg signed [16:0] GY  ;
reg signed [16:0] GCb ;
reg signed [16:0] GCr ;

always @(posedge clk or negedge rstn)
    if (!rstn) GY  <= 17'h00000 ;
     else GY  <= GYCONST*oY ;
always @(posedge clk or negedge rstn)
    if (!rstn) GCb <= 17'h00000 ;
     else GCb <= GCBCONST*oCb;
always @(posedge clk or negedge rstn)
    if (!rstn) GCr <= 17'h00000 ;
     else GCr <= GCRCONST*oCr;

reg signed [16:0] BY  ;
reg signed [16:0] BCb ;
reg signed [16:0] BCr ;

always @(posedge clk or negedge rstn)
    if (!rstn) BY  <= 17'h00000 ;
     else BY  <= BYCONST*oY ;
always @(posedge clk or negedge rstn)
    if (!rstn) BCb <= 17'h00000 ;
     else BCb <= BCB1CONST*oCb + BCBCONST*oCb;
always @(posedge clk or negedge rstn)
    if (!rstn) BCr <= 17'h00000 ;
     else BCr <= BCRCONST*oCr;

reg signed [16:0] RY  ;
reg signed [16:0] RCb ;
reg signed [16:0] RCr ;

always @(posedge clk or negedge rstn)
    if (!rstn) RY  <= 17'h00000 ;
     else RY  <= RYCONST*oY ;
always @(posedge clk or negedge rstn)
    if (!rstn) RCb <= 17'h00000 ;
     else RCb <= RCBCONST*oCb;
always @(posedge clk or negedge rstn)
    if (!rstn) RCr <= 17'h00000 ;
     else RCr <= RCR1CONST*oCr + RCRCONST*oCr;

wire signed [16:0] SLongR = RY + RCb + RCr;
wire signed [16:0] SLongG = GY - GCb - GCr;
wire signed [16:0] SLongB = BY + BCb + BCr;

wire [7:0] LongR = (SLongR[16:15] == 2'b10) ? 8'hff : (SLongR[16:15] == 2'b11) ? 8'h00 : SLongR[15:8] ;
wire [7:0] LongG = (SLongG[16:15] == 2'b10) ? 8'hff : (SLongG[16:15] == 2'b11) ? 8'h00 : SLongG[15:8] ;
wire [7:0] LongB = (SLongB[16:15] == 2'b10) ? 8'hff : (SLongB[16:15] == 2'b11) ? 8'h00 : SLongB[15:8] ;


reg [23:0] Reg_RGBdata  ;

always @(posedge clk or negedge rstn)
    if (!rstn) Reg_RGBdata    <= 24'h000000;  
     else Reg_RGBdata  <= {LongR,LongB,LongG};

assign RGBdata = Reg_RGBdata;
    
endmodule
