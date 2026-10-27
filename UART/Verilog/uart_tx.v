// ── MASTER CODER OUTPUT ──────────────────────────────────────────────
// Mode: Write | Module: uart_tx (Ashvanth, Wave-Wars UART core)
// Principles: SRP, KISS (4-state FSM), testability (clear handshake)
// ─────────────────────────────────────────────────────────────────────
// 8N1 transmitter, LSB first.
// Handshake: pulse `tx_start` for 1 cycle with `tx_data` valid while
// `tx_busy` is low. `tx_busy` stays high for the whole frame (incl. stop
// bit). `tx_done` pulses for 1 cycle when the stop bit has finished.
// tx_start while busy is ignored (the caller must wait for tx_busy low).
module uart_tx #(
    parameter CLKS_PER_BIT = 868
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    output wire       tx_busy,
    output reg        tx_done,
    output reg        tx_out        // serial line, idles HIGH
);
    localparam IDLE  = 2'd0,
               START = 2'd1,
               DATA  = 2'd2,
               STOP  = 2'd3;

    reg [1:0] state;
    reg [7:0] shifter;
    reg [2:0] bit_idx;

    wire tick;
    // Counter is held at 0 while idle so the start bit begins on a clean
    // boundary and lasts exactly CLKS_PER_BIT cycles.
    baud_gen #(.DIVISOR(CLKS_PER_BIT)) u_baud (
        .clk(clk), .rst(rst), .clear(state == IDLE),
        .tick(tick), .mid_tick()
    );

    assign tx_busy = (state != IDLE);

    always @(posedge clk) begin
        tx_done <= 1'b0;                       // default: pulse only
        if (rst) begin
            state   <= IDLE;
            tx_out  <= 1'b1;
            shifter <= 8'd0;
            bit_idx <= 3'd0;
        end else begin
            case (state)
                IDLE: begin
                    tx_out <= 1'b1;
                    if (tx_start) begin
                        shifter <= tx_data;    // latch: caller may change data
                        tx_out  <= 1'b0;       // start bit begins now
                        state   <= START;
                    end
                end
                START: if (tick) begin
                    tx_out  <= shifter[0];     // data bit 0 (LSB)
                    shifter <= {1'b0, shifter[7:1]};
                    bit_idx <= 3'd0;
                    state   <= DATA;
                end
                DATA: if (tick) begin
                    if (bit_idx == 3'd7) begin
                        tx_out <= 1'b1;        // stop bit
                        state  <= STOP;
                    end else begin
                        tx_out  <= shifter[0];
                        shifter <= {1'b0, shifter[7:1]};
                        bit_idx <= bit_idx + 3'd1;
                    end
                end
                STOP: if (tick) begin
                    tx_done <= 1'b1;
                    state   <= IDLE;
                end
            endcase
        end
    end
endmodule
