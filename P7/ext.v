`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:29:27 12/17/2021 
// Design Name: 
// Module Name:    ext 
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
module ext(
	 input [15:0] imm16,
    input [2:0] ExtOp,
    output [31:0] ext_data
    );
	 
	 localparam [2:0] ZeroExt = 1,SignExt = 2,lui = 3;
	 assign ext_data = (ExtOp == ZeroExt) ? {16'b0,imm16} :
							 (ExtOp == SignExt) ? {{16{imm16[15]}},imm16} :
							 (ExtOp == lui) ? {imm16,16'b0} : 0;
endmodule
