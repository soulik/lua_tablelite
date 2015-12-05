cmake_minimum_required (VERSION 3.1.0)
project (sqlite3)

include_directories(.)

set(sqlite3_src
	sqlite3.c
)

set(sqlite3_sources
	${sqlite3_src}
)

add_definitions(-DSQLITE_ENABLE_COLUMN_METADATA)
add_definitions(-DSQLITE_ENABLE_RTREE)

if(UNIX)
	list(APPEND CMAKE_C_FLAGS "-Wmissing-declarations -fPIC")
endif()

add_library(sqlite3 STATIC
	${sqlite3_sources}
)

set_target_properties(sqlite3
    PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

if (UNIX)
	target_link_libraries (sqlite3
		pthread
	)
endif()

if(WIN32)
	configure_file(	${CMAKE_CURRENT_SOURCE_DIR}/sqlite3.def ${CMAKE_CURRENT_BINARY_DIR}/sqlite3.def @ONLY)
endif()

if(WIN32)
	if(MSVC)
		set_target_properties(sqlite3 PROPERTIES LINK_FLAGS "/DEF:sqlite3.def")
	endif()
endif()


set(CMAKE_RUNTIME_OUTPUT_DIRECTORY build)
set_target_properties(sqlite3 PROPERTIES PREFIX "")
