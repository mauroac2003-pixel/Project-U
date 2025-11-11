// -----------------------------------------------------------
// Instruction Memory (IMEM)
// -----------------------------------------------------------
module imem (
    input  logic [31:0] a,
    output logic [31:0] rd
);
    // Memoria de instrucciones: 256 palabras de 32 bits
    logic [31:0] RAM [0:255];

`ifndef SYNTHESIS
    // --- Solo en simulación ---
    initial begin
        $display("[IMEM] Cargando desde 'testbench/riscvtest.txt'");
        $readmemh("testbench/riscvtest.txt", RAM);
    end
`else
    // --- En síntesis (Yosys) ---
    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            // Cargar NOP: 32'h00000013 (addi x0,x0,0)
            RAM[i] = 32'h00000013;
        end
    end
`endif

    // Lectura síncrona por dirección alineada
    assign rd = RAM[a[9:2]];  // usa bits 9:2 -> 256 posiciones (4 bytes por instrucción)
endmodule
