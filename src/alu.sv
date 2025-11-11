`timescale 1ns/1ps

module alu(
  input  logic [31:0] A, B,
  input  logic [3:0]  ALUControl,
  output logic [31:0] ALUResult,
  output logic        Zero,
  output logic        lt,
  output logic        ltu
);
  logic [31:0] temp, Sum, Y;
  logic        slt_v, sltu_v;

  assign temp   = ALUControl[0] ? ~B : B;
  assign Sum    = A + temp + ALUControl[0];
  assign slt_v  = (A[31] == B[31]) ? (A < B) : A[31];
  assign sltu_v = (A < B);

  always_comb begin
    unique case (ALUControl)
      4'b0000: Y = Sum;               // ADD
      4'b0001: Y = Sum;               // SUB
      4'b0010: Y = A & B;             // AND
      4'b0011: Y = A | B;             // OR
      4'b0100: Y = A ^ B;             // XOR
      4'b0101: Y = {31'b0, slt_v};    // SLT
      4'b0110: Y = {31'b0, sltu_v};   // SLTU
      4'b1000: Y = A << B[4:0];       // SLL
      4'b1001: Y = A >> B[4:0];       // SRL
      4'b1010: Y = $signed(A) >>> B[4:0]; // SRA/SRAI
      default: Y = 32'h0000_0000;
    endcase
  end

  assign ALUResult = Y;
  assign Zero      = (Y == 32'd0);
  assign lt        = slt_v;
  assign ltu       = sltu_v;
endmodule
