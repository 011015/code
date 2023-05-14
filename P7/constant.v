`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:28:57 12/17/2021 
// Design Name: 
// Module Name:    constant 
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
`define opcode 31:26
`define rs 25:21
`define rt 20:16
`define rd 15:11
`define shamt 10:6
`define func 5:0
`define imm26 25:0
`define imm16 15:0

//cal_i 
`define addi 6'b001000
`define addiu 6'b001001
`define slti 6'b001010
`define sltiu 6'b001011
`define andi 6'b001100
`define ori 6'b001101
`define xori 6'b001110
`define sll 6'b000000	//special
`define srl 6'b000010	//special
`define sra 6'b000011	//special

//cal_r	//special
`define add 6'b100000
`define addu 6'b100001
`define sub 6'b100010
`define subu 6'b100011
`define slt 6'b101010
`define sltu 6'b101011
`define AND 6'b100100
`define OR 6'b100101
`define NOR 6'b100111
`define XOR 6'b100110
`define sllv 6'b000100
`define srlv 6'b000110
`define srav 6'b000111

//branch
`define beq 6'b000100
`define bne 6'b000101
`define bgez 6'b000001
`define bgtz 6'b000111
`define blez 6'b000110
`define bltz 6'b000001

//store
`define sb 6'b101000
`define sh 6'b101001
`define sw 6'b101011

//load
`define lb 6'b100000
`define lbu 6'b100100
`define lh 6'b100001
`define lhu 6'b100101
`define lw 6'b100011

//mult,div  //special
`define mfhi 6'b010000
`define mflo 6'b010010
`define mthi 6'b010001
`define mtlo 6'b010011
`define mult 6'b011000
`define multu 6'b011001
`define div 6'b011010
`define divu 6'b011011

//jump
`define j 6'b000010
`define jal 6'b000011
`define jalr 6'b001001	//special
`define jr 6'b001000		//special

`define lui 6'b001111

//CP0
`define COP0 6'b010000
`define eret 6'b011000	//func
`define mtc0 5'b00100	//rs
`define mfc0 5'b00000	//rs
`define SR 5'd12
`define Cause 5'd13
`define EPC 5'd14
`define PRId 5'd15
`define IM SR[15:10]
`define IE SR[0]
`define EXL SR[1]
`define IP Cause[15:10]
`define ExcCode Cause[6:2]
`define BD Cause[31]

//ExcCode
`define Int 5'd0
`define AdEL 5'd4
`define AdES 5'd5
`define SYSCALLS 5'd8
`define RI 5'd10
`define Ov 5'd12

//addr
`define start_addr_dm 32'h0000_0000
`define end_addr_dm 32'h0000_2fff

`define start_addr_im 32'h0000_3000
`define end_addr_im 32'h0000_6fff

`define start_addr_timer0 32'h0000_7f00
`define end_addr_timer0 32'h0000_7f0b

`define start_addr_timer1 32'h0000_7f10
`define end_addr_timer1 32'h0000_7f1b