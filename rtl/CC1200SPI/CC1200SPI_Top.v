`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.11.2021 09:22:53
// Design Name: 
// Module Name: CC1200SPI_Top
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


module CC1200SPI_Top(
input  APBclk,
input  clk,
input  APBrstn,
input  rstn,

input  [31:0] APB_S_0_paddr,
input         APB_S_0_penable,
output [31:0] APB_S_0_prdata,
output        APB_S_0_pready,
input         APB_S_0_psel,
output        APB_S_0_pslverr,
input  [31:0] APB_S_0_pwdata,
input         APB_S_0_pwrite,

output [3:0]  GPIO_OutEn, 
output [3:0]  GPIO_Out,
input  [3:0]  GPIO_In,

input        GetDataEn,
input [11:0] GetData,
output       Next_data,
input        TranFrame,
input        FraimSync,
input [15:0] TranAdd,

output [11:0] RxData,
output        RxValid,
output        RxHeader,
output [15:0] RxAdd,
output        RxAddValid,
output signed [7:0]  CorThre,  //output [7:0]  CorThre,


output FrameSync,
output LineSync,

output wire [15:0] CS_nCounter,
output wire [7:0] ShiftMISO,

output SCLK,
output MOSI,
input  MISO,
output CS_n
    );

wire [31:0] RegVsync0  = 32'h93aaaade;
wire [31:0] RegVsync1  = 32'h935555de;
wire [31:0] RegHsync  = 32'h6cf4ae21;


wire        Start        ; // output        Start,
wire        Busy         ; // input         Busy,
wire [31:0] DataOut      ; // output [31:0] DataOut,
wire [31:0] DataIn       ; // input  [31:0] DataIn,
wire [3:0]  WR           ; // output [3:0]  WR,
wire [15:0] ClockDiv     ; // output [15:0] ClockDiv,
wire        Trans        ; // output Trans
wire        Receive      ; // output Receive
wire [7:0]  Tx_Pkt_size  ; // output [7:0] Tx_Pkt_size,
wire [7:0]  Rx_Pkt_size  ; // output [7:0] Rx_Pkt_size,
wire [15:0] Tx_wait      ; // output [15:0] Tx_wait,
wire  signed [7:0] RFpow ; // input  signed [7:0] RFpow,
CC1200SPI_Regs CC1200SPI_Regs_inst(
.clk(APBclk),
.rstn(APBrstn),

.APB_S_0_paddr  (APB_S_0_paddr  ),
.APB_S_0_penable(APB_S_0_penable),
.APB_S_0_prdata (APB_S_0_prdata ),
.APB_S_0_pready (APB_S_0_pready ),
.APB_S_0_psel   (APB_S_0_psel   ),
.APB_S_0_pslverr(APB_S_0_pslverr),
.APB_S_0_pwdata (APB_S_0_pwdata ),
.APB_S_0_pwrite (APB_S_0_pwrite ),

.Start      (Start      ),   // output        Start,
.Busy       (Busy       ),   // input         Busy,
.DataOut    (DataOut    ),   // output [31:0] DataOut,
.DataIn     (DataIn     ),   // input  [31:0] DataIn,
.WR         (WR         ),   // output [3:0]  WR,
.ClockDiv   (ClockDiv   ),   // output [15:0] ClockDiv,
.GPIO_OutEn (GPIO_OutEn ),   // output [3:0]  GPIO_OutEn, 
.GPIO_Out   (GPIO_Out   ),   // output [3:0]  GPIO_Out,
.GPIO_In    (GPIO_In    ),   // input  [3:0]  GPIO_In
.Tx_Pkt_size(Tx_Pkt_size),   // output [7:0] Tx_Pkt_size,
.Rx_Pkt_size(Rx_Pkt_size),   // output [7:0] Rx_Pkt_size,
.Tx_wait    (Tx_wait    ),   // output [15:0] Tx_wait,
.CorThre    (CorThre    ),  //output [7:0]  CorThre,
.RFpow      (RFpow      ), // input  signed [7:0] RFpow,


.Trans     (Trans     ),     // output Trans
.Receive   (Receive   ) // output Receive
    );

//////////////////////// Zynq Control SPI //////////////////////// 
wire [7:0] SPIDataIn;
reg [1:0] DevCS_n;
always @(posedge clk or negedge rstn)
    if (!rstn) DevCS_n <= 2'b00;
     else DevCS_n <= {DevCS_n[0],CS_n};
wire Load_Next;
reg [31:0] Send_Data;
always @(posedge clk or negedge rstn)
    if (!rstn) Send_Data <= 32'h00000000;
     else if (CS_n) Send_Data <= DataOut;
     else if ((DevCS_n == 2'b10) || Load_Next) Send_Data <= {Send_Data[23:0],8'h00}; 

reg [2:0] Rx_SPI_count;     
reg DelSCLK;
always @(posedge clk or negedge rstn)
    if (!rstn) DelSCLK <= 1'b0;
     else DelSCLK <= SCLK;
reg [31:0] Get_Data;
always @(posedge clk or negedge rstn)
    if (!rstn) Get_Data <= 32'h00000000;
     else if (!DelSCLK && SCLK) Get_Data <= {Get_Data[30:0],MISO}; 
assign DataIn = Get_Data;
assign ShiftMISO = Get_Data[7:0];

reg [4:0] CorCount;
always @(posedge clk or negedge rstn)
    if (!rstn) CorCount <= 5'h07;
     else if (CS_n) CorCount <= 5'h07;
     else if (DelSCLK && !SCLK) CorCount <= CorCount - 1;
 
//assign FrameSync = (Get_Data == RegVsync) ? 1'b1 : 1'b0;
//assign LineSync  = (Get_Data == RegHsync) ? 1'b1 : 1'b0;

reg signed [7:0] FramCorCount;
always @(posedge clk or negedge rstn)
    if (!rstn) FramCorCount <= 8'h00;
     else if (Rx_SPI_count == 3'b000) FramCorCount <= 8'h00;
     else if (Rx_SPI_count == 3'b111) FramCorCount <= 8'h00;
     else if ((!DelSCLK && SCLK) && (MISO == RegVsync0[CorCount])) FramCorCount <= FramCorCount + 1;
     else if ((!DelSCLK && SCLK) && (MISO != RegVsync0[CorCount])) FramCorCount <= FramCorCount - 1;
reg signed [7:0] LineCorCount;
always @(posedge clk or negedge rstn)
    if (!rstn) LineCorCount <= 8'h00;
     else if (Rx_SPI_count == 3'b000) LineCorCount <= 8'h00;
     else if (Rx_SPI_count == 3'b111) LineCorCount <= 8'h00;
     else if ((!DelSCLK && SCLK) && (MISO == RegHsync[CorCount])) LineCorCount <= LineCorCount + 1;
     else if ((!DelSCLK && SCLK) && (MISO != RegHsync[CorCount])) LineCorCount <= LineCorCount - 1;

assign FrameSync = (FramCorCount > CorThre) ? 1'b1 : 1'b0;
assign LineSync  = (LineCorCount > CorThre) ? 1'b1 : 1'b0;

assign RxAdd      = Get_Data[15:0];
assign RxAddValid = (Rx_SPI_count == 3'b110) ? Load_Next : 1'b0;
     
reg [3:0] Send_Stop;
always @(posedge clk or negedge rstn)
    if (!rstn) Send_Stop <= 4'h0;
     else if (CS_n) Send_Stop <= WR;
     else if (WR == 4'hf) Send_Stop <= WR;
     else if (Load_Next) Send_Stop <= {Send_Stop[2:0],1'b0}; 
//////////////////////// End Of Zynq Control SPI //////////////////////// 

/////////////////////////////////////////////////////////////////
/////////////////// Transmit Data from Memory ///////////////////
/////////////////////////////////////////////////////////////////
//Trans

//input        GetDataEn,
//input [11:0] GetData,
//output       Next_data,


//wire [7:0] Tx_Pkt_size = 8'h12;
wire [7:0] RegCommand = 8'h7F;
//reg TransOn;

reg TransOn;   
reg [7:0] TxByteCounter;
reg [19:0] TxWaitCounter;
reg [1:0] TxSM;
reg [1:0] TxSM_next;
always @(*)
    case (TxSM)
    2'b00 : if (TransOn) TxSM_next <= 2'b01;
             else TxSM_next <= 2'b00;
    2'b01 : if (GPIO_In[3]) TxSM_next <= 2'b10;
             else TxSM_next <= 2'b01;
    2'b10 : if (!GPIO_In[3]) TxSM_next <= 2'b11;
             else TxSM_next <= 2'b10;
    2'b11 : if (TxWaitCounter == Tx_wait) TxSM_next <= 2'b00;
             else TxSM_next <= 2'b11;
    default :  TxSM_next <= 2'b00;
    endcase         
always @(posedge clk or negedge rstn)
    if (!rstn) TxSM <= 2'b00;
     else TxSM <= TxSM_next;
                                 
always @(posedge clk or negedge rstn)
    if (!rstn) TransOn <= 1'b0;
     else if (TxByteCounter == Tx_Pkt_size) TransOn <= 1'b0;
     else if ((TxSM == 2'b00) && Trans && GetDataEn) TransOn <= 1'b1;
reg [1:0] DevTranStart;
always @(posedge clk or negedge rstn)
    if (!rstn) DevTranStart <= 2'b00;
     else DevTranStart <= {DevTranStart[0],TransOn};
     
always @(posedge clk or negedge rstn)
    if (!rstn) TxByteCounter <= 8'h00;
     else if (!TransOn) TxByteCounter <= 8'h00;
     else if (Load_Next) TxByteCounter <= TxByteCounter + 1;

always @(posedge clk or negedge rstn)
    if (!rstn) TxWaitCounter <= 20'h00000;
     else if (TxSM != 2'b11) TxWaitCounter <= 20'h00000;
     else TxWaitCounter <= TxWaitCounter + 1;
          
reg [2:0] Tran_SPI_count;
always @(posedge clk or negedge rstn) 
    if (!rstn) Tran_SPI_count <= 3'b000;
     else if (!TransOn) Tran_SPI_count <= 3'b000;
     else if (Tran_SPI_count == 3'b111) Tran_SPI_count <= 3'b111;
     else if (DevTranStart == 2'b01) Tran_SPI_count <=3'b001;  
     else if (Load_Next) Tran_SPI_count <= Tran_SPI_count + 1;  

reg [1:0] TxSPIdatactrl;
always @(posedge clk or negedge rstn) 
    if (!rstn) TxSPIdatactrl <= 2'b00;
     else if (Tran_SPI_count != 3'b111) TxSPIdatactrl <= 2'b00;
     else if (TxSPIdatactrl == 2'b11) TxSPIdatactrl <= 2'b00;
     else if (Load_Next) TxSPIdatactrl <= TxSPIdatactrl + 1;

wire [31:0] HeadTran = (TranFrame &&  FraimSync) ? RegVsync0 : 
                       (TranFrame && ~FraimSync) ? RegVsync1 : RegHsync;
     
reg [11:0] TxSavePreData;
always @(posedge clk or negedge rstn) 
    if (!rstn) TxSavePreData <= 12'h000;
     else if (Load_Next) TxSavePreData <= GetData;
    
wire [7:0] Byte2SPI = (Tran_SPI_count != 3'b111) ? 8'h00                             :
                      (TxSPIdatactrl == 2'b00)   ? GetData[7:0]                      :
                      (TxSPIdatactrl == 2'b01)   ? {GetData[3:0],TxSavePreData[11:8]}:
                      (TxSPIdatactrl == 2'b10)   ? TxSavePreData[11:4]               : 8'h00;
                      
assign Next_data = (Tran_SPI_count != 3'b111) ? 1'b0 : 
                   (TxSPIdatactrl  ==  2'b10) ? 1'b0 : Load_Next ;

/////////////////// End of Transmit Data from Memory ///////////////////

/////////////////////////////////////////////////////////////////
///////////////////  Receive data to Memory   ///////////////////
/////////////////////////////////////////////////////////////////
//GPIO_In
wire [7:0] RegRxCommand = 8'hFF;
//wire [7:0] Rx_Pkt_size  = 8'h14;

reg [1:0] DevRxPkt;
always @(posedge clk or negedge rstn)
    if (!rstn) DevRxPkt <= 2'b00;
     else DevRxPkt <= {DevRxPkt[0],GPIO_In[3]};
wire posRxPkt = (DevRxPkt == 3'b01) ? 1'b1 : 1'b0;
wire negRxPkt = (DevRxPkt == 3'b10) ? 1'b1 : 1'b0;

//Receive
reg ReadRxFIFO;
reg [7:0] ReadRxCounter;
always @(posedge clk or negedge rstn) 
    if (!rstn) ReadRxFIFO <= 1'b0;
     else if (negRxPkt) ReadRxFIFO <= 1'b1;
     else if (Load_Next && (ReadRxCounter == Rx_Pkt_size)) ReadRxFIFO <= 1'b0;

always @(posedge clk or negedge rstn) 
    if (!rstn) ReadRxCounter <= 8'h00;
     else if (!ReadRxFIFO) ReadRxCounter <= 8'h00;
     else if (Load_Next) ReadRxCounter <= ReadRxCounter + 1;

always @(posedge clk or negedge rstn) 
    if (!rstn) Rx_SPI_count <= 3'b000;
     else if (!ReadRxFIFO) Rx_SPI_count <= 3'b000;
     else if (Rx_SPI_count == 3'b111) Rx_SPI_count <= 3'b111;
//     else if (negRxPkt) Rx_SPI_count <=3'b001;  
     else if (Load_Next) Rx_SPI_count <= Rx_SPI_count + 1;  

reg Reg_RxHeader;
always @(posedge clk or negedge rstn)
    if (!rstn) Reg_RxHeader <= 1'b0;
     else if (!ReadRxFIFO) Reg_RxHeader <= 1'b0;
     else if (Load_Next &&(Rx_SPI_count == 3'b000)) Reg_RxHeader <= 1'b1;
     else if (Load_Next &&(Rx_SPI_count == 3'b110)) Reg_RxHeader <= 1'b0;
assign RxHeader = Reg_RxHeader;
     
reg [1:0] RxSPIdatactrl;
always @(posedge clk or negedge rstn) 
    if (!rstn) RxSPIdatactrl <= 2'b00;
     else if (Rx_SPI_count != 3'b111) RxSPIdatactrl <= 2'b00;
     else if (RxSPIdatactrl == 2'b11) RxSPIdatactrl <= 2'b00;
     else if (Load_Next) RxSPIdatactrl <= RxSPIdatactrl + 1;

reg [7:0] RxSavePreData;
always @(posedge clk or negedge rstn) 
    if (!rstn) RxSavePreData <= 8'h00;
     else if (Load_Next) RxSavePreData <= SPIDataIn;

reg signed [7:0] Reg_RFpow ; // input  signed [7:0] RFpow,
always @(posedge clk or negedge rstn) 
    if (!rstn) Reg_RFpow <= 8'h00;
     else if (Load_Next) Reg_RFpow <= RxSavePreData;
assign RFpow = Reg_RFpow;

assign RxData = (!ReadRxCounter) ? 8'h00                             :
                (RxSPIdatactrl == 2'b00)   ? 12'h000                    :
                (RxSPIdatactrl == 2'b01)   ? {SPIDataIn[3:0],RxSavePreData}:
                (RxSPIdatactrl == 2'b10)   ? {SPIDataIn,RxSavePreData[7:4]}: 8'h00;
                      
assign RxValid = (!ReadRxCounter) ? 1'b0 : 
                 (|RxSPIdatactrl) ? Load_Next : 1'b0;
     
/////////////////// End of Receive data to Memory   ///////////////////
                     
wire SPIstart = (Trans)   ? (DevTranStart == 2'b01) : 
                (Receive) ? negRxPkt : Start;
//wire SPIstop  = (Trans) ? (DevTranStart == 2'b00) : 
wire SPIstop  = (Trans) ? !TransOn : 
                (Receive && (ReadRxCounter != Rx_Pkt_size)) ? 1'b0 :
                (Receive && (ReadRxCounter == Rx_Pkt_size)) ? 1'b1 :
                 Send_Stop[2];

wire [7:0] SPIdata = 
                     (Trans && (Tran_SPI_count == 3'b000)) ? RegCommand       :
                     (Trans && (Tran_SPI_count == 3'b001)) ? HeadTran[31:24]  :
                     (Trans && (Tran_SPI_count == 3'b010)) ? HeadTran[23:16]  :
                     (Trans && (Tran_SPI_count == 3'b011)) ? HeadTran[15: 8]  :
                     (Trans && (Tran_SPI_count == 3'b100)) ? HeadTran[ 7: 0]  :
                     (Trans && (Tran_SPI_count == 3'b101)) ? TranAdd[15: 8]  :
                     (Trans && (Tran_SPI_count == 3'b110)) ? TranAdd[ 7: 0]  :
                     (Trans && (Tran_SPI_count == 3'b111)) ? Byte2SPI         : 
                     (Receive && !ReadRxFIFO)              ? RegRxCommand     :
                     (Receive &&  ReadRxFIFO)              ? 8'h00            :
                     Send_Data[23:16];
                   
                   
CC1200SPI CC1200SPI_inst(
.clk (clk),
.rstn(rstn),

.Start   (SPIstart            ),  // input         Start,
.Stop    (SPIstop      ),  // input         Stop,
.Busy    (Busy             ),  // output        Busy,
.DataOut (SPIdata ),  // input  [7:0] DataOut,
.DataIn  (SPIDataIn        ),  // output [7:0] DataIn,
.ClockDiv(ClockDiv         ),  // input  [15:0] ClockDiv,

.Load_Next(Load_Next),         //   output Load_Next,

.SCLK(SCLK),
.MOSI(MOSI),
.MISO(MISO),
.CS_n(CS_n)
    );

reg DelCS_n;
always @(posedge clk or negedge rstn)
    if (!rstn) DelCS_n <= 1'b0;
     else DelCS_n <= CS_n;
//reg DelSCLK;
//always @(posedge clk or negedge rstn)
//    if (!rstn) DelSCLK <= 1'b0;
//     else DelSCLK <= SCLK;
reg [15:0] Reg_CS_nCounter;
always @(posedge clk or negedge rstn)
    if (!rstn) Reg_CS_nCounter <= 16'h0000;
     else if (CS_n && !DelCS_n) Reg_CS_nCounter <= Reg_CS_nCounter + 1;
assign CS_nCounter = Reg_CS_nCounter;    
//reg [7:0] Reg_ShiftMISO;
//always @(posedge clk or negedge rstn)
//    if (!rstn) Reg_ShiftMISO <= 8'h00;
////     else if (CS_n) Reg_ShiftMISO <= 8'h00;
//     else if (DelSCLK && !SCLK) Reg_ShiftMISO <= {Reg_ShiftMISO[6:0],MISO};
//assign ShiftMISO = Reg_ShiftMISO;     
endmodule
