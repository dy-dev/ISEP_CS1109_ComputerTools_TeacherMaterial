// src/main.cpp
//
// Runner orchestrator, Raylib version. The loop runs 60 times per second and
// reads the keyboard on every frame: the world is continuous now.

#include <algorithm>
#include <vector>

#include "raylib.h"

#include "Board.h"
#include "Player.h"

int main() {
    InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Runner CS.1109");
    SetTargetFPS(60);

    Position player = { PLAYER_X, GROUND_Y };
    std::vector<Position> obstacles;
    int   score = 0;
    float scoreTime = 0.0f;   // seconds elapsed, feeds the score
    int lives = LIVES_INIT;
    float velocityY = 0.0f;
    float spawnTimer = 0.0f;
    float hitCooldown = 0.0f;   // avoids losing several lives on one obstacle

    const float SPAWN_INTERVAL = 1.5f;

    while (!WindowShouldClose() && lives > 0) {
        float dt = GetFrameTime();

        if (handleInput(player, velocityY)) {
            break;
        }
        updateJump(player, velocityY, dt);

        // Scroll the obstacles to the left
        for (Position& obs : obstacles) {
            obs.x -= SPEED * dt;
        }

        // Remove obstacles that left the screen
        obstacles.erase(
            std::remove_if(obstacles.begin(), obstacles.end(),
                           [](const Position& p) { return p.x + PLAYER_SIZE < 0.0f; }),
            obstacles.end());

        // Spawn an obstacle at a regular interval
        spawnTimer += dt;
        if (spawnTimer >= SPAWN_INTERVAL) {
            spawnTimer = 0.0f;
            float y = (GetRandomValue(0, 1) == 0) ? GROUND_Y : TOP_Y;
            obstacles.push_back({ static_cast<float>(SCREEN_WIDTH), y });
        }

        // Collision, with a short cooldown so one obstacle costs one life
        if (hitCooldown > 0.0f) {
            hitCooldown -= dt;
        } else if (checkCollision(player, obstacles)) {
            lives -= 1;
            hitCooldown = 0.5f;
        }

        // Score tied to time, not to the number of frames: the elapsed seconds
        // are accumulated as a float, the displayed score derives from them.
        // (score += 10 * dt would truncate to 0 every frame on an int.)
        scoreTime += dt;
        score = static_cast<int>(scoreTime * 10.0f);   // ~10 points per second

        BeginDrawing();
        ClearBackground(RAYWHITE);
        displayState(player, obstacles, score, lives);
        if (lives <= 0) {
            DrawText("GAME OVER", SCREEN_WIDTH / 2 - 100, SCREEN_HEIGHT / 2 - 20, 40, RED);
        }
        EndDrawing();
    }

    CloseWindow();
    return 0;
}
