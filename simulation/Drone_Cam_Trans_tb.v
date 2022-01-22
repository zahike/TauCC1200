`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.09.2021 20:05:47
// Design Name: 
// Module Name: Drone_Cam_Trans_tb
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


module Drone_Cam_Trans_tb();
reg clk;
reg aclk;
reg rstn;
reg HDMIrstn;
initial begin 
clk = 1'b0;
aclk = 1'b0;
rstn = 1'b0;
HDMIrstn = 1'b0;
#100;
rstn = 1'b1;
#2500000;
#300;
HDMIrstn = 1'b1;
end
always #4 clk = ~clk;
always #10 aclk = ~aclk;

wire [31:0] TxS_APB_0_prdata  ;  // output [31:0] APB_S_0_prdata,
wire        TxS_APB_0_pready  ;  // output        APB_S_0_pready,
wire        TxS_APB_0_pslverr ; // output        APB_S_0_pslverr,
wire [31:0] RxS_APB_0_prdata  ;  // output [31:0] APB_S_0_prdata,
wire        RxS_APB_0_pready  ;  // output        APB_S_0_pready,
wire        RxS_APB_0_pslverr ; // output        APB_S_0_pslverr,

reg  [31:0] S_APB_0_paddr   ;   // input  [31:0] APB_S_0_paddr,
reg         S_APB_0_penable ; // input         APB_S_0_penable,
wire [31:0] S_APB_0_prdata  = TxS_APB_0_prdata | RxS_APB_0_prdata;  // output [31:0] APB_S_0_prdata,
wire        S_APB_0_pready  = TxS_APB_0_pready || RxS_APB_0_pready;  // output        APB_S_0_pready,
reg         S_APB_0_psel    ;    // input         APB_S_0_psel,
wire        S_APB_0_pslverr = TxS_APB_0_pready || RxS_APB_0_pready; // output        APB_S_0_pslverr,
reg  [31:0] S_APB_0_pwdata  ;  // input  [31:0] APB_S_0_pwdata,
reg         S_APB_0_pwrite  ;  // input         APB_S_0_pwrite,

wire        m_axis_video_tready;   // output        s_axis_video_tready, 
wire [31:0] m_axis_video_tdata ;   // input  [23:0] s_axis_video_tdata , 
reg         m_axis_video_tvalid;   // input         s_axis_video_tvalid, 
reg         m_axis_video_tuser ;   // input         s_axis_video_tuser , 
reg         m_axis_video_tlast ;   // input         s_axis_video_tlast , 


TxSyntPic TxSyntPic_inst(
.clk (clk ),
.rstn(rstn),

.SelStat(1'b1),

.s_axis_video_tdata  (32'h00000000)       ,
.s_axis_video_tready (m_axis_video_tready),
.s_axis_video_tvalid (m_axis_video_tvalid),
.s_axis_video_tlast  (m_axis_video_tlast) ,
.s_axis_video_tuser  (m_axis_video_tuser) ,
.m_axis_video_tdata  (m_axis_video_tdata) ,
.m_axis_video_tvalid ()                   ,
.m_axis_video_tready (1'b1)               ,
.m_axis_video_tlast  ()                   ,
.m_axis_video_tuser  ()     
    );
 
initial begin 
m_axis_video_tvalid = 0;   // input         s_axis_video_tvalid, 
m_axis_video_tuser  = 0;   // input         s_axis_video_tuser , 
m_axis_video_tlast  = 0;   // input         s_axis_video_tlast , 
@(posedge rstn);
#100;
repeat (15)begin 
        wrLine(1);
        repeat (479) wrLine(0);
//        repeat (1000000) @(posedge clk);
        #4620608;
        @(posedge clk);
    end
#1000000;    
$finish;    
end

wire TxPixelClk ;

 wire [31 : 0] Ms_axis_video_tdata  = m_axis_video_tdata ; //input  wire [23 : 0] s_axis_video_tdata    , 
 wire          Ms_axis_video_tready    ; //output wire s_axis_video_tready            , 
 wire          Ms_axis_video_tvalid = m_axis_video_tvalid ; //input  wire s_axis_video_tvalid            , 
 wire          Ms_axis_video_tlast  = m_axis_video_tlast ; //input  wire s_axis_video_tlast             , 
 wire          Ms_axis_video_tuser  = m_axis_video_tuser ; //input  wire s_axis_video_tuser         ,     
// wire [23 : 0] Mm_axis_video_tdata    ; //output wire [23 : 0] m_axis_video_tdata    , 
// wire          Mm_axis_video_tvalid   ; //output wire m_axis_video_tvalid            , 
// wire          Mm_axis_video_tready   ;// = 1'b1; //input  wire m_axis_video_tready            , 
// wire          Mm_axis_video_tlast    ; //output wire m_axis_video_tlast             , 
// wire          Mm_axis_video_tuser    ; //output wire m_axis_video_tuser               

wire HVsync                     ;                        // input HVsync,                      
wire TxFraimSync;
wire HMemRead                   ;                      // input HMemRead,                    
wire  [23:0] TxHDMIdata_Slant     ;   // output [11:0] HDMIdata             
wire [23 : 0] Out_pData;
wire Out_pHSync;
wire pVDE;

wire  TransValid;
wire [7:0] Trans0Data;
wire [7:0] Trans1Data;
wire [7:0] Trans2Data;
wire [7:0] Trans3Data;

wire TranEn          ;
wire [11:0] TranData ;
wire NextData        ;
wire TranFrame       ; // output TranFrame
wire [15:0] TranAdd  ; //output [15:0] TranAdd,

wire TxSCLK;                       // output SCLK,
wire TxMOSI;                       // output MOSI,
reg  TxMISO;                       // input  MISO,
wire TxCS_n;                       // output CS_n

wire RxSCLK;                       // output SCLK,
wire RxMOSI;                       // output MOSI,
wire RxMISO;                       // input  MISO,
wire RxCS_n;                       // output CS_n

  
TxMem TxMem_inst(
.Cclk               (clk),                       // input Cclk,                        
.rstn               (rstn),                      // input rstn,                        

.Mem_cont           (4'hf),
.s_axis_video_tready(Ms_axis_video_tready),       // output        s_axis_video_tready, 
.s_axis_video_tdata (Ms_axis_video_tdata ),       // input  [23:0] s_axis_video_tdata , 
.s_axis_video_tvalid(Ms_axis_video_tvalid),       // input         s_axis_video_tvalid, 
.s_axis_video_tuser (Ms_axis_video_tuser ),       // input         s_axis_video_tuser , 
.s_axis_video_tlast (Ms_axis_video_tlast ),       // input         s_axis_video_tlast , 

.FraimSync          (TxFraimSync          ),
.PixelClk           (TxPixelClk           ),       // input Hclk,                        
.FraimSel           (1'b00               ),

.HVsync             (HVsync             ),       // input HVsync,                      
.HMemRead           (HMemRead           ),       // input HMemRead,         
.pVDE               (pVDE               ),       // output        Out_pVDE  ,
.HDMIdata           (TxHDMIdata_Slant   ),        // output [11:0] HDMIdata    

//.SCLK(SCLK),
//.MOSI(MOSI),
//.MISO(MISO),
//.CS_n(CS_n),

//.TransValid(TransValid),
//.Trans0Data(Trans0Data),//output [7:0] Trans0Data,
//.Trans1Data(Trans1Data),//output [7:0] Trans1Data,
//.Trans2Data(Trans2Data),//output [7:0] Trans2Data,
//.Trans3Data(Trans3Data) //output [7:0] Trans3Data,   

.TranEn  (TranEn  ),     // output TranEn,      
.TranData(TranData),   // output [11:0] TranData,
.NextData(NextData),    // input NextData
.TranFrame(TranFrame), // output TranFrame    
.TranAdd (TranAdd) // output [15:0] TranAdd,  
    );

reg SelHDMI;
initial SelHDMI = 1'b1;
always @(TxFraimSync) SelHDMI = ~SelHDMI;
  TxHDMI TxHDMI_inst (
    .clk(TxPixelClk),
    .rstn(HDMIrstn),
    .SelHDMI(SelHDMI),
    .Out_pData(Out_pData),
    .Out_pVSync(HVsync),
    .Out_pHSync(Out_pHSync),
    .Out_pVDE(pVDE),
    .FraimSync(TxFraimSync),
    .Mem_Read(HMemRead),
    .Mem_Data(TxHDMIdata_Slant)
  );
  

wire [3 : 0] GPIO_OutEn;   // output wire [3 : 0] GPIO_OutEn;
wire [3 : 0] GPIO_Out;     // output wire [3 : 0] GPIO_Out;
reg  [3 : 0] TxGPIO_In;      // input  wire [3 : 0] GPIO_In;
reg  [3 : 0] RxGPIO_In;      // input  wire [3 : 0] GPIO_In;
wire GetDataEn;            // input  wire GetDataEn;
wire [11 : 0] GetData;     // input  wire [11 : 0] GetData;
wire Next_data;            // output wire Next_data;
wire [11 : 0] RxData;      // output wire [11 : 0] RxData;
wire RxValid;              // output wire RxValid;
wire FrameSync;            // output wire FrameSync;
wire [15 : 0] CS_nCounter; // output wire [15 : 0] CS_nCounter;
wire [7 : 0] ShiftMISO;    // output wire [7 : 0] ShiftMISO;
reg TxRxn;
reg TxAndRx;
reg NewSpi;

initial begin
TxGPIO_In = 4'h0;
RxGPIO_In = 4'h0;
TxRxn   = 1'b0;
TxAndRx = 1'b1; // config both
TxMISO = 1'b0;
NewSpi = 1'b0;
@(posedge rstn);
#1000;
WriteAXI(32'h00000014,32'h00000004);
WriteAXI(32'h00000024,32'h0000007e);
WriteAXI(32'h00000028,32'h00000080);
WriteAXI(32'h00000030,32'h00000018);
//WriteAXI(32'h0000002c,32'h00000012);
TxRxn   = 1'b0; // config Rx
TxAndRx = 1'b0; 
WriteAXI(32'h00000000,32'h00000004);
TxRxn   = 1'b1; // config Tx
TxAndRx = 1'b0; 
WriteAXI(32'h00000000,32'h00000002);
TxRxn   = 1'b0;

while (1) begin
    @(posedge TxCS_n);
    TxGPIO_In = 4'h8;
    #1000;
    @(posedge clk);
    #1;
    RxGPIO_In = 4'h8;
    #1000;
    @(posedge clk);
    #1;
    RxGPIO_In = 4'h0;
//    @(posedge RxCS_n);
#100000;
    @(posedge clk);
    #1;
    NewSpi = 1'b1;
    #100;
    @(posedge clk);
    #1;
    NewSpi = 1'b0;   
    TxGPIO_In = 4'h0;
end 
end 

  CC1200SPI_Top CC1200SPI_Tx_Top_inst (                    
    .APBclk(aclk),                      // input wire APBclk;
    .clk(clk),                            // input wire clk;
    .APBrstn(rstn),                    // input wire APBrstn;
    .rstn(rstn),                          // input wire rstn;
    .APB_S_0_paddr  (S_APB_0_paddr  ),      // input wire [31 : 0] APB_S_0_paddr;
    .APB_S_0_penable((TxAndRx || TxRxn) && S_APB_0_penable),    // input wire APB_S_0_penable;
    .APB_S_0_prdata (TxS_APB_0_prdata ),     // output wire [31 : 0] APB_S_0_prdata;
    .APB_S_0_pready (TxS_APB_0_pready ),     // output wire APB_S_0_pready;
    .APB_S_0_psel   ((TxAndRx || TxRxn) && S_APB_0_psel   ),       // input wire APB_S_0_psel;
    .APB_S_0_pslverr(TxS_APB_0_pslverr),    // output wire APB_S_0_pslverr;
    .APB_S_0_pwdata (S_APB_0_pwdata ),     // input wire [31 : 0] APB_S_0_pwdata;
    .APB_S_0_pwrite (S_APB_0_pwrite ),     // input wire APB_S_0_pwrite;
    .GPIO_OutEn(GPIO_OutEn),              // output wire [3 : 0] GPIO_OutEn;
    .GPIO_Out(GPIO_Out),                  // output wire [3 : 0] GPIO_Out;
    .GPIO_In(TxGPIO_In),                    // input wire [3 : 0] GPIO_In;
    .GetDataEn(TranEn),                // input wire GetDataEn;
    .GetData(TranData),                    // input wire [11 : 0] GetData;
    .Next_data(NextData),                // output wire Next_data;
    .TranFrame(TranFrame),               // output TranFrame     
    .FraimSync(TxFraimSync),              // input        FraimSync, 
    .TranAdd (TranAdd),                  // output [15:0] TranAdd,  
    .RxData (),//RxData),                      // output wire [11 : 0] RxData;
    .RxValid(),//RxValid),                    // output wire RxValid;
    .Out_Off_Link(1'b0),//Out_Off_Link), //output Out_Off_Link,
    .FrameSync(FrameSync),                // output wire FrameSync;
    .CS_nCounter(CS_nCounter),            // output wire [15 : 0] CS_nCounter;
    .ShiftMISO(ShiftMISO),                // output wire [7 : 0] ShiftMISO;
    .SCLK(TxSCLK),                          // output wire SCLK;
    .MOSI(TxMOSI),                          // output wire MOSI;
    .MISO(TxMISO),                          // input wire MISO;
    .CS_n(TxCS_n)                           // output wire CS_n;
  );

reg [1:0] DevTxSCLK;
always @(posedge clk or negedge rstn) 
    if (!rstn) DevTxSCLK <= 2'b00;
     else DevTxSCLK <= {DevTxSCLK[0],TxSCLK};
reg [1:0] DevRxSCLK;
always @(posedge clk or negedge rstn) 
    if (!rstn) DevRxSCLK <= 2'b00;
     else DevRxSCLK <= {DevRxSCLK[0],RxSCLK};

reg [1123:0] ShiftMOSI2MISO;
reg [11:0] RxMISOadd;
always @(posedge TxSCLK or negedge rstn)
    if (!rstn) ShiftMOSI2MISO <= {{1107{1'b0}},16'h3081}; 
     else if (NewSpi) ShiftMOSI2MISO <= {{1107{1'b0}},16'h3081}; 
     else if (RxMISOadd > 12'h017) ShiftMOSI2MISO <= {ShiftMOSI2MISO[1123:16],TxMOSI,16'h3081};
//     else ShiftMOSI2MISO <= {ShiftMOSI2MISO[1023:0],1'b0};

always @(posedge clk or negedge rstn) 
    if (!rstn) RxMISOadd <= 12'h010;
     else if (NewSpi) RxMISOadd <= 12'h010;
     else if (DevTxSCLK == 2'b10) RxMISOadd <= RxMISOadd + 1;
     else if (DevRxSCLK == 2'b10) RxMISOadd <= RxMISOadd - 1;

assign RxMISO = (!RxCS_n) ? ShiftMOSI2MISO[RxMISOadd-1] : 1'b0;

wire        RxHeader;           // output        RxHeader,
wire [15:0] RxAdd     ;        // output [15:0] RxAdd,
wire        RxAddValid;        // output        RxAddValid,
wire signed [7:0]  CorThre;  //output [7:0]  CorThre,

wire   Out_Off_Link   ;     //output Out_Off_Link,

CC1200SPI_Top CC1200SPI_Rx_Top_inst(
.APBclk (aclk ),
.clk    (clk    ),
.APBrstn(rstn),
.rstn   (rstn   ),

.APB_S_0_paddr  (S_APB_0_paddr  ), // input  [31:0] APB_S_0_paddr,
.APB_S_0_penable((TxAndRx || !TxRxn) && S_APB_0_penable), // input         APB_S_0_penable,
.APB_S_0_prdata (RxS_APB_0_prdata ), // output [31:0] APB_S_0_prdata,
.APB_S_0_pready (RxS_APB_0_pready ), // output        APB_S_0_pready,
.APB_S_0_psel   ((TxAndRx || !TxRxn) && S_APB_0_psel   ), // input         APB_S_0_psel,
.APB_S_0_pslverr(RxS_APB_0_pslverr), // output        APB_S_0_pslverr,
.APB_S_0_pwdata (S_APB_0_pwdata ), // input  [31:0] APB_S_0_pwdata,
.APB_S_0_pwrite (S_APB_0_pwrite ), // input         APB_S_0_pwrite,

.GPIO_OutEn(),                             // output [3:0]  GPIO_OutEn, 
.GPIO_Out  (),                               // output [3:0]  GPIO_Out,
.GPIO_In   (RxGPIO_In),                                // input  [3:0]  GPIO_In,
                                      // 
.GetDataEn(),                        // input        GetDataEn,
.GetData  (),                          // input [11:0] GetData,
.Next_data(),                        // output       Next_data,
                                  // 
.RxData    (RxData ),                          // output [11:0] RxData,
.RxValid   (RxValid),                          // output       RxValid,
.RxHeader  (RxHeader),              // output        RxHeader,
.RxAdd     (RxAdd     ),        // output [15:0] RxAdd,
.RxAddValid(RxAddValid),        // output        RxAddValid,
.CorThre   (CorThre),              //output [7:0]  CorThre
.Out_Off_Link(Out_Off_Link),//output Out_Off_Link,
                  // 
.FrameSync(),//FrameSync),            // output FrameSync,
.LineSync (),//LineSync ),            // output LineSync,                                        
 
.CS_nCounter(),                // output wire [15:0] CS_nCounter,
.ShiftMISO  (),                   // output wire [7:0] ShiftMISO,
                                        // 
.SCLK(RxSCLK),                                   // output SCLK,
.MOSI(RxMOSI),                                   // output MOSI,
.MISO(RxMISO),                                   // input  MISO,
.CS_n(RxCS_n)                                    // output CS_n
    );

//initial begin 
////#3100000;
//force RxGPIO_In = 4'h0;
////#2000000;
//force RxMem_inst.mainWD = 32'h04407000;
//@(posedge clk);
//#1;
//@(posedge clk);
//#1;
//release RxMem_inst.mainWD;
////force RxGPIO_In = 4'h4;

////release RxGPIO_In;
//////@(RxMem_inst.Reg_Pck_WD_count == 20'h05000);
//////force RxMem_inst.Reg_Pck_WD_count = 20'h23480;
//////@(posedge clk);
//////release RxMem_inst.Reg_Pck_WD_count;
//end
wire PixelClk;          // output wire PixelClk;
wire [15 : 0] DEWMadd;  // output wire [15 : 0] DEWMadd;
//wire HVsync;             // input wire HVsync;
//wire HMemRead;           // input wire HMemRead;
//wire pVDE;               // input wire pVDE;
wire [23 : 0] HDMIdata; // output wire [23 : 0] HDMIdata;

  RxMem RxMem_inst (
    .Cclk(clk),
    .rstn(rstn),
//    .FraimSync(FrameSync),
//    .LineSync (LineSync ),
    .RxData(RxData),
    .RxValid(RxValid),
    .RxHeader(RxHeader), // input        RxHeader,    
    .RxAdd     (RxAdd     ),
    .RxAddValid(RxAddValid), 
    .CorThre(CorThre),  //input [7:0]  CorThre,   
    .PixelClk(PixelClk),
    .Out_Off_Link(Out_Off_Link),  //output Out_Off_Link,
    .SCLK(RxSCLK),
    .MOSI(RxMOSI),
    .MISO(RxMISO),
    .CS_n(RxCS_n),
//    .DEWMadd(DEWMadd),
    .HVsync(HVsync),
    .HMemRead(HMemRead),
    .pVDE(pVDE),
    .HDMIdata(HDMIdata)
  );
  
////////////////////////////// End Of mem test //////////////////////////////
task wr4fix;
begin 
m_axis_video_tvalid = 1'b1;   
repeat (4) @(posedge clk);
#1;
m_axis_video_tvalid = 1'b0;   
repeat (3) @(posedge clk);
#1;
end 
endtask

task wr4fix_frame;
input frame;
begin 
m_axis_video_tvalid = 1'b1;   
m_axis_video_tuser  = 1'b0;
m_axis_video_tlast  = 1'b0;
repeat (2) @(posedge clk);
#1;
 m_axis_video_tlast  = 1'b1;
@(posedge clk);#1;
m_axis_video_tlast  = 1'b0;
if (frame)m_axis_video_tuser  = 1'b1;
@(posedge clk);#1;
m_axis_video_tvalid = 1'b0;   
repeat (3) @(posedge clk);
#1;
m_axis_video_tuser  = 1'b0;
repeat (3) wr4fix;
end 
endtask

task wr16pix;
begin 
repeat (7) @(posedge clk);
#1;
repeat (4) wr4fix;
end 
endtask

task wrLine;
input frame;
begin 
wr4fix_frame(frame);
repeat (39) wr16pix;
repeat (1750) @(posedge clk);
#1;
end
endtask

//////////////////////////////////////////////////
/////////////// Read/write tasks /////////////////
//////////////////////////////////////////////////

task ReadAXI;
input [31:0] addr;
begin 
    S_APB_0_paddr    = 0; // input  [31:0] S_APB_0_paddr      ,
    S_APB_0_penable  = 0; // input         S_APB_0_penable    ,
    S_APB_0_psel     = 0; // input         S_APB_0_psel       ,
    S_APB_0_pwdata   = 0; // input  [31:0] S_APB_0_pwdata     ,
    S_APB_0_pwrite   = 0; // input         S_APB_0_pwrite     ,
    @(posedge aclk);
    S_APB_0_paddr   = addr;
    S_APB_0_psel    = 1'b1;
    @(posedge aclk);
    S_APB_0_penable    = 1'b1;
    while (~S_APB_0_pready) begin
        @(posedge aclk);    
        if (S_APB_0_pready) begin 
                S_APB_0_psel  = 1'b0;
                S_APB_0_penable  = 1'b0;
                end
    end
end 
endtask 


task WriteAXI;
input [31:0] addr;
input [31:0] data;
begin 
    S_APB_0_paddr    = 0; // input  [31:0] S_APB_0_paddr      ,
    S_APB_0_penable  = 0; // input         S_APB_0_penable    ,
    S_APB_0_psel     = 0; // input         S_APB_0_psel       ,
    S_APB_0_pwdata   = 0; // input  [31:0] S_APB_0_pwdata     ,
    S_APB_0_pwrite   = 0; // input         S_APB_0_pwrite     ,


    @(posedge aclk);
    S_APB_0_paddr   = addr;
    S_APB_0_pwdata  = data;
    S_APB_0_pwrite  = 1'b1;
    S_APB_0_psel    = 1'b1;
    @(posedge aclk);
    S_APB_0_penable  = 1'b1;
    while (~S_APB_0_pready) begin
        @(posedge aclk);    
        if (S_APB_0_pready) begin 
                S_APB_0_psel  = 1'b0;
                S_APB_0_penable  = 1'b0;
                end
    end
end 
endtask 

endmodule
