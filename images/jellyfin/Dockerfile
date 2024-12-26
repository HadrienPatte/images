ARG UBUNTU_VERSION
FROM ubuntu:$UBUNTU_VERSION AS builder

ARG TARGETARCH
ARG VERSION
ARG CHISEL_VERSION
ARG UBUNTU_VERSION

RUN \
    # Install chisel and dependencies \
    apt update \
    && apt install --yes \
        # Needed to download chisel \
        curl \
        # Needed to get the jellyfin-ffmpeg version \
        jq \
    && curl \
        --location \
        https://github.com/canonical/chisel/releases/download/${CHISEL_VERSION}/chisel_${CHISEL_VERSION}_linux_${TARGETARCH}.tar.gz \
            | tar xzf - --directory /usr/bin \
    && mkdir /rootfs \
    \
    # Install jellyfin \
    && mkdir /jellyfin \
    # Download and extract jellyfin-web \
    && curl \
        --location \
        --remote-name \
        https://repo.jellyfin.org/files/server/ubuntu/stable/v${VERSION}/${TARGETARCH}/jellyfin-web_${VERSION}+ubu2404_all.deb \
    && dpkg --extract jellyfin-web_*.deb /jellyfin \
    \
    # Download and extract jellyfin-server \
    && curl \
        --location \
        --remote-name \
        https://repo.jellyfin.org/files/server/ubuntu/stable/v${VERSION}/${TARGETARCH}/jellyfin-server_${VERSION}+ubu2404_${TARGETARCH}.deb \
    && dpkg --extract jellyfin-server_*.deb /jellyfin \
    \
    # Download and extract jellyfin-ffmpeg \
    && FFMPEG_TAG=$(curl -s "https://api.github.com/repos/Jellyfin/jellyfin-ffmpeg/releases/latest" \
        | jq -r '.tag_name') \
    && FFMPEG_VERSION=${FFMPEG_TAG#v} \
    && curl \
        --location \
        --remote-name \
        https://repo.jellyfin.org/files/ffmpeg/ubuntu/7.x/${FFMPEG_VERSION}/${TARGETARCH}/jellyfin-ffmpeg7_${FFMPEG_VERSION}-noble_${TARGETARCH}.deb \
    && dpkg --extract jellyfin-ffmpeg7_*.deb /jellyfin \
    \
    # Prepare jellyfin-ffmpeg dependencies list \
    && dpkg --control jellyfin-ffmpeg7_*.deb \
    && export FFMPEG_DEPS=$(sed '/^Depends:/!d; s/Depends:\s//; s/\s([^)]*)//g; s/,\s/\n/g' DEBIAN/control \
        | sed 's/\s|.*$//g; s/$/_libs/' \
        | sort --unique) \
    \
    && rm \
        /jellyfin/usr/share/doc/*/changelog*.gz \
    \
    # Build rootfs with jellyfin dependencies \
    && chisel cut \
        --release ubuntu-${UBUNTU_VERSION} \
        --root /rootfs \
        # Base filesystem \
        base-files_base \
        base-files_chisel \
        ca-certificates_data \
        # jellyfin dependencies \
        dotnet-runtime-8.0_libs \
        libsqlite3-0_libs \
        # jellyfin-ffmpeg dependencies \
        ${FFMPEG_DEPS} \
    && useradd \
        --root /rootfs \
        --system \
        --no-create-home \
        --uid 1000 \
        nonroot \
    && rm /rootfs/etc/.pwd.lock \
    && mkdir /rootfs/config \
    && chown 1000 /rootfs/config

FROM scratch
COPY --from=builder /rootfs /
COPY --from=builder /jellyfin/usr /usr

USER nonroot
ENV XDG_CACHE_HOME=/config/cache
ENTRYPOINT ["/usr/lib/jellyfin/bin/jellyfin", "--ffmpeg=/usr/lib/jellyfin-ffmpeg/ffmpeg", "--webdir=/usr/share/jellyfin/web", "--datadir=/config"]
