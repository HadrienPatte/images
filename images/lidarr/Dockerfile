ARG UBUNTU_VERSION
FROM ubuntu:$UBUNTU_VERSION AS builder

ARG TARGETARCH
ARG VERSION
ARG CHISEL_VERSION
ARG UBUNTU_VERSION

# Install chisel and build rootfs with lidarr dependencies
RUN \
    apt update \
    && apt install --yes \
        # Needed to download chisel and chisel-wrapper \
        curl \
        # chisel-wrapper dependency \
        file \
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
    && chisel-wrapper --generate-dpkg-status /rootfs/var/lib/dpkg/status -- \
        --release ubuntu-${UBUNTU_VERSION} \
        --root /rootfs \
        # Base filesystem \
        base-files_base \
        ca-certificates_data \
        # lidarr dependencies \
        libicu74_libs \
        libsqlite3-0_libs \
        libssl3t64_libs \
        zlib1g_libs \
    && useradd \
        --root /rootfs \
        --system \
        --no-create-home \
        --uid 1000 \
        nonroot \
    && rm /rootfs/etc/.pwd.lock \
    && mkdir /rootfs/config \
    && chown 1000 /rootfs/config

# Download lidarr
RUN \
    case "${TARGETARCH}" in \
        'amd64') export ARCH='x64' ;; \
        'arm64') export ARCH='arm64' ;; \
    esac \
    && curl --location "https://github.com/Lidarr/Lidarr/releases/download/v${VERSION}/Lidarr.master.${VERSION}.linux-core-${ARCH}.tar.gz" \
        | tar xzf - -C / \
    && rm -r /Lidarr/Lidarr.Update

FROM scratch
COPY --from=builder /rootfs /
COPY --from=builder /Lidarr /Lidarr

USER nonroot
ENTRYPOINT ["/Lidarr/Lidarr", "--nobrowser", "--data=/config"]
