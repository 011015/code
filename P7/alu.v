`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:28:14 12/17/2021 
// Design Name: 
// Module Name:    alu 
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
module alu(
    input [31:0] A,
    input [31:0] B,
    input [4:0] shamt,
    input [3:0] ALUOp,
	 output overflow,
    output [31:0] out
    );
	 
	 localparam [3:0] add = 1,sub = 2,slt = 3,sltu = 4,AND = 5,OR = 6,NOR = 7,
							XOR = 8,sll = 9,srl = 10,sra = 11,sllv = 12,srlv = 13,srav = 14;
	 
	 wire [4:0] s = A[4:0];
	 wire [32:0] temp = (ALUOp == add) ? {A[31],A} + {B[31],B} :
							  (ALUOp == sub) ? {A[31],A} - {B[31],B} : 0;
							  
	 assign overflow = (temp[32] != temp[31]);
	 assign out = (ALUOp == add) ? A + B :
					  (ALUOp == sub) ? A - B :
					  (ALUOp == slt) ? {31'b0,$signed(A) < $signed(B)} :
					  (ALUOp == sltu) ? {31'b0,A < B} :
					  (ALUOp == AND) ? A & B :
					  (ALUOp == OR) ? A | B :
					  (ALUOp == NOR) ? ~(A | B) :
					  (ALUOp == XOR) ? A ^ B :
					  (ALUOp == sll) ? B << shamt :
					  (ALUOp == srl) ? B >> shamt :
					  (ALUOp == sra) ? $signed($signed(B) >>> shamt) :
					  (ALUOp == sllv) ? B << s :
					  (ALUOp == srlv) ? B >> s :
					  (ALUOp == srav) ? $signed($signed(B) >>> s) : 0;

endmodule
