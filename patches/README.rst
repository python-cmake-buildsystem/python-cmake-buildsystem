CPython Patches
===============

Fixes and improvements to CPython should first be contributed upstream. The
`Python Developer’s Guide <https://docs.python.org/devguide/>`_ is a great
resource to guide you through the process.

That said, there are few scenarios where using `python-cmake-buildsystem` to
patch CPython is relevant. Learn more about these at https://github.com/python-cmake-buildsystem/cpython.

By default, patches are applied at configuration time. Setting the option
``PYTHON_APPLY_PATCHES`` to ``OFF`` allows to change this. Note that the
build system keep track which patches have been applied.

Each patch is documented by adding an entry to the `README.rst` file
found in the same directory (or a parent directory). Whenever possible,
references to `bugs.python.org <http://bugs.python.org>`_(bpo) issues,
corresponding `GitHub PRs <https://github.com/python/cpython/pull/>`_ and
any related discussions on forums or mailing lists are also provided.

Patches are organized per python version. Patches specific to a system,
a system+compiler, or a system+compiler+compiler_version are organized in
corresponding sub-directories::

  patches/<PY_VERSION_MAJOR>.<PY_VERSION_MINOR>
  patches/<PYTHON_VERSION>
  patches/<PYTHON_VERSION>/<CMAKE_SYSTEM_NAME>
  patches/<PYTHON_VERSION>/<CMAKE_SYSTEM_NAME>-<CMAKE_C_COMPILER_ID>
  patches/<PYTHON_VERSION>/<CMAKE_SYSTEM_NAME>-<CMAKE_C_COMPILER_ID>/<compiler_version>

where

* ``<PYTHON_VERSION>`` is of the form ``X.Y.Z``

* ``<CMAKE_SYSTEM_NAME>`` is a value like ``Darwin``, ``Linux`` or ``Windows``. See
  corresponding CMake documentation for more details.

* ``<CMAKE_C_COMPILER_ID>`` is a valid like ``Clang``, ``GNU`` or ``MSVC``. See
  corresponding CMake documentation for more details.

* ``<compiler_version>`` is set to the value of ``CMAKE_C_COMPILER_VERSION`` (e.g ``5.2.1``)
  except when using Microsoft compiler where it is set to the value of ``MSVC_VERSION`` (e.g ``1900``).

Before being applied, patches are sorted alphabetically. This ensures that
patch starting with `0001-` is applied before the one starting with `0002-`.


Note that for historical reasons, there are still patches found in ``cmake/patches``
and ``cmake/patches-win32`` subdirectories. These will gradually be organized as
described above.
