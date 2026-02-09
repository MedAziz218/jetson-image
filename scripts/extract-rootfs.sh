#!/usr/bin/env bash

# Check Ubuntu version ($1)
if [ "$1" != "24.04" ] && [ "$1" != "22.04" ] && [ "$1" != "20.04" ]; then
  echo "Error: Unknown version of Ubuntu. Supported: 20.04, 22.04, 24.04"
  exit 1
fi

# Check Stage ID ($2) is not empty
if [ -z "$2" ]; then
  echo "Error: Stage ID (second argument) cannot be empty."
  exit 1
fi

VERSION=$1
STAGE=$2
IMAGE_NAME="jetson-rootfs-$VERSION:$STAGE"

if ! podman image exists "$IMAGE_NAME" && ! podman image exists "localhost/$IMAGE_NAME"; then
  echo "Error: Image '$IMAGE_NAME' not found locally."
  exit 1
fi

# 1. Save image to directory format
podman save --format docker-dir -o "base-$VERSION-$STAGE" "$IMAGE_NAME"

# 2. Create target directory
mkdir -p "rootfs-$VERSION-$STAGE"

# 3. Extract layers
# Note: Using jq to get layers and xargs/tar to extract them
for layer in $(jq -r '.layers[].digest' "base-$VERSION-$STAGE/manifest.json" | awk -F ':' '{print $2}'); do
  tar xf "base-$VERSION-$STAGE/$layer" --directory="rootfs-$VERSION-$STAGE"
done

# 4. Cleanup
rm -rf "rootfs-$VERSION-$STAGE/.bash_history"
rm -rf "base-$VERSION-$STAGE"

echo "Build complete: rootfs-$VERSION-$STAGE directory is ready."