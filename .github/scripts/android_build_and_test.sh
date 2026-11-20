#!/usr/bin/env bash
#
# Cross-compile Python for Android and test it on a connected device or a running emulator.
#
# Required environment variables:
#   ANDROID_NDK       Path to the Android NDK
#   ANDROID_ABI       Android ABI to build for (e.g. x86_64, arm64-v8a)
#   PYTHON_FOR_BUILD  Python interpreter of the same version running on the build host
# Optional environment variables:
#   ANDROID_PLATFORM  Minimum Android API level (default: 21)
#   PY_VERSION        Python version to build (default: build system default)
#   EXTRA_CMAKE_ARGS  Additional CMake configuration arguments
#   CACHE_PRESET      Initial cache file providing the results of the configuration
#                     checks that run on the target. If set, no device is used: the
#                     project is only built and installed.
#   RUN_UNIT_TESTS    Set to 0 to only run the smoke test on the device (default: 1)

set -euo pipefail

src_dir=$(cd "$(dirname "$0")/../.." && pwd)
build_dir=${BUILD_DIR:-${src_dir}/../python-android-build}
install_dir=${build_dir}-install
device_dir=/data/local/tmp/python
api_level=${ANDROID_PLATFORM:-21}

configure_args=()
if [[ -n "${PY_VERSION:-}" ]]; then
  configure_args+=(-DPYTHON_VERSION:STRING=${PY_VERSION})
fi
if [[ -n "${CACHE_PRESET:-}" ]]; then
  configure_args+=(-C "$(cd "$(dirname "${CACHE_PRESET}")" && pwd)/$(basename "${CACHE_PRESET}")")
else
  configure_args+=(-DCMAKE_CROSSCOMPILING_EMULATOR:FILEPATH="${src_dir}/run_on_android.sh")
fi
# shellcheck disable=SC2206
configure_args+=(${EXTRA_CMAKE_ARGS:-})

echo "::group::Configure"
cmake -G Ninja \
  -S "${src_dir}" -B "${build_dir}" \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -DCMAKE_INSTALL_PREFIX:PATH="${install_dir}" \
  -DCMAKE_TOOLCHAIN_FILE:FILEPATH="${ANDROID_NDK}/build/cmake/android.toolchain.cmake" \
  -DANDROID_ABI:STRING="${ANDROID_ABI}" \
  -DANDROID_PLATFORM:STRING="${api_level}" \
  -DPYTHON_FOR_BUILD:FILEPATH="${PYTHON_FOR_BUILD}" \
  -DENABLE_CTYPES:BOOL=OFF \
  "${configure_args[@]}"
echo "::endgroup::"

echo "::group::Results of configuration checks run on the target"
# These are the values to provide in a cache preset to configure without a device
grep -E "^[A-Z0-9_]+_COMPILED:" "${build_dir}/CMakeCache.txt" | sed 's/_COMPILED:.*//' | sort -u | while read -r var; do
  grep -E "^${var}(:[A-Z]+)?=" "${build_dir}/CMakeCache.txt" || true
done
grep -E "^(HAVE_BROKEN_NICE|HAVE_BROKEN_POLL|HAVE_MMAP_DEV_ZERO)(:[A-Z]+)?=" "${build_dir}/CMakeCache.txt" || true
echo "::endgroup::"

echo "::group::Build"
# Keep going after errors to report all failures at once
cmake --build "${build_dir}" --parallel -- -k 0
echo "::endgroup::"

echo "::group::Install"
cmake --install "${build_dir}"
echo "::endgroup::"

if [[ -n "${CACHE_PRESET:-}" ]]; then
  echo "Configured using ${CACHE_PRESET}: no device available, skipping tests"
  exit 0
fi

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
if ! run_python android_smoke_test.py "${api_level}"; then
  echo "::endgroup::"
  echo "::group::Device crash log"
  adb shell getprop ro.product.cpu.abilist || true
  adb logcat -d -b crash || true
  echo "::endgroup::"
  exit 1
fi
echo "::endgroup::"

if [[ "${RUN_UNIT_TESTS:-1}" == "1" ]]; then
  echo "::group::Unit tests"
  # Creating named pipes is denied by SELinux on Android (skipped by Python >= 3.13 test suite)
  ignore_args="--ignore '*test_walk_named_pipe*'"
  device_api_level=$(adb shell getprop ro.build.version.sdk | tr -d '')
  if [[ "${device_api_level}" -le 30 ]]; then
    # Time zone rules given in the TZ environment variable are not applied as expected on Android 11 images
    ignore_args+=" --ignore '*test_timestamp_naive*'"
  fi
  run_python -m test -u none --verbose2 ${ignore_args} test_math test_json test_re test_zlib test_decimal test_os test_unicode test_string test_struct test_datetime
  echo "::endgroup::"
fi
