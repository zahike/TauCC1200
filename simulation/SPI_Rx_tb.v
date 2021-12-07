`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.11.2021 13:39:14
// Design Name: 
// Module Name: SPI_Rx_tb
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


module SPI_Rx_tb();
reg clk ;
reg rstn;
initial begin 
clk = 1'b0;
rstn = 1'b0;
#100;
rstn = 1'b1;
end

always #4 clk = ~clk;


SPI_Rx SPI_Rx_inst(
.clk (clk ),
.rstn(rstn),

.SCLK(),
.MOSI(),
.MISO(),
.CS_n()
    );

endmodule
