`timescale 1ns/1ps

module aludec(
  input  logic       opb5,
  input  logic [2:0] funct3,
  input  logic [6:0] funct7,
  input  logic [1:0] ALUOp,
  output logic [3:0] ALUControl
);
  logic RtypeSub;
  assign RtypeSub = funct7 & opb5;

  always_comb
    case (ALUOp)
      2'b00: ALUControl = 4'b0000; // ADD
      2'b01: ALUControl = 4'b0001; // SUB
      default: begin
        case (funct3)
          3'b000: ALUControl = RtypeSub ? 4'b0001 : 4'b0000; // SUB / ADD
          3'b010: ALUControl = 4'b0101; // SLT
          3'b011: ALUControl = 4'b0110; // SLTU
          3'b110: ALUControl = 4'b0011; // OR
          3'b111: ALUControl = 4'b0010; // AND
          3'b100: ALUControl = 4'b0100; // XOR
          3'b001: ALUControl = 4'b1000; // SLL, SLLI
          3'b101: ALUControl =(funct7) ? 4'b1010 : 4'b1001; // 1=SRA, 0=SRL
          default:ALUControl = 4'b0000;
        endcase
      end
    endcase
endmodule
