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
    -DANDROID_ABI=arm64-v8a \
    -DANDROID_PLATFORM=24 \
    -DCMAKE_CROSSCOMPILING_EMULATOR=../python-cmake-buildsystem/run_on_android.sh \
    -DPYTHON_FOR_BUILD=/path/to/python3.12 \
    -DENABLE_CTYPES=OFF \
    ../python-cmake-buildsystem

``run_on_android.sh`` sends executable configuration files and launches them on connected device or launched
emulator. Ensure device or emulator have same architecture you builds python.

For Python >= 3.11, ``PYTHON_FOR_BUILD`` must be set to a Python interpreter of the same version (major.minor)
running on the build host. It is used to generate the frozen modules and the sysconfig data, similarly to the
``--with-build-python`` option of CPython ``configure`` script. When cross-compiling for other targets,
``PYTHON_FOR_BUILD`` is optional: if it is not set, then the executables built for the target are run on
the build host (using ``CMAKE_CROSSCOMPILING_EMULATOR`` if set), which requires the build host to be able to run them.

``ENABLE_CTYPES`` is disabled because the Android NDK does not provide ``libffi``.

See ``.github/scripts/android_build_and_test.sh`` for a complete example, which is used for continuous
integration testing on an Android emulator.
