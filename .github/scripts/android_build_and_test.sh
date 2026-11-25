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
#                     checks that run on the target. If set, no device is used during
#                     configuration.
#   NO_DEVICE         Set to 1 to only build and install, without testing on a device
#   UNIT_TESTS        Unit tests to run on the device:
#                       all         all the tests listed in android_tests.sh (default)
#                       in-process  only the tests that do not start processes, for
#                                   devices that cannot fork() (e.g. ARM binary translation)
#                       none        only run the smoke test

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

if [[ "${NO_DEVICE:-0}" == "1" ]]; then
  echo "No device available, skipping tests"
  exit 0
fi

echo "::group::Push to device"
adb shell rm -rf "${device_dir}"
adb push "${install_dir}" "${device_dir}" > /dev/null
adb push "${src_dir}/.github/scripts/android_smoke_test.py" "${device_dir}/" > /dev/null
adb shell chmod 755 "${device_dir}/bin/python*"
echo "::endgroup::"

# "adb shell" does not return the exit code of the command before Android 7.0 (API
# level 24), so the exit code is printed and parsed instead.
run_python() {
  local output status
  output=$(mktemp)
  adb shell "cd ${device_dir} && HOME=${device_dir} TMPDIR=${device_dir} PYTHONHOME=${device_dir} ./bin/python $*; echo \"@@exit=\$?@@\"" | tr -d '\r' | tee "${output}"
  status=$(sed -n 's/^@@exit=\([0-9]*\)@@$/\1/p' "${output}" | tail -n 1)
  rm -f "${output}"
  return "${status:-1}"
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

unit_tests=${UNIT_TESTS:-all}
if [[ "${unit_tests}" != "none" ]]; then
  echo "::group::Unit tests (${unit_tests})"
  device_api_level=$(adb shell getprop ro.build.version.sdk | tr -d '\r')
  py_version=$(run_python -c "'import sys; print(\"%d.%d\" % sys.version_info[:2])'" | head -n 1)
  # shellcheck source=android_tests.sh
  source "${src_dir}/.github/scripts/android_tests.sh"
  android_tests "${unit_tests}" "${device_api_level}" "${py_version}"
  echo "Device API level: ${device_api_level}, Python ${py_version}"
  echo "Tests: ${tests[*]}"
  echo "Ignored: ${ignored[*]}"
  ignore_args=""
  for pattern in "${ignored[@]}"; do
    ignore_args+=" --ignore '${pattern}'"
  done
  run_python -m test -u none --timeout 900 --verbose2 ${ignore_args} "${tests[@]}"
  echo "::endgroup::"
fi
