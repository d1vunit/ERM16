module muxN

 #(parameter bits = 16,size = 2,set=1)

 (input logic [size-1:0] [bits-1:0] DI,input logic [set-1:0] sel,output logic [bits-1:0] DO);

 assign DO = DI[sel];

 endmodule

