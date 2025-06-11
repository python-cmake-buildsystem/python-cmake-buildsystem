add_definitions(-DPy_BUILD_CORE)
add_definitions(-DPy_BUILD_CORE_BUILTIN)
add_definitions(-DNDEBUG)

set(MODULE_SOURCES # Equivalent to MODULE_OBJS in Makefile.pre
    ${SRC_DIR}/Modules/gcmodule.c
    ${SRC_DIR}/Modules/main.c
)
if(UNIX OR PY_VERSION VERSION_LESS "3.11")
    list(APPEND MODULE_SOURCES
        ${PROJECT_BINARY_DIR}/CMakeFiles/config.c
    )
endif()
if(UNIX)
    list(APPEND MODULE_SOURCES
        # Starting with Python 3.11 "Modules/getpath.c" is deepfrozen and later appended to LIBPYTHON_SOURCES
        $<$<VERSION_LESS:${PY_VERSION},3.11>:${SRC_DIR}/Modules/getpath.c>
    )
    set(PYTHONPATH "${EXTRA_PYTHONPATH}:lib-dynload:plat-${PY_PLATFORM}")
    if(PY_VERSION VERSION_GREATER_EQUAL "3.11")
        set(PYTHONPATH "${PYTHONPATH}:lib/python${PY_VERSION_MAJOR}.${PY_VERSION_MINOR}")
        set(PYTHONPATH "${PYTHONPATH}:lib/python${PY_VERSION_MAJOR}.${PY_VERSION_MINOR}/lib-dynload")
    endif()
    if(ENABLE_TKINTER)
        set(PYTHONPATH "${PYTHONPATH}:lib-tk")
    endif()
    set_property(
        SOURCE ${SRC_DIR}/Modules/getpath.c
        PROPERTY COMPILE_DEFINITIONS
            PREFIX="${CMAKE_INSTALL_PREFIX}"
            EXEC_PREFIX="${CMAKE_INSTALL_PREFIX}"
            VERSION="${PY_VERSION_MAJOR}.${PY_VERSION_MINOR}"
            VPATH="."
            PYTHONPATH="${PYTHONPATH}"
            PLATLIBDIR="${LIBDIR}" # Introduced in Python 3.11
      )
endif()

# Removed in Python 3.11
if(WIN32 AND PY_VERSION VERSION_LESS "3.11")
    list(APPEND MODULE_SOURCES
        ${SRC_DIR}/PC/getpathp.c
    )
    # HACK To workaround limitation in escaping logic of CMake, the pythonpath
    #      separator is conditionally set depending of the version of Visual Studio.
    #      See http://cmake.org/Bug/view.php?id=14073
    if( ("${MSVC_VERSION}" VERSION_GREATER "1599") AND ("${CMAKE_GENERATOR}" MATCHES "^Visual Studio") )
        set(PATHSEP "%3B")
    elseif( (${MSVC}) AND ("${CMAKE_GENERATOR}" MATCHES "^Ninja") )
        set(PATHSEP "\;")
    elseif( (${MSVC}) AND ("${CMAKE_GENERATOR}" MATCHES "^NMake") )
        set(PATHSEP "\;")
    elseif(MINGW)
        set(PATHSEP "\;")
    else()
        set(PATHSEP ";")
    endif()
    string(REPLACE "/" "\\\\" PYTHONHOME_ESCAPED ${PYTHONHOME})
    string(REPLACE "/" "\\\\" EXTENSION_INSTALL_DIR_ESCAPED ${EXTENSION_INSTALL_DIR})
    set(PYTHONPATH "${EXTRA_PYTHONPATH}")
    set(PYTHONPATH "${PYTHONPATH}${PATHSEP}.\\\\${PYTHONHOME_ESCAPED}")
    set(PYTHONPATH "${PYTHONPATH}${PATHSEP}.\\\\${EXTENSION_INSTALL_DIR_ESCAPED}")
    set(PYTHONPATH "${PYTHONPATH}${PATHSEP}.\\\\${EXTENSION_INSTALL_DIR_ESCAPED}\\\\${CMAKE_CFG_INTDIR}")
    set(PYTHONPATH "${PYTHONPATH}${PATHSEP}.\\\\${PYTHONHOME_ESCAPED}\\\\plat-${PY_PLATFORM}")
    if(ENABLE_TKINTER)
        set(PYTHONPATH "${PYTHONPATH}${PATHSEP}.\\\\${PYTHONHOME_ESCAPED}\\\\lib-tk")
    endif()

    set(_wide_char_modifier "L")

    set_property(
        SOURCE ${SRC_DIR}/PC/getpathp.c
        PROPERTY COMPILE_DEFINITIONS
            "LANDMARK=${_wide_char_modifier}\"${PYTHONHOME_ESCAPED}\\\\os.py\""
            "PYTHONPATH=${_wide_char_modifier}\"${PYTHONPATH}\""
            "PY3_DLLNAME=${_wide_char_modifier}\"python3$<$<CONFIG:Debug>:_d>\""
    )
endif()

set(PARSER_COMMON_SOURCES # Equivalent to POBJS in Makefile.pre
    ${SRC_DIR}/Parser/parser.c

    # Removed in Python 3.8
    $<$<VERSION_LESS:${PY_VERSION},3.8>:${SRC_DIR}/Parser/bitset.c>
    $<$<VERSION_LESS:${PY_VERSION},3.8>:${SRC_DIR}/Parser/firstsets.c>
    $<$<VERSION_LESS:${PY_VERSION},3.8>:${SRC_DIR}/Parser/grammar.c>
    $<$<VERSION_LESS:${PY_VERSION},3.8>:${SRC_DIR}/Parser/metagrammar.c>
    $<$<VERSION_LESS:${PY_VERSION},3.8>:${SRC_DIR}/Parser/pgen.c>

    # Introduced in Python 3.8
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.8>:${SRC_DIR}/Parser/myreadline.c>
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.8>:${SRC_DIR}/Parser/token.c>
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.8>:${SRC_DIR}/Parser/tokenizer.c>

    # Introduced in Python 3.8 and removed in Python 3.10
    $<$<AND:$<VERSION_GREATER_EQUAL:${PY_VERSION},3.8>,$<VERSION_LESS:${PY_VERSION},3.10>>:${SRC_DIR}/Parser/parsetok.c>

    # Introduced in Python 3.9 and removed in Python 3.10
    $<$<VERSION_EQUAL:${PY_VERSION_MAJOR}.${PY_VERSION_MINOR},3.9>:${SRC_DIR}/Parser/pegen/pegen.c>
    $<$<VERSION_EQUAL:${PY_VERSION_MAJOR}.${PY_VERSION_MINOR},3.9>:${SRC_DIR}/Parser/pegen/parse.c>
    $<$<VERSION_EQUAL:${PY_VERSION_MAJOR}.${PY_VERSION_MINOR},3.9>:${SRC_DIR}/Parser/pegen/parse_string.c>
    $<$<VERSION_EQUAL:${PY_VERSION_MAJOR}.${PY_VERSION_MINOR},3.9>:${SRC_DIR}/Parser/pegen/peg_api.c>

    # Removed in Python 3.10
    $<$<VERSION_LESS:${PY_VERSION},3.10>:${SRC_DIR}/Parser/acceler.c>
    $<$<VERSION_LESS:${PY_VERSION},3.10>:${SRC_DIR}/Parser/grammar1.c>
    $<$<VERSION_LESS:${PY_VERSION},3.10>:${SRC_DIR}/Parser/listnode.c>
    $<$<VERSION_LESS:${PY_VERSION},3.10>:${SRC_DIR}/Parser/node.c>

    # Introduced in Python 3.10
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.10>:${SRC_DIR}/Parser/peg_api.c>
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.10>:${SRC_DIR}/Parser/pegen.c>
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.10>:${SRC_DIR}/Parser/string_parser.c>

    # Introduced in Python 3.11
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.11>:${SRC_DIR}/Parser/action_helpers.c>
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.11>:${SRC_DIR}/Parser/pegen_errors.c>
)

set(OBJECT_COMMON_SOURCES # Equivalent to OBJECT_OBJS in Makefile.pre
    # Removed in Python 3.12
    $<$<VERSION_LESS:${PY_VERSION},3.12>:${SRC_DIR}/Objects/accu.c>

    ${SRC_DIR}/Objects/bytesobject.c
    $<$<C_COMPILER_ID:MSVC>:${SRC_DIR}/PC/invalid_parameter_handler.c>
    ${SRC_DIR}/Objects/abstract.c
    ${SRC_DIR}/Objects/boolobject.c
    ${SRC_DIR}/Objects/bytearrayobject.c
    ${SRC_DIR}/Objects/bytes_methods.c
    ${SRC_DIR}/Objects/capsule.c
    ${SRC_DIR}/Objects/cellobject.c
    ${SRC_DIR}/Objects/classobject.c
    ${SRC_DIR}/Objects/codeobject.c
    ${SRC_DIR}/Objects/complexobject.c
    ${SRC_DIR}/Objects/descrobject.c
    ${SRC_DIR}/Objects/dictobject.c
    ${SRC_DIR}/Objects/enumobject.c
    ${SRC_DIR}/Objects/exceptions.c
    ${SRC_DIR}/Objects/fileobject.c
    ${SRC_DIR}/Objects/floatobject.c
    ${SRC_DIR}/Objects/frameobject.c
    ${SRC_DIR}/Objects/funcobject.c
    ${SRC_DIR}/Objects/genobject.c
    ${SRC_DIR}/Objects/iterobject.c
    ${SRC_DIR}/Objects/listobject.c
    ${SRC_DIR}/Objects/longobject.c
    ${SRC_DIR}/Objects/memoryobject.c
    ${SRC_DIR}/Objects/methodobject.c
    ${SRC_DIR}/Objects/moduleobject.c
    ${SRC_DIR}/Objects/object.c
    ${SRC_DIR}/Objects/obmalloc.c
    ${SRC_DIR}/Objects/rangeobject.c
    ${SRC_DIR}/Objects/setobject.c
    ${SRC_DIR}/Objects/sliceobject.c
    ${SRC_DIR}/Objects/structseq.c
    ${SRC_DIR}/Objects/tupleobject.c
    ${SRC_DIR}/Objects/typeobject.c
    ${SRC_DIR}/Objects/unicodectype.c
    ${SRC_DIR}/Objects/unicodeobject.c
    ${SRC_DIR}/Objects/weakrefobject.c

    # Introduced in Python 3.3
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.3>:${SRC_DIR}/Objects/namespaceobject.c>

    # Introduced in Python 3.5
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.5>:${SRC_DIR}/Objects/odictobject.c>

    # Introduced in Python 3.7
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.7>:${SRC_DIR}/Objects/call.c>

    # Introduced in Python 3.8
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.8>:${SRC_DIR}/Objects/interpreteridobject.c>
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.8>:${SRC_DIR}/Objects/picklebufobject.c>

    # Introduced in Python 3.9
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.9>:${SRC_DIR}/Objects/genericaliasobject.c>

    # Introduced in Python 3.10
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.10>:${SRC_DIR}/Objects/unionobject.c>

    # Introduced in Python 3.12
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:${SRC_DIR}/Objects/typevarobject.c>
)

if(CMAKE_C_COMPILER_ID MATCHES GNU)
    foreach(filename class complex float int method string type unicode weakref)
        set_property(SOURCE ${SRC_DIR}/Objects/${filename}object.c PROPERTY COMPILE_FLAGS -Wno-unused-value)
    endforeach()
endif()

set(DYNLOAD_SOURCES
  )

if(UNIX AND HAVE_DLOPEN)
    list(APPEND DYNLOAD_SOURCES
        ${SRC_DIR}/Python/dynload_shlib.c
    )
    set_property(
        SOURCE ${SRC_DIR}/Python/dynload_shlib.c
        PROPERTY COMPILE_DEFINITIONS
            SOABI="${SOABI}"
            #MULTIARCH
        )
elseif(WIN32)
    list(APPEND DYNLOAD_SOURCES
        $<$<VERSION_LESS:${PY_VERSION},3.11>:${SRC_DIR}/PC/dl_nt.c>
        ${SRC_DIR}/Python/dynload_win.c
        )
    set(ms_dll_id "${PY_VERSION_MAJOR}.${PY_VERSION_MINOR}")
    if(${CMAKE_SIZEOF_VOID_P} EQUAL 4)
      set(ms_dll_id "${ms_dll_id}-32")
    endif()
    set_property(
        SOURCE ${SRC_DIR}/PC/dl_nt.c
        PROPERTY COMPILE_DEFINITIONS
            Py_ENABLE_SHARED
            MS_DLL_ID="${ms_dll_id}"
        )
    set(_wide_char_modifier "L")
    set_property(
        SOURCE ${SRC_DIR}/Python/dynload_win.c
        PROPERTY COMPILE_DEFINITIONS
            "PY3_DLLNAME=${_wide_char_modifier}\"python3$<$<CONFIG:Debug>:_d>\"" # Python 3.11
        )
endif()

set(PYTHON_COMMON_SOURCES
    ${DYNLOAD_SOURCES}
    ${SRC_DIR}/Python/dynamic_annotations.c
    ${SRC_DIR}/Python/fileutils.c
    ${SRC_DIR}/Python/pystrtod.c
    ${SRC_DIR}/Python/pytime.c
    ${SRC_DIR}/Python/asdl.c
    ${SRC_DIR}/Python/ast.c
    ${SRC_DIR}/Python/bltinmodule.c
    ${SRC_DIR}/Python/ceval.c
    ${SRC_DIR}/Python/codecs.c
    ${SRC_DIR}/Python/compile.c
    ${SRC_DIR}/Python/dtoa.c
    ${SRC_DIR}/Python/errors.c
    ${SRC_DIR}/Python/formatter_unicode.c
    ${SRC_DIR}/Python/future.c
    ${SRC_DIR}/Python/getargs.c
    ${SRC_DIR}/Python/getcompiler.c
    ${SRC_DIR}/Python/getcopyright.c
    ${SRC_DIR}/Python/getopt.c
    ${SRC_DIR}/Python/getplatform.c
    ${SRC_DIR}/Python/getversion.c
    ${SRC_DIR}/Python/import.c
    ${SRC_DIR}/Python/importdl.c
    ${SRC_DIR}/Python/marshal.c
    ${SRC_DIR}/Python/modsupport.c
    ${SRC_DIR}/Python/mysnprintf.c
    ${SRC_DIR}/Python/mystrtoul.c
    ${SRC_DIR}/Python/pyarena.c
    ${SRC_DIR}/Python/pyctype.c
    ${SRC_DIR}/Python/pyfpe.c
    ${SRC_DIR}/Python/pymath.c
    ${SRC_DIR}/Python/pystate.c
    ${SRC_DIR}/Python/pystrcmp.c
    ${SRC_DIR}/Python/Python-ast.c
    ${SRC_DIR}/Python/pythonrun.c
    ${SRC_DIR}/Python/structmember.c
    ${SRC_DIR}/Python/symtable.c
    ${SRC_DIR}/Python/sysmodule.c
    ${SRC_DIR}/Python/traceback.c
    ${SRC_DIR}/Python/_warnings.c

    # Introduced in Python 3.4
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.4>:${SRC_DIR}/Python/pyhash.c>

    # Introduced in Python 3.5
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.5>:${SRC_DIR}/Python/pylifecycle.c>
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.5>:${SRC_DIR}/Python/pystrhex.c>

    # Removed in Python 3.7
    $<$<VERSION_LESS:${PY_VERSION},3.7>:${SRC_DIR}/Python/random.c>

    # Introduced in Python 3.7
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.7>:${SRC_DIR}/Python/ast_opt.c>
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.7>:${SRC_DIR}/Python/ast_unparse.c>
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.7>:${SRC_DIR}/Python/bootstrap_hash.c>
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.7>:${SRC_DIR}/Python/context.c>
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.7>:${SRC_DIR}/Python/hamt.c>
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.7>:${SRC_DIR}/Python/pathconfig.c>
    $<$<OR:$<BOOL:${WITH_THREAD}>,$<VERSION_GREATER_EQUAL:${PY_VERSION},3.7>>:${SRC_DIR}/Python/thread.c>

    # Introduced in Python 3.8
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.8>:${SRC_DIR}/Python/initconfig.c>
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.8>:${SRC_DIR}/Python/preconfig.c>

    # Removed in Python 3.10
    $<$<VERSION_LESS:${PY_VERSION},3.10>:${SRC_DIR}/Python/graminit.c>
    $<$<VERSION_LESS:${PY_VERSION},3.10>:${SRC_DIR}/Python/peephole.c>

    # Introduced in Python 3.10
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.10>:${SRC_DIR}/Python/suggestions.c>

    # Introduced in Python 3.11
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.11>:${SRC_DIR}/Python/Python-tokenize.c>
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.11>:${SRC_DIR}/Python/frame.c>
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.11>:${SRC_DIR}/Python/specialize.c>

    # Introduced in Python 3.12
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:${SRC_DIR}/Python/assemble.c>
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:${SRC_DIR}/Python/ceval_gil.c>
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:${SRC_DIR}/Python/flowgraph.c>
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:${SRC_DIR}/Python/instrumentation.c>
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:${SRC_DIR}/Python/intrinsics.c>
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:${SRC_DIR}/Python/legacy_tracing.c>
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:${SRC_DIR}/Python/perf_trampoline.c>
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:${SRC_DIR}/Python/tracemalloc.c>
)

if(UNIX)
    list(APPEND PYTHON_COMMON_SOURCES
        ${SRC_DIR}/Python/frozenmain.c
    )
else()
    list(APPEND PYTHON_COMMON_SOURCES
        # Removed in Python 3.11
        $<$<VERSION_LESS:${PY_VERSION},3.11>:${SRC_DIR}/Python/frozen.c>
    )
endif()

if(UNIX OR MINGW)
    set_property(
        SOURCE ${SRC_DIR}/Python/getplatform.c
        PROPERTY COMPILE_DEFINITIONS
            PLATFORM="${PY_PLATFORM}"
    )
endif()
if(UNIX OR MINGW OR PY_VERSION VERSION_GREATER_EQUAL "3.11")
    set_property(
        SOURCE ${SRC_DIR}/Python/sysmodule.c
        PROPERTY COMPILE_DEFINITIONS
            VPATH="..\\\\.." # Python 3.11
            ABIFLAGS="${ABIFLAGS}"
        )
endif()

# Introduced in Python 3.10 and removed in Python 3.11
if(WIN32 AND "${PY_VERSION_MAJOR}.${PY_VERSION_MINOR}" VERSION_EQUAL "3.10")
    set(_wide_char_modifier "L")
    set_property(
        SOURCE ${SRC_DIR}/Python/pathconfig.c
        PROPERTY COMPILE_DEFINITIONS
            "PY3_DLLNAME=${_wide_char_modifier}\"python3$<$<CONFIG:Debug>:_d>\""
        )
endif()

list(APPEND MODULE_SOURCES
    ${SRC_DIR}/Modules/signalmodule.c
)

set(LIBPYTHON_OMIT_FROZEN_SOURCES
    ${SRC_DIR}/Modules/getbuildinfo.c
    ${MODULE_SOURCES}
    ${OBJECT_COMMON_SOURCES}
    ${PARSER_COMMON_SOURCES}
    ${PYTHON_COMMON_SOURCES}

    $<$<VERSION_LESS:${PY_VERSION},3.8>:${SRC_DIR}/Parser/myreadline.c>
    $<$<VERSION_LESS:${PY_VERSION},3.8>:${SRC_DIR}/Parser/parsetok.c>
    $<$<VERSION_LESS:${PY_VERSION},3.8>:${SRC_DIR}/Parser/tokenizer.c>
)

# List of builtin extensions
get_property(builtin_extensions GLOBAL PROPERTY builtin_extensions)

# Collect builtin extension sources
set(builtin_extension_sources)
foreach(name ${builtin_extensions})
    get_property(extension_${name}_sources GLOBAL PROPERTY extension_${name}_sources)
    list(APPEND builtin_extension_sources ${extension_${name}_sources})
endforeach()

# XXX Associate Py_NO_ENABLE_SHARED with "_ctypes/callbacks.c" if corresponding
#     extension is builtin.
if(WIN32)
    foreach(src ${builtin_extension_sources})
        get_filename_component(filename ${src} NAME)
        if(${filename} STREQUAL "callbacks.c")
            set_property(SOURCE ${src} APPEND PROPERTY COMPILE_DEFINITIONS Py_NO_ENABLE_SHARED)
        endif()
    endforeach()
endif()
list(APPEND LIBPYTHON_OMIT_FROZEN_SOURCES ${builtin_extension_sources})

# Collect builtin extension link libraries
set(builtin_link_libraries)
foreach(name ${builtin_extensions})
    get_property(extension_${name}_link_libraries GLOBAL PROPERTY extension_${name}_link_libraries)
    list(APPEND builtin_link_libraries ${extension_${name}_link_libraries})
endforeach()

# Collect builtin extension includedirs
set(builtin_includedirs)
foreach(name ${builtin_extensions})
    get_property(extension_${name}_includedirs GLOBAL PROPERTY extension_${name}_includedirs)
    list(APPEND builtin_includedirs ${extension_${name}_includedirs})
endforeach()

# Collect builtin extension definitions
set(builtin_compile_definitions_without_py_limited_api)
foreach(name ${builtin_extensions})
    get_property(extension_${name}_definitions GLOBAL PROPERTY extension_${name}_definitions)
    if(extension_${name}_definitions)
        set_property(SOURCE ${extension_${name}_sources}
            APPEND PROPERTY COMPILE_DEFINITIONS ${extension_${name}_definitions})
        # Workaround for CMake issue #26993 (https://gitlab.kitware.com/cmake/cmake/-/issues/26993):
        # Generator expressions are not supported in the SOURCE argument of set_property().
        # Collect compile definitions here to propagate them via target_compile_definitions().
        if(NOT ${name} STREQUAL "xxlimited")
            list(APPEND builtin_compile_definitions_without_py_limited_api ${extension_${name}_definitions})
        endif()
    endif()
endforeach()

include_directories(${builtin_includedirs})

# Create the parts of config.c for platform-specific and user-controlled
# builtin modules.
set(init_return_type "PyObject*")
set(init_prefix "PyInit_")

set(config_inits "")
set(config_entries "")
foreach(ext ${builtin_extensions})
    set(config_inits "${config_inits}extern ${init_return_type} ${init_prefix}${ext}(void);\n")
    set(config_entries "${config_entries}    {\"${ext}\", ${init_prefix}${ext}},\n")
endforeach()

if(PY_VERSION VERSION_GREATER_EQUAL "3.7")
    set(PyInit_imp "PyInit__imp")
else()
    set(PyInit_imp "PyInit_imp")
endif()

configure_file(
    ${PROJECT_SOURCE_DIR}/cmake/config_${PY_VERSION_MAJOR}.c.in
    ${PROJECT_BINARY_DIR}/CMakeFiles/config.c
    )

if(WIN32 AND PY_VERSION VERSION_GREATER_EQUAL "3.11")
set(config_inits "")
set(minimal_builtin_extensions _codecs _collections _io _imp _sre _thread _tracemalloc _weakref errno faulthandler itertools time)
if(PY_VERSION VERSION_GREATER_EQUAL "3.12")
  list(APPEND minimal_builtin_extensions _typing _winapi)
endif()
if(WIN32)
    list(APPEND minimal_builtin_extensions nt winreg)
    set(config_inits "${config_inits}/* Define extern variables omitted from minimal builds */\n")
    set(config_inits "${config_inits}void *PyWin_DLLhModule = NULL;\n\n")
endif()
set(config_entries "")
foreach(ext IN LISTS minimal_builtin_extensions)
    set(config_inits "${config_inits}extern ${init_return_type} ${init_prefix}${ext}(void);\n")
    set(config_entries "${config_entries}    {\"${ext}\", ${init_prefix}${ext}},\n")
endforeach()
configure_file(
    ${PROJECT_SOURCE_DIR}/cmake/config_${PY_VERSION_MAJOR}.c.in
    ${PROJECT_BINARY_DIR}/CMakeFiles/config_minimal.c
    )
endif()

# Collect libpython target libraries
set(LIBPYTHON_TARGET_LIBRARIES
  ${builtin_link_libraries}
  )
if(HAVE_LIBDL)
  list(APPEND LIBPYTHON_TARGET_LIBRARIES ${HAVE_LIBDL})
endif()
if(WITH_THREAD OR PY_VERSION VERSION_GREATER_EQUAL "3.7")
    list(APPEND LIBPYTHON_TARGET_LIBRARIES ${CMAKE_THREAD_LIBS_INIT})
endif()
if(UNIX)
    list(APPEND LIBPYTHON_TARGET_LIBRARIES ${LIBUTIL_LIBRARIES} ${M_LIBRARIES})
endif()
if(WIN32)
    list(APPEND LIBPYTHON_TARGET_LIBRARIES
      ws2_32 # Required by signalmodule
      $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.5>:version> # Required by sysmodule
      $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.6>:shlwapi> # Required by PC/getpathp
      $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.9>:pathcch>
      $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.11>:bcrypt> # Required by bootstrap_hash
     )
endif()

set(LIBPYTHON_FROZEN_SOURCES )

# Build _freeze_importlib executable
add_executable(_freeze_importlib

  # Introduced in Python 3.3 and removed in Python 3.11
  $<$<AND:$<VERSION_GREATER_EQUAL:${PY_VERSION},3.3>,$<VERSION_LESS:${PY_VERSION},3.11>>:${SRC_DIR}/$<IF:$<VERSION_GREATER_EQUAL:${PY_VERSION},3.5>,Programs,Modules>/_freeze_importlib.c>

  # Introduced in Python 3.11
  $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.11>:${SRC_DIR}/Programs/_freeze_module.c>
  $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.11>:${SRC_DIR}/Modules/getpath_noop.c>
  $<$<AND:$<BOOL:${WIN32}>,$<VERSION_GREATER_EQUAL:${PY_VERSION},3.11>>:${PROJECT_BINARY_DIR}/CMakeFiles/config_minimal.c>

  ${LIBPYTHON_OMIT_FROZEN_SOURCES}
  )
target_link_libraries(_freeze_importlib ${LIBPYTHON_TARGET_LIBRARIES})
if(builtin_compile_definitions_without_py_limited_api)
  # Workaround for CMake issue #26993 (https://gitlab.kitware.com/cmake/cmake/-/issues/26993):
  # Explicitly propagate built-in extension definitions to this target.
  # These would otherwise be lost due to generator expression limitations in set_property().
  target_compile_definitions(_freeze_importlib PRIVATE ${builtin_compile_definitions_without_py_limited_api})
endif()
target_compile_definitions(_freeze_importlib
  PUBLIC
    Py_NO_ENABLE_SHARED
)

# Freeze modules for Python < 3.11
if(PY_VERSION VERSION_LESS "3.11")
set(LIBPYTHON_FROZEN_SOURCES
  ${SRC_DIR}/Python/importlib_external.h
  ${SRC_DIR}/Python/importlib.h
  $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.8>:${SRC_DIR}/Python/importlib_zipimport.h>
)
add_custom_command(
  OUTPUT ${LIBPYTHON_FROZEN_SOURCES}
  COMMAND
    _freeze_importlib
      $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.8>:importlib._bootstrap_external>
      ${SRC_DIR}/Lib/importlib/_bootstrap_external.py
      ${SRC_DIR}/Python/importlib_external.h
  COMMAND
    _freeze_importlib
      $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.8>:importlib._bootstrap>
      ${SRC_DIR}/Lib/importlib/_bootstrap.py
      ${SRC_DIR}/Python/importlib.h
  DEPENDS
    _freeze_importlib
    ${SRC_DIR}/Lib/importlib/_bootstrap_external.py
    ${SRC_DIR}/Lib/importlib/_bootstrap.py
)

if(PY_VERSION VERSION_GREATER_EQUAL "3.8")
  add_custom_command(
    OUTPUT ${LIBPYTHON_FROZEN_SOURCES}
    COMMAND
      _freeze_importlib
        zipimport
        ${SRC_DIR}/Lib/zipimport.py
        ${SRC_DIR}/Python/importlib_zipimport.h
    DEPENDS
      ${SRC_DIR}/Lib/zipimport.py
    APPEND
  )
endif()
endif()

# Freeze modules for Python >= 3.11
if(PY_VERSION VERSION_GREATER_EQUAL "3.11")

set(LIBPYTHON_FROZEN_SOURCES
  ${SRC_DIR}/Python/frozen_modules/importlib._bootstrap.h
  ${SRC_DIR}/Python/frozen_modules/importlib._bootstrap_external.h
  ${SRC_DIR}/Python/frozen_modules/zipimport.h
  ${SRC_DIR}/Python/frozen_modules/abc.h
  ${SRC_DIR}/Python/frozen_modules/codecs.h
  ${SRC_DIR}/Python/frozen_modules/io.h
  ${SRC_DIR}/Python/frozen_modules/_collections_abc.h
  ${SRC_DIR}/Python/frozen_modules/_sitebuiltins.h
  ${SRC_DIR}/Python/frozen_modules/genericpath.h
  ${SRC_DIR}/Python/frozen_modules/ntpath.h
  ${SRC_DIR}/Python/frozen_modules/posixpath.h
  ${SRC_DIR}/Python/frozen_modules/os.h
  ${SRC_DIR}/Python/frozen_modules/site.h
  ${SRC_DIR}/Python/frozen_modules/stat.h
  ${SRC_DIR}/Python/frozen_modules/importlib.util.h
  ${SRC_DIR}/Python/frozen_modules/importlib.machinery.h
  ${SRC_DIR}/Python/frozen_modules/runpy.h
  ${SRC_DIR}/Python/frozen_modules/__hello__.h
  ${SRC_DIR}/Python/frozen_modules/__phello__.h
  ${SRC_DIR}/Python/frozen_modules/__phello__.ham.h
  ${SRC_DIR}/Python/frozen_modules/__phello__.ham.eggs.h
  ${SRC_DIR}/Python/frozen_modules/__phello__.spam.h
  ${SRC_DIR}/Python/frozen_modules/frozen_only.h
  ${SRC_DIR}/Python/frozen_modules/getpath.h
)
add_custom_command(
  OUTPUT ${LIBPYTHON_FROZEN_SOURCES}
  COMMAND
    _freeze_importlib
      importlib._bootstrap
      ${SRC_DIR}/Lib/importlib/_bootstrap.py
      ${SRC_DIR}/Python/frozen_modules/importlib._bootstrap.h
  COMMAND
    _freeze_importlib
      importlib._bootstrap_external
      ${SRC_DIR}/Lib/importlib/_bootstrap_external.py
      ${SRC_DIR}/Python/frozen_modules/importlib._bootstrap_external.h
  COMMAND
    _freeze_importlib
      zipimport
      ${SRC_DIR}/Lib/zipimport.py
      ${SRC_DIR}/Python/frozen_modules/zipimport.h
  COMMAND
    _freeze_importlib
      abc
      ${SRC_DIR}/Lib/abc.py
      ${SRC_DIR}/Python/frozen_modules/abc.h
  COMMAND
    _freeze_importlib
      codecs
      ${SRC_DIR}/Lib/codecs.py
      ${SRC_DIR}/Python/frozen_modules/codecs.h
  COMMAND
    _freeze_importlib
      io
      ${SRC_DIR}/Lib/io.py
      ${SRC_DIR}/Python/frozen_modules/io.h
  COMMAND
    _freeze_importlib
      _collections_abc
      ${SRC_DIR}/Lib/_collections_abc.py
      ${SRC_DIR}/Python/frozen_modules/_collections_abc.h
  COMMAND
    _freeze_importlib
      _sitebuiltins
      ${SRC_DIR}/Lib/_sitebuiltins.py
      ${SRC_DIR}/Python/frozen_modules/_sitebuiltins.h
  COMMAND
    _freeze_importlib
      genericpath
      ${SRC_DIR}/Lib/genericpath.py
      ${SRC_DIR}/Python/frozen_modules/genericpath.h
  COMMAND
    _freeze_importlib
      ntpath
      ${SRC_DIR}/Lib/ntpath.py
      ${SRC_DIR}/Python/frozen_modules/ntpath.h
  COMMAND
    _freeze_importlib
      posixpath
      ${SRC_DIR}/Lib/posixpath.py
      ${SRC_DIR}/Python/frozen_modules/posixpath.h
  COMMAND
    _freeze_importlib
      os
      ${SRC_DIR}/Lib/os.py
      ${SRC_DIR}/Python/frozen_modules/os.h
  COMMAND
    _freeze_importlib
      site
      ${SRC_DIR}/Lib/site.py
      ${SRC_DIR}/Python/frozen_modules/site.h
  COMMAND
    _freeze_importlib
      stat
      ${SRC_DIR}/Lib/stat.py
      ${SRC_DIR}/Python/frozen_modules/stat.h
  COMMAND
    _freeze_importlib
      importlib.util
      ${SRC_DIR}/Lib/importlib/util.py
      ${SRC_DIR}/Python/frozen_modules/importlib.util.h
  COMMAND
    _freeze_importlib
      importlib.machinery
      ${SRC_DIR}/Lib/importlib/machinery.py
      ${SRC_DIR}/Python/frozen_modules/importlib.machinery.h
  COMMAND
    _freeze_importlib
      runpy
      ${SRC_DIR}/Lib/runpy.py
      ${SRC_DIR}/Python/frozen_modules/runpy.h
  COMMAND
    _freeze_importlib
      __hello__
      ${SRC_DIR}/Lib/__hello__.py
      ${SRC_DIR}/Python/frozen_modules/__hello__.h
  COMMAND
    _freeze_importlib
      __phello__
      ${SRC_DIR}/Lib/__phello__/__init__.py
      ${SRC_DIR}/Python/frozen_modules/__phello__.h
  COMMAND
    _freeze_importlib
      __phello__.ham
      ${SRC_DIR}/Lib/__phello__/ham/__init__.py
      ${SRC_DIR}/Python/frozen_modules/__phello__.ham.h
  COMMAND
    _freeze_importlib
      __phello__.ham.eggs
      ${SRC_DIR}/Lib/__phello__/ham/eggs.py
      ${SRC_DIR}/Python/frozen_modules/__phello__.ham.eggs.h
  COMMAND
    _freeze_importlib
      __phello__.spam
      ${SRC_DIR}/Lib/__phello__/spam.py
      ${SRC_DIR}/Python/frozen_modules/__phello__.spam.h
  COMMAND
    _freeze_importlib
      frozen_only
      ${SRC_DIR}/Tools/freeze/flag.py
      ${SRC_DIR}/Python/frozen_modules/frozen_only.h
  COMMAND
    _freeze_importlib
      getpath
      ${SRC_DIR}/Modules/getpath.py
      ${SRC_DIR}/Python/frozen_modules/getpath.h
  DEPENDS
      _freeze_importlib
      ${SRC_DIR}/Lib/importlib/_bootstrap.py
      ${SRC_DIR}/Lib/importlib/_bootstrap_external.py
      ${SRC_DIR}/Lib/zipimport.py
      ${SRC_DIR}/Lib/abc.py
      ${SRC_DIR}/Lib/codecs.py
      ${SRC_DIR}/Lib/io.py
      ${SRC_DIR}/Lib/_collections_abc.py
      ${SRC_DIR}/Lib/_sitebuiltins.py
      ${SRC_DIR}/Lib/genericpath.py
      ${SRC_DIR}/Lib/ntpath.py
      ${SRC_DIR}/Lib/posixpath.py
      ${SRC_DIR}/Lib/os.py
      ${SRC_DIR}/Lib/site.py
      ${SRC_DIR}/Lib/stat.py
      ${SRC_DIR}/Lib/importlib/util.py
      ${SRC_DIR}/Lib/importlib/machinery.py
      ${SRC_DIR}/Lib/runpy.py
      ${SRC_DIR}/Lib/__hello__.py
      ${SRC_DIR}/Lib/__phello__/__init__.py
      ${SRC_DIR}/Lib/__phello__/ham/__init__.py
      ${SRC_DIR}/Lib/__phello__/ham/eggs.py
      ${SRC_DIR}/Lib/__phello__/spam.py
      ${SRC_DIR}/Tools/freeze/flag.py
      ${SRC_DIR}/Modules/getpath.py
  )
endif()

# This is a convenience target allowing to regenerate
# the frozen sources.
add_custom_target(freeze_modules DEPENDS
    ${LIBPYTHON_FROZEN_SOURCES}
)

set(LIBPYTHON_DEEPFREEZE_SOURCES )

if(PY_VERSION VERSION_GREATER_EQUAL "3.11")

# Build _bootstrap_python executable
add_executable(_bootstrap_python
    ${SRC_DIR}/Programs/_bootstrap_python.c
    ${SRC_DIR}/Modules/getpath.c
    $<$<BOOL:${WIN32}>:${PROJECT_BINARY_DIR}/CMakeFiles/config_minimal.c>
    ${LIBPYTHON_OMIT_FROZEN_SOURCES}
    ${LIBPYTHON_FROZEN_SOURCES}
)
target_link_libraries(_bootstrap_python ${LIBPYTHON_TARGET_LIBRARIES})
if(builtin_compile_definitions_without_py_limited_api)
  # Workaround for CMake issue #26993 (https://gitlab.kitware.com/cmake/cmake/-/issues/26993):
  # Explicitly propagate built-in extension definitions to this target.
  # These would otherwise be lost due to generator expression limitations in set_property().
  target_compile_definitions(_bootstrap_python PRIVATE ${builtin_compile_definitions_without_py_limited_api})
endif()
target_compile_definitions(_bootstrap_python
    PUBLIC
        Py_NO_ENABLE_SHARED
)

list(APPEND LIBPYTHON_DEEPFREEZE_SOURCES
    ${SRC_DIR}/Python/deepfreeze/deepfreeze.c
)

set(DEEPFREEZE_PY ${SRC_DIR}/Tools/$<IF:$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>,build,scripts>/deepfreeze.py)

add_custom_command(
  OUTPUT ${LIBPYTHON_DEEPFREEZE_SOURCES}
  COMMAND
    _bootstrap_python
      ${DEEPFREEZE_PY}
        "${SRC_DIR}/Python/frozen_modules/importlib._bootstrap.h:importlib._bootstrap"
        "${SRC_DIR}/Python/frozen_modules/importlib._bootstrap_external.h:importlib._bootstrap_external"
        "${SRC_DIR}/Python/frozen_modules/zipimport.h:zipimport"
        "${SRC_DIR}/Python/frozen_modules/abc.h:abc"
        "${SRC_DIR}/Python/frozen_modules/codecs.h:codecs"
        "${SRC_DIR}/Python/frozen_modules/io.h:io"
        "${SRC_DIR}/Python/frozen_modules/_collections_abc.h:_collections_abc"
        "${SRC_DIR}/Python/frozen_modules/_sitebuiltins.h:_sitebuiltins"
        "${SRC_DIR}/Python/frozen_modules/genericpath.h:genericpath"
        "${SRC_DIR}/Python/frozen_modules/ntpath.h:ntpath"
        "${SRC_DIR}/Python/frozen_modules/posixpath.h:posixpath"
        "${SRC_DIR}/Python/frozen_modules/os.h:os"
        "${SRC_DIR}/Python/frozen_modules/site.h:site"
        "${SRC_DIR}/Python/frozen_modules/stat.h:stat"
        "${SRC_DIR}/Python/frozen_modules/importlib.util.h:importlib.util"
        "${SRC_DIR}/Python/frozen_modules/importlib.machinery.h:importlib.machinery"
        "${SRC_DIR}/Python/frozen_modules/runpy.h:runpy"
        "${SRC_DIR}/Python/frozen_modules/__hello__.h:__hello__"
        "${SRC_DIR}/Python/frozen_modules/__phello__.h:__phello__"
        "${SRC_DIR}/Python/frozen_modules/__phello__.ham.h:__phello__.ham"
        "${SRC_DIR}/Python/frozen_modules/__phello__.ham.eggs.h:__phello__.ham.eggs"
        "${SRC_DIR}/Python/frozen_modules/__phello__.spam.h:__phello__.spam"
        "${SRC_DIR}/Python/frozen_modules/frozen_only.h:frozen_only"
      "-o" "${LIBPYTHON_DEEPFREEZE_SOURCES}"
  DEPENDS
    ${DEEPFREEZE_PY}
    ${LIBPYTHON_FROZEN_SOURCES}
)

# This is a convenience target allowing to regenerate
# the deepfreeze sources.
add_custom_target(deepfreeze_modules DEPENDS
    ${LIBPYTHON_DEEPFREEZE_SOURCES}
)
endif()

if(PY_VERSION VERSION_LESS "3.8")
# Build pgen executable
add_executable(pgen
    ${PARSER_COMMON_SOURCES}
    ${SRC_DIR}/Python/dynamic_annotations.c
    ${SRC_DIR}/Objects/obmalloc.c
    ${SRC_DIR}/Python/mysnprintf.c
    ${SRC_DIR}/Python/pyctype.c
    ${SRC_DIR}/Parser/tokenizer_pgen.c
    ${SRC_DIR}/Parser/printgrammar.c
    ${SRC_DIR}/Parser/pgenmain.c

    # Removed in Python 3.10 but excluded starting with Python 3.3 when the new parser
    # was introduced.
    # See cpython/cpython@1ed83adb0e9 ("bpo-40939: Remove the old parser (GH-20768)", 2020-06-11)
    $<$<VERSION_LESS:${PY_VERSION},3.3>:${SRC_DIR}/Parser/parsetok.c>

    # Introduced in Python 3.3
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.3>:${SRC_DIR}/Parser/parsetok_pgen.c>
)
if(builtin_compile_definitions_without_py_limited_api)
  # Workaround for CMake issue #26993 (https://gitlab.kitware.com/cmake/cmake/-/issues/26993):
  # Explicitly propagate built-in extension definitions to this target.
  # These would otherwise be lost due to generator expression limitations in set_property().
  target_compile_definitions(pgen PRIVATE ${builtin_compile_definitions_without_py_limited_api})
endif()
endif()

# Collect libpython sources
set(LIBPYTHON_SOURCES
    ${LIBPYTHON_OMIT_FROZEN_SOURCES}
    ${LIBPYTHON_FROZEN_SOURCES}
    ${LIBPYTHON_DEEPFREEZE_SOURCES}
    $<$<OR:$<BOOL:${UNIX}>,$<VERSION_GREATER_EQUAL:${PY_VERSION},3.11>>:${SRC_DIR}/Python/frozen.c>

    # Introduced in Python 3.11
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.11>:${SRC_DIR}/Modules/getpath.c>
    $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.11>:${SRC_DIR}/Modules/_typingmodule.c>
    $<$<AND:$<BOOL:${WIN32}>,$<VERSION_GREATER_EQUAL:${PY_VERSION},3.11>>:${PROJECT_BINARY_DIR}/CMakeFiles/config.c>
    $<$<AND:$<BOOL:${WIN32}>,$<VERSION_GREATER_EQUAL:${PY_VERSION},3.11>>:${SRC_DIR}/PC/dl_nt.c>
)
if(WIN32 AND PY_VERSION VERSION_GREATER_EQUAL "3.11")
    set(PYTHONPATH "${EXTRA_PYTHONPATH}\\\;${LIBDIR}\\\\lib-dynload")
    set(PYTHONPATH "${PYTHONPATH}\\\;${LIBDIR}\\\\lib-dynload\\\\$<CONFIG>")

    set(_wide_char_modifier "L")

    set_property(
        SOURCE ${SRC_DIR}/Modules/getpath.c
        PROPERTY COMPILE_DEFINITIONS
            PREFIX=NULL
            EXEC_PREFIX=NULL
            VERSION="${PY_VERSION_MAJOR}.${PY_VERSION_MINOR}"
            VPATH="..\\\\.."
            PYDEBUGEXT="$<$<CONFIG:Debug>:_d>"
            PLATLIBDIR="${LIBDIR}"
            PYTHONPATH="${_wide_char_modifier}${PYTHONPATH}"
        )
    set_property(
        SOURCE ${SRC_DIR}/PC/dl_nt.c
        PROPERTY COMPILE_DEFINITIONS
            Py_ENABLE_SHARED
            MS_DLL_ID="${ms_dll_id}"
        )
endif()

# Build python libraries
function(add_libpython name type install component)
    add_library(${name} ${type} ${LIBPYTHON_SOURCES})
    target_link_libraries(${name} ${LIBPYTHON_TARGET_LIBRARIES})

    if(MSVC)
        # Explicitly disable COMDAT folding. Note that this was not required
        # in the original "pcbuild.sln" solution file because it was side effect
        # of having "/Zi" flag set.
        set_target_properties(${name} PROPERTIES LINK_FLAGS /OPT:NOICF)
    endif()

    set_target_properties(${name} PROPERTIES
        OUTPUT_NAME ${LIBPYTHON}${ABIFLAGS}
        LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/${LIBPYTHON_LIBDIR}
        RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/${LIBPYTHON_LIBDIR}
        INSTALL_NAME_DIR ${CMAKE_INSTALL_PREFIX}/${LIBPYTHON_LIBDIR}
    )
    set_target_properties(${name} PROPERTIES
        POSITION_INDEPENDENT_CODE ON
    )

    if(builtin_compile_definitions_without_py_limited_api)
        # Workaround for CMake issue #26993 (https://gitlab.kitware.com/cmake/cmake/-/issues/26993):
        # Explicitly propagate built-in extension definitions to this target.
        # These would otherwise be lost due to generator expression limitations in set_property().
        target_compile_definitions(${name} PRIVATE ${builtin_compile_definitions_without_py_limited_api})
    endif()

    # Export target
    set_property(GLOBAL APPEND PROPERTY PYTHON_TARGETS ${name})

    if(install)
        install(TARGETS ${name} EXPORT PythonTargets
            ARCHIVE DESTINATION ${LIBPYTHON_ARCHIVEDIR}
            LIBRARY DESTINATION ${LIBPYTHON_LIBDIR}
            RUNTIME DESTINATION ${LIBPYTHON_LIBDIR}
            COMPONENT ${component}
        )
    endif()
endfunction()

if(BUILD_LIBPYTHON_SHARED)
    add_libpython(libpython-shared SHARED 1 Runtime)
    set_target_properties(libpython-shared PROPERTIES
        ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/${LIBPYTHON_ARCHIVEDIR}
    )
    if(APPLE)
        # HACK For python <= 2.7.3, this fix link error related to undefined _environ symbol and
        #      is equivalent to solution implemented in commit http://hg.python.org/cpython/rev/864b983
        #      The property is set here because source file properties can't be in one directory
        #      and used to build a target in an other directory.
        set_property(
            SOURCE ${SRC_DIR}/Modules/posixmodule.c
            APPEND PROPERTY COMPILE_DEFINITIONS WITH_NEXT_FRAMEWORK)
    endif()

    set(targetname "libpython3-shared")

    if(MSVC AND PY_VERSION VERSION_LESS "3.10")
        # XXX Add BuildPython3_dDef

        # Generate 'python3stub.def'
        set(pythonstub_def ${PROJECT_BINARY_DIR}/${LIBPYTHON_ARCHIVEDIR}/${CMAKE_CFG_INTDIR}/python3stub.def)
        add_custom_command(
            OUTPUT ${pythonstub_def}
            COMMAND ${CMAKE_COMMAND}
                -DINPUT_DEF_FILE:PATH=${SRC_DIR}/PC/python3.def
                -DOUTPUT_DEF_FILE:PATH=${PROJECT_BINARY_DIR}/CMakeFiles/python3stub.def
                -P ${CMAKE_CURRENT_SOURCE_DIR}/generate_libpythonstub_def.cmake
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                ${PROJECT_BINARY_DIR}/CMakeFiles/python3stub.def
                ${pythonstub_def}
        )
        add_custom_target(generate_libpython3stub_def DEPENDS ${pythonstub_def})

        # Build 'python3stub.lib' before linking 'python3.dll'
        set(python3stub_lib ${PROJECT_BINARY_DIR}/${LIBPYTHON_ARCHIVEDIR}/${CMAKE_CFG_INTDIR}/python3stub.lib)
        set(machine X86)
        if(${CMAKE_SIZEOF_VOID_P} EQUAL 8)
            set(machine X64)
        endif()
        add_custom_command(
            OUTPUT ${python3stub_lib}
            COMMAND lib /nologo /def:${pythonstub_def} /out:${python3stub_lib} /MACHINE:${machine}
            COMMENT "Rebuilding python3stub.lib"
            DEPENDS generate_libpython3stub_def
            VERBATIM
        )
        add_custom_target(generate_libpython3stub_lib DEPENDS ${python3stub_lib})
    endif()

    if(MSVC)
        # Build 'python3.dll'
        add_library(${targetname} SHARED
            ${SRC_DIR}/PC/python3dll.c

            # Removed in Python 3.10
            $<$<VERSION_LESS:${PY_VERSION},3.10>:${SRC_DIR}/PC/python3.def>
        )
        set_target_properties(${targetname} PROPERTIES
            OUTPUT_NAME python3
            LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/${LIBPYTHON_LIBDIR}
            RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/${LIBPYTHON_LIBDIR}
            INSTALL_NAME_DIR ${CMAKE_INSTALL_PREFIX}/${LIBPYTHON_LIBDIR}
        )
        if(PY_VERSION VERSION_LESS "3.10")
            add_dependencies(${targetname} generate_libpython3stub_lib)
        endif()

        target_link_libraries(${targetname}
            libpython-shared

            # Removed in Python 3.10
            $<$<VERSION_LESS:${PY_VERSION},3.10>:${python3stub_lib}>
        )

        if(PY_VERSION VERSION_GREATER_EQUAL "3.10")
            set_property(
                SOURCE ${SRC_DIR}/PC/python3dll.c
                PROPERTY COMPILE_DEFINITIONS
                    "PYTHON_DLL_NAME=\"python${PY_VERSION_MAJOR}${PY_VERSION_MINOR}$<$<CONFIG:Debug>:_d>\""
                )
        endif()
    endif()

    if(UNIX AND NOT APPLE)
        add_library(${targetname} SHARED ${PROJECT_SOURCE_DIR}/cmake/empty.c)
        set_target_properties(${targetname} PROPERTIES
            LINK_FLAGS "-Wl,--no-as-needed"
            OUTPUT_NAME python3
            LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/${LIBPYTHON_LIBDIR}
            RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/${LIBPYTHON_LIBDIR}
            INSTALL_NAME_DIR ${CMAKE_INSTALL_PREFIX}/${LIBPYTHON_LIBDIR}
        )
        target_link_libraries(${targetname} libpython-shared)
    endif()

    # Export target
    if(TARGET ${targetname})
        set_property(GLOBAL APPEND PROPERTY PYTHON_TARGETS ${targetname})

        install(TARGETS ${targetname} EXPORT PythonTargets
            ARCHIVE DESTINATION ${LIBPYTHON_ARCHIVEDIR}
            LIBRARY DESTINATION ${LIBPYTHON_LIBDIR}
            RUNTIME DESTINATION ${LIBPYTHON_LIBDIR}
        )
    endif()

endif()

if(NOT BUILD_LIBPYTHON_SHARED)
    add_libpython(libpython-static STATIC ${INSTALL_DEVELOPMENT} Development)
    target_compile_definitions(libpython-static
        PUBLIC
            Py_NO_ENABLE_SHARED
    )
    set_target_properties(libpython-static PROPERTIES
        ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/${LIBPYTHON_STATIC_ARCHIVEDIR}
    )
    if(INSTALL_DEVELOPMENT)
        install(TARGETS libpython-static
            ARCHIVE DESTINATION ${PYTHONHOME}/config/
            COMPONENT Development)
    endif()
endif()
