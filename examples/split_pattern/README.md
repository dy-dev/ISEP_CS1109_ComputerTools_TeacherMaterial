# examples/split_pattern - The .h / .cpp pattern in practice

This folder contains an isolated example of the declaration/definition
pattern in C++. Read it before starting Phase B of the lab.

## What the folder contains

- `Score.h`: declaration of a `Score` class (method names, signatures,
  members). This is what another file includes to know "what can be done with
  Score", without knowing the implementation.
- `Score.cpp`: definition of the methods declared in the header. This is the
  actual code that gets compiled.

## Why this pattern

A C++ project grows fast. If everything sits in a single `runner.cpp`, the
compiler has to recompile everything as soon as one line changes, and several
people cannot work in parallel without conflicts.

By splitting each unit into two files:

- Other files include only the `.h` (lightweight, rarely changes): compile
  time stays under control.
- The `.cpp` can be modified without forcing the recompilation of the files
  that use the class.
- Include guards (`#ifndef SCORE_H` / `#define SCORE_H` / `#endif`) prevent
  the header content from being included twice in the same file, which would
  cause multiple-definition errors.

## How to use it

This folder is not meant to be integrated into the runner. It is provided as
a model. For Phase B of the lab, each of you will apply the same pattern to
the contents of `runner.cpp`:

- The `Position` struct and the `displayState` function become
  `include/Board.h` + `src/Board.cpp`.
- The `handleInput` and `checkCollision` functions become
  `include/Player.h` + `src/Player.cpp`.

The pattern stays the same, only the content changes: declarations in the
`.h`, definitions in the `.cpp`, include guards at the top of every header.
