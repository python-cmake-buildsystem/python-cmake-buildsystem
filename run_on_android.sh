#!/bin/sh
#
# Run an executable built for Android on a connected device or a running emulator.
#
# Intended to be used as CMAKE_CROSSCOMPILING_EMULATOR. Supported invocations:
#   run_on_android.sh <executable>
#   run_on_android.sh <executable> <input-file> <output-file>
#
# The exit code of the executable is returned.

device_dir=/data/local/tmp

push() {
  adb push "$1" "${device_dir}/" > /dev/null 2>&1 || { echo "run_on_android.sh: failed to push $1" >&2; exit 1; }
}

executable=$(basename "$1")
push "$1"

if [ $# -eq 1 ]; then
  adb shell "${device_dir}/${executable}"
elif [ $# -eq 3 ]; then
  push "$2"
  adb shell "${device_dir}/${executable}" "${device_dir}/$(basename "$2")" "${device_dir}/$(basename "$3")"
  status=$?
  adb pull "${device_dir}/$(basename "$3")" "$3" > /dev/null 2>&1 || { echo "run_on_android.sh: failed to pull $3" >&2; exit 1; }
  exit ${status}
else
  echo "run_on_android.sh: unsupported number of arguments ($#) for ${executable}" >&2
  exit 1
fi
