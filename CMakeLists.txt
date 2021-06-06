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

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${COMPILER_FLAGS}")
