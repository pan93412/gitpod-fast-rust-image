#!/usr/bin/env bash
# -*- coding: utf-8 -*-

cd "$(dirname "$0")" || exit 1
. "./common.sh"

# Install mold.
cd $WORKDIR || exit 1
sudo make install
