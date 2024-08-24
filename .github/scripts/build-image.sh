#!/usr/bin/env bash
set -euo pipefail

IMAGE=$1

echo "Building $IMAGE"

DEFAULT_GOLANG_VERSION="1.21"
DEFAULT_CHISEL_VERSION="v0.10.0"

REPOSITORY=$(jq -r '.repository' ./images/${IMAGE}/metadata.json)
RELEASE_METADATA=$(curl -s "https://api.github.com/repos/${REPOSITORY}/releases/latest")
SOURCE_DATE_EPOCH=$(date +%s -d $(echo ${RELEASE_METADATA} | jq -r '.created_at'))
RELEASE=$(echo ${RELEASE_METADATA} | jq -r '.tag_name')
VERSION=${RELEASE%%_*}
VERSION=${VERSION#release-}
VERSION=${VERSION#v}

echo "Version $VERSION"
if [[ -z $VERSION ]]; then
    echo "Failed to retrieve latest version for $IMAGE"
else
    docker buildx build \
        --platform linux/amd64,linux/arm64 \
        --provenance=false \
        --tag ghcr.io/${GITHUB_REPOSITORY_OWNER,,}/${IMAGE}:${VERSION} \
        --tag ghcr.io/${GITHUB_REPOSITORY_OWNER,,}/${IMAGE}:latest \
        --build-arg RELEASE=${RELEASE} \
        --build-arg VERSION=${VERSION} \
        --build-arg GOLANG_VERSION=${DEFAULT_GOLANG_VERSION} \
        --build-arg CHISEL_VERSION=${DEFAULT_CHISEL_VERSION} \
        --build-arg SOURCE_DATE_EPOCH=${SOURCE_DATE_EPOCH} \
        --label "org.opencontainers.image.authors=${GITHUB_REPOSITORY_OWNER}" \
        --label "org.opencontainers.image.source=${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}" \
        --label "org.opencontainers.image.version=${VERSION}" \
        --label "org.opencontainers.image.vendor=${GITHUB_REPOSITORY_OWNER}" \
        --label "org.opencontainers.image.title=${IMAGE}" \
        --output type=registry,name=ghcr.io/${GITHUB_REPOSITORY_OWNER,,}/${IMAGE}:${VERSION},rewrite-timestamp=true \
        --output type=registry,name=ghcr.io/${GITHUB_REPOSITORY_OWNER,,}/${IMAGE}:latest,rewrite-timestamp=true \
        - < images/${IMAGE}/Dockerfile
fi
