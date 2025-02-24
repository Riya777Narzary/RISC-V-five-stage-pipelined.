`timescale 1ns/1ps

module Mux2to1(in1, in0,sel,out);
    input signed [31:0]in1,in0;
    input [0:0]sel;
    output signed [31:0] out;
    
    
    assign out = sel? in1:in0; 
endmodule
