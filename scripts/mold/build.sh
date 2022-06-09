#!/usr/bin/env bash
# -*- coding: utf-8 -*-

cd "$(dirname "$0")" || exit 1
. "./common.sh"

# Clone mold's repo.
git clone https://github.com/rui314/mold.git "$WORKDIR"
cd $WORKDIR || exit 1
git checkout v1.2.1

# Install dependencies.
sudo ./install-build-deps.sh

# Build mold.
make -j"$(nproc)" CXX=clang++
