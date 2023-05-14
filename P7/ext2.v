`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:29:39 12/17/2021 
// Design Name: 
// Module Name:    ext2 
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
module ext2(
    input [1:0] A,
    input [31:0] Din,
    input [2:0] Op,
    output [31:0] Dout
    );
	 
	 localparam [2:0] lw = 0,lbu = 1,lb = 2,lhu = 3,lh = 4;
	 wire [7:0] data_byte;
	 wire [15:0] data_half;
	 
	 assign data_byte = (A == 2'b00) ? Din[7:0] :
							  (A == 2'b01) ? Din[15:8] :
							  (A == 2'b10) ? Din[23:16] :
							  (A == 2'b11) ? Din[31:24] : 0;
							  
	 assign data_half = (A[1] == 1'b0) ? Din[15:0] :
							  (A[1] == 1'b1) ? Din[31:16] : 0;
							  
	 assign Dout = (Op == lbu) ? {24'b0,data_byte} :
						(Op == lb) ? {{24{data_byte[7]}},data_byte} :
						(Op == lhu) ? {16'b0,data_half} :
						(Op == lh) ? {{16{data_half[15]}},data_half} : Din;
endmodule
