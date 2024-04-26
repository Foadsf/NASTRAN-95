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

# set(CMAKE_Fortran_MODULE_DIRECTORY ${PROJECT_BINARY_DIR}/obj)

# Create necessary directories
# file(MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/lib)
# file(MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/obj)
file(MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/bin)


# Collect all source files from the necessary directories
file(GLOB BD_SOURCES "bd/*.f")
file(GLOB MIS_SOURCES "mis/*.f")
file(GLOB MDS_SOURCES "mds/*.f")

# Define libraries
add_library(nasmis STATIC ${MIS_SOURCES})
add_library(nasmds STATIC ${MDS_SOURCES})
list(REMOVE_ITEM nasmds "mds/chkfil.f")
add_library(nasbd STATIC ${BD_SOURCES})

# Combine static libraries into a single library
add_library(nas STATIC $<TARGET_OBJECTS:nasmis>
                      $<TARGET_OBJECTS:nasmds>
                      $<TARGET_OBJECTS:nasbd>)

# Create the nastran executable
add_executable(nastran "bin/nastrn.f" ${BD_SOURCES})
target_link_libraries(nastran nas -static)

# Set output directory for the executable
set_target_properties(nastran PROPERTIES
  RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin
)

add_executable(nasthelp "um/nasthelp.f")

# Add custom commands for NASINFO and documentation files
add_custom_command(OUTPUT NASINFO
                   COMMAND ${CMAKE_COMMAND} -E create_symlink rf/NASINFO NASINFO
                   COMMENT "Creating symlink for NASINFO")

file(GLOB DOCTXT um/*.TXT)
foreach(FILE ${DOCTXT})
    get_filename_component(FILENAME ${FILE} NAME)
    add_custom_command(OUTPUT bin/${FILENAME}
                       COMMAND ${CMAKE_COMMAND} -E create_symlink ${FILE} bin/${FILENAME}
                       COMMENT "Creating symlink for ${FILENAME}")
endforeach()

# Set output directory for the executable
set_target_properties(nasthelp PROPERTIES
  RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin
)


add_executable(nastplot "utility/nastplot.f")
set_target_properties(nastplot PROPERTIES
  RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin
)

add_executable(ff "utility/ff.f")
target_link_libraries(ff nas)
set_target_properties(ff PROPERTIES
  RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin
)


add_executable(chkfil "mds/chkfil.f")
set_target_properties(chkfil PROPERTIES
  RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin
)




