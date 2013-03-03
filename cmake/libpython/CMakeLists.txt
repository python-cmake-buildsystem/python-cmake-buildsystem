add_definitions(-DPy_BUILD_CORE)
add_definitions(-DNDEBUG)

set(LIBPYTHON_SOURCES
    ${CMAKE_SOURCE_DIR}/cmake/config.c
    ${SRC_DIR}/Modules/_codecsmodule.c
    ${SRC_DIR}/Modules/errnomodule.c
    ${SRC_DIR}/Modules/gcmodule.c
    ${SRC_DIR}/Modules/getbuildinfo.c
    ${SRC_DIR}/Modules/main.c
    ${SRC_DIR}/Modules/signalmodule.c
    ${SRC_DIR}/Modules/_sre.c
    ${SRC_DIR}/Modules/symtablemodule.c
    ${SRC_DIR}/Modules/_weakref.c
    ${SRC_DIR}/Modules/xxsubtype.c
    ${SRC_DIR}/Modules/zipimport.c
    ${SRC_DIR}/Objects/abstract.c
    ${SRC_DIR}/Objects/boolobject.c
    ${SRC_DIR}/Objects/bufferobject.c
    ${SRC_DIR}/Objects/bytearrayobject.c
    ${SRC_DIR}/Objects/bytes_methods.c
    ${SRC_DIR}/Objects/capsule.c
    ${SRC_DIR}/Objects/cellobject.c
    ${SRC_DIR}/Objects/classobject.c
    ${SRC_DIR}/Objects/cobject.c
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
    ${SRC_DIR}/Objects/intobject.c
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
    ${SRC_DIR}/Objects/stringobject.c
    ${SRC_DIR}/Objects/structseq.c
    ${SRC_DIR}/Objects/tupleobject.c
    ${SRC_DIR}/Objects/typeobject.c
    ${SRC_DIR}/Objects/unicodectype.c
    ${SRC_DIR}/Objects/unicodeobject.c
    ${SRC_DIR}/Objects/weakrefobject.c
    ${SRC_DIR}/Parser/acceler.c
    ${SRC_DIR}/Parser/bitset.c
    ${SRC_DIR}/Parser/firstsets.c
    ${SRC_DIR}/Parser/grammar1.c
    ${SRC_DIR}/Parser/grammar.c
    ${SRC_DIR}/Parser/listnode.c
    ${SRC_DIR}/Parser/metagrammar.c
    ${SRC_DIR}/Parser/myreadline.c
    ${SRC_DIR}/Parser/node.c
    ${SRC_DIR}/Parser/parser.c
    ${SRC_DIR}/Parser/parsetok.c
    ${SRC_DIR}/Parser/pgen.c
    ${SRC_DIR}/Parser/tokenizer.c
    ${SRC_DIR}/Python/asdl.c
    ${SRC_DIR}/Python/ast.c
    ${SRC_DIR}/Python/bltinmodule.c
    ${SRC_DIR}/Python/ceval.c
    ${SRC_DIR}/Python/codecs.c
    ${SRC_DIR}/Python/compile.c
    ${SRC_DIR}/Python/dtoa.c
    ${SRC_DIR}/Python/errors.c
    ${SRC_DIR}/Python/formatter_string.c
    ${SRC_DIR}/Python/formatter_unicode.c
    ${SRC_DIR}/Python/frozen.c
    ${SRC_DIR}/Python/future.c
    ${SRC_DIR}/Python/getargs.c
    ${SRC_DIR}/Python/getcompiler.c
    ${SRC_DIR}/Python/getcopyright.c
    ${SRC_DIR}/Python/getopt.c
    ${SRC_DIR}/Python/getplatform.c
    ${SRC_DIR}/Python/getversion.c
    ${SRC_DIR}/Python/graminit.c
    ${SRC_DIR}/Python/import.c
    ${SRC_DIR}/Python/importdl.c
    ${SRC_DIR}/Python/marshal.c
    ${SRC_DIR}/Python/modsupport.c
    ${SRC_DIR}/Python/mysnprintf.c
    ${SRC_DIR}/Python/mystrtoul.c
    ${SRC_DIR}/Python/peephole.c
    ${SRC_DIR}/Python/pyarena.c
    ${SRC_DIR}/Python/pyctype.c
    ${SRC_DIR}/Python/pyfpe.c
    ${SRC_DIR}/Python/pymath.c
    ${SRC_DIR}/Python/pystate.c
    ${SRC_DIR}/Python/pystrcmp.c
    ${SRC_DIR}/Python/pystrtod.c
    ${SRC_DIR}/Python/Python-ast.c
    ${SRC_DIR}/Python/pythonrun.c
    ${SRC_DIR}/Python/random.c
    ${SRC_DIR}/Python/structmember.c
    ${SRC_DIR}/Python/symtable.c
    ${SRC_DIR}/Python/sysmodule.c
    ${SRC_DIR}/Python/traceback.c
    ${SRC_DIR}/Python/_warnings.c
    ${builtin_source}
)

if(UNIX)
    foreach(filename class complex float int method string type unicode weakref)
        set_property(SOURCE ${SRC_DIR}/Objects/${filename}object.c PROPERTY COMPILE_FLAGS -Wno-unused-value)
    endforeach()
endif(UNIX)

if(WITH_THREAD)
    list(APPEND LIBPYTHON_SOURCES
        ${SRC_DIR}/Modules/threadmodule.c
        ${SRC_DIR}/Python/thread.c
    )
endif()

if(UNIX OR MINGW)
    set_property(
        SOURCE ${SRC_DIR}/Python/getplatform.c
        PROPERTY COMPILE_DEFINITIONS
            PLATFORM="${PY_PLATFORM}"
    )
endif(UNIX OR MINGW)

# Platform-specific source files
if(UNIX)
    list(APPEND LIBPYTHON_SOURCES
        ${SRC_DIR}/Python/dynload_shlib.c
        ${SRC_DIR}/Modules/getpath.c
    )
    set_property(
        SOURCE ${SRC_DIR}/Modules/getpath.c
        PROPERTY COMPILE_FLAGS
            -Wno-deprecated-declarations
        )
    set_property(
        SOURCE ${SRC_DIR}/Modules/getpath.c
        PROPERTY COMPILE_DEFINITIONS
            PREFIX="${CMAKE_INSTALL_PREFIX}"
            EXEC_PREFIX="${CMAKE_INSTALL_PREFIX}"
            VERSION="${PY_VERSION_MAJOR}.${PY_VERSION_MINOR}"
            VPATH="."
            PYTHONPATH="${EXTRA_PYTHONPATH}:lib-dynload:plat-${PY_PLATFORM}"
      )
elseif(WIN32)
    list(APPEND LIBPYTHON_SOURCES
        ${SRC_DIR}/PC/dl_nt.c
        ${SRC_DIR}/PC/getpathp.c
        ${SRC_DIR}/PC/import_nt.c
        ${SRC_DIR}/Python/dynload_win.c
    )
    string(REPLACE "/" "\\\\" PYTHONHOME_ESCAPED ${PYTHONHOME})
    string(REPLACE "/" "\\\\" DYNLOAD_ESCAPED ${DYNLOAD})
    set(PYTHONPATH "${EXTRA_PYTHONPATH}")
    set(PYTHONPATH "${PYTHONPATH};.\\\\${PYTHONHOME_ESCAPED}")
    set(PYTHONPATH "${PYTHONPATH};.\\\\${DYNLOAD_ESCAPED}")
    set(PYTHONPATH "${PYTHONPATH};.\\\\${DYNLOAD_ESCAPED}\\\\${CMAKE_CFG_INTDIR}")
    set(PYTHONPATH "${PYTHONPATH};.\\\\${PYTHONHOME_ESCAPED}\\\\plat-${PY_PLATFORM}")
    set_property(
        SOURCE ${SRC_DIR}/PC/getpathp.c
        PROPERTY COMPILE_DEFINITIONS
            LANDMARK="${PYTHONHOME_ESCAPED}\\\\os.py"
            PYTHONPATH="${PYTHONPATH}"
    )
    set_property(
        SOURCE ${SRC_DIR}/PC/dl_nt.c
        PROPERTY COMPILE_DEFINITIONS Py_ENABLE_SHARED
    )
endif(UNIX)

# Create the parts of config.c for platform-specific and user-controlled
# builtin modules.
set(config_inits_file ${CMAKE_CURRENT_BINARY_DIR}/platform-config-inits.c)
set(config_entries_file ${CMAKE_CURRENT_BINARY_DIR}/platform-config-entries.c)
include_directories(${CMAKE_CURRENT_BINARY_DIR})
include_directories(${builtin_includedirs})

file(WRITE "${config_inits_file}" "")
file(WRITE "${config_entries_file}" "")

foreach(ext ${builtin_extensions})
    file(APPEND "${config_inits_file}" "extern void init${ext}(void);\n")
    file(APPEND "${config_entries_file}" "{\"${ext}\", init${ext}},\n")
endforeach(ext)


function(add_libpython name type)
    add_library(${name} ${type} ${LIBPYTHON_SOURCES})
    target_link_libraries(${name}
        ${builtin_link_libraries}
        ${HAVE_LIBDL}
        ${HAVE_LIBM}
    )
    if(WITH_THREAD)
        target_link_libraries(${name} ${CMAKE_THREAD_LIBS_INIT})
    endif(WITH_THREAD)

    if(UNIX)
        target_link_libraries(${name} ${HAVE_LIBUTIL})
    endif(UNIX)
    
    if(APPLE)
        set_target_properties(${name} PROPERTIES LINK_FLAGS -Wl,-undefined,dynamic_lookup)
    endif(APPLE)

    set_target_properties(${name} PROPERTIES
        OUTPUT_NAME ${LIBPYTHON}
        LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${LIBPYTHON_LIBDIR}
        RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${LIBPYTHON_LIBDIR}
    )

    if(builtin_definitions)
        set_target_properties(${name} PROPERTIES COMPILE_DEFINITIONS "${builtin_definitions}")
    endif(builtin_definitions)

    # Export target
    set_property(GLOBAL APPEND PROPERTY PYTHON_TARGETS ${name})

    install(TARGETS ${name} EXPORT PythonTargets
        ARCHIVE DESTINATION ${LIBPYTHON_ARCHIVEDIR}
        LIBRARY DESTINATION ${LIBPYTHON_LIBDIR}
        RUNTIME DESTINATION ${LIBPYTHON_LIBDIR}
    )
endfunction(add_libpython)

if(ENABLE_SHARED)
    add_libpython(libpython-shared SHARED)
    set_target_properties(libpython-shared PROPERTIES
        ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${LIBPYTHON_ARCHIVEDIR}
    )
endif(ENABLE_SHARED)

if(ENABLE_STATIC)
    add_libpython(libpython-static STATIC)
    set_target_properties(libpython-static PROPERTIES
        COMPILE_DEFINITIONS Py_NO_ENABLE_SHARED
        ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${LIBPYTHON_STATIC_ARCHIVEDIR}
    )
endif(ENABLE_STATIC)
