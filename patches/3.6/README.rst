* ``0001-Prevent-incorrect-include-of-io.h-found-in-libmpdec-.patch``: Rename header files found in
  ``Modules/_decimal/libmpdec`` directory to avoid conflicts with system headers of the same name.

* ``0002-Prevent-duplicated-OverlappedType-symbols-with-built.patch``: Prevent duplicated OverlappedType
  symbols with built-in extension on Windows.

* ``0003-mpdecimal-Export-inlined-functions-to-support-extens.patch``: Export inlined functions to
  support extension built-in on Windows.

* ``0004-Fix-Windows-build-of-Python-for-latest-WinSDK.patch``: Fix build of iomodule using
  Visual Studio >= 2017. It is a partial backport of commit [python/cpython@df4852c](https://github.com/python/cpython/commit/df4852cbe4b757e8b79506d73a09ec8a1b595970)
  originally associated with [CPython GH-6874](https://github.com/python/cpython/pull/6874).
