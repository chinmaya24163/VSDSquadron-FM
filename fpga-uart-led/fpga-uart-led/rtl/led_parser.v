// rtl/led_parser.v
module led_parser (
    input  wire        clk,
    input  wire        rstn,        // active-high reset
    input  wire [7:0]  rx_byte,
    input  wire        rx_valid,
    output reg  [2:0]  leds         // leds[0..2] = external LEDs, active HIGH
);
    always @(posedge clk) begin
        if (!rstn) begin
            leds <= 3'b000;
        end else begin
            if (rx_valid) begin
                case (rx_byte)
                    "1": leds <= 3'b001;
                    "2": leds <= 3'b010;
                    "3": leds <= 3'b100;
                    "0": leds <= 3'b000;
                    default: leds <= leds; // ignore others
                endcase
            end
        end
    end
endmodule
