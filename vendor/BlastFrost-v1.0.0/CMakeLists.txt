cmake_minimum_required(VERSION 3.11)
project(BlastFrost)

include(FetchContent)

#NOTE: If Bifrost is compiled with a different maximum k-mer size, please also adjust this parameter here:
#add_definitions(-DMAX_KMER_SIZE=32)
set(MAX_KMER_SIZE "32")

if (NOT DEFINED LIBRARY_OUTPUT_PATH)
  set(LIBRARY_OUTPUT_PATH ${CMAKE_CURRENT_BINARY_DIR}/lib)
endif()
if (NOT DEFINED CMAKE_RUNTIME_OUTPUT_DIRECTORY)
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)
endif()

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Release")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c99 -O3 -ffunction-sections -fdata-sections -Wl,-gc-sections -s -Wl,--strip-all -fmerge-all-constants -Wl,-z,norelro -fPIE -fPIC -DNDEBUG")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14 -O3 -ffunction-sections -fdata-sections -Wl,-gc-sections -s -Wl,--strip-all -fmerge-all-constants -Wl,-z,norelro -fPIE -fPIC")
endif(NOT CMAKE_BUILD_TYPE)

if (CMAKE_WITH_NATIVE_INSTRUCTIONS)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -march=native -mtune=native")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=native -mtune=native")
else()
  set(CMAKE_WITH_NATIVE_INSTRUCTIONS 0)
endif()

if(CMAKE_WITH_FLTO)
  cmake_policy(SET CMP0069 NEW)
  set(CMAKE_POLICY_DEFAULT_CMP0069 NEW)
  set(CMAKE_INTERPROCEDURAL_OPTIMIZATION 1)
endif()

if(CMAKE_PGO_GENERATE AND NOT CMAKE_PGO_USE)
  if (CMAKE_C_COMPILER_ID STREQUAL "Clang")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fprofile-instr-generate -fcoverage-mapping")
  else()
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fprofile-generate")
  endif()
  if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fprofile-instr-generate -fcoverage-mapping")
  else()
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fprofile-generate")
  endif()
endif()

if(CMAKE_PGO_USE)
  if (CMAKE_C_COMPILER_ID STREQUAL "Clang")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fprofile-instr-use=${CMAKE_CURRENT_BINARY_DIR}/default.profdata -fprofile-correction")
  else()
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fprofile-use -fprofile-correction")
  endif()
  if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fprofile-instr-use=${CMAKE_CURRENT_BINARY_DIR}/default.profdata -fprofile-correction")
  else()
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fprofile-use -fprofile-correction")
  endif()
endif()

find_package(Threads REQUIRED)
find_package(ZLIB REQUIRED)

add_executable(BlastFrost
  src/BlastFrost.cpp
  src/BubbleExplorer.cpp
  src/QuerySearch.cpp
  src/SubGraphTraverser.cpp
  src/UnionFind.cpp
  src/UnitigData.cpp
  )

## alignment-writer
if (DEFINED CMAKE_BIFROST_HEADERS AND DEFINED CMAKE_BIFROST_LIBRARIES)
  message(STATUS "bifrost headers provided in: ${CMAKE_BIFROST_HEADERS}")
  message(STATUS "bifrost library provided in: ${CMAKE_BIFROST_LIBRARIES}")
else()
  FetchContent_Declare(bifrost-compile
    GIT_REPOSITORY    https://github.com/pmelsted/bifrost
    GIT_TAG            v1.0.6.4                           ## BlastFrost does not compile with newer versions
    PREFIX            "external"
    SOURCE_DIR        "${CMAKE_CURRENT_SOURCE_DIR}/external/bifrost"
    BINARY_DIR        "${CMAKE_CURRENT_BINARY_DIR}/external/bifrost"
    BUILD_IN_SOURCE   0
    CMAKE_ARGS      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
                    -D CMAKE_C_FLAGS=${CMAKE_C_FLAGS}
		    -D CMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
		    -D CMAKE_C_COMPILER=${CMAKE_C_COMPILER}
		    -D CMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
		    -D MAX_KMER_SIZE=${MAX_KMER_SIZE}
		    -D COMPILATION_ARCH=${CMAKE_WITH_NATIVE_INSTRUCTIONS}
    INSTALL_COMMAND   ""
    )
  FetchContent_MakeAvailable(bifrost-compile)
  add_dependencies(BlastFrost bifrost_static)
  set_target_properties(Bifrost PROPERTIES EXCLUDE_FROM_ALL 1)
  set_target_properties(bifrost_dynamic PROPERTIES EXCLUDE_FROM_ALL 1)
  set(CMAKE_BIFROST_HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/external/bifrost/src)
  set(CMAKE_BIFROST_LIBRARIES ${CMAKE_CURRENT_BINARY_DIR}/lib/libbifrost.a)
endif()
include_directories(${CMAKE_BIFROST_HEADERS})
target_link_libraries(BlastFrost ${CMAKE_BIFROST_LIBRARIES})

include_directories(src)

target_link_libraries(BlastFrost Threads::Threads ${ZLIB_LIBRARIES} ${BIFROST_LIBRARIES})
