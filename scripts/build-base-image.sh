#!/usr/bin/env bash

set -e -o xtrace

# Load command-line arguments
if [[ $# != 2 ]]; then
  printf 'Usage: %s RELEASE_IMAGE PUSH_TO_GITLAB\n' "$0" >&2
  exit 1
fi

docker_build_command="docker build"
buildx_driver="$(docker buildx inspect | sed -n 's/^Driver:\s*\(.*\)$/\1/p')"
if [[ "$buildx_driver" == "docker-container" ]]; then
  echo "This runner does seem to have buildx support. Trying to build multi-architecture images."
  docker_build_command="docker buildx build --platform linux/arm/v7,linux/arm64/v8,linux/amd64"
fi

RELEASE_IMAGE="$1"
PUSH_TO_GITLAB="$2"

# Construct image tag
GL_PUSH_TAG="$RELEASE_IMAGE:base"

# Build and tag image
$docker_build_command -f Dockerfile.base --tag "$GL_PUSH_TAG" .

# Push image
if [[ -n "$PUSH_TO_GITLAB" ]]; then
  docker push "$GL_PUSH_TAG"
fi

# Untag build images, so that the runner can prune them
docker rmi --no-prune "$GL_PUSH_TAG" || true
