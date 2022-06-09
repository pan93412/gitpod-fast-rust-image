#!/usr/bin/env bash
# -*- coding: utf-8 -*-

cp -r /tmp/cargo-pkgs/* /workspace/.cargo || exit 1
sudo rm -rf /tmp/cargo-pkgs || exit 2
