`timescale 1ns/1ps
module flopr_tb;
  logic clk = 0, reset = 0;
  logic [31:0] d, q;

  flopr #(32) uut(.clk(clk), .reset(reset), .d(d), .q(q));

  always #5 clk = ~clk;

  initial begin
    d = 32'hABCD_EF01;
    @(posedge clk);
    reset = 1;
    @(posedge clk);
    reset = 0;
    d = 32'h1234_5678;
    @(posedge clk);
    assert(q == 32'h1234_5678);
    $display("✅ flopr test passed.");
    $finish;
  end
endmodule
