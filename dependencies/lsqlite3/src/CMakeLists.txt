set(lsqlite3_src
	lsqlite3.c
)

set(lsqlite3_sources
	${lsqlite3_src}
)

set(lsqlite3_version_script lsqlite3.version)

IF(UNIX)
    IF(CMAKE_COMPILER_IS_GNUCC)
         SET(CMAKE_SHARED_LINKER_FLAGS  "${CMAKE_SHARED_LINKER_FLAGS} ${CMAKE_CXX_COMPILE_OPTIONS_VISIBILITY}hidden -Wl,--version-script=${CMAKE_CURRENT_SOURCE_DIR}/${lsqlite3_version_script}")
    ENDIF(CMAKE_COMPILER_IS_GNUCC)

    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wmissing-declarations")
ENDIF(UNIX)

add_library(lsqlite3 SHARED
	${lsqlite3_sources}
)

if(WIN32)
	configure_file(	${CMAKE_CURRENT_SOURCE_DIR}/lsqlite3.def ${CMAKE_CURRENT_BINARY_DIR}/lsqlite3.def @ONLY)
endif()

if(WIN32)
	if(MSVC)
		set_target_properties(lsqlite3 PROPERTIES LINK_FLAGS "/DEF:lsqlite3.def")
	endif()
endif()

set_target_properties(lsqlite3
    PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

target_link_libraries (lsqlite3
	sqlite3
	${LUA_LIBRARY}
)
