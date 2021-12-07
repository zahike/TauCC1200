`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/10/2021 12:24:42 PM
// Design Name: 
// Module Name: FreqLUT
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


module FreqLUT(
input clk,
input rstn,

input  [5:0]  FreqNum,
output [31:0] FreqData
    );



   reg [31:0] RegData;

   always @(posedge clk)
      if (rstn)
         case (FreqNum)
            6'b000000: RegData <= 32'h0c000d3c;
            6'b000001: RegData <= 32'h0c300d3c;
            6'b000010: RegData <= 32'h0c600d3c;
            6'b000011: RegData <= 32'h0c900d3c;
            6'b000100: RegData <= 32'h0cC00d3c;
            6'b000101: RegData <= 32'h0cF00d3c;
            6'b000110: RegData <= 32'h0c200d3d;
            6'b000111: RegData <= 32'h0c500d3d;
            6'b001000: RegData <= 32'h0c800d3d;
            6'b001001: RegData <= 32'h0cB00d3d;
            6'b001010: RegData <= 32'h0cE00d3d;
            6'b001011: RegData <= 32'h0c100d3e;
            6'b001100: RegData <= 32'h0c400d3e;
            6'b001101: RegData <= 32'h0c700d3e;
            6'b001110: RegData <= 32'h0cA00d3e;
            6'b001111: RegData <= 32'h0cD00d3e;
            6'b010000: RegData <= 32'h0c000d3f;
            6'b010001: RegData <= 32'h0c300d3f;
            6'b010010: RegData <= 32'h0c600d3f;
            6'b010011: RegData <= 32'h0c900d3f;
            6'b010100: RegData <= 32'h0cC00d3f;
            6'b010101: RegData <= 32'h0cF00d3f;
            6'b010110: RegData <= 32'h0c200d40;
            6'b010111: RegData <= 32'h0c500d40;
            6'b011000: RegData <= 32'h0c800d40;
            6'b011001: RegData <= 32'h0cB00d40;
            6'b011010: RegData <= 32'h0cE00d40;
            6'b011011: RegData <= 32'h0c100d41;
            6'b011100: RegData <= 32'h0c400d41;
            6'b011101: RegData <= 32'h0c700d41;
            6'b011110: RegData <= 32'h0cA00d41;
            6'b011111: RegData <= 32'h0cD00d41;
            6'b111111: RegData <= 32'h0c100d42;
            default:   RegData <= 32'h0c000d3c;
         endcase

assign FreqData =  RegData;   
endmodule
