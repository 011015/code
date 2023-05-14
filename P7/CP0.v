`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    04:19:35 12/21/2021 
// Design Name: 
// Module Name:    CP0 
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
module CP0(
    input [4:0] Addr,
    input [31:0] DIn,
    input [31:0] PC,
    input [6:2] excCode,
    input [5:0] HWInt,
	 input bd,
    input WE,
    input EXLClr,
    input clk,
    input rst,
    output IntReq,
	 output ExcReq,
	 output Req,
	 output t_Req,
    output [31:0] epc,
    output reg [31:0] DOut
    );
	 
	 reg [31:0] SR,Cause,EPC,PRId;
	 
	 always @(*) begin
		case (Addr)
			`SR : DOut = SR;
			`Cause : DOut = Cause;
			`EPC : DOut = EPC;
			`PRId : DOut = PRId;
			default : DOut = 0;
		endcase
	 end
	 
	 always @(posedge clk) begin
		if(rst) begin
			SR <= 0;		//12
			Cause <= 0;	//13
			EPC <= 0;	//14
			PRId <= 0;	//15	
		end
		else begin
			if(WE & ~Req)
				case (Addr)
					`SR : SR <= DIn;
					`EPC : EPC <= DIn;
				endcase
			`IP <= HWInt;
			if(EXLClr) `EXL <= 1'b0;
			if(IntReq) begin
				`EXL <= 1'b1;
				EPC <= (bd) ? PC - 4 : PC;
				`BD <= bd;
				`ExcCode <= 5'b0;
			end
			else if(ExcReq) begin
				`EXL <= 1'b1;
				EPC <= (bd) ? PC - 4 : PC;
				`BD <= bd;
				`ExcCode <= excCode;
			end
		end
	 end
	 
	 assign IntReq = (|(HWInt & `IM)) & `IE & ~`EXL;
	 assign ExcReq = (|excCode) & ~`EXL;
	 assign Req = IntReq | ExcReq;
	 assign t_Req = (HWInt[2] & SR[12]) & `IE & ~`EXL;
	 assign epc = EPC; 
	 
endmodule
