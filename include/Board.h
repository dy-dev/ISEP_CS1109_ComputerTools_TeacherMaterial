// include/Board.h
//
// Board: the world constants and the ground rendering. The objects of the
// game (player, obstacles) now draw themselves: Board only keeps what is
// shared by everyone.

#ifndef BOARD_H
#define BOARD_H

extern const int SCREEN_WIDTH;   // window width in pixels
extern const int SCREEN_HEIGHT;  // window height in pixels
extern const int PLAYER_SIZE;    // side of every square in pixels
extern const float PLAYER_X;     // fixed player column (pixels)
extern const float GROUND_LINE;  // y of the ground line
extern const float GROUND_Y;     // top of a square resting on the ground
extern const float TOP_Y;        // high obstacle row (top of a square placed up there)
extern const float SPEED;        // obstacle scrolling speed, pixels per second
extern const float GRAVITY;      // downward acceleration, pixels per second squared
extern const float JUMP_SPEED;   // vertical impulse on jump (negative: y grows downwards)
extern const int LIVES_INIT;     // lives at startup

// Draws the ground band and the HUD (score, lives).
void drawBoard(int score, int lives);

#endif  // BOARD_H
