# SystemC dependencies
set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)

# Find SystemC using SystemC's CMake integration
set(CMAKE_PREFIX_PATH "/usr/local/share/systemc-2.3.4")
find_package(SystemCLanguage QUIET)

file(GLOB SC_SIM_SRC
     "*.h"
     "*.cpp")

add_executable(pfc-sim ${SC_SIM_SRC})

set_property(
  TARGET pfc-sim
  PROPERTY CXX_STANDARD ${SystemC_CXX_STANDARD})

target_link_bsim_systemc(pfc-sim
  mkPostfixCalculator32x32
  ${PROJECT_SOURCE_DIR}/cores/PostfixCalculator32x32/PostfixCalculator32x32.bsv

  LINK_LIBS
  Stack PostfixCalculator)
