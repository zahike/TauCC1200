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
input  [3:0]  GPIO_In,
output [7:0] Tx_Pkt_size,
output [7:0] Rx_Pkt_size,
output [15:0] Tx_wait,
output [7:0]  CorThre,
input  signed [7:0] RFpow,

output Trans,
output Receive
    );

reg        RegStart   ;
always @(posedge clk or negedge rstn)
    if (!rstn) RegStart <= 1'b0;
     else if (Start) RegStart <= 1'b0;
     else if (APB_S_0_penable && APB_S_0_psel && APB_S_0_pwrite && (APB_S_0_paddr[7:0] == 8'h00)) RegStart <= APB_S_0_pwdata[0];
assign Start = RegStart;
reg        RegTrans   ;
always @(posedge clk or negedge rstn)
    if (!rstn) RegTrans <= 1'b0;
     else if (APB_S_0_penable && APB_S_0_psel && APB_S_0_pwrite && (APB_S_0_paddr[7:0] == 8'h00)) RegTrans <= APB_S_0_pwdata[1];
assign Trans = RegTrans;
reg        RegReceive   ;
always @(posedge clk or negedge rstn)
    if (!rstn) RegReceive <= 1'b0;
     else if (APB_S_0_penable && APB_S_0_psel && APB_S_0_pwrite && (APB_S_0_paddr[7:0] == 8'h00)) RegReceive <= APB_S_0_pwdata[2];
assign Receive = RegReceive;
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

reg [7:0] Reg_Tx_Pkt_size;
always @(posedge clk or negedge rstn)
    if (!rstn) Reg_Tx_Pkt_size <= 8'h00;
     else if (APB_S_0_penable && APB_S_0_psel && APB_S_0_pwrite && (APB_S_0_paddr[7:0] == 8'h24)) Reg_Tx_Pkt_size <= APB_S_0_pwdata[7:0];
assign Tx_Pkt_size = Reg_Tx_Pkt_size;
reg [7:0] Reg_Rx_Pkt_size;
always @(posedge clk or negedge rstn)
    if (!rstn) Reg_Rx_Pkt_size <= 8'h00;
     else if (APB_S_0_penable && APB_S_0_psel && APB_S_0_pwrite && (APB_S_0_paddr[7:0] == 8'h28)) Reg_Rx_Pkt_size <= APB_S_0_pwdata[7:0];
assign Rx_Pkt_size = Reg_Rx_Pkt_size;
reg [7:0] Reg_Tx_wait;
always @(posedge clk or negedge rstn)
    if (!rstn) Reg_Tx_wait <= 16'h0000;
     else if (APB_S_0_penable && APB_S_0_psel && APB_S_0_pwrite && (APB_S_0_paddr[7:0] == 8'h2c)) Reg_Tx_wait <= APB_S_0_pwdata[7:0];
assign Tx_wait = Reg_Tx_wait;
reg [7:0] Reg_CorThre;
always @(posedge clk or negedge rstn)
    if (!rstn) Reg_CorThre <= 16'h0000;
     else if (APB_S_0_penable && APB_S_0_psel && APB_S_0_pwrite && (APB_S_0_paddr[7:0] == 8'h30)) Reg_CorThre <= APB_S_0_pwdata[7:0];
assign CorThre = Reg_CorThre;

//output [7:0]  CorThre,

assign APB_S_0_prdata = (APB_S_0_paddr[7:0] == 8'h00) ? {29'h00000000,RegReceive,RegTrans,RegStart} :
                        (APB_S_0_paddr[7:0] == 8'h04) ? {31'h00000000,Busy}              :
                        (APB_S_0_paddr[7:0] == 8'h08) ? RegDataOut                       :
                        (APB_S_0_paddr[7:0] == 8'h0c) ? DataIn                           :
                        (APB_S_0_paddr[7:0] == 8'h10) ? {28'h0000000,RegWR}              : 
                        (APB_S_0_paddr[7:0] == 8'h14) ? {16'h0000,RegClockDiv}           : 
                        (APB_S_0_paddr[7:0] == 8'h18) ? {28'h0000000,RegGPIO_OutEn}      : 
                        (APB_S_0_paddr[7:0] == 8'h1c) ? {28'h0000000,RegGPIO_Out}        : 
                        (APB_S_0_paddr[7:0] == 8'h20) ? {28'h0000000,GPIO_In}            : 
                        (APB_S_0_paddr[7:0] == 8'h24) ? {24'h000000,Reg_Tx_Pkt_size}     : 
                        (APB_S_0_paddr[7:0] == 8'h28) ? {24'h000000,Reg_Rx_Pkt_size}     : 
                        (APB_S_0_paddr[7:0] == 8'h2c) ? {16'h0000,Reg_Tx_wait}           : 
                        (APB_S_0_paddr[7:0] == 8'h30) ? {24'h000000,Reg_CorThre}         : 
                        (APB_S_0_paddr[7:0] == 8'h34) ? {{24{RFpow[7]}},RFpow}           : 
                        32'h00000000;

reg Reg_pready;
always @(posedge clk or negedge rstn)
    if (!rstn) Reg_pready <= 1'b0;
     else if (APB_S_0_penable && APB_S_0_psel) Reg_pready <= 1'b1;
     else Reg_pready <= 1'b0;

assign APB_S_0_pready = Reg_pready;

assign  APB_S_0_pslverr = 1'b0;  
endmodule
