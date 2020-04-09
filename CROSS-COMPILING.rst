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
    -DCMAKE_CROSSCOMPILING_EMULATOR=../python-cmake-buildsystem/run_on_android.sh \
    -DANDROID_ALLOW_UNDEFINED_SYMBOLS=ON \
    -DENABLE_DECIMAL=OFF \
    -DENABLE_CTYPES=OFF \
    -DANDROID_PLATFORM=21 \
    ../python-cmake-buildsystem

``run_on_android.sh`` sends executable configuration files and launches them on connected device or launched
emulator. Ensure device or emulator have same architecture you builds python.
