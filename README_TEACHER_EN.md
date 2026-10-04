# Teacher reference — S3 split (console Runner)

Reference version of the S2 `runner.cpp` split following the
declaration/definition pattern, as expected at the end of Phase B of the S3
lab. **Teacher use only**: keep it at hand to unblock a group during the
session, do not distribute it to students.

## Layout

```
CS1109_Runner_S4_Start/   (link 03_S4_Start_equals_S3_Solution = S3 solution)
├── CMakeLists.txt          add_executable + target_include_directories
├── include/
│   ├── Board.h             Position struct, world constants, displayState
│   └── Player.h            handleInput, checkCollision (includes Board.h)
└── src/
    ├── Board.cpp           definition of the constants + displayState
    ├── Player.cpp          definition of handleInput + checkCollision
    └── main.cpp            orchestration (game loop), includes both .h
```

## Mapping with the lab

- **B5 (Member 1)** -> `include/Board.h` + `src/Board.cpp`: the `Position`
  struct, the world constants, the `displayState` function.
- **B6 (Member 2)** -> `include/Player.h` + `src/Player.cpp`: `handleInput`
  and `checkCollision`. `Player.h` includes `Board.h` to know `Position`.
- **B7 (Member 3)** -> `src/main.cpp`: the `main()` extracted from runner.cpp,
  unchanged except for the two `#include "Board.h"` / `#include "Player.h"`
  added at the top, and the original `runner.cpp` deleted.

## Build and run

```
cmake -B build
cmake --build build
./build/runner
```

Compiles without warnings under `-Wall -Wextra`.

## Common issues during the session

- **Constants**: `Board.h` declares them with `extern const`, `Board.cpp`
  defines them. A group that puts the value (`const int WIDTH = 40;`) directly
  in the `.h` will get a multiple-definition error as soon as two `.cpp` files
  include `Board.h`. That is the classic trap - a chance to explain the
  declaration/definition difference on a piece of data.
- **Including Board from Player**: if a group forgets `#include "Board.h"` in
  `Player.h`, the compiler does not know `Position` -> error. Board.h's include
  guards make multiple inclusion safe.
- **CMakeLists**: the three sources must be listed in `add_executable`, and
  `target_include_directories(runner PRIVATE include)` is required so that
  `#include "Board.h"` is found.
- **Cross-platform clear**: `main.cpp` uses `#ifdef _WIN32` to pick `cls` on
  Windows and `clear` elsewhere. A hardcoded `system("cls")` breaks on the
  Mac/Linux terminals the lab allows.

## The console jump

The jump lasts a single turn: the local flag `airborneLastTurn` in `main` is
set when the player leaves the ground and, on the next turn, brings the player
back down to `GROUND_Y`. It is a local, not a global, and it is initialised to
`false` (reading an uninitialised bool is undefined behaviour).

In session 4 this turn-based jump is replaced by a real one: a vertical speed
and a constant gravity (`GRAVITY`, `JUMP_SPEED`). The flag disappears with it —
being airborne is read off the position, `player.y >= GROUND_Y` meaning landed.
