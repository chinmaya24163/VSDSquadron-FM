// sensor_if.v
// simple module: sample digital sensor and output ASCII '0' or '1' when asked

module sensor_if (
    input  wire clk,        // system / baud clock (we will use clk_9600 or a slower enable)
    input  wire sensor_in,  // digital sensor input
    input  wire sample_en,  // when high, latch sample
    output reg  [7:0] out_byte // ASCII byte to transmit
);
    always @(posedge clk) begin
        if (sample_en) begin
            if (sensor_in)
                out_byte <= "1";
            else
                out_byte <= "0";
        end
    end
endmodule
