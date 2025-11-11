`timescale 1ns/1ps
module imem (
    input  logic [31:0] a,
    output logic [31:0] rd
);
    // Memoria de instrucciones: 256 palabras de 32 bits
    logic [31:0] RAM [0:255];

    // En simulación (ModelSim):
    //   Carga riscvtest.txt desde testbench/
`ifndef SYNTHESIS
    initial begin
        $display("[IMEM] Cargando desde 'testbench/riscvtest.txt'");
        $readmemh("testbench/riscvtest.txt", RAM);
    end
`else
    // En síntesis (Yosys):
    //   Llena toda la memoria con NOP (32'h00000013)
    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            RAM[i] = 32'h00000013;  // ADDI x0,x0,0
        end
    end
`endif

    // Lectura por dirección alineada: usa bits 9:2 → 256 posiciones (4 bytes por instrucción)
    assign rd = RAM[a[9:2]];
endmodule
