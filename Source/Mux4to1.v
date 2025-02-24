`timescale 1ns/1ps

module Mux4to1(in0, in1, in2, in3,sel, out);
    input signed [31:0] in0, in1, in2, in3;
    input [1:0]sel;
    output reg signed [31:0]out;
    
    always @(*)begin
        case(sel)
            2'b00: out = in0;
            2'b01: out = in1;
            2'b10: out = in2;
            2'b11: out = in3;

            default: out = 32'bx;
        endcase
    end
    
    
endmodule
