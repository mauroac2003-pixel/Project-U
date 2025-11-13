`timescale 1ns/1ps

module dmem_tb;
  logic clk = 0;
  logic we;
  logic [31:0] a, wd, rd;

  dmem uut(.clk(clk), .we(we), .a(a), .wd(wd), .rd(rd));

  always #5 clk = ~clk;

  initial begin
    we = 1;
    a  = 32'h00000008;
    wd = 32'hCAFEBABE;
    @(posedge clk);

    we = 0;
    #1;
    assert(rd == 32'hCAFEBABE);

    $display("✅ dmem test passed.");
    $finish;
  end
endmodule
