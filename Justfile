set positional-arguments := true

default:
    @just --list --unsorted

build-jetson-base-rootfs *args="":
    -@scripts/build-base-rootfs.sh {{ args }}

build-jetson-stage1-rootfs *args="":
    mkdir -p ./.podman_apt_cache
    -@scripts/build-stage1-rootfs.sh {{ args }}

build-jetson-image *args="":
    -@scripts/build-jetson-image.sh {{ args }}

flash-jetson-image Jetson-image device:
    @scripts/flash-jetson-image.sh {{ Jetson-image }} {{ device }}

clean:
    rm -rf base rootfs .podman_apt_cache
    podman rmi -a -f
    sudo podman rmi -a -f
    sudo rm -rf jetson.img
