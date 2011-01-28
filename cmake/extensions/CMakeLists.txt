add_definitions(-DWITH_APPINIT=1)
add_definitions(-DHAVE_GDBM_DASH_NDBM_H)
add_definitions(-DUSE_ZLIB_CRC32)
add_definitions(-DHAVE_EXPAT_CONFIG_H=1)
add_definitions(-DUSE_PYEXPAT_CAPI)

add_python_extension(array SOURCES arraymodule.c)
add_python_extension(audioop SOURCES audioop.c)
add_python_extension(_bisect SOURCES _bisectmodule.c)
add_python_extension(cmath SOURCES _math.c cmathmodule.c LIBRARIES m)
add_python_extension(_codecs_cn SOURCES cjkcodecs/_codecs_cn.c)
add_python_extension(_codecs_hk SOURCES cjkcodecs/_codecs_hk.c)
add_python_extension(_codecs_iso2022 SOURCES cjkcodecs/_codecs_iso2022.c)
add_python_extension(_codecs_jp SOURCES cjkcodecs/_codecs_jp.c)
add_python_extension(_codecs_kr SOURCES cjkcodecs/_codecs_kr.c)
add_python_extension(_codecs_tw SOURCES cjkcodecs/_codecs_tw.c)
add_python_extension(_collections SOURCES _collectionsmodule.c)
add_python_extension(cPickle SOURCES cPickle.c)
add_python_extension(crypt SOURCES cryptmodule.c LIBRARIES crypt)
add_python_extension(cStringIO SOURCES cStringIO.c)
add_python_extension(_csv SOURCES _csv.c)
add_python_extension(_ctypes
    SOURCES _ctypes/_ctypes.c
            _ctypes/callbacks.c
            _ctypes/callproc.c
            _ctypes/cfield.c
            _ctypes/libffi/src/closures.c
            _ctypes/libffi/src/dlmalloc.c
            _ctypes/libffi/src/x86/ffi.c
            _ctypes/libffi/src/x86/ffi64.c
            _ctypes/libffi/src/prep_cif.c
            _ctypes/stgdict.c
            _ctypes/libffi/src/x86/sysv.S
            _ctypes/libffi/src/x86/unix64.S
    INCLUDEDIRS ${CMAKE_SOURCE_DIR}/Modules/_ctypes/libffi/src/x86
                ${CMAKE_SOURCE_DIR}/Modules/_ctypes/libffi/include
)
add_python_extension(_ctypes_test SOURCES _ctypes/_ctypes_test.c)
add_python_extension(datetime SOURCES datetimemodule.c timemodule.c LIBRARIES m)
add_python_extension(_elementtree SOURCES _elementtree.c)
add_python_extension(fcntl SOURCES fcntlmodule.c)
add_python_extension(_functools SOURCES _functoolsmodule.c)
add_python_extension(future_builtins SOURCES future_builtins.c)
add_python_extension(grp SOURCES grpmodule.c)
add_python_extension(_heapq SOURCES _heapqmodule.c)
add_python_extension(_hotshot SOURCES _hotshot.c)
add_python_extension(_io SOURCES
    _io/_iomodule.c
    _io/bufferedio.c
    _io/bytesio.c
    _io/fileio.c
    _io/iobase.c
    _io/stringio.c
    _io/textio.c
)
add_python_extension(itertools SOURCES itertoolsmodule.c)
add_python_extension(_json SOURCES _json.c)
add_python_extension(linuxaudiodev SOURCES linuxaudiodev.c)
add_python_extension(_locale SOURCES _localemodule.c)
add_python_extension(_lsprof SOURCES _lsprof.c rotatingtree.c)
add_python_extension(math SOURCES _math.c mathmodule.c)
add_python_extension(mmap SOURCES mmapmodule.c)
add_python_extension(_multibytecodec SOURCES cjkcodecs/multibytecodec.c)
add_python_extension(_multiprocessing SOURCES
    _multiprocessing/multiprocessing.c
    _multiprocessing/semaphore.c
    _multiprocessing/socket_connection.c
)
add_python_extension(nis SOURCES nismodule.c LIBRARIES nsl)
add_python_extension(operator SOURCES operator.c)
add_python_extension(ossaudiodev SOURCES ossaudiodev.c)
add_python_extension(parser SOURCES parsermodule.c)
add_python_extension(_random SOURCES _randommodule.c)
add_python_extension(resource SOURCES resource.c)
add_python_extension(select SOURCES selectmodule.c)
add_python_extension(_socket SOURCES socketmodule.c)
add_python_extension(spwd SOURCES spwdmodule.c)
add_python_extension(strop SOURCES stropmodule.c)
add_python_extension(_struct SOURCES _struct.c)
add_python_extension(syslog SOURCES syslogmodule.c)
add_python_extension(termios SOURCES termios.c)
add_python_extension(_testcapi SOURCES _testcapimodule.c)
add_python_extension(time SOURCES timemodule.c LIBRARIES m)
add_python_extension(unicodedata SOURCES unicodedata.c)


if (BZIP2_FOUND)
    add_python_extension(bz2 SOURCES bz2module.c LIBRARIES ${BZIP2_LIBRARIES})
endif (BZIP2_FOUND)

if (CURSES_FOUND)
    add_python_extension(_curses_panel SOURCES _curses_panel.c LIBRARIES ${CURSES_LIBRARIES})
    add_python_extension(_curses SOURCES _cursesmodule.c LIBRARIES ${CURSES_LIBRARIES})
endif (CURSES_FOUND)

if (DB_INCLUDE_PATH AND DB_LIBRARIES)
    add_python_extension(_bsddb
        SOURCES _bsddb.c
        LIBRARIES ${DB_LIBRARIES}
        INCLUDEDIRS ${DB_INCLUDE_PATH}
    )
endif (DB_INCLUDE_PATH AND DB_LIBRARIES)

if (EXPAT_FOUND)
    add_python_extension(pyexpat
        SOURCES pyexpat.c
                expat/xmlparse.c
                expat/xmlrole.c
                expat/xmltok.c
        LIBRARIES ${EXPAT_LIBRARIES}
    )
endif (EXPAT_FOUND)

if (GDBM_INCLUDE_PATH AND GDBM_LIBRARY AND GDBM_COMPAT_LIBRARY)
    add_python_extension(dbm
        SOURCES dbmmodule.c
        LIBRARIES ${GDBM_LIBRARY} ${GDBM_COMPAT_LIBRARY}
        INCLUDEDIRS ${GDBM_INCLUDE_PATH}
    )
    add_python_extension(gdbm
        SOURCES gdbmmodule.c
        LIBRARIES ${GDBM_LIBRARY}
        INCLUDEDIRS ${GDBM_INCLUDE_PATH}
    )
endif (GDBM_INCLUDE_PATH AND GDBM_LIBRARY AND GDBM_COMPAT_LIBRARY)

if (OPENSSL_FOUND)
    add_python_extension(_hashlib SOURCES _hashopenssl.c LIBRARIES ${OPENSSL_LIBRARIES})
    add_python_extension(_ssl SOURCES _ssl.c LIBRARIES ${OPENSSL_LIBRARIES})
endif (OPENSSL_FOUND)

if (READLINE_INCLUDE_PATH AND READLINE_LIBRARY)
    add_python_extension(readline
        SOURCES readline.c
        LIBRARIES ${READLINE_LIBRARY}
        INCLUDEDIRS ${READLINE_INCLUDE_PATH}
    )
endif (READLINE_INCLUDE_PATH AND READLINE_LIBRARY)

if (TK_FOUND AND TCL_FOUND)
    add_python_extension(_tkinter
        SOURCES _tkinter.c tkappinit.c
        LIBRARIES ${TCL_LIBRARY} ${TK_LIBRARY}
        INCLUDEDIRS ${TCL_INCLUDE_PATH} ${TK_INCLUDE_PATH}
    )
endif (TK_FOUND AND TCL_FOUND)

if (ZLIB_FOUND)
    add_python_extension(binascii SOURCES binascii.c LIBRARIES ${ZLIB_LIBRARIES})
    add_python_extension(zlib SOURCES zlibmodule.c LIBRARIES ${ZLIB_LIBRARIES})
endif (ZLIB_FOUND)

