`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/04/2021 11:40:34 AM
// Design Name: 
// Module Name: writeRxData
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


module writeRxData(
input wire clk,
input wire rstn,

input wire [5:0] ReceiveData,

output wire WriteRxY,
output wire WriteRxC,
output wire [16:0] WriteRxAdd,

output wire FrameEven ,        
output wire FrameAdd  ,        
output wire HSync            
    );
parameter FRAME1 = 24'haab155;
parameter FRAME0 = 24'haa8d55;
parameter HSYNC  = 8'h55;
    
wire Sync0 = (ReceiveData > 6'h1f) ? 1'b1 : 1'b0;
reg [1:0] DevRe0Data;
always @(posedge clk or negedge rstn) 
    if (!rstn) DevRe0Data <= 2'b00;
     else DevRe0Data <= {DevRe0Data[0],Sync0};
wire PosRe0Data = (DevRe0Data == 2'b01) ? 1'b1 : 1'b0;     
wire NegRe0Data = (DevRe0Data == 2'b10) ? 1'b1 : 1'b0;

reg [7:0] Bit0MeasureCount;
reg [7:0] EndOfBit;
reg [7:0] BitTime0Counter;
reg [7:0] configBitTime [0:3];
reg [4:0] configBitSR;
reg SetBitTime;

always @(posedge clk or negedge rstn)
    if (!rstn) SetBitTime <= 1'b0;
     else if (ReceiveData > 6'h1f) SetBitTime <= 1'b1;
     else if (Bit0MeasureCount > 8'h24) SetBitTime <= 1'b0;

always @(posedge clk or negedge rstn)
    if (!rstn) Bit0MeasureCount <= 8'h00;
     else if (!SetBitTime) Bit0MeasureCount <= 8'h00;      
     else if (PosRe0Data || NegRe0Data) Bit0MeasureCount <= 8'h00;      
     else Bit0MeasureCount <= Bit0MeasureCount + 1;
     
always @(posedge clk or negedge rstn)
    if (!rstn) begin 
            configBitTime[0] <= 8'h00;
            configBitTime[1] <= 8'h00;
            configBitTime[2] <= 8'h00;
            configBitTime[3] <= 8'h00;
            configBitSR      <= 5'h00;
         end 
     else if (!SetBitTime) begin 
            configBitTime[0] <= 8'h00;
            configBitTime[1] <= 8'h00;
            configBitTime[2] <= 8'h00;
            configBitTime[3] <= 8'h00;
            configBitSR      <= 5'h00;
         end
     else if (PosRe0Data || NegRe0Data) begin 
                configBitTime[0] <= Bit0MeasureCount;
                configBitTime[1] <= configBitTime[0];
                configBitTime[2] <= configBitTime[1];
                configBitTime[3] <= configBitTime[2];
                configBitSR      <= {configBitSR[3:0],SetBitTime};
             end

wire [9:0] avrageBitTime = configBitTime[3] + configBitTime[2] + configBitTime[1] + configBitTime[0];


always @(posedge clk or negedge rstn)
    if (!rstn) EndOfBit <= 8'h18;
     else if (configBitSR == 5'h1f) EndOfBit <= avrageBitTime[9:2];
    
always @(posedge clk or negedge rstn)
    if (!rstn) BitTime0Counter <= 8'h00;
     else if (PosRe0Data || NegRe0Data) BitTime0Counter <= 8'h00;      
     else if (BitTime0Counter == EndOfBit) BitTime0Counter <= 8'h00;      
     else BitTime0Counter <= BitTime0Counter + 1;

reg [23:0] SyncShiftReg;
always @(posedge clk or negedge rstn) 
    if (!rstn) SyncShiftReg <= 24'h000000;
     else if (BitTime0Counter == 8'h14) SyncShiftReg <= {SyncShiftReg[22:0],Sync0};
assign FrameEven = (SyncShiftReg == FRAME1) ? 1'b1 : 1'b0;         
assign FrameAdd  = (SyncShiftReg == FRAME0) ? 1'b1 : 1'b0;         
assign HSync     = (SyncShiftReg == {16'h0000,HSYNC}) ? 1'b1 : 1'b0;         


reg Frame0_received;
reg [17:0] Frame0_nextLine;
reg [17:0] RXadd0;
always @(posedge clk or negedge rstn)
    if (!rstn) Frame0_received <= 1'b0;
     else if (FrameEven || FrameAdd) Frame0_received <= 1'b1; 
     else if (RXadd0 == 18'h12C00) Frame0_received <= 1'b0;
always @(posedge clk or negedge rstn)
    if (!rstn) Frame0_nextLine <= 18'h0009e;
     else if (FrameEven || FrameAdd) Frame0_nextLine <= 18'h0009e;    
     else if ((BitTime0Counter == 8'h00) && HSync) Frame0_nextLine <= Frame0_nextLine + 18'h000a0;    
always @(posedge clk or negedge rstn)
    if (!rstn) RXadd0 <= 18'h00000;
     else if (FrameEven || FrameAdd) RXadd0 <= 18'h00000;
     else if ((BitTime0Counter == 8'h16) && HSync) RXadd0 <= Frame0_nextLine;
     else if (BitTime0Counter == 8'h16) RXadd0 <= RXadd0 + 1;

assign WriteRxY   = Frame0_received && (BitTime0Counter == 8'h14) && !RXadd0[0];
assign WriteRxC   = Frame0_received && (BitTime0Counter == 8'h14) &&  RXadd0[0];
assign WriteRxAdd = RXadd0[17:1];
    
endmodule
