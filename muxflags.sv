module muxflags (input logic [5:0] DI,input logic [2:0] sel,output logic DO);

assign DO = DI[sel];

endmodule