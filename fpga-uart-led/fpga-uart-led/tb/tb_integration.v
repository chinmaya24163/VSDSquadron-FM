// tb/tb_integration.v
`timescale 1ns/1ps

module tb_integration;
    // Clock (12 MHz emulation) and reset
    reg clk = 0;
    always #41.666 clk = ~clk; // ~12 MHz

    reg rstn = 0;

    // FIFO interface (driven by TB)
    reg [7:0] tb_fifo_dout = 8'h00;
    reg tb_fifo_empty = 1'b1;
    wire fifo_rd;

    // parser outputs (wired)
    wire buf_we;
    wire [$clog2(16*2)-1:0] buf_addr;
    wire [7:0] buf_din;
    wire lcd_valid;
    wire [7:0] lcd_data;
    wire lcd_is_data;
    wire lcd_ready;

    // Instantiate parser (uses fifo_dout/fifo_empty -> fifo_rd)
    parser #(.COLS(16), .ROWS(2)) pars (
        .clk(clk), .rstn(rstn),
        .fifo_dout(tb_fifo_dout), .fifo_empty(tb_fifo_empty), .fifo_rd(fifo_rd),
        .buf_we(buf_we), .buf_addr(buf_addr), .buf_din(buf_din),
        .lcd_valid(lcd_valid), .lcd_data(lcd_data), .lcd_is_data(lcd_is_data), .lcd_ready(lcd_ready)
    );

    // Instantiate lcd_ctrl: we'll tie lcd_ready high (accept immediately)
    reg lcd_ready_reg = 1'b1;
    assign lcd_ready = lcd_ready_reg;

    lcd_ctrl lcd (
        .clk(clk), .rstn(rstn),
        .in_valid(lcd_valid), .in_data(lcd_data), .in_is_data(lcd_is_data), .in_ready(/*unused*/),
        .db(), .rs(), .rw(), .e()
    );

    // Instantiate display buffer
    display_buffer #(.COLS(16), .ROWS(2)) dbuf (
        .clk(clk), .rstn(rstn), .we(buf_we), .addr(buf_addr), .din(buf_din), .dout()
    );

    // Sequence of bytes to send: clear, "Hello", newline, "Worl"
    reg [7:0] seq [0:15];
    integer seq_len = 11;
    integer seq_idx = 0;

    // integer variables at module scope (no in-block declarations)
    integer i;
    integer tmp;

    initial begin
        seq[0] = 8'h0C; // clear
        seq[1] = "H";
        seq[2] = "e";
        seq[3] = "l";
        seq[4] = "l";
        seq[5] = "o";
        seq[6] = 8'h0A; // newline
        seq[7] = "W";
        seq[8] = "o";
        seq[9] = "r";
        seq[10] = "l";
    end

    // Drive FIFO: when parser asserts fifo_rd, present next byte so parser reads it next cycle.
    always @(posedge clk) begin
        if (!rstn) begin
            tb_fifo_empty <= 1'b1;
            tb_fifo_dout <= 8'h00;
            seq_idx <= 0;
        end else begin
            if (seq_idx < seq_len) begin
                if (fifo_rd) begin
                    tb_fifo_dout <= seq[seq_idx];
                    tb_fifo_empty <= 1'b0;
                    seq_idx <= seq_idx + 1;
                end else begin
                    tb_fifo_empty <= 1'b1;
                end
            end else begin
                tb_fifo_empty <= 1'b1;
            end
        end
    end

    // Reset pulse, VCD dump, run length, and buffer dump
    initial begin
        $display("Starting integration testbench...");
        $dumpfile("build/tb_integration.vcd");
        $dumpvars(0, tb_integration);

        rstn = 0;
        #200;
        rstn = 1;

        // run enough time for parser + lcd_ctrl to process bytes
        #2000000; // 2 ms simulated time

        // Dump display buffer contents (hex and printable char if in range)
        $display("Display buffer contents (addr : hex / printable):");
        for (i = 0; i < 16*2; i = i + 1) begin
            tmp = dbuf.mem[i];
            if (tmp >= 32 && tmp <= 126) begin
                // printable ASCII
                $display("%0d : 0x%0h / %c", i, tmp, tmp);
            end else begin
                $display("%0d : 0x%0h / .", i, tmp);
            end
        end
        $display("End of buffer dump.");
        $finish;
    end

endmodule
