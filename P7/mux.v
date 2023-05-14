`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:30:55 12/17/2021 
// Design Name: 
// Module Name:    mux 
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
module mux(
    input [4:0] rt,
    input [4:0] rd,
    input [31:0] alu,
	 input [31:0] hi,
	 input [31:0] lo,
    input [31:0] dm,
	 input [31:0] CP0,
    input [31:0] ext,
    input [31:0] PC,
	 input [31:0] grf_rdata2,
	 input [31:0] store_data,
	 input [2:0] RegDst,
    input [2:0] MemtoReg,
    input [2:0] ALUSrc,
	 output [4:0] grf_wreg,
	 output [31:0] grf_wdata,
	 output [31:0] alu_b,
	 output [31:0] dm_wdata
    );
	 assign grf_wreg = (RegDst == 3'b01) ? rd :	//cal_r
							 (RegDst == 3'b10) ? 5'b11111 : rt;
	 assign grf_wdata = (MemtoReg == 3'b001) ? dm :		//store
							  (MemtoReg == 3'b010) ? ext :	//lui
							  (MemtoReg == 3'b011) ? (PC + 8) :	//jump
							  (MemtoReg == 3'b100) ? hi :			//mfhi
							  (MemtoReg == 3'b101) ? lo : 		//mflo
							  (MemtoReg == 3'b110) ? CP0 : alu;
	 assign alu_b = (ALUSrc == 3'b01) ? ext : grf_rdata2;
endmodule
