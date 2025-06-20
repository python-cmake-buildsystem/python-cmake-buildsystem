set(WIN32_BUILTIN )
if(WIN32)
    set(WIN32_BUILTIN BUILTIN)
endif()

# Boolean variables intended to be associated with the REQUIRES argument of add_python_extension
set(IS_PY_LESS_3_8 0)
if(PY_VERSION VERSION_LESS "3.8")
    set(IS_PY_LESS_3_8 1)
endif()
set(IS_PY_LESS_3_10 0)
if(PY_VERSION VERSION_LESS "3.10")
    set(IS_PY_LESS_3_10 1)
endif()
set(IS_PY_LESS_3_12 0)
if(PY_VERSION VERSION_LESS "3.12")
    set(IS_PY_LESS_3_12 1)
endif()

set(IS_PY3_3_OR_GREATER 0)
if(PY_VERSION VERSION_GREATER_EQUAL "3.3")
    set(IS_PY3_3_OR_GREATER 1)
endif()
set(IS_PY3_4_OR_GREATER 0)
if(PY_VERSION VERSION_GREATER_EQUAL "3.4")
    set(IS_PY3_4_OR_GREATER 1)
endif()
set(IS_PY3_5_OR_GREATER 0)
if(PY_VERSION VERSION_GREATER_EQUAL "3.5")
    set(IS_PY3_5_OR_GREATER 1)
endif()
set(IS_PY3_6_OR_GREATER 0)
if(PY_VERSION VERSION_GREATER_EQUAL "3.6")
    set(IS_PY3_6_OR_GREATER 1)
endif()
set(IS_PY3_7_OR_GREATER 0)
if(PY_VERSION VERSION_GREATER_EQUAL "3.7")
    set(IS_PY3_7_OR_GREATER 1)
endif()
set(IS_PY3_8_OR_GREATER 0)
if(PY_VERSION VERSION_GREATER_EQUAL "3.8")
    set(IS_PY3_8_OR_GREATER 1)
endif()
set(IS_PY3_9_OR_GREATER 0)
if(PY_VERSION VERSION_GREATER_EQUAL "3.9")
    set(IS_PY3_9_OR_GREATER 1)
endif()
set(IS_PY3_12_OR_GREATER 0)
if(PY_VERSION VERSION_GREATER_EQUAL "3.12")
    set(IS_PY3_12_OR_GREATER 1)
endif()

add_python_extension(array ${WIN32_BUILTIN} SOURCES arraymodule.c)
add_python_extension(audioop ${WIN32_BUILTIN}
    REQUIRES
        HAVE_LIBM
    SOURCES
        audioop.c
    LIBRARIES
        ${M_LIBRARIES}
)
add_python_extension(_bisect ${WIN32_BUILTIN} SOURCES _bisectmodule.c)
add_python_extension(cmath
    REQUIRES HAVE_LIBM ${WIN32_BUILTIN}
    SOURCES
        $<$<VERSION_LESS:${PY_VERSION},3.11>:_math.c>
        cmathmodule.c
    LIBRARIES
        ${M_LIBRARIES})
add_python_extension(_codecs_cn ${WIN32_BUILTIN} SOURCES cjkcodecs/_codecs_cn.c)
add_python_extension(_codecs_hk ${WIN32_BUILTIN} SOURCES cjkcodecs/_codecs_hk.c)
add_python_extension(_codecs_iso2022 ${WIN32_BUILTIN} SOURCES cjkcodecs/_codecs_iso2022.c)
add_python_extension(_codecs_jp ${WIN32_BUILTIN} SOURCES cjkcodecs/_codecs_jp.c)
add_python_extension(_codecs_kr ${WIN32_BUILTIN} SOURCES cjkcodecs/_codecs_kr.c)
add_python_extension(_codecs_tw ${WIN32_BUILTIN} SOURCES cjkcodecs/_codecs_tw.c)
add_python_extension(_collections ${WIN32_BUILTIN} BUILTIN SOURCES _collectionsmodule.c) # Container types

set(crypt_NAME _crypt)
if(PY_VERSION VERSION_LESS 3.3)
    set(crypt_NAME crypt)
endif()
add_python_extension(${crypt_NAME}
    REQUIRES
        HAVE_LIBCRYPT
    SOURCES
        ${crypt_NAME}module.c
    LIBRARIES
        ${HAVE_LIBCRYPT}
)

add_python_extension(_csv ${WIN32_BUILTIN} SOURCES _csv.c)
add_python_extension(_ctypes_test NEVER_BUILTIN REQUIRES HAVE_LIBM SOURCES _ctypes/_ctypes_test.c LIBRARIES ${M_LIBRARIES})

add_python_extension(_datetime ${WIN32_BUILTIN}
    REQUIRES
        HAVE_LIBM
    SOURCES
        _datetimemodule.c
        $<$<VERSION_LESS_EQUAL:${PY_VERSION},3.1>:timemodule.c>
        $<$<VERSION_EQUAL:${PY_VERSION_MAJOR}.${PY_VERSION_MINOR},3.2>:_time.c>
    LIBRARIES
        ${M_LIBRARIES}
)
#if(ENABLE_DATETIME AND CMAKE_C_COMPILER_ID MATCHES GNU)
#    set_property(SOURCE ${SRC_DIR}/Modules/datetimemodule.c PROPERTY COMPILE_FLAGS -Wno-unused-value)
#endif()

add_python_extension(_functools ${WIN32_BUILTIN} BUILTIN SOURCES _functoolsmodule.c DEFINITIONS Py_BUILD_CORE) # Tools for working with functions and callable objects
add_python_extension(_heapq ${WIN32_BUILTIN} SOURCES _heapqmodule.c)

set(_io_SOURCES
    _io/_iomodule.c
    _io/bufferedio.c
    _io/bytesio.c
    _io/fileio.c
    _io/iobase.c
    _io/stringio.c
    _io/textio.c
    )
if(WIN32 AND EXISTS ${SRC_DIR}/Modules/_io/winconsoleio.c)
    list(APPEND _io_SOURCES
        ${SRC_DIR}/Modules/_io/winconsoleio.c
        )
endif()
add_python_extension(_io ${WIN32_BUILTIN} ALWAYS_BUILTIN SOURCES ${_io_SOURCES} DEFINITIONS Py_BUILD_CORE)

add_python_extension(itertools ${WIN32_BUILTIN} BUILTIN SOURCES itertoolsmodule.c) # Functions creating iterators for efficient looping
add_python_extension(_json ${WIN32_BUILTIN} SOURCES _json.c)
add_python_extension(_locale ${WIN32_BUILTIN} BUILTIN SOURCES _localemodule.c) # access to ISO C locale support
add_python_extension(_lsprof ${WIN32_BUILTIN} SOURCES _lsprof.c rotatingtree.c)
add_python_extension(math ${WIN32_BUILTIN}
    REQUIRES
        HAVE_LIBM
    SOURCES
        $<$<VERSION_LESS:${PY_VERSION},3.11>:_math.c>
        mathmodule.c
    LIBRARIES
        ${M_LIBRARIES}
)
add_python_extension(mmap ${WIN32_BUILTIN} SOURCES mmapmodule.c)
add_python_extension(_multibytecodec ${WIN32_BUILTIN} SOURCES cjkcodecs/multibytecodec.c)
add_python_extension(parser ${WIN32_BUILTIN}
    REQUIRES
        IS_PY_LESS_3_10
    SOURCES
        parsermodule.c
)
add_python_extension(_random ${WIN32_BUILTIN} SOURCES _randommodule.c)
add_python_extension(_struct ${WIN32_BUILTIN} SOURCES _struct.c)

add_python_extension(_testcapi NEVER_BUILTIN
    SOURCES
        _testcapimodule.c

        # Introduced in Python 3.12
        $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:_testcapi/abstract.c>
        $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:_testcapi/buffer.c>
        $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:_testcapi/bytes.c>
        $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:_testcapi/code.c>
        $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:_testcapi/codec.c>
        $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:_testcapi/complex.c>
        $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:_testcapi/datetime.c>
        $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:_testcapi/dict.c>
        $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:_testcapi/docstring.c>
        $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:_testcapi/exceptions.c>
        $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:_testcapi/file.c>
        $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:_testcapi/float.c>
        $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:_testcapi/gc.c>
        $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:_testcapi/getargs.c>
        $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:_testcapi/heaptype.c>
        $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:_testcapi/immortal.c>
        $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:_testcapi/list.c>
        $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:_testcapi/long.c>
        $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:_testcapi/mem.c>
        $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:_testcapi/numbers.c>
        $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:_testcapi/run.c>
        $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:_testcapi/set.c>
        $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:_testcapi/structmember.c>
        $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:_testcapi/tuple.c>
        $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:_testcapi/unicode.c>
        $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:_testcapi/vectorcall.c>
        $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:_testcapi/watchers.c>

        # Introduced in Python 3.12 and removed in 3.13
        $<$<VERSION_EQUAL:${PY_VERSION_MAJOR}.${PY_VERSION_MINOR},3.12>:_testcapi/bytearray.c>
        $<$<VERSION_EQUAL:${PY_VERSION_MAJOR}.${PY_VERSION_MINOR},3.12>:_testcapi/eval.c>
        $<$<VERSION_EQUAL:${PY_VERSION_MAJOR}.${PY_VERSION_MINOR},3.12>:_testcapi/heaptype_relative.c>
        $<$<VERSION_EQUAL:${PY_VERSION_MAJOR}.${PY_VERSION_MINOR},3.12>:_testcapi/import.c>
        $<$<VERSION_EQUAL:${PY_VERSION_MAJOR}.${PY_VERSION_MINOR},3.12>:_testcapi/pyos.c>
        $<$<VERSION_EQUAL:${PY_VERSION_MAJOR}.${PY_VERSION_MINOR},3.12>:_testcapi/pytime.c>
        $<$<VERSION_EQUAL:${PY_VERSION_MAJOR}.${PY_VERSION_MINOR},3.12>:_testcapi/sys.c>
        $<$<VERSION_EQUAL:${PY_VERSION_MAJOR}.${PY_VERSION_MINOR},3.12>:_testcapi/vectorcall_limited.c>
)

set(thread_REQUIRES)
if(PY_VERSION VERSION_LESS "3.7")
  list(APPEND thread_REQUIRES WITH_THREAD)
endif()
add_python_extension(_thread ALWAYS_BUILTIN
    REQUIRES
        ${thread_REQUIRES}
    SOURCES
        ${SRC_DIR}/Modules/_threadmodule.c
    DEFINITIONS
        Py_BUILD_CORE
)

add_python_extension(time ${WIN32_BUILTIN} BUILTIN
    REQUIRES
        HAVE_LIBM
    SOURCES
        timemodule.c
        $<$<VERSION_EQUAL:${PY_VERSION_MAJOR}.${PY_VERSION_MINOR},3.2>:_time.c>
    DEFINITIONS
        Py_BUILD_CORE
    LIBRARIES
        ${M_LIBRARIES}
        ${TIMEMODULE_LIB}
)

add_python_extension(unicodedata SOURCES unicodedata.c)

# Register functions to be run at interpreter-shutdown
add_python_extension(atexit BUILTIN
    REQUIRES
    SOURCES
        atexitmodule.c
)
add_python_extension(_codecs BUILTIN SOURCES _codecsmodule.c) # access to the builtin codecs and codec registry
set(operator_NAME _operator)
if(PY_VERSION VERSION_LESS 3.4)
    set(operator_NAME operator)
endif()
add_python_extension(${operator_NAME} BUILTIN REQUIRES SOURCES ${operator_NAME}.c)
add_python_extension(faulthandler ALWAYS_BUILTIN
    REQUIRES IS_PY3_3_OR_GREATER
    SOURCES faulthandler.c
)
add_python_extension(_opcode ${WIN32_BUILTIN}
    REQUIRES IS_PY3_4_OR_GREATER
    SOURCES _opcode.c
)

add_python_extension(_pickle ${WIN32_BUILTIN} REQUIRES SOURCES _pickle.c)

# Fredrik Lundh's new regular expressions
add_python_extension(_sre BUILTIN
    SOURCES
        $<$<VERSION_LESS:${PY_VERSION},3.11>:_sre.c>
        $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.11>:_sre/sre.c>
)

# stat.h interface
add_python_extension(_stat BUILTIN
    REQUIRES IS_PY3_4_OR_GREATER
    SOURCES _stat.c
)

add_python_extension(_symtable BUILTIN SOURCES symtablemodule.c)

# Python PEP-3118 (buffer protocol) test module
add_python_extension(_testbuffer
    REQUIRES IS_PY3_3_OR_GREATER
    SOURCES _testbuffer.c
)

# Test loading multiple modules from one compiled file (http://bugs.python.org/issue16421)
add_python_extension(_testimportmultiple
    REQUIRES IS_PY3_4_OR_GREATER
    SOURCES _testimportmultiple.c
)
# Test multi-phase extension module init (PEP 489)
add_python_extension(_testmultiphase
    REQUIRES IS_PY3_5_OR_GREATER
    SOURCES _testmultiphase.c
)
# debug tool to trace memory blocks allocated by Python
add_python_extension(_tracemalloc ALWAYS_BUILTIN
    REQUIRES IS_PY3_4_OR_GREATER
    SOURCES
       ${SRC_DIR}/$<IF:$<VERSION_GREATER_EQUAL:${PY_VERSION},3.9>,Python,Modules>/hashtable.c
       _tracemalloc.c
)
add_python_extension(_weakref ALWAYS_BUILTIN SOURCES _weakref.c)
math(EXPR _limited_api_version "${PY_VERSION_MAJOR} * 100 + ${PY_VERSION_MINOR}")
add_python_extension(xxlimited REQUIRES BUILD_TESTING
    SOURCES xxlimited.c
    DEFINITIONS $<$<VERSION_LESS:${PY_VERSION},3.10>:Py_LIMITED_API=0x${_limited_api_version}0000>
    NO_INSTALL
)
add_python_extension(xxsubtype BUILTIN SOURCES xxsubtype.c)

# The zipimport module is always imported at startup. Having it as a
# builtin module avoids some bootstrapping problems and reduces overhead.
add_python_extension(zipimport ALWAYS_BUILTIN
    REQUIRES
        IS_PY_LESS_3_8
    SOURCES
        zipimport.c
    DEFINITIONS
        Py_BUILD_CORE
)

# Python 3.6
# asyncio speedups
add_python_extension(_asyncio
    REQUIRES
        IS_PY3_6_OR_GREATER
    SOURCES
        _asynciomodule.c
)
# blake module
set(_blake2_SOURCES
    _blake2/blake2module.c
    _blake2/blake2b_impl.c
    _blake2/blake2s_impl.c
)
add_python_extension(_blake2 ${WIN32_BUILTIN}
    REQUIRES
        IS_PY3_6_OR_GREATER
    SOURCES
        ${_blake2_SOURCES}
)
add_python_extension(_sha3 ${WIN32_BUILTIN}
    REQUIRES
        IS_PY3_6_OR_GREATER
        IS_PY_LESS_3_12
    SOURCES
        _sha3/sha3module.c
)
add_python_extension(_testconsole ${WIN32_BUILTIN}
    REQUIRES
        IS_PY3_6_OR_GREATER
        WIN32
    SOURCES
        ../PC/_testconsole.c
)

# Python 3.7
add_python_extension(_abc BUILTIN
    REQUIRES
        IS_PY3_7_OR_GREATER
    SOURCES
        _abc.c
)
add_python_extension(_contextvars ${WIN32_BUILTIN}
    REQUIRES
        IS_PY3_7_OR_GREATER
    SOURCES
        _contextvarsmodule.c
)
add_python_extension(_queue
    REQUIRES
        IS_PY3_7_OR_GREATER
    SOURCES
        _queuemodule.c
)
add_python_extension(_uuid
    REQUIRES
        IS_PY3_7_OR_GREATER
        UUID_LIBRARY
        "HAVE_UUID_H OR HAVE_UUID_UUID_H"
    SOURCES
        _uuidmodule.c
    LIBRARIES
        ${UUID_LIBRARY}
)
add_python_extension(_xxtestfuzz
    REQUIRES
        IS_PY3_7_OR_GREATER
    SOURCES
        _xxtestfuzz/_xxtestfuzz.c
        _xxtestfuzz/fuzzer.c
)

# Python 3.8
set(_wide_char_modifier "L")
add_python_extension(_testinternalcapi
    REQUIRES
        IS_PY3_8_OR_GREATER
    SOURCES
        _testinternalcapi.c
    DEFINITIONS
        "PY3_DLLNAME=${_wide_char_modifier}\"python3$<$<CONFIG:Debug>:_d>\""
)

# Python 3.9
add_python_extension(_peg_parser ALWAYS_BUILTIN
    REQUIRES
        IS_PY3_9_OR_GREATER
        IS_PY_LESS_3_10
    SOURCES
        _peg_parser.c
)

# Python Argument Clinic functional test module
add_python_extension(_testclinic
    REQUIRES
        "PY_VERSION VERSION_GREATER_EQUAL 3.10.10"
    SOURCES
        _testclinic.c
)

# Python 3.12
add_python_extension(_testsinglephase BUILTIN
    REQUIRES
        IS_PY3_12_OR_GREATER
    SOURCES
        _testsinglephase.c
)

# Python interface to subinterpreter C-API.
add_python_extension(_xxsubinterpreters ${WIN32_BUILTIN}
    REQUIRES
        IS_PY3_8_OR_GREATER
    SOURCES
        _xxsubinterpretersmodule.c
)

# UNIX-only extensions
add_python_extension(fcntl REQUIRES UNIX SOURCES fcntlmodule.c)
add_python_extension(grp REQUIRES UNIX SOURCES grpmodule.c)

set(nis_REQUIRES UNIX HAVE_LIBNSL)
set(nis_LIBRARIES ${HAVE_LIBNSL})
set(nis_INCLUDEDIRS )
if(TIRPC_LIBRARY AND TIRPC_RPC_INCLUDE_PATH)
    # if rpc.h is provided by libtirpc (instead of being provided by glibc). See python/cpython#5137
    list(APPEND nis_LIBRARIES ${TIRPC_LIBRARY})
    list(APPEND nis_INCLUDEDIRS ${TIRPC_RPC_INCLUDE_PATH}/../)
    if(WITH_STATIC_DEPENDENCIES AND TIRPC_LIBRARY_STATIC_DEPENDENCY_REQUIRED)
        list(APPEND nis_REQUIRES TIRPC_STATIC_LIBRARIES)
        list(APPEND nis_LIBRARIES ${TIRPC_STATIC_LIBRARIES})
    endif()
endif()
add_python_extension(nis
    REQUIRES
        ${nis_REQUIRES}
    SOURCES
        nismodule.c
    LIBRARIES
        ${nis_LIBRARIES}
    INCLUDEDIRS
        ${nis_INCLUDEDIRS}
)

add_python_extension(posix REQUIRES UNIX ALWAYS_BUILTIN SOURCES posixmodule.c DEFINITIONS Py_BUILD_CORE)
add_python_extension(pwd REQUIRES UNIX BUILTIN SOURCES pwdmodule.c) # this is needed to find out the user's home dir if $HOME is not set
add_python_extension(resource REQUIRES UNIX SOURCES resource.c)
add_python_extension(spwd
    REQUIRES
        UNIX
        HAVE_GETSPNAM
        HAVE_GETSPENT
    SOURCES
        spwdmodule.c
)
add_python_extension(syslog REQUIRES UNIX SOURCES syslogmodule.c)
add_python_extension(termios REQUIRES UNIX SOURCES termios.c)

# Python3: UNIX-only extensions
add_python_extension(errno BUILTIN UNIX SOURCES errnomodule.c)
add_python_extension(_posixsubprocess REQUIRES UNIX SOURCES _posixsubprocess.c)

# MacOSX-only extensions
set(_scproxy3_SOURCES ${SRC_DIR}/Modules/_scproxy.c)
add_python_extension(_scproxy
    REQUIRES APPLE HAVE_LIBCOREFOUNDATION HAVE_LIBSYSTEMCONFIGURATION
    SOURCES ${_scproxy${PY_VERSION_MAJOR}_SOURCES}
    LIBRARIES ${HAVE_LIBSYSTEMCONFIGURATION} ${HAVE_LIBCOREFOUNDATION}
)

# Linux-only extensions
add_python_extension(ossaudiodev
    REQUIRES
        LINUX
    SOURCES
        ossaudiodev.c
)

# Python 3.8: UNIX-only extensions
set(_posixshmem_LIBRARIES)
if(HAVE_SHM_OPEN_IN_RT)
    list(APPEND _posixshmem_LIBRARIES rt)
endif()
add_python_extension(_posixshmem
    REQUIRES
        IS_PY3_8_OR_GREATER
        UNIX
    SOURCES
        _multiprocessing/posixshmem.c
    LIBRARIES
        ${_posixshmem_LIBRARIES}
)

# Windows-only extensions
add_python_extension(_msi
    REQUIRES
        WIN32
    SOURCES
        ${SRC_DIR}/PC/_msi.c
    DEFINITIONS
        $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.11>:NEEDS_PY_IDENTIFIER>
    LIBRARIES
        cabinet.lib
        msi.lib
        rpcrt4.lib
)
add_python_extension(msvcrt REQUIRES MSVC BUILTIN SOURCES ${SRC_DIR}/PC/msvcrtmodule.c)
add_python_extension(nt REQUIRES WIN32 ALWAYS_BUILTIN SOURCES posixmodule.c)

add_python_extension(winreg REQUIRES WIN32 BUILTIN SOURCES ${SRC_DIR}/PC/winreg.c)

# Python3: Windows-only extensions
add_python_extension(_overlapped
    REQUIRES
        WIN32
    SOURCES
        ${SRC_DIR}/Modules/overlapped.c
    LIBRARIES
        ws2_32
        $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.9>:pathcch>
)
add_python_extension(_winapi REQUIRES WIN32 BUILTIN SOURCES ${SRC_DIR}/Modules/_winapi.c)

set(HAS_DISTUTILS_FINDVS_MODULE_SRC 0)
set(module_src ${SRC_DIR}/PC/_findvs.cpp)
if(EXISTS ${module_src})
  set(HAS_DISTUTILS_FINDVS_MODULE_SRC 1)
endif()
add_python_extension(_distutils_findvs REQUIRES WIN32 HAS_DISTUTILS_FINDVS_MODULE_SRC SOURCES ${module_src})

add_python_extension(_wmi
    REQUIRES
        IS_PY3_12_OR_GREATER
        WIN32
    SOURCES
        ${SRC_DIR}/PC/_wmimodule.cpp
    LIBRARIES
        propsys
        wbemuuid
)

# Multiprocessing is different on unix and windows
if(UNIX)
    set(_multiprocessing3_SOURCES )
    if(HAVE_SEM_OPEN AND NOT POSIX_SEMAPHORES_NOT_ENABLED)
        list(APPEND _multiprocessing${PY_VERSION_MAJOR}_SOURCES
            _multiprocessing/semaphore.c
        )
    endif()
    set(_multiprocessing_REQUIRES)
    if(PY_VERSION VERSION_LESS "3.7")
      list(APPEND _multiprocessing_REQUIRES WITH_THREAD)
    endif()
    add_python_extension(_multiprocessing
        SOURCES
            _multiprocessing/multiprocessing.c
            ${_multiprocessing${PY_VERSION_MAJOR}_SOURCES}
        REQUIRES
            ${_multiprocessing_REQUIRES}
    )
elseif(WIN32)
    set(_multiprocessing3_SOURCES )
    add_python_extension(_multiprocessing
        SOURCES
            _multiprocessing/multiprocessing.c
            _multiprocessing/semaphore.c
            ${_multiprocessing${PY_VERSION_MAJOR}_SOURCES}
        LIBRARIES
            ws2_32
    )
endif()

# Select needs winsock on Windows
if(WIN32)
    add_python_extension(select SOURCES selectmodule.c LIBRARIES ws2_32)
else()
    add_python_extension(select SOURCES selectmodule.c)
endif()

# Socket is different on Windows
set(_socket_SOURCES socketmodule.c)
if(WIN32)
    add_python_extension(_socket
        REQUIRES
            HAVE_LIBM
        SOURCES
            ${_socket_SOURCES}
        DEFINITIONS
            EAI_ADDRFAMILY
            HAVE_SOCKADDR_STORAGE
            HAVE_ADDRINFO
        LIBRARIES
            ws2_32
            ${M_LIBRARIES}
            $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.8>:iphlpapi>
            $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:Rpcrt4>
    )
else()
    add_python_extension(_socket
        REQUIRES
            HAVE_LIBM
        SOURCES
            ${_socket_SOURCES}
        LIBRARIES
            ${M_LIBRARIES}
    )
endif()

set(_libffi_system_dir ${CMAKE_SYSTEM_PROCESSOR})
if("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "i686")
  set(_libffi_system_dir "x86")
elseif("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "x86_64" OR "${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "amd64")
  set(_libffi_system_dir "x86")
elseif("${CMAKE_SYSTEM_PROCESSOR}" MATCHES "arm")
  set(_libffi_system_dir "arm")
endif()
# Common ctypes sources
set(ctypes_COMMON_SOURCES
    _ctypes/_ctypes.c
    _ctypes/callbacks.c
    _ctypes/callproc.c
    _ctypes/stgdict.c
    _ctypes/cfield.c
)

if(
    (WIN32 AND PY_VERSION VERSION_GREATER_EQUAL "3.8")
    OR
    (LINUX AND PY_VERSION VERSION_GREATER_EQUAL "3.7")
    OR
    (APPLE AND PY_VERSION VERSION_GREATER_EQUAL "3.12")
  )
    # If found, build ctypes against ffi library
    # * on Windows for python >= 3.8
    # * on Linux for python >= 3.7
    # * on macOS for python >= 3.12
    set(ctypes_malloc_closure 0)
    if(APPLE AND PY_VERSION VERSION_GREATER_EQUAL "3.12")
      set(ctypes_malloc_closure 1)
    endif()
    set(_ctypes_REQUIRES)
    if(UNIX AND PY_VERSION VERSION_GREATER_EQUAL "3.12")
      list(APPEND _ctypes_REQUIRES HAVE_FFI_CALL)
    endif()
    set(ffi_building 0)
    get_filename_component(_ffi_library_name ${LibFFI_LIBRARY} NAME)
    # Linking against the static library on Windows requires defining "FFI_BUILDING".
    # See ffi.h for more details.
    if(WIN32 AND _ffi_library_name MATCHES "^ffi_static")
      set(ffi_building 1)
    endif()
    add_python_extension(_ctypes
        REQUIRES
            LibFFI_INCLUDE_DIR
            LibFFI_LIBRARY
            ${_ctypes_REQUIRES}
        SOURCES
            ${ctypes_COMMON_SOURCES}
            $<$<BOOL:${ctypes_malloc_closure}>:_ctypes/malloc_closure.c>
        DEFINITIONS
            Py_BUILD_CORE_MODULE
            $<$<BOOL:${ctypes_malloc_closure}>:USING_MALLOC_CLOSURE_DOT_C=1>
            $<$<BOOL:${ffi_building}>:FFI_BUILDING>
        INCLUDEDIRS
            ${LibFFI_INCLUDE_DIR}
        LIBRARIES
            ${LibFFI_LIBRARY}
    )
else()
# ctypes is different on Windows
if(WIN32)
    if(MINGW)
      add_python_extension(_ctypes
          SOURCES
              ${ctypes_COMMON_SOURCES}
              _ctypes/libffi_mingw/closures.c
              _ctypes/libffi_mingw/debug.c
              _ctypes/libffi_mingw/prep_cif.c
              _ctypes/libffi_mingw/raw_api.c
              _ctypes/libffi_mingw/${_libffi_system_dir}/ffi.c
              _ctypes/libffi_mingw/${_libffi_system_dir}/win32.S
          INCLUDEDIRS
              ${SRC_DIR}/Modules/_ctypes/libffi/src/${_libffi_system_dir}
              ${SRC_DIR}/Modules/_ctypes/libffi/include
          DEFINITIONS
              X86_WIN32
        )
    else() # Visual Studio
      if(${CMAKE_SIZEOF_VOID_P} EQUAL 8)
          enable_language(ASM_MASM)
          set(_ctype_arch_impl win64.asm)
      else()
          set(_ctype_arch_impl win32.c)
      endif()
      add_python_extension(_ctypes
          SOURCES
              ${ctypes_COMMON_SOURCES}
              _ctypes/malloc_closure.c
              _ctypes/libffi_msvc/prep_cif.c
              _ctypes/libffi_msvc/ffi.c
              _ctypes/libffi_msvc/${_ctype_arch_impl}
          REQUIRES
              BUILD_LIBPYTHON_SHARED
          INCLUDEDIRS
              ${SRC_DIR}/Modules/_ctypes/libffi_msvc
        )
    endif()
else()
    if(APPLE)
        add_python_extension(_ctypes
            SOURCES
                ${ctypes_COMMON_SOURCES}
                _ctypes/malloc_closure.c
                _ctypes/darwin/dlfcn_simple.c
                _ctypes/libffi_osx/ffi.c
                _ctypes/libffi_osx/x86/darwin64.S
                _ctypes/libffi_osx/x86/x86-darwin.S
                _ctypes/libffi_osx/x86/x86-ffi_darwin.c
                _ctypes/libffi_osx/x86/x86-ffi64.c
            INCLUDEDIRS
                ${SRC_DIR}/Modules/_ctypes/libffi_osx/include
                ${SRC_DIR}/Modules/_ctypes/darwin
            DEFINITIONS
                MACOSX
        )
    else()
        if("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "x86_64")
          set(_libffi_system_extra_src
                _ctypes/libffi/src/${_libffi_system_dir}/ffi64.c
                _ctypes/libffi/src/${_libffi_system_dir}/unix64.S
                )
        elseif("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "i686")
          set(_libffi_system_extra_src
                _ctypes/libffi/src/${_libffi_system_dir}/win32.S
                )
        endif()
        # To facilitate an eventual contribution of the configuration
        # of fficonfig.h to the upstream project, corresponding tests
        # in ConfigureChecks.cmake are labeled using this convention:
        # * "libffi specific"
        # * "libffi and cpython"
        set(LIBFFI_VERSION "3.1")
        configure_file(
          ${PROJECT_SOURCE_DIR}/cmake/fficonfig.h.in
          ${INCLUDE_BUILD_DIR}/fficonfig.h
          )
        add_python_extension(_ctypes
            SOURCES
                ${ctypes_COMMON_SOURCES}
                _ctypes/libffi/src/closures.c
                _ctypes/libffi/src/prep_cif.c
                _ctypes/libffi/src/${_libffi_system_dir}/ffi.c
                _ctypes/libffi/src/${_libffi_system_dir}/sysv.S
                ${_libffi_system_extra_src}
            INCLUDEDIRS
                ${SRC_DIR}/Modules/_ctypes/libffi/src/${_libffi_system_dir}
                ${SRC_DIR}/Modules/_ctypes/libffi/include
                ${INCLUDE_BUILD_DIR}      # For fficonfig.h
                ${PROJECT_SOURCE_DIR}/cmake # For ffi.h
        )
    endif()
endif()
endif()

# Python3: _decimal
set(libmpdec_config_x64          CONFIG_64 ASM)
set(libmpdec_config_uint128      CONFIG_64 ANSI HAVE_UINT128_T)
set(libmpdec_config_ansi64       CONFIG_64 ANSI)
set(libmpdec_config_ppro         CONFIG_32 PPRO ASM)
set(libmpdec_config_ansi32       CONFIG_32 PPRO) # XXX Is ANSI needed here ?
set(libmpdec_config_ansi_legacy  CONFIG_32 ANSI LEGACY_COMPILER)
set(libmpdec_config_universal    UNIVERSAL)

if(USE_SYSTEM_LIBMPDEC)
    set(_decimal_REQUIRES REQUIRES LIBMPDEC_LIBRARIES LIBMPDEC_INCLUDE_DIR)
    set(_decimal_LIBRARIES LIBRARIES ${LIBMPDEC_LIBRARIES})
    set(_decimal_EXTRA_SOURCES )
    set(_decimal_INCLUDEDIRS INCLUDEDIRS ${LIBMPDEC_INCLUDE_DIR})
else()
    set(_decimal_REQUIRES )
    set(_decimal_EXTRA_SOURCES
        _decimal/libmpdec/basearith.c
        _decimal/libmpdec/constants.c
        _decimal/libmpdec/context.c
        _decimal/libmpdec/convolute.c
        _decimal/libmpdec/crt.c
        _decimal/libmpdec/difradix2.c
        _decimal/libmpdec/fnt.c
        _decimal/libmpdec/fourstep.c
        _decimal/libmpdec/io.c
        _decimal/libmpdec/mpdecimal.c
        _decimal/libmpdec/numbertheory.c
        _decimal/libmpdec/sixstep.c
        _decimal/libmpdec/transpose.c

        # Removed in Python 3.9
        $<$<VERSION_LESS:${PY_VERSION},3.9>:_decimal/libmpdec/memory.c>

        # Introduced in Python 3.9
        $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.9>:_decimal/libmpdec/mpalloc.c>
    )
    if(WIN32)
        if(${CMAKE_SIZEOF_VOID_P} EQUAL 8)
            enable_language(ASM_MASM)
            list(APPEND _decimal_EXTRA_SOURCES
                _decimal/libmpdec/vcdiv64.asm
            )
        endif()
    endif()
    set(_decimal_INCLUDEDIRS INCLUDEDIRS ${SRC_DIR}/Modules/_decimal/libmpdec)
endif()
set(libmpdec_config )
set(_decimal_compile_flags )
if(APPLE)
    # Universal here means: build with the same options Python
    # was built with.
    set(libmpdec_config universal)
elseif(${CMAKE_SIZEOF_VOID_P} EQUAL 8)
    if(HAVE_GCC_ASM_FOR_X64)
        set(libmpdec_config x64)
    elseif(HAVE_GCC_UINT128_T)
        set(libmpdec_config uint128)
    else()
        set(libmpdec_config ansi64)
    endif()
elseif(${CMAKE_SIZEOF_VOID_P} EQUAL 4)
    if(HAVE_GCC_ASM_FOR_X87 AND
        (CMAKE_C_COMPILER_ID MATCHES "GNU" OR CMAKE_C_COMPILER_ID MATCHES "Clang")
        AND NOT CMAKE_SYSTEM MATCHES SunOS
    )
        # solaris: problems with register allocation.
        # icc >= 11.0 works as well.
        set(libmpdec_config ppro)
        list(APPEND _decimal_compile_flags "-Wno-unknown-pragmas")
    else()
      set(libmpdec_config ansi32)
    endif()
else()
    message(FATAL_ERROR "extension_decimal: unsupported architecture")
endif()

# Workarounds for toolchain bugs:
if(HAVE_IPA_PURE_CONST_BUG)
    # Some versions of gcc miscompile inline asm:
    # http://gcc.gnu.org/bugzilla/show_bug.cgi?id=46491
    # http://gcc.gnu.org/ml/gcc/2010-11/msg00366.html
    list(APPEND _decimal_compile_flags "-fno-ipa-pure-const")
endif()
if(HAVE_GLIBC_MEMMOVE_BUG)
    # _FORTIFY_SOURCE wrappers for memmove and bcopy are incorrect:
    # http://sourceware.org/ml/libc-alpha/2010-12/msg00009.html
    # XXX Implement missing logic
#    undef_macros.append('_FORTIFY_SOURCE')
endif()

if(NOT WITH_THREAD AND PY_VERSION VERSION_LESS "3.7")
    # Faster version without thread local contexts:
    list(APPEND libmpdec_config_${libmpdec_config}
        WITHOUT_THREADS
    )
endif()

if(WIN32)
    list(APPEND libmpdec_config_${libmpdec_config}
        _CRT_SECURE_NO_WARNINGS MASM
    )
endif()

# Uncomment for extra functionality:
#list(APPEND libmpdec_config_${libmpdec_config} EXTRA_FUNCTIONALITY)

if(ENABLE_DECIMAL)
    message(STATUS "extension_decimal: libmpdec_config [${libmpdec_config}]")
endif()
add_python_extension(_decimal
    REQUIRES
        IS_PY3_3_OR_GREATER
    SOURCES
        _decimal/_decimal.c
        _decimal/docstrings.h
        ${_decimal_EXTRA_SOURCES}
    DEFINITIONS ${libmpdec_config_${libmpdec_config}}
    ${_decimal_REQUIRES}
    ${_decimal_LIBRARIES}
    ${_decimal_INCLUDEDIRS}
)
if(_decimal_compile_flags AND ENABLE_DECIMAL AND TARGET extension_decimal AND NOT BUILTIN_DECIMAL)
    set_target_properties(extension_decimal PROPERTIES COMPILE_FLAGS ${_decimal_compile_flags})
endif()

# Build expat using the system expat if it's installed, otherwise use the
# builtin version.
if(EXPAT_LIBRARIES AND EXPAT_INCLUDE_DIRS)
    add_python_extension(pyexpat
        SOURCES pyexpat.c
        LIBRARIES ${EXPAT_LIBRARIES}
        INCLUDEDIRS ${EXPAT_INCLUDE_DIRS}
    )
    add_python_extension(_elementtree
        SOURCES _elementtree.c
        LIBRARIES ${EXPAT_LIBRARIES}
        INCLUDEDIRS ${EXPAT_INCLUDE_DIRS}
    )
else()
    set(_pyexpat_definitions XML_STATIC)
    set(_pyexpat_SOURCES
        pyexpat.c
        expat/xmlparse.c
        expat/xmlrole.c
        expat/xmltok.c
        )
    if(UNIX)
        list(APPEND _pyexpat_definitions HAVE_EXPAT_CONFIG_H)
        # bpo-30947: Python uses best available entropy sources to
        # call XML_SetHashSalt(), expat entropy sources are not needed
        list(APPEND _pyexpat_definitions XML_POOR_ENTROPY)
    elseif(WIN32)
        list(APPEND _pyexpat_definitions COMPILED_FROM_DSP)
        if(EXISTS "${SRC_DIR}/Modules/expat/loadlibrary.c")
            list(APPEND _pyexpat_SOURCES "${SRC_DIR}/Modules/expat/loadlibrary.c")
        endif()
    endif()
    add_python_extension(pyexpat
        SOURCES ${_pyexpat_SOURCES}
        DEFINITIONS ${_pyexpat_definitions}
        INCLUDEDIRS ${SRC_DIR}/Modules/expat
    )
    set(_elementtree_definitions USE_PYEXPAT_CAPI)
    if(WIN32)
        list(APPEND _elementtree_definitions COMPILED_FROM_DSP)
    endif()
    add_python_extension(_elementtree
        SOURCES _elementtree.c
        DEFINITIONS ${_elementtree_definitions}
        INCLUDEDIRS ${SRC_DIR}/Modules/expat
    )
endif()

# We always compile these even when OpenSSL is available (issue #14693).
# It's harmless and the object code is tiny (40-50 KB per module,
# only loaded when actually used).
add_python_extension(_md5 ${WIN32_BUILTIN}
    SOURCES
        md5module.c
        $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:_hacl/Hacl_Hash_MD5.c>
    INCLUDEDIRS
        $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:${SRC_DIR}/Modules/_hacl/include>
    DEFINITIONS
        $<$<AND:$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>,$<BOOL:${UNIX}>>:_BSD_SOURCE>
        $<$<AND:$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>,$<BOOL:${UNIX}>>:_DEFAULT_SOURCE>
)
add_python_extension(_sha1 ${WIN32_BUILTIN}
    SOURCES
        sha1module.c
        $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:_hacl/Hacl_Hash_SHA1.c>
    INCLUDEDIRS
        $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:${SRC_DIR}/Modules/_hacl/include>
    DEFINITIONS
        $<$<AND:$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>,$<BOOL:${UNIX}>>:_BSD_SOURCE>
        $<$<AND:$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>,$<BOOL:${UNIX}>>:_DEFAULT_SOURCE>
)

# Removed in Python 3.12
add_python_extension(_sha256 ${WIN32_BUILTIN}
    REQUIRES
        IS_PY_LESS_3_12
    SOURCES
        sha256module.c
)
add_python_extension(_sha512 ${WIN32_BUILTIN}
    REQUIRES
        IS_PY_LESS_3_12
    SOURCES
        sha512module.c
)

# Python 3.12
add_python_extension(_sha2 ${WIN32_BUILTIN}
    REQUIRES
        IS_PY3_12_OR_GREATER
    SOURCES
        sha2module.c
        _hacl/Hacl_Hash_SHA2.c
    INCLUDEDIRS
        ${SRC_DIR}/Modules/_hacl/include
    DEFINITIONS
        $<$<BOOL:${UNIX}>:_BSD_SOURCE>
        $<$<BOOL:${UNIX}>:_DEFAULT_SOURCE>
)
add_python_extension(_sha3 ${WIN32_BUILTIN}
    REQUIRES
        IS_PY3_12_OR_GREATER
    SOURCES
        sha3module.c
        $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:_hacl/Hacl_Hash_SHA3.c>
    INCLUDEDIRS
        $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.12>:${SRC_DIR}/Modules/_hacl/include>
    DEFINITIONS
        $<$<BOOL:${UNIX}>:_BSD_SOURCE>
        $<$<BOOL:${UNIX}>:_DEFAULT_SOURCE>
)
add_python_extension(_tokenize ALWAYS_BUILTIN
    REQUIRES
        IS_PY3_12_OR_GREATER
    SOURCES
        ${SRC_DIR}/Python/Python-tokenize.c
)
add_python_extension(_typing ALWAYS_BUILTIN
    REQUIRES
        IS_PY3_12_OR_GREATER
    SOURCES
        _typingmodule.c
)
add_python_extension(_xxinterpchannels ALWAYS_BUILTIN
    REQUIRES
        IS_PY3_12_OR_GREATER
    SOURCES
        _xxinterpchannelsmodule.c
)

# Extensions that depend on other libraries
set(binascii_REQUIRES "")
set(binascii_DEFINITIONS "")
set(binascii_LIBRARIES "")
set(binascii_INCLUDEDIRS "")
if(ZLIB_LIBRARY)
  list(APPEND binascii_REQUIRES ZLIB_INCLUDE_DIR)
  list(APPEND binascii_DEFINITIONS USE_ZLIB_CRC32)
  list(APPEND binascii_LIBRARIES ${ZLIB_LIBRARY})
  list(APPEND binascii_INCLUDEDIRS ${ZLIB_INCLUDE_DIR})
endif()
add_python_extension(binascii
    REQUIRES ${binascii_REQUIRES}
    ${WIN32_BUILTIN}
    SOURCES binascii.c
    DEFINITIONS ${binascii_DEFINITIONS}
    LIBRARIES ${binascii_LIBRARIES}
    INCLUDEDIRS ${binascii_INCLUDEDIRS}
)
add_python_extension(_bz2
    REQUIRES BZIP2_LIBRARIES BZIP2_INCLUDE_DIR
    SOURCES _bz2module.c
    LIBRARIES ${BZIP2_LIBRARIES}
    INCLUDEDIRS ${BZIP2_INCLUDE_DIR}
)
set(curses_common_REQUIRES CURSES_LIBRARIES)
set(curses_common_LIBRARIES ${CURSES_LIBRARIES})
if(WITH_STATIC_DEPENDENCIES)
    list(APPEND curses_common_REQUIRES TINFO_LIBRARY GPM_LIBRARY)
    list(APPEND curses_common_LIBRARIES ${TINFO_LIBRARY} ${GPM_LIBRARY})
endif()
add_python_extension(_curses_panel
    REQUIRES ${curses_common_REQUIRES} PANEL_LIBRARIES "HAVE_PANEL_H OR HAVE_NCURSES_PANEL_H"
    SOURCES _curses_panel.c
    LIBRARIES ${curses_common_LIBRARIES} ${PANEL_LIBRARIES}
)
add_python_extension(_curses
    REQUIRES ${curses_common_REQUIRES}
    SOURCES _cursesmodule.c
    LIBRARIES ${curses_common_LIBRARIES}
)
add_python_extension(_dbm
    REQUIRES NDBM_TAG GDBM_LIBRARY GDBM_COMPAT_LIBRARY
    SOURCES _dbmmodule.c
    DEFINITIONS
        HAVE_${NDBM_TAG}_H
        USE_${NDBM_USE} # Python 3.11
    LIBRARIES
        ${GDBM_LIBRARY}
        ${GDBM_COMPAT_LIBRARY}
    INCLUDEDIRS
        ${${NDBM_TAG}_INCLUDE_PATH}
)
add_python_extension(_gdbm
    REQUIRES GDBM_INCLUDE_PATH GDBM_LIBRARY GDBM_COMPAT_LIBRARY
    SOURCES _gdbmmodule.c
    DEFINITIONS HAVE_GDBM_DASH_NDBM_H
    LIBRARIES ${GDBM_LIBRARY}
    INCLUDEDIRS ${GDBM_INCLUDE_PATH}
)
add_python_extension(_hashlib
    REQUIRES OPENSSL_INCLUDE_DIR OPENSSL_LIBRARIES
      IS_PY3_5_OR_GREATER
    SOURCES _hashopenssl.c
    LIBRARIES ${OPENSSL_LIBRARIES}
    INCLUDEDIRS ${OPENSSL_INCLUDE_DIR}
)
if(ENABLE_HASHLIB AND CMAKE_C_COMPILER_ID MATCHES GNU)
    set_property(SOURCE ${SRC_DIR}/Modules/_hashopenssl.c PROPERTY COMPILE_FLAGS -Wno-deprecated-declarations)
endif()
# lzma module was introduced in Python 3.3
add_python_extension(_lzma
    REQUIRES LZMA_INCLUDE_PATH LZMA_LIBRARY IS_PY3_3_OR_GREATER
    SOURCES _lzmamodule.c
    DEFINITIONS MODULE_NAME="lzma" LZMA_API_STATIC=1
    INCLUDEDIRS ${LZMA_INCLUDE_PATH}
    LIBRARIES ${LZMA_LIBRARY}
)
set(readline_DEFINITIONS "")
if(USE_LIBEDIT)
  if(PY_VERSION VERSION_GREATER_EQUAL "3.10")
    list(APPEND readline_DEFINITIONS WITH_EDITLINE)
  endif()
endif()
add_python_extension(readline
    REQUIRES READLINE_INCLUDE_PATH READLINE_LIBRARY CURSES_LIBRARIES HAVE_READLINE_READLINE_H
    SOURCES readline.c
    DEFINITIONS ${readline_DEFINITIONS}
    LIBRARIES ${READLINE_LIBRARY} ${CURSES_LIBRARIES}
    INCLUDEDIRS ${READLINE_INCLUDE_PATH}
)
add_python_extension(_sqlite3
    REQUIRES SQLite3_INCLUDE_DIRS SQLite3_LIBRARIES
    SOURCES
        # Removed in Python 3.11
        $<$<VERSION_LESS:${PY_VERSION},3.11>:_sqlite/cache.c>

        _sqlite/connection.c
        _sqlite/cursor.c
        _sqlite/microprotocols.c
        _sqlite/module.c
        _sqlite/prepare_protocol.c
        _sqlite/row.c
        _sqlite/statement.c
        _sqlite/util.c

        # Introduced in Python 3.11
        $<$<VERSION_GREATER_EQUAL:${PY_VERSION},3.11>:_sqlite/blob.c>

    DEFINITIONS
        MODULE_NAME="sqlite3"
        SQLITE_OMIT_LOAD_EXTENSION=1
    INCLUDEDIRS
        ${SQLite3_INCLUDE_DIRS}
    LIBRARIES
        ${SQLite3_LIBRARIES}
)
if(ENABLE_SQLITE3 AND CMAKE_C_COMPILER_ID MATCHES GNU)
    set_property(SOURCE ${SRC_DIR}/Modules/_sqlite/module.c PROPERTY COMPILE_FLAGS -Wno-deprecated-declarations)
endif()
set(_ssl_LIBRARIES ${OPENSSL_LIBRARIES})
if(WIN32)
    list(APPEND _ssl_LIBRARIES Crypt32 ws2_32)
endif()
set(_ssl_SOURCES _ssl.c)
if(WIN32)
    list(APPEND _ssl_SOURCES ${OPENSSL_INCLUDE_DIR}/openssl/applink.c)
endif()
add_python_extension(_ssl
    REQUIRES OPENSSL_INCLUDE_DIR OPENSSL_LIBRARIES
      IS_PY3_5_OR_GREATER
    SOURCES ${_ssl_SOURCES}
    LIBRARIES ${_ssl_LIBRARIES}
    INCLUDEDIRS ${OPENSSL_INCLUDE_DIR}
)
set(_tkinter_REQUIRES TCL_LIBRARY TK_LIBRARY TCL_INCLUDE_PATH TK_INCLUDE_PATH)
set(_tkinter_LIBRARIES ${TCL_LIBRARY} ${TK_LIBRARY})
set(_tkinter_INCLUDEDIRS ${TCL_INCLUDE_PATH} ${TK_INCLUDE_PATH})
if(UNIX)
  list(APPEND _tkinter_REQUIRES X11_INCLUDE_DIR X11_LIBRARIES)
  list(APPEND _tkinter_LIBRARIES ${X11_LIBRARIES})
  list(APPEND _tkinter_INCLUDEDIRS ${X11_INCLUDE_DIR})
endif()
add_python_extension(_tkinter
    REQUIRES ${_tkinter_REQUIRES}
    SOURCES _tkinter.c tkappinit.c
    DEFINITIONS WITH_APPINIT=1
    LIBRARIES ${_tkinter_LIBRARIES}
    INCLUDEDIRS ${_tkinter_INCLUDEDIRS}
)
if(NOT USE_BUILTIN_ZLIB)
    add_python_extension(zlib
        REQUIRES ZLIB_LIBRARY ZLIB_INCLUDE_DIR
        SOURCES zlibmodule.c
        LIBRARIES ${ZLIB_LIBRARY}
        INCLUDEDIRS ${ZLIB_INCLUDE_DIR}
    )
else()
    add_python_extension(zlib BUILTIN
        REQUIRES
        SOURCES
            zlibmodule.c
            zlib/adler32.c
            zlib/compress.c
            zlib/crc32.c
            zlib/deflate.c
            zlib/infback.c
            zlib/inffast.c
            zlib/inflate.c
            zlib/inftrees.c
            zlib/trees.c
            zlib/uncompr.c
            zlib/zutil.c
        INCLUDEDIRS ${SRC_DIR}/Modules/zlib
    )
endif()
