#!/usr/bin/env bash
set -euo pipefail

IMAGE=$1

echo "Building $IMAGE"

RELEASE=$(./images/${IMAGE}/latest.sh)
VERSION=${RELEASE%%_*}
VERSION=${VERSION#release-}
VERSION=${VERSION#v}

if [[ -z $VERSION ]]; then
    echo "Failed to retrieve latest version for $IMAGE"
else
    docker buildx build \
        --push \
        --platform linux/amd64,linux/arm64 \
        --tag ghcr.io/${GITHUB_REPOSITORY_OWNER,,}/${IMAGE}:${VERSION} \
        --tag ghcr.io/${GITHUB_REPOSITORY_OWNER,,}/${IMAGE}:latest \
        --build-arg RELEASE=${RELEASE} \
        --build-arg VERSION=${VERSION} \
        --build-arg GOLANG_VERSION="1.20" \
        --build-arg CHISEL_VERSION="v0.9.1" \
        --label "org.opencontainers.image.authors=${GITHUB_REPOSITORY_OWNER}" \
        --label "org.opencontainers.image.source=${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}" \
        --label "org.opencontainers.image.version=${VERSION}" \
        --label "org.opencontainers.image.vendor=${GITHUB_REPOSITORY_OWNER}" \
        --label "org.opencontainers.image.title=${IMAGE}" \
        - < images/${IMAGE}/Dockerfile
fi
