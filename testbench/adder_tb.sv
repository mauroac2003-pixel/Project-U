`timescale 1ns/1ps
module adder_tb;
  logic [31:0] a, b, y;

  adder uut(.a(a), .b(b), .y(y));

  initial begin
    a = 32'h0000_0001;
    b = 32'h0000_0002;
    #1;
    $display("Adder: %h + %h = %h", a, b, y);
    assert(y == 32'h0000_0003) else $fatal("Adder failed");
    $finish;
  end
endmodule
