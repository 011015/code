`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:31:08 12/17/2021 
// Design Name: 
// Module Name:    pc 
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
module pc(
	 input clk,
	 input reset,
	 input M_eret,
	 input Req,
	 input stall,
	 input [31:0] D_PC,
	 input [31:0] ext_data,		//b÷∏¡Ó
	 input [25:0] imm26,		//jal
	 input [31:0] reg_data,		//jr
	 input [31:0] EPC,
	 input [2:0] NPCSrc,
	 output reg [31:0] PC
    );
	 
	 wire [31:0] b_target = D_PC + 4 + {ext_data,2'b0};
	 wire [31:0] j_target = {D_PC[31:28],imm26,2'b0};
	 wire [31:0] next_PC;
						  
	 assign next_PC = (NPCSrc == 3'b01) ? b_target :
						   (NPCSrc == 3'b10) ? j_target :
							(NPCSrc == 3'b11) ? reg_data : PC + 4;

	 always@(posedge clk) begin
		if(reset) PC <= 32'h3000;
		else if(M_eret) PC <= EPC;
		else if(Req) PC <= 32'h4180;
		else if(stall) PC <= PC; 	//pc.en = 0
		else PC <= next_PC;
	 end
	 
endmodule
