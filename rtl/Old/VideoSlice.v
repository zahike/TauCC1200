`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.09.2021 11:18:53
// Design Name: 
// Module Name: VideoSlice
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


module VideoSlice(
input  wire clk ,
input  wire rstn,
input  wire [23 : 0] s_axis_video_tdata    ,
output wire          s_axis_video_tready            ,
input  wire          s_axis_video_tvalid            ,
input  wire          s_axis_video_tlast             ,
input  wire          s_axis_video_tuser         ,
output wire [23 : 0] om_axis_video_tdata    ,
output wire          om_axis_video_tvalid            ,
input  wire          om_axis_video_tready            ,
output wire          om_axis_video_tlast             ,
output wire          om_axis_video_tuser             ,
output wire [23 : 0] ym_axis_video_tdata    ,
output wire          ym_axis_video_tvalid            ,
input  wire          ym_axis_video_tready            ,
output wire          ym_axis_video_tlast             ,
output wire          ym_axis_video_tuser             
    );

assign om_axis_video_tdata  = s_axis_video_tdata  ;
assign s_axis_video_tready = ym_axis_video_tready || om_axis_video_tready ;
assign om_axis_video_tvalid = s_axis_video_tvalid ;
assign om_axis_video_tlast  = s_axis_video_tlast  ;
assign om_axis_video_tuser  = s_axis_video_tuser  ;
assign ym_axis_video_tdata  = s_axis_video_tdata  ;
assign ym_axis_video_tvalid = s_axis_video_tvalid ;
assign ym_axis_video_tlast  = s_axis_video_tlast  ;
assign ym_axis_video_tuser  = s_axis_video_tuser  ;
    
endmodule
