# Build variant image on top of the shared base image (Dockerfile-base).
ARG BASE_IMAGE=ghcr.io/riptidewave93/arm64-valheim:base
FROM ${BASE_IMAGE}

# BOX64_PACKAGE selects the box64 build for the target platform
ARG BOX64_PACKAGE=box64
RUN apt-get update \
    && apt-get install -y \
        ${BOX64_PACKAGE} \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy scripts
WORKDIR /root
COPY src/bootstrap src/common /usr/local/lib/valheim/
COPY src/valheim-backup src/valheim-updater /usr/local/bin/

# CPU_AFFINITY sets the default cores the server is pinned to, for SoCs with
# fast and slow cores (e.g. 4-7 for the RK3588 A76 cores). Unset by default.
ARG CPU_AFFINITY=
ENV CPU_AFFINITY=${CPU_AFFINITY}

# Required ports for the Valheim server
EXPOSE 2456-2458/tcp 2456-2458/udp

# tini forwards signals to bootstrap, which forwards them to the server
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/bin/bash", "/usr/local/lib/valheim/bootstrap"]
