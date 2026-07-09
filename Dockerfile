FROM debian:bookworm-slim

LABEL maintainer="2ddevworks"
LABEL description="Empyrion: Galactic Survival Dedicated Server"

ENV DEBIAN_FRONTEND=noninteractive
ENV DEDICATED_YML=""

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests \
        ca-certificates \
        lib32gcc-s1 \
        locales \
        net-tools \
        tar \
        wget \
        wine64 \
        xvfb \
    && sed -i 's/# en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen \
    && locale-gen \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Install SteamCMD
RUN mkdir -p /steamcmd && \
    wget -qO- https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar xz -C /steamcmd && \
    /steamcmd/steamcmd.sh +quit || true

# Create directories
RUN mkdir -p /empyrion-server /scripts

# Copy entrypoint
COPY entrypoint.sh /scripts/entrypoint.sh
RUN chmod +x /scripts/entrypoint.sh

EXPOSE 30000-30003/udp
VOLUME ["/empyrion-server"]
ENTRYPOINT ["/scripts/entrypoint.sh"]
