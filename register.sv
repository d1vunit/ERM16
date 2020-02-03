module register 

 #(parameter bits = 6)

 (input logic [bits-1:0]  D,input logic clk,rst,hlt,output logic [bits-1:0] Q);
 logic w_clk;
 assign w_clk = hlt? clk:0;

 always_ff @ (posedge w_clk,posedge rst) begin

	 if (rst) Q <= 'b0;

	 else Q <= D;
 end

endmodule
