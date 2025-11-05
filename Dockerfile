# ============================================================================
# Dockerfile
# ============================================================================

# Base image Ubuntu 22.04
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

################################################################################
# SECTION 1: Common Dependencies
################################################################################
RUN echo "=== [SECTION 1] Installing common dependencies ===" && \
    apt-get update && \
    apt-get install -y \
    wget \
    git \
    curl \
    ca-certificates \
    make \
    build-essential \
    python3 \
    python3-pip

################################################################################
# SECTION 2: ModelSim (Simulation)
################################################################################
RUN echo "=== [SECTION 2] Installing ModelSim prerequisites ===" && \
    dpkg --add-architecture i386 && apt-get update && \
    apt-get install -y \
    libc6:i386 \
    libxtst6:i386 \
    libncurses5:i386 \
    libxft2:i386 \
    libstdc++6:i386 \
    libc6-dev-i386 \
    lib32z1 \
    libqt5xml5

WORKDIR /tmp
RUN echo "=== [SECTION 2] Downloading and installing ModelSim ===" && \
    wget -q https://download.altera.com/akdlm/software/acdsinst/20.1std/711/ib_installers/ModelSimSetup-20.1.0.711-linux.run && \
    chmod +x ModelSimSetup-20.1.0.711-linux.run && \
    ./ModelSimSetup-20.1.0.711-linux.run \
      --mode unattended \
      --accept_eula 1 \
      --installdir /opt/ModelSim-20.1.0 \
      --unattendedmodeui none && \
    rm -f ModelSimSetup-20.1.0.711-linux.run

ENV PATH="/opt/ModelSim-20.1.0/modelsim_ase/bin:${PATH}"

################################################################################
# SECTION 3: Yosys and OpenSTA (Synthesis)
################################################################################
RUN echo "=== [SECTION 3] Installing Yosys ===" && \
    apt-get install -y yosys opensta

################################################################################
# SECTION 4: GTKWave (Waveform Viewer)
################################################################################
RUN echo "=== [SECTION 4] Installing GTKWave ===" && \
    apt-get install -y gtkwave

################################################################################
# SECTION 5: Final Steps
################################################################################
WORKDIR /workspace
VOLUME /workspace

RUN echo "=== [SECTION 5] Clean Cache ===" && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN echo "=== [SECTION 5] Setting up user environment ===" && \
cat >> /root/.bashrc <<'EOF'
# Prompt customization
export PS1="\[\033[01;32m\]eda-env\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
echo "EDA environment ready"
EOF

CMD ["/bin/bash"]
