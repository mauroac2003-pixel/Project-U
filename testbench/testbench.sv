`timescale 1ns/1ps

module testbench;
  // Reloj y reset
  reg clk   = 1'b0;
  reg reset = 1'b1;
  always #5 clk = ~clk;

  // Instancia del TOP
  // (coincide con tu design.sv: module top(...))
  top dut (.clk(clk), .reset(reset), .WriteData(), .DataAdr(), .MemWrite());

  // Dirección de la etiqueta <fin> (de tu listing)
  localparam [31:0] FIN_ADDR = 32'h000000BC;

  integer k;
  reg hit_fin = 1'b0;  // flag en lugar de 'break'

  initial begin
    // Reset corto
    repeat (2) @(posedge clk);
    reset = 1'b0;

    // Espera a que PC alcance <fin> con timeout
    for (k = 0; k < 50000; k = k + 1) begin
      @(posedge clk);
      if (dut.PC === FIN_ADDR)
        hit_fin = 1'b1;
    end

    if (!hit_fin) begin
      $display("FAIL: Timeout. PC=0x%08h no llegó a <fin> (0x%08h)", dut.PC, FIN_ADDR);
      $finish;
    end

    // --- Checks: a0 = x10 = 0x00fff05f; sp = x2 = 0x00100000 ---
    $display("PC         = 0x%08h", dut.PC);
    $display("a0 (x10)   = 0x%08h", dut.rvsingle.dp.rf.rf[10]);
    $display("sp (x2)    = 0x%08h", dut.rvsingle.dp.rf.rf[2]);
    
    if (dut.rvsingle.dp.rf.rf[10] !== 32'h00fff05f) begin
      $display("FAIL: a0(x10)=0x%08h != 0x00fff05f", dut.rvsingle.dp.rf.rf[10]);
      $finish;
    end

    if (dut.rvsingle.dp.rf.rf[2] !== 32'h00100000) begin
      $display("FAIL: sp(x2)=0x%08h != 0x00100000", dut.rvsingle.dp.rf.rf[2]);
      $finish;
    end

    $display("PASS: Cifrado ejecutado correctamente.");
    $finish;
  end
endmodule
