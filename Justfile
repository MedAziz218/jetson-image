set positional-arguments := true

default:
    @just --list --unsorted

build-rootfs version stage:
    -@scripts/build-rootfs.sh  {{version}} {{stage}}
    
extract-rootfs version stage:
    -@scripts/extract-rootfs.sh  {{version}} {{stage}}

 
build-jetson-image *args="":
    -@scripts/build-jetson-image.sh {{ args }}

# flash-jetson-image Jetson-image device:
#     @scripts/flash-jetson-image.sh {{ Jetson-image }} {{ device }}

clean:
    rm -rf base rootfs .podman_apt_cache
    podman rmi -a -f
    sudo podman rmi -a -f
    sudo rm -rf jetson.img
