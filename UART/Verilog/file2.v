`timescale 1ns / 1ps

module dds_generator (
    input  wire       clk,
    input  wire       rst,
    input  wire       sample_tick, // Triggers step update
    output wire [7:0] sig_a,      // Sine Wave (Reference)
    output reg  [7:0] sig_b       // Square/Sawtooth Wave
);

    reg [7:0] phase_acc;

    // Step size of 4 gives 64 samples per period
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            phase_acc <= 8'd0;
        end else if (sample_tick) begin
            phase_acc <= phase_acc + 8'd4;
        end
    end

    // Signal A: Read from Sine ROM
    sine_rom u_sine (
        .addr(phase_acc),
        .sine_out(sig_a)
    );

    // Signal B: Square Wave scaled between [0, 254]
    always @(*) begin
        if (phase_acc < 8'd128)
            sig_b = 8'd254; // HIGH level
        else
            sig_b = 8'd0;   // LOW level
    end

endmodule