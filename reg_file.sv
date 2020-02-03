module reg_file

 #(parameter bits = 16,N = 3)

 (input logic [N-1:0] RA1,RA2,WA3,input logic WE3,clk,rst,input logic [bits-1:0] WD3,output logic [bits-1:0] RD1,RD2);

 logic [bits-1:0] sram [2**N-1:0];

 always_ff @ (posedge clk,posedge rst) begin

	 if (rst) begin
		
		 sram[0] <= 'b0;
		 sram[1] <= 'b0;
		 sram[2] <= 'b0;
		 sram[3] <= 'b0;
		 sram[4] <= 'b0;
		 sram[5] <= 'b0;
		 sram[6] <= 'b0;
		 sram[7] <= 'b0;
	end

	 else if (WE3) sram[WA3] <= WD3;

 end

 assign RD1 = sram[RA1];
 assign RD2 = sram[RA2];
/*
 initial begin

	 $readmemh("prog.mem",sram);
	 $display("r0 : 0x%h\nr1 : 0x%h\nr2 : 0x%h\nr3 : 0x%h\nr4 : 0x%h\nr5 : 0x%h\nr6 : 0x%h\nr7 : 0x%h",sram[0],sram[1],sram[2],sram[3],sram[4],sram[5],sram[6],sram[7]);
 end
*/
endmodule
