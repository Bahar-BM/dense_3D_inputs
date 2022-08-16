cmake_minimum_required(VERSION 3.18)

set(PROJECT_NAME model_test)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_SOURCE_DIR}/cmake)

project(${PROJECT_NAME})
add_executable(${PROJECT_NAME} main.cpp)

find_package(TensorFlowLite REQUIRED)

if(ANDROID)
	target_link_libraries(${PROJECT_NAME} PUBLIC ${TensorFlowLite_LIBRARIES} ${ABSL_LIBS} ${RUY_LIBS} ${FFT2D_LIBS} log)
else()
	target_link_libraries(${PROJECT_NAME} PUBLIC "-Wl,--start-group" ${TensorFlowLite_LIBRARIES} ${ABSL_LIBS} ${RUY_LIBS} ${FFT2D_LIBS} "-Wl,--end-group" dl pthread)
endif()
	
target_include_directories(${PROJECT_NAME} PUBLIC ${TensorFlowLite_INCLUDE_DIR})

