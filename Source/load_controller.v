`timescale 1ns / 1ps

`define lw 3'b010
`define lb 3'b000
`define lh 3'b001
`define lbu 3'b100
`define lhu 3'b101


module load_controller(funct3, result);
    input [2:0] funct3;
    output reg [2:0] result;
    
    always@(*)begin
        case(funct3)
            `lw : result = 3'b000;
            `lb : result = 3'b001;
            `lh : result = 3'b010;
            `lbu : result = 3'b011;
            `lhu : result = 3'b100;
            3'b110 : result = 3'b0;
            3'b111: result = 3'b0;
            default : result = 3'b0;
        endcase
    end
endmodule
