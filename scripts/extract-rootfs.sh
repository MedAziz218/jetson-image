#!/usr/bin/env bash
set -e

# 1. Validate inputs
if [[ ! "$1" =~ ^(20.04|22.04|24.04)$ ]]; then
  echo "Error: Supported versions: 20.04, 22.04, 24.04"
  exit 1
fi

if [ -z "$2" ]; then
  echo "Error: You must specify the source stage (e.g., 'base' or 'ros2')"
  exit 1
fi

VERSION=$1
SOURCE_STAGE=$2
SOURCE_IMAGE="jetson-rootfs-$VERSION:$SOURCE_STAGE"
TARGET_IMAGE="jetson-rootfs-$VERSION:extract"
TARGET_DIR="rootfs-$VERSION-$SOURCE_STAGE"
TEMP_SAVE="temp-save-$VERSION"
FILE_VER=${VERSION//./_}


# 2. Build the 'extract' stage using the source stage as an argument
echo "Building extraction layer from $SOURCE_IMAGE..."
podman build \
    --squash-all \
    --arch=arm64 \
    --build-arg SOURCE_IMAGE="$SOURCE_IMAGE" \
    -f "Containerfile.rootfs.${FILE_VER}.extract" \
    -t "$TARGET_IMAGE" .

# 3. Save and Extract
echo "Flattening image layers..."
rm -rf "$TEMP_SAVE" "$TARGET_DIR"
mkdir -p "$TARGET_DIR"
podman save --format docker-dir -o "$TEMP_SAVE" "$TARGET_IMAGE"

# Using jq to extract layers in order
for layer in $(jq -r '.layers[].digest' "$TEMP_SAVE/manifest.json" | awk -F ':' '{print $2}'); do
    echo "Unpacking layer: $layer"
    tar xf "$TEMP_SAVE/$layer" --directory="$TARGET_DIR"
done

# 4. Cleanup
rm -rf "$TEMP_SAVE"
echo "Success! Final rootfs is in: $TARGET_DIR"