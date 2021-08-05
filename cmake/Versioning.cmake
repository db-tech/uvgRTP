if(GIT_FOUND)
    execute_process(
            COMMAND ${GIT_EXECUTABLE} rev-parse --short HEAD
            RESULT_VARIABLE result
            OUTPUT_VARIABLE uvgrtp_GIT_HASH
            OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    if(result)
        message(WARNING "Failed to get git hash: ${result}")
    endif()
endif()

if(uvgrtp_GIT_HASH)
    SET(uvgrtp_GIT_HASH "-${uvgrtp_GIT_HASH}")
endif()

option(RELEASE_VERSION "Create a release version" OFF)
if(RELEASE_VERSION)
    set (LIBRARY_VERSION ${PROJECT_VERSION})
else()
    set (LIBRARY_VERSION ${PROJECT_VERSION}${uvgrtp_GIT_HASH})
endif()

configure_file(cmake/uvgrtp_version.cpp.in uvgrtp_version.cpp
        @ONLY
        )
add_library(${PROJECT_NAME}_version OBJECT
        ${CMAKE_CURRENT_BINARY_DIR}/uvgrtp_version.cpp)
target_include_directories(${PROJECT_NAME}_version
        PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
        )


