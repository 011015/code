`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:29:53 12/17/2021 
// Design Name: 
// Module Name:    grf 
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
module grf(
	 input [31:0] PC,
    input [4:0] read_reg1,
    input [4:0] read_reg2,
    input [4:0] write_reg,
    input [31:0] wdata,
    input clk,
    input reset,
	 input RegWrite,
    output [31:0] rdata1,
    output [31:0] rdata2
    );
	 reg [31:0] GRF [0:31];
	 integer i;
	 
	 assign rdata1 = GRF[read_reg1];		//read1
	 assign rdata2 = GRF[read_reg2];		//read2
	 
	 initial begin
		for(i=0;i<32;i=i+1)
			GRF[i] <= 32'b0;
	 end
	 always @(posedge clk) begin		//write
		if(reset) begin
			for(i=0;i<32;i=i+1) begin
				GRF[i] <= 32'b0;
			end
		end
		else if(RegWrite && (write_reg != 5'b0)) GRF[write_reg] <= wdata;
		else GRF[write_reg] <= GRF[write_reg];
	 end
	 
endmodule
