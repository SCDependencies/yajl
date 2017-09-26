# Copyright (c) 2007-2014, Lloyd Hilaiel <me@lloyd.io>
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

PROJECT(YetAnotherJSONParser C)

SET (YAJL_MAJOR 2)
SET (YAJL_MINOR 1)
SET (YAJL_MICRO 1)

SET (PKG_NAME "yajl")
SET (VERSION "${YAJL_MAJOR}.${YAJL_MINOR}.${YAJL_MICRO}")
SET (YAJL_DIST_NAME "${PKG_NAME}-${VERSION}")
SET (YAJL_TAG_NAME "${YAJL_MAJOR}.${YAJL_MINOR}")

IF (NOT CMAKE_BUILD_TYPE)
  SET(CMAKE_BUILD_TYPE "Release")
ENDIF (NOT CMAKE_BUILD_TYPE)

SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")

IF (WIN32)
  SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /W4")
  ADD_DEFINITIONS(-DWIN32)
  SET(linkFlags "/PDB:NONE /INCREMENTAL:NO /OPT:NOREF /OPT:NOICF")
  SET(CMAKE_EXE_LINKER_FLAGS    "${linkFlags}"
      CACHE STRING "YAJL linker flags" FORCE)
  SET(CMAKE_EXE_LINKER_FLAGS_DEBUG ""
      CACHE STRING "YAJL debug linker flags" FORCE)
  SET(CMAKE_EXE_LINKER_FLAGS_RELEASE
      CACHE STRING "YAJL release linker flags" FORCE)
  SET(CMAKE_SHARED_LINKER_FLAGS "${linkFlags}"
      CACHE STRING "YAJL shared linker flags" FORCE)
  SET(CMAKE_MODULE_LINKER_FLAGS "${linkFlags}"
      CACHE STRING "YAJL module linker flags" FORCE)

  SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /wd4996 /wd4255 /wd4130 /wd4100 /wd4711")
  SET(CMAKE_C_FLAGS_DEBUG "/D DEBUG /Od /Z7")
  SET(CMAKE_C_FLAGS_RELEASE "/D NDEBUG /O2")
ELSE (WIN32)
  SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall")
  IF(CMAKE_COMPILER_IS_GNUCC)
    INCLUDE(CheckCCompilerFlag)
    CHECK_C_COMPILER_FLAG(-fvisibility=hidden HAVE_GCC_VISIBILITY)
    IF(HAVE_GCC_VISIBILITY)
      SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fvisibility=hidden")
    ENDIF(HAVE_GCC_VISIBILITY)
  ENDIF(CMAKE_COMPILER_IS_GNUCC)
  SET(CMAKE_C_FLAGS
      "${CMAKE_C_FLAGS} -std=c99 -pedantic -Wpointer-arith -Wno-format-y2k -Wstrict-prototypes -Wmissing-declarations -Wnested-externs -Wextra	-Wundef -Wwrite-strings -Wold-style-definition -Wredundant-decls -Wno-unused-parameter -Wno-sign-compare -Wmissing-prototypes")

  SET(CMAKE_C_FLAGS_DEBUG "-DDEBUG -g")
  SET(CMAKE_C_FLAGS_RELEASE "-DNDEBUG -O2 -Wuninitialized")
ENDIF (WIN32)


ADD_SUBDIRECTORY(src)
ADD_SUBDIRECTORY(test)
ADD_SUBDIRECTORY(reformatter)
ADD_SUBDIRECTORY(verify)
ADD_SUBDIRECTORY(example)
ADD_SUBDIRECTORY(perf)

INCLUDE(YAJLDoc.cmake)

# a test target
ADD_CUSTOM_TARGET(test
                  ./run_tests.sh ${CMAKE_CURRENT_BINARY_DIR}/test/parsing/yajl_test
                  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/test/parsing)

ADD_CUSTOM_TARGET(test-api ${CMAKE_CURRENT_SOURCE_DIR}/test/api/run_tests.sh
                  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/test/api)

## RPM packaging
# CPACK
set(CPACK_PACKAGE_VERSION ${VERSION})
set(CPACK_GENERATOR  "RPM")
# set(CPACK_GENERATOR  "DEB")
set(CPACK_PACKAGE_NAME ${PKG_NAME})
set(CPACK_PACKAGE_SUMMARY "Yet Another JSON Library (YAJL)")
set(CPACK_PACKAGE_LICENSE "BSD")
set(CPACK_PACKAGE_RELEASE 0)
set(CPACK_PACKAGE_APP_GROUP "Development/Libraries")
set(CPACK_PACKAGE_CONTACT ${AUTHOR})
set(CPACK_PACKAGE_VENDOR ${VENDOR})
set(CPACK_PACKAGING_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX})
set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${CPACK_PACKAGE_RELEASE}.${CMAKE_SYSTEM_PROCESSOR}")
set(CPACK_RPM_PACKAGE_REQUIRES "cmake")

if(NOT DEFINED CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST)
    set(CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST /usr /usr/local  /usr/local/lib /usr/local/include)
    if(CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST_ADDITION)
      if(CPACK_RPM_PACKAGE_DEBUG)
        message("CPackRPM:Debug: Adding ${CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST_ADDITION} to builtin omit list.")
      endif()
      list(APPEND CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST "${CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST_ADDITION}")
    endif()
endif()


include(CPack)

# source tar ball
add_custom_command(
        OUTPUT ${PKG_NAME}-${CPACK_PACKAGE_VERSION}.tar.gz
        COMMAND git archive --format=tar --prefix=${PKG_NAME}-${CPACK_PACKAGE_VERSION}/ ${YAJL_TAG_NAME} | gzip -c > ${CMAKE_CURRENT_BINARY_DIR}/${PKG_NAME}-${CPACK_PACKAGE_VERSION}.tar.gz
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
add_custom_target(
        src_tgz
        DEPENDS ${PKG_NAME}-${CPACK_PACKAGE_VERSION}.tar.gz
)

# CPack does not have a rule for source rpm
# the following is a way to do that
set(RPM_BUILD_DIR rpm_build)
# rpm spec file
configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/rpm.spec.in
        ${CMAKE_CURRENT_BINARY_DIR}/${RPM_BUILD_DIR}/SPECS/${PKG_NAME}.spec )
# rules to build src rpm
set(SRC_RPM ${PKG_NAME}-${CPACK_PACKAGE_VERSION}-${CPACK_PACKAGE_RELEASE}.src.rpm)
add_custom_command(
        OUTPUT ${SRC_RPM}
        COMMAND ${CMAKE_COMMAND} -E make_directory ${RPM_BUILD_DIR}
        COMMAND ${CMAKE_COMMAND} -E make_directory ${RPM_BUILD_DIR}/BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory ${RPM_BUILD_DIR}/BUILDROOT
        COMMAND ${CMAKE_COMMAND} -E make_directory ${RPM_BUILD_DIR}/RPMS
        COMMAND ${CMAKE_COMMAND} -E make_directory ${RPM_BUILD_DIR}/SOURCES
        COMMAND ${CMAKE_COMMAND} -E make_directory ${RPM_BUILD_DIR}/SPECS
        COMMAND ${CMAKE_COMMAND} -E make_directory ${RPM_BUILD_DIR}/SRPMS
        COMMAND ${CMAKE_COMMAND} -E make_directory ${RPM_BUILD_DIR}/tmp
        COMMAND ${CMAKE_COMMAND} -E copy ${PKG_NAME}-${CPACK_PACKAGE_VERSION}.tar.gz ${RPM_BUILD_DIR}/SOURCES
        COMMAND rpmbuild -bs --define=\"_topdir ${RPM_BUILD_DIR}\" --buildroot=${RPM_BUILD_DIR}/tmp  ${RPM_BUILD_DIR}/SPECS/${PKG_NAME}.spec
        COMMAND ${CMAKE_COMMAND} -E copy ${RPM_BUILD_DIR}/SRPMS/${SRC_RPM} ${SRC_RPM}
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        DEPENDS src_tgz
)
add_custom_target(
        srpm
        DEPENDS ${SRC_RPM}
)
