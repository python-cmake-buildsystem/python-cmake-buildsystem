Modifying CMakeList.txt and using cmake modules
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The central configuration cmake file is the ``CMakeLists.txt``, this is a Makefile equivalent,
with added funcionalities.

The ``CMakeLists.txt`` can import and use support modules (usually ending with the *.cmake* prefix and locate under the
main tree:

.. code-block:: shell-session

    <python source directory>
    ├───CMakeLists.txt      <- main cmake configuration file
    ├───cmake               <- ``CMakeLists.txt`` support files
    ├───Doc
    │   ├───cmake           <- cmake documentation
    │   ├───tutorial
    │   ├───using
    │   └───whatsnew
    ├───Grammar
    ├───Include
    .....
    ├───Python
    │   └───clinic
    └───Tools


``CMakeLists.txt``

To facilitate the writing of ``CMakeLists.txt`` cmake modules can be used. In order to make
use of them, it is necessary to include them using the cmake command ``find_package`` from within ``CMakeLists.txt``:

.. code-block:: cmake

    include(cmake/CMakeChecks.cmake)


List of support modules
~~~~~~~~~~~~~~~~~~~~~~~

For more details, see each module documentation.

.. toctree::
   :maxdepth: 2

   modules/CheckCMakeCommandExists
   modules/CMakeChecks
   modules/PythonApplyPatches




