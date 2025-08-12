// uart_rx.v - simple UART receiver 8N1, parametrized
// Samples using clock ticks: DIV = CLK_FREQ / BAUD must be integer.
`timescale 1ns/1ps
module uart_rx #(
    parameter integer CLK_FREQ = 12000000,
    parameter integer BAUD = 9600
)(
    input  wire clk,
    input  wire rstn,    // active high reset (1 = run). If you have active-low button, tie rstn = rstn_btn
    input  wire rx,      // serial input (idle high)
    output reg  [7:0] dout,
    output reg  valid    // 1-cycle pulse when dout is valid
);
    localparam integer DIV = CLK_FREQ / BAUD;
    localparam integer HALF = DIV / 2;

    // state encoding
    localparam IDLE  = 2'd0;
    localparam START = 2'd1;
    localparam RXB   = 2'd2;
    localparam STOP  = 2'd3;

    reg [1:0] state;
    reg [$clog2(DIV)-1:0] cnt;
    reg [3:0] bit_idx;
    reg [7:0] shift;
    reg rx_d;

    // synchronize rx
    always @(posedge clk) rx_d <= rx;

    always @(posedge clk) begin
        if (!rstn) begin
            state <= IDLE;
            cnt <= 0;
            bit_idx <= 0;
            shift <= 8'h00;
            dout <= 8'h00;
            valid <= 1'b0;
        end else begin
            valid <= 1'b0;
            case (state)
                IDLE: begin
                    if (rx_d == 1'b0) begin
                        state <= START;
                        cnt <= 0;
                    end
                end
                START: begin
                    if (cnt == HALF - 1) begin
                        // confirm start bit in middle
                        if (rx_d == 1'b0) begin
                            cnt <= 0;
                            bit_idx <= 0;
                            state <= RXB;
                        end else begin
                            state <= IDLE;
                        end
                    end else cnt <= cnt + 1;
                end
                RXB: begin
                    if (cnt == DIV - 1) begin
                        cnt <= 0;
                        shift[bit_idx] <= rx_d;
                        if (bit_idx == 7) state <= STOP;
                        else bit_idx <= bit_idx + 1;
                    end else cnt <= cnt + 1;
                end
                STOP: begin
                    if (cnt == DIV - 1) begin
                        cnt <= 0;
                        dout <= shift;
                        valid <= 1'b1;
                        state <= IDLE;
                    end else cnt <= cnt + 1;
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
