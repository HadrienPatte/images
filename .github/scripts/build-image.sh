#!/usr/bin/env bash
set -euo pipefail

DEFAULT_UBUNTU_VERSION="24.04"
DEFAULT_CHISEL_VERSION="v1.2.0"

if [[ -z $VERSION ]]; then
    echo "Failed to retrieve latest version for $IMAGE"
else
    echo "Building ${IMAGE}:${VERSION}"
    docker buildx build \
        --platform "${PLATFORM}" \
        --provenance=false \
        --build-arg RELEASE=${RELEASE} \
        --build-arg VERSION=${VERSION} \
        --build-arg UBUNTU_VERSION=${DEFAULT_UBUNTU_VERSION} \
        --build-arg CHISEL_VERSION=${DEFAULT_CHISEL_VERSION} \
        --build-arg SOURCE_DATE_EPOCH=${SOURCE_DATE_EPOCH} \
        --secret id=UBUNTU_PRO_CREDS \
        --build-arg "BUILDKIT_DOCKERFILE_CHECK=skip=InvalidDefaultArgInFrom;error=true" \
        --label "org.opencontainers.image.authors=${GITHUB_REPOSITORY_OWNER}" \
        --label "org.opencontainers.image.source=${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}" \
        --label "org.opencontainers.image.version=${VERSION}" \
        --label "org.opencontainers.image.vendor=${GITHUB_REPOSITORY_OWNER}" \
        --label "org.opencontainers.image.title=${IMAGE}" \
        --output "type=image,name=ghcr.io/${GITHUB_REPOSITORY_OWNER,,}/${IMAGE}-test,rewrite-timestamp=true,push-by-digest=true" \
        - < images/${IMAGE}/Dockerfile
        #--output "type=registry,name=ghcr.io/${GITHUB_REPOSITORY_OWNER,,}/${IMAGE}:latest,rewrite-timestamp=true" \
fi
