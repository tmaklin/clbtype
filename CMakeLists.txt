cmake_minimum_required(VERSION 3.11)
project(clbtype)
include(FetchContent)

set(LIBRARY_OUTPUT_PATH ${CMAKE_CURRENT_SOURCE_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/bin)

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

## bifrost
FetchContent_Declare(bifrost-compile
  SOURCE_DIR        "${CMAKE_CURRENT_SOURCE_DIR}/vendor/bifrost-v1.0.6.4"
  BUILD_IN_SOURCE   0
  CMAKE_ARGS      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
                  -D CMAKE_C_FLAGS=${CMAKE_C_FLAGS}
		  -D CMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
		  -D CMAKE_C_COMPILER=${CMAKE_C_COMPILER}
		  -D CMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
		  -D COMPILATION_ARCH=${CMAKE_WITH_NATIVE_INSTRUCTIONS}
  INSTALL_COMMAND   ""
  )
FetchContent_MakeAvailable(bifrost-compile)
set_target_properties(bifrost_dynamic PROPERTIES EXCLUDE_FROM_ALL 1)
set(CMAKE_BIFROST_HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/vendor/bifrost-v1.0.6.4/src)
set(CMAKE_BIFROST_LIBRARIES ${CMAKE_CURRENT_SOURCE_DIR}/lib/libbifrost.a)

## BlastFrost
FetchContent_Declare(blastfrost-compile
  SOURCE_DIR        "${CMAKE_CURRENT_SOURCE_DIR}/vendor/BlastFrost-v1.0.0"
  BUILD_IN_SOURCE   0
  CMAKE_ARGS      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
                  -D CMAKE_C_FLAGS=${CMAKE_C_FLAGS}
		  -D CMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
		  -D CMAKE_C_COMPILER=${CMAKE_C_COMPILER}
		  -D CMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
		  -D CMAKE_WITH_NATIVE_INSTRUCTIONS=${CMAKE_WITH_NATIVE_INSTRUCTIONS}
		  -D CMAKE_WITH_FLTO=${CMAKE_WITH_FLTO}
		  -D CMAKE_PGO_GENERATE=${CMAKE_PGO_GENERATE}
		  -D CMAKE_PGO_USE=${CMAKE_PGO_USE}
		  -D CMAKE_BIFROST_LIBRARIES=${CMAKE_BIFROST_LIBRARIES}
		  -D CMAKE_BIFROST_HEADERS=${CMAKE_BIFROST_HEADERS}
  INSTALL_COMMAND   ""
  )
FetchContent_MakeAvailable(blastfrost-compile)
add_dependencies(BlastFrost bifrost_static)
