`timescale 1ns/1ps

module testbench;
  // Reloj y reset
  reg clk   = 1'b0;
  reg reset = 1'b1;
  always #5 clk = ~clk;

  // Instancia del TOP
  top dut (.clk(clk), .reset(reset), .WriteData(), .DataAdr(), .MemWrite());

  // Dirección de finalización común
  localparam [31:0] FIN_ADDR = 32'h000000BC;

  // Nombre del programa cargado
  string filename;

  initial begin
    // Obtener el archivo cargado desde +program=
    if (!$value$plusargs("program=%s", filename)) begin
      $display("❌ ERROR: No se proporcionó +program");
      $finish;
    end

    $display("📦 Testbench cargando programa: %s", filename);

    // Reset corto
    repeat (2) @(posedge clk);
    reset = 1'b0;

    // Espera hasta alcanzar la dirección de fin
    int k;
    bit hit_fin = 1'b0;
    for (k = 0; k < 50000; k = k + 1) begin
      @(posedge clk);
      if (dut.PC === FIN_ADDR) begin
        hit_fin = 1'b1;
        disable wait_loop;
      end
    end

  wait_loop: assert (hit_fin)
    else begin
      $display("❌ FAIL: Timeout. PC no llegó a la dirección <fin> (0x%08h)", FIN_ADDR);
      $finish;
    end

    // Validaciones específicas
    $display("PC final: 0x%08h", dut.PC);
    $display("a0 (x10)   = 0x%08h", dut.rvsingle.dp.rf.rf[10]);
    $display("sp (x2)    = 0x%08h", dut.rvsingle.dp.rf.rf[2]);

    if (filename == "testbench/riscvtest1.txt") begin
      // === Validación: Cifrado factorial ===
      if (dut.rvsingle.dp.rf.rf[10] !== 32'h00fff05f) begin
        $display("❌ FAIL: a0(x10)=0x%08h != 0x00fff05f", dut.rvsingle.dp.rf.rf[10]);
        $finish;
      end
      if (dut.rvsingle.dp.rf.rf[2] !== 32'h00100000) begin
        $display("❌ FAIL: sp(x2)=0x%08h != 0x00100000", dut.rvsingle.dp.rf.rf[2]);
        $finish;
      end
      $display("✅ PASS: Cifrado factorial ejecutado correctamente.");
    end

    else if (filename == "testbench/riscvtest2.txt") begin
      // === Validación: Ordenamiento + Transformación + Búsqueda ===
      if (dut.PC !== FIN_ADDR) begin
        $display("❌ FAIL: PC final incorrecto para ordenamiento");
      end

      if (dut.rvsingle.dp.rf.rf[10] !== 32'd3) begin
        $display("❌ FAIL: Índice de búsqueda binaria incorrecto. Esperado: 3, Obtenido: %0d", dut.rvsingle.dp.rf.rf[10]);
        $finish;
      end else begin
        $display("✅ PASS: Programa Ordenamiento finalizó correctamente.");
      end

      // Imprimir memoria transformada (opcional)
      $display("🧠 Arreglo modificado en memoria (base = 0x00400000):");
      for (int i = 0; i < 6; i++) begin
        $display("mem[%0d] = 0x%08h", i, dut.rvsingle.dp.dmem.RAM[256 + i]);
      end
    end

    else begin
      $display("⚠️  ADVERTENCIA: No hay validación definida para %s", filename);
    end

    $finish;
  end
endmodule
