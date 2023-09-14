#!/bin/sh
adb push "$1" /data/local/tmp/ 1>/dev/null 2>/dev/null
if [ $# -eq 1 ]; then
  adb shell /data/local/tmp/$(basename $1)
elif [ $# -eq 3 ]; then
  adb push "$2" /data/local/tmp/ 1>/dev/null 2>/dev/null
  adb shell /data/local/tmp/$(basename $1) /data/local/tmp/$(basename $2) /data/local/tmp/$(basename $3)
  adb pull /data/local/tmp/$(basename $3) "$3" 1>/dev/null 2>/dev/null
fi
