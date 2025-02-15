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
