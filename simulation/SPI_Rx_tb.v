`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.11.2021 13:39:14
// Design Name: 
// Module Name: SPI_Rx_tb
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


module SPI_Rx_tb();
reg clk ;
reg APBclk;
reg rstn;
reg APBrstn;
initial begin 
clk     = 1'b0;
APBclk  = 1'b0;
rstn    = 1'b0;
APBrstn = 1'b0;
#100;
rstn    = 1'b1;
APBrstn = 1'b1;
end

always #4  clk    = ~clk;
always #10 APBclk = ~APBclk;


//SPI_Rx SPI_Rx_inst(
//.clk (clk ),
//.rstn(rstn),

//.SCLK(),
//.MOSI(),
//.MISO(),
//.CS_n()
//    );

reg TxRxn;
reg TxAndRx;

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

wire [3:0]  GPIO_OutEn;          // output [3:0]  GPIO_OutEn, 
wire [3:0]  GPIO_Out  ;            // output [3:0]  GPIO_Out,
reg  [3:0]  GPIO_In   ;             // input  [3:0]  GPIO_In,
                                // 
reg        GetDataEn;            // input        GetDataEn,
reg [11:0] GetData  ;              // input [11:0] GetData,
wire       Next_data;            // output       Next_data,
                                // 
wire [11:0] RxData ;              // output [11:0] RxData,
wire        RxValid;              // output       RxValid,
                                // 
wire FrameSync;                 // output FrameSync,
                                 // 
wire [15:0] CS_nCounter;    // output wire [15:0] CS_nCounter,
wire [7:0] ShiftMISO   ;       // output wire [7:0] ShiftMISO,
                                 // 
wire TxSCLK;                       // output SCLK,
wire TxMOSI;                       // output MOSI,
reg  TxMISO;                       // input  MISO,
wire TxCS_n;                       // output CS_n

wire RxSCLK;                       // output SCLK,
wire RxMOSI;                       // output MOSI,
wire RxMISO;                       // input  MISO,
wire RxCS_n;                       // output CS_n

initial begin 
TxMISO = 1'b0;
GetDataEn = 1'b0;            // input        GetDataEn,
GetData  = 12'h111;              // input [11:0] GetData,
TxRxn   = 1'b1;
TxAndRx = 1'b1; // config both
GPIO_In = 4'h0;
@(posedge rstn);
WriteAXI(32'h00000014,32'h00000004);
WriteAXI(32'h00000024,32'h00000010);
WriteAXI(32'h00000028,32'h00000010);
TxRxn   = 1'b0; // config Rx
TxAndRx = 1'b0; 
WriteAXI(32'h00000000,32'h00000004);
TxRxn   = 1'b1; // config Tx
TxAndRx = 1'b0; 
WriteAXI(32'h00000000,32'h00000002);
#1000;
GetDataEn = 1'b1;            // input        GetDataEn,
#1;
@(posedge Next_data);            // output       Next_data,
#1;
@(negedge Next_data);            // output       Next_data,
#1;
GetData  = 12'h222;              // input [11:0] GetData,
#1;
@(posedge Next_data);            // output       Next_data,
#1;
@(negedge Next_data);            // output       Next_data,
#1;
GetData  = 12'h333;              // input [11:0] GetData,
#1;
@(posedge Next_data);            // output       Next_data,
#1;
@(negedge Next_data);            // output       Next_data,
#1;
GetData  = 12'h444;              // input [11:0] GetData,
#1;
@(posedge Next_data);            // output       Next_data,
#1;
@(negedge Next_data);            // output       Next_data,
#1;
GetData  = 12'h555;              // input [11:0] GetData,
#1;
@(posedge Next_data);            // output       Next_data,
#1;
@(negedge Next_data);            // output       Next_data,
#1;
GetData  = 12'h666;              // input [11:0] GetData,
#1;
@(posedge Next_data);            // output       Next_data,
#1;
@(negedge Next_data);            // output       Next_data,
#1;
GetData  = 12'h777;              // input [11:0] GetData,
#1;
@(posedge Next_data);            // output       Next_data,
#1;
@(negedge Next_data);            // output       Next_data,
#1;
GetData  = 12'h888;              // input [11:0] GetData,
#1;
@(posedge Next_data);            // output       Next_data,
#1;
@(negedge Next_data);            // output       Next_data,
#1;
GetData  = 12'h999;              // input [11:0] GetData,
@(posedge TxCS_n);
GetDataEn = 1'b0;            // input        GetDataEn,
#1000;
GPIO_In = 4'h8;
#1000;
GPIO_In = 4'h0;

//@(posedge Next_data);            // output       Next_data,



/*
WriteAXI(32'h00000014,32'h00000004);
WriteAXI(32'h00000028,32'h00000010);
WriteAXI(32'h00000000,32'h00000004);
#1000;
GPIO_In = 4'h8;
#1000;
GPIO_In = 4'h0;

repeat (8) begin 
    @(negedge SCLK);
    #1;
    end
ShiftRegMISO = 32'h930b51de;
repeat (32) begin 
    @(negedge SCLK);
    #1;
    end
ShiftRegMISO = 32'h11212233;
repeat (32) begin 
    @(negedge SCLK);
    #1;
    end
ShiftRegMISO = 32'h43445565;
repeat (32) begin 
    @(negedge SCLK);
    #1;
    end
ShiftRegMISO = 32'h66778788;
repeat (32) begin 
    @(negedge SCLK);
    #1;
    end
ShiftRegMISO = 32'h00000000;
#1000;
*/

end


CC1200SPI_Top CC1200SPI_Tx_Top_inst(
.APBclk (APBclk ),
.clk    (clk    ),
.APBrstn(APBrstn),
.rstn   (rstn   ),

.APB_S_0_paddr  (S_APB_0_paddr  ), // input  [31:0] APB_S_0_paddr,
.APB_S_0_penable((TxAndRx || TxRxn) && S_APB_0_penable), // input         APB_S_0_penable,
.APB_S_0_prdata (TxS_APB_0_prdata ), // output [31:0] APB_S_0_prdata,
.APB_S_0_pready (TxS_APB_0_pready ), // output        APB_S_0_pready,
.APB_S_0_psel   ((TxAndRx || TxRxn) && S_APB_0_psel   ), // input         APB_S_0_psel,
.APB_S_0_pslverr(TxS_APB_0_pslverr), // output        APB_S_0_pslverr,
.APB_S_0_pwdata (S_APB_0_pwdata ), // input  [31:0] APB_S_0_pwdata,
.APB_S_0_pwrite (S_APB_0_pwrite ), // input         APB_S_0_pwrite,

.GPIO_OutEn(),                             // output [3:0]  GPIO_OutEn, 
.GPIO_Out  (),                               // output [3:0]  GPIO_Out,
.GPIO_In   (GPIO_In),                                // input  [3:0]  GPIO_In,
                                      // 
.GetDataEn(GetDataEn),                        // input        GetDataEn,
.GetData  (GetData  ),                          // input [11:0] GetData,
.Next_data(Next_data),                        // output       Next_data,
                                  // 
.RxData ( ),                          // output [11:0] RxData,
.RxValid(),                          // output       RxValid,
                                        // 
.FrameSync(FrameSync),                              // output FrameSync,
                                        // 
.CS_nCounter(),                // output wire [15:0] CS_nCounter,
.ShiftMISO  (),                   // output wire [7:0] ShiftMISO,
                                        // 
.SCLK(TxSCLK),                                   // output SCLK,
.MOSI(TxMOSI),                                   // output MOSI,
.MISO(TxMISO),                                   // input  MISO,
.CS_n(TxCS_n)                                    // output CS_n
    );

reg [1:0] DevTxSCLK;
always @(posedge clk or negedge rstn) 
    if (!rstn) DevTxSCLK <= 2'b00;
     else DevTxSCLK <= {DevTxSCLK[0],TxSCLK};
reg [1:0] DevRxSCLK;
always @(posedge clk or negedge rstn) 
    if (!rstn) DevRxSCLK <= 2'b00;
     else DevRxSCLK <= {DevRxSCLK[0],RxSCLK};
reg [140:0] ShiftMOSI2MISO;
reg [7:0] RxMISOadd;
always @(posedge TxSCLK or negedge rstn)
    if (!rstn) ShiftMOSI2MISO <= {141{1'b0}}; 
     else if (RxMISOadd > 7) ShiftMOSI2MISO <= {ShiftMOSI2MISO[139:0],TxMOSI};
     else ShiftMOSI2MISO <= {ShiftMOSI2MISO[139:0],1'b0};
    
always @(posedge clk or negedge rstn) 
    if (!rstn) RxMISOadd <= 8'h00;
     else if (DevTxSCLK == 2'b10) RxMISOadd <= RxMISOadd + 1;
     else if (DevRxSCLK == 2'b10) RxMISOadd <= RxMISOadd - 1;

assign RxMISO = ShiftMOSI2MISO[RxMISOadd-1];

CC1200SPI_Top CC1200SPI_Rx_Top_inst(
.APBclk (APBclk ),
.clk    (clk    ),
.APBrstn(APBrstn),
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
.GPIO_In   (GPIO_In),                                // input  [3:0]  GPIO_In,
                                      // 
.GetDataEn(GetDataEn),                        // input        GetDataEn,
.GetData  (GetData  ),                          // input [11:0] GetData,
.Next_data(),                        // output       Next_data,
                                  // 
.RxData (RxData ),                          // output [11:0] RxData,
.RxValid(RxValid),                          // output       RxValid,
                                        // 
.FrameSync(FrameSync),                              // output FrameSync,
                                        // 
.CS_nCounter(),                // output wire [15:0] CS_nCounter,
.ShiftMISO  (),                   // output wire [7:0] ShiftMISO,
                                        // 
.SCLK(RxSCLK),                                   // output SCLK,
.MOSI(RxMOSI),                                   // output MOSI,
.MISO(RxMISO),                                   // input  MISO,
.CS_n(RxCS_n)                                    // output CS_n
    );

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
    @(posedge APBclk);
    S_APB_0_paddr   = addr;
    S_APB_0_psel    = 1'b1;
    @(posedge APBclk);
    S_APB_0_penable    = 1'b1;
    while (~S_APB_0_pready) begin
        @(posedge APBclk);    
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


    @(posedge APBclk);
    S_APB_0_paddr   = addr;
    S_APB_0_pwdata  = data;
    S_APB_0_pwrite  = 1'b1;
    S_APB_0_psel    = 1'b1;
    @(posedge APBclk);
    S_APB_0_penable  = 1'b1;
    while (~S_APB_0_pready) begin
        @(posedge APBclk);    
        if (S_APB_0_pready) begin 
                S_APB_0_psel  = 1'b0;
                S_APB_0_penable  = 1'b0;
                end
    end
end 
endtask 

endmodule
