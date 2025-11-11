`timescale 1ns/1ps

module maindec(
  input  logic [6:0] op,
  output logic [1:0] ResultSrc, 
  output logic       MemWrite,
  output logic       Branch, ALUSrc,
  output logic       RegWrite, Jump,
  output logic [2:0] ImmSrc,
  output logic [1:0] ALUOp
);
  // RegWrite | ImmSrc(3) | ALUSrc | MemWrite | ResultSrc(2) | Branch | ALUOp(2) | Jump
  logic [12:0] controls;
  assign {RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, Branch, ALUOp, Jump} = controls;

  always_comb
    case (op)
      7'b0000011: controls = 13'b1_000_1_0_01_0_00_0; // LW
      7'b0100011: controls = 13'b0_001_1_1_00_0_00_0; // SW
      7'b0110011: controls = 13'b1_000_0_0_00_0_10_0; // R-type
      7'b1100011: controls = 13'b0_010_0_0_00_1_01_0; // Branch
      7'b0010011: controls = 13'b1_000_1_0_00_0_10_0; // I-ALU
      7'b1101111: controls = 13'b1_011_0_0_10_0_00_1; // JAL
      7'b1100111: controls = 13'b1_000_1_0_10_0_00_1; // JALR
      7'b0110111: controls = 13'b1_100_0_0_11_0_00_0; // LUI
      default:    controls = 13'b0_000_0_0_00_0_00_0;
    endcase
endmodule
