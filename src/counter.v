module counter #(
    parameter WIDTH = 8,
    parameter MAX_VALUE = 255
)(
    input wire clk,
    input wire rst,
    input wire en,
    output reg tc,          // terminal count
    output reg [WIDTH-1:0] count
);

// FSM states
localparam [1:0] RESET = 2'b00,
                 HOLD  = 2'b01,
                 RUN   = 2'b10;

reg [1:0] current_state, next_state;

// Initial block
initial begin
    current_state = RESET;
    next_state = RESET;
    count = {WIDTH{1'b0}};
    tc = 1'b0;
end

// Register counter and current_state
always @(posedge clk) begin
    if (rst) begin
        current_state <= RESET;
        count <= {WIDTH{1'b0}};  // more portable than '0
    end else begin
        current_state <= next_state;
        case (current_state)
            RESET: begin
                count <= {WIDTH{1'b0}};
            end
            HOLD: begin
                count <= count;
            end
            RUN: begin
                if (count == MAX_VALUE)
                    count <= {WIDTH{1'b0}};
                else
                    count <= count + 1;
            end
            default: count <= {WIDTH{1'b0}};
        endcase
    end
end

// Next state logic
always @(*) begin
    next_state = current_state;
    tc <= 1'b0;  // default value
    
    case (current_state)
        RESET: begin
            next_state <= (en) ? RUN : HOLD;
        end
        HOLD: begin
            if (en) next_state <= RUN;
        end
        RUN: begin
            if (!en)
                next_state <= HOLD;
            else if (count == MAX_VALUE)
                tc <= 1'b1;  // terminal pulse
        end
        default: next_state <= RESET;
    endcase
end

endmodule