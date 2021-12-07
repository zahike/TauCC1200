`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.11.2021 09:09:19
// Design Name: 
// Module Name: CC1200SPI_Regs
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


module CC1200SPI_Regs(
input  clk,
input  rstn,

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
output [3:0]  WR,
output [15:0] ClockDiv,
output [3:0]  GPIO_OutEn, 
output [3:0]  GPIO_Out,
input  [3:0]  GPIO_In
    );

reg        RegStart   ;
always @(posedge clk or negedge rstn)
    if (!rstn) RegStart <= 1'b0;
     else if (Start) RegStart <= 1'b0;
     else if (APB_S_0_penable && APB_S_0_psel && APB_S_0_pwrite && (APB_S_0_paddr[7:0] == 8'h00)) RegStart <= 1'b1;
assign Start = RegStart;
reg [31:0] RegDataOut ;
always @(posedge clk or negedge rstn)
    if (!rstn) RegDataOut <= 32'h00000000;
     else if (APB_S_0_penable && APB_S_0_psel && APB_S_0_pwrite && (APB_S_0_paddr[7:0] == 8'h08)) RegDataOut <= APB_S_0_pwdata;
assign DataOut = RegDataOut;
reg [3:0] RegWR;
always @(posedge clk or negedge rstn)
    if (!rstn) RegWR <= 16'h0000;
     else if (APB_S_0_penable && APB_S_0_psel && APB_S_0_pwrite && (APB_S_0_paddr[7:0] == 8'h10)) RegWR <= APB_S_0_pwdata[3:0];
assign WR = RegWR;
reg [15:0] RegClockDiv;
always @(posedge clk or negedge rstn)
    if (!rstn) RegClockDiv <= 16'h0000;
     else if (APB_S_0_penable && APB_S_0_psel && APB_S_0_pwrite && (APB_S_0_paddr[7:0] == 8'h14)) RegClockDiv <= APB_S_0_pwdata[15:0];
assign ClockDiv = RegClockDiv;
reg [3:0] RegGPIO_OutEn;
always @(posedge clk or negedge rstn)
    if (!rstn) RegGPIO_OutEn <= 16'h0000;
     else if (APB_S_0_penable && APB_S_0_psel && APB_S_0_pwrite && (APB_S_0_paddr[7:0] == 8'h18)) RegGPIO_OutEn <= APB_S_0_pwdata[3:0];
assign GPIO_OutEn = RegGPIO_OutEn;
reg [3:0] RegGPIO_Out;
always @(posedge clk or negedge rstn)
    if (!rstn) RegGPIO_Out <= 16'h0000;
     else if (APB_S_0_penable && APB_S_0_psel && APB_S_0_pwrite && (APB_S_0_paddr[7:0] == 8'h1c)) RegGPIO_Out <= APB_S_0_pwdata[3:0];
assign GPIO_Out = RegGPIO_Out;


assign APB_S_0_prdata = (APB_S_0_paddr[7:0] == 8'h00) ? {31'h00000000,RegStart}     :
                        (APB_S_0_paddr[7:0] == 8'h04) ? {31'h00000000,Busy}         :
                        (APB_S_0_paddr[7:0] == 8'h08) ? RegDataOut                  :
                        (APB_S_0_paddr[7:0] == 8'h0c) ? DataIn                      :
                        (APB_S_0_paddr[7:0] == 8'h10) ? {28'h0000000,RegWR}         : 
                        (APB_S_0_paddr[7:0] == 8'h14) ? {16'h0000,RegClockDiv}      : 
                        (APB_S_0_paddr[7:0] == 8'h18) ? {28'h0000000,RegGPIO_OutEn} : 
                        (APB_S_0_paddr[7:0] == 8'h1c) ? {28'h0000000,RegGPIO_Out}   : 
                        (APB_S_0_paddr[7:0] == 8'h20) ? {28'h0000000,GPIO_In}       : 
                        32'h00000000;

reg Reg_pready;
always @(posedge clk or negedge rstn)
    if (!rstn) Reg_pready <= 1'b0;
     else if (APB_S_0_penable && APB_S_0_psel) Reg_pready <= 1'b1;
     else Reg_pready <= 1'b0;

assign APB_S_0_pready = Reg_pready;

assign  APB_S_0_pslverr = 1'b0;  
endmodule
