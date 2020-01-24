Cross-compiling
===============

Android target from Linux host
..............................

*This is is under active development. Its content, API and behavior may change at any time. We mean it!*

To build Python with Android NDK set up emulator, toolchain and ABI (see `Android CMake
Guide <https://developer.android.com/ndk/guides/cmake>`_).

.. code:: bash

  # Unix
  cmake \
    -DCMAKE_INSTALL_PREFIX:PATH=${HOME}/scratch/python-install \
    -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK}/build/cmake/android.toolchain.cmake \
    -DANDROID_ABI=armeabi-v7a \
    -DCMAKE_CROSSCOMPILING_EMULATOR=adb-emu.sh \
    -DANDROID_ALLOW_UNDEFINED_SYMBOLS=ON \
    -DENABLE_DECIMAL=OFF \
    -DENABLE_CTYPES=OFF \
    -DANDROID_PLATFORM=21 \
    ../python-cmake-buildsystem

``adb-emu.sh`` sends executable configuration files and launches them on connected device or launched
emulator. Ensure device or emulator have same architecture you builds python:

.. code:: bash

  #!/bin/sh
  adb push "$1" /data/local/tmp/ 1>/dev/null 2>/dev/null
  if [ $# -eq 1 ]; then
    adb shell /data/local/tmp/$(basename $1)
  elif [ $# -eq 3 ]; then
    adb push "$2" /data/local/tmp/ 1>/dev/null 2>/dev/null
    adb shell /data/local/tmp/$(basename $1) /data/local/tmp/$(basename $2) /data/local/tmp/$(basename $3)
    adb pull /data/local/tmp/$(basename $3) "$3" 1>/dev/null 2>/dev/null
  fi
