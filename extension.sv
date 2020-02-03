module extension

#(parameter inp_bits = 6)

(input logic [inp_bits-1:0] DI,output logic [2*inp_bits-1:0] DO);

always_comb begin

	DO = 'b0;

	case(DI[inp_bits-1])

		1: begin 
		
			DO[inp_bits-1:0] = DI;
			DO[2*inp_bits-1:inp_bits] = 'b11111111;
		end
		0: begin
			
			DO[inp_bits-1:0] = DI;
			DO[2*inp_bits-1:inp_bits] = 'b0;
		 end
			
		default: DO = 'b0;
		
	endcase

end

endmodule

