FROM ubuntu:24.04

ARG TARGETARCH

RUN \
    apt update \
    && apt install -y \
        gnupg2 \
        curl \
        ca-certificates \
    && curl -fsSL "https://repo.jellyfin.org/ubuntu/jellyfin_team.gpg.key" | apt-key add - \
    && echo "deb [arch=$TARGETARCH] https://repo.jellyfin.org/ubuntu noble main" > /etc/apt/sources.list.d/jellyfin.list \
    && apt update \
    && apt install -y \
        jellyfin-server \
        jellyfin-web \
        jellyfin-ffmpeg6 \
        libsqlite3-0 \
    && apt upgrade -y \
    && export SUDO_FORCE_REMOVE=yes \
    && apt remove -y \
        gnupg2 \
        curl \
    && apt purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && apt autoremove -y \
    && apt clean \
    && rm -rf \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/tmp/ \
        /etc/apt/sources.list.d/jellyfin.list \
        /etc/apt/trusted.gpg \
        /etc/systemd/system/jellyfin.service.d/jellyfin.service.conf \
    && userdel ubuntu \
    && useradd \
        --system \
        --no-create-home \
        --uid 1000 \
        nonroot \
    && rm /etc/adduser.conf \
    && mkdir /config \
    && chown 1000 /config

ENV XDG_CACHE_HOME=/config/cache
USER nonroot
ENTRYPOINT ["/usr/bin/jellyfin", "--ffmpeg=/usr/lib/jellyfin-ffmpeg/ffmpeg", "--webdir=/usr/share/jellyfin/web", "--datadir=/config"]
