`timescale 1ns/1ps

module datapath(
  input  logic        clk, reset,
  input  logic [1:0]  ResultSrc,
  input  logic [1:0]  PCSrc,
  input  logic        ALUSrc,
  input  logic        RegWrite,
  input  logic [2:0]  ImmSrc,
  input  logic [3:0]  ALUControl,
  output logic        Zero,
  output logic        lt,
  output logic        ltu,
  output logic [31:0] PC,
  input  logic [31:0] Instr,
  output logic [31:0] ALUResult, WriteData,
  input  logic [31:0] ReadData
);
  logic [31:0] PCNext, PCPlus4, PCTarget, PCTarget_R;
  logic [31:0] ImmExt;
  logic [31:0] SrcA, SrcB;
  logic [31:0] Result;

  assign PCTarget_R = {ALUResult[31:1], 1'b0};

  flopr #(32) pcreg(clk, reset, PCNext, PC);
  adder pcadd4(PC, 32'd4, PCPlus4);
  adder pcaddbranch(PC, ImmExt, PCTarget);
  mux3  #(32) pcmux(PCPlus4, PCTarget, PCTarget_R, PCSrc, PCNext);

  regfile rf(clk, RegWrite, Instr[19:15], Instr[24:20],
             Instr[11:7], Result, SrcA, WriteData);

  extend ext(Instr, ImmSrc, ImmExt);

  mux2  #(32) srcbmux(WriteData, ImmExt, ALUSrc, SrcB);
  alu         alu_u(SrcA, SrcB, ALUControl, ALUResult, Zero, lt, ltu);

  always_comb
    unique case (ResultSrc)
      2'b00: Result = ALUResult;
      2'b01: Result = ReadData;
      2'b10: Result = PCPlus4;
      2'b11: Result = ImmExt;
      default: Result = ALUResult;
    endcase
endmodule


    
