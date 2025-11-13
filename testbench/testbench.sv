`timescale 1ns/1ps

module testbench;

  // Señales de reloj y reset
  reg clk = 0;
  reg reset = 1;
  always #5 clk = ~clk;  // Reloj con periodo de 10ns

  // Instancia del diseño top
  logic [31:0] WriteData, DataAdr;
  logic MemWrite;
  top dut(
    .clk(clk),
    .reset(reset),
    .WriteData(WriteData),
    .DataAdr(DataAdr),
    .MemWrite(MemWrite)
  );

  // Variables de control
  string filename;
  int k;
  bit hit_fin;

  // Dirección donde el programa finaliza (etiqueta "fin" = dirección PC)
  localparam [31:0] FIN_ADDR = 32'h00000158;

  initial begin
    // Obtener nombre del archivo de programa desde +program
    if (!$value$plusargs("program=%s", filename)) begin
      $display("❌ ERROR: No se proporcionó +program");
      $finish;
    end

    $display("📦 Cargando programa: %s", filename);

    // Ciclos iniciales con reset activado
    repeat (2) @(posedge clk);
    reset = 0;

    // Esperar a que el PC alcance la dirección de fin
    hit_fin = 0;
    for (k = 0; k < 50000; k = k + 1) begin
      @(posedge clk);
      if (dut.PC == FIN_ADDR) begin
        hit_fin = 1;
        break;
      end
    end

    if (!hit_fin) begin
      $display("❌ FAIL: Timeout — PC no alcanzó la dirección de fin (0x%08h)", FIN_ADDR);
      $finish;
    end

    // Mostrar resultados
    $display("🏁 PC final:   0x%08h", dut.PC);
    $display("🔎 a0 (x10)   = 0x%08h", dut.rvsingle.dp.rf.rf[10]);
    $display("📌 sp (x2)    = 0x%08h", dut.rvsingle.dp.rf.rf[2]);

    // Validaciones por programa
    if (filename == "testbench/riscvtest1.txt") begin
      // Test del cifrador factorial
      if (dut.rvsingle.dp.rf.rf[10] !== 32'h00fff05f) begin
        $display("❌ FAIL: Valor incorrecto en x10 (a0). Esperado 0x00fff05f");
        $finish;
      end
      if (dut.rvsingle.dp.rf.rf[2] !== 32'h000ffff4) begin
        $display("❌ FAIL: Stack pointer incorrecto (x2). Esperado 0x000ffff4");
        $finish;
      end
      $display("✅ PASS: Cifrado factorial correcto.");
    end

    else if (filename == "testbench/riscvtest2.txt") begin
      // Test del ordenamiento + búsqueda binaria
      if (dut.rvsingle.dp.rf.rf[10] !== 32'd3) begin
        $display("❌ FAIL: Índice incorrecto de búsqueda binaria. Esperado: 3, Obtenido: %0d", dut.rvsingle.dp.rf.rf[10]);
        $finish;
      end
      $display("✅ PASS: Ordenamiento + búsqueda binaria exitosos.");

      // Mostrar contenido del arreglo transformado (en memoria)
      $display("🧠 Estado del arreglo ordenado en memoria:");
      for (int i = 0; i < 6; i++) begin
        $display("  RAM[%0d] = 0x%08h", i, dut.rvsingle.dmem.RAM[256 + i]);
      end
    end

    else begin
      $display("⚠️  ADVERTENCIA: No hay validación definida para %s", filename);
    end

    $finish;
  end

endmodule
