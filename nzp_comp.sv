module nzp_comp
(
	input [2:0] cc, 
	input [2:0] dest,
	output logic out
);


always_comb
	begin
		if((cc[0] && dest[0]) || 
			(cc[1] && dest[1]) || 
			(cc[2] && dest[2]))
			out = 1;
		else
			out = 0;
	end
endmodule : nzp_comp