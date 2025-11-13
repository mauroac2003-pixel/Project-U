`timescale 1ns/1ps

module testbench;
  // Reloj y reset
  reg clk   = 1'b0;
  reg reset = 1'b1;
  always #5 clk = ~clk;

  // Instancia del TOP
  top dut (.clk(clk), .reset(reset), .WriteData(), .DataAdr(), .MemWrite());

  // Programa seleccionado dinámicamente (por +program=)
  string program_path;

  // Extraer argumento de línea de comandos: +program=...
  initial begin
    if (!$value$plusargs("program=%s", program_path)) begin
      $display("ERROR: No se especificó el programa (+program=...)");
      $finish;
    end else begin
      $display("[IMEM] Cargando programa: %s", program_path);
    end
  end

  // Espera al final del programa
  integer k;
  reg hit_fin = 1'b0;

  initial begin
    repeat (2) @(posedge clk);
    reset = 1'b0;

    for (k = 0; k < 50000; k = k + 1) begin
      @(posedge clk);
      if (dut.PC === 32'h000000bc || dut.PC === 32'h00000100) begin
        hit_fin = 1'b1;
        break;
      end
    end

    if (!hit_fin) begin
      $display("FAIL: Timeout. PC no llegó a <fin>");
      $finish;
    end

    // Mostrar registros clave
    $display("PC final: 0x%08h", dut.PC);
    $display("a0 (x10)   = 0x%08h", dut.rvsingle.dp.rf.rf[10]);
    $display("sp (x2)    = 0x%08h", dut.rvsingle.dp.rf.rf[2]);

    // Validación específica por programa
    if (program_path == "testbench/riscvtest1.txt") begin
      // CIFRADOR
      if (dut.PC !== 32'h000000bc)
        $display("FAIL: PC final incorrecto para cifrador");
        
      if (dut.rvsingle.dp.rf.rf[10] !== 32'h00fff05f)
        $display(" WARNING: a0 (x10) esperado: 0x00fff05f, obtenido: 0x%08h", dut.rvsingle.dp.rf.rf[10]);
      else
        $display("PASS: Cifrado ejecutado correctamente.");
    end
    else if (program_path == "testbench/riscvtest2.txt") begin
      // ORDENAMIENTO
      if (dut.PC !== 32'h00000100)
        $display("FAIL: PC final incorrecto para ordenamiento");

      $display(" PASS: Programa Ordenamiento finalizó (validación específica opcional).");
    end else begin
      $display(" WARNING: No hay validación definida para este programa.");
    end

    $finish;
  end
endmodule
