// src/Board.cpp
//
// Definition of what is declared in Board.h. Only this file talks to Raylib
// for drawing: Player keeps the logic, Board keeps the rendering.

#include "Board.h"

#include <string>

#include "raylib.h"

const int   SCREEN_WIDTH  = 1024;
const int   SCREEN_HEIGHT = 576;
const int   PLAYER_SIZE   = 40;
const float PLAYER_X      = 120.0f;
const float GROUND_Y      = 500.0f - PLAYER_SIZE;   // ground line at y=500
const float TOP_Y         = GROUND_Y - 120.0f;
const float SPEED         = 300.0f;
const float GRAVITY       = 1500.0f;
const float JUMP_SPEED    = -600.0f;   // apex = JUMP_SPEED^2 / (2*GRAVITY) = 120 px = TOP_Y
const int   LIVES_INIT    = 3;

void displayState(const Position& player,
                  const std::vector<Position>& obstacles,
                  int score,
                  int lives) {
    // Ground
    DrawRectangle(0, 500, SCREEN_WIDTH, SCREEN_HEIGHT - 500, DARKGREEN);

    // Obstacles
    for (const Position& obs : obstacles) {
        DrawRectangle(static_cast<int>(obs.x), static_cast<int>(obs.y),
                      PLAYER_SIZE, PLAYER_SIZE, DARKGRAY);
    }

    // Player
    DrawRectangle(static_cast<int>(player.x), static_cast<int>(player.y),
                  PLAYER_SIZE, PLAYER_SIZE, RED);

    // HUD
    std::string scoreText = "Score: " + std::to_string(score);
    std::string livesText = "Lives: " + std::to_string(lives);
    DrawText(scoreText.c_str(), 10, 10, 20, BLACK);
    DrawText(livesText.c_str(), SCREEN_WIDTH - 110, 10, 20, BLACK);
}
