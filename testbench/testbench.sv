`timescale 1ns/1ps

module testbench;
  reg clk = 1'b0;
  reg reset = 1'b1;

  always #5 clk = ~clk;

  // Acceso al DUT
  top dut(.clk(clk), .reset(reset), .WriteData(), .DataAdr(), .MemWrite());

  localparam [31:0] FIN_CIFRADOR = 32'h000000BC;
  localparam [31:0] FIN_ORDENAMIENTO = 32'h00000100;

  reg [255:0] filename;
  initial begin
    if (!$value$plusargs("program=%s", filename)) begin
      $display("❌ ERROR: No se proporcionó +program");
      $finish;
    end
  end

  integer k;
  reg hit_fin = 1'b0;

  initial begin
    repeat (2) @(posedge clk);
    reset = 0;

    for (k = 0; k < 50000; k++) begin
      @(posedge clk);
      if ((filename == "testbench/riscvtest1.txt" && dut.PC == FIN_CIFRADOR) ||
          (filename == "testbench/riscvtest2.txt" && dut.PC == FIN_ORDENAMIENTO)) begin
        hit_fin = 1'b1;
        break;
      end
    end

    if (!hit_fin) begin
      $display("❌ FAIL: Timeout. PC = 0x%08h", dut.PC);
      $finish;
    end

    $display("✅ PC final: 0x%08h", dut.PC);
    $display("a0 (x10)   = 0x%08h", dut.rvsingle.dp.rf.rf[10]);
    $display("sp (x2)    = 0x%08h", dut.rvsingle.dp.rf.rf[2]);

    if (filename == "testbench/riscvtest1.txt") begin
      if (dut.rvsingle.dp.rf.rf[10] !== 32'h00fff05f)
        $fatal(1, "❌ FAIL: a0 (x10) esperado: 0x00fff05f");
      if (dut.rvsingle.dp.rf.rf[2] !== 32'h00100000)
        $fatal(1, "❌ FAIL: sp (x2) esperado: 0x00100000");
      $display("🎉 PASS: Programa Cifrado ejecutado correctamente.");
    end
    else if (filename == "testbench/riscvtest2.txt") begin
      $display("🎉 PASS: Programa Ordenamiento finalizó (validación específica opcional).");
    end

    $finish;
  end
endmodule
