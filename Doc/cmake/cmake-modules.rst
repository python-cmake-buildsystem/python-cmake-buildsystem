=============
CMake modules
=============

To facilitate the writing of ``CMakeLists.txt`` used to build
CPython C/C++/Cython extensions, **scikit-build** provides the following
CMake modules:

.. toctree::
   :maxdepth: 1

   cmake-modules/CMakeChecks


They can be included using ``find_package``:

.. code-block:: cmake

    include(cmake/CMakeChecks.cmake)


For more details, see the respective documentation of each modules.