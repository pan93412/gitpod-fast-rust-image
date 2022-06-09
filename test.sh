#!/usr/bin/env bash
# -*- coding: utf-8 -*-

IMAGE_NAME="pan93412/gitpod-fast-rust-image:staging-local"

output() {
    printf "\n---\n\x1b[1m%s\x1b[0m\n" "$1"
}

if [ ! "$1" == "--skip-build" ]; then
    DOCKER_BUILDKIT=1 docker build -t "$IMAGE_NAME" . || exit $?
fi

output "Testing:  mold"
docker run -it --rm "$IMAGE_NAME" mold -V || exit $?

output "Testing:  cargo udeps"
docker run -it --rm "$IMAGE_NAME" cargo udeps -h || exit $?

output "Testing:  sccache"
docker run -it --rm "$IMAGE_NAME" sccache -V || exit $?

output "Testing:  cargo config - config.toml"
docker run -it --rm "$IMAGE_NAME" cat /home/gitpod/.cargo/config.toml || exit $?

output "Testing:  cargo config - bashrc.d"
docker run -it --rm "$IMAGE_NAME" cat /home/gitpod/.bashrc.d/81-cargo-config || exit $?

output "Testing:  /bin/sh -> /bin/bash"
docker run -it --rm "$IMAGE_NAME" ls -al /bin/sh || exit $?
