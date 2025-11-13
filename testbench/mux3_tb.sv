`timescale 1ns/1ps
module mux3_tb;
  logic [31:0] d0, d1, d2, y;
  logic [1:0] s;

  mux3 #(32) uut(.d0(d0), .d1(d1), .d2(d2), .s(s), .y(y));

  initial begin
    d0 = 32'h1111_1111;
    d1 = 32'h2222_2222;
    d2 = 32'h3333_3333;

    s = 2'b00; #1; assert(y == d0);
    s = 2'b01; #1; assert(y == d1);
    s = 2'b10; #1; assert(y == d2);

    $display("✅ Mux3 test passed.");
    $finish;
  end
endmodule
