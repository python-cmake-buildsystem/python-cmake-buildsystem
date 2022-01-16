set(files)

if(PY_VERSION VERSION_GREATER_EQUAL "3.6")
list(APPEND files
  Tools/scripts/run_tests.py
)
endif()

foreach(file IN LISTS files)
  get_filename_component(path ${file} PATH)
  file(COPY ${SRC_DIR}/${file} DESTINATION ${PROJECT_BINARY_DIR}/${LIBDIR}/${path})
  install(FILES ${SRC_DIR}/${file} DESTINATION ${LIBDIR}/${path})
endforeach()
