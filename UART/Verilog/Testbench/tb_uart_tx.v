// Self-checking TX testbench: samples the serial line independently
// (mid-bit) and checks start bit, 8 data bits LSB first, and stop bit.
`timescale 1ns/1ps
module tb_uart_tx;
    localparam CLKS_PER_BIT = 868;
    localparam CLK_PERIOD   = 10;           // 100 MHz

    reg        clk = 0, rst = 1, tx_start = 0;
    reg  [7:0] tx_data = 0;
    wire       tx_busy, tx_done, tx_line;
    integer    errors = 0;

    always #(CLK_PERIOD/2) clk = ~clk;

    uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) dut (
        .clk(clk), .rst(rst), .tx_start(tx_start), .tx_data(tx_data),
        .tx_busy(tx_busy), .tx_done(tx_done), .tx_out(tx_line)
    );

    task send_and_check(input [7:0] value);
        integer i;
        reg [7:0] got;
        begin
            @(negedge clk); tx_data = value; tx_start = 1;
            @(negedge clk); tx_start = 0;
            // line should drop (start bit) immediately
            if (tx_line !== 1'b0) begin
                $display("FAIL: no start bit for %h", value); errors = errors + 1;
            end
            repeat (CLKS_PER_BIT/2) @(posedge clk);       // middle of start
            if (tx_line !== 1'b0) begin
                $display("FAIL: start bit not low (%h)", value); errors = errors + 1;
            end
            for (i = 0; i < 8; i = i + 1) begin
                repeat (CLKS_PER_BIT) @(posedge clk);
                got[i] = tx_line;                         // LSB first
            end
            repeat (CLKS_PER_BIT) @(posedge clk);         // middle of stop
            if (tx_line !== 1'b1) begin
                $display("FAIL: stop bit not high (%h)", value); errors = errors + 1;
            end
            if (got !== value) begin
                $display("FAIL: sent %h, line carried %h", value, got); errors = errors + 1;
            end else
                $display("PASS: %h", value);
            wait (!tx_busy);
        end
    endtask

    initial begin
        repeat (5) @(posedge clk); rst = 0; repeat (5) @(posedge clk);
        if (tx_line !== 1'b1) begin $display("FAIL: line not idle-high"); errors = errors + 1; end
        send_and_check(8'hFF);   // packet header
        send_and_check(8'h55);
        send_and_check(8'hAA);
        send_and_check(8'h00);
        send_and_check(8'hA5);
        send_and_check(8'hFE);   // max sample value (samples are 0..254)
        if (errors == 0) $display("ALL TX TESTS PASSED");
        else             $display("TX TESTS FAILED: %0d error(s)", errors);
        $finish;
    end

    initial begin #50_000_000; $display("TIMEOUT"); $finish; end
endmodule
