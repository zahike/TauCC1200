`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.11.2021 13:25:18
// Design Name: 
// Module Name: SPI_Rx
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


module SPI_Rx(
input clk,
input rstn,

output SPIDataValid,
output [11:0] SPIData,
output [15:0] SPIDataAdd,

input  SCLK,
input  MOSI,
output MISO,
input  CS_n

    );
assign MISO = 1'b0;   

reg [1:0] DevSCLK;
always @(posedge clk or negedge rstn)
    if (!rstn) DevSCLK <= 2'b00;
     else DevSCLK <= {DevSCLK[0],SCLK};
wire posSCLK = (DevSCLK == 2'b01) ? 1'b1 : 1'b0;     
wire negSCLK = (DevSCLK == 2'b10) ? 1'b1 : 1'b0;  

reg [2:0] BitCounter;

always @(posedge clk or negedge rstn) 
    if (!rstn) BitCounter <= 3'b000;
     else if (CS_n) BitCounter <= 3'b000;
     else if (negSCLK) BitCounter <= BitCounter + 1;

reg [7:0] ShifrMOSI;
always @(posedge clk or negedge rstn)
    if (!rstn) ShifrMOSI <= 8'h00;
     else if (CS_n) ShifrMOSI <= 8'h00;
     else if (posSCLK) ShifrMOSI <= {ShifrMOSI[6:0],MOSI};

wire SaveData = negSCLK && (BitCounter == 3'b111);
wire [7:0] DataOut   = ShifrMOSI;

reg [7:0] DataSPIsave;
reg [11:0] DataSPI2Mem;
reg [1:0] DataSPIcount;
always @(posedge clk or negedge rstn)
    if (!rstn) DataSPIcount <= 2'b01;
     else if (CS_n) DataSPIcount <= 2'b01;
     else if (DataSPIcount == 2'b00) DataSPIcount <= 2'b01;
     else if (SaveData) DataSPIcount <= DataSPIcount + 1;

always @(posedge clk or negedge rstn)
    if (!rstn) DataSPIsave <= 8'h00;
     else if (SaveData) DataSPIsave <= DataOut;

always @(posedge clk or negedge rstn)
    if (!rstn) DataSPI2Mem <= 12'h000;
     else if (SaveData && (DataSPIcount == 2'b10)) DataSPI2Mem <= {DataOut[3:0],DataSPIsave[7:0]};  
     else if (SaveData && (DataSPIcount == 2'b11)) DataSPI2Mem <= {DataOut[7:0],DataSPIsave[7:4]};

reg DelValid;
always @(posedge clk or negedge rstn) 
    if (!rstn) DelValid <= 1'b0;
     else if (CS_n) DelValid <= 1'b0;
     else if (SaveData) DelValid <= DataSPIcount[1];
reg [15:0] RWadd;
always @(posedge clk or negedge rstn)
    if (!rstn) RWadd <= 16'h0000;
     else if (CS_n) RWadd <= 16'h0000;
     else if (SaveData && DelValid) RWadd <= RWadd + 1;

assign  SPIDataValid = posSCLK && (BitCounter == 3'b000) && DelValid;
assign  SPIData      = DataSPI2Mem;
assign  SPIDataAdd   = RWadd      ;
         
endmodule
