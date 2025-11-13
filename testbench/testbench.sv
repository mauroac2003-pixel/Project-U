`timescale 1ns/1ps

module testbench;

  // Reloj y reset
  logic clk = 0;
  logic reset = 1;

  // Generación del reloj: 10ns por ciclo (100 MHz)
  always #5 clk = ~clk;

  // Instancia del DUT (top)
  logic [31:0] WriteData, DataAdr;
  logic MemWrite;

  top dut(
    .clk(clk),
    .reset(reset),
    .WriteData(WriteData),
    .DataAdr(DataAdr),
    .MemWrite(MemWrite)
  );

  // Parámetros y variables
  string filename;
  int k;
  bit hit_fin;

  // Dirección de finalización (última instrucción ejecutada)
  localparam [31:0] FIN_ADDR = 32'h000000bc;

  initial begin
    // Obtener argumento +program desde la línea de comandos
    if (!$value$plusargs("program=%s", filename)) begin
      $display("❌ ERROR: No se proporcionó +program=<archivo>");
      $finish;
    end

    $display("📦 Cargando programa: %s", filename);

    // Liberar el reset luego de dos ciclos
    repeat (2) @(posedge clk);
    reset = 0;

    // Esperar a que PC alcance la dirección de fin
    hit_fin = 0;
    for (k = 0; k < 50000; k = k + 1) begin
      @(posedge clk);
      if (dut.rvsingle.PC == FIN_ADDR) begin
        hit_fin = 1;
        break;
      end
    end

    // Verificar si se alcanzó la dirección de fin
    if (!hit_fin) begin
      $display("❌ FAIL: Timeout — PC no alcanzó dirección de fin (0x%08h)", FIN_ADDR);
      $finish;
    end

    // Mostrar resultados
    $display("========================================");
    $display("✅ Finalización detectada en PC = 0x%08h", dut.rvsingle.PC);
    $display("🧪 Registro x10 (a0) = 0x%08h", dut.rvsingle.dp.rf.rf[10]);
    $display("🧪 Registro x2  (sp) = 0x%08h", dut.rvsingle.dp.rf.rf[2]);
    $display("========================================");

    // Validaciones según archivo cargado
    if (filename == "testbench/riscvtest1.txt") begin
      if (dut.rvsingle.dp.rf.rf[10] !== 32'h00fff05f) begin
        $display("❌ FAIL: Valor incorrecto en x10 (a0). Esperado: 0x00fff05f");
        $finish;
      end
      if (dut.rvsingle.dp.rf.rf[2] !== 32'h00100000) begin
        $display("❌ FAIL: Valor incorrecto en x2 (sp). Esperado: 0x00100000");
        $finish;
      end
      $display("✅ PASS: Cifrado factorial correcto.");
    end

    else if (filename == "testbench/riscvtest2.txt") begin
      if (dut.rvsingle.dp.rf.rf[10] !== 32'd3) begin
        $display("❌ FAIL: Índice incorrecto de búsqueda binaria. Esperado: 3, Obtenido: %0d", dut.rvsingle.dp.rf.rf[10]);
        $finish;
      end
      $display("✅ PASS: Ordenamiento + búsqueda binaria correctos.");

      // Mostrar memoria (opcional)
      $display("🧠 Estado del arreglo ordenado en memoria:");
      for (int i = 0; i < 6; i++) begin
        $display("  RAM[%0d] = 0x%08h", i, dut.rvsingle.dp.dmem.RAM[256 + i]);
      end
    end

    else begin
      $display("⚠️  ADVERTENCIA: No hay validaciones definidas para %s", filename);
    end

    $finish;
  end

endmodule
