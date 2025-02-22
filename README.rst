CPython CMake Buildsystem
=========================

Overview
--------

A replacement buildsystem for CPython.

This `CMake <http://cmake.org>`_ buildsystem has the following advantages:

* No compiled program for the target architecture is used in the build
  itself.  This makes **cross-compiling** easier, less error prone, and
  reduces manual steps.

* Same build information for all platforms - there's no need to maintain the
  autotools configuration separately from four different MSVC project files.

* Support for other build systems and IDE's like `Ninja
  <https://martine.github.io/ninja/>`_, `Sublime Text
  <https://www.sublimetext.com/>`_, and many others.

* Easily build C-extensions against other C/C++ libraries built with CMake.

* It's much faster to compile: 7 seconds instead of 58 seconds in my
  unscientific test.

Usage
-----

How to use this buildsystem:

1. Checkout the buildsystem

.. code:: bash

  cd ~/scratch
  git clone git://github.com/python-cmake-buildsystem/python-cmake-buildsystem

2. Build

.. code:: bash

  # Unix
  cd ~/scratch
  mkdir -p python-build && mkdir -p python-install
  cd python-build
  cmake -DCMAKE_INSTALL_PREFIX:PATH=${HOME}/scratch/python-install ../python-cmake-buildsystem
  make -j10
  make install

  # Windows
  cd %HOME%/scratch
  mkdir python-build
  mkdir python-install
  cd python-build
  cmake -G "Visual Studio 16 2019" -A x64 -DCMAKE_INSTALL_PREFIX:PATH=%HOME%/scratch/python-install ../python-cmake-buildsystem
  cmake --build . --config Release -- /m
  cmake --build . --config Release --target INSTALL

.. note::

  By default, the build system will download the python 3.9.10 source from
  http://www.python.org/ftp/python/


CMake Options
-------------

You can pass options to CMake to control the way Python is built.  You only
need to give each option once - they get saved in `CMakeCache.txt`.  Pass
options on the commandline with `-DOPTION=VALUE`, or use the "ccmake" gui.

::

  PYTHON_VERSION=major.minor.patch (defaults to 3.9.10)
    The version of Python to build.

  PYTHON_APPLY_PATCHES=ON|OFF (defaults to ON)
    Apply patches required to build CPython based on the system and compiler
    found when configuring the project. Note that when cross-compiling, patches
    coresponding to the target system are applied.
    Patches can be found in "patches" directory.

  CMAKE_BUILD_TYPE=Debug|Release
    Build with debugging symbols or with optimisations.

  CMAKE_INSTALL_PREFIX=<path>   (defaults to /usr/local)
    Path in which to install Python.

  DOWNLOAD_SOURCES=ON|OFF      (defaults to ON)
    Download, check MD5 sum and extract python sources in the parent directory.
    Source archive is downloaded from http://www.python.org/ftp/python

  BUILD_LIBPYTHON_SHARED=ON|OFF (defaults to OFF)
    Build libpython as a shared library (.so or .dll) or a static library
    (.a).

    Note that Python extensions are always built as shared libraries.  On
    Windows it is not possible to build shared .dll extensions against a
    static libpython, so you must build any extensions you want into libpython
    itself (see the BUILTIN flags below).

  BUILD_EXTENSIONS_AS_BUILTIN=ON|OFF (defaults to OFF)
    If enabled, all extensions are statically compiled into the built python
    libraries (static and/or shared).

    Note that all previously set BUILTIN_<extension> options are ignored and
    reset to their original value.

  WITH_STATIC_DEPENDENCIES=ON|OFF    (defaults to OFF, available only on UNIX)
    If this is set to ON then cmake will compile statically libpython and all
    extensions. External dependencies (ncurses, sqlite, ...) will be builtin
    only if they are available as static libraries.

  BUILD_WININST=ON|OFF (only for windows, defaults to ON if not crosscompiling)
    If enabled, build the 'Windows Installer' program for distutils if not
    already provided in the source tree.

  BUILD_WININST_ALWAYS=ON|OFF (only for windows, defaults to OFF)
    If enabled, always build 'Windows Installer' program for distutils even
    if it is already provided in the source tree.

  INSTALL_DEVELOPMENT=ON|OFF (defaults to ON)
    If enabled, install files required to develop C extensions.

  INSTALL_MANUAL=ON|OFF (defaults to ON)
    If enabled, install manuals.

  INSTALL_TEST=ON|OFF (defaults to ON)
    If enabled, install test files.

  ENABLE_<extension>=ON|OFF     (defaults to ON)
  BUILTIN_<extension>=ON|OFF    (defaults to OFF except for POSIX, PWD and
                                 NT extensions which are builtin by default)
    These two options control how individual python extensions are built.
    <extension> is the name of the extension in upper case, and without any
    leading underscore (_).  Known extensions for 2.7.12 include:

      ARRAY AUDIOOP BINASCII BISECT BSDDB BZ2 CMATH CODECS_CN CODECS_HK
      CODECS_ISO2022 CODECS_JP CODECS_KR CODECS_TW COLLECTIONS CPICKLE CRYPT
      CSTRINGIO CSV CTYPES CTYPES_TEST CURSES CURSES_PANEL DATETIME DBM
      ELEMENTTREE FCNTL FUNCTOOLS FUTURE_BUILTINS GDBM GRP HASHLIB HEAPQ
      HOTSHOT IO ITERTOOLS JSON LINUXAUDIODEV LOCALE LSPROF LZMA MATH MMAP
      MULTIBYTECODEC MULTIPROCESSING NIS NT OPERATOR OSSAUDIODEV PARSER POSIX
      PWD PYEXPAT RANDOM READLINE RESOURCE SELECT SOCKET SPWD SQLITE3 SSL
      STROP STRUCT SYSLOG TERMIOS TESTCAPI TIME TKINTER UNICODEDATA ZLIB

    All extensions are enabled by default, but some might depend on system
    libraries and will get disabled if they're not available (a list of
    extensions that didn't have all their prerequisites available will be
    printed when you run cmake).

    By default extensions are compiled as separate shared libraries (.so or
    .dll files) and installed in lib/python2.7/lib-dynload.  If you set
    BUILTIN_<extension> to ON then the extension is compiled into libpython
    instead.

  USE_LIB64=ON|OFF              (defaults to OFF)
    If this is set to ON then cmake will look for dependencies in lib64 as
    well as lib directories.  Compiled python extensions will also be
    installed into lib64/python2.7/lib-dynload instead of
    lib/python2.7/lib-dynload.

  Py_USING_UNICODE             (only for python2, defaults to ON)
    Enable unicode support. By default, ucs2 is used. It can be
    forced to ucs4 setting Py_UNICODE_SIZE to 4.

  WITH_C_LOCALE_COERCION       (only for python3.7 and above, default to ON)
    Enable C locale coercion to a UTF-8 based locale.

  WITH_DECIMAL_CONTEXTVAR      (only for python3.8 and above, default to ON)
    Build _decimal module using a coroutine-local rather than a thread-local context.

  WITH_TRACE_REFS              (only for python3.8 and above, default to OFF)
    Enable tracing references for debugging purpose

  WITH_SSL_DEFAULT_SUITES      (only for python3.7 and above, default to "python")
    Override default cipher suites string:
    * python: use Python's preferred selection (default)
    * openssl: leave OpenSSL's defaults untouched
    * STRING: use a custom string, PROTOCOL_SSLv2 ignores the setting

  EXTRA_PYTHONPATH=dir1:dir2    (defaults to "")
    Colon (:) separated list of extra directories to add to the compiled-in
    PYTHONPATH.

  USE_SYSTEM_LIBRARIES=ON|OFF   (defaults to ON)
    If set to OFF, no attempt to detect system libraries will be done.
    Options documented below allow to enable/disable detection of particular
    libraries.

  USE_SYSTEM_Curses=ON|OFF      (defaults to ON)
    If set to OFF, no attempt to detect Curses libraries will be done.
    Associated python extensions are: CURSES, CURSES_PANEL, READLINE
    Following CMake variables can manually be set: CURSES_LIBRARIES, PANEL_LIBRARIES

  USE_SYSTEM_EXPAT=ON|OFF       (defaults to ON)
    If set to OFF, no attempt to detect Expat libraries will be done.
    Associated python extensions are: ELEMENTTREE, PYEXPAT
    Following CMake variables can manually be set: EXPAT_LIBRARIES, EXPAT_INCLUDE_DIRS

  USE_SYSTEM_LibFFI=ON|OFF       (defaults to ON)
    If set to OFF, no attempt to detect libffi libraries will be done.
    Associated python extensions are: CTYPES
    Following CMake variables can manually be set: LibFFI_LIBRARY and LibFFI_INCLUDE_DIR

  USE_SYSTEM_OpenSSL=ON|OFF     (defaults to ON)
    If set to OFF, no attempt to detect OpenSSL libraries will be done.
    Associated python extensions are: HASHLIB, SSL, MD5, SHA, SHA256, SHA512
    Following CMake variables can manually be set: OPENSSL_INCLUDE_DIR, OPENSSL_LIBRARIES
    If [OPENSSL_INCLUDE_DIR, OPENSSL_LIBRARIES] are found, extensions [HASHLIB, SSL] will be built
    If [OPENSSL_INCLUDE_DIR, OPENSSL_LIBRARIES] are NOT found, extensions [SHA, SHA256, SHA512] will be built

  USE_SYSTEM_TCL=ON|OFF         (defaults to ON)
    If set to OFF, no attempt to detect Tcl libraries will be done.
    Associated python extensions are: TKINTER
    Following CMake variables can manually be set: TCL_LIBRARY, TK_LIBRARY, TCL_INCLUDE_PATH, TK_INCLUDE_PATH

  USE_SYSTEM_ZLIB=ON|OFF        (defaults to ON)
    If set to OFF, no attempt to detect ZLIB libraries will be done.
    Associated python extensions are: BINASCII, ZLIB
    Following CMake variables can manually be set: ZLIB_LIBRARY, ZLIB_INCLUDE_DIR, ZLIB_ROOT
    ZLIB_ROOT should be set only if USE_SYSTEM_ZLIB is ON
    If [ZLIB_LIBRARY, ZLIB_INCLUDE_DIR] are found, extensions [BINASCII] will be built with ZLIB_CRC32

  USE_SYSTEM_DB=ON|OFF          (defaults to ON)
    If set to OFF, no attempt to detect DB libraries will be done.
    Associated python extensions are: BSDDB
    Following CMake variables can manually be set: DB_INCLUDE_PATH, DB_LIBRARY

  USE_SYSTEM_GDBM=ON|OFF        (defaults to ON)
    If set to OFF, no attempt to detect GDBM libraries will be done.
    Associated python extensions are: DBM, GDBM
    Following CMake variables can manually be set: GDBM_INCLUDE_PATH, GDBM_LIBRARY, GDBM_COMPAT_LIBRARY, NDBM_TAG, <NDBM_TAG>_INCLUDE_PATH

  USE_SYSTEM_LZMA=ON|OFF     (defaults to ON)
    If set to OFF, no attempt to detect LZMA libraries will be done.
    Associated python extensions are: LZMA
    Following CMake variables can manually be set: LZMA_INCLUDE_PATH, LZMA_LIBRARY

  USE_SYSTEM_READLINE=ON|OFF    (defaults to ON)
    If set to OFF, no attempt to detect Readline libraries will be done.
    Associated python extensions are: READLINE
    Following CMake variables can manually be set: READLINE_INCLUDE_PATH, READLINE_LIBRARY

  USE_SYSTEM_SQLite3=ON|OFF     (defaults to ON)
    If set to OFF, no attempt to detect SQLite3 libraries will be done.
    Associated python extensions are: SQLITE3
    Following CMake variables can manually be set: SQLite3_INCLUDE_DIR, SQLite3_LIBRARY

  CMAKE_OSX_SDK                (MacOSX, default is autodetected, e.g 'macosx10.06')
    By default, the variable is automatically set running `xcrun` and/or `xcodebuild`. Note that its
    value can also be explicitly set when doing a clean configuration either by adding a cache entry in
    `cmake-gui` or by passing the argument `-DCMAKE_OSX_SDK:STRING=macosx10.6` when running `cmake`.
    Then, this variable is used to initialize `CMAKE_OSX_SYSROOT`, `CMAKE_OSX_DEPLOYMENT_TARGET`
    and `MACOSX_DEPLOYMENT_TARGET` variables.

Cross-compiling for Android from Linux (unsupported)
....................................................

To build Python with Android NDK set up emulator, toolchain and ABI (see `Android CMake
Guide <https://developer.android.com/ndk/guides/cmake>`_).

.. code:: bash

  # Unix
  cmake -DCMAKE_INSTALL_PREFIX:PATH=${HOME}/scratch/python-install -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK}/build/cmake/android.toolchain.cmake -DANDROID_ABI=armeabi-v7a -DCMAKE_CROSSCOMPILING_EMULATOR=adb-emu.sh -DANDROID_ALLOW_UNDEFINED_SYMBOLS=On -DENABLE_DECIMAL=Off -DENABLE_CTYPES=Off -DANDROID_PLATFORM=21 ../python-cmake-buildsystem

adb-emu.sh sends executable configuration files and launches them on connected device or launched
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

Licenses
--------

Materials in this repository are distributed under the following licenses:

  All software is licensed under the Apache 2.0 License.
  See `LICENSE_Apache_20 <LICENSE_Apache_20>`_ file for details.


FAQ
---

Why Apache 2.0 License?
.......................

From the python.org wiki, the answer to the question `What if I want to
contribute my code to the PSF
<https://wiki.python.org/moin/PythonSoftwareFoundationLicenseFaq#What_if_I_want_to_contribute_my_code_to_the_PSF.3F>`_
mentions that if code is going to end up in Python or the standard library,
the PSF will require you to license code under "Academic Free License" or
"Apache License 2.0".

Which python versions are supported?
....................................

This project supports building multiple versions of CPython 2.7 and CPython 3.
See current list of supported version in top-level `CMakeLists.txt <https://github.com/python-cmake-buildsystem/python-cmake-buildsystem/blob/master/CMakeLists.txt>`_.

Since this repository is maintained separately from `python/CPython <https://github.com/python/cpython>`_ itself,
it needs to be manually updated whenever there is a new release of Python.
