`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.09.2021 10:03:14
// Design Name: 
// Module Name: RxMem
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


module RxMem(
input Cclk,
input rstn,

input FraimSync,
input LineSync,

input [11:0] RxData,
input        RxValid,

output PixelClk,

input  [3:0] SCLK,
input  [3:0] MOSI,
output [3:0] MISO,
input  [3:0] CS_n,

output [15:0] DEWMadd,

input HVsync  ,
input HMemRead,
input pVDE    ,
output [23:0] HDMIdata

    );

wire [3:0] SPIDataValid;
wire [11:0] SPIData[3:0];
wire [15:0] SPIDataAdd[3:0];

genvar i;

generate 
for (i=0;i<4;i=i+1) begin
SPI_Rx SPI_Rx_inst(
.clk (Cclk ),                    // input clk,
.rstn(rstn),                   // input rstn,

.SPIDataValid(SPIDataValid[i]),          // output SPIDataValid,
.SPIData     (SPIData     [i]),               // output [11:0] SPIData,
.SPIDataAdd  (SPIDataAdd  [i]),            // output [15:0] SPIDataAdd,

.SCLK(SCLK[i]),                  // input  SCLK,
.MOSI(MOSI[i]),                  // input  MOSI,
.MISO(MISO[i]),                  // output MISO,
.CS_n(CS_n[i])                   // input  CS_n
    );
end
endgenerate
reg DelLineSync;
always @(posedge Cclk or negedge rstn) 
    if (!rstn) DelLineSync <= 1'b0;
    else DelLineSync <= LineSync;
    
reg [15:0] NextLineAdd;
always @(posedge Cclk or negedge rstn) 
    if (!rstn) NextLineAdd <= 16'h0050;
     else if (FraimSync) NextLineAdd <= 16'h0050;
     else if (NextLineAdd == 16'h9600) NextLineAdd <= 16'h9600;
     else if (DelLineSync && !LineSync) NextLineAdd <= NextLineAdd + 16'h0050;

reg [15:0] WMadd;
always @(posedge Cclk or negedge rstn) 
    if (!rstn) WMadd <= 16'h0000;
     else if (FraimSync) WMadd <= 16'h0000; 
     else if (WMadd == 16'h9600) WMadd <= 16'h9600;
     else if (RxValid)   WMadd <= WMadd + 1;
     else if (LineSync)  WMadd <= NextLineAdd; 

assign DEWMadd = WMadd;
     
reg [11:0] YMem0 [0:38399]; // 95ff
reg [11:0] YMem1 [0:38399]; // 95ff
reg [11:0] YMem2 [0:38399]; // 95ff
reg [11:0] YMem3 [0:38399]; // 95ff
always @(posedge Cclk)
//    if (SPIDataValid[0]) YMem0[SPIDataAdd[0]] <= SPIData[0];
    if (RxValid) YMem0[WMadd] <= RxData;
always @(posedge Cclk)                 
    if (SPIDataValid[1]) YMem1[SPIDataAdd[1]] <= SPIData[1];
always @(posedge Cclk)                
    if (SPIDataValid[2]) YMem2[SPIDataAdd[2]] <= SPIData[2];
always @(posedge Cclk)                 
    if (SPIDataValid[3]) YMem3[SPIDataAdd[3]] <= SPIData[3];

///////////////////////////  TRANSFRT DATA TO SCREAN  ///////////////////////////  
reg [2:0] Cnt_Div_Clk;
always @(posedge Cclk or negedge rstn)
    if (!rstn) Cnt_Div_Clk <= 3'b000;
     else if (Cnt_Div_Clk == 3'b100) Cnt_Div_Clk <= 3'b000;
     else Cnt_Div_Clk <= Cnt_Div_Clk + 1;
reg Reg_Div_Clk;
always @(posedge Cclk or negedge rstn)
    if (!rstn) Reg_Div_Clk <= 1'b0;
     else if (Cnt_Div_Clk == 3'b000)  Reg_Div_Clk <= 1'b1;
     else if (Cnt_Div_Clk == 3'b010)  Reg_Div_Clk <= 1'b0;

   BUFG BUFG_inst (
      .O(PixelClk), // 1-bit output: Clock output
      .I(Reg_Div_Clk)  // 1-bit input: Clock input
   );

reg Reg_SwReadAdd;
always @(posedge Cclk or negedge rstn)
    if (!rstn) Reg_SwReadAdd <= 1'b0;
     else if (Cnt_Div_Clk == 3'b000)  Reg_SwReadAdd <= 1'b1;
     else if (Cnt_Div_Clk == 3'b011)  Reg_SwReadAdd <= 1'b0;
        
reg [19:0] HRadd;
reg [15:0] TRadd;

wire [15:0] readMemAdd = (!Reg_Div_Clk) ? HRadd[19:3] : TRadd;

reg [11:0] Reg_YMem0;
reg [11:0] Reg_YMem1;
reg [11:0] Reg_YMem2;
reg [11:0] Reg_YMem3;
always @(posedge Cclk)
    Reg_YMem0 <=  YMem0[readMemAdd];
always @(posedge Cclk)
    Reg_YMem1 <=  YMem1[readMemAdd];
always @(posedge Cclk)
    Reg_YMem2 <=  YMem2[readMemAdd];
always @(posedge Cclk)
    Reg_YMem3 <=  YMem3[readMemAdd];

always @(posedge Cclk or negedge rstn)
    if (!rstn) HRadd <= 20'h00001;
     else if (!HVsync) HRadd <= 20'h00001;
     else if ((Cnt_Div_Clk == 3'b000) && HMemRead) HRadd <= HRadd + 1;

reg Del_HMemRead;
always @(posedge Cclk or negedge rstn) 
    if (!rstn) Del_HMemRead <= 1'b0;
     else Del_HMemRead <= HMemRead;
reg [3:0] REnslant;
always @(posedge Cclk or negedge rstn)
    if (!rstn) REnslant <= 4'h1;
     else if (!HVsync) REnslant <= 4'h1;
     else if ((Cnt_Div_Clk == 3'b001) && !HMemRead && Del_HMemRead) REnslant <= {REnslant[0],REnslant[3:1]};
     else if ((Cnt_Div_Clk == 3'b000) && HMemRead && !HRadd[0]) REnslant <= {REnslant[2:0],REnslant[3]};

reg [95:0] RGB4Pix;
always @(posedge Cclk or negedge rstn)
    if (!rstn) RGB4Pix <= {96{1'b0}};
     else if (Cnt_Div_Clk == 3'b000) RGB4Pix <= {Reg_YMem3[11:8],4'hf,Reg_YMem3[7:4],4'hf,Reg_YMem3[3:0],4'hf,
                                                 Reg_YMem2[11:8],4'hf,Reg_YMem2[7:4],4'hf,Reg_YMem2[3:0],4'hf,
                                                 Reg_YMem1[11:8],4'hf,Reg_YMem1[7:4],4'hf,Reg_YMem1[3:0],4'hf,
                                                 Reg_YMem0[11:8],4'hf,Reg_YMem0[7:4],4'hf,Reg_YMem0[3:0],4'hf
                                                 };

assign  HDMIdata = (REnslant[0]) ? RGB4Pix[23:0] :
                   (REnslant[1]) ? RGB4Pix[47:24] :
                   (REnslant[2]) ? RGB4Pix[71:48] :
                   (REnslant[3]) ? RGB4Pix[95:72] : 24'h000000;
  

/////////////////////////// End Of TRANSFRT DATA TO SCREAN  ///////////////////////////  
endmodule
