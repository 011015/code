`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:59:03 12/17/2021 
// Design Name: 
// Module Name:    CPU 
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
module CPU(
    input clk,
    input reset,
	 input [31:0] i_inst_rdata,
	 input [31:0] m_data_rdata,
	 input [15:10] HWInt,
	 output [31:0] i_inst_addr,
	 output [31:0] m_data_addr,
	 output [31:0] m_data_wdata,
	 output [3 :0] m_data_byteen,
	 output [31:0] m_inst_addr,
	 output w_grf_we,
	 output [4:0] w_grf_addr,
	 output [31:0] w_grf_wdata,
	 output [31:0] w_inst_addr,
	 output [31:0] macroscopic_pc,
	 output t_Req
    );
	 
	 //F
	 wire F_BD,jump;
	 wire [31:0] F_PC,F_instr;
	 wire [2:0] NPCSrc;
	 wire [4:0] F_ExcCode;
	 
	 //D
	 wire [2:0] ExtOp;
	 wire [3:0] CompOp;
	 wire [4:0] D_ExcCode,D_temp_ExcCode;
	 wire [31:0] D_PC,D_instr;
	 wire D_comp_data,D_BD,D_RI,D_syscalls;
	 wire [31:0] D_grf_rdata1,D_grf_rdata2,D_ext_data;
	 
	 //E
	 wire E_start,E_busy,overflow,E_BD,MDUWrite;
	 wire [2:0] ALUSrc;
	 wire [3:0] ALUOp,MultDivOp;
	 wire [4:0] E_ExcCode,E_temp_ExcCode;
	 wire [31:0] E_PC,E_instr;
	 wire [31:0] E_ext_data,E_grf_rdata1,E_grf_rdata2,E_alu_b,E_alu_data,E_hi,E_lo;
	 
	 //M
	 wire MemWrite,CP0Write,M_eret,M_BD,IntReq,ExcReq,M_muldiv,BD;
	 wire [2:0] M_ExtOp;
	 wire [4:0] M_ExcCode;
	 wire [31:0] M_PC,M_instr,M_EPC,PC;
	 wire [31:0] M_grf_rdata2,M_ext_data,M_alu_data,M_dm_rdata,M_hi,M_lo,M_data_wdata,M_CP0_rdata;
	 	 
	 //W
	 wire RegWrite;
	 wire [2:0] RegDst,MemtoReg;
	 wire [4:0] W_grf_wreg;
	 wire [31:0] W_PC,W_instr;
	 wire [31:0] W_alu_data,W_dm_rdata,W_ext_data,W_grf_wdata,W_hi,W_lo,W_CP0_rdata;
	 
	 //Hazard
	 wire stall;
	 wire [2:0] D_Tuse_rs,D_Tuse_rt,E_Tnew,M_Tnew,W_Tnew;
	 wire [31:0] MFRSD,MFRTD,MFRSE,MFRTE,MFRTM;
	  
	 //F级
	 pc F_PC_(.clk(clk),
				 .reset(reset),
				 .M_eret(M_eret),
				 .Req(Req),
				 .stall(stall),
				 .D_PC(D_PC),
				 .ext_data(D_ext_data),
				 .imm26(D_instr[`imm26]),
				 .reg_data(MFRSD),
				 .EPC(M_EPC),
				 .NPCSrc(NPCSrc),
				 .PC(F_PC)
				 );
				 
	 assign F_ExcCode = ~(F_PC >= `start_addr_im && F_PC <= `end_addr_im) ? `AdEL :
							  (|F_PC[1:0]) ? `AdEL : 0;
	 assign i_inst_addr = F_PC;
	 assign F_instr = (F_ExcCode) ? 32'd0 : i_inst_rdata;
	 
	 ctrl NPC_ctrl(.opcode(D_instr[`opcode]),
						.func(D_instr[`func]),
						.rs(D_instr[`rs]),
						.rt(D_instr[`rt]),
						.bd(F_BD),
						.comp(D_comp_data),
						.NPCSrc(NPCSrc)
						);
	 //********** IF/ID **********
	 pipeline_reg FtoD_reg(.clk(clk),
								  .reset(reset),
								  .req(Req | M_eret),
								  .stall(stall),
								  .instr(F_instr),
								  .pc(F_PC),
								  .bd(F_BD),
								  .ExcCode(F_ExcCode),
								  .D_instr(D_instr),
								  .D_pc(D_PC),
								  .D_BD(D_BD),
								  .D_ExcCode(D_temp_ExcCode)
								  );
	 //D级
	 assign w_grf_we = RegWrite;
	 assign w_grf_addr = W_grf_wreg;
	 assign w_grf_wdata = W_grf_wdata;
	 assign w_inst_addr = W_PC;
	 
	 assign D_ExcCode = (D_temp_ExcCode) ? D_temp_ExcCode :
							  (D_syscalls) ? `SYSCALLS :
							  (D_RI) ? `RI : 0;
							  
	 grf D_grf(.PC(W_PC),
				  .read_reg1(D_instr[`rs]),
				  .read_reg2(D_instr[`rt]),
				  .write_reg(W_grf_wreg),
				  .wdata(W_grf_wdata),
				  .clk(clk),
				  .reset(reset),
				  .RegWrite(RegWrite),
				  .rdata1(D_grf_rdata1),
				  .rdata2(D_grf_rdata2)
				  );
	 ext D_ext(.imm16(D_instr[`imm16]),
				  .ExtOp(ExtOp),
				  .ext_data(D_ext_data)
				  );
	 comp D_comp(.A(MFRSD),		//D_grf_rdata1
					 .B(MFRTD),		//D_grf_rdata2
					 .CompOp(CompOp),
					 .out(D_comp_data)
					 );
	 ctrl D_ctrl(.opcode(D_instr[`opcode]),
					 .func(D_instr[`func]),
					 .rs(D_instr[`rs]),
					 .rt(D_instr[`rt]),
					 .ExcCode(D_temp_ExcCode),
					 .CompOp(CompOp),
					 .ExtOp(ExtOp),
					 .syscalls(D_syscalls),
					 .RI(D_RI),
					 .Tuse_rs(D_Tuse_rs),
					 .Tuse_rt(D_Tuse_rt)
					 );
	 //********** ID/EX **********
	 pipeline_reg DtoE_reg(.clk(clk),
								  .reset(reset),
								  .req(Req | M_eret),
								  .stall(stall),
								  .instr(D_ExcCode ? 32'd0 : D_instr),
								  .pc(D_PC),
								  .bd(D_BD),
								  .ExcCode(D_ExcCode),
								  .grf_rdata1(MFRSD),
								  .grf_rdata2(MFRTD),
								  .ext(D_ext_data),
								  .E_instr(E_instr),
								  .E_pc(E_PC),
								  .E_BD(E_BD),
								  .E_ExcCode(E_temp_ExcCode),
								  .E_grf_rdata1(E_grf_rdata1),
								  .E_grf_rdata2(E_grf_rdata2),
								  .E_ext(E_ext_data)
								  );
	 //E级
	 mux E_mux(.ext(E_ext_data),
				  .grf_rdata2(MFRTE),	//E_grf_rdata2
				  .ALUSrc(ALUSrc),
				  .alu_b(E_alu_b)
				  );
	 alu E_alu(.A(MFRSE),				//E_grf_rdata1
				  .B(E_alu_b),
				  .shamt(E_instr[`shamt]),
				  .ALUOp(ALUOp),
				  .overflow(overflow),
				  .out(E_alu_data)
				  );
	 mult_div E_mult_div(.A(MFRSE),
								.B(E_alu_b),
								.clk(clk),
								.reset(reset),
								.start(E_start),
								.MultDivOp(MultDivOp),
								.MDUWrite(MDUWrite),
								.req(Req | M_eret),
								.busy(E_busy),
								.hi(E_hi),
								.lo(E_lo)
								);
	 ctrl E_ctrl(.opcode(E_instr[`opcode]),
					 .func(E_instr[`func]),
					 .rs(E_instr[`rs]),
					 .rt(E_instr[`rt]),
					 .ExcCode(E_temp_ExcCode),
					 .alu(E_alu_data),
					 .overflow(overflow),
					 .ALUOp(ALUOp),
					 .MultDivOp(MultDivOp),
					 .E_ExcCode(E_ExcCode),
					 .MDUWrite(MDUWrite),
					 .ALUSrc(ALUSrc),
					 .start(E_start),
					 .Tnew(E_Tnew)
					 );
	 //********** EX/MEM **********
	 pipeline_reg EtoM_reg(.clk(clk),
								  .reset(reset),
								  .req(Req | M_eret),
								  .instr(E_ExcCode ? 32'd0 : E_instr),
								  .pc(E_PC),
								  .bd(E_BD),
								  .ExcCode(E_ExcCode),
								  .grf_rdata2(MFRTE),
								  .ext(E_ext_data),
								  .alu(E_alu_data),
								  .hi(E_hi),
								  .lo(E_lo),
								  .Tnew(E_Tnew),
								  .M_instr(M_instr),
								  .M_pc(M_PC),
								  .M_BD(M_BD),
								  .M_ExcCode(M_ExcCode),
								  .M_grf_rdata2(M_grf_rdata2),
								  .M_ext(M_ext_data),
								  .M_alu(M_alu_data),
								  .M_hi(M_hi),
								  .M_lo(M_lo),
								  .M_Tnew(M_Tnew)
								  );
	 //M级
	 be M_be(.A(M_alu_data[1:0]),	//store
			   .opcode(M_instr[`opcode]),
				.wdata(MFRTM),
			   .MemWrite(MemWrite & ~Req),
				.change_wdata(M_data_wdata),
			   .data_byteen(m_data_byteen)
			   );
			  
	 assign m_data_addr = M_alu_data;
	 assign m_data_wdata = M_data_wdata;
	 assign m_inst_addr = M_PC;
	 assign macroscopic_pc = {PC[31:2],2'b0};	//M_PC
	 
	 assign PC = (M_PC) ? M_PC :
					 (E_PC) ? E_PC :
					 (D_PC) ? D_PC :
					 (F_PC) ? F_PC : 0;
	 
	 assign BD = (M_PC) ? M_BD :
					 (E_PC) ? E_BD :
					 (D_PC) ? D_BD :
					 (F_PC) ? F_BD : 0;
					 
	 ext2 M_ext(.A(M_alu_data[1:0]),	//load
					.Din(m_data_rdata),
					.Op(M_ExtOp),
					.Dout(M_dm_rdata)
					);
	 CP0 M_CP0(.Addr(M_instr[`rd]),
				  .DIn(MFRTM),
				  .PC(PC),	//M_PC
				  .excCode(M_ExcCode),
				  .HWInt(HWInt),
				  .bd(BD),	//M_BD
				  .WE(CP0Write),
				  .EXLClr(M_eret),
				  .clk(clk),
				  .rst(reset),
				  .IntReq(IntReq),
				  .ExcReq(ExcReq),
				  .Req(Req),
				  .t_Req(t_Req),
				  .epc(M_EPC),
				  .DOut(M_CP0_rdata)
				  );
	 
	 ctrl M_ctrl(.opcode(M_instr[`opcode]),
					 .func(M_instr[`func]),
					 .rs(M_instr[`rs]),
					 .rt(M_instr[`rt]),
					 .M_ExtOp(M_ExtOp),
					 .MemWrite(MemWrite),
					 .CP0Write(CP0Write),
					 .eret(M_eret)
					 );
	 //********** MEM/WB **********
	 pipeline_reg MtoW_reg(.clk(clk),
								  .reset(reset),
								  .req(Req | M_eret),
								  .instr(M_instr),
								  .pc(M_PC),
								  .ext(M_ext_data),
								  .alu(M_alu_data),
								  .hi(M_hi),
								  .lo(M_lo),
								  .dm_rdata(M_dm_rdata),
								  .CP0_rdata(M_CP0_rdata),
								  .Tnew(M_Tnew),
								  .W_instr(W_instr),
								  .W_pc(W_PC),
								  .W_ext(W_ext_data),
								  .W_alu(W_alu_data),
								  .W_hi(W_hi),
								  .W_lo(W_lo),
								  .W_dm_rdata(W_dm_rdata),
								  .W_CP0_rdata(W_CP0_rdata),
								  .W_Tnew(W_Tnew)
								  );
	 //W级
	 mux W_mux(.rt(W_instr[`rt]),
				  .rd(W_instr[`rd]),
				  .alu(W_alu_data),
				  .hi(W_hi),
				  .lo(W_lo),
				  .dm(W_dm_rdata),
				  .CP0(W_CP0_rdata),
				  .ext(W_ext_data),
				  .PC(W_PC),
				  .RegDst(RegDst),
				  .MemtoReg(MemtoReg),
				  .grf_wreg(W_grf_wreg),
				  .grf_wdata(W_grf_wdata)
				  );
	 ctrl W_ctrl(.opcode(W_instr[`opcode]),
					 .func(W_instr[`func]),
					 .rs(W_instr[`rs]),
					 .rt(W_instr[`rt]),
					 .RegDst(RegDst),
					 .RegWrite(RegWrite),
					 .MemtoReg(MemtoReg)
					 );
	 //Hazard
	 Hazard Hazard_(.D_Tuse_rs(D_Tuse_rs),
						 .D_Tuse_rt(D_Tuse_rt),
						 .E_start(E_start),
						 .E_busy(E_busy),
						 .E_Tnew(E_Tnew),
						 .M_Tnew(M_Tnew),
						 .W_Tnew(W_Tnew),
						 .D_ir(D_instr),
						 .E_ir(E_instr),
						 .M_ir(M_instr),
						 .W_ir(W_instr),
						 .E_ext(E_ext_data),
						 .E_PC8(E_PC + 8),
						 .M_alu(M_alu_data),
						 .M_hi(M_hi),
						 .M_lo(M_lo),
						 .M_ext(M_ext_data),
						 .M_PC8(M_PC + 8),
						 .W_alu(W_alu_data),
						 .W_hi(W_hi),
						 .W_lo(W_lo),
						 .W_dm(W_dm_rdata),
						 .W_CP0(W_CP0_rdata),
						 .W_ext(W_ext_data),
						 .W_PC8(W_PC + 8),
						 .D_grf_rdata1(D_grf_rdata1),
						 .D_grf_rdata2(D_grf_rdata2),
						 .E_grf_rdata1(E_grf_rdata1),
						 .E_grf_rdata2(E_grf_rdata2),
						 .M_grf_rdata2(M_grf_rdata2),
						 .MFRSD(MFRSD),
						 .MFRTD(MFRTD),
						 .MFRSE(MFRSE),
						 .MFRTE(MFRTE),
						 .MFRTM(MFRTM),
						 .stall(stall)
						 );
endmodule
