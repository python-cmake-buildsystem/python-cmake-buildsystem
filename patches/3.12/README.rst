* ``0001-_bootstrap_python-Fix-execution-on-windows-disabling.patch``: _bootstrap_python: Fix execution on windows disabling site import.

* ``0002-getpath-Update-build-directory-assumptions-based-on-.patch``: getpath: Update build directory assumptions based on
 python-cmake-buildsystem

* ``0003-pycore_atomic-Fix-build-for-Windows-ARM64EC.patch``: pycore_atomic: Use the plain interlocked
  intrinsics instead of the x64-only HLE variants on Windows ARM64EC.

* ``0004-python3dll-Fix-build-for-Windows-ARM64EC.patch``: python3dll: Do not export functions that are
  not defined in the release build on Windows ARM64EC, as the ARM64EC linker requires them to exist.
