// src/Player.cpp
//
// Definition of what is declared in Player.h.

#include "Player.h"

#include "raylib.h"

bool handleInput(Position& player, float& velocityY) {
    if (IsKeyPressed(KEY_ESCAPE)) {
        return true;
    }
    // On the ground: y never goes below GROUND_Y, so >= means "landed".
    if (IsKeyPressed(KEY_SPACE) && player.y >= GROUND_Y) {
        velocityY = JUMP_SPEED;
    }
    return false;
}

void updateJump(Position& player, float& velocityY, float dt) {
    velocityY += GRAVITY * dt;      // gravity pulls the vertical speed down
    player.y += velocityY * dt;     // the speed moves the player

    if (player.y >= GROUND_Y) {     // landed: snap back, never compare floats with ==
        player.y = GROUND_Y;
        velocityY = 0.0f;
    }
}

bool checkCollision(const Position& player,
                    const std::vector<Position>& obstacles) {
    for (const Position& obs : obstacles) {
        bool overlapX = player.x < obs.x + PLAYER_SIZE && obs.x < player.x + PLAYER_SIZE;
        bool overlapY = player.y < obs.y + PLAYER_SIZE && obs.y < player.y + PLAYER_SIZE;
        if (overlapX && overlapY) {
            return true;
        }
    }
    return false;
}
