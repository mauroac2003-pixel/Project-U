`timescale 1ns/1ps

module tb_counter_rtl;

localparam WIDTH = 8;
localparam MAX_VALUE = 9;

reg clk;
reg rst;
reg en;
wire tc;
wire [WIDTH-1:0] count;

// Function to print the state in text
function [55:0] state_name;  // 7 characters * 8 bits = 56 bits
    input [1:0] s;
    begin
        case (s)
            0: state_name = "RESET ";
            1: state_name = "HOLD  ";
            2: state_name = "RUN   ";
            default: state_name = "UNKNOWN";
        endcase
    end
endfunction

reg [55:0] current_state_str;

always @(*) begin
    current_state_str = state_name(dut.current_state);
end

counter #(
    .WIDTH(WIDTH),
    .MAX_VALUE(MAX_VALUE)
) dut (
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

// Stimulus sequence
initial begin
    // Scenario 1: RESET
    rst = 1; en = 0;
    #20; rst = 0;
    
    // Scenario 2: HOLD
    #30;
    
    // Scenario 3: RUN
    en = 1;
    #100;
    
    // Scenario 4: TERMINAL COUNT
    #(MAX_VALUE*10+20);
    
    // Scenario 5: HOLD after counting
    en = 0;
    #40;
    
    // Scenario 6: RESET while running
    en = 1;
    #40; rst = 1;
    #20; rst = 0;
    
    #100 $finish;
end

// Monitor signals
initial begin
    $monitor("t=%0t | clk=%b rst=%b en=%b count=%0d tc=%b state=%s",
            $time, clk, rst, en, count, tc, current_state_str);
end

// VCD
initial begin
    $dumpfile("dump_rtl.vcd");
    $dumpvars(0, tb_counter_rtl);
end

endmodule
