`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.11.2021 16:08:43
// Design Name: 
// Module Name: SyntPic
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


module SyntPic(
input  wire clk ,
input  wire rstn,

input  wire SelStat,

input  wire [31 : 0] s_axis_video_tdata ,
output wire s_axis_video_tready            ,
input  wire s_axis_video_tvalid            ,
input  wire s_axis_video_tlast             ,
input  wire s_axis_video_tuser         ,
output wire [31 : 0] m_axis_video_tdata    ,
output wire m_axis_video_tvalid            ,
input  wire m_axis_video_tready            ,
output wire m_axis_video_tlast             ,
output wire m_axis_video_tuser       
    );
reg [4:0] Gdata;
always @(posedge clk or negedge rstn)
    if (!rstn) Gdata <= 5'h00;
     else if (s_axis_video_tuser) Gdata <= 5'h00;
     else if (s_axis_video_tvalid) Gdata <= Gdata + 1;
reg [4:0] Bdata;
always @(posedge clk or negedge rstn)
    if (!rstn) Bdata <= 5'h00;
     else if (s_axis_video_tuser) Bdata <= 5'h00;
     else if (s_axis_video_tlast) Bdata <= Bdata + 1;
reg [4:0] Rdata;
always @(posedge clk or negedge rstn)
    if (!rstn) Rdata <= 5'h1f;
     else if (s_axis_video_tuser) Rdata <= 5'h1f;
     else if (s_axis_video_tlast && (Bdata == 5'h1f)) Rdata <= Rdata - 1;

assign m_axis_video_tdata   = (SelStat) ? {2'b00,Rdata,5'h00,Bdata,5'h00,Gdata,5'h00} : s_axis_video_tdata; 
assign m_axis_video_tvalid  =  s_axis_video_tvalid     ;
assign m_axis_video_tlast   =  s_axis_video_tlast      ;
assign m_axis_video_tuser   =  s_axis_video_tuser      ;
         
assign s_axis_video_tready  = m_axis_video_tready;
         
endmodule
