module mux8 #(parameter width = 16)
(
	input [2:0] sel, 
	input [width-1:0] a, b, c, d, e, f, g, h,
	output logic [width-1:0] out
);

always_comb
begin
	case(sel)
		3'b000: begin
			out = a;
		end
		
		3'b001: begin
			out = b;
		end
		
		3'b010: begin
			out = c;
		end		
		
		3'b011: begin
			out = d;
		end	
		
		3'b100: begin
			out = e;
		end
		
		3'b101: begin
			out = f;
		end
		
		3'b110: begin
			out = g;
		end		
		
		3'b111: begin
			out = h;
		end	
		
		default: out=a;
	endcase
end

endmodule : mux8