`timescale 1ns / 1ps

`define sw 2'b10
`define sb 2'b00
`define sh 2'b01



module store_controller(funct3, result);
    input [1:0] funct3;
    output reg [1:0] result;
    
    always@ (*) begin
  
        case(funct3)
            `sw: result = 2'b00;
            `sb: result = 2'b01;
            `sh: result = 2'b10;
            2'b11: result = 2'b11;
            default: result = 2'bx;
        endcase
    end
endmodule
