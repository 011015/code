`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:28:42 12/17/2021 
// Design Name: 
// Module Name:    comp 
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
module comp(
    input [31:0] A,
    input [31:0] B,
    input [3:0] CompOp,
    output out
    );
	 
	 localparam [3:0] beq = 1,bne = 2,bgez = 3,bgtz = 4,blez = 5,bltz = 6;
	 assign out = (CompOp == beq) ? A == B :
					  (CompOp == bne) ? A != B :
					  (CompOp == bgez) ? $signed(A) >= 0 :
					  (CompOp == bgtz) ? $signed(A) > 0 :
					  (CompOp == blez) ? $signed(A) <= 0 :
					  (CompOp == bltz) ? $signed(A) < 0 : 0;
	 
endmodule
