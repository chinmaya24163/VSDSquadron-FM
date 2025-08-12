// rtl/test_blink.v - toggle all segments ON / OFF so you can visually verify wiring and mapping
module test_blink (
    input  wire clk_12mhz,
    input  wire rstn_btn,
    output wire uart_tx,
    output wire led_green,
    output wire led_red,
    output wire led_blue,
    output wire [7:0] seg_pins
);

    wire rstn = rstn_btn;

    // simple clock divider to create ~1 Hz blink from 12 MHz
    reg [22:0] cnt;
    reg blink;

    always @(posedge clk_12mhz or negedge rstn) begin
        if (!rstn) begin
            cnt <= 0;
            blink <= 1'b0;
        end else begin
            cnt <= cnt + 1;
            if (cnt == 0) begin
                blink <= ~blink;
            end
        end
    end

    // For common-anode: driving LOW lights segments.
    // When blink=1 -> all segments ON (drive 0), when blink=0 -> all segments OFF (drive 1)
    assign seg_pins = blink ? 8'b0000_0000 : 8'b1111_1111;

    assign uart_tx = 1'b1;
    assign led_green = 1'b0;
    assign led_red   = 1'b0;
    assign led_blue  = 1'b0;

endmodule
