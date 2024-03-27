FROM golang:latest as builder

ARG TARGETARCH
ARG VERSION

# Install chisel and build rootfs with radarr dependencies
RUN \
    go install github.com/canonical/chisel/cmd/chisel@latest \
    && mkdir /rootfs \
    && chisel cut \
        --release ubuntu-24.04 \
        --root /rootfs \
        base-files_base \
        base-files_release-info \
        base-passwd_data \
        ca-certificates_data \
        dotnet-runtime-8.0_libs \
        libsqlite3-0_libs

# Download radarr
RUN \
    case "${TARGETARCH}" in \
        'amd64') export ARCH='x64' ;; \
        'arm64') export ARCH='arm64' ;; \
    esac \
    && curl -L "https://github.com/Radarr/Radarr/releases/download/v${VERSION}/Radarr.master.${VERSION}.linux-core-${ARCH}.tar.gz" \
    | tar xzf - -C / \
    && rm -rf /Radarr/Radarr.Update

FROM scratch
COPY --from=builder /rootfs /
COPY --from=builder /Radarr /Radarr

ENTRYPOINT ["/Radarr/Radarr", "--nobrowser", "--data=/config"]
