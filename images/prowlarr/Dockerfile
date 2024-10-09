ARG UBUNTU_VERSION
FROM ubuntu:$UBUNTU_VERSION AS builder

ARG TARGETARCH
ARG VERSION
ARG CHISEL_VERSION
ARG UBUNTU_VERSION

# Install chisel and build rootfs with prowlarr dependencies
RUN \
    apt update \
    && apt install file curl --yes \
    && curl -L https://github.com/canonical/chisel/releases/download/${CHISEL_VERSION}/chisel_${CHISEL_VERSION}_linux_${TARGETARCH}.tar.gz \
        | tar xzf - -C /usr/bin \
    && curl -LO --output-dir /usr/bin https://raw.githubusercontent.com/canonical/rocks-toolbox/main/chisel-wrapper \
    && chmod +x /usr/bin/chisel-wrapper \
    && mkdir -p /rootfs/var/lib/dpkg \
    && chisel-wrapper --generate-dpkg-status /rootfs/var/lib/dpkg/status -- \
        --release ubuntu-${UBUNTU_VERSION} \
        --root /rootfs \
        base-files_base \
        ca-certificates_data \
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

# Download prowlarr
RUN \
    case "${TARGETARCH}" in \
        'amd64') export ARCH='x64' ;; \
        'arm64') export ARCH='arm64' ;; \
    esac \
    && curl -L "https://github.com/Prowlarr/Prowlarr/releases/download/v${VERSION}/Prowlarr.master.${VERSION}.linux-core-${ARCH}.tar.gz" \
        | tar xzf - -C / \
    && rm -rf /Prowlarr/Prowlarr.Update

FROM scratch
COPY --from=builder /rootfs /
COPY --from=builder /Prowlarr /Prowlarr

USER nonroot
ENTRYPOINT ["/Prowlarr/Prowlarr", "--nobrowser", "--data=/config"]
