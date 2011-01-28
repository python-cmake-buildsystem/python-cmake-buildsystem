# Install all the python module source from Lib/

set(libdir ${CMAKE_SOURCE_DIR}/Lib)
file(GLOB_RECURSE libfiles RELATIVE ${libdir} "${libdir}/*")

foreach (file ${libfiles})
    get_filename_component(path ${file} PATH)
    install(FILES ${libdir}/${file} DESTINATION lib/${LIBPYTHON}/${path})
endforeach (file)
