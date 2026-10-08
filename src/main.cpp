// src/main.cpp
//
// Runner orchestrator, object-oriented version. main no longer knows how a
// player jumps or how an obstacle moves: it owns the objects, calls update
// and draw on each of them through the GameObject interface, and handles
// the rules of the game (spawn, collisions, lives).

#include <algorithm>
#include <memory>
#include <vector>

#include "Board.h"
#include "GameObject.h"
#include "Obstacle.h"
#include "Player.h"
#include "raylib.h"

int main() {
    InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Runner CS.1109");
    SetTargetFPS(60);

    Player player(PLAYER_X, GROUND_Y, PLAYER_SIZE);

    // Obstacles held through the base class: main only sees GameObjects.
    // update() and draw() below resolve to Obstacle's versions at runtime —
    // that is the polymorphism.
    std::vector<std::unique_ptr<GameObject>> obstacles;

    int   score = 0;
    float scoreTime = 0.0f;   // seconds elapsed, feeds the score
    int lives = LIVES_INIT;
    float spawnTimer = 0.0f;
    float hitCooldown = 0.0f;
    const float SPAWN_INTERVAL = 1.5f;

    while (!WindowShouldClose() && lives > 0) {
        float dt = GetFrameTime();

        // --- input ---
        player.handleInput();

        // --- update: every object advances through the same interface ---
        player.update(dt);
        for (std::unique_ptr<GameObject>& obj : obstacles) {
            obj->update(dt);  // virtual call: Obstacle::update
        }

        // Remove the obstacles that left the screen (entirely past the left edge)
        obstacles.erase(std::remove_if(obstacles.begin(), obstacles.end(),
                                       [](const std::unique_ptr<GameObject>& o) {
                                           return o->getX() + PLAYER_SIZE < 0.0f;
                                       }),
                        obstacles.end());

        spawnTimer += dt;
        if (spawnTimer >= SPAWN_INTERVAL) {
            spawnTimer = 0.0f;
            float y = (GetRandomValue(0, 1) == 0) ? GROUND_Y : TOP_Y;
            obstacles.push_back(
                std::make_unique<Obstacle>(static_cast<float>(SCREEN_WIDTH), y, PLAYER_SIZE));
        }

        // --- rules: collisions with a short cooldown ---
        if (hitCooldown > 0.0f) {
            hitCooldown -= dt;
        } else {
            for (const std::unique_ptr<GameObject>& obj : obstacles) {
                if (CheckCollisionRecs(player.getBounds(), obj->getBounds())) {
                    lives -= 1;
                    hitCooldown = 0.5f;
                    break;
                }
            }
        }

        // Score tied to time, not to the number of frames.
        scoreTime += dt;
        score = static_cast<int>(scoreTime * 10.0f);   // ~10 points per second

        // --- draw: every object draws itself ---
        BeginDrawing();
        ClearBackground(RAYWHITE);
        drawBoard(score, lives);
        for (const std::unique_ptr<GameObject>& obj : obstacles) {
            obj->draw();  // virtual call: Obstacle::draw
        }
        player.draw();
        if (lives <= 0) {
            DrawText("GAME OVER", SCREEN_WIDTH / 2 - 100, SCREEN_HEIGHT / 2 - 20, 40, RED);
        }
        EndDrawing();
    }

    CloseWindow();
    return 0;
}
