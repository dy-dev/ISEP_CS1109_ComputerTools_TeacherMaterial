# Dockerfile — CS.1109 Runner
#
# Multi-stage build:
#   stage 1 "build"   : Ubuntu + compiler + CMake + Raylib deps, builds the
#                       project and runs the tests.
#   stage 2 "runtime" : a much lighter image that only carries the test
#                       binary. No compiler, no sources.
#
# The game itself (runner) needs a display, which a container does not have.
# What runs in the container is runner_tests: the whole game logic, headless.

# ---------- stage 1 : build ----------
FROM ubuntu:24.04 AS build

# Tools and the system libraries Raylib needs to compile (X11, OpenGL).
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential cmake git ca-certificates \
        libgl1-mesa-dev libx11-dev libxrandr-dev libxinerama-dev \
        libxcursor-dev libxi-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the whole project, then build. Simple, and correct.
# (Every source edit invalidates this layer, so Raylib and Catch2 are
#  downloaded again on each build. Making the dependency download a separate,
#  cached layer is the bonus exercise of the lab.)
COPY CMakeLists.txt ./
COPY include/ include/
COPY src/ src/
COPY tests/ tests/

RUN cmake -B build -S . -DCMAKE_BUILD_TYPE=Release \
    && cmake --build build --parallel

# The tests run at build time: an image with failing tests cannot be built.
RUN ./build/runner_tests

# ---------- stage 2 : runtime ----------
FROM ubuntu:24.04 AS runtime

# runner_tests only needs the C/C++ runtime already present in the base
# image (check with `ldd`): Raylib is linked statically and the tests never
# open a window. No X11, no OpenGL, no compiler: that is the point of the
# second stage.

WORKDIR /app
COPY --from=build /app/build/runner_tests ./runner_tests

CMD ["./runner_tests"]
