`timescale 1ns/1ps

module controller(
  input  logic [6:0] op,
  input  logic [2:0] funct3,
  input  logic [6:0] funct7,
  
  // Banderas de la ALU
  input  logic       Zero,
  input  logic 		 lt,
  input  logic 		 ltu,
  
  output logic [1:0] ResultSrc,
  output logic       MemWrite,
  output logic [1:0] PCSrc,
  output logic       ALUSrc,
  output logic       RegWrite, Jump,
  output logic [2:0] ImmSrc,
  output logic [3:0] ALUControl
);
  // Señales internas
  logic [1:0] ALUOp;
  logic       Branch;
  logic       is_jal, is_jalr;
  logic 	  cond;
  
  // Detecta el op 
  assign is_jal  = (op == 7'b1101111);
  assign is_jalr = (op == 7'b1100111);

  maindec md(op, ResultSrc, MemWrite, Branch, ALUSrc, RegWrite, Jump, ImmSrc, ALUOp);
  aludec  ad(op[5], funct3, funct7, ALUOp, ALUControl);

  // Logica para Branches 
   always_comb begin
    unique case (funct3)
      3'b000: cond =  Zero;  // BEQ
      3'b001: cond = ~Zero;  // BNE
      3'b100: cond =  lt;    // BLT
      3'b101: cond = ~lt;    // BGE
      3'b110: cond =  ltu;   // BLTU
      3'b111: cond = ~ltu;   // BGEU
      default: cond = 1'b0;
    endcase
  end
  
  // Seleccion del PC mediante PCSrc
  always_comb begin
    PCSrc = 2'b00;
    if      (is_jalr)       PCSrc = 2'b10;
    else if (is_jal)        PCSrc = 2'b01;
    else if (Branch & cond) PCSrc = 2'b01;
  end
endmodule
