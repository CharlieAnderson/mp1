import lc3b_types::*;

module mp1
(
    input clk,

    /* Memory signals */
    input mem_resp,
    input lc3b_word mem_rdata,
    output mem_read,
    output mem_write,
    output lc3b_mem_wmask mem_byte_enable,
    output lc3b_word mem_address,
    output lc3b_word mem_wdata
);

/* Instantiate MP 0 top level blocks here */

logic load_cc;
logic load_ir;
logic load_mar;
logic load_mdr;
logic load_pc;
logic load_regfile;
logic storemux_sel;

logic mdrmux_sel;
logic branch_enable;
logic jsrr_enable;
logic imm5_enable;
logic A_bit;
logic D_bit;

lc3b_2bit_sel marmux_sel;
lc3b_3bit_sel alumux_sel;
lc3b_3bit_sel regfilemux_sel;
lc3b_3bit_sel pcmux_sel;
lc3b_aluop aluop;
lc3b_opcode opcode;

datapath data
(
	 .clk,
	 .load_pc(load_pc),
	 .load_ir(load_ir),
	 .load_regfile(load_regfile),
	 .load_mar(load_mar),
	 .load_mdr(load_mdr),
	 .load_cc(load_cc),
    .pcmux_sel(pcmux_sel),
	 .storemux_sel(storemux_sel),
	 .alumux_sel(alumux_sel),
	 .regfilemux_sel(regfilemux_sel),
	 .marmux_sel(marmux_sel),
	 .mdrmux_sel(mdrmux_sel),
	 .branch_enable(branch_enable),
	 .aluop(aluop),
	 .opcode(opcode),
	 .mem_rdata(mem_rdata),
	 .mem_address(mem_address),
	 .mem_wdata(mem_wdata),
	 .jsrr_enable(jsrr_enable),
	 .imm5_enable(imm5_enable),
	 .A_bit(A_bit),
	 .D_bit(D_bit)
	
);

control Control
(
    .clk,

    /* control signals */
	 .opcode(opcode),
	 .load_pc(load_pc),
	 .load_ir(load_ir),
	 .load_regfile(load_regfile),
	 .load_mar(load_mar),
	 .load_mdr(load_mdr),
	 .load_cc(load_cc),
	 .byte_enable(mem_address[0]),
    .pcmux_sel(pcmux_sel),
	 .storemux_sel(storemux_sel),
	 .alumux_sel(alumux_sel),
	 .regfilemux_sel(regfilemux_sel),
	 .marmux_sel(marmux_sel),
	 .mdrmux_sel(mdrmux_sel),
	 .branch_enable(branch_enable),
	 .aluop(aluop),
	 .mem_byte_enable(mem_byte_enable),
	 .mem_resp(mem_resp),
	 .mem_read(mem_read),
	 .mem_write(mem_write),
	 .jsrr_enable(jsrr_enable),
	 .imm5_enable(imm5_enable),
	 .A_bit(A_bit),
	 .D_bit(D_bit)
);
endmodule : mp1
