`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:31:40 12/17/2021 
// Design Name: 
// Module Name:    target_reg 
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
module target_reg(
    input [31:0] instr,
    output [4:0] A3,
	 output mul_div,
	 output cal,
	 output load,
	 output lui,
	 output jump,
	 output mfhi,
	 output mflo,
	 output mfc0
    );
	 
	 wire [5:0] opcode = instr[`opcode];
	 wire [5:0] func = instr[`func];
	 wire special = (opcode == 6'b0);
	 wire [4:0] rs = instr[`rs]; 
	 
	 wire add = (special && (func == `add));
	 wire addu = (special && (func == `addu));
	 wire sub = (special && (func == `sub));
	 wire subu = (special && (func == `subu));
	 wire slt = (special && (func == `slt));
	 wire sltu = (special && (func == `sltu));
	 wire AND = (special && (func == `AND));
	 wire OR = (special && (func == `OR));
	 wire NOR = (special && (func == `NOR));
	 wire XOR = (special && (func == `XOR));
	 wire sll = (special && (func == `sll));
	 wire srl = (special && (func == `srl));
	 wire sra = (special && (func == `sra));
	 wire sllv = (special && (func == `sllv));
	 wire srlv = (special && (func == `srlv));
	 wire srav = (special && (func == `srav));
	 assign mfhi = (special && (func == `mfhi));
	 assign mflo = (special && (func == `mflo));
	 wire mthi = (special && (func == `mthi));
	 wire mtlo = (special && (func == `mtlo));
	 wire mult = (special && (func == `mult));
	 wire multu = (special && (func == `multu));
	 wire div = (special && (func == `div));
	 wire divu = (special && (func == `divu));
	 wire jalr = (special && (func == `jalr));
	 
	 wire addi = (opcode == `addi);	//cal_i
	 wire addiu = (opcode == `addiu);
	 wire slti = (opcode == `slti);
	 wire sltiu = (opcode == `sltiu);
	 wire andi = (opcode == `andi);
	 wire ori = (opcode == `ori);
	 wire xori = (opcode == `xori);
	 wire lb = (opcode == `lb);		//load
	 wire lbu = (opcode == `lbu);
	 wire lh = (opcode == `lh);
	 wire lhu = (opcode == `lhu);
	 wire lw = (opcode == `lw);
	 wire jal = (opcode == `jal);		//jump
	 assign lui = (opcode == `lui);
	 assign mfc0 = (opcode == `COP0) && (rs == `mfc0);
	 
	 wire cal_r = add | addu | sub | subu | slt | sltu | AND | OR | NOR | XOR | sll | 
					  srl | sra | sllv | srlv | srav;
	 wire cal_i = addi | addiu | slti | sltiu | andi | ori | xori;
	 
	 assign mul_div = mfhi | mflo | mthi | mtlo | mult | multu | div | divu;
	 assign cal = cal_r | cal_i;
	 assign load = lb | lbu | lh | lhu | lw;
	 assign jump = jal | jalr;
	 assign A3 = (cal_r | jalr | mfhi | mflo) ? instr[`rd] :	//cal_r
					 (lui | cal_i | load | mfc0) ? instr[`rt] :	//cal_i | load
					 (jal) ? 5'd31 : 5'b0;
	 
endmodule
