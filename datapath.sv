import lc3b_types::*;

module datapath
(
    input clk,

    /* control signals */
	 
    input load_pc,
    input load_cc,
    input load_ir,
    input load_mar,
    input load_mdr,
    input load_regfile,

    input mdrmux_sel,
	 input lc3b_3bit_sel pcmux_sel,
	 input storemux_sel,
    input lc3b_3bit_sel alumux_sel,
    input lc3b_2bit_sel marmux_sel,
    input lc3b_3bit_sel regfilemux_sel,

    input lc3b_aluop aluop,

    /* declare more ports here */
    input lc3b_word mem_rdata,

    //output [3:0] opcode,
    output lc3b_opcode opcode,
    output lc3b_word mem_address, 
    output lc3b_word mem_wdata,
	
    output logic branch_enable,
	 output logic jsrr_enable,
	 output logic imm5_enable,
	 output logic D_bit,
	 output logic A_bit
);


lc3b_offset6 offset6;
lc3b_offset9 offset9;
lc3b_offset11 offset11;

lc3b_word sext5_out;
lc3b_word sext6_out;

lc3b_imm5 imm5;
lc3b_imm4 imm4;

lc3b_reg sr1;
lc3b_reg sr2;
lc3b_reg dest;
lc3b_reg storemux_out;

lc3b_nzp cc_out;
lc3b_nzp gencc_out;

lc3b_word pcmux_out;
lc3b_word alumux_out;
lc3b_word marmux_out;
lc3b_word mdrmux_out;

lc3b_word sr2_out;
lc3b_word adj6_out;
lc3b_word adj9_out;
lc3b_word adj11_out;
lc3b_word zext_mem;
lc3b_word regfilemux_out;
lc3b_word pc_out;
lc3b_word br_add_out;
lc3b_word jsr_add_out;
lc3b_word pc_plus2_out;
lc3b_word alu_out;
lc3b_word sr1_out;
lc3b_word zext_imm4;
lc3b_word zext_trapvector;
lc3b_word zext_mem_low;
lc3b_word zext_mem_high;

lc3b_byte mem_wdata_low;
lc3b_byte mem_wdata_high;
lc3b_byte trapvector;
assign mem_wdata_low = mem_wdata[7:0];
assign mem_wdata_high = mem_wdata[15:8];

/*
 * PC
 */
mux8 pcmux
(
    .sel(pcmux_sel),
    .a(pc_plus2_out),
    .b(br_add_out),
	 .c(sr1_out),
	 .d(jsr_add_out),
	 .e(zext_trapvector),
	 .f(pc_plus2_out),
	 .g(pc_plus2_out),
	 .h(pc_plus2_out),
    .out(pcmux_out)
);

register pc
(
    .clk,
    .load(load_pc),
    .in(pcmux_out),
    .out(pc_out)
);

mux2 #(.width(3)) storemux
(
	.sel(storemux_sel),
	.a(sr1),
	.b(dest),
	.f(storemux_out)
);

mux3 marmux
(
    .sel(marmux_sel),
    .a(alu_out),
    .b(pc_out),
    .c(mem_wdata),
    .f(marmux_out)
);

register mar
(
    .clk,
    .load(load_mar),
    .in(marmux_out),
    .out(mem_address)
);
plus2 pc_plus2
(
    .in(pc_out),
    .out(pc_plus2_out)
);

adder br_adder 
(
    .a(adj9_out),
    .b(pc_out),
    .sum(br_add_out)
);

adder jsr_adder 
(
    .a(adj11_out),
    .b(pc_out),
    .sum(jsr_add_out)
);



register mdr
(
    .clk,
    .load(load_mdr),
    .in(mdrmux_out),
    .out(mem_wdata)
);
mux2 mdrmux
(
    .sel(mdrmux_sel),
    .a(alu_out),
    .b(mem_rdata),
    .f(mdrmux_out)
);


mux8 regfilemux
(
    .sel(regfilemux_sel),
    .a(alu_out),
    .b(mem_wdata),
	 .c(br_add_out),
    .d(zext_mem_low),
	 .e(zext_mem_high),
	 .f(pc_out),
	 .g(alu_out),
	 .h(alu_out),
    .out(regfilemux_out)
);

regfile regfile 
(
    .clk,
    .load(load_regfile), 
    .in(regfilemux_out), 
    .src_a(storemux_out), 
    .src_b(sr2),
    .dest(dest),
    .reg_a(sr1_out),
    .reg_b(sr2_out)
);


nzp_comp cccomp 
(
    .dest(dest),
    .cc(cc_out),
    .out(branch_enable)
);



gencc gencc
(
    .in(regfilemux_out),
    .out(gencc_out)
);
ir IR 
(
    .clk,
    .load(load_ir),
    .in(mem_wdata),
    .opcode(opcode),
    .dest(dest),
    .src1(sr1),
    .src2(sr2),
    .offset6(offset6),
    .offset9(offset9),
	 .offset11(offset11),
	 .imm5(imm5),
	 .imm5_enable(imm5_enable),
	 .A_bit(A_bit),
	 .D_bit(D_bit),
	 .trapvector(trapvector),
	 .imm4(imm4),
	 .jsrr_enable(jsrr_enable)
);

register #(.width(3)) CC
(
    .clk,
    .load(load_cc),
    .in(gencc_out),
    .out(cc_out)
);


alu ALU 
(
    .aluop(aluop),
    .a(sr1_out),
    .b(alumux_out),
    .f(alu_out)
);

adj #(.width(11)) adj11
(
    .in(offset11),
    .out(adj11_out)
);

adj #(.width(9)) adj9
(
    .in(offset9),
    .out(adj9_out)
);

adj #(.width(6)) adj6
(
    .in(offset6),
    .out(adj6_out)
);

sext #(.width(5)) sext5
(
    .in(imm5),
    .out(sext5_out)
);

sext #(.width(6)) sext6
(
    .in(offset6),
    .out(sext6_out)
);

mux8 alumux 
(
    .sel(alumux_sel),
    .a(sr2_out),
    .b(adj6_out),
	 .c(sext5_out),
    .d(zext_imm4),
	 .e(sext6_out),
	 .f(sext6_out),
	 .g(sext6_out),
	 .h(sext6_out),
    .out(alumux_out)
);

zext #(.width(4)) imm4_zext 
(
.in(imm4),
.out(zext_imm4)
);

zext #(.width(8)) zext_memw_low
(
.in(mem_wdata_low),
.out(zext_mem_low)
);

zext #(.width(8)) zext_memw_high
(
.in(mem_wdata_high),
.out(zext_mem_high)
);

zextadj #(.width(8)) zext_trap
(
.in(trapvector),
.out(zext_trapvector)
);



endmodule : datapath