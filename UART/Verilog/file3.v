`timescale 1ns / 1ps

module packet_controller (
    input  wire       clk,
    input  wire       rst,
    input  wire [7:0] sig_a,
    input  wire [7:0] sig_b,
    input  wire       tx_busy,
    output reg  [7:0] tx_data,
    output reg        tx_start,
    output reg        sample_tick
);

    localparam IDLE   = 3'd0,
               SEND_HDR = 3'd1,
               WAIT_HDR = 3'd2,
               SEND_SIGA = 3'd3,
               WAIT_SIGA = 3'd4,
               SEND_SIGB = 3'd5,
               WAIT_SIGB = 3'd6,
               SEND_CHK  = 3'd7;

    reg [2:0] state;
    reg [16:0] sample_timer; // 1,000 Hz tick generation from 100 MHz clock

    // Sample Rate Timer: Triggers packet framing every 1 ms
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sample_timer <= 17'd0;
            sample_tick  <= 1'b0;
        end else if (sample_timer == 17'd99_999) begin
            sample_timer <= 17'd0;
            sample_tick  <= 1'b1;
        end else begin
            sample_timer <= sample_timer + 1'b1;
            sample_tick  <= 1'b0;
        end
    end

    // Packet Assembly FSM
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state    <= IDLE;
            tx_data  <= 8'd0;
            tx_start <= 1'b0;
        end else begin
            tx_start <= 1'b0; // Default pulse
            case (state)
                IDLE: begin
                    if (sample_tick)
                        state <= SEND_HDR;
                end

                SEND_HDR: begin
                    tx_data  <= 8'hFF; // Header Byte
                    tx_start <= 1'b1;
                    state    <= WAIT_HDR;
                end

                WAIT_HDR: begin
                    if (!tx_busy && !tx_start)
                        state <= SEND_SIGA;
                end

                SEND_SIGA: begin
                    tx_data  <= sig_a;
                    tx_start <= 1'b1;
                    state    <= WAIT_SIGA;
                end

                WAIT_SIGA: begin
                    if (!tx_busy && !tx_start)
                        state <= SEND_SIGB;
                end

                SEND_SIGB: begin
                    tx_data  <= sig_b;
                    tx_start <= 1'b1;
                    state    <= WAIT_SIGB;
                end

                WAIT_SIGB: begin
                    if (!tx_busy && !tx_start)
                        state <= SEND_CHK;
                end

                SEND_CHK: begin
                    tx_data  <= sig_a ^ sig_b; // XOR Checksum
                    tx_start <= 1'b1;
                    state    <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule