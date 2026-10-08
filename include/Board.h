// include/Board.h
//
// Board: the "world" of the Runner.
//   - the Position struct (shared across the whole project)
//   - the world constants (screen size in pixels, reference positions)
//   - the scene display (displayState), now drawn with Raylib

#ifndef BOARD_H
#define BOARD_H

#include <vector>

// Coordinates in pixels. Floats: the world is continuous now.
struct Position {
    float x;
    float y;
};

// Screen and world constants. Declared here, defined in Board.cpp.
extern const int   SCREEN_WIDTH;    // window width in pixels
extern const int   SCREEN_HEIGHT;   // window height in pixels
extern const int   PLAYER_SIZE;     // player square side in pixels
extern const float PLAYER_X;        // fixed player column (pixels)
extern const float GROUND_Y;        // ground line (top of the player when on the ground)
extern const float TOP_Y;           // high obstacle row (top of a square placed up there)
extern const float SPEED;           // obstacle scrolling speed, pixels per second
extern const float GRAVITY;         // downward acceleration, pixels per second squared
extern const float JUMP_SPEED;      // vertical impulse on jump (negative: y grows downwards)
extern const int   LIVES_INIT;      // lives at startup

// Draws the ground, the player, the obstacles, the score and the lives.
void displayState(const Position& player,
                  const std::vector<Position>& obstacles,
                  int score,
                  int lives);

#endif  // BOARD_H
