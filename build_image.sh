#!/bin/bash

IMAGE="ghcr.io/sartais/php_grpc"

# Ensure we are using a multi-arch builder
if ! docker buildx inspect multiarch >/dev/null 2>&1; then
  docker buildx create --name multiarch --driver docker-container --use
else
  docker buildx use multiarch
fi

docker buildx inspect --bootstrap >/dev/null 2>&1

# Prompt for the PHP tag
read -rp "Enter PHP tag for the debian base PHP image (e.g. 8.4): " TAG_NAME

# Ask if the image should also be tagged as "latest" (default: no)
read -rp "Do you want to also tag this image as 'latest'? (y/N) " TAG_LATEST

# Prepare optional extra tag(s)
EXTRA_TAGS=()
if [[ "$TAG_LATEST" =~ ^[Yy]$ ]]; then
  EXTRA_TAGS+=(-t "${IMAGE}:latest")
fi

echo "Building and pushing multi-arch image for ${IMAGE}:${TAG_NAME} ..."

docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --build-arg PHP_TAG="${TAG_NAME}" \
  -t "${IMAGE}:${TAG_NAME}" \
  "${EXTRA_TAGS[@]}" \
  --push \
  .

echo "Done."
