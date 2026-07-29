FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        make \
        python3 \
        iverilog \
        verilator \
        yosys \
        nextpnr-ice40 \
        fpga-icestorm \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

CMD ["bash"]
