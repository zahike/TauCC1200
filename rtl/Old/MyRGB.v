`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.09.2021 16:05:03
// Design Name: 
// Module Name: MyRGB
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


module MyRGB(
input  wire clk ,
input  wire rstn,
input  wire [23 : 0] s_axis_video_tdata    ,
output wire s_axis_video_tready            ,
input  wire s_axis_video_tvalid            ,
input  wire s_axis_video_tlast             ,
input  wire s_axis_video_tuser         ,
output wire [23 : 0] m_axis_video_tdata    ,
output wire m_axis_video_tvalid            ,
input  wire m_axis_video_tready            ,
output wire m_axis_video_tlast             ,
output wire m_axis_video_tuser             

//output [7:0] LR,
//output [7:0] LB,
//output [7:0] SR,
//output [7:0] SB
    );
localparam RYCONST = 256;
localparam GYCONST = 256;
localparam BYCONST = 256;

localparam RCBCONST  = 0;
localparam GCBCONST  = 88;
localparam BCB1CONST = 256;
localparam BCBCONST  = 198;

localparam RCR1CONST = 256;
localparam RCRCONST  = 103;
localparam GCRCONST  = 183;
localparam BCRCONST  = 0;

wire signed [8:0] oY  = {1'b0,s_axis_video_tdata  [7:0]} - 9'h010;
wire signed [8:0] oCb = {1'b0,s_axis_video_tdata [15:8]} - 9'h080;
wire signed [8:0] oCr = {1'b0,s_axis_video_tdata[23:16]} - 9'h080;

//wire signed [17:0] RY  = RYCONST*oY ;
//wire signed [17:0] RCb = RCBCONST*oCb;
//wire signed [17:0] RCr = RCR1CONST*oCr + RCRCONST*oCr;
                            
//wire signed [17:0] GY  = GYCONST*oY ;
//wire signed [17:0] GCb = GCBCONST*oCb;
//wire signed [17:0] GCr = GCRCONST*oCr;
                            
//wire signed [17:0] BY  = BYCONST*oY ;
//wire signed [17:0] BCb = BCB1CONST*oCb + BCBCONST*oCb;
//wire signed [17:0] BCr = BCRCONST*oCr;


reg signed [17:0] RY  ;
reg signed [17:0] RCb ;
reg signed [17:0] RCr ;

always @(posedge clk or negedge rstn)
    if (!rstn) RY  <= 18'h00000 ;
     else RY  <= RYCONST*oY ;
always @(posedge clk or negedge rstn)
    if (!rstn) RCb <= 18'h00000 ;
     else RCb <= RCBCONST*oCb;
always @(posedge clk or negedge rstn)
    if (!rstn) RCr <= 18'h00000 ;
     else RCr <= RCR1CONST*oCr + RCRCONST*oCr;

reg signed [17:0] GY  ;
reg signed [17:0] GCb ;
reg signed [17:0] GCr ;

always @(posedge clk or negedge rstn)
    if (!rstn) GY  <= 18'h00000 ;
     else GY  <= GYCONST*oY ;
always @(posedge clk or negedge rstn)
    if (!rstn) GCb <= 18'h00000 ;
     else GCb <= GCBCONST*oCb;
always @(posedge clk or negedge rstn)
    if (!rstn) GCr <= 18'h00000 ;
     else GCr <= GCRCONST*oCr;

reg signed [17:0] BY  ;
reg signed [17:0] BCb ;
reg signed [17:0] BCr ;

always @(posedge clk or negedge rstn)
    if (!rstn) BY  <= 18'h00000 ;
     else BY  <= BYCONST*oY ;
always @(posedge clk or negedge rstn)
    if (!rstn) BCb <= 18'h00000 ;
     else BCb <= BCB1CONST*oCb + BCBCONST*oCb;
always @(posedge clk or negedge rstn)
    if (!rstn) BCr <= 18'h00000 ;
     else BCr <= BCRCONST*oCr;

reg        Reg_m_axis_video_tvalid ;
reg        Reg_s_axis_video_tready ;
reg        Reg_m_axis_video_tlast  ;
reg        Reg_m_axis_video_tuser  ;

always @(posedge clk or negedge rstn)
    if (!rstn) Reg_m_axis_video_tvalid   <= 1'b0;  
     else Reg_m_axis_video_tvalid <= s_axis_video_tvalid;
always @(posedge clk or negedge rstn)
    if (!rstn) Reg_s_axis_video_tready   <= 1'b0;  
     else Reg_s_axis_video_tready <= m_axis_video_tready ;
always @(posedge clk or negedge rstn)
    if (!rstn) Reg_m_axis_video_tlast    <= 1'b0;  
     else Reg_m_axis_video_tlast  <= s_axis_video_tlast ;
always @(posedge clk or negedge rstn)
    if (!rstn) Reg_m_axis_video_tuser    <= 1'b0;  
     else Reg_m_axis_video_tuser  <= s_axis_video_tuser ;    


wire signed [17:0] SLongR = RY + RCb + RCr;
wire signed [17:0] SLongG = GY - GCb - GCr;
wire signed [17:0] SLongB = BY + BCb + BCr;

wire [15:0] LongR = (SLongR[17:15] == 3'b010) ? 16'hff00 : (SLongR[17:15] == 3'b111) ? 16'h0000 : SLongR ;
wire [15:0] LongG = (SLongG[17:15] == 3'b010) ? 16'hff00 : (SLongG[17:15] == 3'b111) ? 16'h0000 : SLongG ;
wire [15:0] LongB = (SLongB[17:15] == 3'b010) ? 16'hff00 : (SLongB[17:15] == 3'b111) ? 16'h0000 : SLongB ;

wire [7:0] R = oCr + oY;
wire [7:0] G = SLongG[15:8];
wire [7:0] B = oCb + oY;

reg [23:0] Reg1_m_axis_video_tdata  ;
reg        Reg1_m_axis_video_tvalid ;
reg        Reg1_s_axis_video_tready ;
reg        Reg1_m_axis_video_tlast  ;
reg        Reg1_m_axis_video_tuser  ;

always @(posedge clk or negedge rstn)
    if (!rstn) Reg1_m_axis_video_tdata    <= 24'h000000;  
     else Reg1_m_axis_video_tdata  <= {LongR[15:8],LongB[15:8],LongG[15:8]};
always @(posedge clk or negedge rstn)
    if (!rstn) Reg1_m_axis_video_tvalid   <= 1'b0;  
     else Reg1_m_axis_video_tvalid <= Reg_m_axis_video_tvalid;
always @(posedge clk or negedge rstn)
    if (!rstn) Reg1_s_axis_video_tready   <= 1'b0;  
     else Reg1_s_axis_video_tready <= Reg_s_axis_video_tready ;
always @(posedge clk or negedge rstn)
    if (!rstn) Reg1_m_axis_video_tlast    <= 1'b0;  
     else Reg1_m_axis_video_tlast  <= Reg_m_axis_video_tlast ;
always @(posedge clk or negedge rstn)
    if (!rstn) Reg1_m_axis_video_tuser    <= 1'b0;  
     else Reg1_m_axis_video_tuser  <= Reg_m_axis_video_tuser ;    

assign m_axis_video_tdata  = Reg1_m_axis_video_tdata ;
assign m_axis_video_tvalid = Reg1_m_axis_video_tvalid;
assign s_axis_video_tready = Reg1_s_axis_video_tready;
assign m_axis_video_tlast  = Reg1_m_axis_video_tlast ;
assign m_axis_video_tuser  = Reg1_m_axis_video_tuser ;


//assign LR = SLongR[15:8];
//assign LB = SLongB[15:8];
//assign SR = R;
//assign SB = B;
 
endmodule
