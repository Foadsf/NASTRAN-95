cmake_minimum_required(VERSION 3.10)
project(Nastran95_Project Fortran)

# Allow the user to specify the Fortran compiler from the command line
if(NOT CMAKE_Fortran_COMPILER)
  set(CMAKE_Fortran_COMPILER gfortran)
endif()

# Set the Fortran compilation flags depending on the compiler
if (CMAKE_Fortran_COMPILER_ID MATCHES "GNU")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -g -w -fno-range-check -fno-automatic -fcray-pointer -std=legacy")
elseif (CMAKE_Fortran_COMPILER_ID MATCHES "Intel")
  # set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} /stand:f77 /Qsafe-cray-ptr /save /check:nobounds /debug:full /Qdiag-disable:10448 /Qdiag-disable:warn")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} /integer-size=64 /Qdiag-disable:10448 /Qdiag-disable:warn")
endif()


# Specify the binary directory and the directories containing additional source files
set(BINARY_DIR "${CMAKE_SOURCE_DIR}/bin")
set(BD_DIR "${CMAKE_SOURCE_DIR}/bd")
set(MIS_DIR "${CMAKE_SOURCE_DIR}/mis")
set(MDS_DIR "${CMAKE_SOURCE_DIR}/mds")

# Include directories for header files or modules
include_directories(${BINARY_DIR})
include_directories(${BD_DIR})
include_directories(${MIS_DIR})
include_directories(${MDS_DIR})

# Collect all source files from the necessary directories
file(GLOB BIN_SOURCES "${BINARY_DIR}/*.f")
file(GLOB BD_SOURCES "${BD_DIR}/*.f")
file(GLOB MIS_SOURCES "${MIS_DIR}/*.f")
file(GLOB MDS_SOURCES "${MDS_DIR}/*.f")

# Specify the target executable and the source files it depends on
add_executable(nastran ${BIN_SOURCES} ${BD_SOURCES} ${MIS_SOURCES} ${MDS_SOURCES})

# Specify the output directory for the executable
set_target_properties(nastran PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${BINARY_DIR}
)

