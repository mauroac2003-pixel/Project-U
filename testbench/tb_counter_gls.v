`timescale 1ns/1fs

module tb_counter_gls;

localparam WIDTH = 8;
localparam MAX_VALUE = 9;

reg clk;
reg rst;
reg en;
wire tc;
wire [WIDTH-1:0] count;

// Instantiate DUT (from synthesized netlist)
// Netlist keeps the same module name: counter
counter dut (
    .clk(clk),
    .rst(rst),
    .en(en),
    .tc(tc),
    .count(count)
);

// Clock generator
initial begin
    clk = 0;
    forever #5 clk = ~clk; // 10 ns period
end

// Stimulus sequence (same as RTL for consistency)
initial begin
    rst = 1; en = 0;
    #20; rst = 0;
    
    #30;
    
    en = 1;
    #100;
    
    #(MAX_VALUE*10+20);
    
    en = 0;
    #40;
    
    en = 1;
    #40; rst = 1;
    #20; rst = 0;
    
    #100 $finish;
end

// Monitor
initial begin
    $monitor("t=%0t | clk=%b rst=%b en=%b count=%0d tc=%b",
             $time, clk, rst, en, count, tc);
end

// VCD
initial begin
    $dumpfile("dump_gls.vcd");
    $dumpvars(0, tb_counter_gls);
end

endmodule
