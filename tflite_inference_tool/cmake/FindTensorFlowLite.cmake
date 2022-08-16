# When setting cmake_minimum_required to 3.12+, one can set TensorflowLite_ROOT variable
# at configure time, and find_library will automatically look inside 
# ${TensorflowLite_ROOT}/lib/${CMAKE_LIBRARY_ARCHITECTURE}, where
# ${CMAKE_LIBRARY_ARCHITECTURE} is x86_64-linux-gnu for Linux,
# and aarch64-linux-android when cross compiling from Linux to Android

# Explanation of NO_CMAKE_FIND_ROOT_PATH: when cross compiling for android, 
# the CMAKE_FIND_ROOT_PATH variable is set to the root folder of the NDK by
# android.toolchain.cmake, without NO_CMAKE_FIND_ROOT_PATH here, find_path 
# and find_library will append ${CMAKE_FIND_ROOT_PATH} to every folder 
# it searches.

find_path(TensorFlowLite_INCLUDE_DIR
    NAMES
        tensorflow/lite/interpreter.h
    NO_CMAKE_FIND_ROOT_PATH
    REQUIRED
)

find_library(TensorFlowLite_LIBRARY 
    NAMES            
        tensorflow-lite
    NO_CMAKE_FIND_ROOT_PATH
    REQUIRED
)

get_filename_component(TFLite_Lib_DIR ${TensorFlowLite_LIBRARY} DIRECTORY)

file(GLOB ABSL_LIBS ${TFLite_Lib_DIR}/libabsl*.a)
file(GLOB RUY_LIBS ${TFLite_Lib_DIR}/libruy*.a)
file(GLOB FFT2D_LIBS ${TFLite_Lib_DIR}/libfft2d*.a)

set(TensorFlowLite_LIBRARIES
    ${TensorFlowLite_LIBRARY}
    ${TFLite_Lib_DIR}/libpthreadpool.a
    ${TFLite_Lib_DIR}/libclog.a
    ${TFLite_Lib_DIR}/libfarmhash.a
    ${TFLite_Lib_DIR}/libcpuinfo.a
    ${TFLite_Lib_DIR}/libflatbuffers.a
    ${TFLite_Lib_DIR}/libXNNPACK.a
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
    TensorFlowLite
    FOUND_VAR TensorFlowLite_FOUND
    REQUIRED_VARS TensorFlowLite_LIBRARIES TensorFlowLite_INCLUDE_DIR
)
