// src/Board.cpp

#include "Board.h"

#include <string>

#include "raylib.h"

const int   SCREEN_WIDTH  = 1024;
const int   SCREEN_HEIGHT = 576;
const int   PLAYER_SIZE   = 40;
const float PLAYER_X      = 120.0f;
const float GROUND_LINE   = 500.0f;
const float GROUND_Y      = GROUND_LINE - PLAYER_SIZE;
const float TOP_Y         = GROUND_Y - 120.0f;
const float SPEED         = 300.0f;
const float GRAVITY       = 1500.0f;
const float JUMP_SPEED    = -600.0f;   // apex = JUMP_SPEED^2 / (2*GRAVITY) = 120 px = TOP_Y
const int   LIVES_INIT    = 3;

void drawBoard(int score, int lives) {
    DrawRectangle(0, static_cast<int>(GROUND_LINE),
                  SCREEN_WIDTH, SCREEN_HEIGHT - static_cast<int>(GROUND_LINE), DARKGREEN);

    std::string scoreText = "Score: " + std::to_string(score);
    std::string livesText = "Lives: " + std::to_string(lives);
    DrawText(scoreText.c_str(), 10, 10, 20, BLACK);
    DrawText(livesText.c_str(), SCREEN_WIDTH - 110, 10, 20, BLACK);
}
