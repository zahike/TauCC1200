`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.09.2021 10:03:14
// Design Name: 
// Module Name: SlantMem
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


module SlantMem(
input Cclk,
input rstn,

input [3:0] Mem_cont,

output        s_axis_video_tready,
input  [23:0] s_axis_video_tdata ,
input         s_axis_video_tvalid,
input         s_axis_video_tuser ,
input         s_axis_video_tlast ,

output FraimSync,
input[1:0]  FraimSel,

output  TransValid,
output [5:0] Trans0Data,
output [5:0] Trans1Data,
output [5:0] Trans2Data,
output [5:0] Trans3Data,


output PixelClk,

input HVsync  ,
input HMemRead,
input pVDE    ,
output [23:0] HDMIdata,

output [31:0] TimeCounter,
output [11:0] CamLineCount,
output [11:0] TranLineCount
    );

parameter INC = 8;
parameter FRAME1 = 24'haab155;
parameter FRAME0 = 24'haa8d55;
parameter HSYNC  = 8'h55;
///////////////////////////  data write to Memory  ///////////////////////////  
reg Del_Last;
always @(posedge Cclk or negedge rstn)
    if (!rstn) Del_Last <= 1'b0;
     else Del_Last <= s_axis_video_tlast;
reg Del_Valid;
always @(posedge Cclk or negedge rstn)
    if (!rstn) Del_Valid <= 1'b0;
     else Del_Valid <= s_axis_video_tvalid;

//wire [4:0] YData  = s_axis_video_tdata[7:3]  ; 
wire [4:0] YData  = (s_axis_video_tdata[7:3]<5'h1f-INC) ? s_axis_video_tdata[7:3]+INC : 5'h1f ; 
wire [4:0] CbData = s_axis_video_tdata[15:11];
wire [4:0] CrData = s_axis_video_tdata[23:19];
reg [4:0] DelYData;
always @(posedge Cclk or negedge rstn)
    if (!rstn) DelYData <= 5'h00;
     else if (s_axis_video_tvalid) DelYData <= YData;     
reg [4:0] DelCbData;
always @(posedge Cclk or negedge rstn)
    if (!rstn) DelCbData <= 5'h00;
     else if (s_axis_video_tvalid) DelCbData <= CbData;     
reg [4:0] DelCrData;
always @(posedge Cclk or negedge rstn)
    if (!rstn) DelCrData <= 5'h00;
     else if (s_axis_video_tvalid) DelCrData <= CrData;     

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

reg [19:0] CWadd;
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

wire [4:0] DelCData = (CWadd[0] == Line_Odd) ? DelCrData : DelCbData;

reg [4:0] YMem0 [0:38399]; // 95ff
//reg [4:0] YMem0 [0:63]; // 95ff
reg [4:0] YMem1 [0:38399];
reg [4:0] YMem2 [0:38399];
reg [4:0] YMem3 [0:38399];
always @(posedge Cclk)
    if (WEnslant[0] && Del_Valid && Valid_odd) YMem0[CWadd[19:2]] <= DelYData;
always @(posedge Cclk)                                       
    if (WEnslant[1] && Del_Valid && Valid_odd) YMem1[CWadd[19:2]] <= DelYData;
always @(posedge Cclk)                                       
    if (WEnslant[2] && Del_Valid && Valid_odd) YMem2[CWadd[19:2]] <= DelYData;
always @(posedge Cclk)                                       
    if (WEnslant[3] && Del_Valid && Valid_odd) YMem3[CWadd[19:2]] <= DelYData;
reg [4:0] CMem0 [0:38399];
//reg [4:0] CMem0 [0:63];
reg [4:0] CMem1 [0:38399];
reg [4:0] CMem2 [0:38399];
reg [4:0] CMem3 [0:38399];
always @(posedge Cclk)
    if (WEnslant[0] && Del_Valid && Valid_odd) CMem0[CWadd[19:2]] <= DelCData;
always @(posedge Cclk)                                       
    if (WEnslant[1] && Del_Valid && Valid_odd) CMem1[CWadd[19:2]] <= DelCData;
always @(posedge Cclk)                                       
    if (WEnslant[2] && Del_Valid && Valid_odd) CMem2[CWadd[19:2]] <= DelCData;
always @(posedge Cclk)                                       
    if (WEnslant[3] && Del_Valid && Valid_odd) CMem3[CWadd[19:2]] <= DelCData;
///////////////////////////  End Of data write to Memory  ///////////////////////////  


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

//   BUFG BUFG_inst (
//      .O(PixelClk), // 1-bit output: Clock output
//      .I(Reg_Div_Clk)  // 1-bit input: Clock input
//   );
assign PixelClk = Reg_Div_Clk;

reg Reg_SwReadAdd;
always @(posedge Cclk or negedge rstn)
    if (!rstn) Reg_SwReadAdd <= 1'b0;
     else if (Cnt_Div_Clk == 3'b000)  Reg_SwReadAdd <= 1'b1;
     else if (Cnt_Div_Clk == 3'b011)  Reg_SwReadAdd <= 1'b0;
        
reg [19:0] HRadd;
reg [16:0] TRadd;

wire [15:0] readMemAdd = (Reg_Div_Clk) ? HRadd[19:3] : TRadd[16:1];

reg [4:0] Reg_YMem0;
reg [4:0] Reg_YMem1;
reg [4:0] Reg_YMem2;
reg [4:0] Reg_YMem3;
always @(posedge Cclk)
    Reg_YMem0 <=  YMem0[readMemAdd];
always @(posedge Cclk)
    Reg_YMem1 <=  YMem1[readMemAdd];
always @(posedge Cclk)
    Reg_YMem2 <=  YMem2[readMemAdd];
always @(posedge Cclk)
    Reg_YMem3 <=  YMem3[readMemAdd];
reg [4:0] Reg_CMem0;
reg [4:0] Reg_CMem1;
reg [4:0] Reg_CMem2;
reg [4:0] Reg_CMem3;
always @(posedge Cclk)
    Reg_CMem0 <=  CMem0[readMemAdd];
always @(posedge Cclk)
    Reg_CMem1 <=  CMem1[readMemAdd];
always @(posedge Cclk)
    Reg_CMem2 <=  CMem2[readMemAdd];
always @(posedge Cclk)
    Reg_CMem3 <=  CMem3[readMemAdd];

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

wire [4:0] Reg_Cont_YMem0 = (Mem_cont[0]) ? Reg_YMem0 : 5'h00;
wire [4:0] Reg_Cont_YMem1 = (Mem_cont[1]) ? Reg_YMem1 : 5'h00;
wire [4:0] Reg_Cont_YMem2 = (Mem_cont[2]) ? Reg_YMem2 : 5'h00;
wire [4:0] Reg_Cont_YMem3 = (Mem_cont[3]) ? Reg_YMem3 : 5'h00;
wire [4:0] Reg_Cont_CMem0 = (Mem_cont[0]) ? Reg_CMem0 : 5'h10;
wire [4:0] Reg_Cont_CMem1 = (Mem_cont[1]) ? Reg_CMem1 : 5'h10;
wire [4:0] Reg_Cont_CMem2 = (Mem_cont[2]) ? Reg_CMem2 : 5'h10;
wire [4:0] Reg_Cont_CMem3 = (Mem_cont[3]) ? Reg_CMem3 : 5'h10;

reg [59:0] YCbCr4Pix;
always @(posedge Cclk or negedge rstn)
    if (!rstn) YCbCr4Pix <= {60{1'b0}};
     else if (Cnt_Div_Clk == 3'b011) YCbCr4Pix <= {Reg_Cont_CMem3,Reg_Cont_CMem2,Reg_Cont_YMem3,
                                                   Reg_Cont_CMem3,Reg_Cont_CMem2,Reg_Cont_YMem2,
                                                   Reg_Cont_CMem1,Reg_Cont_CMem0,Reg_Cont_YMem1,
                                                   Reg_Cont_CMem1,Reg_Cont_CMem0,Reg_Cont_YMem0
                                                   };

wire [95:0] RGB4Pix;

genvar i;
generate 
for (i=0;i<4;i=i+1) begin
        PixYCbCr2RGB PixYCbCr2RGB_inst(
        .clk      (Cclk),
        .rstn     (rstn),
                 
        .YCbCrData(YCbCr4Pix[15*i+14:15*i]),
        .RGBdata  (RGB4Pix[24*i+23:24*i])
    );

    end
endgenerate     

//assign  HDMIdata = (REnslant[0] && Mem_cont[0]) ? RGB4Pix[23:0] :
//                   (REnslant[1] && Mem_cont[1]) ? RGB4Pix[47:24] :
//                   (REnslant[2] && Mem_cont[2]) ? RGB4Pix[71:48] :
//                   (REnslant[3] && Mem_cont[3]) ? RGB4Pix[95:72] : 24'h000000;
assign  HDMIdata = (REnslant[0]) ? RGB4Pix[23:0] :
                   (REnslant[1]) ? RGB4Pix[47:24] :
                   (REnslant[2]) ? RGB4Pix[71:48] :
                   (REnslant[3]) ? RGB4Pix[95:72] : 24'h000000;
  
assign s_axis_video_tready = 1'b1;   



reg [4:0] TClkCounter;
//reg [16:0] TRadd;
reg Transmit;
reg [23:0] FrameSR;
reg [16:0] NextLine;
reg [7:0]  HsyncSR;

always @(posedge Cclk or negedge rstn)
    if (!rstn) TClkCounter <= 5'h00;
     else if (!Transmit) TClkCounter <= 5'h00;
     else if (TClkCounter == 5'h18) TClkCounter <= 5'h00;
     else TClkCounter <= TClkCounter + 1;
     
always @(posedge Cclk or negedge rstn)
    if (!rstn) TRadd <= 17'h00000;
     else if (!Transmit) TRadd <= 17'h00000;
     else if (|FrameSR) TRadd <= 17'h00000;
     else if (|HsyncSR) TRadd <= TRadd;
     else if (TClkCounter == 5'h16) TRadd <= TRadd + 1;
     
always @(posedge Cclk or negedge rstn)
    if (!rstn) Transmit <= 1'b0;
     else if ((Cnt_Div_Clk == 3'b100) && (CWadd == 20'h0603e)) Transmit <= 1'b1;
     else if (TRadd == 17'h12c00) Transmit <= 1'b0;

always @(posedge Cclk or negedge rstn)
    if (!rstn) FrameSR <= 24'h000000;
     else if ((CWadd == 20'h0603d) &&  Reg_FraimSync) FrameSR <= FRAME1;
     else if ((CWadd == 20'h0603d) && ~Reg_FraimSync) FrameSR <= FRAME0;
     else if (TClkCounter == 5'h18) FrameSR <= {FrameSR[23:0],1'b0};

always @(posedge Cclk or negedge rstn)
    if (!rstn) NextLine <= 17'h0009e;
     else if (!Transmit) NextLine <= 17'h0009e;
     else if ((TClkCounter == 5'h18) && (TRadd == NextLine))  NextLine <= NextLine + 17'h000a0;

always @(posedge Cclk or negedge rstn)
    if (!rstn) HsyncSR <= 8'h00;
     else if ((TClkCounter == 5'h18) && (TRadd == NextLine)) HsyncSR <= HSYNC;
     else if (TClkCounter == 5'h18) HsyncSR <= {HsyncSR[6:0],1'b0};
     
reg [4:0] Reg_YTMem0;
reg [4:0] Reg_YTMem1;
reg [4:0] Reg_YTMem2;
reg [4:0] Reg_YTMem3;
always @(posedge Cclk or negedge rstn)
   if (!rstn) Reg_YTMem0 <= 5'h00;
    else if (Cnt_Div_Clk == 3'b100) Reg_YTMem0 <=  Reg_YMem0;
always @(posedge Cclk or negedge rstn)
   if (!rstn) Reg_YTMem1 <= 5'h00;
    else if (Cnt_Div_Clk == 3'b100) Reg_YTMem1 <=  Reg_YMem1;
always @(posedge Cclk or negedge rstn)
   if (!rstn) Reg_YTMem2 <= 5'h00;
    else if (Cnt_Div_Clk == 3'b100) Reg_YTMem2 <=  Reg_YMem2;
always @(posedge Cclk or negedge rstn)
   if (!rstn) Reg_YTMem3 <= 5'h00;
    else if (Cnt_Div_Clk == 3'b100) Reg_YTMem3 <=  Reg_YMem3;

reg [4:0] Reg_CTMem0;
reg [4:0] Reg_CTMem1;
reg [4:0] Reg_CTMem2;
reg [4:0] Reg_CTMem3;
always @(posedge Cclk or negedge rstn)
  if (!rstn) Reg_CTMem0 <= 5'h00;
   else if (Cnt_Div_Clk == 3'b100) Reg_CTMem0 <=  Reg_CMem0;
always @(posedge Cclk or negedge rstn)
  if (!rstn) Reg_CTMem1 <= 5'h00;
   else if (Cnt_Div_Clk == 3'b100) Reg_CTMem1 <=  Reg_CMem1;
always @(posedge Cclk or negedge rstn)
  if (!rstn) Reg_CTMem2 <= 5'h00;
   else if (Cnt_Div_Clk == 3'b100) Reg_CTMem2 <=  Reg_CMem2;
always @(posedge Cclk or negedge rstn)
  if (!rstn) Reg_CTMem3 <= 5'h00;
   else if (Cnt_Div_Clk == 3'b100) Reg_CTMem3 <=  Reg_CMem3;


wire [4:0] Reg_cont_YTMem0 = (Mem_cont[0]) ? Reg_YTMem0 : 5'h00;
wire [4:0] Reg_cont_YTMem1 = (Mem_cont[1]) ? Reg_YTMem1 : 5'h00;
wire [4:0] Reg_cont_YTMem2 = (Mem_cont[2]) ? Reg_YTMem2 : 5'h00;
wire [4:0] Reg_cont_YTMem3 = (Mem_cont[3]) ? Reg_YTMem3 : 5'h00;
wire [4:0] Reg_cont_CTMem0 = (Mem_cont[0]) ? Reg_CTMem0 : 5'h10;
wire [4:0] Reg_cont_CTMem1 = (Mem_cont[1]) ? Reg_CTMem1 : 5'h10;
wire [4:0] Reg_cont_CTMem2 = (Mem_cont[2]) ? Reg_CTMem2 : 5'h10;
wire [4:0] Reg_cont_CTMem3 = (Mem_cont[3]) ? Reg_CTMem3 : 5'h10;



reg [1:0] switchYC;
always @(posedge Cclk or negedge rstn) 
    if (!rstn) switchYC <= 2'b00;
     else switchYC <= {switchYC[0],TRadd[0]};
assign  TransValid = (Transmit && (TClkCounter == 5'h00)) ? 1'b1 : 1'b0; 
    
assign  Trans0Data = (!Transmit) ? 6'h00 :
                     (|FrameSR)  ? (FrameSR[23]) ? 6'h3f : 6'h00 :
                     (|HsyncSR)  ? (HsyncSR[7]) ? 6'h3f : 6'h00 :
                     (switchYC[1])  ? {1'b0,Reg_cont_CTMem0} : {1'b0,Reg_cont_YTMem0};

assign  Trans1Data = (!Transmit) ? 6'h00 :
                     (|FrameSR)  ? (FrameSR[23]) ? 6'h3f : 6'h00 :
                     (|HsyncSR)  ? (HsyncSR[7]) ? 6'h3f : 6'h00 :
                     (switchYC[1])  ? {1'b0,Reg_cont_CTMem1} : {1'b0,Reg_cont_YTMem1};

assign  Trans2Data = (!Transmit) ? 6'h00 :
                     (|FrameSR)  ? (FrameSR[23]) ? 6'h3f : 6'h00 :
                     (|HsyncSR)  ? (HsyncSR[7]) ? 6'h3f : 6'h00 :
                     (switchYC[1])  ? {1'b0,Reg_cont_CTMem2} : {1'b0,Reg_cont_YTMem2};

assign  Trans3Data = (!Transmit) ? 6'h00 :
                     (|FrameSR)  ? (FrameSR[23]) ? 6'h3f : 6'h00 :
                     (|HsyncSR)  ? (HsyncSR[7]) ? 6'h3f : 6'h00 :
                     (switchYC[1])  ? {1'b0,Reg_cont_CTMem3} : {1'b0,Reg_cont_YTMem3};
                     
reg [11:0] Reg_CamLineCount;
always @(posedge Cclk or negedge rstn)
    if (!rstn) Reg_CamLineCount <= 12'h000;
     else if (s_axis_video_tuser) Reg_CamLineCount <= 12'h000;
     else if (s_axis_video_tlast) Reg_CamLineCount <= Reg_CamLineCount + 1;
assign CamLineCount = Reg_CamLineCount;
reg [11:0] Reg_TranLineCount;
always @(posedge Cclk or negedge rstn)
    if (!rstn) Reg_TranLineCount <= 12'h000;
     else if (|FrameSR) Reg_TranLineCount <= 12'h000;
     else if ((TClkCounter == 5'h18) && (HsyncSR == HSYNC)) Reg_TranLineCount <= Reg_TranLineCount + 1;
assign TranLineCount = Reg_TranLineCount;
reg [31:0] Reg_TimeCounter;
always @(posedge Cclk or negedge rstn)
    if (!rstn) Reg_TimeCounter <= 32'h00000000;
     else if (s_axis_video_tuser) Reg_TimeCounter <= 32'h00000000;
     else Reg_TimeCounter <= Reg_TimeCounter + 1;
assign TimeCounter = Reg_TimeCounter;     
endmodule
