`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.08.2021 18:01:09
// Design Name: 
// Module Name: þþRGB888Mem
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


module RGB888Mem(
input Cclk,
input rstn,

//input  wire Sel,
//input  wire [23 : 0] Sel_RGB    ,

input [3:0] Mem_cont,

output        s_axis_video_tready,
input  [23:0] s_axis_video_tdata ,
input         s_axis_video_tvalid,
input         s_axis_video_tuser ,
input         s_axis_video_tlast ,

//output FraimSync,

input Hclk,

input HVsync  ,
input HMemRead,
input pVDE    ,
output [23:0] HDMIdata
    );

reg  [23:0] Del_tdata ;
reg         Del_tvalid;
reg         Del_tuser ;
reg         Del_tlast ;

always @(posedge Cclk or negedge rstn) 
    if (!rstn) Del_tdata <= 24'h000000;
     else Del_tdata <= s_axis_video_tdata;
always @(posedge Cclk or negedge rstn) 
    if (!rstn) Del_tvalid <= 1'b0;
     else Del_tvalid <= s_axis_video_tvalid;
always @(posedge Cclk or negedge rstn) 
    if (!rstn) Del_tuser <= 1'b0;
     else Del_tuser <= s_axis_video_tuser;
always @(posedge Cclk or negedge rstn) 
    if (!rstn) Del_tlast <= 1'b0;
     else Del_tlast <= s_axis_video_tlast;

//reg [1:0] Del_HMemRead;
//always @(posedge Hclk or negedge rstn)
//    if (!rstn) Del_HMemRead <= 2'b00;
//     else Del_HMemRead <= {Del_HMemRead[0],HMemRead}; 

reg [19:0] Wadd;    
always @(posedge Cclk or negedge rstn) 
    if (!rstn) Wadd <= 20'h00000;
     else if (s_axis_video_tvalid && s_axis_video_tuser) Wadd <= 20'h00000;
     else if (Del_tvalid) Wadd <= Wadd + 1;
reg [3:0] DevHclk;
always @(posedge Cclk or negedge rstn) 
    if (!rstn) DevHclk <= 4'h0;
     else DevHclk <= {DevHclk[2:0],Hclk};    
reg [19:0] Radd;    
always @(posedge Cclk or negedge rstn) 
    if (!rstn) Radd <= 20'h00000;
//     else if (s_axis_video_tvalid && s_axis_video_tuser) Radd <= 20'h00000;
     else if (!HVsync) Radd <= 20'h00000;
     else if (HMemRead && (DevHclk == 4'hc)) Radd <= Radd + 1;
//reg [23:0] Mem [0:307199];
reg [11:0] Mem [0:307199];
//reg [23:0] Mem [0:307];
always @(posedge Cclk)
    if (Del_tvalid) Mem[Wadd] = {s_axis_video_tdata[23:20],s_axis_video_tdata[15:12],s_axis_video_tdata[7:4]};
    
reg [11:0] Reg_mem;
always @(posedge Cclk)
//    if (HMemRead && (DevHclk == 4'hc)) Reg_mem <=  {s_axis_video_tdata[23:20],s_axis_video_tdata[15:12],s_axis_video_tdata[7:4]};
    if (HMemRead && (DevHclk == 4'hc)) Reg_mem <=  Mem[Radd];

assign HDMIdata = {Reg_mem[11:8],4'b1111,Reg_mem[7:4],4'b0111,Reg_mem[3:0],4'b0000};  
 
    /*
//reg Del_Frame;
//always @(posedge Cclk or negedge rstn)
//    if (!rstn) Del_Frame <= 1'b0;
//     else if (s_axis_video_tuser && s_axis_video_tvalid) Del_Frame <= 1'b1;
//     else Del_Frame <= 1'b0;  
reg Del_Last;
always @(posedge Cclk or negedge rstn)
    if (!rstn) Del_Last <= 1'b0;
     else Del_Last <= s_axis_video_tlast;
//reg Frame_odd;
//always @(posedge Cclk or negedge rstn)
//    if (!rstn) Frame_odd <= 1'b0;
//     else if (Del_Frame) Frame_odd <= ~Frame_odd;
reg Line_odd;
always @(posedge Cclk or negedge rstn)
    if (!rstn) Line_odd <= 1'b0;
     else if (s_axis_video_tuser && s_axis_video_tvalid) Line_odd <= Line_odd;
     else if (Del_Last) Line_odd <= ~Line_odd;
reg Valid_odd;
always @(posedge Cclk or negedge rstn)
    if (!rstn) Valid_odd <= 1'b0;
     else if (s_axis_video_tuser && s_axis_video_tvalid)  Valid_odd <=  ~Valid_odd;
     else if (Del_Last)  Valid_odd <=  Valid_odd;
     else if (s_axis_video_tvalid) Valid_odd <= ~Valid_odd;
     
reg [19:0] CWadd;
always @(posedge Cclk or negedge rstn)
    if (!rstn) CWadd <= 20'h00000;
     else if (s_axis_video_tvalid && s_axis_video_tuser && s_axis_video_tready) CWadd <= 20'h00000;
     else if (s_axis_video_tvalid && Valid_odd) CWadd <= CWadd + 1;

reg DelValid;
always @(posedge Cclk or negedge rstn)
    if (!rstn) DelValid <= 1'b0;
     else DelValid <= s_axis_video_tvalid;
//reg [11:0] DelData;
reg [8:0] DelData;
always @(posedge Cclk or negedge rstn)
    if (!rstn) DelData <= 12'h000;
//     else if (s_axis_video_tvalid) DelData <= {s_axis_video_tdata[23:20],s_axis_video_tdata[15:12],s_axis_video_tdata[7:4]};     
     else if (s_axis_video_tvalid) DelData <= {s_axis_video_tdata[23:21],s_axis_video_tdata[15:13],s_axis_video_tdata[7:5]};     

reg [19:0] HRadd;
always @(posedge Hclk or negedge rstn)
    if (!rstn) HRadd <= 20'h00000;
     else if (!HVsync) HRadd <= 20'h00000;
     else if (HMemRead) HRadd <= HRadd + 1;

/////// Memory //////
//reg [8:0] Mem [0:307199];
//reg [11:0] Mem [0:153599];
reg [8:0] Mem [0:153599];
reg [8:0] Reg_mem;
always @(posedge Cclk)
    if (DelValid && Valid_odd) Mem[CWadd] <= DelData;

always @(posedge Hclk)
    Reg_mem <=  Mem[Mem_Read_Add];

//assign HDMIdata = Reg_mem;
assign HDMIdata = {Reg_mem[8:6],1'b1,Reg_mem[5:3],1'b1,Reg_mem[2:0],1'b1};

    */

assign s_axis_video_tready = 1'b1;

endmodule
