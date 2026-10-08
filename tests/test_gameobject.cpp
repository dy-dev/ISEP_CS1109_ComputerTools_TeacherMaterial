// tests/test_gameobject.cpp
//
// Bounds and collision, through the GameObject interface.

#include <catch2/catch_test_macros.hpp>

#include "Board.h"
#include "Obstacle.h"
#include "Player.h"
#include "raylib.h"

TEST_CASE("getBounds reflects position and size", "[gameobject]") {
    Obstacle obs(100.0f, 200.0f, PLAYER_SIZE);

    Rectangle r = obs.getBounds();

    REQUIRE(r.x == 100.0f);
    REQUIRE(r.y == 200.0f);
    REQUIRE(r.width == static_cast<float>(PLAYER_SIZE));
    REQUIRE(r.height == static_cast<float>(PLAYER_SIZE));
}

TEST_CASE("Overlapping objects collide, distant objects do not", "[gameobject]") {
    Player player(PLAYER_X, GROUND_Y, PLAYER_SIZE);
    Obstacle touching(PLAYER_X + 10.0f, GROUND_Y, PLAYER_SIZE);
    Obstacle far(PLAYER_X + 500.0f, GROUND_Y, PLAYER_SIZE);

    REQUIRE(CheckCollisionRecs(player.getBounds(), touching.getBounds()));
    REQUIRE_FALSE(CheckCollisionRecs(player.getBounds(), far.getBounds()));
}
