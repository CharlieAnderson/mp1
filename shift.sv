module shift #(parameter width = 16)
(
	input A_bit, D_bit,
	input [3:0] imm4, // imm4 is unsigned
	input lc3b_reg sr1,
	output lc3b_reg dest
);

always_comb
begin
	if(D_bit == 0)
		dest = (sr1 << imm4);
	else begin
		if(A_bit == 0)
			dest = (imm4 >> sr1);
		else
			dest = (imm4 >> sr1);			
	end
end

endmodule : shift