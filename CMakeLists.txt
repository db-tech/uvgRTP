cmake_minimum_required(VERSION 3.5)

#-------------------------------------
# Project Configuration
#-------------------------------------
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

project(uvgrtp)

option(DISABLE_CRYPTO "Do not build uvgRTP with crypto enabled" OFF)
include(cmake/FindDependencies.cmake)

#-------------------------------------
# Define Sources <PRIVATE>
#-------------------------------------
add_library(uvgrtp STATIC
    src/clock.cc
    src/crypto.cc
    src/dispatch.cc
    src/frame.cc
    src/hostname.cc
    src/lib.cc
    src/media_stream.cc
    src/mingw_inet.cc
    src/multicast.cc
    src/pkt_dispatch.cc
    src/poll.cc
    src/queue.cc
    src/random.cc
    src/rtcp.cc
    src/rtp.cc
    src/runner.cc
    src/session.cc
    src/socket.cc
    src/zrtp.cc
    src/holepuncher.cc
    src/formats/media.cc
    src/formats/h26x.cc
    src/formats/h264.cc
    src/formats/h264_pkt_handler.cc
    src/formats/h265.cc
    src/formats/h265_pkt_handler.cc
    src/formats/h266.cc
    src/formats/h266_pkt_handler.cc
    src/zrtp/zrtp_receiver.cc
    src/zrtp/hello.cc
    src/zrtp/hello_ack.cc
    src/zrtp/commit.cc
    src/zrtp/dh_kxchng.cc
    src/zrtp/confirm.cc
    src/zrtp/confack.cc
    src/zrtp/error.cc
    src/rtcp/app.cc
    src/rtcp/sdes.cc
    src/rtcp/bye.cc
    src/rtcp/receiver.cc
    src/rtcp/sender.cc
    src/rtcp/rtcp_runner.cc
    src/srtp/base.cc
    src/srtp/srtp.cc
    src/srtp/srtcp.cc
)

target_link_libraries(${PROJECT_NAME} PUBLIC Threads::Threads)
target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_SOURCE_DIR}/src)
target_include_directories(${PROJECT_NAME} PUBLIC ${CMAKE_SOURCE_DIR}/include)

if (UNIX)
    set(COMPILER_FLAGS "-Wall -Wextra -Wuninitialized -Wshadow -O2 -g -march=native -DNDEBUG")
    
    if (DISABLE_CRYPTO)
        string(APPEND COMPILER_FLAGS " -D__RTP_NO_CRYPTO__")
    endif(DISABLE_CRYPTO)

    # Check the getrandom() function exists
    include(CheckCXXSymbolExists)
    check_cxx_symbol_exists(getrandom sys/random.h HAVE_GETRANDOM)

    if(HAVE_GETRANDOM)
        add_compile_definitions(HAVE_GETRANDOM=1)
    endif()

        install(TARGETS uvgrtp
                ARCHIVE
                DESTINATION /usr/local/lib
        )

    install(DIRECTORY include/ DESTINATION /usr/local/include/uvgrtp
            FILES_MATCHING PATTERN "*.hh"
    )
endif (UNIX)

if (WIN32)
    if(MSVC)
	    # /Zc:__cplusplus makes it so the correct c++ version is defined 
        set(COMPILER_FLAGS "/O2 /DNDEBUG /Zc:__cplusplus")
    else(MSVC)
        set(COMPILER_FLAGS "-O2 -DNDEBUG")
    endif(MSVC)
    SET(OUT_DIR ${CMAKE_BINARY_DIR}/Debug)

    if (DISABLE_CRYPTO)
        if(MSVC)
            string(APPEND COMPILER_FLAGS " /D__RTP_NO_CRYPTO__")
        else(MSVC)
            string(APPEND COMPILER_FLAGS " -D__RTP_NO_CRYPTO__")
        endif(MSVC)
    endif(DISABLE_CRYPTO)

        install(TARGETS uvgrtp
                ARCHIVE
                DESTINATION ${PROJECT_BINARY_DIR}/lib
        )

    install(DIRECTORY include/ DESTINATION ${PROJECT_BINARY_DIR}/include
            FILES_MATCHING PATTERN "*.hh"
    )
endif (WIN32)

#-------------------------------------
# Install
#-------------------------------------
# Define install target, install libraries and archives (static libraries) to "<prefix>/lib"
install(TARGETS ${PROJECT_NAME} EXPORT ${PROJECT_NAME}Targets
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib
        INCLUDES DESTINATION include)

#Copy all header files to the <prefix>/include directory with subdirectories retained
install(DIRECTORY ${CMAKE_SOURCE_DIR}/${PROJECT_NAME}
        DESTINATION include/uvgrtp
        FILES_MATCHING PATTERN "*.h")
include(CMakePackageConfigHelpers)
#Create a File representing the current library version
write_basic_package_version_file(
        "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}/${PROJECT_NAME}ConfigVersion.cmake"
        VERSION "1.0.0"
        COMPATIBILITY SameMajorVersion
)
#Create a Targets file representing exported targets (uvgrtp::uvgrtp)
export(EXPORT ${PROJECT_NAME}Targets
        FILE "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}/${PROJECT_NAME}Targets.cmake"
        NAMESPACE ${PROJECT_NAME}::
        )
#Copy "cmake/uvgrtpConfig.cmake" to "${CMAKE_CURRENT_BINARY_DIR}/uvgrtp/uvgrtpConfig.cmake"
configure_file(cmake/${PROJECT_NAME}Config.cmake
        "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}/${PROJECT_NAME}Config.cmake"
        COPYONLY
        )
#Copy "cmake/uvgrtpMacros.cmake" to "${CMAKE_CURRENT_BINARY_DIR}/uvgrtp/uvgrtpMacros.cmake"
configure_file(cmake/${PROJECT_NAME}Macros.cmake
        "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}/${PROJECT_NAME}Macros.cmake"
        COPYONLY
        )

# -----------------------------------------------
#
# -- Adding target to installing cmake package --
#
# -----------------------------------------------
set(ConfigPackageLocation lib/cmake/${PROJECT_NAME})
install(EXPORT ${PROJECT_NAME}Targets
        FILE ${PROJECT_NAME}Targets.cmake
        NAMESPACE ${PROJECT_NAME}::
        DESTINATION ${ConfigPackageLocation}
        )

install(
        FILES cmake/${PROJECT_NAME}Config.cmake cmake/${PROJECT_NAME}Macros.cmake
        "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}/${PROJECT_NAME}ConfigVersion.cmake"
        DESTINATION ${ConfigPackageLocation}
        COMPONENT Devel
)


set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${COMPILER_FLAGS}")
