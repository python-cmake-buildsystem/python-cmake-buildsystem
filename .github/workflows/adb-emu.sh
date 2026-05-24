#!/bin/sh
adb push "$1" /data/local/tmp/ 1>/dev/null 2>/dev/null
BINARY=$(basename "$1")
if [ $# -eq 1 ]; then
  adb shell "/data/local/tmp/${BINARY}"
elif [ $# -eq 3 ]; then
  adb push "$2" /data/local/tmp/ 1>/dev/null 2>/dev/null
  adb shell "/data/local/tmp/${BINARY}" "/data/local/tmp/$(basename $2)" "/data/local/tmp/$(basename $3)"
  adb pull "/data/local/tmp/$(basename $3)" "$3" 1>/dev/null 2>/dev/null
elif [ $# -eq 4 ] && [ "${BINARY}" = "_freeze_importlib" ]; then
  adb push "$3" /data/local/tmp/ 1>/dev/null 2>/dev/null
  adb shell "/data/local/tmp/${BINARY}" "$2" "/data/local/tmp/$(basename $3)" "/data/local/tmp/$(basename $4)"
  adb pull "/data/local/tmp/$(basename $4)" "$4" 1>/dev/null 2>/dev/null
else
  echo "Unknown number of arguments $# for ${BINARY}"
  exit 1
fi
