`timescale 1ns/1ps

module adder(in1,  in2, result);
    input signed [31:0] in1, in2;
    output signed [31:0] result;
    
    assign result = in1 + in2;
endmodule
