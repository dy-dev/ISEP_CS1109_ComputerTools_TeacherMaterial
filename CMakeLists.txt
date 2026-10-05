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
FetchContent_Declare(
    Catch2
    GIT_REPOSITORY https://github.com/catchorg/Catch2.git
    GIT_TAG        v3.7.1
)
FetchContent_MakeAvailable(raylib Catch2)

# --- game logic, shared by the game and the tests (no main inside) ---
add_library(runner_core STATIC
    src/Board.cpp
    src/GameObject.cpp
    src/Player.cpp
    src/Obstacle.cpp
)
target_include_directories(runner_core PUBLIC include)
target_link_libraries(runner_core PUBLIC raylib)

# --- the game ---
add_executable(runner src/main.cpp)
target_link_libraries(runner PRIVATE runner_core)

# --- the tests ---
add_executable(runner_tests
    tests/test_obstacle.cpp
    tests/test_player.cpp
    tests/test_gameobject.cpp
)
target_link_libraries(runner_tests PRIVATE runner_core Catch2::Catch2WithMain)

enable_testing()
add_test(NAME runner_tests COMMAND runner_tests)
