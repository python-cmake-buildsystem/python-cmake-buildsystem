# Install all the header files in Include/

set(includedir ${SRC_DIR}/Include)
file(GLOB_RECURSE hfiles RELATIVE ${includedir} "${includedir}/*")

foreach(file ${hfiles})
    get_filename_component(path ${file} PATH)
    install(FILES ${includedir}/${file} DESTINATION include/${LIBPYTHON}/${path})
endforeach(file)
