#!/usr/bin/env bash

# fail on error
set -e
set -o pipefail

declare -r build_dir='/i/ports/build-32/python-vs'
rm -rf ${build_dir}
mkdir ${build_dir}

cd ${build_dir}

cmake.exe -G"Visual Studio 16 2019" -A Win32 -DCMAKE_INSTALL_PREFIX=I:/ports/vs16-32/python-debug I:/ports/repo/python-cmake-buildsystem

# install dlls
declare -r DLLs="${build_dir}/lib/lib-dynload/Debug"
mkdir --parents "${DLLs}"
cp ${ASV_PLAT_PORTS}/python/DLLS/*.dll ${DLLs}
cp ${ASV_PLAT_PORTS}/python-debug/DLLS/*.dll ${DLLs}
