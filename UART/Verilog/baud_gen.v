// ── MASTER CODER OUTPUT ──────────────────────────────────────────────
// Mode: Write | Module: baud_gen (Ashvanth, Wave-Wars UART core)
// Principles: SRP (only counts clocks), DRY (shared by TX and RX), KISS
// ─────────────────────────────────────────────────────────────────────
// Restartable bit-timing counter.
//   tick     : 1-cycle pulse once every DIVISOR clocks (end of a bit)  -> TX
//   mid_tick : 1-cycle pulse DIVISOR/2 clocks after (re)start/tick      -> RX
// Holding `clear` high keeps the counter at 0, so TX/RX can align the
// bit boundary to the exact clock cycle where a frame begins.
module baud_gen #(
    parameter DIVISOR = 868          // clock cycles per bit (100 MHz / 115200)
)(
    input  wire clk,
    input  wire rst,                 // synchronous, active high
    input  wire clear,               // restart counter (align to frame start)
    output wire tick,
    output wire mid_tick
);
    reg [15:0] count;

    assign tick     = (count == DIVISOR - 1);
    assign mid_tick = (count == DIVISOR / 2);

    always @(posedge clk) begin
        if (rst || clear || tick)
            count <= 16'd0;
        else
            count <= count + 16'd1;
    end
endmodule
