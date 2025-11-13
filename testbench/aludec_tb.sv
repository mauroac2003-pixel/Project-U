`timescale 1ns/1ps

module aludec_tb;
  logic        opb5;
  logic [2:0]  funct3;
  logic [6:0]  funct7;
  logic [1:0]  ALUOp;
  logic [3:0]  ALUControl;

  aludec uut(
    .opb5(opb5), .funct3(funct3), .funct7(funct7),
    .ALUOp(ALUOp), .ALUControl(ALUControl)
  );

  initial begin
    // R-type ADD (funct7 = 0)
    ALUOp = 2'b10; funct3 = 3'b000; funct7 = 7'b0000000; opb5 = 1'b1;
    #1;
    assert(ALUControl == 4'b0000);

    // R-type SUB (funct7 = 0b0100000)
    ALUOp = 2'b10; funct3 = 3'b000; funct7 = 7'b0100000; opb5 = 1'b1;
    #1;
    assert(ALUControl == 4'b0001);

    // R-type OR
    ALUOp = 2'b10; funct3 = 3'b110;
    #1;
    assert(ALUControl == 4'b0011);

    $display("✅ aludec test passed.");
    $finish;
  end
endmodule
