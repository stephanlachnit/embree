## ======================================================================== ##
## Copyright 2009-2017 Intel Corporation                                    ##
##                                                                          ##
## Licensed under the Apache License, Version 2.0 (the "License");          ##
## you may not use this file except in compliance with the License.         ##
## You may obtain a copy of the License at                                  ##
##                                                                          ##
##     http://www.apache.org/licenses/LICENSE-2.0                           ##
##                                                                          ##
## Unless required by applicable law or agreed to in writing, software      ##
## distributed under the License is distributed on an "AS IS" BASIS,        ##
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. ##
## See the License for the specific language governing permissions and      ##
## limitations under the License.                                           ##
## ======================================================================== ##

SET(FLAGS_SSE2  "-msse2")
SET(FLAGS_SSE3  "-msse3")
SET(FLAGS_SSSE3 "-mssse3")
SET(FLAGS_SSE41 "-msse4.1")
SET(FLAGS_SSE42 "-msse4.2")
SET(FLAGS_AVX   "-mavx")
SET(FLAGS_AVX2  "-mf16c -mavx2 -mfma -mlzcnt -mbmi -mbmi2")
SET(FLAGS_AVX512KNL "-march=knl")
SET(FLAGS_AVX512SKX "-march=skx")

IF (WIN32)

  SET(COMMON_CXX_FLAGS "")
  SET(COMMON_CXX_FLAGS "${COMMON_CXX_FLAGS} /EHsc")        # catch C++ exceptions only and extern "C" functions never throw a C++ exception
#  SET(COMMON_CXX_FLAGS "${COMMON_CXX_FLAGS} /MP")          # compile source files in parallel
  SET(COMMON_CXX_FLAGS "${COMMON_CXX_FLAGS} /GR")          # enable runtime type information (on by default)
  SET(COMMON_CXX_FLAGS "${COMMON_CXX_FLAGS} -Xclang -fcxx-exceptions") # enable C++ exceptions in Clang
  IF (EMBREE_STACK_PROTECTOR)
    SET(COMMON_CXX_FLAGS "${COMMON_CXX_FLAGS} /GS")          # protects against return address overrides
  ELSE()
    SET(COMMON_CXX_FLAGS "${COMMON_CXX_FLAGS} /GS-")          # do not protect against return address overrides
  ENDIF()
  
  SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} ${COMMON_CXX_FLAGS}")
  SET(CMAKE_EXE_LINKER_FLAGS_DEBUG "${CMAKE_EXE_LINKER_FLAGS_DEBUG} /DEBUG")        # generate debug information
  SET(CMAKE_SHARED_LINKER_FLAGS_DEBUG "${CMAKE_SHARED_LINKER_FLAGS_DEBUG} /DEBUG")  # generate debug information

  SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} ${COMMON_CXX_FLAGS}")
  SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /Ox")                       # enable full optimizations
  SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /Oi")                       # inline intrinsic functions
  SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /Gy")                       # package individual functions
  SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -fno-vectorize")            # disable auto vectorization
  
  SET(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} ${COMMON_CXX_FLAGS}")
  SET(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} /Ox")                      # enable full optimizations
  SET(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} /Oi")                      # inline intrinsic functions
  SET(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} /Gy")                      # package individual functions
  SET(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} -fno-vectorize")           # disable auto vectorization
  SET(CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO "${CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO} /DEBUG")        # generate debug information
  SET(CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO "${CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO} /DEBUG")  # generate debug information
  
  SET(SECURE_LINKER_FLAGS "")
  SET(SECURE_LINKER_FLAGS "${SECURE_LINKER_FLAGS} /NXCompat")    # compatible with data execution prevention (on by default)
  SET(SECURE_LINKER_FLAGS "${SECURE_LINKER_FLAGS} /DynamicBase") # random rebase of executable at load time
  IF (CMAKE_SIZEOF_VOID_P EQUAL 4)
    SET(SECURE_LINKER_FLAGS "${SECURE_LINKER_FLAGS} /SafeSEH")     # invoke known exception handlers (Win32 only, x64 exception handlers are safe by design)
  ENDIF()
  SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${SECURE_LINKER_FLAGS}")
  SET(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${SECURE_LINKER_FLAGS}")

  INCLUDE(msvc_post)

ELSE()

  OPTION(EMBREE_IGNORE_CMAKE_CXX_FLAGS "When enabled Embree ignores default CMAKE_CXX_FLAGS." ON)
  IF (EMBREE_IGNORE_CMAKE_CXX_FLAGS)
    SET(CMAKE_CXX_FLAGS "")
  ENDIF()

  SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall")                       # enables most warnings
  SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wformat -Wformat-security")  # enables string format vulnerability warnings
  IF (NOT APPLE)
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIE")                     # enables support for more secure position independent execution
  ENDIF()
  SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")                       # generate position independent code suitable for shared libraries
  SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")                  # enables C++11 features
  SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fvisibility=hidden")         # makes all symbols hidden by default
  SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fvisibility-inlines-hidden") # makes all inline symbols hidden by default
  SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-strict-aliasing")        # disables strict aliasing rules
  SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D_FORTIFY_SOURCE=2")         # perform extra security checks for some standard library calls
  SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-tree-vectorize")         # disable auto vectorizer
  IF (EMBREE_STACK_PROTECTOR)
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fstack-protector")           # protects against return address overrides
  ENDIF()

  SET(CMAKE_CXX_FLAGS_DEBUG "")
  SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DDEBUG")          # enable assertions
  SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DTBB_USE_DEBUG")  # configure TBB in debug mode
  SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -g")               # generate debug information
  SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -O0")              # disable optimizations

  SET(CMAKE_CXX_FLAGS_RELEASE "")
  SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -DNDEBUG")     # disable assertions
  SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3")          # enable full optimizations

  SET(CMAKE_CXX_FLAGS_RELWITHDEBINFO "")
  SET(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} -DDEBUG")         # enable assertions
  SET(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} -DTBB_USE_DEBUG") # configure TBB in debug mode
  SET(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} -g")              # generate debug information
  SET(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} -O3")             # enable full optimizations

  IF (APPLE)
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mmacosx-version-min=10.7")   # makes sure code runs on older MacOSX versions
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++")             # link against libc++ which supports C++11 features
  ELSE(APPLE)
    SET(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--no-undefined") # issues link error for undefined symbols in shared library
    SET(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -z noexecstack")     # we do not need an executable stack
    SET(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -z relro -z now")    # re-arranges data sections to increase security
    SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -z noexecstack")           # we do not need an executable stack
    SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -z relro -z now")          # re-arranges data sections to increase security
    SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -pie")                     # enables position independent execution for executable
  ENDIF(APPLE)

ENDIF()
