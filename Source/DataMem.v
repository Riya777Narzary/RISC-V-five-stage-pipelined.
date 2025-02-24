`timescale 1ns/1ps

module DataMem(WD, A, clk, WE, RD, RD1);
    input [13:0] A;  // because this sofware doesn't support 32 bit size address line.
    input [31:0] WD;  //WD - write Data
    input clk;
    input WE;  //write enable
    output [31:0]RD,RD1;
    
    integer i;
    reg [31:0] datamem[0:99];
//    reg [31:0] datamem_next;
//    wire [31:0]adr;
//    assign adr = {A[31:2], 2'b00}; // address is 0, 4 , 8 ... each data is 4 bytes long.



    assign RD = datamem[A];   // Async read 
    assign RD1 = datamem[5]; // check for the datat to be stored.
    
    
//    always @(posedge clk)    // Sync write
//    begin
//            datamem[A] <= datamem_next;   // Store the previous value
//    end
    
    always@(posedge clk)begin
        if(WE)
            datamem[A] = WD;
            
    end
    initial   // initializing some values (with a gap of 4)
        begin
            datamem[0] = 32'h9F5D4A6E;
            datamem[4] = 32'he;
            datamem[8] = 32'h0000000a;
            datamem[12] = 32'h0000000a;
            datamem[28] = 32'h0;// Max value will be stored here.
            datamem[30] = 32'h5;
            datamem[34] = 32'ha;
            datamem[38] = 32'h6;
            datamem[42] = 32'h2;
            datamem[46] = 32'h8;
            datamem[50] = 32'h9;
            datamem[54] = 32'h7;
            datamem[58] = 32'h3;
            datamem[62] = 32'h4;
            datamem[66] = 32'h6;
            datamem[70] = 32'h6;
            
//              $readmemb("data.mem", datamem);
        end
endmodule
