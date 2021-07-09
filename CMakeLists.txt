cmake_minimum_required(VERSION 3.12)

#
# Project Configuration
#
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

project(uvgrtp
        VERSION 2.0.0)

option(DISABLE_CRYPTO "Do not build uvgRTP with crypto enabled" OFF)
include(cmake/FindDependencies.cmake)

add_library(${PROJECT_NAME} SHARED)
set_target_properties(${PROJECT_NAME} PROPERTIES
        SOVERSION ${CMAKE_MAJOR_VERSION}
        VERSION ${PROJECT_VERSION}
        )

target_sources(${PROJECT_NAME} PRIVATE
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

# Including header files so VisualStudio will list them correctly
target_sources(${PROJECT_NAME} PRIVATE
        src/random.hh
        src/dispatch.hh
        src/holepuncher.hh
        src/hostname.hh
        src/mingw_inet.hh
        src/multicast.hh
        src/pkt_dispatch.hh
        src/poll.hh
        src/rtp.hh
        src/zrtp.hh
        src/queue.hh
        include/util.hh
        include/clock.hh
        include/crypto.hh
        include/debug.hh
        include/frame.hh
        include/lib.hh
        include/media_stream.hh
        include/rtcp.hh
        include/runner.hh
        include/session.hh
        include/socket.hh
        )

target_link_libraries(${PROJECT_NAME} PRIVATE Threads::Threads)
target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_SOURCE_DIR}/src)


target_include_directories(${PROJECT_NAME} PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include/${PROJECT_NAME}>
        )

#TODO: DO I still need EXCLUDE_FROM_ALL
add_subdirectory(test EXCLUDE_FROM_ALL)


if(MSVC)
    target_compile_options(${PROJECT_NAME} PRIVATE /Zc:__cplusplus)
else()
    target_compile_options(${PROJECT_NAME} PRIVATE -Wall -Wextra -Wpedantic #[[-Werror]])
endif()

if (DISABLE_CRYPTO)
    target_compile_definitions(${PROJECT_NAME} PRIVATE __RTP_NO_CRYPTO__)
endif()

if (UNIX)
    # Check the getrandom() function exists
    include(CheckCXXSymbolExists)
    check_cxx_symbol_exists(getrandom sys/random.h HAVE_GETRANDOM)

    if(HAVE_GETRANDOM)
        target_compile_definitions(${PROJECT_NAME} PRIVATE HAVE_GETRANDOM=1)
    endif()
endif (UNIX)


#
# Install
#
# Define install target, install libraries and archives (static libraries) to "<prefix>/..."
include(GNUInstallDirs)
install(TARGETS ${PROJECT_NAME} EXPORT ${PROJECT_NAME}Targets
        LIBRARY
            DESTINATION ${CMAKE_INSTALL_LIBDIR}
            COMPONENT Runtime
        ARCHIVE
            DESTINATION ${CMAKE_INSTALL_LIBDIR}
            COMPONENT Runtime
        RUNTIME
            DESTINATION ${CMAKE_INSTALL_BINDIR}
            COMPONENT Runtime)

#Copy all header files to the <prefix>/include/uvgrtp directory
file(GLOB DEPLOY_FILES_AND_DIRS "${CMAKE_SOURCE_DIR}/include/*")
install(FILES ${DEPLOY_FILES_AND_DIRS}
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}/
        COMPONENT Develop)

#Create a File representing the current library version
include(CMakePackageConfigHelpers)
write_basic_package_version_file(
        "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}/${PROJECT_NAME}ConfigVersion.cmake"
        COMPATIBILITY SameMajorVersion
)

#Create a Targets file representing exported targets (for usage within the build tree)
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

#
# Adding target to installing cmake package
#
set(ConfigPackageLocation lib/cmake/${PROJECT_NAME})
install(EXPORT ${PROJECT_NAME}Targets
        FILE ${PROJECT_NAME}Targets.cmake
        NAMESPACE ${PROJECT_NAME}::
        DESTINATION ${ConfigPackageLocation}
        )

install(FILES cmake/${PROJECT_NAME}Config.cmake cmake/${PROJECT_NAME}Macros.cmake
        "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}/${PROJECT_NAME}ConfigVersion.cmake"
        DESTINATION ${ConfigPackageLocation}
        COMPONENT uvgRTPMain
)
