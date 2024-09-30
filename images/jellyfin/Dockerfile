ARG UBUNTU_VERSION
FROM ubuntu:$UBUNTU_VERSION AS builder

ARG TARGETARCH
ARG VERSION
ARG CHISEL_VERSION

# Install chisel and build rootfs with jellyfin dependencies
RUN \
    apt update \
    && apt install --yes \
        # Needed to download chisel and chisel-wrapper \
        curl \
        # chisel-wrapper dependency \
        file \
        # Needed to clone a custom chisel-releases \
        git \
        # Needed to get the jellyfin-ffmpeg version \
        jq \
    && curl \
        --location \
        https://github.com/canonical/chisel/releases/download/${CHISEL_VERSION}/chisel_${CHISEL_VERSION}_linux_${TARGETARCH}.tar.gz \
            | tar xzf - --directory /usr/bin \
    && curl \
        --location \
        --remote-name \
        --output-dir /usr/bin \
        https://raw.githubusercontent.com/canonical/rocks-toolbox/main/chisel-wrapper \
    && chmod +x /usr/bin/chisel-wrapper \
    && mkdir -p /rootfs/var/lib/dpkg \
    && git clone --branch jellyfin https://github.com/HadrienPatte/chisel-releases.git \
    && case "${TARGETARCH}" in \
        'amd64') \
            export FFMPEG_DEPS="\
                libbluray2_libs \
                libbz2-1.0_libs \
                libc6_libs \
                libelf1t64_libs \
                libexpat1_libs \
                libgcc-s1_libs \
                libgmp10_libs \
                libgnutls30t64_libs \
                libllvm17t64_libs \
                libmp3lame0_libs \
                libopenmpt0t64_libs \
                libopus0_libs \
                libpciaccess0_libs \
                libstdc++6_libs \
                libtheora0_libs \
                libudev1_libs \
                libvorbis0a_libs \
                libvorbisenc2_libs \
                libvpx9_libs \
                libwebp7_libs \
                libwebpmux3_libs \
                libx11-xcb1_libs \
                libx264-164_libs \
                libx265-199_libs \
                libxcb-dri2-0_libs \
                libxcb-dri3-0_libs \
                libxcb-present0_libs \
                libxcb-randr0_libs \
                libxcb-shm0_libs \
                libxcb-sync1_libs \
                libxcb-xfixes0_libs \
                libxcb1_libs \
                libxshmfence1_libs \
                libzstd1_libs \
                libzvbi0t64_libs \
                ocl-icd-libopencl1_libs \
            " \
        ;; \
        'arm64') \
            export FFMPEG_DEPS="\
                libbluray2_libs \
                libbz2-1.0_libs \
                libc6_libs \
                libdrm2_libs \
                libgcc-s1_libs \
                libgmp10_libs \
                libgnutls30t64_libs \
                libmp3lame0_libs \
                libopenmpt0t64_libs \
                libopus0_libs \
                libstdc++6_libs \
                libtheora0_libs \
                libvorbis0a_libs \
                libvorbisenc2_libs \
                libvpx9_libs \
                libwebp7_libs \
                libwebpmux3_libs \
                libx264-164_libs \
                libx265-199_libs \
                libzvbi0t64_libs \
                ocl-icd-libopencl1_libs \
            " \
        ;; \
    esac \
    && chisel-wrapper --generate-dpkg-status /rootfs/var/lib/dpkg/status -- \
        --release ./chisel-releases \
        --root /rootfs \
        # Base filesystem \
        base-files_base \
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

# Install jellyfin
RUN \
    mkdir /jellyfin \
    && FFMPEG_TAG=$(curl -s "https://api.github.com/repos/Jellyfin/jellyfin-ffmpeg/releases/latest" | jq -r '.tag_name') \
    && FFMPEG_VERSION=${FFMPEG_TAG#v} \
    && curl \
        --location \
        --remote-name \
        https://repo.jellyfin.org/files/ffmpeg/ubuntu/7.x/${FFMPEG_VERSION}/${TARGETARCH}/jellyfin-ffmpeg7_${FFMPEG_VERSION}-noble_${TARGETARCH}.deb \
    && dpkg --extract jellyfin-ffmpeg7_*.deb /jellyfin \
    \
    && curl \
        --location \
        --remote-name \
        https://repo.jellyfin.org/files/server/ubuntu/stable/v${VERSION}/${TARGETARCH}/jellyfin-web_${VERSION}+ubu2404_all.deb \
    && dpkg --extract jellyfin-web_*.deb /jellyfin \
    \
    && curl \
        --location \
        --remote-name \
        https://repo.jellyfin.org/files/server/ubuntu/stable/v${VERSION}/${TARGETARCH}/jellyfin-server_${VERSION}+ubu2404_${TARGETARCH}.deb \
    && dpkg --extract jellyfin-server_*.deb /jellyfin \
    \
    && rm \
        /jellyfin/usr/share/doc/*/changelog*.gz

FROM scratch
COPY --from=builder /rootfs /
COPY --from=builder /jellyfin/usr /usr

USER nonroot
ENV XDG_CACHE_HOME=/config/cache
ENTRYPOINT ["/usr/lib/jellyfin/bin/jellyfin", "--ffmpeg=/usr/lib/jellyfin-ffmpeg/ffmpeg", "--webdir=/usr/share/jellyfin/web", "--datadir=/config"]

