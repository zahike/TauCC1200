`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.11.2021 09:32:58
// Design Name: 
// Module Name: CC1200SPI
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


module CC1200SPI(
input clk,
input rstn,

input         Start,
input         Stop,
output         Busy,
input  [7:0] DataOut,
output [7:0] DataIn,
input  [15:0] ClockDiv,

output Load_Next,

output SCLK,
output MOSI,
input  MISO,
output CS_n
    );
    
// Clock divider
reg [15:0] Reg_Clock_Counter;
always @(posedge clk or negedge rstn)
    if (!rstn) Reg_Clock_Counter <= 16'h0000;
     else if (Reg_Clock_Counter == ClockDiv) Reg_Clock_Counter <= 16'h0000;
     else Reg_Clock_Counter <= Reg_Clock_Counter + 1;

reg SCLKclk;
always @(posedge clk or negedge rstn) 
    if (!rstn) SCLKclk <= 1'b0;
     else if (Reg_Clock_Counter == ClockDiv) SCLKclk <= ~SCLKclk;

wire posSCCBclk = (!SCLKclk && (Reg_Clock_Counter == ClockDiv)) ? 1'b1 : 1'b0;     
wire negSCCBclk = ( SCLKclk && (Reg_Clock_Counter == ClockDiv)) ? 1'b1 : 1'b0;     

reg StartTran;
always @(posedge clk or negedge rstn)
    if (!rstn) StartTran <= 1'b0;
     else if (Start) StartTran <= 1'b1;
     else if (!MISO && negSCCBclk) StartTran <= 1'b0;
     
reg Reg_busy;
reg [3:0] BitCounter;
reg Reg_CS_n;
reg FrameOn;
always @(posedge clk or negedge rstn)
    if (!rstn) FrameOn <= 1'b0;
     else if (StartTran && negSCCBclk) FrameOn <= 1'b1;
     else if (Reg_CS_n) FrameOn <= 1'b0;
always @(posedge clk or negedge rstn)
    if (!rstn) Reg_CS_n <= 1'b1;
     else if (StartTran && negSCCBclk) Reg_CS_n <= 1'b0;
     else if (Load_Next && Stop) Reg_CS_n <= 1'b1;

always @(posedge clk or negedge rstn) 
    if (!rstn) Reg_busy <= 1'b0;
     else if (Reg_busy && Load_Next) Reg_busy <= 1'b0;
     else if (StartTran && !MISO && negSCCBclk) Reg_busy <= 1'b1;
     else if (!StartTran && !Reg_busy && !Reg_CS_n && negSCCBclk) Reg_busy <= 1'b1;
          
always @(posedge clk or negedge rstn) 
    if (!rstn) BitCounter <= 4'h0;
     else if (!Reg_busy) BitCounter <= 4'h0;
     else if (negSCCBclk) BitCounter <= BitCounter + 1;

reg [7:0] Reg_MOSI;
always @(posedge clk or negedge rstn) 
    if (!rstn) Reg_MOSI <= 8'h00;
     else if (Start || Load_Next) Reg_MOSI <= DataOut;
     else if (Reg_busy && negSCCBclk) Reg_MOSI <= {Reg_MOSI[6:0],1'b0}; 

reg [7:0] Reg_MISO;
always @(posedge clk or negedge rstn) 
    if (!rstn) Reg_MISO <= 8'h00;
     else if (Reg_busy && posSCCBclk) Reg_MISO <= {Reg_MISO[6:0],MISO}; 
     
         
      
assign SCLK = (Reg_busy) ? SCLKclk : 1'b0;
assign MOSI = Reg_MOSI[7];
assign CS_n = Reg_CS_n;

assign DataIn = Reg_MISO;
assign Load_Next = ((BitCounter == 4'h8) && posSCCBclk) ? 1'b1 : 1'b0;

assign Busy = StartTran || FrameOn || Reg_busy;
    
endmodule
