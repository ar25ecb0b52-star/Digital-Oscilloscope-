// ── MASTER CODER OUTPUT ──────────────────────────────────────────────
// Mode: Write | Module: uart_top (Ashvanth, Wave-Wars UART core)
// Principles: SRP (wiring only), single place to set clock/baud
// ─────────────────────────────────────────────────────────────────────
// Zikra instantiates this (or just uart_tx) from the packet controller.
module uart_top #(
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD     = 115_200
)(
    input  wire       clk,
    input  wire       rst,
    // TX side (from packet controller)
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    output wire       tx_busy,
    output wire       tx_done,
    output wire       uart_txd,
    // RX side
    input  wire       uart_rxd,
    output wire [7:0] rx_data,
    output wire       rx_valid,
    output wire       rx_frame_err
);
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD;   // 868 @ 100 MHz

    uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_tx (
        .clk(clk), .rst(rst),
        .tx_start(tx_start), .tx_data(tx_data),
        .tx_busy(tx_busy), .tx_done(tx_done), .tx_out(uart_txd)
    );

    uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_rx (
        .clk(clk), .rst(rst), .rx_in(uart_rxd),
        .rx_data(rx_data), .rx_valid(rx_valid), .rx_frame_err(rx_frame_err)
    );
endmodule
