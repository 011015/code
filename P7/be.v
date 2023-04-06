`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:28:28 12/17/2021 
// Design Name: 
// Module Name:    be 
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
module be(
    input [1:0] A,
	 input [5:0] opcode,
	 input [31:0] wdata,
	 input MemWrite,
	 output reg [31:0] change_wdata,
    output reg [3:0] data_byteen
    );

	 always@(*) begin
		if(MemWrite) begin
			case (opcode)
				`sb : begin
					data_byteen = (A == 2'b00) ? 4'b0001 :
									  (A == 2'b01) ? 4'b0010 :
									  (A == 2'b10) ? 4'b0100 :
									  (A == 2'b11) ? 4'b1000 : 4'b0;
					change_wdata = {4{wdata[7:0]}};
				end
				`sh : begin
					data_byteen = (A[1] == 1'b0) ? 4'b0011 :
									  (A[1] == 1'b1) ? 4'b1100 : 4'b0;
					change_wdata = {2{wdata[15:0]}};
				end  
				`sw : begin
					data_byteen = 4'b1111;
					change_wdata = wdata;
				end
				default : begin
					data_byteen = 4'b0;
					change_wdata = wdata;
				end
			endcase
		end
		else begin
			data_byteen = 4'b0;
			change_wdata = wdata;
		end
	 end
	 
endmodule
