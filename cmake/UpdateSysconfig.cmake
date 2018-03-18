
#
# Required by Python >= 2.7.5
#
# This cmake script allows to adapt the output of sysconfig._generate_posix_vars()
# function to play nice with CMake build system.
#
#  1. Backup original pybuilddir.txt to pybuilddir.txt.backup
#  2. Read the value PYBUILDDIR written in pybuilddir.txt
#  3. Copy the file <PYBUILDDIR>/<SYSCONFIGDATA_PY> to <EXTENSION_INSTALL_DIR>
#  4. Create a new pybuilddir.txt file with <EXTENSION_INSTALL_DIR>
#

# Sanity checks
foreach(var BIN_BUILD_DIR PYTHON_BINARY_DIR EXTENSION_INSTALL_DIR SYSCONFIGDATA_PY)
  if(NOT DEFINED ${var})
    message(FATAL_ERROR "CMake parameter -D${var} is missing !")
  endif()
endforeach()

set(_pybuilddir ${BIN_BUILD_DIR}/pybuilddir.txt)
if(NOT EXISTS ${_pybuilddir})
  message(FATAL_ERROR "File ${_pybuilddir} does NOT exist")
endif()

# Backup file
if(NOT EXISTS ${_pybuilddir}.backup)
  execute_process(
    COMMAND ${CMAKE_COMMAND} -E copy
      ${_pybuilddir} ${_pybuilddir}.backup
    )
endif()

# Read PYBUILDDIR value
file(READ ${_pybuilddir}.backup PYBUILDDIR)

# Copy SYSCONFIGDATA_PY
execute_process(COMMAND ${CMAKE_COMMAND} -E copy_if_different
  ${BIN_BUILD_DIR}/${PYBUILDDIR}/${SYSCONFIGDATA_PY}
  ${PYTHON_BINARY_DIR}/${EXTENSION_INSTALL_DIR}/${SYSCONFIGDATA_PY}
  )

# Create new file
file(WRITE "${_pybuilddir}" "${EXTENSION_INSTALL_DIR}")
