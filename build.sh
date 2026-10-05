#!/bin/bash
# CS.1109 Runner — one-command build.
# Usage: ./build.sh          (Release by default)
#        ./build.sh Debug
set -e

BUILD_TYPE="${1:-Release}"

cmake -B build -S . -DCMAKE_BUILD_TYPE="$BUILD_TYPE"
cmake --build build --parallel

echo
echo "Build OK ($BUILD_TYPE)."
echo "  Run the game : ./build/runner"
echo "  Run the tests: ./build/runner_tests"
