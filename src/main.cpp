// src/main.cpp
//
// Runner orchestrator: only the game loop remains here. All the logic lives in
// Board (display, world) and Player (input, collision). We include their .h to
// find the functions that were moved out.

#include <algorithm>
#include <cstdlib>
#include <ctime>
#include <iostream>
#include <string>
#include <vector>

#include "Board.h"
#include "Player.h"

#ifdef _WIN32
    #define CLEAR_SCREEN "cls"
#else
    #define CLEAR_SCREEN "clear"
#endif

bool isInAir = false;

int main() {
    std::srand(static_cast<unsigned>(std::time(nullptr)));

    std::cout << "Runner CS.1109\n";
    std::cout << "Controls: 's' to jump, Enter to move forward, 'q' to quit\n";

    Position player = { PLAYER_X, GROUND_Y };
    std::vector<Position> obstacles;
    int score = 0;
    int lives = LIVES_INIT;

    while (lives > 0) {
        displayState(player, obstacles, score, lives);
        std::cout << "> ";

        std::string line;
        if (!std::getline(std::cin, line)) {
            break;
        }

        char command = line.empty() ? '\0' : line[0];
        if (handleInput(command, player)) {
            break;
        }

        for (Position& obs : obstacles) {
            obs.x -= 1;
        }

        obstacles.erase(
            std::remove_if(obstacles.begin(), obstacles.end(),
                           [](const Position& p) { return p.x < 0; }),
            obstacles.end());

        if (std::rand() % 3 == 0) {
            int y = (std::rand() % 2 == 0) ? GROUND_Y : TOP_Y;
            obstacles.push_back({ WIDTH - 1, y });
        }

        if (checkCollision(player, obstacles)) {
            lives -= 1;
            std::cout << "\n>> COLLISION! Lives left: " << lives << "\n";
        }

        if (isInAir) {
            player.y = GROUND_Y;
            isInAir = false;
        }

        if (player.y != GROUND_Y) {
            isInAir = true;
        }

        std::system(CLEAR_SCREEN);
        score += 1;
    }

    std::cout << "\n=== GAME OVER === Final score: " << score << "\n";
    return 0;
}
