`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.11.2021 13:34:13
// Design Name: 
// Module Name: Drone_Rx_Top
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


module Drone_Rx_Top(
input       sys_clock       ,
output      hdmi_tx_clk_n   ,
output      hdmi_tx_clk_p   ,
output [2:0]hdmi_tx_data_n  ,
output [2:0]hdmi_tx_data_p  ,
input  [3:0] sw,
input  [3:0] btn,
input  [3:0] ja_p,
input  [3:0] ja_n,
input  [4:1] jb_p,
input  [4:1] jb_n,
input  [4:1] jc_p,
input  [4:1] jc_n,
input  [4:1] jd_n,
input  [4:1] jd_p,
input  [8:1] je
    );

wire clk ;
wire rstn;
wire PixelClk;            // output wire PixelClk;

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
  clk_wiz_0 clk_wiz_0_inst
   (
    // Clock out ports
    .clk_out1(clk),     // output clk_out1
    // Status and control signals
    .locked(rstn),       // output locked
   // Clock in ports
    .clk_in1(sys_clock));      // input clk_in1

//reg [2:0] Cnt_Div_Clk;
//always @(posedge clk or negedge rstn)
//    if (!rstn) Cnt_Div_Clk <= 3'b000;
//     else if (Cnt_Div_Clk == 3'b100) Cnt_Div_Clk <= 3'b000;
//     else Cnt_Div_Clk <= Cnt_Div_Clk + 1;
//reg Reg_Div_Clk;
//always @(posedge clk or negedge rstn)
//    if (!rstn) Reg_Div_Clk <= 1'b0;
//     else if (Cnt_Div_Clk == 3'b000)  Reg_Div_Clk <= 1'b1;
//     else if (Cnt_Div_Clk == 3'b010)  Reg_Div_Clk <= 1'b0;

//   BUFG BUFG_inst (
//      .O(PixelClk), // 1-bit output: Clock output
//      .I(Reg_Div_Clk)  // 1-bit input: Clock input
//   );

wire [7:0] TestDataE;
wire [7:0] TestDataD;
wire [7:0] TestDataC;
wire [7:0] TestDataB;

wire [5 : 0] Receive0Data = TestDataE[5:0];  // input wire [5 : 0] Receive0Data;
wire [5 : 0] Receive1Data = TestDataD[5:0];  // input wire [5 : 0] Receive1Data;
wire [5 : 0] Receive2Data = TestDataC[5:0];  // input wire [5 : 0] Receive2Data;
wire [5 : 0] Receive3Data = TestDataB[5:0];  // input wire [5 : 0] Receive3Data;
wire [3 : 0] FrameEven;    // output wire [3 : 0] FrameEven;
wire [3 : 0] FrameAdd;     // output wire [3 : 0] FrameAdd;
wire [3 : 0] HSync;        // output wire [3 : 0] HSync;
//wire [3 : 0] Mem_cont;      // input wire [3 : 0] Mem_cont;
wire FraimSync;            // output wire FraimSync;
wire [1 : 0] FraimSel = 2'b00;      // input wire [1 : 0] FraimSel;
//wire PixelClk;             // output wire PixelClk;
wire HVsync;                // input wire HVsync;
wire HMemRead;              // input wire HMemRead;
wire pVDE;                  // input wire pVDE;
wire [23 : 0] HDMIdata;    // output wire [23 : 0] HDMIdata;

wire Out_pVSync;          // output wire Out_pVSync;
wire Out_pHSync;          // output wire Out_pHSync;
wire Out_pVDE;            // output wire Out_pVDE;
wire Mem_Read;            // output wire Mem_Read;

  SlantReceiver #(
    .FRAME1(24'HAAB155),
    .FRAME0(24'HAA8D55),
    .HSYNC(8'B01010101)
  ) SlantReceiver_inst (
    .clk(clk),
    .rstn(rstn),
    .Receive0Data(Receive0Data),
    .Receive1Data(Receive1Data),
    .Receive2Data(Receive2Data),
    .Receive3Data(Receive3Data),
    .FrameEven(FrameEven),
    .FrameAdd(FrameAdd),
    .HSync(HSync),
//    .Mem_cont(Mem_cont),
    .FraimSync(FraimSync),
    .FraimSel(FraimSel),
    .PixelClk(PixelClk),
    .HVsync(Out_pVSync),
    .HMemRead(Mem_Read),
    .pVDE(Out_pVDE),
    .HDMIdata(HDMIdata)
  );


wire [23 : 0] Out_pData;  // output wire [23 : 0] Out_pData; 
//wire FraimSync = 1'b0;          // input wire TxFraimSync;
wire [23 : 0] Mem_Data;  // input wire [23 : 0] TxMem_Data;
assign Mem_Data = (Mem_Read) ? 24'hff0000 : 24'h000000;
  HDMIdebug HDMIdebug_inst (
    .clk(PixelClk),
    .rstn(rstn),
    .Out_pData(Out_pData),
    .Out_pVSync(Out_pVSync),
    .Out_pHSync(Out_pHSync),
    .Out_pVDE(Out_pVDE),
    .Mem_Read(Mem_Read),
    .FraimSync(FraimSync),
    .Mem_Data (HDMIdata)
  );

rgb2dvi rgb2dvi_inst (
      // DVI 1.0 TMDS video interface
      .TMDS_Clk_p  (hdmi_tx_clk_p ), // : out std_logic;
      .TMDS_Clk_n  (hdmi_tx_clk_n ), // : out std_logic;
      .TMDS_Data_p (hdmi_tx_data_p), // : out std_logic_vector(2 downto 0);
      .TMDS_Data_n (hdmi_tx_data_n), // : out std_logic_vector(2 downto 0);
      
      // Auxiliary signals 
      .aRst   (~rstn), // : in std_logic; --asynchronous reset; must be reset when RefClk is not within spec
      .aRst_n (rstn), // : in std_logic; --asynchronous reset; must be reset when RefClk is not within spec
      
      // Video in
      .vid_pData  (Out_pData), // : in std_logic_vector(23 downto 0);
      .vid_pVDE   (Out_pVDE), // : in std_logic;
      .vid_pHSync (Out_pVSync), // : in std_logic;
      .vid_pVSync (Out_pHSync), // : in std_logic;
      .PixelClk   (PixelClk), // : in std_logic; --pixel-clock recovered from the DVI interface
      
      .SerialClk (clk) // : in std_logic
      ); 

//wire [7:0] TestDataB;
//wire [7:0] TestDataC;
//wire [7:0] TestDataD;
//wire [7:0] TestDataE;
reg [7:0] Reg_TestDataB;
reg [7:0] Reg_TestDataC;
reg [7:0] Reg_TestDataD;
reg [7:0] Reg_TestDataE;

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
ila_0 ila_0_inst (
	.clk(clk), // input wire clk

	.probe0(rstn), // input wire [0:0]  probe0  
	.probe1(Out_pData), // input wire [23:0]  probe1 
	.probe2(Out_pVDE), // input wire [0:0]  probe2 
	.probe3(Out_pVSync), // input wire [0:0]  probe3 
	.probe4(Out_pHSync), // input wire [0:0]  probe4 
	.probe5(PixelClk), // input wire [0:0]  probe5
	.probe6(TestDataB), // input wire [7:0]  probe6 
    .probe7(TestDataC), // input wire [7:0]  probe7 
    .probe8(TestDataD), // input wire [7:0]  probe8 
    .probe9(TestDataE), // input wire [7:0]  probe9
	.probe10(Reg_TestDataB), // input wire [7:0]  probe10 
    .probe11(Reg_TestDataC), // input wire [7:0]  probe11 
    .probe12(Reg_TestDataD), // input wire [7:0]  probe12 
    .probe13(Reg_TestDataE), // input wire [7:0]  probe13
	.probe14(FrameEven), // input wire [3:0]  probe14 
    .probe15(FrameAdd), // input wire [3:0]  probe15 
    .probe16(HSync   ) // input wire [3:0]  probe16
);


assign TestDataB[0] = jb_p[1];
assign TestDataB[1] = jb_n[1];
assign TestDataB[2] = jb_p[2];
assign TestDataB[3] = jb_n[2];
assign TestDataB[4] = jb_p[3];
assign TestDataB[5] = jb_n[3];
assign TestDataB[6] = jb_p[4];
assign TestDataB[7] = jb_n[4];

assign TestDataC[0] = jc_n[1];
assign TestDataC[1] = jc_p[1];
assign TestDataC[2] = jc_n[2];
assign TestDataC[3] = jc_p[2];
assign TestDataC[4] = jc_n[3];
assign TestDataC[5] = jc_p[3];
assign TestDataC[6] = jc_n[4];
assign TestDataC[7] = jc_p[4];

assign TestDataD[0] = jd_p[1];
assign TestDataD[1] = jd_n[1];
assign TestDataD[2] = jd_p[2];
assign TestDataD[3] = jd_n[2];
assign TestDataD[4] = jd_p[3];
assign TestDataD[5] = jd_n[3];
assign TestDataD[6] = jd_p[4];
assign TestDataD[7] = jd_n[4];

assign TestDataE[0] = je  [1];
assign TestDataE[1] = je  [2];
assign TestDataE[2] = je  [3];
assign TestDataE[3] = je  [4];
assign TestDataE[4] = je  [5];
assign TestDataE[5] = je  [6];
assign TestDataE[6] = je  [7];
assign TestDataE[7] = je  [8];


always @(posedge clk or negedge rstn)
    if (!rstn) Reg_TestDataB <= 8'h00;
     else Reg_TestDataB <= TestDataB;  
always @(posedge clk or negedge rstn)
    if (!rstn) Reg_TestDataC <= 8'h00;
     else Reg_TestDataC <= TestDataC;  
always @(posedge clk or negedge rstn)
    if (!rstn) Reg_TestDataD <= 8'h00;
     else Reg_TestDataD <= TestDataD;  
always @(posedge clk or negedge rstn)
    if (!rstn) Reg_TestDataE <= 8'h00;
     else Reg_TestDataE <= TestDataE;  
endmodule
