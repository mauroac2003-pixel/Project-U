`timescale 1ns/1ps

module maindec_tb;
  logic [6:0] op;
  logic [1:0] ResultSrc;
  logic       MemWrite, Branch, ALUSrc, RegWrite, Jump;
  logic [2:0] ImmSrc;
  logic [1:0] ALUOp;

  maindec uut(
    .op(op), .ResultSrc(ResultSrc), .MemWrite(MemWrite),
    .Branch(Branch), .ALUSrc(ALUSrc),
    .RegWrite(RegWrite), .Jump(Jump),
    .ImmSrc(ImmSrc), .ALUOp(ALUOp)
  );

  initial begin
    // LW
    op = 7'b0000011; #1;
    assert(RegWrite == 1 && ALUSrc == 1 && ResultSrc == 2'b01);

    // SW
    op = 7'b0100011; #1;
    assert(MemWrite == 1 && ALUSrc == 1);

    // R-type
    op = 7'b0110011; #1;
    assert(RegWrite == 1 && ALUSrc == 0 && ALUOp == 2'b10);

    // BEQ
    op = 7'b1100011; #1;
    assert(Branch == 1);

    $display("✅ maindec test passed.");
    $finish;
  end
endmodule
