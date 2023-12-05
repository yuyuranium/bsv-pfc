cmake_minimum_required(VERSION 3.22)

project(pfc
  VERSION 0.0
  DESCRIPTION "Postfix Calculator"
  LANGUAGES CXX)

set(CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake/" ${CMAKE_MODULE_PATH})

include(BluespecTargets)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")

add_subdirectory(lib)
add_subdirectory(cores)
add_subdirectory(sim)
add_subdirectory(test)
