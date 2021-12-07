`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.08.2021 11:22:31
// Design Name: 
// Module Name: GammDebug
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


module GammDebug(
input clk,
input rstn,

output        s_axis_video_tready,
//input  [23:0] s_axis_video_tdata ,
input  [31:0] s_axis_video_tdata ,
input         s_axis_video_tvalid,
input         s_axis_video_tuser ,
input         s_axis_video_tlast ,

input          m_axis_video_tready,
output  [23:0] m_axis_video_tdata ,
output         m_axis_video_tvalid,
output         m_axis_video_tuser ,
output         m_axis_video_tlast ,

output         tuser ,
output         tlast ,
output         Orjtuser ,
output         Orjtlast ,
output         Orjtvalid ,

output [23:0] tuser_count ,
output [15:0] tlast_count ,
output [15:0] Num_valid,
output [15:0] Line
    );
    
assign   s_axis_video_tready = m_axis_video_tready;
//assign   m_axis_video_tdata  = s_axis_video_tdata ;
assign   m_axis_video_tdata  = {s_axis_video_tdata[29:22],s_axis_video_tdata[19:12],s_axis_video_tdata[9:2]} ;
assign   m_axis_video_tvalid = s_axis_video_tvalid;
assign   m_axis_video_tuser  = s_axis_video_tuser ;
assign   m_axis_video_tlast  = s_axis_video_tlast ;

reg [1:0] Devtuser;
always @(posedge clk or negedge rstn)
    if (!rstn) Devtuser <= 2'b00;
     else Devtuser <= {Devtuser[0],s_axis_video_tuser};
reg [1:0] Devtlast;
always @(posedge clk or negedge rstn)
    if (!rstn) Devtlast <= 2'b00;
     else Devtlast <= {Devtlast[0],m_axis_video_tlast};

reg Reg_tuser;
always @(posedge clk or negedge rstn)
    if (!rstn) Reg_tuser <= 1'b0;
     else if (Devtuser == 2'b01) Reg_tuser <= ~Reg_tuser;
reg Reg_tlast;
always @(posedge clk or negedge rstn)
    if (!rstn) Reg_tlast <= 1'b0;
     else if (Devtlast == 2'b01) Reg_tlast <= ~Reg_tlast;

reg [23:0] Count_tuser;
always @(posedge clk or negedge rstn)
    if (!rstn) Count_tuser <= 24'h000000;
     else if (Devtuser == 2'b01) Count_tuser <= 24'h000000;
     else Count_tuser <= Count_tuser + 1; 
reg [15:0] Count_tlast;
always @(posedge clk or negedge rstn)
    if (!rstn) Count_tlast <= 16'h0000;
     else if (Devtlast == 2'b01) Count_tlast <= 16'h0000;
     else Count_tlast <= Count_tlast + 1; 
reg [15:0] Count_valid;
always @(posedge clk or negedge rstn)
    if (!rstn) Count_valid <= 16'h0000;
     else if (Devtlast == 2'b01) Count_valid <= 16'h0000;
     else if (s_axis_video_tvalid) Count_valid <= Count_valid + 1; 

reg [15:0] Count_Line;
always @(posedge clk or negedge rstn)
    if (!rstn) Count_Line <= 16'h0000;
     else if (Devtuser == 2'b01) Count_Line <= 16'h0000;
     else if (Devtlast == 2'b01) Count_Line <= Count_Line + 1; 


assign tuser = Reg_tuser;
assign tlast = Reg_tlast;
assign Orjtuser = s_axis_video_tuser ; 
assign Orjtlast = s_axis_video_tlast ; 
assign Orjtvalid = s_axis_video_tvalid ; 
assign tuser_count = Count_tuser;
assign tlast_count = Count_tlast;
assign Num_valid = Count_valid;
assign Line = Count_Line;

endmodule
