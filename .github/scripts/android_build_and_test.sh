#!/usr/bin/env bash
#
# Cross-compile Python for Android and test it on a connected device or a running emulator.
#
# Required environment variables:
#   ANDROID_NDK       Path to the Android NDK
#   ANDROID_ABI       Android ABI to build for (e.g. x86_64, arm64-v8a)
#   PYTHON_FOR_BUILD  Python interpreter of the same version running on the build host
# Optional environment variables:
#   ANDROID_PLATFORM  Minimum Android API level (default: 24)
#   PY_VERSION        Python version to build (default: build system default)

set -euo pipefail

src_dir=$(cd "$(dirname "$0")/../.." && pwd)
build_dir=${BUILD_DIR:-${src_dir}/../python-android-build}
install_dir=${build_dir}-install
device_dir=/data/local/tmp/python

version_args=()
if [[ -n "${PY_VERSION:-}" ]]; then
  version_args=(-DPYTHON_VERSION:STRING=${PY_VERSION})
fi

echo "::group::Configure"
cmake -G Ninja \
  -S "${src_dir}" -B "${build_dir}" \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -DCMAKE_INSTALL_PREFIX:PATH="${install_dir}" \
  -DCMAKE_TOOLCHAIN_FILE:FILEPATH="${ANDROID_NDK}/build/cmake/android.toolchain.cmake" \
  -DANDROID_ABI:STRING="${ANDROID_ABI}" \
  -DANDROID_PLATFORM:STRING="${ANDROID_PLATFORM:-24}" \
  -DCMAKE_CROSSCOMPILING_EMULATOR:FILEPATH="${src_dir}/run_on_android.sh" \
  -DPYTHON_FOR_BUILD:FILEPATH="${PYTHON_FOR_BUILD}" \
  -DENABLE_CTYPES:BOOL=OFF \
  "${version_args[@]}"
echo "::endgroup::"

echo "::group::Build"
# Keep going after errors to report all failures at once
cmake --build "${build_dir}" --parallel -- -k 0
echo "::endgroup::"

echo "::group::Install"
cmake --install "${build_dir}"
echo "::endgroup::"

echo "::group::Push to device"
adb shell rm -rf "${device_dir}"
adb push "${install_dir}" "${device_dir}" > /dev/null
adb push "${src_dir}/.github/scripts/android_smoke_test.py" "${device_dir}/" > /dev/null
adb shell chmod 755 "${device_dir}/bin/python*"
echo "::endgroup::"

run_python() {
  adb shell "cd ${device_dir} && HOME=${device_dir} TMPDIR=${device_dir} PYTHONHOME=${device_dir} ./bin/python $*"
}

echo "::group::Smoke test"
run_python android_smoke_test.py
echo "::endgroup::"

echo "::group::Unit tests"
# Creating named pipes is denied by SELinux on Android (skipped by Python >= 3.13 test suite)
run_python -m test -u none --verbose2 --ignore "'*test_walk_named_pipe*'" test_math test_json test_re test_zlib test_decimal test_os test_unicode test_string test_struct test_datetime
echo "::endgroup::"
