ARG GOLANG_VERSION
FROM golang:$GOLANG_VERSION as builder

ARG TARGETARCH
ARG VERSION
ARG CHISEL_VERSION

# Install chisel and build rootfs with prowlarr dependencies
RUN \
    go install github.com/canonical/chisel/cmd/chisel@${CHISEL_VERSION} \
    && mkdir /rootfs \
    && chisel cut \
        --release ubuntu-24.04 \
        --root /rootfs \
        base-files_base \
        base-files_release-info \
        ca-certificates_data \
        dotnet-runtime-8.0_libs \
        libsqlite3-0_libs \
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
