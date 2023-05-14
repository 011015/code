`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:30:09 12/17/2021 
// Design Name: 
// Module Name:    Hazard 
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
module Hazard(
    input [2:0] D_Tuse_rs,
    input [2:0] D_Tuse_rt,
	 input E_start,
	 input E_busy,
	 input [2:0] E_Tnew,
    input [2:0] M_Tnew,
	 input [2:0] W_Tnew,
	 input [31:0] D_ir,	//instr
	 input [31:0] E_ir,
	 input [31:0] M_ir,
	 input [31:0] W_ir,
	 input [31:0] E_ext,	//data
	 input [31:0] E_PC8,
	 input [31:0] M_alu,
	 input [31:0] M_hi,
	 input [31:0] M_lo,
	 input [31:0] M_ext,
	 input [31:0] M_PC8,
	 input [31:0] W_alu,
	 input [31:0] W_hi,
	 input [31:0] W_lo,
	 input [31:0] W_dm,
	 input [31:0] W_CP0,
	 input [31:0] W_ext,
	 input [31:0] W_PC8,
	 input [31:0] D_grf_rdata1,
	 input [31:0] D_grf_rdata2,
	 input [31:0] E_grf_rdata1,
	 input [31:0] E_grf_rdata2,
	 input [31:0] M_grf_rdata2,
    output [31:0] MFRSD,
    output [31:0] MFRTD,
    output [31:0] MFRSE,
    output [31:0] MFRTE,
    output [31:0] MFRTM,
	 output stall
    );
	 
	 wire [4:0] E_A3,M_A3,W_A3;
	 wire D_mul_div;
	 wire E_cal,E_load,E_lui,E_jump,E_mfhi,E_mflo,E_mfc0;
	 wire M_cal,M_load,M_lui,M_jump,M_mfhi,M_mflo,M_mfc0;
	 wire W_cal,W_load,W_lui,W_jump,W_mfhi,W_mflo,W_mfc0;
	 
	 target_reg D_target_reg(.instr(D_ir),.mul_div(D_mul_div));
	 target_reg E_target_reg(.instr(E_ir),.A3(E_A3),.cal(E_cal),.load(E_load),.lui(E_lui),.jump(E_jump),.mfhi(E_mfhi),.mflo(E_mflo),.mfc0(E_mfc0));
	 target_reg M_target_reg(.instr(M_ir),.A3(M_A3),.cal(M_cal),.load(M_load),.lui(M_lui),.jump(M_jump),.mfhi(M_mfhi),.mflo(M_mflo),.mfc0(M_mfc0));
	 target_reg W_target_reg(.instr(W_ir),.A3(W_A3),.cal(W_cal),.load(W_load),.lui(W_lui),.jump(W_jump),.mfhi(W_mfhi),.mflo(W_mflo),.mfc0(W_mfc0));
	 
	 //ForwardMux
	 assign MFRSD = (D_ir[`rs] == 0) ? 32'b0 :
						 ((E_Tnew == 0) && (D_ir[`rs] == E_A3) && (E_lui)) ? E_ext :			//** E ** lui
						 ((E_Tnew == 0) && (D_ir[`rs] == E_A3) && (E_jump)) ? E_PC8 :			//jal,jalr
						 ((M_Tnew == 0) && (D_ir[`rs] == M_A3) && (M_cal)) ? M_alu :			//** M ** cal
						 ((M_Tnew == 0) && (D_ir[`rs] == M_A3) && (M_mfhi)) ? M_hi :			//mfhi
						 ((M_Tnew == 0) && (D_ir[`rs] == M_A3) && (M_mflo)) ? M_lo :			//mflo
						 ((M_Tnew == 0) && (D_ir[`rs] == M_A3) && (M_lui)) ? M_ext :			//lui
						 ((M_Tnew == 0) && (D_ir[`rs] == M_A3) && (M_jump)) ? M_PC8 :			//jal,jalr
						 ((W_Tnew == 0) && (D_ir[`rs] == W_A3) && (W_cal)) ? W_alu :			//** W ** cal
						 ((W_Tnew == 0) && (D_ir[`rs] == W_A3) && (W_mfhi)) ? W_hi :			//mfhi
						 ((W_Tnew == 0) && (D_ir[`rs] == W_A3) && (W_mflo)) ? W_lo :			//mflo
						 ((W_Tnew == 0) && (D_ir[`rs] == W_A3) && (W_load)) ? W_dm :			//load
						 ((W_Tnew == 0) && (D_ir[`rs] == W_A3) && (W_mfc0)) ? W_CP0 :			//mfc0
						 ((W_Tnew == 0) && (D_ir[`rs] == W_A3) && (W_lui)) ? W_ext :			//lui
						 ((W_Tnew == 0) && (D_ir[`rs] == W_A3) && (W_jump)) ? W_PC8 : D_grf_rdata1;		//jal,jalr
						 
	 assign MFRTD = (D_ir[`rt] == 0) ? 32'b0 :
						 ((E_Tnew == 0) && (D_ir[`rt] == E_A3) && (E_lui)) ? E_ext :			//** E ** lui
						 ((E_Tnew == 0) && (D_ir[`rt] == E_A3) && (E_jump)) ? E_PC8 :			//jal,jalr
						 ((M_Tnew == 0) && (D_ir[`rt] == M_A3) && (M_cal)) ? M_alu :			//** M ** cal
						 ((M_Tnew == 0) && (D_ir[`rt] == M_A3) && (M_mfhi)) ? M_hi :			//mfhi
						 ((M_Tnew == 0) && (D_ir[`rt] == M_A3) && (M_mflo)) ? M_lo :			//mflo
						 ((M_Tnew == 0) && (D_ir[`rt] == M_A3) && (M_lui)) ? M_ext :			//lui
						 ((M_Tnew == 0) && (D_ir[`rt] == M_A3) && (M_jump)) ? M_PC8 :			//jal,jalr
						 ((W_Tnew == 0) && (D_ir[`rt] == W_A3) && (W_cal)) ? W_alu :			//** W ** cal
						 ((W_Tnew == 0) && (D_ir[`rt] == W_A3) && (W_mfhi)) ? W_hi :			//mfhi
						 ((W_Tnew == 0) && (D_ir[`rt] == W_A3) && (W_mflo)) ? W_lo :			//mflo
						 ((W_Tnew == 0) && (D_ir[`rt] == W_A3) && (W_load)) ? W_dm :			//load
						 ((W_Tnew == 0) && (D_ir[`rt] == W_A3) && (W_mfc0)) ? W_CP0 :			//mfc0
						 ((W_Tnew == 0) && (D_ir[`rt] == W_A3) && (W_lui)) ? W_ext :			//lui
						 ((W_Tnew == 0) && (D_ir[`rt] == W_A3) && (W_jump)) ? W_PC8 : D_grf_rdata2;		//jal,jalr
						 
	 assign MFRSE = (E_ir[`rs] == 0) ? 32'b0 :
						 ((M_Tnew == 0) && (E_ir[`rs] == M_A3) && (M_cal)) ? M_alu :			//** M ** cal
						 ((M_Tnew == 0) && (E_ir[`rs] == M_A3) && (M_mfhi)) ? M_hi :			//mfhi
						 ((M_Tnew == 0) && (E_ir[`rs] == M_A3) && (M_mflo)) ? M_lo :			//mflo
						 ((M_Tnew == 0) && (E_ir[`rs] == M_A3) && (M_lui)) ? M_ext:				//lui
						 ((M_Tnew == 0) && (E_ir[`rs] == M_A3) && (M_jump)) ? M_PC8 :			//jal,jalr
						 ((W_Tnew == 0) && (E_ir[`rs] == W_A3) && (W_cal)) ? W_alu :			//** W ** cal
						 ((W_Tnew == 0) && (E_ir[`rs] == W_A3) && (W_mfhi)) ? W_hi :			//mfhi
						 ((W_Tnew == 0) && (E_ir[`rs] == W_A3) && (W_mflo)) ? W_lo :			//mflo
						 ((W_Tnew == 0) && (E_ir[`rs] == W_A3) && (W_load)) ? W_dm :			//load
						 ((W_Tnew == 0) && (E_ir[`rs] == W_A3) && (W_mfc0)) ? W_CP0 :			//mfc0
						 ((W_Tnew == 0) && (E_ir[`rs] == W_A3) && (W_lui)) ? W_ext :			//lui
						 ((W_Tnew == 0) && (E_ir[`rs] == W_A3) && (W_jump)) ? W_PC8 : E_grf_rdata1;		//jal,jalr
						 
	 assign MFRTE = (E_ir[`rt] == 0) ? 32'b0 :
						 ((M_Tnew == 0) && (E_ir[`rt] == M_A3) && (M_cal)) ? M_alu :			//** M ** cal
						 ((M_Tnew == 0) && (E_ir[`rt] == M_A3) && (M_mfhi)) ? M_hi :			//mfhi
						 ((M_Tnew == 0) && (E_ir[`rt] == M_A3) && (M_mflo)) ? M_lo :			//mflo
						 ((M_Tnew == 0) && (E_ir[`rt] == M_A3) && (M_lui)) ? M_ext :			//lui
						 ((M_Tnew == 0) && (E_ir[`rt] == M_A3) && (M_jump)) ? M_PC8 :			//jal,jalr
						 ((W_Tnew == 0) && (E_ir[`rt] == W_A3) && (W_cal)) ? W_alu :			//** W ** cal
						 ((W_Tnew == 0) && (E_ir[`rt] == W_A3) && (W_mfhi)) ? W_hi :			//mfhi
						 ((W_Tnew == 0) && (E_ir[`rt] == W_A3) && (W_mflo)) ? W_lo :			//mflo
						 ((W_Tnew == 0) && (E_ir[`rt] == W_A3) && (W_load)) ? W_dm :			//load
						 ((W_Tnew == 0) && (E_ir[`rt] == W_A3) && (W_mfc0)) ? W_CP0 :			//mfc0
						 ((W_Tnew == 0) && (E_ir[`rt] == W_A3) && (W_lui)) ? W_ext :			//lui
						 ((W_Tnew == 0) && (E_ir[`rt] == W_A3) && (W_jump)) ? W_PC8 : E_grf_rdata2;		//jal,jalr
						 
	 assign MFRTM = (M_ir[`rt] == 0) ? 32'b0 :
						 ((W_Tnew == 0) && (M_ir[`rt] == W_A3) && (W_cal)) ? W_alu :			//** W ** cal
						 ((W_Tnew == 0) && (M_ir[`rt] == W_A3) && (W_mfhi)) ? W_hi :			//mfhi
						 ((W_Tnew == 0) && (M_ir[`rt] == W_A3) && (W_mflo)) ? W_lo :			//mflo
						 ((W_Tnew == 0) && (M_ir[`rt] == W_A3) && (W_load)) ? W_dm :			//load
						 ((W_Tnew == 0) && (M_ir[`rt] == W_A3) && (W_mfc0)) ? W_CP0 :			//mfc0
						 ((W_Tnew == 0) && (M_ir[`rt] == W_A3) && (W_lui)) ? W_ext :			//lui
						 ((W_Tnew == 0) && (M_ir[`rt] == W_A3) && (W_jump)) ? W_PC8 : M_grf_rdata2;		//jal,jalr
						
	 //Stall
	 wire stall_mul_div = ((E_start | E_busy) && (D_mul_div));
	 wire stall_rs = ((D_ir[`rs]) && (D_Tuse_rs < E_Tnew) && (D_ir[`rs] == E_A3) && (E_cal | E_mfhi | E_mflo)) | 	//cal
						  ((D_ir[`rs]) && (D_Tuse_rs < E_Tnew) && (D_ir[`rs] == E_A3) && (E_load | E_mfc0)) |				//load
						  ((D_ir[`rs]) && (D_Tuse_rs < M_Tnew) && (D_ir[`rs] == M_A3) && (M_load | M_mfc0));				//load
							 
	 wire stall_rt = ((D_ir[`rt]) && (D_Tuse_rt < E_Tnew) && (D_ir[`rt] == E_A3) && (E_cal | E_mfhi | E_mflo)) | 	//cal
						  ((D_ir[`rt]) && (D_Tuse_rt < E_Tnew) && (D_ir[`rt] == E_A3) && (E_load | E_mfc0)) |				//load
						  ((D_ir[`rt]) && (D_Tuse_rt < M_Tnew) && (D_ir[`rt] == M_A3) && (M_load | M_mfc0));				//load
						  
	 assign stall = stall_mul_div | stall_rs | stall_rt;

endmodule
