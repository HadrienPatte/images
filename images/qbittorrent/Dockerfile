ARG GOLANG_VERSION
FROM golang:$GOLANG_VERSION AS builder

ARG TARGETARCH
ARG RELEASE
ARG CHISEL_VERSION

# Install chisel and build rootfs
RUN \
    go install github.com/canonical/chisel/cmd/chisel@${CHISEL_VERSION} \
    && curl -LO https://raw.githubusercontent.com/canonical/rocks-toolbox/main/chisel-wrapper \
    && chmod +x ./chisel-wrapper \
    && apt update \
    && apt install file --yes \
    && mkdir -p /rootfs/var/lib/dpkg \
    && ./chisel-wrapper --generate-dpkg-status /rootfs/var/lib/dpkg/status -- \
        --release ubuntu-24.04 \
        --root /rootfs \
        base-files_base \
        ca-certificates_data \
    && useradd \
        --root /rootfs \
        --system \
        --no-create-home \
        --uid 1000 \
        nonroot \
    && rm /rootfs/etc/.pwd.lock \
    && mkdir -p /rootfs/config/qBittorrent/config \
    && chown -R 1000 /rootfs/config

# Download qbittorrent
RUN \
    case "${TARGETARCH}" in \
        'amd64') export ARCH='x86_64' ;; \
        'arm64') export ARCH='aarch64' ;; \
    esac \
    && curl -L -o /qbittorrent-nox "https://github.com/userdocs/qbittorrent-nox-static/releases/download/${RELEASE}/${ARCH}-qbittorrent-nox" \
    && chmod +x /qbittorrent-nox

FROM scratch
COPY --from=builder /rootfs /
COPY --from=builder /qbittorrent-nox /bin/qbittorrent-nox

USER nonroot
ENTRYPOINT ["/bin/qbittorrent-nox", "--profile=/config"]
