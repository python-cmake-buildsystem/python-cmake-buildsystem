#!/usr/bin/env bash

# fail on error
set -e
set -o pipefail

declare pydir='python-debug'
declare pydir='python'
declare -r PR="${ASV_PLAT_PORTS}/${pydir}"
declare -r BD="${PR}/Scripts"

${BD}/python run_py_ver.py ${PR} setup_py_env.py ${PR}
# python setup_py_env.py ${PR}
