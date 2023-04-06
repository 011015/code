`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:31:25 12/17/2021 
// Design Name: 
// Module Name:    pipeline_reg 
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
module pipeline_reg(
	 input clk,
	 input reset,
	 input req,
	 input stall,
    input [31:0] instr,
    input [31:0] pc,
	 input bd,
	 input [4:0] ExcCode,
    input [31:0] grf_rdata1,
    input [31:0] grf_rdata2,
    input [31:0] ext,
    input [31:0] alu,
	 input [31:0] hi,
	 input [31:0] lo,
    input [31:0] dm_rdata,
	 input [31:0] CP0_rdata,
	 input [2:0] Tnew,
    output reg [31:0] D_instr,	//D
    output reg [31:0] D_pc,
	 output reg D_BD,
	 output reg [4:0] D_ExcCode,
	 output reg [2:0] D_Tnew,
    output reg [31:0] E_instr,	//E
    output reg [31:0] E_pc,
	 output reg E_BD,
	 output reg [4:0] E_ExcCode,
    output reg [31:0] E_grf_rdata1,
    output reg [31:0] E_grf_rdata2,
    output reg [31:0] E_ext,
	 output reg [2:0] E_Tnew,
    output reg [31:0] M_instr,	//M
    output reg [31:0] M_pc,
	 output reg M_BD,
	 output reg [4:0] M_ExcCode,
    output reg [31:0] M_grf_rdata2,
    output reg [31:0] M_ext,
	 output reg [31:0] M_alu,
	 output reg [31:0] M_hi,
	 output reg [31:0] M_lo,
	 output reg [2:0] M_Tnew,
    output reg [31:0] W_instr,	//W
    output reg [31:0] W_pc,
    output reg [31:0] W_ext,
	 output reg [31:0] W_alu,
	 output reg [31:0] W_hi,
	 output reg [31:0] W_lo,
    output reg [31:0] W_dm_rdata,
	 output reg [31:0] W_CP0_rdata,
	 output reg [2:0] W_Tnew
    );
	 
	 wire [2:0] temp_Tnew = (Tnew > 3'b0) ? Tnew - 1 : 3'b0; 
	 // IF/ID,D级
	 always @(posedge clk) begin
		if(reset) begin
			D_instr <= 0;
			D_pc <= 32'h3000;
			D_BD <= 0;
			D_ExcCode <= 0;
			D_Tnew <= 0;
		end
		else if(req) begin
			D_instr <= 0;
			D_pc <= 0;	//32'h4180
			D_BD <= 0;
			D_ExcCode <= 0;
			D_Tnew <= 0;
		end
		else if(stall) begin		//D.en = 0
			D_instr <= D_instr;
			D_pc <= D_pc;
			D_BD <= D_BD;
			D_ExcCode <= D_ExcCode;
			D_Tnew <= D_Tnew;
		end
		else begin
			D_instr <= instr;
			D_pc <= pc;
			D_BD <= bd;
			D_ExcCode <= ExcCode;
			D_Tnew <= temp_Tnew;
		end
	 end
	 
	 // ID/EX,E级
	 always @(posedge clk) begin
		if(reset) begin
			E_instr <= 0;
			E_pc <= 32'h3000;
			E_BD <= 0;
			E_ExcCode <= 0;
			E_grf_rdata1 <= 0;
			E_grf_rdata2 <= 0;
			E_ext <= 0;
			E_Tnew <= 0;
		end
		else if(req) begin
			E_instr <= 0;
			E_pc <= 0;	//32'h4180
			E_BD <= 0;
			E_ExcCode <= 0;
			E_grf_rdata1 <= 0;
			E_grf_rdata2 <= 0;
			E_ext <= 0;
			E_Tnew <= 0;
		end
		else if(stall) begin		//E.clr = 1
			E_instr <= 0;
			E_pc <= 0;		//pc
			E_BD <= 0;		//bd
			E_ExcCode <= 0;
			E_grf_rdata1 <= 0;
			E_grf_rdata2 <= 0;
			E_ext <= 0;
			E_Tnew <= 0;
		end
		else begin
			E_instr <= instr;
			E_pc <= pc;
			E_BD <= bd;
			E_ExcCode <= ExcCode;
			E_grf_rdata1 <= grf_rdata1;
			E_grf_rdata2 <= grf_rdata2;
			E_ext <= ext;
			E_Tnew <= temp_Tnew;
		end
	 end
	 
	 // EX/MEM,M级
	 always @(posedge clk) begin
		if(reset) begin
			M_instr <= 0;
			M_pc <= 32'h3000;
			M_BD <= 0;
			M_ExcCode <= 0;
			M_grf_rdata2 <= 0;
			M_ext <= 0;
			M_alu <= 0;
			M_hi <= 0;
			M_lo <= 0;
			M_Tnew <= 0;
		end
		else if(req) begin
			M_instr <= 0;
			M_pc <= 0;	//32'h4180
			M_BD <= 0;
			M_ExcCode <= 0;
			M_grf_rdata2 <= 0;
			M_ext <= 0;
			M_alu <= 0;
			M_hi <= 0;
			M_lo <= 0;
			M_Tnew <= 0;
		end
		else begin
			M_instr <= instr;
			M_pc <= pc;
			M_BD <= bd;
			M_ExcCode <= ExcCode;
			M_grf_rdata2 <= grf_rdata2;
			M_ext <= ext;
			M_alu <= alu;
			M_hi <= hi;
			M_lo <= lo;
			M_Tnew <= temp_Tnew;
		end
	 end
	 
	 // MEM/WriteBack,W级
	 always @(posedge clk) begin
		if(reset) begin
			W_instr <= 0;
			W_pc <= 32'h3000;
			W_ext <= 0;
			W_alu <= 0;
			W_hi <= 0;
			W_lo <= 0;
			W_dm_rdata <= 0;
			W_CP0_rdata <= 0;
			W_Tnew <= 0;
		end
		else if(req) begin
			W_instr <= 0;
			W_pc <= 0;	//32'h4180
			W_ext <= 0;
			W_alu <= 0;
			W_hi <= 0;
			W_lo <= 0;
			W_dm_rdata <= 0;
			W_CP0_rdata <= 0;
			W_Tnew <= 0;
		end
		else begin
			W_instr <= instr;
			W_pc <= pc;
			W_ext <= ext;
			W_alu <= alu;
			W_hi <= hi;
			W_lo <= lo;
			W_dm_rdata <= dm_rdata;
			W_CP0_rdata <= CP0_rdata;
			W_Tnew <= temp_Tnew;
		end
	 end
	 
endmodule
