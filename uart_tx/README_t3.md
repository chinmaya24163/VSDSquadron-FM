# UART Transmitter - VSDSquadron FPGA Mini

## Objective

Transmit a single character ('D') using a UART transmitter implemented on the VSDSquadron FPGA Mini board. This project demonstrates the basic principles of serial transmission using a baud-rate generator and FSM-based UART logic.

---

## Files

* `uart_trx.v` – Verilog source for UART transmission logic.
* `top.v` – Top-level Verilog module instantiating and configuring the UART transmitter.
* `VSDSquadronFM.pcf` – Pin constraint file mapping `uart_tx` and `clk` to FPGA pins.
* `Makefile` – Build and flash instructions.
* `README.md` – This documentation.

---

## Code Overview

### top.v
- Instantiates `uart_tx_8n1` to send the character "D"
- Uses SB_HFOSC for 12 MHz clock
- Divides clock to create 9600 Hz
- Uses counter to generate send trigger

### uart_trx.v
- FSM with states: IDLE, STARTTX, TXING, TXDONE
- Transmits 1 start bit, 8 data bits, 1 stop bit

### VSDSquadronFM.pcf
- Pin 14 = uarttx (TX)
- Pin 20 = hw_clk (clock input)

### Makefile
- `make build`: Synthesizes and P&R
- `make flash`: Programs the FPGA
- `make terminal`: Opens serial terminal using picocom

---

## Step 1: Understand the Design

The design transmits the character 'D' over UART at 9600 baud. The `uart_trx.v` module handles UART transmission using a simple FSM. A clock divider reduces the 12 MHz oscillator to the appropriate baud rate.

### UART Transmitter Architecture

```
+--------------------------+
|                          |
|   Clock Divider (9600)   |
|                          |
+------------+-------------+
             |
             v
+--------------------------+
|  UART FSM: Start -> TX -> Done  |
|  (start bit, 8 data bits, stop) |
+--------------------------+
             |
             v
         uart_tx (Pin 14)
```

**Diagram:**

![uart_tx_block_diagram](images/uart_tx_block_diagram.png)

* The oscillator is divided to 9600 baud.
* The FSM transmits: Start bit (0), bits of 'D', Stop bit (1).
* Data is sent through Pin 14 (TX).

---

## Step 2: Pin Mapping (`VSDSquadronFM.pcf`)

```text
set_io uarttx 14
set_io hw_clk 20
```

| Signal   | Pin | Description                 |
| -------- | --- | --------------------------- |
| `uarttx` | 14  | TX output from FPGA (to PC) |
| `hw_clk` | 20  | 12 MHz oscillator clock     |

These match the TX pin on the VSDSquadron FPGA Mini board.

---

## Step 3: Circuit Diagram

A simple UART TX-only setup is shown below:

![uart_tx_circuit_diagram](images/uart_tx_circuit_diagram.png)

* Connect Pin 14 (TX) from FPGA to RX of USB-UART converter.
* Connect GND from FPGA to GND of USB-UART converter.
* No connection needed for RX since it's a one-way transmitter.

---

## Step 4: Build & Flash

Run the following in the project directory:

```text
make clean       # Remove previous builds
make build       # Synthesizes and places design
sudo make flash  # Flash to FPGA board
```

---

## Step 5: Testing

Use a serial terminal to view output:

```text
sudo picocom -b 9600 /dev/ttyUSB0
```

Expected result: the terminal repeatedly prints the character 'D'.

![make_build](images/make_build.png)

---

## Testing & Verification

**Objective:**
To verify successful UART transmission of the character 'D' from the FPGA.

**Procedure:**

1. Connect FPGA TX (Pin 14) to USB UART RX.
2. Power FPGA.
3. Open serial terminal using baud 9600.
4. Observe terminal output.

**Expected Output:**

```text
DDDDDDDDDDDDDDDDDD...
```
## Findings & Test Results

1. **Synthesis**  
   - Yosys successfully generated `top.json`.  
   - ![Yosys synth_1](images/yosys_synth_1.png)
   - ![Yosys synth_2](images/yosys_synth_2.png)
   - ![Yosys synth_3](images/yosys_synth_3.png)
   - ![Yosys synth_4](images/yosys_synth_4.png)
   - ![Yosys synth_5](images/yosys_synth_5.png)
   - ![Yosys synth_6](images/yosys_synth_6.png)
   - ![Yosys synth_7](images/yosys_synth_7.png)
   - ![Yosys synth_8](images/yosys_synth_8.png)
   - ![Yosys synth_9](images/yosys_synth_9.png)
   - ![Yosys synth_10](images/yosys_synth_10.png)
   - ![Yosys synth_11](images/yosys_synth_11.png)
   - ![Yosys synth_12](images/yosys_synth_12.png)
   - ![Yosys synth_13](images/yosys_synth_13.png)
   - ![Yosys synth_14](images/yosys_synth_14.png)
   - ![Yosys synth_15](images/yosys_synth_15.png)
   - ![Yosys synth_16](images/yosys_synth_16.png)
   - ![Yosys synth_17](images/yosys_synth_17.png)
   - ![Yosys synth_18](images/yosys_synth_18.png)
   - ![Yosys synth_19](images/yosys_synth_19.png)
   - ![Yosys synth_20](images/yosys_synth_20.png)
   - ![Yosys synth_21](images/yosys_synth_21.png)
   - ![Yosys synth_22](images/yosys_synth_22.png)
   - ![Yosys synth_23](images/yosys_synth_23.png)
   - ![Yosys synth_24](images/yosys_synth_24.png)
   - ![Yosys synth_25](images/yosys_synth_25.png)
   - ![Yosys synth_26](images/yosys_synth_26.png)
   - ![Yosys synth_27](images/yosys_synth_27.png)
   - ![Yosys synth_28](images/yosys_synth_28.png)
   - ![Yosys synth_29](images/yosys_synth_29.png)
   - ![Yosys synth_30](images/yosys_synth_30.png)
   - ![Yosys synth_31](images/yosys_synth_31.png)
   - ![Yosys synth_32](images/yosys_synth_32.png)
   - ![Yosys synth_33](images/yosys_synth_33.png)
   - ![Yosys synth_34](images/yosys_synth_34.png)
   - ![Yosys synth_35](images/yosys_synth_35.png)
   - ![Yosys synth_36](images/yosys_synth_36.png)
   - ![Yosys synth_37](images/yosys_synth_37.png)
   - ![Yosys synth_38](images/yosys_synth_38.png)
   - ![Yosys synth_39](images/yosys_synth_39.png)
   - ![Yosys synth_40](images/yosys_synth_40.png)
   - ![Yosys synth_41](images/yosys_synth_41.png)
   - ![Yosys synth_42](images/yosys_synth_42.png)
   - ![Yosys synth_43](images/yosys_synth_43.png)
   - ![Yosys synth_44](images/yosys_synth_44.png)
   - ![Yosys synth_45](images/yosys_synth_45.png)
   - ![Yosys synth_46](images/yosys_synth_46.png)
   - ![Yosys synth_47](images/yosys_synth_47.png)
   - ![Yosys synth_48](images/yosys_synth_48.png)
   - ![Yosys synth_49](images/yosys_synth_49.png)
   - ![Yosys synth_50](images/yosys_synth_50.png)
   - ![Yosys synth_51](images/yosys_synth_51.png)
   - ![Yosys synth_52](images/yosys_synth_52.png)
   - ![Yosys synth_53](images/yosys_synth_53.png)
   - ![Yosys synth_54](images/yosys_synth_54.png)
   - ![Yosys synth_55](images/yosys_synth_55.png)
   - ![Yosys synth_56](images/yosys_synth_56.png)
   - ![Yosys synth_57](images/yosys_synth_57.png)

2. **Place & Route**  
   - nextpnr-ice40 placed and routed with 0% utilization of critical primitives.    

3. **Bitstream Generation**  
   - `icepack` created `top_out.bin` without errors.  

4. **Programming the FPGA**  
   - `iceprog` successfully flashed the board (VERIFY OK).  
   - ![iceprog flash log](images/iceprog.png)  

5. **UART Verification**  
   - PuTTY on Windows (COM5, 9600 baud, 8N1) showed continuous ‘D’.  
   - ![PuTTY showing D’s](images/putty_output.png)

   - picocom on Linux (`sudo picocom -b 9600 /dev/ttyUSB0`) confirmed the same.    

**Conclusion:**
The FPGA successfully transmits the UART data repeatedly. The FSM and divider logic operate correctly to output the 'D' character at 9600 baud.

### UART Transmission Demo Video

[YouTube Short – UART TX Demo](https://youtube.com/shorts/VtstkPyz7ns?si=Y0yuQZwfJEE9kOj5)
