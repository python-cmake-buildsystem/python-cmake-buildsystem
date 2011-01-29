add_definitions(-DPy_BUILD_CORE)
add_definitions(-DNDEBUG)

add_definitions(-DPREFIX="${CMAKE_INSTALL_PREFIX}")
add_definitions(-DEXEC_PREFIX="${CMAKE_INSTALL_PREFIX}")
add_definitions(-DVERSION="${LIBPYTHON_VERSION}")
add_definitions(-DVPATH="")
add_definitions(-DPYTHONPATH=":plat-linux2:lib-tk:lib-old")
add_definitions(-DPLATFORM="linux2")

set(LIBPYTHON_SOURCES
    ${CMAKE_SOURCE_DIR}/Modules/_codecsmodule.c
    ${CMAKE_SOURCE_DIR}/Modules/config.c
    ${CMAKE_SOURCE_DIR}/Modules/errnomodule.c
    ${CMAKE_SOURCE_DIR}/Modules/gcmodule.c
    ${CMAKE_SOURCE_DIR}/Modules/getbuildinfo.c
    ${CMAKE_SOURCE_DIR}/Modules/getpath.c
    ${CMAKE_SOURCE_DIR}/Modules/main.c
    ${CMAKE_SOURCE_DIR}/Modules/posixmodule.c
    ${CMAKE_SOURCE_DIR}/Modules/pwdmodule.c
    ${CMAKE_SOURCE_DIR}/Modules/signalmodule.c
    ${CMAKE_SOURCE_DIR}/Modules/_sre.c
    ${CMAKE_SOURCE_DIR}/Modules/symtablemodule.c
    ${CMAKE_SOURCE_DIR}/Modules/threadmodule.c
    ${CMAKE_SOURCE_DIR}/Modules/_weakref.c
    ${CMAKE_SOURCE_DIR}/Modules/xxsubtype.c
    ${CMAKE_SOURCE_DIR}/Modules/zipimport.c
    ${CMAKE_SOURCE_DIR}/Objects/abstract.c
    ${CMAKE_SOURCE_DIR}/Objects/boolobject.c
    ${CMAKE_SOURCE_DIR}/Objects/bufferobject.c
    ${CMAKE_SOURCE_DIR}/Objects/bytearrayobject.c
    ${CMAKE_SOURCE_DIR}/Objects/bytes_methods.c
    ${CMAKE_SOURCE_DIR}/Objects/capsule.c
    ${CMAKE_SOURCE_DIR}/Objects/cellobject.c
    ${CMAKE_SOURCE_DIR}/Objects/classobject.c
    ${CMAKE_SOURCE_DIR}/Objects/cobject.c
    ${CMAKE_SOURCE_DIR}/Objects/codeobject.c
    ${CMAKE_SOURCE_DIR}/Objects/complexobject.c
    ${CMAKE_SOURCE_DIR}/Objects/descrobject.c
    ${CMAKE_SOURCE_DIR}/Objects/dictobject.c
    ${CMAKE_SOURCE_DIR}/Objects/enumobject.c
    ${CMAKE_SOURCE_DIR}/Objects/exceptions.c
    ${CMAKE_SOURCE_DIR}/Objects/fileobject.c
    ${CMAKE_SOURCE_DIR}/Objects/floatobject.c
    ${CMAKE_SOURCE_DIR}/Objects/frameobject.c
    ${CMAKE_SOURCE_DIR}/Objects/funcobject.c
    ${CMAKE_SOURCE_DIR}/Objects/genobject.c
    ${CMAKE_SOURCE_DIR}/Objects/intobject.c
    ${CMAKE_SOURCE_DIR}/Objects/iterobject.c
    ${CMAKE_SOURCE_DIR}/Objects/listobject.c
    ${CMAKE_SOURCE_DIR}/Objects/longobject.c
    ${CMAKE_SOURCE_DIR}/Objects/memoryobject.c
    ${CMAKE_SOURCE_DIR}/Objects/methodobject.c
    ${CMAKE_SOURCE_DIR}/Objects/moduleobject.c
    ${CMAKE_SOURCE_DIR}/Objects/object.c
    ${CMAKE_SOURCE_DIR}/Objects/obmalloc.c
    ${CMAKE_SOURCE_DIR}/Objects/rangeobject.c
    ${CMAKE_SOURCE_DIR}/Objects/setobject.c
    ${CMAKE_SOURCE_DIR}/Objects/sliceobject.c
    ${CMAKE_SOURCE_DIR}/Objects/stringobject.c
    ${CMAKE_SOURCE_DIR}/Objects/structseq.c
    ${CMAKE_SOURCE_DIR}/Objects/tupleobject.c
    ${CMAKE_SOURCE_DIR}/Objects/typeobject.c
    ${CMAKE_SOURCE_DIR}/Objects/unicodectype.c
    ${CMAKE_SOURCE_DIR}/Objects/unicodeobject.c
    ${CMAKE_SOURCE_DIR}/Objects/weakrefobject.c
    ${CMAKE_SOURCE_DIR}/Parser/acceler.c
    ${CMAKE_SOURCE_DIR}/Parser/bitset.c
    ${CMAKE_SOURCE_DIR}/Parser/firstsets.c
    ${CMAKE_SOURCE_DIR}/Parser/grammar1.c
    ${CMAKE_SOURCE_DIR}/Parser/grammar.c
    ${CMAKE_SOURCE_DIR}/Parser/listnode.c
    ${CMAKE_SOURCE_DIR}/Parser/metagrammar.c
    ${CMAKE_SOURCE_DIR}/Parser/myreadline.c
    ${CMAKE_SOURCE_DIR}/Parser/node.c
    ${CMAKE_SOURCE_DIR}/Parser/parser.c
    ${CMAKE_SOURCE_DIR}/Parser/parsetok.c
    ${CMAKE_SOURCE_DIR}/Parser/pgen.c
    ${CMAKE_SOURCE_DIR}/Parser/tokenizer.c
    ${CMAKE_SOURCE_DIR}/Python/asdl.c
    ${CMAKE_SOURCE_DIR}/Python/ast.c
    ${CMAKE_SOURCE_DIR}/Python/bltinmodule.c
    ${CMAKE_SOURCE_DIR}/Python/ceval.c
    ${CMAKE_SOURCE_DIR}/Python/codecs.c
    ${CMAKE_SOURCE_DIR}/Python/compile.c
    ${CMAKE_SOURCE_DIR}/Python/dtoa.c
    ${CMAKE_SOURCE_DIR}/Python/dynload_shlib.c
    ${CMAKE_SOURCE_DIR}/Python/errors.c
    ${CMAKE_SOURCE_DIR}/Python/formatter_string.c
    ${CMAKE_SOURCE_DIR}/Python/formatter_unicode.c
    ${CMAKE_SOURCE_DIR}/Python/frozen.c
    ${CMAKE_SOURCE_DIR}/Python/frozenmain.c
    ${CMAKE_SOURCE_DIR}/Python/future.c
    ${CMAKE_SOURCE_DIR}/Python/getargs.c
    ${CMAKE_SOURCE_DIR}/Python/getcompiler.c
    ${CMAKE_SOURCE_DIR}/Python/getcopyright.c
    ${CMAKE_SOURCE_DIR}/Python/getopt.c
    ${CMAKE_SOURCE_DIR}/Python/getplatform.c
    ${CMAKE_SOURCE_DIR}/Python/getversion.c
    ${CMAKE_SOURCE_DIR}/Python/graminit.c
    ${CMAKE_SOURCE_DIR}/Python/import.c
    ${CMAKE_SOURCE_DIR}/Python/importdl.c
    ${CMAKE_SOURCE_DIR}/Python/marshal.c
    ${CMAKE_SOURCE_DIR}/Python/modsupport.c
    ${CMAKE_SOURCE_DIR}/Python/mysnprintf.c
    ${CMAKE_SOURCE_DIR}/Python/mystrtoul.c
    ${CMAKE_SOURCE_DIR}/Python/peephole.c
    ${CMAKE_SOURCE_DIR}/Python/pyarena.c
    ${CMAKE_SOURCE_DIR}/Python/pyctype.c
    ${CMAKE_SOURCE_DIR}/Python/pyfpe.c
    ${CMAKE_SOURCE_DIR}/Python/pymath.c
    ${CMAKE_SOURCE_DIR}/Python/pystate.c
    ${CMAKE_SOURCE_DIR}/Python/pystrcmp.c
    ${CMAKE_SOURCE_DIR}/Python/pystrtod.c
    ${CMAKE_SOURCE_DIR}/Python/Python-ast.c
    ${CMAKE_SOURCE_DIR}/Python/pythonrun.c
    ${CMAKE_SOURCE_DIR}/Python/structmember.c
    ${CMAKE_SOURCE_DIR}/Python/symtable.c
    ${CMAKE_SOURCE_DIR}/Python/sysmodule.c
    ${CMAKE_SOURCE_DIR}/Python/thread.c
    ${CMAKE_SOURCE_DIR}/Python/traceback.c
    ${CMAKE_SOURCE_DIR}/Python/_warnings.c
)

function (add_libpython name type)
    add_library(${name} ${type} ${LIBPYTHON_SOURCES})
    target_link_libraries(${name}
        ${CMAKE_THREAD_LIBS_INIT}
        dl
        m
        util
    )
    set_target_properties(${name} PROPERTIES OUTPUT_NAME ${LIBPYTHON})
    install(TARGETS ${name}
        ARCHIVE DESTINATION lib
        LIBRARY DESTINATION lib
    )
endfunction (add_libpython)

if (ENABLE_SHARED)
    add_libpython(libpython-shared SHARED)
endif (ENABLE_SHARED)

if (ENABLE_STATIC)
    add_libpython(libpython-static STATIC)
endif (ENABLE_STATIC)
