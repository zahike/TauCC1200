`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.08.2021 09:40:28
// Design Name: 
// Module Name: SCCBGPIO_Top
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


module SCCBGPIO_Top(
input  clk,
input  rstn,

input  [31:0] S_APB_0_paddr,
input         S_APB_0_penable,
output [31:0] S_APB_0_prdata,
output        S_APB_0_pready,
input         S_APB_0_psel,
output        S_APB_0_pslverr,
input  [31:0] S_APB_0_pwdata,
input         S_APB_0_pwrite,

output sccb_clk,
output sccb_clk_en,
output sccb_data_out,
input  sccb_data_in,
output sccb_data_en,

output        GPIO 

    );

wire        Start   ;    
wire        Busy    ;     
wire [31:0] DataOut ;  
wire [7:0] ReadData  ;   
wire [3:0]  WR      ;       
wire [15:0] ClockDiv; 
wire [15:0] NegDel  ; 
    
RegisterBlock RegisterBlock_insy
(
.clk             (clk             ),                    // input  clk,                     
.rstn            (rstn            ),                   // input  rstn,                    

.APB_S_0_paddr   (S_APB_0_paddr   ),   // input  [31:0] APB_M_0_paddr,    
.APB_S_0_penable (S_APB_0_penable ), // input         APB_M_0_penable,  
.APB_S_0_prdata  (S_APB_0_prdata  ),  // output [31:0] APB_M_0_prdata,   
.APB_S_0_pready  (S_APB_0_pready  ),  // output        APB_M_0_pready,   
.APB_S_0_psel    (S_APB_0_psel    ),    // input         APB_M_0_psel,     
.APB_S_0_pslverr (S_APB_0_pslverr ), // output        APB_M_0_pslverr,  
.APB_S_0_pwdata  (S_APB_0_pwdata  ),  // input  [31:0] APB_M_0_pwdata,   
.APB_S_0_pwrite  (S_APB_0_pwrite  ),  // input         APB_M_0_pwrite,   

.Start           (Start           ),        // output        Start,            
.Busy            (Busy            ),        // input         Busy,             
.DataOut         (DataOut         ),        // output [31:0] DataOut,          
.DataIn          ({24'h000000,ReadData}),        // input  [31:0] DataIn,           
.WR              (WR              ),        // output [3:0]  WR,               
.ClockDiv        (ClockDiv        ),        // output [15:0] ClockDiv,         
.NegDel          (NegDel          ),         // output [15:0] NegDel    
.GPIO            (GPIO            )          //output        GPIO         
        );

SCCB SCCB_inst(
.clk            (clk          ),    //input clk            ,  
.rstn           (rstn         ),    //input rstn           ,  

.ClkDiv         (ClockDiv     ),    //input [15:0] ClkDiv  ,  
.NegDel         (NegDel       ),    //input [15:0] NegDel  ,  

.Start          (Start        ),    //input Start          ,  
.WR             (WR           ),    //input [3:0] WR       ,  
.DataIn        (DataOut       ),    //input [31:0] DataIn  ,  
.Busy          (Busy         ),    //output Busy          ,  
.ReadData      (ReadData     ),    //output [7:0] ReadData,  

.sccb_clk      (sccb_clk     ),    //output sccb_clk      ,  
.sccb_clk_en   (sccb_clk_en  ),    //output sccb_clk_en   ,  
.sccb_data_out (sccb_data_out),    //output sccb_data_out ,  
.sccb_data_in  (sccb_data_in ),    //input  sccb_data_in  ,  
.sccb_data_en  (sccb_data_en )    //output sccb_data_en     

    );

    
endmodule
