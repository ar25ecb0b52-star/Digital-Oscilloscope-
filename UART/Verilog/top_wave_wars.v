// =========================================================================
// Top-Level Module: top_wave_wars.v
// Integrated Stage 1 (DDS & Packet Controller) + Stage 2 (UART Transceiver)
// =========================================================================
`timescale 1ns / 1ps

module top_wave_wars (
    input  wire clk,         // 100 MHz System Clock
    input  wire rst,
    output wire tx_serial    // UART Transmit Line (115,200 Baud)
);

    wire [7:0] sig_a;
    wire [7:0] sig_b;
    wire [7:0] tx_byte;
    wire       tx_start;
    wire       tx_busy;

    // Stage 1A: DDS Signal Generator
    dds_generator u_dds (
        .clk(clk),
        .rst(rst),
        .sig_a(sig_a),
        .sig_b(sig_b)
    );

    // Stage 1B: 4-Byte Packet Framing Controller
    packet_controller u_pkt_ctrl (
        .clk(clk),
        .rst(rst),
        .sig_a(sig_a),
        .sig_b(sig_b),
        .tx_busy(tx_busy),
        .tx_byte(tx_byte),
        .tx_start(tx_start)
    );

    // Stage 2: UART Transceiver Top Module
    // Configured for 100 MHz clock / 115,200 baud -> CLKS_PER_BIT = 868
    uart_top #(
        .CLKS_PER_BIT(868)
    ) u_uart_tx (
        .clk(clk),
        .rst(rst),
        .tx_data(tx_byte),
        .tx_start(tx_start),
        .tx_out(tx_serial),
        .tx_done(tx_busy)
    );

endmodule