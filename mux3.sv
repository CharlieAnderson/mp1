module mux3 #(parameter width = 16)
(
	input [1:0] sel, 
	input [width-1:0] a, b, c,
	output logic [width-1:0] f
);

always_comb
begin
	case(sel)
		2'b00: begin
			f = a;
		end
		
		2'b01: begin
			f = b;
		end
		
		2'b10: begin
			f = c;
		end		
		
		default: f=a;
	endcase
end

endmodule : mux3