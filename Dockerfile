FROM debian:bullseye-slim

LABEL maintainer="Evirth"

# Install tools required for the project
RUN dpkg --add-architecture armhf
RUN apt update && apt full-upgrade -y
RUN apt install -y \
    gcc-arm-linux-gnueabihf \
    curl \
    libsdl2-2.0-0 \
    wget \
    gpg
RUN apt install -y \
    libc6:armhf \
    libncurses5:armhf \
    libstdc++6:armhf

# Install the box86 to emulate x86 platform (for steamcmd client)
WORKDIR /root/box86
RUN wget https://itai-nelken.github.io/weekly-box86-debs/debian/box86.list -O /etc/apt/sources.list.d/box86.list
RUN wget -qO- https://itai-nelken.github.io/weekly-box86-debs/debian/KEY.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/box86-debs-archive-keyring.gpg
RUN apt update && apt install box86:armhf=0.3.0+20230312.a43884f-1 -y
# using v0.3.0 because steamcmd crashes on latest (v0.3.2)

# Install steamcmd and download the valheim server
WORKDIR /root/steamcmd
RUN curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -
ENV DEBUGGER "/usr/local/bin/box86"
RUN ./steamcmd.sh +@sSteamCmdForcePlatformType linux +force_install_dir /root/valheim_server +login anonymous +app_update 896660 validate +quit

# Box64 installation
WORKDIR /root/box64
RUN wget https://ryanfortner.github.io/box64-debs/box64.list -O /etc/apt/sources.list.d/box64.list
RUN wget -qO- https://ryanfortner.github.io/box64-debs/KEY.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/box64-debs-archive-keyring.gpg
RUN apt update && apt install box64-arm64 -y

# Clean the image
RUN apt purge -y wget gpg
RUN rm -r /root/box86
RUN rm -r /root/box64

# Specific for run Valheim server
EXPOSE 2456-2457/udp
WORKDIR /root
COPY bootstrap .
CMD ["/bin/bash", "/root/bootstrap"]