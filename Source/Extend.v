`timescale 1ns/1ps

`define  I_T 3'b000
`define  S_T 3'b001
`define  B_T 3'b010
`define  J_T 3'b011
`define  U_T 3'b100
`define sra 3'b101
`define slli_srli 3'b110



module Extend(ImmSrc, ImmExt, data);
    input [2:0] ImmSrc;
    input [24:0] data;
    output reg signed [31:0] ImmExt;
    
    always@(data or ImmSrc)begin
        case(ImmSrc)
            `I_T: ImmExt = {{20{data[24]}}, data[24:13]};
            `S_T: ImmExt = {{20{data[24]}}, data[24:18], data[4:0]};
            `B_T: ImmExt = {{20{data[24]}}, data[0], data[23:18], data[4:1], 1'b0};
            `J_T: ImmExt = {{12{data[24]}}, data[12:5], data[13], data[23:14], 1'b0};
            `U_T: ImmExt = {data[24:5], {12{1'b0}}};
            `sra: ImmExt = {{14{1'b0}},{6{1'b0}}, data[17:13]};
            `slli_srli: ImmExt = { {19{1'b0}}, data[17:13]};
            
            default: ImmExt = 32'b0;
        endcase
    end
    
endmodule
