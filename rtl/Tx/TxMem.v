`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.09.2021 10:03:14
// Design Name: 
// Module Name: TxMem
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


module TxMem(
input Cclk,
input rstn,

input [3:0] Mem_cont,

output        s_axis_video_tready,
input  [31:0] s_axis_video_tdata ,
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

output [3:0] SCLK,
output [3:0] MOSI,
input  [3:0] MISO,
output [3:0] CS_n

    );

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


reg [11:0] YMem0 [0:38399]; // 95ff
reg [11:0] YMem1 [0:38399];
reg [11:0] YMem2 [0:38399];
reg [11:0] YMem3 [0:38399];
always @(posedge Cclk)
    if (WEnslant[0] && Del_Valid && Valid_odd) YMem0[CWadd[19:2]] <= DelYData;
always @(posedge Cclk)                                       
    if (WEnslant[1] && Del_Valid && Valid_odd) YMem1[CWadd[19:2]] <= DelYData;
always @(posedge Cclk)                                       
    if (WEnslant[2] && Del_Valid && Valid_odd) YMem2[CWadd[19:2]] <= DelYData;
always @(posedge Cclk)                                       
    if (WEnslant[3] && Del_Valid && Valid_odd) YMem3[CWadd[19:2]] <= DelYData;
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
//reg [15:0] TRadd;
wire [15:0] TRadd[0:3];

wire [15:0] readMemAdd0 = (!Reg_Div_Clk) ? HRadd[19:3] : TRadd[0];
wire [15:0] readMemAdd1 = (!Reg_Div_Clk) ? HRadd[19:3] : TRadd[1];
wire [15:0] readMemAdd2 = (!Reg_Div_Clk) ? HRadd[19:3] : TRadd[2];
wire [15:0] readMemAdd3 = (!Reg_Div_Clk) ? HRadd[19:3] : TRadd[3];

reg [11:0] Reg_YMem0;
reg [11:0] Reg_YMem1;
reg [11:0] Reg_YMem2;
reg [11:0] Reg_YMem3;
always @(posedge Cclk)
    Reg_YMem0 <=  YMem0[readMemAdd0];
always @(posedge Cclk)
    Reg_YMem1 <=  YMem1[readMemAdd1];
always @(posedge Cclk)
    Reg_YMem2 <=  YMem2[readMemAdd2];
always @(posedge Cclk)
    Reg_YMem3 <=  YMem3[readMemAdd3];

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

wire [11:0] Reg_Cont_YMem0 = (Mem_cont[0]) ? Reg_YMem0 : 12'h000;
wire [11:0] Reg_Cont_YMem1 = (Mem_cont[1]) ? Reg_YMem1 : 12'h000;
wire [11:0] Reg_Cont_YMem2 = (Mem_cont[2]) ? Reg_YMem2 : 12'h000;
wire [11:0] Reg_Cont_YMem3 = (Mem_cont[3]) ? Reg_YMem3 : 12'h000;

reg [95:0] RGB4Pix;
always @(posedge Cclk or negedge rstn)
    if (!rstn) RGB4Pix <= {96{1'b0}};
     else if (Cnt_Div_Clk == 3'b000) RGB4Pix <= {Reg_Cont_YMem3[11:8],4'hf,Reg_Cont_YMem3[7:4],4'hf,Reg_Cont_YMem3[3:0],4'hf,
                                                   Reg_Cont_YMem2[11:8],4'hf,Reg_Cont_YMem2[7:4],4'hf,Reg_Cont_YMem2[3:0],4'hf,
                                                   Reg_Cont_YMem1[11:8],4'hf,Reg_Cont_YMem1[7:4],4'hf,Reg_Cont_YMem1[3:0],4'hf,
                                                   Reg_Cont_YMem0[11:8],4'hf,Reg_Cont_YMem0[7:4],4'hf,Reg_Cont_YMem0[3:0],4'hf
                                                   };

assign  HDMIdata = (REnslant[0]) ? RGB4Pix[23:0] :
                   (REnslant[1]) ? RGB4Pix[47:24] :
                   (REnslant[2]) ? RGB4Pix[71:48] :
                   (REnslant[3]) ? RGB4Pix[95:72] : 24'h000000;
  
assign s_axis_video_tready = 1'b1;   

/////////////////////////// End Of TRANSFRT DATA TO SCREAN  ///////////////////////////  
/////////////////////////// Transmit Data  ///////////////////////////  

/*
//reg tranData;
wire StartSPI;
reg StopSPI;
wire Busy;
wire Load_Next;
reg [11:0] SPIdatasave;
reg [7:0] SPIdataOut;
reg [1:0] SPIcount;

always @(posedge Cclk or negedge rstn)
    if (!rstn) tranData <= 1'b0;
     else if (CWadd == 20'h0603d) tranData <= 1'b1;
     else if (TRadd == 16'h9600) tranData <= 1'b0;

reg [1:0] DevtranData;
always @(posedge Cclk or negedge rstn)
    if (!rstn) DevtranData <= 2'b00;
     else DevtranData <= {DevtranData[0],tranData}; 
*/         

reg [11:0] Reg_TranData0;
reg [11:0] Reg_TranData1;
reg [11:0] Reg_TranData2;
reg [11:0] Reg_TranData3;
always @(posedge Cclk or negedge rstn)
    if (!rstn) Reg_TranData0 <= 12'h000;
     else if (Cnt_Div_Clk == 3'b010) Reg_TranData0 <= Reg_YMem0;
always @(posedge Cclk or negedge rstn)
    if (!rstn) Reg_TranData1 <= 12'h000;
     else if (Cnt_Div_Clk == 3'b010) Reg_TranData1 <= Reg_YMem1;
always @(posedge Cclk or negedge rstn)
    if (!rstn) Reg_TranData2 <= 12'h000;
     else if (Cnt_Div_Clk == 3'b010) Reg_TranData2 <= Reg_YMem2;
always @(posedge Cclk or negedge rstn)
    if (!rstn) Reg_TranData3 <= 12'h000;
     else if (Cnt_Div_Clk == 3'b010) Reg_TranData3 <= Reg_YMem3;
     
wire [11:0] TranInData[0:3]; 

assign TranInData[0] = Reg_TranData0;
assign TranInData[1] = Reg_TranData1;
assign TranInData[2] = Reg_TranData2;
assign TranInData[3] = Reg_TranData3;
     
 /*    

always @(posedge Cclk or negedge rstn)
    if (!rstn) SPIdatasave <= 12'h000;
     else if (Load_Next || StartSPI) SPIdatasave <= Reg_TranData0;

always @(posedge Cclk or negedge rstn)
    if (!rstn) SPIcount <= 2'b00;
     else if (SPIcount == 2'b11) SPIcount <= 2'b00;
     else if (StartSPI) SPIcount <= 2'b01;
     else if (!tranData) SPIcount <= 2'b00;
     else if (Load_Next) SPIcount <= SPIcount + 1;

always @(posedge Cclk or negedge rstn)
    if (!rstn) SPIdataOut <= 8'h00;
     else if (!tranData) SPIdataOut <= Reg_TranData0[7:0];
     else case (SPIcount)
            2'b00 : SPIdataOut <= Reg_TranData0[7:0];
            2'b01 : SPIdataOut <= {Reg_TranData0[3:0],SPIdatasave[11:8]};
            2'b10 : SPIdataOut <= Reg_TranData0[11:4];
          default : SPIdataOut <= Reg_TranData0[7:0];
        endcase
       
assign StartSPI = (DevtranData == 2'b01) ? 1'b1 : 1'b0;     

always @(posedge Cclk or negedge rstn)
    if (!rstn) StopSPI <= 1'b0;
     else if (DevtranData == 2'b10) StopSPI <= 1'b1;
     else if (Load_Next) StopSPI <= 1'b0;      
      
always @(posedge Cclk or negedge rstn) 
    if (!rstn) TRadd <= 16'h0000;
     else if (!tranData) TRadd <= 16'h0000;
     else if (StartSPI ) TRadd <= 16'h0001;
     else if (Load_Next && (SPIcount != 2'b01)) TRadd <= TRadd + 1;
          
CC1200SPI CC1200SPI_inst(
.clk (Cclk),
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
*/
wire Tran1Start = (CWadd == 20'h0603d) ? 1'b1 : 1'b0;
wire [15:0] TRadd_test;     

//wire [3:0] SCLK;               // output wire SCLK,
//wire [3:0] MOSI;               // output wire MOSI,
//wire [3:0] MISO;               // input  wire MISO,
//wire [3:0] CS_n;               // output wire CS_n
     

genvar i;
generate 
for (i=0;i<4;i=i+1) begin
    TxSPItran TxSPItran_inst(
    .clk (Cclk),               // input  wire clk ,
    .rstn(rstn),               // input  wire rstn,
                         //         
    .TranStart(Tran1Start),          // input  wire TranStart,
                         //         
    .TranInData(TranInData[i]),         // input  wire [11:0] TranInData,
                        //         
    .TRadd(TRadd[i]),              // output wire  [15:0] TRadd,
    
    .SCLK(SCLK[i]),               // output wire SCLK,
    .MOSI(MOSI[i]),               // output wire MOSI,
    .MISO(MISO[i]),               // input  wire MISO,
    .CS_n(CS_n[i])                // output wire CS_n
            );
end
endgenerate
endmodule
