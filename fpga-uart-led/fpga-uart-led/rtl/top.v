// rtl/top.v
`default_nettype none
module top (
    input  wire clk_12mhz,   // board 12 MHz
    input  wire uart_rx_pin, // RX from FTDI

    // external LEDs (3 external pins). Active HIGH out -> resistor -> LED -> GND
    output wire ext_led0,
    output wire ext_led1,
    output wire ext_led2,

    // keep uart_tx pin even if unused
    output wire uart_tx_pin
);

    // ---------- Power-On Reset (POR) ----------
    // hold reset low for POR_CYCLES cycles after power-up
    localparam integer CLK_FREQ = 12000000;
    // POR time (in cycles) ~ 12k cycles = 1 ms, 120k = 10 ms — choose 120k for ~10ms
    localparam integer POR_CYCLES = 120000;
    // width for counter
    localparam integer POR_BITS = $clog2(POR_CYCLES+1);
    reg [POR_BITS-1:0] por_cnt = 0;
    always @(posedge clk_12mhz) begin
        if (por_cnt != POR_CYCLES) por_cnt <= por_cnt + 1;
    end
    wire rstn = (por_cnt == POR_CYCLES); // 1 = run, 0 = reset

    // ---------- UART RX ----------
    wire [7:0] rx_byte;
    wire       rx_valid;
    uart_rx #(.CLK_FREQ(CLK_FREQ), .BAUD(9600)) uart_inst (
        .clk(clk_12mhz), .rstn(rstn), .rx(uart_rx_pin), .dout(rx_byte), .valid(rx_valid)
    );

    // ---------- LED parser ----------
    wire [2:0] leds_out;
    led_parser parser (
        .clk(clk_12mhz), .rstn(rstn), .rx_byte(rx_byte), .rx_valid(rx_valid), .leds(leds_out)
    );

    // ---------- RX activity pulse for debugging ----------
    // Make ext_led2 show a short pulse on any received byte; does not interfere with parser
    reg [15:0] act_ctr;
    wire activity = (act_ctr != 0);
    always @(posedge clk_12mhz) begin
        if (!rstn) act_ctr <= 0;
        else begin
            if (rx_valid) act_ctr <= 16'hFFFF; // long enough to be visible
            else if (act_ctr != 0) act_ctr <= act_ctr - 1;
        end
    end

    // connect outputs:
    assign ext_led0 = leds_out[0];                // controlled by '1' command
    assign ext_led1 = leds_out[1];                // '2'
    // ext_led2 shows parser control OR activity pulse: prefer parser whenever it sets ext_led2 (command '3'),
    // but if parser doesn't set it, activity will show any incoming bytes
    assign ext_led2 = leds_out[2] | (activity & ~leds_out[2]);

    // unused uart tx pulled high (idle)
    assign uart_tx_pin = 1'b1;

endmodule
`default_nettype wire
