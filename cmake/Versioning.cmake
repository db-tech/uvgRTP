
set(uvgrtp_GIT_HASH "fcf2c8fd")
execute_process(
        COMMAND ${GIT_EXECUTABLE} rev-parse --short HEAD
        RESULT_VARIABLE result
        OUTPUT_VARIABLE uvgrtp_GIT_HASH
        OUTPUT_STRIP_TRAILING_WHITESPACE
)
if(result)
    message(FATAL_ERROR "Failed to get git hash: ${result}")
endif()

configure_file(cmake/rtp_version.cpp.in rtp_version.cpp
        @ONLY
        )
add_library(${PROJECT_NAME}_version OBJECT
        ${CMAKE_CURRENT_BINARY_DIR}/rtp_version.cpp)
target_include_directories(${PROJECT_NAME}_version
        PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
        )


