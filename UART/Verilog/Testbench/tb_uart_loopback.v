// Self-checking loopback testbench: TX -> RX through uart_top.
// Test 1: 8 bytes sent back-to-back (as the packet controller will).
// Test 2: a 4-byte Wave-Wars packet [FF|A|B|A^B].
// Test 3: a manually injected frame with a bad stop bit -> frame error.
// Test 4: a short glitch on the line must NOT produce a byte.
`timescale 1ns/1ps
module tb_uart_loopback;
    localparam CLK_FREQ = 100_000_000, BAUD = 115_200;
    localparam BIT_NS   = 1_000_000_000 / BAUD;      // ~8680 ns

    reg        clk = 0, rst = 1, tx_start = 0, inject = 0, inject_line = 1;
    reg  [7:0] tx_data = 0;
    wire       tx_busy, tx_done, txd, rxd, rx_valid, rx_frame_err;
    wire [7:0] rx_data;
    integer    errors = 0, rx_count = 0, err_count = 0;
    reg  [7:0] expected [0:15];
    integer    exp_n = 0;

    always #5 clk = ~clk;

    assign rxd = inject ? inject_line : txd;         // mux for fault injection

    uart_top #(.CLK_FREQ(CLK_FREQ), .BAUD(BAUD)) dut (
        .clk(clk), .rst(rst),
        .tx_start(tx_start), .tx_data(tx_data),
        .tx_busy(tx_busy), .tx_done(tx_done), .uart_txd(txd),
        .uart_rxd(rxd), .rx_data(rx_data),
        .rx_valid(rx_valid), .rx_frame_err(rx_frame_err)
    );

    // Scoreboard: every received byte must equal the next expected byte.
    always @(posedge clk) begin
        if (rx_valid) begin
            if (rx_count >= exp_n) begin
                $display("FAIL: unexpected byte %h", rx_data); errors = errors + 1;
            end else if (rx_data !== expected[rx_count]) begin
                $display("FAIL: got %h, expected %h", rx_data, expected[rx_count]);
                errors = errors + 1;
            end else
                $display("PASS: received %h", rx_data);
            rx_count = rx_count + 1;
        end
        if (rx_frame_err) err_count = err_count + 1;
    end

    task send_byte(input [7:0] value);
        begin
            wait (!tx_busy);
            expected[exp_n] = value; exp_n = exp_n + 1;
            @(negedge clk); tx_data = value; tx_start = 1;
            @(negedge clk); tx_start = 0;
        end
    endtask

    task inject_bit(input b);
        begin inject_line = b; #(BIT_NS); end
    endtask

    integer i;
    reg [7:0] a, b;
    initial begin
        repeat (5) @(posedge clk); rst = 0; repeat (5) @(posedge clk);

        // Test 1: back-to-back bytes incl. header and edge values
        send_byte(8'hFF); send_byte(8'h00); send_byte(8'h55); send_byte(8'hAA);
        send_byte(8'h01); send_byte(8'h80); send_byte(8'hFE); send_byte(8'hA5);
        wait (!tx_busy); #(BIT_NS * 3);

        // Test 2: Wave-Wars packet
        a = 8'd127; b = 8'd200;
        send_byte(8'hFF); send_byte(a); send_byte(b); send_byte(a ^ b);
        wait (!tx_busy); #(BIT_NS * 3);

        if (rx_count !== exp_n) begin
            $display("FAIL: received %0d of %0d bytes", rx_count, exp_n); errors = errors + 1;
        end

        // Test 3: bad stop bit (data 0x3C), expect frame error, no byte
        inject = 1; inject_line = 1; #(BIT_NS * 2);
        inject_bit(0);                                  // start
        for (i = 0; i < 8; i = i + 1) inject_bit(8'h3C >> i & 1'b1);
        inject_bit(0);                                  // BAD stop bit
        inject_bit(1); #(BIT_NS * 2);
        if (err_count !== 1) begin
            $display("FAIL: expected 1 frame error, saw %0d", err_count); errors = errors + 1;
        end else $display("PASS: frame error detected");

        // Test 4: 1/4-bit glitch must be rejected (no new byte)
        inject_line = 0; #(BIT_NS / 4); inject_line = 1; #(BIT_NS * 12);
        if (rx_count !== exp_n) begin
            $display("FAIL: glitch produced a byte"); errors = errors + 1;
        end else $display("PASS: glitch rejected");

        if (errors == 0) $display("ALL LOOPBACK TESTS PASSED");
        else             $display("LOOPBACK TESTS FAILED: %0d error(s)", errors);
        $finish;
    end

    initial begin #100_000_000; $display("TIMEOUT"); $finish; end
endmodule
