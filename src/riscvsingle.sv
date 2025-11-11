`timescale 1ns/1ps

module riscvsingle(
  input  logic        clk, reset,
  output logic [31:0] PC,
  input  logic [31:0] Instr,
  output logic        MemWrite,
  output logic [31:0] ALUResult, WriteData,
  input  logic [31:0] ReadData
);
  logic        ALUSrc, RegWrite, Jump;
  logic [1:0]  PCSrc, ResultSrc;
  logic [2:0]  ImmSrc;
  logic [3:0]  ALUControl;
  logic        Zero, lt, ltu, cond;

  controller c(
    .op        (Instr[6:0]),
    .funct3    (Instr[14:12]),
    .funct7    (Instr[31:25]),
    .Zero      (Zero),
    .lt			(lt),
    .ltu		(ltu),
    .ResultSrc (ResultSrc),
    .MemWrite  (MemWrite),
    .PCSrc     (PCSrc),
    .ALUSrc    (ALUSrc),
    .RegWrite  (RegWrite),
    .Jump      (Jump),
    .ImmSrc    (ImmSrc),
    .ALUControl(ALUControl)
  );

  datapath dp(
    .clk       (clk),
    .reset     (reset),
    .ResultSrc (ResultSrc),
    .PCSrc     (PCSrc),
    .ALUSrc    (ALUSrc),
    .RegWrite  (RegWrite),
    .ImmSrc    (ImmSrc),
    .ALUControl(ALUControl),
    .Zero      (Zero),
    .lt        (lt),
    .ltu       (ltu),
    .PC        (PC),
    .Instr     (Instr),
    .ALUResult (ALUResult),
    .WriteData (WriteData),
    .ReadData  (ReadData)
  );

endmodule
