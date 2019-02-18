cmake_minimum_required(VERSION 2.8.6)
include(asv_cmake_defaults)

set(instloc "${CMAKE_INSTALL_PREFIX}")
set(wloc "${CMAKE_SOURCE_DIR}")
set(iscript "${wloc}/run_py_ver.py")
install(CODE
    "execute_process(COMMAND python ${iscript} ${instloc} setup_py_env.py ${instloc} WORKING_DIRECTORY ${wloc})")
