`timescale 1ns/1ps

`include "riscvsingle.sv"
`include "imem.sv"
`include "dmem.sv"
`include "controller.sv"
`include "maindec.sv"
`include "aludec.sv"
`include "datapath.sv"
`include "alu.sv"
`include "regfile.sv"
`include "extend.sv"
`include "flopr.sv"
`include "adder.sv"
`include "mux2.sv"
`include "mux3.sv"

module top(
  input  logic        clk, reset,
  output logic [31:0] WriteData, DataAdr,
  output logic        MemWrite
);
  logic [31:0] PC, Instr, ReadData;

  riscvsingle rvsingle(
    .clk(clk), .reset(reset),
    .PC(PC), .Instr(Instr),
    .MemWrite(MemWrite),
    .ALUResult(DataAdr), .WriteData(WriteData),
    .ReadData(ReadData)
  );

  imem imem(.a(PC), .rd(Instr));
  dmem dmem(.clk(clk), .we(MemWrite), .a(DataAdr), .wd(WriteData), .rd(ReadData));
endmodule
