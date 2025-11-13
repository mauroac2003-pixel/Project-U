`timescale 1ns/1ps
module extend_tb;
  logic [31:0] instr;
  logic [2:0] ImmSrc;
  logic [31:0] immext;

  extend uut(.instr(instr), .ImmSrc(ImmSrc), .immext(immext));

  initial begin
    // I-type immediate
    instr = 32'hFFF00093; // ADDI x1, x0, -1
    ImmSrc = 3'b000; #1;
    assert(immext == 32'hFFFF_FFFF);

    // U-type
    instr = 32'h00100037; // LUI x0, 0x00100
    ImmSrc = 3'b100; #1;
    assert(immext == 32'h00100000);

    $display("✅ Extend test passed.");
    $finish;
  end
endmodule
