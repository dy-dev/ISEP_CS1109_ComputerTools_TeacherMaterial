cmake_minimum_required(VERSION 3.20)
project(Runner LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(FetchContent)
FetchContent_Declare(
    raylib
    GIT_REPOSITORY https://github.com/raysan5/raylib.git
    GIT_TAG        5.5
)
FetchContent_MakeAvailable(raylib)

add_executable(runner
    src/main.cpp
    src/Board.cpp
    src/Player.cpp
)

target_include_directories(runner PRIVATE include)
target_link_libraries(runner PRIVATE raylib)
