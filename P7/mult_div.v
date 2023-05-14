`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:30:42 12/17/2021 
// Design Name: 
// Module Name:    mult_div 
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
module mult_div(
    input [31:0] A,
    input [31:0] B,
	 input clk,
	 input reset,
	 input start,
	 input [3:0] MultDivOp,
	 input MDUWrite,
	 input req,
	 output busy,
    output [31:0] hi,
	 output [31:0] lo
    );
	 
	 reg [31:0] HI,LO;
	 reg BUSY;
	 integer count;
	 localparam [3:0] mult = 1,multu = 2,div = 3,divu = 4,mthi = 5,mtlo = 6;
	 
	 always@(posedge clk) begin
		if(reset) begin
			HI <= 0;
			LO <= 0;
			BUSY <= 0;
			count <= 0;
		end
		else if(~BUSY) begin
			if(start & ~req) begin
				case (MultDivOp)
					mult : {HI,LO} <= $signed(A) * $signed(B);
					multu : {HI,LO} <= A * B;
					div : {HI,LO} <= (B != 0) ? {($signed(A)) % ($signed(B)),($signed(A)) / ($signed(B))} : {HI,LO};
					divu : {HI,LO} <= (B != 0) ? {A % B ,A / B} : {HI,LO};
				endcase
				BUSY <= 1;
				count <= ((MultDivOp == mult) | (MultDivOp == multu)) ? 4 :
							((MultDivOp == div) | (MultDivOp == divu)) ? 9 : 0;
			end
			else if(MDUWrite & ~req) begin
				case (MultDivOp)
					mthi : HI <= A;
					mtlo : LO <= A;
				endcase
			end
		end
		else if(count == 0) BUSY <= 0;
		else if(BUSY) count <= count - 1;
	 end
		
	 assign busy = BUSY;
	 assign hi = (busy == 0) ? HI : 0;
	 assign lo = (busy == 0) ? LO : 0;
	 
endmodule
