`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:47:02 12/19/2021 
// Design Name: 
// Module Name:    bridge 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`include "constant.v"
module bridge(
    input [31:0] CPU_Addr,
	 input [3:0] CPU_byteen,
    input [31:0] CPU_WD,
	 input [31:0] DM_RD,
	 input [31:0] TIMER0_RD,
	 input [31:0] TIMER1_RD,
	 output [31:0] DEV_Addr,
	 output [3:0] DM_byteen,
	 output [31:0] DM_WD,
	 output TIMER0_WE,
	 output TIMER1_WE,
	 output [31:0] DEV_RD
    );
	 
	 assign DEV_Addr = CPU_Addr;
	 assign DM_byteen = CPU_byteen;
	 assign DM_WD = CPU_WD;
	 
	 assign TIMER0_WE =(CPU_Addr >= `start_addr_timer0) && (CPU_Addr <= `end_addr_timer0) && (|CPU_byteen);
	 assign TIMER1_WE =(CPU_Addr >= `start_addr_timer1) && (CPU_Addr <= `end_addr_timer1) && (|CPU_byteen);
	 
	 assign DEV_RD = (CPU_Addr >= `start_addr_dm) && (CPU_Addr <= `end_addr_dm) ? DM_RD :
						  (CPU_Addr >= `start_addr_timer0) && (CPU_Addr <= `end_addr_timer0) ? TIMER0_RD :
						  (CPU_Addr >= `start_addr_timer1) && (CPU_Addr <= `end_addr_timer1) ? TIMER1_RD : 0;
	 
endmodule
