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

//output        s_axis_video_tready,
//input  [31:0] s_axis_video_tdata ,
//input         s_axis_video_tvalid,
//input         s_axis_video_tuser ,
//input         s_axis_video_tlast ,

output FraimSync,
input[1:0]  FraimSel,

output PixelClk,

input  [3:0] SCLK,
input  [3:0] MOSI,
output [3:0] MISO,
input  [3:0] CS_n,

input HVsync  ,
input HMemRead,
input pVDE    ,
output [23:0] HDMIdata

    );
/*
wire        s_axis_video_tready;
wire [31:0] s_axis_video_tdata  = 32'h00000000;
wire        s_axis_video_tvalid = 1'b0;
wire        s_axis_video_tuser  = 1'b0;
wire        s_axis_video_tlast  = 1'b0;

parameter INC = 4;
parameter FRAME1 = 24'haab155;
parameter FRAME0 = 24'haa8d55;
parameter HSYNC  = 8'h55;
///////////////////////////  data write to Memory  ///////////////////////////  
reg tranData;           // data transmition block write frame from Camera
reg [19:0] CWadd;       // Camera write address

reg ValidBlock;
always @(posedge Cclk or negedge rstn)
    if (!rstn) ValidBlock <= 1'b0;
     else if ( tranData && (CWadd == 20'h257ff)) ValidBlock <= 1'b1;
     else if (!tranData && (CWadd == 20'h257ff)) ValidBlock <= 1'b0;

reg Del_Last;
always @(posedge Cclk or negedge rstn)
    if (!rstn) Del_Last <= 1'b0;
     else Del_Last <= s_axis_video_tlast;
reg Del_Valid;
always @(posedge Cclk or negedge rstn)
    if (!rstn) Del_Valid <= 1'b0;
     else if (ValidBlock) Del_Valid <= 1'b0;
     else Del_Valid <= s_axis_video_tvalid;

wire [11:0] YData  = {s_axis_video_tdata[29:26],s_axis_video_tdata[19:16],s_axis_video_tdata[9:6]};
reg [11:0] DelYData;
always @(posedge Cclk or negedge rstn)
    if (!rstn) DelYData <= 5'h00;
     else if (s_axis_video_tvalid) DelYData <= YData;     

reg Valid_odd;
always @(posedge Cclk or negedge rstn)
    if (!rstn) Valid_odd <= 1'b0;
     else if (s_axis_video_tuser && s_axis_video_tvalid)  Valid_odd <=  ~Valid_odd;
     else if (Del_Last)  Valid_odd <=  Valid_odd;
     else if (s_axis_video_tvalid) Valid_odd <= ~Valid_odd;

reg Reg_FraimSync;
always @(posedge Cclk or negedge rstn) 
    if (!rstn) Reg_FraimSync <= 1'b0;
     else if (FraimSel == 2'b11) Reg_FraimSync <= 1'b1;
     else if (FraimSel == 2'b10) Reg_FraimSync <= 1'b0;
     else if (s_axis_video_tuser && s_axis_video_tvalid && Valid_odd) Reg_FraimSync <= 1'b1;
     else if (s_axis_video_tuser && s_axis_video_tvalid && ~Valid_odd) Reg_FraimSync <= 1'b0;
assign FraimSync = Reg_FraimSync;

always @(posedge Cclk or negedge rstn)
    if (!rstn) CWadd <= 20'h00000;
     else if (s_axis_video_tvalid && s_axis_video_tuser && s_axis_video_tready) CWadd <= 20'h00000;
     else if (s_axis_video_tvalid && Valid_odd) CWadd <= CWadd + 1;

reg [3:0] WEnslant;
always @(posedge Cclk or negedge rstn)
    if (!rstn) WEnslant <= 4'h1;
     else if (s_axis_video_tvalid && s_axis_video_tuser && s_axis_video_tready) WEnslant <= 4'h1;
     else if (Valid_odd && s_axis_video_tlast) WEnslant <= WEnslant;
     else if (Valid_odd && Del_Last) WEnslant <= WEnslant;
     else if (s_axis_video_tvalid && Valid_odd) WEnslant <= {WEnslant[2:0],WEnslant[3]};

reg Line_Odd;
always @(posedge Cclk or negedge rstn)
    if (!rstn) Line_Odd <= 1'b0;
     else if (Del_Last && ~Valid_odd) Line_Odd <= Reg_FraimSync ;
     else if (Del_Last &&  Valid_odd) Line_Odd <= ~Reg_FraimSync ;
*/

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

reg [11:0] YMem0 [0:38399]; // 95ff
reg [11:0] YMem1 [0:38399]; // 95ff
reg [11:0] YMem2 [0:38399]; // 95ff
reg [11:0] YMem3 [0:38399]; // 95ff
always @(posedge Cclk)
    if (SPIDataValid[0]) YMem0[SPIDataAdd[0]] <= SPIData[0];
always @(posedge Cclk)                 
    if (SPIDataValid[1]) YMem1[SPIDataAdd[1]] <= SPIData[1];
always @(posedge Cclk)                
    if (SPIDataValid[2]) YMem2[SPIDataAdd[2]] <= SPIData[2];
always @(posedge Cclk)                 
    if (SPIDataValid[3]) YMem3[SPIDataAdd[3]] <= SPIData[3];

//reg [11:0] YMem0 [0:38399]; // 95ff
//reg [11:0] YMem1 [0:38399];
//reg [11:0] YMem2 [0:38399];
//reg [11:0] YMem3 [0:38399];
//always @(posedge Cclk)
//    if (WEnslant[0] && Del_Valid && Valid_odd) YMem0[CWadd[19:2]] <= DelYData;
//always @(posedge Cclk)                                       
//    if (WEnslant[1] && Del_Valid && Valid_odd) YMem1[CWadd[19:2]] <= DelYData;
//always @(posedge Cclk)                                       
//    if (WEnslant[2] && Del_Valid && Valid_odd) YMem2[CWadd[19:2]] <= DelYData;
//always @(posedge Cclk)                                       
//    if (WEnslant[3] && Del_Valid && Valid_odd) YMem3[CWadd[19:2]] <= DelYData;
///////////////////////////  End Of data write to Memory  ///////////////////////////  


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

//reg [11:0] Reg_YMem0;
//reg [11:0] Reg_YMem1;
//reg [11:0] Reg_YMem2;
//reg [11:0] Reg_YMem3;
//always @(posedge Cclk)
//    Reg_YMem0 <=  YMem0[readMemAdd];
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
  
//assign s_axis_video_tready = 1'b1;   

/////////////////////////// End Of TRANSFRT DATA TO SCREAN  ///////////////////////////  
endmodule
