project(set10108-cw02 LANGUAGES CXX CUDA)
cmake_minimum_required(VERSION 3.17)
set(CMAKE_CXX_STANDARD 17)

#### OPEN MP PACKAGES ####
find_package(OpenMP)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")

add_executable(serialNQueens nqueensSerialOriginal.cpp)
add_executable(serialNQueensNonRec nqueensSerialNonRecursive.cpp)
add_executable(openMPNqueens nqueens-openmp.cpp)

add_executable(CUDANqueens nqueens-cuda.cu)
set_property(TARGET CUDANqueens PROPERTY CUDA_SEPARABLE_COMPILATION ON)