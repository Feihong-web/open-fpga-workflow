SHELL := /bin/bash

TOP          ?= top
DEVICE       ?= up5k
PACKAGE      ?= sg48
FREQ_MHZ     ?= 12
PCF          ?= constraints/icebreaker.pcf

BUILD_DIR    := build
RTL_SOURCES  := $(wildcard rtl/*.v) $(wildcard rtl/*.sv)
TB_SOURCES   := $(wildcard tb/*.v) $(wildcard tb/*.sv)
JSON         := $(BUILD_DIR)/$(TOP).json
ASC          := $(BUILD_DIR)/$(TOP).asc
BIN          := $(BUILD_DIR)/$(TOP).bin
SIM          := $(BUILD_DIR)/sim.vvp
VCD          := $(BUILD_DIR)/wave.vcd

.PHONY: help all check lint sim synth pnr bitstream timing versions clean

help:
	@echo "Open FPGA workflow (default target: iCEBreaker / iCE40 UP5K)"
	@echo
	@echo "  make check       Run lint and RTL simulation"
	@echo "  make all         Run lint, simulation, synthesis, P&R and bitstream"
	@echo "  make timing      Generate a timing report"
	@echo "  make versions    Print tool versions"
	@echo "  make clean       Remove generated files"
	@echo
	@echo "Docker:"
	@echo "  docker compose build"
	@echo "  docker compose run --rm fpga make all"

all: check bitstream timing

check: lint sim

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

lint: | $(BUILD_DIR)
	verilator --lint-only --Wall --top-module $(TOP) $(RTL_SOURCES)

sim: $(SIM)
	vvp $(SIM)
	@test -f $(VCD)

$(SIM): $(RTL_SOURCES) $(TB_SOURCES) | $(BUILD_DIR)
	iverilog -g2012 -Wall -s tb_top -o $@ $(RTL_SOURCES) $(TB_SOURCES)

synth: $(JSON)

$(JSON): $(RTL_SOURCES) | $(BUILD_DIR)
	yosys -q -p "read_verilog -sv $(RTL_SOURCES); synth_ice40 -top $(TOP) -json $@"

pnr: $(ASC)

$(ASC): $(JSON) $(PCF)
	nextpnr-ice40 \
		--$(DEVICE) \
		--package $(PACKAGE) \
		--freq $(FREQ_MHZ) \
		--json $(JSON) \
		--pcf $(PCF) \
		--asc $@

bitstream: $(BIN)

$(BIN): $(ASC)
	icepack $< $@
	@echo "Bitstream created: $@"

timing: $(ASC)
	icetime -d $(DEVICE) -mtr $(BUILD_DIR)/timing.rpt $(ASC)
	@echo "Timing report: $(BUILD_DIR)/timing.rpt"

versions:
	@iverilog -V 2>&1 | head -n 1
	@verilator --version
	@yosys -V
	@nextpnr-ice40 --version
	@icepack -V 2>&1 | head -n 1 || true

clean:
	rm -rf $(BUILD_DIR)
