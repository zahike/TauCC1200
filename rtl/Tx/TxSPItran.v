`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.11.2021 11:26:53
// Design Name: 
// Module Name: TxSPItran
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


module TxSPItran(
input  wire clk ,
input  wire rstn,
        
input  wire TranStart,
        
input  wire [11:0] TranInData,
        
output wire  [15:0] TRadd,

output wire SCLK,
output wire MOSI,
input  wire MISO,
output wire CS_n
    );

reg TranOn;
always @(posedge clk or negedge rstn) 
    if (!rstn) TranOn <= 1'b0;
     else if (TranStart) TranOn <= 1'b1;
     else if (TRadd == 16'h9600) TranOn <= 1'b0;

reg DelTranOn;
always @(posedge clk or negedge rstn) 
    if (!rstn) DelTranOn <= 1'b0;
     else DelTranOn <= TranOn;

wire StartSPI;
reg StopSPI;
wire Busy;
wire Load_Next;
reg [1:0] SPIcount;
reg [11:0] SPIdatasave;
reg [7:0] SPIdataOut;
reg [15:0] Reg_TRadd;

assign StartSPI = (TranOn && !DelTranOn) ? 1'b1 : 1'b0;     

always @(posedge clk or negedge rstn)
    if (!rstn) StopSPI <= 1'b0;
     else if (!TranOn && DelTranOn) StopSPI <= 1'b1;
     else if (Load_Next) StopSPI <= 1'b0;      
     
always @(posedge clk or negedge rstn)
    if (!rstn) SPIcount <= 2'b00;
     else if (SPIcount == 2'b11) SPIcount <= 2'b00;
     else if (StartSPI) SPIcount <= 2'b01;
     else if (!TranOn) SPIcount <= 2'b00;
     else if (Load_Next) SPIcount <= SPIcount + 1;

always @(posedge clk or negedge rstn)
    if (!rstn) SPIdatasave <= 12'h000;
     else if (Load_Next || StartSPI) SPIdatasave <= TranInData;

always @(posedge clk or negedge rstn)
    if (!rstn) SPIdataOut <= 8'h00;
     else if (!TranOn) SPIdataOut <= TranInData[7:0];
     else case (SPIcount)
            2'b00 : SPIdataOut <=  TranInData[7:0];
            2'b01 : SPIdataOut <= {TranInData[3:0],SPIdatasave[11:8]};
            2'b10 : SPIdataOut <=  TranInData[11:4];
          default : SPIdataOut <=  TranInData[7:0];
        endcase

always @(posedge clk or negedge rstn) 
    if (!rstn) Reg_TRadd <= 16'h0000;
     else if (!TranOn) Reg_TRadd <= 16'h0000;
     else if (StartSPI ) Reg_TRadd <= 16'h0001;
     else if (Load_Next && (SPIcount != 2'b01)) Reg_TRadd <= Reg_TRadd + 1;

assign TRadd = Reg_TRadd;

CC1200SPI CC1200SPI_inst(
.clk (clk),
.rstn(rstn),

.Start   (StartSPI   ),
.Stop    (StopSPI),
.Busy    (Busy        ),
.DataOut (SPIdataOut ),
.DataIn  (  ),
.ClockDiv(16'h0010),

.Load_Next(Load_Next),

.SCLK(SCLK),
.MOSI(MOSI),
.MISO(MISO),
.CS_n(CS_n)
    );
       
endmodule
