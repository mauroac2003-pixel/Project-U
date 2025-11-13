`timescale 1ns/1ps

module controller_tb;
  logic [6:0] op, funct7;
  logic [2:0] funct3;
  logic Zero, lt, ltu;
  logic [1:0] ResultSrc, PCSrc;
  logic       MemWrite, ALUSrc, RegWrite, Jump;
  logic [2:0] ImmSrc;
  logic [3:0] ALUControl;

  controller uut(
    .op(op), .funct3(funct3), .funct7(funct7),
    .Zero(Zero), .lt(lt), .ltu(ltu),
    .ResultSrc(ResultSrc), .MemWrite(MemWrite),
    .PCSrc(PCSrc), .ALUSrc(ALUSrc),
    .RegWrite(RegWrite), .Jump(Jump),
    .ImmSrc(ImmSrc), .ALUControl(ALUControl)
  );

  initial begin
    op = 7'b0110011; // R-type
    funct3 = 3'b000; funct7 = 7'b0000000;
    Zero = 0; lt = 0; ltu = 0;
    #1;
    assert(ALUControl == 4'b0000);
    assert(RegWrite == 1);

    op = 7'b1100011; // BEQ
    funct3 = 3'b000; Zero = 1;
    #1;
    assert(PCSrc == 2'b01); // Taken

    $display("✅ controller test passed.");
    $finish;
  end
endmodule
