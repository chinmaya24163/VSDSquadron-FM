`include "uart_trx.v"
`include "sensor_if.v"

module top (
  output wire led_red,
  output wire led_blue,
  output wire led_green,
  output wire uarttx,
  input  wire ir_sensor,   // mapped to pin 21 in PCF
  input  wire hw_clk
);

  wire int_osc;
  reg [27:0] frequency_counter_i;

  // 9600 "baud clock" generation (toggle every period_9600 cycles)
  reg clk_9600 = 0;
  reg [31:0] cntr_9600 = 32'b0;
  parameter period_9600 = 625; // as in your repo

  // trigger sample once every ~some interval (e.g. frequency_counter_i[20])
  wire sample_tick = frequency_counter_i[20]; // choose bit to set sampling rate

  reg sample_edge = 0;
  reg prev_sample_tick = 0;

  // wires to/from sensor_if and uart
  wire [7:0] sensor_byte;
  reg  senddata = 0;

  // instantiate sensor interface: sample on rising sample_tick
  sensor_if sinst (
    .clk(clk_9600),
    .sensor_in(ir_sensor),
    .sample_en(sample_edge),
    .out_byte(sensor_byte)
  );

  // instantiate UART
  uart_tx_8n1 DanUART (
    .clk (clk_9600),
    .txbyte(sensor_byte),
    .senddata(senddata),
    .tx(uarttx)
  );

  // internal oscillator
  SB_HFOSC #(.CLKHF_DIV ("0b10")) u_SB_HFOSC (
    .CLKHFPU(1'b1),
    .CLKHFEN(1'b1),
    .CLKHF(int_osc)
  );

  // main counter and 9600 clock + generate a one-clock 'sample_edge'
  always @(posedge int_osc) begin
    frequency_counter_i <= frequency_counter_i + 1'b1;

    // 9600 generation
    cntr_9600 <= cntr_9600 + 1;
    if (cntr_9600 == period_9600) begin
      clk_9600 <= ~clk_9600;
      cntr_9600 <= 32'b0;
    end

    // create a pulse when sample_tick rises
    prev_sample_tick <= sample_tick;
    sample_edge <= sample_tick & ~prev_sample_tick;

    // trigger senddata for one clk_9600 cycle when sample_edge occurs
    // we will assert senddata in clk_9600 domain, so create handshake:
    // We'll detect sample_edge in int_osc domain and set send_request, then clear in clk_9600 domain.
  end

  // Simple cross-domain: request register (from int_osc to clk_9600)
  reg send_request = 0;
  always @(posedge int_osc) begin
    if (sample_edge) send_request <= 1'b1;
  end

  // consume the request in clk_9600 domain
  reg request_sync = 0;
  always @(posedge clk_9600) begin
    if (send_request) begin
      senddata <= 1'b1;
      send_request <= 1'b0;
      request_sync <= 1'b1;
    end else begin
      senddata <= 1'b0;
      request_sync <= 1'b0;
    end
  end

  // Simple LED breathing/color (optional) — keep as before or remove
  SB_RGBA_DRV RGB_DRIVER (
    .RGBLEDEN(1'b1),
    .RGB0PWM (frequency_counter_i[24]&frequency_counter_i[23]),
    .RGB1PWM (frequency_counter_i[24]&~frequency_counter_i[23]),
    .RGB2PWM (~frequency_counter_i[24]&frequency_counter_i[23]),
    .CURREN  (1'b1),
    .RGB0    (led_green),
    .RGB1    (led_blue),
    .RGB2    (led_red)
  );
  defparam RGB_DRIVER.RGB0_CURRENT = "0b000001";
  defparam RGB_DRIVER.RGB1_CURRENT = "0b000001";
  defparam RGB_DRIVER.RGB2_CURRENT = "0b000001";

endmodule
