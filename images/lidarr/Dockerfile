ARG UBUNTU_VERSION
FROM ubuntu:$UBUNTU_VERSION AS builder

ARG TARGETARCH
ARG VERSION
ARG CHISEL_VERSION
ARG UBUNTU_VERSION

# Install chisel and build rootfs with lidarr dependencies
RUN --mount=type=secret,id=UBUNTU_PRO_CREDS,target=/etc/apt/auth.conf.d/90ubuntu-advantage \
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
