# Install all the header files in Include/

set(includedir ${INCLUDE_BUILD_DIR})
file(GLOB_RECURSE hfiles RELATIVE ${includedir} "${includedir}/*")

foreach(file ${hfiles})
    get_filename_component(path ${file} PATH)
    if(WIN32)
        file(COPY ${includedir}/${file} DESTINATION ${PROJECT_BINARY_DIR}/${INCLUDE_INSTALL_DIR}/${path})
    endif()
    if(INSTALL_DEVELOPMENT)
        install(FILES ${includedir}/${file} DESTINATION ${INCLUDE_INSTALL_DIR}/${path} COMPONENT Development)
    endif()
endforeach()
if(BUILD_FRAMEWORK)
    install(CODE "
        message(STATUS \"Creating Python header framework symlinks...\")
        execute_process(
            COMMAND
                \${CMAKE_COMMAND} -E create_symlink Versions/Current/Headers Headers
            WORKING_DIRECTORY
                \"${CMAKE_INSTALL_PREFIX}/${FRAMEWORK_DIR_ROOT}\"
        )

        execute_process(
            COMMAND
                \${CMAKE_COMMAND} -E create_symlink \"${REL_INCLUDE_INSTALL_DIR}\" Headers
            WORKING_DIRECTORY
                \"${CMAKE_INSTALL_PREFIX}/${FRAMEWORK_DIR_PREFIX}\"
        )
    ")
endif()
