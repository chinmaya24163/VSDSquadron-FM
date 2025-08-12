TOP = top
PCF = constraints/vsdsquadron.pcf
VERILOG = rtl/*.v
BUILD = build
YOSYS = yosys
NEXTPNR = nextpnr-ice40
ICEPACK = icepack
ICEPROG = iceprog

all: $(BUILD)/$(TOP).bin

$(BUILD)/$(TOP).asc: $(VERILOG) $(PCF)
	mkdir -p $(BUILD)
	$(YOSYS) -p "synth_ice40 -top $(TOP) -json $(BUILD)/$(TOP).json" $(VERILOG)
	$(NEXTPNR) --up5k --package sg48 --pcf $(PCF) --json $(BUILD)/$(TOP).json --asc $(BUILD)/$(TOP).asc
	$(ICEPACK) $(BUILD)/$(TOP).asc $(BUILD)/$(TOP).bin

$(BUILD)/$(TOP).bin: $(BUILD)/$(TOP).asc
	@echo "bitstream ready: $(BUILD)/$(TOP).bin"

flash: $(BUILD)/$(TOP).bin
	$(ICEPROG) $(BUILD)/$(TOP).bin

clean:
	rm -rf $(BUILD)/*

.PHONY: all flash clean