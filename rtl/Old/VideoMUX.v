`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.09.2021 11:11:16
// Design Name: 
// Module Name: VideoMUX
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


module VideoMUX(
input  wire clk ,
input  wire rstn,
input  wire Sel,
input  wire [23 : 0] os_axis_video_tdata    ,
output wire          os_axis_video_tready            ,
input  wire          os_axis_video_tvalid            ,
input  wire          os_axis_video_tlast             ,
input  wire          os_axis_video_tuser             ,
input  wire [23 : 0] ys_axis_video_tdata    ,
output wire          ys_axis_video_tready            ,
input  wire          ys_axis_video_tvalid            ,
input  wire          ys_axis_video_tlast             ,
input  wire          ys_axis_video_tuser             ,
output wire [23 : 0] m_axis_video_tdata    ,
output wire m_axis_video_tvalid            ,
input  wire m_axis_video_tready            ,
output wire m_axis_video_tlast             ,
output wire m_axis_video_tuser       

    );
    
assign m_axis_video_tdata  = (Sel) ? ys_axis_video_tdata  : os_axis_video_tdata ;
assign m_axis_video_tvalid = (Sel) ? ys_axis_video_tvalid : os_axis_video_tvalid  ;
assign m_axis_video_tlast  = (Sel) ? ys_axis_video_tlast  : os_axis_video_tlast   ;
assign m_axis_video_tuser  = (Sel) ? ys_axis_video_tuser  : os_axis_video_tuser   ;

assign os_axis_video_tready = m_axis_video_tready;
assign ys_axis_video_tready = m_axis_video_tready;

    
endmodule
