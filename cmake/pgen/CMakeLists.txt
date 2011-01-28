cmake_minimum_required(VERSION 2.6)

add_definitions(-DPy_BUILD_CORE)
add_definitions(-DNDEBUG)

set(PGEN_SOURCES
    ${CMAKE_SOURCE_DIR}/Objects/obmalloc.c
    ${CMAKE_SOURCE_DIR}/Parser/acceler.c
    ${CMAKE_SOURCE_DIR}/Parser/bitset.c
    ${CMAKE_SOURCE_DIR}/Parser/firstsets.c
    ${CMAKE_SOURCE_DIR}/Parser/grammar1.c
    ${CMAKE_SOURCE_DIR}/Parser/grammar.c
    ${CMAKE_SOURCE_DIR}/Parser/listnode.c
    ${CMAKE_SOURCE_DIR}/Parser/metagrammar.c
    ${CMAKE_SOURCE_DIR}/Parser/node.c
    ${CMAKE_SOURCE_DIR}/Parser/parser.c
    ${CMAKE_SOURCE_DIR}/Parser/parsetok.c
    ${CMAKE_SOURCE_DIR}/Parser/pgen.c
    ${CMAKE_SOURCE_DIR}/Parser/pgenmain.c
    ${CMAKE_SOURCE_DIR}/Parser/printgrammar.c
    ${CMAKE_SOURCE_DIR}/Parser/tokenizer_pgen.c
    ${CMAKE_SOURCE_DIR}/Python/mysnprintf.c
    ${CMAKE_SOURCE_DIR}/Python/pyctype.c
)

add_executable(pgen ${PGEN_SOURCES})
