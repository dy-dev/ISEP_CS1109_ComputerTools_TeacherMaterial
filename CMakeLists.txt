cmake_minimum_required(VERSION 3.20)
project(Runner)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(runner
    src/main.cpp
    src/Board.cpp
    src/Player.cpp
)

target_include_directories(runner PRIVATE include)
