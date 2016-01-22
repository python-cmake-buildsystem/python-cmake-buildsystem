
# XXX Because of CMake issue #8170 disable ctypes support when using
#     "Visual Studio 2008 Win64" generator.
if("${MSVC_VERSION}" VERSION_EQUAL 1500 AND ${CMAKE_SIZEOF_VOID_P} EQUAL 8)
    set(warn "Disable 'ctypes' and 'ctypes_test' extensions when using 'Visual Studio 2008 Win64' generator. See http://public.kitware.com/Bug/view.php?id=8170 for more details.")
    if(NOT DEFINED ENABLE_CTYPES OR ENABLE_CTYPES OR NOT DEFINED ENABLE_CTYPES_TEST OR ENABLE_CTYPES_TEST)
        message(WARNING ${warn})
    endif()
    set(ENABLE_CTYPES OFF CACHE BOOL "${warn}" FORCE)
    set(ENABLE_CTYPES_TEST OFF CACHE BOOL "${warn}" FORCE)
endif()
# XXX Because of CMake issue #11536, disable ctypes support when using
#     CMake < 2.8.12 with "Visual Studio 2010" and "Visual Studio 2010 Win64"
#     generator.
if(CMAKE_VERSION VERSION_LESS 2.8.12)
    if("${MSVC_VERSION}" VERSION_EQUAL 1600)
        set(warn "Disable 'ctypes' and 'ctypes_test' extensions when using CMake < 2.8.12 with any 'Visual Studio 2010' generators. See http://public.kitware.com/Bug/view.php?id=11536 for more details.")
        if(NOT DEFINED ENABLE_CTYPES OR ENABLE_CTYPES OR NOT DEFINED ENABLE_CTYPES_TEST OR ENABLE_CTYPES_TEST)
            message(WARNING ${warn})
        endif()
        set(ENABLE_CTYPES OFF CACHE BOOL "${warn}" FORCE)
        set(ENABLE_CTYPES_TEST OFF CACHE BOOL "${warn}" FORCE)
    endif()
endif()

set(MSVC_BUILTIN )
if(MSVC)
    set(MSVC_BUILTIN BUILTIN)
endif(MSVC)

add_python_extension(array ${MSVC_BUILTIN} SOURCES arraymodule.c)
add_python_extension(audioop ${MSVC_BUILTIN} SOURCES audioop.c)
add_python_extension(_bisect ${MSVC_BUILTIN} SOURCES _bisectmodule.c)
add_python_extension(cmath REQUIRES HAVE_LIBM ${MSVC_BUILTIN} SOURCES _math.c cmathmodule.c LIBRARIES ${M_LIBRARIES})
add_python_extension(_codecs_cn ${MSVC_BUILTIN} SOURCES cjkcodecs/_codecs_cn.c)
add_python_extension(_codecs_hk ${MSVC_BUILTIN} SOURCES cjkcodecs/_codecs_hk.c)
add_python_extension(_codecs_iso2022 ${MSVC_BUILTIN} SOURCES cjkcodecs/_codecs_iso2022.c)
add_python_extension(_codecs_jp ${MSVC_BUILTIN} SOURCES cjkcodecs/_codecs_jp.c)
add_python_extension(_codecs_kr ${MSVC_BUILTIN} SOURCES cjkcodecs/_codecs_kr.c)
add_python_extension(_codecs_tw ${MSVC_BUILTIN} SOURCES cjkcodecs/_codecs_tw.c)
add_python_extension(_collections ${MSVC_BUILTIN} SOURCES _collectionsmodule.c)
add_python_extension(cPickle ${MSVC_BUILTIN} SOURCES cPickle.c)
add_python_extension(crypt REQUIRES HAVE_LIBCRYPT SOURCES cryptmodule.c LIBRARIES ${HAVE_LIBCRYPT})
add_python_extension(cStringIO ${MSVC_BUILTIN} SOURCES cStringIO.c)
add_python_extension(_csv ${MSVC_BUILTIN} SOURCES _csv.c)
add_python_extension(_ctypes_test SOURCES _ctypes/_ctypes_test.c)
set(datetime_SOURCES datetimemodule.c)
if(UNIX)
  list(APPEND datetime_SOURCES timemodule.c)
endif()
add_python_extension(datetime ${MSVC_DATETIME} REQUIRES HAVE_LIBM ${MSVC_BUILTIN} SOURCES ${datetime_SOURCES} LIBRARIES ${M_LIBRARIES})
if(ENABLE_DATETIME AND CMAKE_C_COMPILER_ID MATCHES GNU)
    set_property(SOURCE ${SRC_DIR}/Modules/datetimemodule.c PROPERTY COMPILE_FLAGS -Wno-unused-value)
endif()
add_python_extension(_functools ${MSVC_BUILTIN} SOURCES _functoolsmodule.c)
add_python_extension(future_builtins ${MSVC_BUILTIN} SOURCES future_builtins.c)
add_python_extension(_heapq ${MSVC_BUILTIN} SOURCES _heapqmodule.c)
add_python_extension(_hotshot ${MSVC_BUILTIN} SOURCES _hotshot.c)
add_python_extension(_io ${MSVC_BUILTIN} SOURCES
    _io/_iomodule.c
    _io/bufferedio.c
    _io/bytesio.c
    _io/fileio.c
    _io/iobase.c
    _io/stringio.c
    _io/textio.c
)
add_python_extension(itertools ${MSVC_BUILTIN} SOURCES itertoolsmodule.c)
add_python_extension(_json ${MSVC_BUILTIN} SOURCES _json.c)
add_python_extension(_locale ${MSVC_BUILTIN} SOURCES _localemodule.c)
add_python_extension(_lsprof ${MSVC_BUILTIN} SOURCES _lsprof.c rotatingtree.c)
add_python_extension(math ${MSVC_BUILTIN} SOURCES _math.c mathmodule.c)
add_python_extension(mmap ${MSVC_BUILTIN} SOURCES mmapmodule.c)
add_python_extension(_multibytecodec ${MSVC_BUILTIN} SOURCES cjkcodecs/multibytecodec.c)
add_python_extension(operator ${MSVC_BUILTIN} SOURCES operator.c)
add_python_extension(parser ${MSVC_BUILTIN} SOURCES parsermodule.c)
add_python_extension(_random ${MSVC_BUILTIN} SOURCES _randommodule.c)
add_python_extension(strop ${MSVC_BUILTIN} SOURCES stropmodule.c)
add_python_extension(_struct ${MSVC_BUILTIN} SOURCES _struct.c)
add_python_extension(_testcapi SOURCES _testcapimodule.c)
add_python_extension(time ${MSVC_BUILTIN} REQUIRES HAVE_LIBM SOURCES timemodule.c LIBRARIES ${M_LIBRARIES})
add_python_extension(unicodedata SOURCES unicodedata.c)

# UNIX-only extensions
add_python_extension(fcntl REQUIRES UNIX SOURCES fcntlmodule.c)
add_python_extension(grp REQUIRES UNIX SOURCES grpmodule.c)
add_python_extension(nis REQUIRES UNIX HAVE_LIBNSL SOURCES nismodule.c LIBRARIES ${HAVE_LIBNSL})
add_python_extension(posix REQUIRES UNIX BUILTIN SOURCES posixmodule.c)
add_python_extension(pwd REQUIRES UNIX BUILTIN SOURCES pwdmodule.c)
add_python_extension(resource REQUIRES UNIX SOURCES resource.c)
add_python_extension(spwd REQUIRES UNIX HAVE_GETSPNAM HAVE_GETSPENT SOURCES spwdmodule.c)
add_python_extension(syslog REQUIRES UNIX SOURCES syslogmodule.c)
add_python_extension(termios REQUIRES UNIX SOURCES termios.c)

# MacOSX-only extensions
add_python_extension(_scproxy
    REQUIRES APPLE HAVE_LIBSYSTEMCONFIGURATION
    SOURCES ${SRC_DIR}/Mac/Modules/_scproxy.c
    LIBRARIES ${HAVE_LIBSYSTEMCONFIGURATION}
)

# Linux-only extensions
add_python_extension(linuxaudiodev REQUIRES LINUX SOURCES linuxaudiodev.c)
add_python_extension(ossaudiodev REQUIRES LINUX SOURCES ossaudiodev.c)

# Windows-only extensions
add_python_extension(_msi
    REQUIRES WIN32 BUILTIN
    SOURCES ${SRC_DIR}/PC/_msi.c
    LIBRARIES cabinet.lib msi.lib rpcrt4.lib
)
add_python_extension(msvcrt REQUIRES MSVC BUILTIN SOURCES ${SRC_DIR}/PC/msvcrtmodule.c)
add_python_extension(nt REQUIRES WIN32 BUILTIN SOURCES posixmodule.c)
add_python_extension(_subprocess REQUIRES WIN32 BUILTIN SOURCES ${SRC_DIR}/PC/_subprocess.c)
add_python_extension(_winreg REQUIRES WIN32 BUILTIN SOURCES ${SRC_DIR}/PC/_winreg.c)

# Multiprocessing is different on unix and windows
if(UNIX)
    add_python_extension(_multiprocessing
        SOURCES _multiprocessing/multiprocessing.c
                _multiprocessing/semaphore.c
                _multiprocessing/socket_connection.c
    )
    if(ENABLE_MULTIPROCESSING AND CMAKE_C_COMPILER_ID MATCHES GNU)
        set_property(SOURCE ${SRC_DIR}/Modules/semaphore.c PROPERTY COMPILE_FLAGS -Wimplicit-function-declaration)
    endif()
elseif(WIN32)
    add_python_extension(_multiprocessing
        SOURCES _multiprocessing/multiprocessing.c
                _multiprocessing/semaphore.c
                _multiprocessing/pipe_connection.c
                _multiprocessing/socket_connection.c
                _multiprocessing/win32_functions.c
        LIBRARIES ws2_32
    )
endif(UNIX)

# Select needs winsock on Windows
if(WIN32)
    add_python_extension(select SOURCES selectmodule.c LIBRARIES ws2_32)
else(WIN32)
    add_python_extension(select SOURCES selectmodule.c)
endif(WIN32)

# Socket is different on Windows
set(_socket_SOURCES socketmodule.c)
if(WIN32)
    add_python_extension(_socket
        REQUIRES HAVE_LIBM
        SOURCES ${_socket_SOURCES}
        DEFINITIONS EAI_ADDRFAMILY
                    HAVE_SOCKADDR_STORAGE
                    HAVE_ADDRINFO
        LIBRARIES ws2_32 ${M_LIBRARIES}
    )
else(WIN32)
    list(APPEND _socket_SOURCES timemodule.c)
    add_python_extension(_socket
        REQUIRES HAVE_LIBM
        SOURCES ${_socket_SOURCES}
        LIBRARIES ${M_LIBRARIES}
    )
endif(WIN32)

set(_libffi_system_dir ${CMAKE_SYSTEM_PROCESSOR})
if("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "i686")
  set(_libffi_system_dir "x86")
elseif("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "x86_64")
  set(_libffi_system_dir "x86")
elseif("${CMAKE_SYSTEM_PROCESSOR}" MATCHES "arm")
  set(_libffi_system_dir "arm")
endif()
# ctypes is different on Windows
if(WIN32)
    if(MINGW)
    add_python_extension(_ctypes
        SOURCES _ctypes/_ctypes.c
                _ctypes/callbacks.c
                _ctypes/callproc.c
                _ctypes/cfield.c
                _ctypes/libffi_mingw/closures.c
                _ctypes/libffi_mingw/debug.c
                _ctypes/libffi_mingw/prep_cif.c
                _ctypes/libffi_mingw/raw_api.c
                _ctypes/libffi_mingw/${_libffi_system_dir}/ffi.c
                _ctypes/libffi_mingw/${_libffi_system_dir}/win32.S
                _ctypes/stgdict.c
        INCLUDEDIRS ${SRC_DIR}/Modules/_ctypes/libffi/src/${_libffi_system_dir}
                    ${SRC_DIR}/Modules/_ctypes/libffi/include
        DEFINITIONS X86_WIN32
      )
    else(MINGW) # Visual Studio
      if(${CMAKE_SIZEOF_VOID_P} EQUAL 8)
          enable_language(ASM_MASM)
          set(_ctype_arch_impl win64.asm)
      else(${CMAKE_SIZEOF_VOID_P} EQUAL 8)
          set(_ctype_arch_impl win32.c)
      endif(${CMAKE_SIZEOF_VOID_P} EQUAL 8)
      add_python_extension(_ctypes
          SOURCES _ctypes/_ctypes.c
                  _ctypes/callbacks.c
                  _ctypes/callproc.c
                  _ctypes/cfield.c
                  _ctypes/malloc_closure.c
                  _ctypes/stgdict.c
                  _ctypes/libffi_msvc/prep_cif.c
                  _ctypes/libffi_msvc/ffi.c
                  _ctypes/libffi_msvc/${_ctype_arch_impl}
          REQUIRES BUILD_SHARED
          INCLUDEDIRS ${SRC_DIR}/Modules/_ctypes/libffi_msvc
        )
    endif(MINGW)
else(WIN32)
    set(_libffi_system_extra_src)
    if(APPLE)
        # TODO - Jc:02/20/2013
        #add_python_extension(_ctypes
        #    SOURCES _ctypes/_ctypes.c
        #            _ctypes/callbacks.c
        #            _ctypes/callproc.c
        #            _ctypes/cfield.c
        #            _ctypes/libffi_osx/src/closures.c
        #            _ctypes/libffi_osx/${_libffi_system_dir}/ffi.c
        #            _ctypes/libffi_osx/${_libffi_system_dir}/ffi64.c
        #            _ctypes/libffi_osx/src/prep_cif.c
        #            _ctypes/stgdict.c
        #            _ctypes/libffi_osx/${_libffi_system_dir}/sysv.S
        #            _ctypes/libffi_osx/${_libffi_system_dir}/darwin64.S
        #    INCLUDEDIRS ${SRC_DIR}/Modules/_ctypes/libffi/src/${_libffi_system_dir}
        #                ${SRC_DIR}/Modules/_ctypes/libffi/include
        #)
    else(APPLE)
        enable_language(ASM)
        if("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "x86_64")
          set(_libffi_system_extra_src
                _ctypes/libffi/src/${_libffi_system_dir}/ffi64.c
                _ctypes/libffi/src/${_libffi_system_dir}/unix64.S
                )
        endif()
        add_python_extension(_ctypes
            SOURCES _ctypes/_ctypes.c
                    _ctypes/callbacks.c
                    _ctypes/callproc.c
                    _ctypes/cfield.c
                    _ctypes/libffi/src/closures.c
                    _ctypes/libffi/src/prep_cif.c
                    _ctypes/stgdict.c
                    _ctypes/libffi/src/${_libffi_system_dir}/ffi.c
                    _ctypes/libffi/src/${_libffi_system_dir}/sysv.S
                    ${_libffi_system_extra_src}
            INCLUDEDIRS ${SRC_DIR}/Modules/_ctypes/libffi/src/${_libffi_system_dir}
                        ${SRC_DIR}/Modules/_ctypes/libffi/include
                        ${CMAKE_SOURCE_DIR}/cmake # For ffi.h and fficonfig.h
        )
    endif(APPLE)
endif(WIN32)

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
else(EXPAT_LIBRARIES AND EXPAT_INCLUDE_DIRS)
    set(_pyexpat_definitions XML_STATIC)
    if(UNIX)
        list(APPEND _pyexpat_definitions HAVE_EXPAT_CONFIG_H)
    elseif(MSVC)
        list(APPEND _pyexpat_definitions COMPILED_FROM_DSP)
    endif(UNIX)
    add_python_extension(pyexpat
        SOURCES pyexpat.c
                expat/xmlparse.c
                expat/xmlrole.c
                expat/xmltok.c
        DEFINITIONS ${_pyexpat_definitions}
        INCLUDEDIRS ${SRC_DIR}/Modules/expat
    )
    set(_elementtree_definitions USE_PYEXPAT_CAPI)
    if(MSVC)
        list(APPEND _elementtree_definitions COMPILED_FROM_DSP)
    endif()
    add_python_extension(_elementtree
        SOURCES _elementtree.c
        DEFINITIONS ${_elementtree_definitions}
        INCLUDEDIRS ${SRC_DIR}/Modules/expat
    )
endif(EXPAT_LIBRARIES AND EXPAT_INCLUDE_DIRS)

# If openssl is NOT available then build some other hash implementations on UNIX
set(HASH_NOT_AVAILABLE ON)
if(NOT WIN32 AND OPENSSL_LIBRARIES)
  set(HASH_NOT_AVAILABLE OFF)
endif()

add_python_extension(_md5 REQUIRES HASH_NOT_AVAILABLE ${MSVC_BUILTIN} SOURCES md5.c md5module.c)
add_python_extension(_sha REQUIRES HASH_NOT_AVAILABLE ${MSVC_BUILTIN} SOURCES shamodule.c)
add_python_extension(_sha256 REQUIRES HASH_NOT_AVAILABLE ${MSVC_BUILTIN} SOURCES sha256module.c)
add_python_extension(_sha512 REQUIRES HASH_NOT_AVAILABLE ${MSVC_BUILTIN} SOURCES sha512module.c)

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
    ${MSVC_BUILTIN}
    SOURCES binascii.c
    DEFINITIONS ${binascii_DEFINITIONS}
    LIBRARIES ${binascii_LIBRARIES}
    INCLUDEDIRS ${binascii_INCLUDEDIRS}
)
add_python_extension(_bsddb
    REQUIRES DB_INCLUDE_PATH DB_LIBRARIES
    SOURCES _bsddb.c
    LIBRARIES ${DB_LIBRARIES}
    INCLUDEDIRS ${DB_INCLUDE_PATH}
)
add_python_extension(bz2
    REQUIRES BZIP2_LIBRARIES BZIP2_INCLUDE_DIR
    SOURCES bz2module.c
    LIBRARIES ${BZIP2_LIBRARIES}
    INCLUDEDIRS ${BZIP2_INCLUDE_DIR}
)
add_python_extension(_curses_panel
    REQUIRES CURSES_LIBRARIES PANEL_LIBRARIES "HAVE_PANEL_H OR HAVE_NCURSES_PANEL_H"
    SOURCES _curses_panel.c
    LIBRARIES ${CURSES_LIBRARIES} ${PANEL_LIBRARIES}
)
add_python_extension(_curses
    REQUIRES CURSES_LIBRARIES HAVE_CURSES_H
    SOURCES _cursesmodule.c
    LIBRARIES ${CURSES_LIBRARIES}
)
add_python_extension(dbm
    REQUIRES NDBM_TAG GDBM_LIBRARY GDBM_COMPAT_LIBRARY
    SOURCES dbmmodule.c
    DEFINITIONS HAVE_${NDBM_TAG}_H
    LIBRARIES ${GDBM_LIBRARY} ${GDBM_COMPAT_LIBRARY}
    INCLUDEDIRS ${${NDBM_TAG}_INCLUDE_PATH}
)
add_python_extension(gdbm
    REQUIRES GDBM_INCLUDE_PATH GDBM_LIBRARY GDBM_COMPAT_LIBRARY
    SOURCES gdbmmodule.c
    DEFINITIONS HAVE_GDBM_DASH_NDBM_H
    LIBRARIES ${GDBM_LIBRARY}
    INCLUDEDIRS ${GDBM_INCLUDE_PATH}
)
add_python_extension(_hashlib
    REQUIRES OPENSSL_INCLUDE_DIR OPENSSL_LIBRARIES
    SOURCES _hashopenssl.c
    LIBRARIES ${OPENSSL_LIBRARIES}
    INCLUDEDIRS ${OPENSSL_INCLUDE_DIR}
)
if(ENABLE_HASHLIB AND CMAKE_C_COMPILER_ID MATCHES GNU)
    set_property(SOURCE ${SRC_DIR}/Modules/_hashopenssl.c PROPERTY COMPILE_FLAGS -Wno-deprecated-declarations)
endif()
add_python_extension(readline
    REQUIRES READLINE_INCLUDE_PATH READLINE_LIBRARY CURSES_LIBRARIES HAVE_READLINE_READLINE_H
    SOURCES readline.c
    LIBRARIES ${READLINE_LIBRARY} ${CURSES_LIBRARIES}
    INCLUDEDIRS ${READLINE_INCLUDE_PATH}
)
add_python_extension(_sqlite3
    REQUIRES SQLITE3_INCLUDE_PATH SQLITE3_LIBRARY
    SOURCES _sqlite/cache.c
            _sqlite/connection.c
            _sqlite/cursor.c
            _sqlite/microprotocols.c
            _sqlite/module.c
            _sqlite/prepare_protocol.c
            _sqlite/row.c
            _sqlite/statement.c
            _sqlite/util.c
    DEFINITIONS MODULE_NAME="sqlite3"
    INCLUDEDIRS ${SQLITE3_INCLUDE_PATH}
    LIBRARIES ${SQLITE3_LIBRARY}
)
if(ENABLE_SQLITE3 AND CMAKE_C_COMPILER_ID MATCHES GNU)
    set_property(SOURCE ${SRC_DIR}/Modules/_sqlite/module.c PROPERTY COMPILE_FLAGS -Wno-deprecated-declarations)
endif()
set(_ssl_LIBRARIES ${OPENSSL_LIBRARIES})
if(WIN32)
    list(APPEND _ssl_LIBRARIES Crypt32 ws2_32)
endif()
add_python_extension(_ssl
    REQUIRES OPENSSL_INCLUDE_DIR OPENSSL_LIBRARIES
    SOURCES _ssl.c
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
add_python_extension(zlib
    REQUIRES ZLIB_LIBRARY ZLIB_INCLUDE_DIR
    SOURCES zlibmodule.c
    LIBRARIES ${ZLIB_LIBRARY}
    INCLUDEDIRS ${ZLIB_INCLUDE_DIR}
)

if(USE_LIBEDIT)
    set_target_properties(extension_readline PROPERTIES
        COMPILE_DEFINITIONS "USE_LIBEDIT")
endif()
