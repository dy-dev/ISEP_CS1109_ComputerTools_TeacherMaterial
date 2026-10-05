// include/Player.h
//
// Player: the player logic.
//   - handleInput: reads the keyboard through Raylib (jump)
//   - checkCollision: tests whether the player overlaps an obstacle

#ifndef PLAYER_H
#define PLAYER_H

#include <vector>

#include "Board.h"  // for Position and the constants

// Reads the keyboard. Starts a jump on Space when on the ground, by giving
// the player an upward vertical speed.
// Returns true if the player asks to quit (Escape).
bool handleInput(Position& player, float& velocityY);

// Applies gravity to the vertical speed, moves the player, and puts it back
// on the ground when it lands.
void updateJump(Position& player, float& velocityY, float dt);

// Returns true if the player square overlaps an obstacle square.
bool checkCollision(const Position& player,
                    const std::vector<Position>& obstacles);

#endif  // PLAYER_H
