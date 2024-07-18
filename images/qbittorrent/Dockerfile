ARG GOLANG_VERSION
FROM golang:$GOLANG_VERSION AS builder

ARG TARGETARCH
ARG RELEASE
ARG CHISEL_VERSION

# Install chisel and build rootfs
RUN \
    go install github.com/canonical/chisel/cmd/chisel@${CHISEL_VERSION} \
    && mkdir /rootfs \
    && chisel cut \
        --release ubuntu-24.04 \
        --root /rootfs \
        base-files_base \
        base-files_release-info \
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
