`default_nettype none

module my_chip (
    input logic [11:0] io_in, // Inputs to your chip
    output logic [11:0] io_out, // Outputs from your chip
    input logic clock,
    input logic reset // Important: Reset is ACTIVE-HIGH
);
    
    // Basic counter design as an example
    // TODO: remove the counter design and use this module to insert your own design
    // DO NOT change the I/O header of this design

    RangeFinder #(9) find(.clock(clock), .reset(reset), 
                    .go(io_in[1]), .finish(io_in[2]),
                    .data_in(io_in[11:3]), .range(io_out[11:2]),
                    .debug_error(io_out[1]));
endmodule


module RangeFinder
    #(parameter WIDTH=16)
    (input logic [WIDTH-1:0] data_in,
    input logic clock, reset,
    input logic go, finish,
    output logic [WIDTH-1:0] range,
    output logic debug_error);

    logic g_ld, l_ld;
    logic [WIDTH-1:0] greatest, least;

    always_ff @(posedge clock, posedge reset) begin
        if (reset) begin
            greatest <= 0;
        end
        else if (g_ld) begin
            greatest <= data_in;
        end
    end

    always_ff @(posedge clock, posedge reset) begin
        if (reset) begin
            least <= 0;
        end
        else if (l_ld) begin
            least <= data_in;
        end
    end

    // Next State and Output Logic
    enum logic {WAIT, FIND} state, nextState;

    always_comb begin
        g_ld = 0;
        l_ld = 0;
        range = 0;
        debug_error = 0;
        nextState = WAIT;

        case (state)
            WAIT: begin
                if ((go && finish) || (finish)) begin
                    nextState = WAIT;
                    debug_error = 1;
                end
                else if (go && ~finish) begin
                    nextState = FIND;

                    g_ld = 1;
                    l_ld = 1;
                    debug_error = 0;
                end
                else if (~go) begin
                    nextState = WAIT;
                end
            end

            FIND: begin
                if ((~finish) && (data_in > greatest)) begin
                    nextState = FIND;
                    g_ld = 1;
                end
                else if ((~finish) && (data_in < least)) begin
                    nextState = FIND;
                    l_ld = 1;
                end
                else if (finish) begin
                    nextState = WAIT;
                    range = greatest - least;
                end
                else begin
                    nextState = FIND;
                end
            end
        endcase
    end

    always_ff @(posedge clock, posedge reset) begin
        if (reset) begin
            state <= WAIT;
        end
        else begin
            state <= nextState;
        end
    end

endmodule: RangeFinder
