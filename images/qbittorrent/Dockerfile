ARG UBUNTU_VERSION
FROM ubuntu:$UBUNTU_VERSION AS builder

ARG TARGETARCH
ARG RELEASE
ARG CHISEL_VERSION
ARG UBUNTU_VERSION

# Install chisel and build rootfs
RUN \
    apt update \
    && apt install --yes \
        # Needed to download chisel \
        curl \
    && curl \
        --location \
        https://github.com/canonical/chisel/releases/download/${CHISEL_VERSION}/chisel_${CHISEL_VERSION}_linux_${TARGETARCH}.tar.gz \
            | tar xzf - --directory /usr/bin \
    && mkdir /rootfs \
    && chisel cut \
        --release ubuntu-${UBUNTU_VERSION} \
        --root /rootfs \
        # Base filesystem \
        base-files_base \
        base-files_chisel \
        ca-certificates_data \
    && useradd \
        --root /rootfs \
        --system \
        --no-create-home \
        --uid 1000 \
        nonroot \
    && rm /rootfs/etc/.pwd.lock \
    && mkdir -p /rootfs/config/qBittorrent/config \
    && chown --recursive 1000 /rootfs/config

# Download qbittorrent
RUN \
    case "${TARGETARCH}" in \
        'amd64') export ARCH='x86_64' ;; \
        'arm64') export ARCH='aarch64' ;; \
    esac \
    && curl \
        --location \
        --output /qbittorrent-nox \
        "https://github.com/userdocs/qbittorrent-nox-static/releases/download/${RELEASE}/${ARCH}-qbittorrent-nox" \
    && chmod +x /qbittorrent-nox

FROM scratch
COPY --from=builder /rootfs /
COPY --from=builder /qbittorrent-nox /bin/qbittorrent-nox

USER nonroot
ENTRYPOINT ["/bin/qbittorrent-nox", "--profile=/config"]
