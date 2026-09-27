# Build variant image on top of the shared base image (Dockerfile-base).
# BOX64_PACKAGE selects the box64 build for the target platform:
#   arm64      - box64
#   pi4        - box64-rpi4arm64
#   pi5        - box64-rpi5arm64ps16k
#   rk3588     - box64-rk3588
#   tegra-t194 - box64-tegra-t194
ARG BASE_IMAGE=ghcr.io/riptidewave93/arm64-valheim:base
FROM ${BASE_IMAGE}

ARG BOX64_PACKAGE=box64
RUN apt-get update \
    && apt-get install -y \
        ${BOX64_PACKAGE} \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Specific for run Valheim server
EXPOSE 2456-2458/tcp 2456-2458/udp
WORKDIR /root
COPY src/bootstrap .
COPY src/valheim-backup /usr/local/bin/
CMD ["/bin/bash", "/root/bootstrap"]
