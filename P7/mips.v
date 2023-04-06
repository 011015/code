`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:30:25 12/17/2021 
// Design Name: 
// Module Name:    mips 
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
module mips(
    input clk,                       // 时钟信号
    input reset,                     // 同步复位信号
    input interrupt,                 // 外部中断信号
    output [31:0] macroscopic_pc,    // 宏观 PC（见下文）

    output [31:0] i_inst_addr,       // 取指 PC
    input  [31:0] i_inst_rdata,      // i_inst_addr 对应的 32 位指令

    output [31:0] m_data_addr,       // 数据存储器待写入地址
    input  [31:0] m_data_rdata,      // m_data_addr 对应的 32 位数据
    output [31:0] m_data_wdata,      // 数据存储器待写入数据
    output [3 :0] m_data_byteen,     // 字节使能信号

    output [31:0] m_inst_addr,       // M 级PC

    output w_grf_we,                 // grf 写使能信号
    output [4 :0] w_grf_addr,        // grf 待写入寄存器编号
    output [31:0] w_grf_wdata,       // grf 待写入数据

    output [31:0] w_inst_addr        // W 级 PC
    );
	 
	 wire [15:10] HWInt = {3'b0,interrupt,TIMER1_IRQ,TIMER0_IRQ};
	 
	 //CPU
	 wire t_Req;
	 reg Req = 0;	//interrupt
	 wire [3:0] CPU_byteen;
	 wire [31:0] CPU_Addr,CPU_WD;
	 
	 //Bridge
	 wire [3:0] bridge_data_byteen;
	 wire [31:0] bridge_data_addr;
	 
	 //TIMER
	 wire TIMER0_WE,TIMER1_WE;
	 wire TIMER0_IRQ,TIMER1_IRQ;
	 wire [31:0] TIMER0_RD,TIMER1_RD,DEV_RD;
	 
	 CPU CPU_(.clk(clk),
				 .reset(reset),
				 .i_inst_rdata(i_inst_rdata),
				 .m_data_rdata(DEV_RD),
				 .HWInt(HWInt),
				 .i_inst_addr(i_inst_addr),
				 .m_data_addr(CPU_Addr),
				 .m_data_wdata(CPU_WD),
				 .m_data_byteen(CPU_byteen),
				 .m_inst_addr(m_inst_addr),
				 .w_grf_we(w_grf_we),
				 .w_grf_addr(w_grf_addr),
				 .w_grf_wdata(w_grf_wdata),
				 .w_inst_addr(w_inst_addr),
				 .macroscopic_pc(macroscopic_pc),
				 .t_Req(t_Req)
				 );
	 
	 always @(posedge clk) begin
		Req <= t_Req;
	 end
	 assign m_data_addr = (Req) ? 32'h0000_7f20 : bridge_data_addr;
	 assign m_data_byteen = (Req) ? 4'h1 : bridge_data_byteen;
	 
	 bridge bridge_(.CPU_Addr(CPU_Addr),
						 .CPU_byteen(CPU_byteen),
						 .CPU_WD(CPU_WD),
						 .DM_RD(m_data_rdata),
						 .TIMER0_RD(TIMER0_RD),
						 .TIMER1_RD(TIMER1_RD),
						 .DEV_Addr(bridge_data_addr),
						 .DM_byteen(bridge_data_byteen),
						 .DM_WD(m_data_wdata),
						 .TIMER0_WE(TIMER0_WE),
						 .TIMER1_WE(TIMER1_WE),
						 .DEV_RD(DEV_RD)
						 );
	 
	 TC timer0(.clk(clk),
				  .reset(reset),
				  .Addr(bridge_data_addr[31:2]),
				  .WE(TIMER0_WE),
				  .Din(m_data_wdata),
				  .Dout(TIMER0_RD),
				  .IRQ(TIMER0_IRQ)
				  );
				  
	 TC timer1(.clk(clk),
				  .reset(reset),
				  .Addr(bridge_data_addr[31:2]),
				  .WE(TIMER1_WE),
				  .Din(m_data_wdata),
				  .Dout(TIMER1_RD),
				  .IRQ(TIMER1_IRQ)
				  );

endmodule
