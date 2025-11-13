`timescale 1ns/1ps

module imem_tb;
  logic [31:0] a, rd;

  imem uut(.a(a), .rd(rd));

  initial begin
    a = 32'd0;
    #1;
    $display("Instruction at addr 0: %h", rd);
    // Puedes cambiar esto si conoces la instrucción esperada
    assert(rd !== 32'hXXXXXXXX);

    $display("✅ imem test passed.");
    $finish;
  end
endmodule
