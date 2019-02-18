#!/usr/bin/env bash

# fail on error
set -e
set -o pipefail

rm -rf ${ASV_PLAT_PORTS}/py* /i/pyenv/glue* /i/ports/build*/*ython*
