`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/12/2021 08:39:46 AM
// Design Name: 
// Module Name: DDS_cont
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


module DDS_cont(
input  clk                       ,
input  rstn                      ,
                                 
input         S_APB_0_axiclk     ,
input         S_APB_0_aresetn    ,
input  [31:0] S_APB_0_paddr      ,
input         S_APB_0_penable    ,
output [31:0] S_APB_0_prdata     ,
output        S_APB_0_pready     ,
input         S_APB_0_psel       ,
output        S_APB_0_pslverr    ,
input  [31:0] S_APB_0_pwdata     ,
input         S_APB_0_pwrite     ,

input [3:0] Test,

input  TransValid                ,
input [5:0] Trans0Data           ,
input [5:0] Trans1Data           ,
input [5:0] Trans2Data           ,
input [5:0] Trans3Data           ,
                                 
output DDS_PCLK                  ,
output DDS_IOup                  ,
output DDS_CSn                   ,
output DDS_RWn                   ,
output DDS_ReadEn                ,
output [7:0] DDS_DataOut         ,
input  [7:0] DDS_DataIn          
    );

wire        Start             ;// output        Start
wire        Busy              ;// input         Busy
wire [31:0] DataOut           ;// output [31:0] DataOut
wire [31:0] DataIn            ;// input  [31:0] DataIn
wire        WR                ; // output        WR
wire        Send              ; // output        Send

DDS_Regs DDS_Regs_inst(
.APB_0_axiclk    (S_APB_0_axiclk ) ,// input         S_APB_0_axiclk
.APB_0_aresetn   (S_APB_0_aresetn) ,// input         S_APB_0_aresetn

.APB_S_0_paddr   (S_APB_0_paddr  ) ,// input  [31:0] APB_S_0_paddr
.APB_S_0_penable (S_APB_0_penable) ,// input         APB_S_0_penable
.APB_S_0_prdata  (S_APB_0_prdata ) ,// output [31:0] APB_S_0_prdata
.APB_S_0_pready  (S_APB_0_pready ) ,// output        APB_S_0_pready
.APB_S_0_psel    (S_APB_0_psel   ) ,// input         APB_S_0_psel
.APB_S_0_pslverr (S_APB_0_pslverr) ,// output        APB_S_0_pslverr
.APB_S_0_pwdata  (S_APB_0_pwdata ) ,// input  [31:0] APB_S_0_pwdata
.APB_S_0_pwrite  (S_APB_0_pwrite ) ,// input         APB_S_0_pwrite

.Start           (Start          ) ,// output        Start
.Busy            (Busy           ) ,// input         Busy
.DataOut         (DataOut        ) ,// output [31:0] DataOut
.DataIn          (DataIn         ) ,// input  [31:0] DataIn
.WR              (WR             ) ,// output        WR
.Send            (Send           )  // output        Send
    );
    
//reg Cclk;
//always @(posedge clk or negedge rstn)
//    if (!rstn) Cclk <= 1'b0;
//     else Cclk <= ~Cclk;    
wire Cclk = clk;
reg [5:0] TimeCounter;
always @(posedge Cclk or negedge rstn)
    if (!rstn) TimeCounter <= 6'h00;
     else if (TimeCounter == 6'h18) TimeCounter <= 6'h00;
     else if (!Test[0] && Send && TransValid) TimeCounter <= 6'h16;
     else TimeCounter <= TimeCounter + 1;

 reg [1:0] DevStart;
always @(posedge Cclk or negedge rstn)
    if (!rstn) DevStart <= 2'b00;
     else DevStart <= {DevStart[0],Start};
reg DtartW4Zero;
always @(posedge Cclk or negedge rstn)
    if (!rstn) DtartW4Zero <= 1'b0;
     else if (DevStart == 2'b01) DtartW4Zero <= 1'b1;
     else if (TimeCounter == 6'h00) DtartW4Zero <= 1'b0;
reg [3:0] ValidDel;
always @(posedge Cclk or negedge rstn)
    if (!rstn) ValidDel <= 4'h0;
     else ValidDel <= {ValidDel[2:0],TransValid};     
reg RWtran;
always @(posedge Cclk or negedge rstn)
    if (!rstn) RWtran <= 1'b0;
     else if (|Test) RWtran <= 1'b1;
     else if ((TimeCounter == 6'h16) && DtartW4Zero) RWtran <= 1'b1;
//     else if (Send && TransValid) RWtran <= 1'b1;
     else if (Send && |ValidDel) RWtran <= 1'b1;
     else if  ((TimeCounter == 6'h18) && !DtartW4Zero) RWtran <= 1'b0;         
assign Busy =  RWtran || DtartW4Zero;  

reg RegPclk;
always @(posedge Cclk or negedge rstn) 
    if (!rstn) RegPclk <= 1'b0;
     else if (TimeCounter == 6'h18) RegPclk <= 1'b1;         
     else if (TimeCounter[1] == 1'b0) RegPclk <= 1'b0;         
     else if (TimeCounter[1] == 1'b1) RegPclk <= 1'b1;         

reg RegCS;
always @(posedge Cclk or negedge rstn) 
    if (!rstn) RegCS <= 1'b1;
     else if (!RWtran) RegCS <= 1'b1;
     else if (TransValid) RegCS <= 1'b1;
     else if (TimeCounter == 6'h00) RegCS <= 1'b0;
     else if (TimeCounter == 6'h08) RegCS <= 1'b1;
     else if (TimeCounter == 6'h0c) RegCS <= 1'b0;
     else if (TimeCounter == 6'h14) RegCS <= 1'b1;

reg RegRWn;
always @(posedge Cclk or negedge rstn) 
    if (!rstn) RegRWn <= 1'b0;
     else if (Send && TransValid) RegRWn <= 1'b0;
     else if (TimeCounter == 6'h00) RegRWn <= WR;

reg [5:0] TranDDSdata0Del;
always @(posedge Cclk or negedge rstn)
    if (!rstn) TranDDSdata0Del <= 6'h00;
     else if (TransValid) TranDDSdata0Del <= Trans0Data;

reg SwitchTestData;
reg [5:0] TestDDSdata;
reg [5:0] MainDDStestData;
always @(posedge Cclk or negedge rstn)
    if (!rstn) SwitchTestData <= 1'b0;
     else if (TimeCounter == 6'h13) SwitchTestData <= ~SwitchTestData;
wire Switch = (Test[2]) ? SwitchTestData : 1'b0;   
always @(posedge Cclk or negedge rstn)
    if (!rstn) TestDDSdata <= 6'h00;
     else if (!Switch && (TimeCounter == 6'h13) && (TestDDSdata == 6'h1f)) TestDDSdata <= 6'h3f;    
     else if (!Switch && (TimeCounter == 6'h13) && (TestDDSdata == 6'h3f)) TestDDSdata <= 6'h00;    
     else if (!Switch && (TimeCounter == 6'h13))  TestDDSdata <= TestDDSdata + 1;    
wire [5:0] data1 = (Test[1]) ? TestDDSdata : 6'h00;
always @(posedge Cclk or negedge rstn)
    if (!rstn) MainDDStestData <= 6'h00;
     else if (!Switch && (TimeCounter == 6'h13) && (TestDDSdata == 6'h3f) && (MainDDStestData == 6'h1f)) MainDDStestData <= 6'h3f;    
     else if (!Switch && (TimeCounter == 6'h13) && (TestDDSdata == 6'h3f) && (MainDDStestData == 6'h3f)) MainDDStestData <= 6'h00;    
     else if (!Switch && (TimeCounter == 6'h13) && (TestDDSdata == 6'h3f))  MainDDStestData <= MainDDStestData + 1;    
wire [5:0] data2 = (Test[1]) ? MainDDStestData : 6'h3f;

wire [5:0] SelTranDDSdata = (Test == 4'h0) ? TranDDSdata0Del : 
                            (Test == 4'h1) ? TestDDSdata :
                            (Switch) ? data1 : data2 ;
//                            (SwitchTestData) ? 6'h00 : 6'h3f;
wire [31:0] FreqDDSdata;
FreqLUT FreqLUT_inst(
.clk (Cclk ),
.rstn(rstn),

.FreqNum (SelTranDDSdata),
//.FreqNum (Trans0Data),
.FreqData(FreqDDSdata)
    );
wire [31:0] data2send0 = (Send) ? FreqDDSdata : DataOut;

reg [7:0] RegData0;
always @(posedge Cclk or negedge rstn)
    if (!rstn) RegData0 <= 8'h00;
     else if (!RWtran) RegData0 <= 8'h00;
     else if (TimeCounter == 6'h18) RegData0 <= data2send0[31:24];
     else if (TimeCounter == 6'h04) RegData0 <= data2send0[23:16];
     else if (TimeCounter == 6'h0b) RegData0 <= data2send0[15:8];
     else if (TimeCounter == 6'h10) RegData0 <= data2send0[7:0];

reg ReadData;
always @(posedge Cclk or negedge rstn) 
    if (!rstn) ReadData <= 1'b0;
     else if (!RegRWn || !RWtran) ReadData <= 1'b0;
     else if (TimeCounter == 6'h04) ReadData <= 1'b1;
     else if (TimeCounter == 6'h0c) ReadData <= 1'b0;
     else if (TimeCounter == 6'h10) ReadData <= 1'b1;
     else if (TimeCounter == 6'h17) ReadData <= 1'b0;

reg [31:0] RegDataIn;
always @(posedge Cclk or negedge rstn)
    if (!rstn) RegDataIn <= 32'h00000000;
     else if (!RegRWn || !RWtran) RegDataIn <= RegDataIn;
     else if (TimeCounter == 6'h03) RegDataIn <= {DDS_DataIn,RegDataIn[23:0]};                  //DataOut[31:24];
     else if (TimeCounter == 6'h0b) RegDataIn <= {RegDataIn[31:24],DDS_DataIn,RegDataIn[15:0]}; //DataOut[23:16];
     else if (TimeCounter == 6'h0f) RegDataIn <= {RegDataIn[31:16],DDS_DataIn,RegDataIn[7:0]};  //DataOut[15:8];
     else if (TimeCounter == 6'h17) RegDataIn <= {RegDataIn[31:8],DDS_DataIn};                  //DataOut[7:0];
     
assign DataIn = RegDataIn;

assign DDS_PCLK     = RegPclk;
assign DDS_IOup     = (RWtran && !RegRWn && (TimeCounter == 6'h18)) ? 1'b1 : 1'b0; 
assign DDS_CSn      = RegCS;
assign DDS_RWn      = RegRWn;
assign DDS_ReadEn   = ReadData;
assign DDS_DataOut  = RegData0;
   
endmodule
