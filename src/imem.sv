`timescale 1ns/1ps
module imem(
  input  logic [31:0] a,
  output logic [31:0] rd
);
  logic [31:0] RAM[0:1023];

`ifndef SYNTHESIS
  // --- SIMULACIÓN: permite +IMEM=<archivo>
  string fname;
  initial begin
    // Si no se pasa +IMEM= por parámetro, se usa la ruta por defecto dentro de testbench/
    if (!$value$plusargs("IMEM=%s", fname)) fname = "testbench/riscvtest.txt";
    $display("[IMEM] Cargando desde '%0s'", fname);
    $readmemh(fname, RAM);
    // $display("[IMEM] RAM[0]=%h RAM[1]=%h RAM[2]=%h", RAM[0], RAM[1], RAM[2]);
  end
`else
  // --- SÍNTESIS: sin string/plusargs (ruta fija)
  initial begin
    $readmemh("testbench/riscvtest.txt", RAM, 0);
  end
`endif

  // 64 palabras -> usa 6 bits de índice (evita mega-mux en síntesis)
  assign rd = RAM[a[11:2]];

endmodule
