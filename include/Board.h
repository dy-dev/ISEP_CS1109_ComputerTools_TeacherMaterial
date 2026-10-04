// include/Board.h
//
// Board: the "world" of the console Runner.
//   - the Position struct (shared across the whole project)
//   - the world constants (dimensions, reference positions)
//   - the scene display (displayState)
//
// Teacher reference for the S3 split. Board does not know about the player:
// it receives everything it must display as parameters.

#ifndef BOARD_H
#define BOARD_H

#include <vector>

// Coordinates of a grid cell. Public by default (struct).
struct Position {
    int x;
    int y;
};

// World constants. Declared here, defined in Board.cpp.
extern const int HEIGHT;      // grid height
extern const int WIDTH;       // grid width
extern const int PLAYER_X;    // fixed player column
extern const int GROUND_Y;    // ground line
extern const int TOP_Y;       // top line (jump position)
extern const int LIVES_INIT;  // lives at startup

// Displays the grid, the player, the obstacles, the score and the lives.
void displayState(const Position& player,
                  const std::vector<Position>& obstacles,
                  int score,
                  int lives);

#endif  // BOARD_H
