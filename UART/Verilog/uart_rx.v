// ── MASTER CODER OUTPUT ──────────────────────────────────────────────
// Mode: Write | Module: uart_rx (Ashvanth, Wave-Wars UART core)
// Principles: SRP, robustness (synchronizer, glitch + framing checks)
// ─────────────────────────────────────────────────────────────────────
// 8N1 receiver, LSB first, samples every bit at its midpoint.
//   rx_valid     : 1-cycle pulse, rx_data holds a good byte (stop bit = 1)
//   rx_frame_err : 1-cycle pulse, stop bit was 0 (byte is discarded)
module uart_rx #(
    parameter CLKS_PER_BIT = 868
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       rx_in,         // asynchronous serial input
    output reg  [7:0] rx_data,
    output reg        rx_valid,
    output reg        rx_frame_err
);
    localparam IDLE  = 2'd0,
               START = 2'd1,
               DATA  = 2'd2,
               STOP  = 2'd3;

    // 2-flop synchronizer: the pin is asynchronous to clk (metastability).
    reg rx_s1, rx_s2;
    always @(posedge clk) begin
        rx_s1 <= rx_in;
        rx_s2 <= rx_s1;
    end

    reg [1:0] state;
    reg [7:0] shifter;
    reg [2:0] bit_idx;

    wire mid_tick;
    // Counter held at 0 in IDLE; after the falling edge it restarts, so
    // mid_tick lands in the middle of the start bit, then of every bit.
    baud_gen #(.DIVISOR(CLKS_PER_BIT)) u_baud (
        .clk(clk), .rst(rst), .clear(state == IDLE),
        .tick(), .mid_tick(mid_tick)
    );

    always @(posedge clk) begin
        rx_valid     <= 1'b0;          // default: pulses only
        rx_frame_err <= 1'b0;
        if (rst) begin
            state   <= IDLE;
            shifter <= 8'd0;
            bit_idx <= 3'd0;
            rx_data <= 8'd0;
        end else begin
            case (state)
                IDLE:  if (rx_s2 == 1'b0) state <= START;   // falling edge

                START: if (mid_tick) begin
                    if (rx_s2 == 1'b0) begin   // still low: real start bit
                        bit_idx <= 3'd0;
                        state   <= DATA;
                    end else
                        state <= IDLE;         // glitch, reject
                end

                DATA:  if (mid_tick) begin
                    shifter <= {rx_s2, shifter[7:1]};   // LSB arrives first
                    if (bit_idx == 3'd7)
                        state <= STOP;
                    else
                        bit_idx <= bit_idx + 3'd1;
                end

                STOP:  if (mid_tick) begin
                    if (rx_s2 == 1'b1) begin
                        rx_data  <= shifter;
                        rx_valid <= 1'b1;
                    end else
                        rx_frame_err <= 1'b1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
