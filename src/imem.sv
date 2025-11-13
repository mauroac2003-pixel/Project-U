`timescale 1ns/1ps

module imem (
  input  logic [31:0] a,
  output logic [31:0] rd
);

  logic [31:0] RAM [0:255];  // 1 KB de memoria (256 palabras de 32 bits)
  string filename;

`ifndef SYNTHESIS
  initial begin
    if (!$value$plusargs("program=%s", filename)) begin
      $display("❌ ERROR: No se proporcionó argumento +program=<archivo>");
      $finish;
    end else begin
      $display("📦 [IMEM] Cargando programa: %s", filename);
      $readmemh(filename, RAM);
      
      // Debug: Mostrar las primeras instrucciones cargadas
      $display("🔍 [IMEM] Instrucciones iniciales cargadas:");
      for (int i = 0; i < 8; i++) begin
        $display("  RAM[%0d] = 0x%08h", i, RAM[i]);
      end
    end
  end
`else
  // En modo de síntesis o FPGA: llenar memoria con NOPs (0x13)
  integer i;
  initial begin
    for (i = 0; i < 256; i = i + 1)
      RAM[i] = 32'h00000013; // NOP
  end
`endif

  // Lógica de lectura: dirección se alinea a palabra de 32 bits
  assign rd = RAM[a[9:2]];

endmodule
