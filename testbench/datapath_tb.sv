`timescale 1ns/1ps

module datapath_tb;
  logic clk = 0, reset = 1;
  logic [1:0] ResultSrc = 0, PCSrc = 0;
  logic ALUSrc = 0, RegWrite = 1;
  logic [2:0] ImmSrc = 3'b000;
  logic [3:0] ALUControl = 4'b0000;
  logic Zero, lt, ltu;
  logic [31:0] PC, Instr, ALUResult, WriteData;
  logic [31:0] ReadData = 32'd0;

  // Una instrucción de prueba: ADDI x1, x0, 5
  assign Instr = 32'h00500093;

  datapath uut(
    .clk(clk), .reset(reset), .ResultSrc(ResultSrc), .PCSrc(PCSrc),
    .ALUSrc(ALUSrc), .RegWrite(RegWrite), .ImmSrc(ImmSrc),
    .ALUControl(ALUControl), .Zero(Zero), .lt(lt), .ltu(ltu),
    .PC(PC), .Instr(Instr), .ALUResult(ALUResult),
    .WriteData(WriteData), .ReadData(ReadData)
  );

  always #5 clk = ~clk;

  initial begin
    #10 reset = 0;
    #50;

    $display("✅ datapath ran. ALUResult=%h", ALUResult);
    $finish;
  end
endmodule
