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

//input FraimSync,
//input LineSync,

input [11:0] RxData,
input        RxValid,
input        RxHeader,
input [15:0] RxAdd,
input        RxAddValid,
input signed [7:0]  CorThre,  //input [7:0]  CorThre,

output PixelClk,

output [15:0] DEWMadd,

output wire FrameSync0,
output wire FrameSync1,
output wire LineSync  ,

output [31:0] Deb_CS_On,
output [31:0] Deb_CS_Off,

input SCLK,
input MOSI,
input MISO,
input CS_n,

output         FraimSync,
input HVsync  ,
input HMemRead,
input pVDE    ,
output [23:0] HDMIdata

    );
wire [31:0] RegVsync0 = 32'h93aaaade;
wire [31:0] RegVsync1 = 32'h935555de;
wire [31:0] RegHsync  = 32'h6cf4ae21;
    
///////////////////// SPI test ///////////////////// 
reg [31:0] Reg_CS_On;
always @(posedge Cclk or negedge rstn) 
    if (!rstn) Reg_CS_On <= 32'h00000000;
     else if (CS_n) Reg_CS_On <= 32'h00000000;
     else Reg_CS_On <= Reg_CS_On + 1;
assign Deb_CS_On = Reg_CS_On;
reg [31:0] Reg_CS_Off;
always @(posedge Cclk or negedge rstn) 
    if (!rstn) Reg_CS_Off <= 32'h00000000;
     else if (!CS_n) Reg_CS_Off <= 32'h00000000;
     else Reg_CS_Off <= Reg_CS_Off + 1;
assign Deb_CS_Off = Reg_CS_Off;
//reg DelLineSync;
//always @(posedge Cclk or negedge rstn) 
//    if (!rstn) DelLineSync <= 1'b0;
//    else DelLineSync <= LineSync;
//wire FrameSync0;
//wire FrameSync1;
//wire LineSync ;
reg DelSCLK;
always @(posedge Cclk or negedge rstn)
    if (!rstn) DelSCLK <= 1'b0;
     else DelSCLK <= SCLK;

reg [5:0] CorCount;
always @(posedge Cclk or negedge rstn)
    if (!rstn) CorCount <= 6'h2f;
     else if (!RxHeader) CorCount <= 6'h2f;
     else if (DelSCLK && !SCLK) CorCount <= CorCount - 1;

reg [15:0] NextLineAdd;
always @(posedge Cclk or negedge rstn) 
    if (!rstn) NextLineAdd <= 16'h0050;
     else if (FrameSync0 || FrameSync1) NextLineAdd <= 16'h0050;
     else if (NextLineAdd == 16'h9600) NextLineAdd <= 16'h9600;
     else if (RxAddValid) NextLineAdd <= NextLineAdd + 16'h0050;
     
wire [47:0] HeadVsync0 = {RegVsync0,16'h0000};
wire [47:0] HeadVsync1 = {RegVsync1,16'h0000};
wire [47:0] HeadHsync  = {RegHsync ,NextLineAdd};

reg signed [7:0] Fram0CorCount;
always @(posedge Cclk or negedge rstn)
    if (!rstn) Fram0CorCount <= 8'h00;
     else if (!RxHeader) Fram0CorCount <= 8'h00;
     else if ((!DelSCLK && SCLK) && (MISO == HeadVsync0[CorCount])) Fram0CorCount <= Fram0CorCount + 1;
     else if ((!DelSCLK && SCLK) && (MISO != HeadVsync0[CorCount])) Fram0CorCount <= Fram0CorCount - 1;
reg signed [7:0] Fram1CorCount;
always @(posedge Cclk or negedge rstn)
    if (!rstn) Fram1CorCount <= 8'h00;
     else if (!RxHeader) Fram1CorCount <= 8'h00;
     else if ((!DelSCLK && SCLK) && (MISO == HeadVsync1[CorCount])) Fram1CorCount <= Fram1CorCount + 1;
     else if ((!DelSCLK && SCLK) && (MISO != HeadVsync1[CorCount])) Fram1CorCount <= Fram1CorCount - 1;
reg signed [7:0] LineCorCount;
always @(posedge Cclk or negedge rstn)
    if (!rstn) LineCorCount <= 8'h00;
     else if (!RxHeader) LineCorCount <= 8'h00;
     else if ((!DelSCLK && SCLK) && (MISO == HeadHsync[CorCount])) LineCorCount <= LineCorCount + 1;
     else if ((!DelSCLK && SCLK) && (MISO != HeadHsync[CorCount])) LineCorCount <= LineCorCount - 1;

assign FrameSync0 = (Fram0CorCount > CorThre) ? 1'b1 : 1'b0;
assign FrameSync1 = (Fram1CorCount > CorThre) ? 1'b1 : 1'b0;
assign LineSync   = (LineCorCount  > CorThre) ? 1'b1 : 1'b0;

reg Reg_FraimSync;
always @(posedge Cclk or negedge rstn)  
    if (!rstn) Reg_FraimSync <= 1'b0;
     else if (RxAdd && FrameSync0) Reg_FraimSync <= 1'b0;
     else if (RxAdd && FrameSync1) Reg_FraimSync <= 1'b1;
assign FraimSync = Reg_FraimSync;

     
////////////////// End Of SPI test ////////////////// 
wire [3:0] SPIDataValid = 0;
wire [11:0] SPIData[3:0];
wire [15:0] SPIDataAdd[3:0];
    
reg [15:0] WMadd;
always @(posedge Cclk or negedge rstn) 
    if (!rstn) WMadd <= 16'h0000;
     else if (FrameSync0 || FrameSync1) WMadd <= 16'h0000; 
     else if (WMadd == 16'h9600) WMadd <= 16'h9600;
     else if (RxValid)   WMadd <= WMadd + 1;
//     else if (RxAddValid)  WMadd <= NextLineAdd; 
     else if (RxAddValid)  WMadd <= RxAdd; 

assign DEWMadd = WMadd;
     
reg [11:0] YMem0 [0:38399]; // 95ff
reg [11:0] YMem1 [0:38399]; // 95ff
reg [11:0] YMem2 [0:38399]; // 95ff
reg [11:0] YMem3 [0:38399]; // 95ff
always @(posedge Cclk)
//    if (SPIDataValid[0]) YMem0[SPIDataAdd[0]] <= SPIData[0];
    if (RxValid) YMem0[WMadd] <= RxData;
//always @(posedge Cclk)                 
//    if (SPIDataValid[1]) YMem1[SPIDataAdd[1]] <= SPIData[1];
//always @(posedge Cclk)                
//    if (SPIDataValid[2]) YMem2[SPIDataAdd[2]] <= SPIData[2];
//always @(posedge Cclk)                 
//    if (SPIDataValid[3]) YMem3[SPIDataAdd[3]] <= SPIData[3];

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
wire [11:0] Reg_YMem1 = 12'h000;
wire [11:0] Reg_YMem2 = 12'h000;
wire [11:0] Reg_YMem3 = 12'h000;
always @(posedge Cclk)
    Reg_YMem0 <=  YMem0[readMemAdd];
//always @(posedge Cclk)
//    Reg_YMem1 <=  YMem1[readMemAdd];
//always @(posedge Cclk)
//    Reg_YMem2 <=  YMem2[readMemAdd];
//always @(posedge Cclk)
//    Reg_YMem3 <=  YMem3[readMemAdd];

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
