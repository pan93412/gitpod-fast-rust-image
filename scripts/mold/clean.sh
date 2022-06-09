#!/usr/bin/env bash
# -*- coding: utf-8 -*-

cd "$(dirname "$0")" || exit 1
. "./common.sh"

sudo rm -rf $WORKDIR
exit 0
