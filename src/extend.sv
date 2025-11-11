`timescale 1ns/1ps

module extend(
  input  logic [31:0] instr,
  input  logic [2:0]  ImmSrc,   // 000:I, 001:S, 010:B, 011:J, 100:U
  output logic [31:0] immext
);
 
  logic [31:0] immI, immS, immB, immJ, immU;

  assign immI = {{20{instr[31]}}, instr[31:20]};                                   // I
  assign immS = {{20{instr[31]}}, instr[31:25], instr[11:7]};                      // S
  assign immB = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}; // B
  assign immJ = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0}; // J
  assign immU = {instr[31:12], 12'b0};                                             // U

  
  always @* begin
    unique case (ImmSrc)
      3'b000: immext = immI;
      3'b001: immext = immS;
      3'b010: immext = immB;
      3'b011: immext = immJ;
      3'b100: immext = immU;
      default: immext = 32'b0;
    endcase
  end
endmodule
