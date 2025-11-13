`timescale 1ns/1ps

module imem (
  input  logic [31:0] a,
  output logic [31:0] rd
);
  logic [31:0] RAM [0:255];
  string filename;

`ifndef SYNTHESIS
  initial begin
    if (!$value$plusargs("program=%s", filename)) begin
      $display("ERROR: No se proporcionó argumento +program");
      $finish;
    end else begin
      $display("[IMEM] Cargando programa: %s", filename);
      $readmemh(filename, RAM);
    end
  end
`else
  integer i;
  initial begin
    for (i = 0; i < 256; i = i + 1)
      RAM[i] = 32'h00000013; // NOP
  end
`endif

  assign rd = RAM[a[9:2]];
endmodule
