FROM ubuntu:24.04

ARG TARGETARCH

RUN \
    case "${TARGETARCH}" in \
        'amd64') \
            export EXTRA_PKGS='intel-media-va-driver-non-free i965-va-driver mesa-va-drivers';; \
        'arm64') \
            export EXTRA_PKGS='libomxil-bellagio0 libomxil-bellagio-bin libraspberrypi0';; \
    esac \
    && apt update \
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
    && userdel ubuntu \
    && useradd \
        --system \
        --no-create-home \
        --uid 1000 \
        nonroot \
    && rm /etc/.pwd.lock \
    && mkdir /config \
    && chown 1000 /config

ENV XDG_CACHE_HOME=/config/cache
USER nonroot
ENTRYPOINT ["/usr/bin/jellyfin", "--ffmpeg=/usr/lib/jellyfin-ffmpeg/ffmpeg", "--webdir=/usr/share/jellyfin/web", "--datadir=/config", "--cachedir=/config/cache"]
