`timescale 1ns / 1ps

`define lw 3'b010
`define lb 3'b000
`define lh 3'b001
`define lbu 3'b100
`define lhu 3'b101


module mux8to1(result, sel, in0, in1, in2, in3, in4, in5, in6, in7);
    input signed [31:0] in0, in1, in2, in3, in4, in5, in6, in7;
    input [2:0] sel;
    output reg signed [31:0] result;
    
    always@ (*) begin
        case(sel)
            `lw : result = in0;
            `lb : result = in1;
            `lh : result = in2;
            `lbu : result = in3;
            `lhu : result = in4;
            3'b011: result = in5;
            3'b110: result = in6;
            3'b111: result = in7;
            default : result = 32'b0;
         endcase
    end
    
endmodule
