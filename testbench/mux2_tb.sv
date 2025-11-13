`timescale 1ns/1ps
module mux2_tb;
  logic [31:0] d0, d1, y;
  logic s;

  mux2 #(32) uut(.d0(d0), .d1(d1), .s(s), .y(y));

  initial begin
    d0 = 32'hAAAA_AAAA;
    d1 = 32'h5555_5555;

    s = 0; #1;
    assert(y == d0);

    s = 1; #1;
    assert(y == d1);

    $display("✅ Mux2 test passed.");
    $finish;
  end
endmodule
