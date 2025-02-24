`timescale 1ns/1ps

module RISC_DATAPATH(clk, rst, pcsrc, MemwriteD, 
                     AluControlSrcD, alusrcD, ImmsrcD, RegwriteD,
                     ALU_branch, op, funct3, funct7,jalD, jalrD, loadD, 
                     storeD,
                     //only for output
                    LoadSrcD, ResultSrcD,
                    pcsrc, StoreSrcD, jalE, jalrE, 
                    loadE, storeE
                    );
output [6:0]op;
output signed [2:0] funct3;
output ALU_branch, funct7;
output jalE, jalrE, loadE, storeE;

input clk, rst;
input signed [2:0]  LoadSrcD, ResultSrcD;
input signed [1:0] pcsrc, StoreSrcD;

input jalD, jalrD, loadD, storeD;
input signed [2:0]  ImmsrcD;
input signed [3:0] AluControlSrcD;
input RegwriteD, MemwriteD, alusrcD; 
 

//External wires to see output.
wire signed [31:0] resultWD_mux, result_load_reg;
wire signed [31:0] resultW;
wire signed [31:0] mem_loc, reg_loc;
wire signed [31:0] srcA, srcB;
            

     //Hazard unit wires
wire StallF, StallD, FlushD, FlushE;
wire [1:0] ForwardAE, ForwardBE;

//Pipeline (Control path wires)
wire RegwriteE, MemwriteE, alusrcE,
     RegwriteM, MemwriteM,
     RegwriteW;
   
wire signed [2:0] ResultSrcE, LoadSrcE,
           ResultSrcM, LoadSrcM,
           ResultSrcW, LoadSrcW;
           
wire signed [1:0]  StoreSrcE;
wire signed [3:0]  AluControlSrcE;
            
//Datapath wires (Pipeline)
wire signed [4:0]  Rs1E, Rs2E, RdE,
            RdM,
            RdW;
            
wire signed [31:0] PCF, PCPlus4F, InstrF,
            PCD, InstrD, PCPlus4D, ImmextD, RD1D, RD2D,
            PCE, PCPlus4E, ImmextE, RD1E, RD2E, AluResultE, WriteDataMuxE, auipcE,srcBE,
            PCPlus4M, ImmextM, auipcM, WriteDataMuxM, AluResultM, ReadDataM,
            PCPlus4W, ImmextW, auipcW, ReadDataW, AluResultW, pc_next, pctarget;
            
 assign auipcE = pctarget;
         
              
             
//MUX for pc selection
Mux4to1 PC_mux(.in0(PCPlus4F), .in1(pctarget), .in2(AluResultE), .in3(32'b0),
               .sel(pcsrc), .out(pc_next));

// register for pc
register PC_register(.data(pc_next), .clk(clk), .rst(rst), .out(PCF), .en(StallF));


//Instruction memory
InstMemory InstMemory(.A(PCF), .RD(InstrF));

//PC + 4 adder
adder PC_plus4_adder(.in1(PCF),  .in2(32'd4), .result(PCPlus4F));

//IF and ID Register.
RegIF_ID RegIF_ID(.instrF(InstrF), .PCF(PCF), .PCplus4F(PCPlus4F), .clk(clk), .rst(rst), .clr(FlushD), .en(StallD),
                         .instrD(InstrD), .PCD(PCD), .PCPlus4D(PCPlus4D));

//Register File
RegisterFile RegisterFile(.A1(InstrD[19:15]), .A2(InstrD[24:20]), .A3(RdW), 
                          .WD3(resultW), .clk(clk), .WE3(RegwriteW), .RD1(RD1D), .RD2(RD2D),
                          .rst(rst), .RD3(reg_loc));
                          
//Sign extension
Extend Extend(.ImmSrc(ImmsrcD), .ImmExt(ImmextD), .data(InstrD[31:7]));

//ID and EX Register

RegID_EX RegID_EX(
//output
.RegwriteE(RegwriteE), .MemwriteE(MemwriteE), .alusrcE(alusrcE), .resultsrcE(ResultSrcE), .load_srcE(LoadSrcE),
.store_srcE(StoreSrcE), .alucontrolE(AluControlSrcE), .Rd1E(RD1E), .Rd2E(RD2E), .ImmextE(ImmextE), 
.Pcplus4E(PCPlus4E), .PcE(PCE), .Rs1E(Rs1E), .Rs2E(Rs2E), .RdE(RdE), .clk(clk), .clr(FlushE), .rst(rst), .jalE(jalE), .jalrE(jalrE), .loadE(loadE), 
.storeE(storeE),
//input

.RegwriteD(RegwriteD), .MemwriteD(MemwriteD), .alusrcD(alusrcD), .resultsrcD(ResultSrcD), .load_srcD(LoadSrcD),
.store_srcD(StoreSrcD), .alucontrolD(AluControlSrcD), .Rd1D(RD1D), .Rd2D(RD2D), .ImmextD(ImmextD), .Pcplus4D(PCPlus4D), 
.PcD(PCD), .Rs1D(InstrD[19:15]), .Rs2D(InstrD[24:20]), .RdD(InstrD[11:7]), .jalD(jalD), .jalrD(jalrD), .loadD(loadD), 
.storeD(storeD)
);

//Mux for harzard rs1
Mux4to1 ForwardR1(.in0(RD1E), .in1(resultW), .in2(AluResultM), .in3(ImmextM),
               .sel(ForwardAE), .out(srcA));
               
//Mux for harzard rs2
Mux4to1 ForwardR2(.in0(RD2E), .in1(resultW), .in2(AluResultM), .in3(ImmextM),
               .sel(ForwardBE), .out(srcB));
               
//MUX for alu selection
Mux2to1 srcB_mux(.in1(ImmextE), .in0(srcB), .sel(alusrcE), .out(srcBE));

//ALU
alu ALU(.A(srcA), .B(srcBE), .Result(AluResultE), .ALUControl(AluControlSrcE), .ALU_branch(ALU_branch));

//PC target adder
adder PC_Target_Adder(.in1(PCE),  .in2(ImmextE), .result(pctarget));

//Store Mux
Mux4to1 store_mux(.in0(srcB), .in1({24'd0,srcB[7:0]}), .in2({16'd0, srcB[15:0]}), .in3(32'b0),
               .sel(StoreSrcE), .out(WriteDataMuxE));
               
// EX and MM Register.
RegEX_MM RegEX_MM(.clk(clk), .rst(rst), .regwriteE(RegwriteE), .memwriteE(MemwriteE), .rdE(RdE), 
                  .aluresultE(AluResultE), .writeDataE(WriteDataMuxE), .auipcE(auipcE),
                  .immextE(ImmextE), .pcplus4E(PCPlus4E), .resultsrcE(ResultSrcE), .loadsrcE(LoadSrcE), 
                 //output
                 .regwriteM(RegwriteM), .memwriteM(MemwriteM), .rdM(RdM), .aluresultM(AluResultM), 
                 .writeDataM(WriteDataMuxM), .auipcM(auipcM), .immextM(ImmextM), .pcplus4M(PCPlus4M)
                 , .resultsrcM(ResultSrcM), .loadsrcM(LoadSrcM)
                 ); 

//Data Memory
DataMem DataMem(.WD(WriteDataMuxM), .A(AluResultM[13:0]), .clk(clk), .WE(MemwriteM), .RD(ReadDataM), .RD1(mem_loc));

//MM and WB Register
RegMM_WB RegMM_WB(.clk(clk), .rst(rst), .regwriteM(RegwriteM), .rdM(RdM), .aluresultM(AluResultM), .readDataM(ReadDataM), 
                  .auipcM(auipcM), .immextM(ImmextM), .pcplus4M(PCPlus4M), .resultsrcM(ResultSrcM), .loadsrcM(LoadSrcM),
                 //output
                 .regwriteW(RegwriteW), .rdW(RdW), .aluresultW(AluResultW), .readDataW(ReadDataW), .auipcW(auipcW),
                 .immextW(ImmextW), .pcplus4W(PCPlus4W), .resultsrcW(ResultSrcW), .loadsrcW(LoadSrcW)
                 );


//Load mux
mux8to1 Load_mux(.in0(ReadDataW),.in1({{24{ReadDataW[7]}}, ReadDataW[7:0]}), .in2({{16{ReadDataW[15]}}, ReadDataW[15:0]}), 
                 .in3({24'd0, ReadDataW[7:0]}), .in4({16'd0, ReadDataW[15:0]}), 
                  .in5(32'b0), .in6(32'b0), .in7(32'b0),.result(resultWD_mux), .sel(LoadSrcW));
                  
//// Load register with en.
register Load_register(.data(resultWD_mux), .clk(clk),.rst(rst), .out(result_load_reg), .en(1'b0));

//Result MUX
mux8to1_result Result_mux(.in0(AluResultW), .in1(result_load_reg), .in2(PCPlus4W), .in3(ImmextW), 
               .in4(auipcW), .in5(32'b0), .in6(32'b0), .in7(32'b0), .sel(ResultSrcW), .result(resultW));
               
//Hazard Unit
Hazard_unit Hazard_unit(.RegwriteM(RegwriteM), .RegwriteW(RegwriteW), .Rs1E(Rs1E), .Rs2E(Rs2E), .RdM(RdM),
                   .forwardAE(ForwardAE), .forwardBE(ForwardBE), .resultsrcE(ResultSrcE), .stallF(StallF),
                   .stallD(StallD), .flushE(FlushE), .flushD(FlushD), .pcsrcE(pcsrc), .Rs1D(InstrD[19:15]), .Rs2D(InstrD[24:20]),
                   .RdW(RdW), .RdE(RdE), .Branch(ALU_branch), .jalD(jalD));


                     
assign op = InstrD[6:0];
assign funct3 = InstrD[14:12];
assign funct7 = InstrD[30];
//assign Rs1D = InstrD[19:15];
//assign Rs2D = InstrD[24:20];
//assign RdD = InstrD[11:7];

endmodule
