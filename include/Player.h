// include/Player.h
//
// Player: the player logic.
//   - handleInput: reacts to a key (jump, quit)
//   - checkCollision: tests whether the player hits an obstacle
//
// Player needs the Position struct defined in Board.h, so it includes Board.h
// here. Board.h's include guards prevent any double inclusion.

#ifndef PLAYER_H
#define PLAYER_H

#include <vector>

#include "Board.h"  // for Position

// Applies the command to the player. Returns true if the player wants to quit.
bool handleInput(char command, Position& player);

// Returns true if the player occupies the same cell as an obstacle.
bool checkCollision(const Position& player,
                    const std::vector<Position>& obstacles);

#endif  // PLAYER_H
