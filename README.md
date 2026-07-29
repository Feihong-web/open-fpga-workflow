# Open FPGA Workflow

A small, reproducible, fully open-source FPGA workflow for teaching and
experimentation. The default hardware target is the iCEBreaker board with an
iCE40 UP5K FPGA.

## Pipeline

1. Verilator lint
2. Icarus Verilog simulation
3. Yosys synthesis
4. nextpnr placement and routing
5. Project IceStorm bitstream generation and timing analysis
6. GitHub Actions continuous integration

No proprietary FPGA software is required.

## Quick start with Docker

```bash
docker compose build
docker compose run --rm fpga make versions
docker compose run --rm fpga make all
```

Successful completion produces:

```text
build/top.bin       FPGA bitstream
build/top.asc       placed-and-routed design
build/top.json      synthesized netlist
build/timing.rpt    timing report
build/wave.vcd      simulation waveform
```

Run only the fast checks while editing RTL:

```bash
docker compose run --rm fpga make check
```

Remove generated files:

```bash
docker compose run --rm fpga make clean
```

## Offline use

Build the image once on a machine with reliable international network access:

```bash
docker compose build
docker save open-fpga-workflow:local | gzip > open-fpga-workflow-image.tar.gz
```

Move the archive to the offline machine and import it without contacting Docker
Hub, APT or GitHub:

```bash
gunzip -c open-fpga-workflow-image.tar.gz | docker load
docker run --rm \
  -v "$PWD:/workspace" \
  -w /workspace \
  open-fpga-workflow:local \
  make all
```

## Use without Docker

Install Icarus Verilog, Verilator, Yosys, nextpnr-ice40, Project IceStorm and
GNU Make, then run:

```bash
make all
```

## Change the hardware target

The default configuration in `Makefile` is:

```make
DEVICE   ?= up5k
PACKAGE  ?= sg48
FREQ_MHZ ?= 12
PCF      ?= constraints/icebreaker.pcf
```

For another iCE40 board, add its PCF constraint file and override these
variables from the command line:

```bash
make all \
  DEVICE=hx8k \
  PACKAGE=ct256 \
  FREQ_MHZ=12 \
  PCF=constraints/my_board.pcf
```

The clock and every top-level I/O port must have a valid physical pin in the
selected PCF file.

## Program the FPGA

Programming is deliberately kept outside the cloud container because it needs
direct access to local USB hardware. For an iCEBreaker with `iceprog` installed:

```bash
iceprog build/top.bin
```

## Suggested BitForge integration

- Put student-editable RTL in `rtl/`.
- Keep deterministic testbenches in `tb/`.
- Let Python generate and validate test programs, ASM and HEX files.
- Do not let the language model directly generate ASM or HEX.
- Run `make check` before synthesis and `make all` before accepting a result.

This keeps language-model edits separate from deterministic verification.
