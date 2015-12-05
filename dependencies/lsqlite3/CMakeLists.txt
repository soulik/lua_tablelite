cmake_minimum_required (VERSION 3.1.0)
project (lsqlite3)

# sqlite3

add_subdirectory(dependencies/sqlite3)
include_directories(dependencies/sqlite3)

set_target_properties(sqlite3
    PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

# Include Lua 5.1

include(FindLua51)
include_directories(SYSTEM ${LUA_INCLUDE_DIR})
include_directories(dependencies/lua/include)

add_subdirectory(src)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY build)
set_target_properties(lsqlite3 PROPERTIES PREFIX "")
