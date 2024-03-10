FROM debian:bookworm-slim

# Install tools required for the project
RUN dpkg --add-architecture armhf \
    && apt update && apt full-upgrade -y \
    && apt install -y \
        locales \
        gcc-arm-linux-gnueabihf \
        curl \
        libsdl2-2.0-0 \
        wget \
        gpg \
    && apt install -y \
        libc6:armhf \
        libncurses5:armhf \
        libstdc++6:armhf \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen

# Set our locale
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en 
ENV LC_ALL en_US.UTF-8

# Install box86 and box64, and cleanup
RUN wget https://itai-nelken.github.io/weekly-box86-debs/debian/box86.list -O /etc/apt/sources.list.d/box86.list \
    && wget -qO- https://itai-nelken.github.io/weekly-box86-debs/debian/KEY.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/box86-debs-archive-keyring.gpg \
    && wget https://ryanfortner.github.io/box64-debs/box64.list -O /etc/apt/sources.list.d/box64.list \
    && wget -qO- https://ryanfortner.github.io/box64-debs/KEY.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/box64-debs-archive-keyring.gpg \
    && apt update \
    && apt install -y \
        box64-tegra-t194 \
        box86 \
    && apt purge -y wget gpg \
    && apt autoremove -y \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

# Specific for run Valheim server
EXPOSE 2456-2457/udp
WORKDIR /root
COPY src/bootstrap .
CMD ["/bin/bash", "/root/bootstrap"]
