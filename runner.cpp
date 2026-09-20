// runner.cpp - Runner CS.1109 (reference console version)
//
// Shared base provided for session S3: the identical starting point for every
// group. The contents of this file will be split during the lab into
// Board.h/Board.cpp (grid, display, world) and Player.h/Player.cpp (input,
// collision), driven by a src/main.cpp reduced to orchestration.

#include <algorithm>
#include <cstdlib>
#include <ctime>
#include <iostream>
#include <string>
#include <vector>

// -----------------------------------------------------------------------------
// Cross-platform screen clear
// -----------------------------------------------------------------------------

#ifdef _WIN32
    #define CLEAR_SCREEN "cls"
#else
    #define CLEAR_SCREEN "clear"
#endif

// -----------------------------------------------------------------------------
// Shared types
// -----------------------------------------------------------------------------

struct Position {
    int x;
    int y;
};

// -----------------------------------------------------------------------------
// World constants
// -----------------------------------------------------------------------------

const int HEIGHT     = 7;
const int WIDTH      = 40;
const int PLAYER_X   = 5;
const int GROUND_Y   = HEIGHT - 2;
const int TOP_Y      = 1;
const int LIVES_INIT = 3;

// -----------------------------------------------------------------------------
// Scene display (goes to Board after the split)
// -----------------------------------------------------------------------------

void displayState(const Position& player,
                  const std::vector<Position>& obstacles,
                  int score,
                  int lives) {
    std::vector<std::string> grid(HEIGHT, std::string(WIDTH, ' '));

    for (const Position& obs : obstacles) {
        if (obs.x >= 0 && obs.x < WIDTH) {
            grid[obs.y][obs.x] = '#';
        }
    }
    grid[player.y][player.x] = '@';

    std::cout << "\n+" << std::string(WIDTH, '-') << "+\n";
    for (std::size_t i = 0; i < grid.size(); ++i) {
        std::cout << "|" << grid[i] << "|\n";
    }
    std::cout << "+" << std::string(WIDTH, '-') << "+\n";
    std::cout << "Score: " << score << "   Lives: " << lives << "\n";
}

// -----------------------------------------------------------------------------
// Player logic (goes to Player after the split)
// -----------------------------------------------------------------------------

// Returns true if the player asks to quit the game.
bool handleInput(char command, Position& player) {
    if (command == 'q') {
        return true;
    }
    if (command == 's' && player.y == GROUND_Y) {
        player.y = TOP_Y;
    }
    return false;
}

bool checkCollision(const Position& player,
                    const std::vector<Position>& obstacles) {
    for (const Position& obs : obstacles) {
        if (obs.x == player.x && obs.y == player.y) {
            return true;
        }
    }
    return false;
}

// -----------------------------------------------------------------------------
// Main loop (goes to src/main.cpp after the split)
// -----------------------------------------------------------------------------

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

        // Move the obstacles to the left
        for (Position& obs : obstacles) {
            obs.x -= 1;
        }

        // Remove obstacles that left the screen
        obstacles.erase(
            std::remove_if(obstacles.begin(), obstacles.end(),
                           [](const Position& p) { return p.x < 0; }),
            obstacles.end());

        // Randomly spawn an obstacle on the right
        if (std::rand() % 3 == 0) {
            int y = (std::rand() % 2 == 0) ? GROUND_Y : TOP_Y;
            obstacles.push_back({ WIDTH - 1, y });
        }

        // Check the collision AFTER moving the obstacles
        if (checkCollision(player, obstacles)) {
            lives -= 1;
            std::cout << "\n>> COLLISION! Lives left: " << lives << "\n";
        }

        // A jump only lasts one turn: come back to the ground on the next turn
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
