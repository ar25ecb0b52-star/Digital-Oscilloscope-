`timescale 1ns / 1ps

module top_wave_wars (
    input  wire clk,
    input  wire rst,
    output wire tx_serial
);

    wire [7:0] sig_a;
    wire [7:0] sig_b;
    wire [7:0] tx_data;
    wire       tx_start;
    wire       tx_busy;
    wire       sample_tick;

    // DDS Waveform Synthesizer
    dds_generator u_dds (
        .clk(clk),
        .rst(rst),
        .sample_tick(sample_tick),
        .sig_a(sig_a),
        .sig_b(sig_b)
    );

    // Packet Controller
    packet_controller u_pkt (
        .clk(clk),
        .rst(rst),
        .sig_a(sig_a),
        .sig_b(sig_b),
        .tx_busy(tx_busy),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .sample_tick(sample_tick)
    );

    // Ashvanth's UART TX Core Integration
    uart_tx #(
        .CLKS_PER_BIT(868) // 100 MHz / 115,200 Baud = 868 cycles/bit
    ) u_uart_tx (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_byte(tx_data),
        .tx_serial(tx_serial),
        .tx_busy(tx_busy)
    );

endmodule