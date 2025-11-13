`timescale 1ns/1ps
module alu_tb;
  logic [31:0] A, B, ALUResult;
  logic [3:0] ALUControl;
  logic Zero, lt, ltu;

  alu uut(.A(A), .B(B), .ALUControl(ALUControl), .ALUResult(ALUResult), .Zero(Zero), .lt(lt), .ltu(ltu));

  initial begin
    A = 32'd10;
    B = 32'd5;
    
    ALUControl = 4'b0000; #1; // ADD
    $display("ADD Result: %0d", ALUResult);
    assert(ALUResult == 15);

    ALUControl = 4'b0001; #1; // SUB
    assert(ALUResult == 5);

    ALUControl = 4'b0010; #1; // AND
    assert(ALUResult == (A & B));

    ALUControl = 4'b0011; #1; // OR
    assert(ALUResult == (A | B));

    ALUControl = 4'b0100; #1; // XOR
    assert(ALUResult == (A ^ B));

    $display("✅ ALU test passed.");
    $finish;
  end
endmodule
