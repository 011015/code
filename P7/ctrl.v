`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:29:13 12/17/2021 
// Design Name: 
// Module Name:    ctrl 
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
module ctrl(
    input [5:0] opcode,
    input [5:0] func,
	 input [4:0] rs,
	 input [4:0] rt,
	 input [4:0] ExcCode,
	 input [31:0] alu,
	 input overflow,
    input comp,
    output [2:0] RegDst,
	 output [1:0] RegRead,
    output RegWrite,
	 output MDUWrite,
    output MemWrite,
	 output CP0Write,
    output [2:0] MemtoReg,
    output [3:0] ALUOp,
	 output [3:0] MultDivOp,
    output [2:0] ALUSrc,
    output [2:0] NPCSrc,
    output [3:0] CompOp,
	 output [2:0] ExtOp,
	 output [2:0] M_ExtOp,
	 output syscalls,
	 output eret,
	 output bd,
	 output [4:0] E_ExcCode,
	 output start,
	 output RI,
	 output [2:0] Tuse_rs,
	 output [2:0] Tuse_rt,
	 output [2:0] Tnew
    );
	 
	 wire special = (opcode == 6'b0);
	 
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
	 wire mfhi = (special && (func == `mfhi));
	 wire mflo = (special && (func == `mflo));
	 wire mthi = (special && (func == `mthi));
	 wire mtlo = (special && (func == `mtlo));
	 wire mult = (special && (func == `mult));
	 wire multu = (special && (func == `multu));
	 wire div = (special && (func == `div));
	 wire divu = (special && (func == `divu));
	 wire jalr = (special && (func == `jalr));
	 wire jr = (special && (func == `jr));
	 assign eret = (opcode == `COP0) && (func == `eret);
	 
	 wire addi = (opcode == `addi);
	 wire addiu = (opcode == `addiu);
	 wire slti = (opcode == `slti);
	 wire sltiu = (opcode == `sltiu);
	 wire andi = (opcode == `andi);
	 wire ori = (opcode == `ori);
	 wire xori = (opcode == `xori);
	 wire beq = (opcode == `beq);		//branch
	 wire bne = (opcode == `bne);
	 wire bgez = (opcode == `bgez) && (rt == 5'b00001);
	 wire bgtz = (opcode == `bgtz);
	 wire blez = (opcode == `blez);
	 wire bltz = (opcode == `bltz) && (rt == 5'b00000);
	 wire sb = (opcode == `sb);		//store
	 wire sh = (opcode == `sh);
	 wire sw = (opcode == `sw);
	 wire lb = (opcode == `lb);		//load
	 wire lbu = (opcode == `lbu);
	 wire lh = (opcode == `lh);
	 wire lhu = (opcode == `lhu);
	 wire lw = (opcode == `lw);
	 wire j = (opcode == `j);			//jump
	 wire jal = (opcode == `jal);
	 wire lui = (opcode == `lui);
	 wire mfc0 = (opcode == `COP0) && (rs == `mfc0);
	 wire mtc0 = (opcode == `COP0) && (rs == `mtc0);
	 assign syscalls = (opcode == 6'b101111) && (func == 6'b001100);
	 
	 wire branch1 = bgez | bgtz | blez | bltz;
	 wire branch2 = beq | bne;
	 wire cal_r = add | addu | sub | subu | slt | sltu | AND | OR | NOR |
					  XOR | sllv | srlv | srav;
	 wire cal_i = addi | addiu | slti | sltiu | andi | ori | xori;
	 wire load = lb | lbu | lh | lhu | lw;
	 wire store = sb | sh | sw;
	 wire mul_div = mult | multu | div | divu;
	 wire shift1 = sll | srl | sra;
	 
	 assign RegDst = (cal_r | shift1 | jalr | mfhi | mflo) ? 3'b01 :
						  (jal) ? 3'b10 : 3'b00;	//load | cal_i = 0
	 assign RegWrite = (cal_r | shift1 | cal_i | lui | load | jal | jalr | mfhi | mflo | mfc0) ? 1'b1 : 1'b0;
	 assign MemWrite = (store) ? 1'b1 : 1'b0;
	 assign MDUWrite = (mthi | mtlo) ? 1'b1 : 1'b0;
	 assign CP0Write = (mtc0) ? 1'b1 : 1'b0;
	 assign MemtoReg = (load) ? 3'b01 :
							 (lui) ? 3'b10 :
							 (jal | jalr) ? 3'b11 :
							 (mfhi) ? 3'b100 : 
							 (mflo) ? 3'b101 : 
							 (mfc0) ? 3'b110 : 3'b00;	//cal_r | cal_i = 3'b0
							 
	 assign ALUOp = (add | addu | addi | addiu | store | load) ? 4'd1 :
						 (sub | subu) ? 4'd2 :
						 (slt | slti) ? 4'd3 :
						 (sltu | sltiu) ? 4'd4 :
						 (AND | andi) ? 4'd5 :
						 (OR | ori) ? 4'd6 :
						 (NOR) ? 4'd7 :
						 (XOR | xori) ? 4'd8 :
						 (sll) ? 4'd9 :
						 (srl) ? 4'd10 :
						 (sra) ? 4'd11 :
						 (sllv) ? 4'd12 :
						 (srlv) ? 4'd13 :
						 (srav) ? 4'd14 : 4'd0;
	 assign MultDivOp = (mult) ? 4'd1 :
							  (multu) ? 4'd2 :
							  (div) ? 4'd3 :
							  (divu) ? 4'd4 :
							  (mthi) ? 4'd5 :
							  (mtlo) ? 4'd6 : 4'd0;
	 assign ALUSrc = (cal_i | store | load) ? 3'b01 : 3'b00;	//cal_r
	 assign NPCSrc = ((branch1 | branch2) & comp) ? 3'b01 :
						  (jal | j) ? 3'b10 : 
						  (jr | jalr) ? 3'b11 : 3'b00;
	 assign CompOp = (beq) ? 3'd1 :
						  (bne) ? 3'd2 :
						  (bgez) ? 3'd3 :
						  (bgtz) ? 3'd4 :
						  (blez) ? 3'd5 :
						  (bltz) ? 3'd6 : 3'd0;
	 assign ExtOp = (andi | ori | xori) ? 3'd1 :
						 (addi | addiu | slti | sltiu | store | load | branch1 | branch2) ? 3'd2 :
						 (lui) ? 3'd3 : 3'd0;
	 assign M_ExtOp = (lbu) ? 3'd1 :
							(lb) ? 3'd2 : 
							(lhu) ? 3'd3 :
							(lh) ? 3'd4 : 3'd0;	//lw = 0
							
	 assign RI = ~(branch1 | branch2 | cal_r | shift1 | cal_i | load | store | 
					 mul_div | mfhi | mflo | mthi | mtlo | j | jal | jr | jalr | lui | mfc0 | mtc0 | eret | syscalls);
				  
	 wire E_Ov = (add | addi | sub) & (overflow);
	 
	 wire E_AdEL = (load & overflow) |
						(lw & (|alu[1:0])) | ((lh | lhu) & alu[0]) | 
						((lh | lhu | lb | lbu) & (alu >= `start_addr_timer0 && alu <= `end_addr_timer0)) | 
						((lh | lhu | lb | lbu) & (alu >= `start_addr_timer1 && alu <= `end_addr_timer1)) | 
						(load & ~((alu >= `start_addr_dm && alu <= `end_addr_dm) |
						(alu >= `start_addr_timer0 && alu <= `end_addr_timer0) |
						(alu >= `start_addr_timer1 && alu <= `end_addr_timer1)));
						
	 wire E_AdES = (store & overflow) |
						(sw & (|alu[1:0])) | (sh & alu[0]) | 
						((sh | sb) & (alu >= `start_addr_timer0 && alu <= `end_addr_timer0)) | 
						((sh | sb) & (alu >= `start_addr_timer1 && alu <= `end_addr_timer1)) | 
						(store & (alu >= 32'h0000_7f08 && alu <= 32'h0000_7f0b)) |	//timer_count
						(store & (alu >= 32'h0000_7f18 && alu <= 32'h0000_7f1b)) |
						(store & ~((alu >= `start_addr_dm && alu <= `end_addr_dm) |
						(alu >= `start_addr_timer0 && alu <= `end_addr_timer0) |
						(alu >= `start_addr_timer1 && alu <= `end_addr_timer1)));
	 
	 assign E_ExcCode = (ExcCode) ? ExcCode :
							  (E_Ov) ? `Ov :
							  (E_AdEL) ? `AdEL : 
							  (E_AdES) ? `AdES : 0;
							  
	 assign bd = (branch1 | branch2 | j | jal | jr | jalr);
	
	 assign start = mul_div ? 1 : 0;
	 assign Tuse_rs = (branch1 | branch2 | jalr | jr) ? 3'b0 :	
							(cal_r | cal_i | load | store | mthi | mtlo | mul_div) ? 3'b1 : 3'd6;	
	 assign Tuse_rt = (branch2) ? 3'b0 :
							(cal_r | shift1 | mul_div) ? 3'b01 :
							(store | mtc0) ? 3'b10 : 3'd6;
	 assign Tnew = (lui | jal | jalr) ? 3'b0 :
						(cal_r | shift1 | cal_i | mfhi | mflo) ? 3'b1 :
						(load | mfc0) ? 3'b10 : 3'd5;
						
	 //lui & j & jalÎŞTuse
	 //jr & beq & j & storeÎŞTnew
endmodule
