`timescale 1ns/1ps
module regfile_tb;
  logic clk = 0;
  always #5 clk = ~clk;

  logic we3;
  logic [4:0] a1, a2, a3;
  logic [31:0] wd3, rd1, rd2;

  regfile uut(.clk(clk), .we3(we3), .a1(a1), .a2(a2), .a3(a3), .wd3(wd3), .rd1(rd1), .rd2(rd2));

  initial begin
    we3 = 1; a3 = 5'd10; wd3 = 32'h12345678;
    @(posedge clk);  // write on posedge

    we3 = 0; a1 = 5'd10; a2 = 5'd0;
    #1;
    assert(rd1 == 32'h12345678);
    assert(rd2 == 32'd0);  // x0 is always zero

    $display("✅ Regfile test passed.");
    $finish;
  end
endmodule
