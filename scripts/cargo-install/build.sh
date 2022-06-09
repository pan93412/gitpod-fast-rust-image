#!/usr/bin/env bash
# -*- coding: utf-8 -*-

mkdir /tmp/cargo-pkgs
cargo install --root="/tmp/cargo-pkgs" sccache cargo-workspace cargo-udeps
