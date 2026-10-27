// =========================================================================
// Testbench: tb_top_wave_wars_bridge.v
// Decodes serial telemetry bitstream & logs binary stream to uart_tx_out.bin
// =========================================================================
`timescale 1ns / 1ps

module tb_top_wave_wars_bridge;

    reg clk;
    reg rst;
    wire tx_serial;
    wire [7:0] rx_data;
    wire rx_done;
    integer fd;

    // Instantiate Integrated System Top
    top_wave_wars uut (
        .clk(clk),
        .rst(rst),
        .tx_serial(tx_serial)
    );

    // Instantiate UART Receiver for deserialization
    uart_rx #(
        .CLKS_PER_BIT(868)
    ) u_rx_decoder (
        .clk(clk),
        .rst(rst),
        .rx_in(tx_serial),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    // 100 MHz Clock Generation (10 ns period)
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        fd = $fopen("uart_tx_out.bin", "wb");
        if (fd == 0) begin
            $display("[TB ERROR] Could not open uart_tx_out.bin for binary write!");
            $finish;
        end
        $display("[TB] Simulation Bridge Started. Logging binary bytes to uart_tx_out.bin...");
        
        #100;
        rst = 0;
        
        // Run simulation for 50 ms to capture serial packets
        #50000000;
        $fclose(fd);
        $display("[TB] Simulation Complete. Log file closed.");
        $finish;
    end

    // Stream decoded UART bytes into binary file on rx_done pulse
    always @(posedge clk) begin
        if (rx_done) begin
            $fwrite(fd, "%c", rx_data);
            $fflush(fd);
        end
    end

endmodule