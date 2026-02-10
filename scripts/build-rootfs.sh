#!/usr/bin/env bash
set -e

VERSION=$1
STAGE=$2

# Validation
if [[ ! "$VERSION" =~ ^(20.04|22.04|24.04)$ ]]; then
  echo "Unsupported Ubuntu version: $VERSION"
  exit 1
fi

# Check Stage ID ($2) is not empty
if [ -z "$2" ]; then
  echo "Stage ID required"
  exit 1
fi

# Convert 22.04 to 22_04 for the filename
FILE_VER=${VERSION//./_}

echo "Building ubuntu ${VERSION} ${STAGE} rootfs"
if [ -z "$NJOBS" ]; then
    NJOBS=8
fi
podman build \
    --layers \
    --jobs=$NJOBS \
    --arch=arm64 \
    --network=host \
    -f Containerfile.rootfs.${FILE_VER}.${STAGE} \
    -t jetson-rootfs-${VERSION}:${STAGE} .

echo "podmant image 'jetson-rootfs-${VERSION}:${STAGE}' created"