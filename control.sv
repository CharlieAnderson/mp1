import lc3b_types::*; /* Import types defined in lc3b_types.sv */

module control
(
    /* Input and output port declarations */
	 
	input clk,
	input branch_enable,
	input imm5_enable,
	input jsrr_enable,
	input mem_resp,
	input D_bit,
	input A_bit,
	input byte_enable,
	
	/* Datapath controls */
	input lc3b_opcode opcode,
	output logic load_pc,
	output logic load_ir,
	output logic load_regfile,
	output logic load_mar,
	output logic load_mdr,
	output logic load_cc,
	output lc3b_3bit_sel pcmux_sel,
	output logic storemux_sel,
	output lc3b_3bit_sel alumux_sel,
	output lc3b_3bit_sel regfilemux_sel,
	output lc3b_2bit_sel marmux_sel,
	output logic mdrmux_sel,
	output lc3b_aluop aluop,

	/* Memory signals */
	output logic mem_read,
	output logic mem_write,
	output lc3b_mem_wmask mem_byte_enable
	
);

enum int unsigned {
    /* List of states */
	fetch1,
	fetch2,
	fetch3,
	decode,
	s_add,
	s_add_imm,
	s_and,
	s_and_imm,
	s_not,
	calc_addr1,
	calc_addr2,
	s_lea,
	ldr1,
	ldr2,
	s_ldb1,
	s_ldb2,
	s_ldi1,
	s_ldi2,
	s_ldi3,
	s_ldi4,
	str1,
	str2,
	shf,
	s_stb1,
	s_stb2,
	s_sti1,
	s_sti2,
	s_sti3,
	s_sti4,
	trap1,
	trap2,
	trap3,
	trap4,
	rti,
	jmp,
	jsr,
	br,
	br_taken
} state, next_state;

always_comb
begin : state_actions
    /* Default output assignments */
	load_pc = 1'b0;
	load_ir = 1'b0;
	load_regfile = 1'b0;
	load_mar = 1'b0;
	load_mdr = 1'b0;
	load_cc = 1'b0;
	pcmux_sel = 3'b000;
	storemux_sel = 1'b0;
	alumux_sel = 3'b000;
	regfilemux_sel = 3'b000;
	marmux_sel = 2'b00;
	mdrmux_sel = 1'b0;
	aluop = alu_add;
	mem_read = 1'b0;
	mem_write = 1'b0;
	mem_byte_enable = 2'b11;
	
    /* Actions for each state */
	case(state)
		fetch1: begin
			/* MAR <= PC */
			marmux_sel = 1;
			load_mar = 1;
			/* PC <= PC + 2 */
			load_pc = 1;
		end
		
		fetch2: begin
			/* Read memory */
			mem_read = 1;
			mdrmux_sel = 1;
			load_mdr = 1;
		end
			
		fetch3: begin
			/* Load IR */
			load_ir = 1;
		end
			
		decode: /* Do nothing */;

		s_add: begin
			/* DR <= SRA + SRB */
			aluop = alu_add;
			load_regfile = 1;
			load_cc = 1;
		end
		
		s_add_imm: begin
			/* DR <= SRA + SEXT(imm5) */
			alumux_sel = 3'b010;
			aluop = alu_add;
			load_regfile = 1;
			load_cc = 1;
		end
		
		s_and: begin
			aluop = alu_and;
			load_regfile = 1;
			load_cc = 1;
		end
		
		s_and_imm: begin
			alumux_sel = 3'b010;
			aluop = alu_and;
			load_regfile = 1;
			load_cc = 1;
		end
		
		s_not: begin
			aluop = alu_not;
			load_regfile = 1;
			load_cc = 1;
		end
		
		calc_addr1: begin
			alumux_sel = 3'b001;
			aluop = alu_add;
			load_mar = 1;
		end
		
		calc_addr2: begin			// no shift, for ldb and stb
			alumux_sel = 3'b101;
			aluop = alu_add;
			load_mar = 1;
		end
		
		ldr1: begin
			mdrmux_sel = 1;
			load_mdr = 1;
			mem_read = 1;
		end
		
		ldr2: begin
			regfilemux_sel = 3'b001;
			load_regfile = 1;
			load_cc = 1;
		end
		
		s_lea: begin
			regfilemux_sel = 3'b010;
			load_regfile = 1;
			load_cc = 1;
		end
		
		str1: begin
			storemux_sel = 1;
			aluop = alu_pass;
			load_mdr = 1;
		end
		
		str2: begin
			mem_write = 1;
		end
		
		s_stb1: begin
			storemux_sel = 1;	
			aluop = alu_pass; //copy bits to both bytes??
			load_mdr = 1;
		end
		
		s_stb2: begin
		if(byte_enable == 1)
			mem_byte_enable = 2'b10;		// if mar[0] do 15:8, else do 7:0 ????
		else
			mem_byte_enable = 2'b01;		// if mar[0] do 15:8, else do 7:0 ????
		
		mem_write = 1;
		end
		
		s_sti1: begin
			load_mdr = 1;
			mdrmux_sel = 1;
			mem_read = 1;

		end
		
		s_sti2: begin 
			marmux_sel = 2'b10; 	// might have to do mem_write then use marmux instead of adding this port
			load_mar = 1;
		end

		s_sti3: begin
			storemux_sel = 1;
			aluop = alu_pass;
			load_mdr = 1;
		end

		s_sti4: begin

			mem_write = 1;

		end

		jmp: begin
			pcmux_sel = 3'b010;
			load_pc = 1;
		end
		
		jsr: begin
			load_pc = 1;
			if(jsrr_enable == 1) begin
				pcmux_sel = 3'b011;
			end
			else begin
				pcmux_sel = 3'b010;
			end
		end
		
		shf: begin
			load_cc = 1;
			load_regfile = 1;		//alumux imm4 zext?
			if(D_bit == 0)
				aluop = alu_sll;
			else begin
				if(A_bit == 0)
					aluop = alu_srl;
				else
					aluop = alu_sra;
			end
		end

		s_ldb1: begin
			mdrmux_sel = 1;
			mem_read = 1;
			load_mdr = 1;
		end 

		s_ldb2: begin
		if(byte_enable == 1)
			regfilemux_sel = 3'b100;		// if mar[0] do 15:8, else do 7:0 ????
		else
			regfilemux_sel = 3'b011;
			
			load_cc = 1;
			load_regfile =1;
		end

		s_ldi1: begin
			mdrmux_sel = 1;
			load_mdr = 1;
			mem_read = 1;
		end
		
		s_ldi2: begin
			load_mar = 1;
			marmux_sel = 2'b10;	// selects mem_wdata
		end

		s_ldi3: begin
			mdrmux_sel = 1;
			load_mdr = 1;
			mem_read = 1;
		end

		s_ldi4: begin
			regfilemux_sel = 3'b001;
			load_regfile = 1;
			load_cc = 1;
		end

		br: ; // nothing
		
		br_taken: begin
			pcmux_sel = 3'b001;
			load_pc = 1;
		end
		
		trap1: begin			// not sure if this is actually loading to r7
			load_regfile = 1;				// pc+ <- R7
			regfilemux_sel = 3'b101;	
		end
		
		trap2:  begin				
			load_mar = 1;
			marmux_sel = 2'b10;

		end
		
		trap3: begin
			mem_read = 1;
			mdrmux_sel = 1b'1;
			load_mdr = 1;
			
		end
		
		trap4: begin
			load_pc = 1;
			pcmux_sel = 3'b010;
			
		end
		default: /* Do nothing */;
		
	endcase
end

always_comb
begin : next_state_logic
    /* Next state information and conditions (if any)
     * for transitioning between states */
	case(state)
		fetch1: begin
			next_state = fetch2;
		end
		
		fetch2: begin
			if(mem_resp == 0)
				next_state = fetch2;
			else
				next_state = fetch3;
		end
			
		fetch3: begin
			next_state = decode;
		end
			
		decode: begin
			case(opcode)
				op_add: begin
					if(imm5_enable == 1)
						next_state = s_add_imm;
					else 
						next_state = s_add;
				end
				
				op_and: begin
					if(imm5_enable == 1)
						next_state = s_and_imm;
					else 
						next_state = s_and;
				end
				
				op_not: begin
					next_state = s_not;
				end
				
				op_lea: begin
					next_state = s_lea;
				end
				op_ldb: begin
					next_state = calc_addr2;
				end


				op_ldr: begin
					next_state = calc_addr1;
				end

				op_ldi: begin
					next_state = calc_addr1;
				end
				
				op_sti: begin
					next_state = calc_addr1;
				end
				
				op_str: begin
					next_state = calc_addr1;
				end
				
				op_jmp: begin
					next_state = jmp;
				end
				
				op_br: begin
					next_state = br;
				end
				
				op_jsr: begin
					next_state = jsr;
				end
				
				op_shf: begin
					next_state = shf;
				end
				
				op_stb: begin
					next_state = calc_addr2;
				end
				
				op_trap: begin
					next_state = trap1;
				end
				
				default: next_state = fetch1;
				
			endcase
		end

		s_add: begin
			next_state = fetch1;
		end
		
		s_add_imm: begin
			next_state = fetch1;
		end
		
		s_and: begin
			next_state = fetch1;
		end
		
		s_and_imm: begin
			next_state = fetch1;
		end		
		
		s_not: begin
			next_state = fetch1;
		end
		
		calc_addr1: begin
			case(opcode)
				op_ldr: begin
					next_state = ldr1;
				end
				
				op_str: begin
					next_state = str1;
				end
				
				op_sti: begin
					next_state = s_sti1;
				end
				op_ldi: begin
					next_state = s_ldi1;	
				end
				default: next_state = fetch1;
			endcase
		end
		
		calc_addr2: begin	// no left-shift
			case(opcode)
				op_ldb: begin
					next_state = s_ldb1;
				end
				
				op_stb: begin
					next_state = s_stb1;
				end
				
				default: next_state = fetch1;
			endcase
		end
		
		ldr1: begin
			if(mem_resp == 0)
				next_state = ldr1;
			else
				next_state = ldr2;
		end
		
		ldr2: begin
			next_state = fetch1;
		end

		s_ldb1: begin 
			if(mem_resp == 0)
				next_state = s_ldb1;
			else
				next_state = s_ldb2;
		end

		s_ldb2: begin
			next_state = fetch1;
		end

		s_ldi1: begin
			if(mem_resp == 0)
				next_state = s_ldi1;
			else
				next_state = s_ldi2;
		end

		s_ldi2: begin

			next_state = s_ldi3;
		end

		s_ldi3: begin
			if(mem_resp == 0)
				next_state = s_ldi3;
			else
				next_state = s_ldi4;
		end

		s_ldi4: begin
			next_state = fetch1;
		end
		
		
		s_sti1: begin
			if(mem_resp == 0)
				next_state = s_sti1;
			else
				next_state = s_sti2;
			end

		s_sti2: begin
			next_state = s_sti3;
		end

		s_sti3: begin
			next_state = s_sti4;
		end

		s_sti4: begin
			if(mem_resp == 0)
				next_state = s_sti4;
			else
				next_state = fetch1;
		end

		s_lea: begin
			next_state = fetch1;
		end
		
		s_stb1: begin
			next_state = s_stb2;
		end
		
		s_stb2: begin
			if(mem_resp == 0)
				next_state = str2;
			else
				next_state = fetch1;			
		end
		
		str1: begin
			next_state = str2;
		end
		
		str2: begin
			if(mem_resp == 0)
				next_state = str2;
			else
				next_state = fetch1;
		end
		
		shf: begin
			next_state = fetch1;
		end
		
		jmp: begin 
			next_state = fetch1;
		end
		
		jsr: begin //store pc first?
			next_state = fetch1;
		end
		
		br: begin
			if(branch_enable == 1)
				next_state = br_taken;
			else
				next_state = fetch1;
		end
		
		br_taken: begin
			next_state = fetch1;
		end
		
		trap1: begin
			next_state = trap2;
		end
		trap2: begin
			if(mem_resp == 0)
				next_state = trap2;
			else
				next_state = trap3;
		end
		trap3: begin
			next_state = trap4;
		end
		trap4: begin
			next_state = fetch1;
		end
		default: /* Do nothing */;
	endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
    /* Assignment of next state on clock edge */
	 state <= next_state;
end



endmodule : control
