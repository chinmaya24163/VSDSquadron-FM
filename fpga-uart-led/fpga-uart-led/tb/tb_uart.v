// tb_uart.v - simple testbench: drives uart_rx line with ASCII '1','2','3','0'
`timescale 1ns/1ps
module tb_uart;
    reg clk = 0;
    always #41.666 clk = ~clk; // 12 MHz

    reg rstn = 0;
    initial begin
        #200 rstn = 1;
    end

    // signals to DUT
    reg rx = 1; // idle high
    wire ext0, ext1, ext2;

    top dut (
        .clk_12mhz(clk), .rstn_btn(rstn),
        .uart_rx_pin(rx),
        .ext_led0(ext0), .ext_led1(ext1), .ext_led2(ext2),
        .uart_tx_pin(), .led_green_unused(), .led_red_unused(), .led_blue_unused()
    );

    // helper task to send a byte on rx (8N1)
    task send_byte(input [7:0] b);
        integer i;
        real bit_time;
        begin
            bit_time = 1.0e9 / 12000000.0 * (12000000/9600); // crude approx; more simply use delays
            // we'll emulate by toggling rx at periods corresponding to baud (approx)
            // start bit
            rx = 0; #104166; // ~104.166 us (9600 baud)
            for (i=0;i<8;i=i+1) begin
                rx = b[i]; #104166;
            end
            rx = 1; #104166; // stop bit
        end
    endtask

    initial begin
        $display("TB start");
        #1000;
        send_byte("1"); #200000;
        send_byte("2"); #200000;
        send_byte("3"); #200000;
        send_byte("0"); #200000;
        $display("ext leds: %b %b %b", ext0, ext1, ext2);
        $finish;
    end
endmodule
