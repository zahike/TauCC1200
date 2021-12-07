`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/12/2021 08:48:22 AM
// Design Name: 
// Module Name: DDS_Regs
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


module DDS_Regs(
input         APB_0_axiclk,
input         APB_0_aresetn,

input  [31:0] APB_S_0_paddr,
input         APB_S_0_penable,
output [31:0] APB_S_0_prdata,
output        APB_S_0_pready,
input         APB_S_0_psel,
output        APB_S_0_pslverr,
input  [31:0] APB_S_0_pwdata,
input         APB_S_0_pwrite,

output        Start,
input         Busy,
output [31:0] DataOut,
input  [31:0] DataIn,
output        WR,
output        Send
    );

reg        RegStart   ;
always @(posedge APB_0_axiclk or negedge APB_0_aresetn)
    if (!APB_0_aresetn) RegStart <= 1'b0;
     else if (Start) RegStart <= 1'b0;
     else if (APB_S_0_penable && APB_S_0_psel && APB_S_0_pwrite && (APB_S_0_paddr[7:0] == 8'h00)) RegStart <= 1'b1;
assign Start = RegStart;
reg [31:0] RegDataOut ;
always @(posedge APB_0_axiclk or negedge APB_0_aresetn)
    if (!APB_0_aresetn) RegDataOut <= 32'h00000000;
     else if (APB_S_0_penable && APB_S_0_psel && APB_S_0_pwrite && (APB_S_0_paddr[7:0] == 8'h08)) RegDataOut <= APB_S_0_pwdata;
assign DataOut = RegDataOut;
reg  RegWR;
always @(posedge APB_0_axiclk or negedge APB_0_aresetn)
    if (!APB_0_aresetn) RegWR <= 1'b0;
     else if (APB_S_0_penable && APB_S_0_psel && APB_S_0_pwrite && (APB_S_0_paddr[7:0] == 8'h10)) RegWR <= APB_S_0_pwdata[0:0];
assign WR = RegWR;
reg  RegSend;
always @(posedge APB_0_axiclk or negedge APB_0_aresetn)
    if (!APB_0_aresetn) RegSend <= 1'b0;
     else if (APB_S_0_penable && APB_S_0_psel && APB_S_0_pwrite && (APB_S_0_paddr[7:0] == 8'h10)) RegSend <= APB_S_0_pwdata[1:1];
assign Send = RegSend;

assign APB_S_0_prdata = (APB_S_0_paddr[7:0] == 8'h00) ? {31'h00000000,RegStart}      :
                        (APB_S_0_paddr[7:0] == 8'h04) ? {31'h00000000,Busy}          :
                        (APB_S_0_paddr[7:0] == 8'h08) ? RegDataOut                   :
                        (APB_S_0_paddr[7:0] == 8'h0c) ? DataIn                       :
                        (APB_S_0_paddr[7:0] == 8'h10) ? {30'h00000000,RegSend,RegWR} : 32'h00000000;
    
reg Reg_pready;
always @(posedge APB_0_axiclk or negedge APB_0_aresetn)
    if (!APB_0_aresetn) Reg_pready <= 1'b0;
     else if (APB_S_0_penable && APB_S_0_psel) Reg_pready <= 1'b1;
     else Reg_pready <= 1'b0;

assign APB_S_0_pready = Reg_pready;

assign  APB_S_0_pslverr = 1'b0;  
endmodule
