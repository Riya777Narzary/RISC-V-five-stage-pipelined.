`timescale 1ns/1ps

module RegIF_ID(instrF, PCF, PCplus4F, clk, rst,clr, en,instrD,PCD,PCPlus4D);
    input signed [31:0] instrF, PCF, PCplus4F;
    input clk,rst,en,clr;
    output reg signed [31:0] instrD,PCD,PCPlus4D;
    
    reg[31:0] inst, pc, pclus4;
    
    always@ (posedge clk) begin
        if(rst | clr) begin
                instrD <= 32'b0;
                PCD <= 32'b0;
                PCPlus4D <= 32'b0;
            end
        else if(en == 1'b0) begin
                instrD <= instrF;
                PCD <= PCF;
                PCPlus4D <= PCplus4F;
            end
        else
            begin
                instrD <= inst;
                PCD <= pc;
                PCPlus4D <= pclus4;
            end
    end
    
    always@(*) begin
        inst = instrD;
        pc = PCD;
        pclus4 = PCPlus4D; 
    end
    
endmodule
