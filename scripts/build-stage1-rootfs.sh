#!/usr/bin/env bash

# Author Badr @pythops

set -e

echo "Building stage1 rootfs"

if [ "$1" != "24.04" ] && [ "$1" != "22.04" ] && [ "$1" != "20.04" ]; then
  echo "Error: Unknow version of ubuntu. The supported versions are: 20.04, 22.04, 24.04"
  exit 1
fi

mkdir -p $(pwd)/.podman_apt_cache/$1
EXTRA_ARGS="-v $(pwd)/.podman_apt_cache/$1:/var/cache/apt"
NJOBS=8
echo "EXTRA_ARGS=${EXTRA_ARGS}"
case $1 in
"20.04")
  podman build \
    --squash-all \
    --jobs=${NJOBS} \
    --arch=arm64 \
    --network=host \
    -f Containerfile.rootfs.20_04.stage1 \
    -t jetson-rootfs-$1:stage1
  ;;

"22.04")
  podman build \
    --squash-all \
    --jobs=${NJOBS} \
    --arch=arm64 \
    --network=host \
    -f Containerfile.rootfs.22_04.stage1 \
    -t jetson-rootfs-$1:stage1
  ;;

"24.04")
  podman build \
    --squash-all \
    --jobs=${NJOBS} \
    --arch=arm64 \
    --network=host \
    -f Containerfile.rootfs.24_04.stage1 \
    -t jetson-rootfs-$1:stage1
  ;;

*)
  exit 1
  ;;
esac
echo "podmant image 'jetson-rootfs-$1:stage1' created"

