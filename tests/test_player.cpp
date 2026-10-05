// tests/test_player.cpp
//
// Player jump logic, without any window. jump() and update() are pure logic;
// handleInput() (which reads the keyboard) is the only part not tested here.

#include <catch2/catch_test_macros.hpp>
#include <catch2/matchers/catch_matchers_floating_point.hpp>

#include "Board.h"
#include "Player.h"

TEST_CASE("A player starts on the ground", "[player]") {
    Player player(PLAYER_X, GROUND_Y, PLAYER_SIZE);

    REQUIRE(player.isOnGround());
    REQUIRE(player.getY() == GROUND_Y);
}

TEST_CASE("jump() gives the player an upward speed and lifts it off", "[player]") {
    Player player(PLAYER_X, GROUND_Y, PLAYER_SIZE);

    player.jump();
    player.update(1.0f / 60.0f);   // one frame is enough to leave the ground

    REQUIRE_FALSE(player.isOnGround());
    REQUIRE(player.getY() < GROUND_Y);
}

TEST_CASE("Gravity brings the player back to the ground on its own", "[player]") {
    Player player(PLAYER_X, GROUND_Y, PLAYER_SIZE);
    player.jump();

    // 90 frames of 1/60 s = 1.5 s, well past the whole jump
    for (int i = 0; i < 90; ++i) {
        player.update(1.0f / 60.0f);
    }

    REQUIRE(player.isOnGround());
    REQUIRE(player.getY() == GROUND_Y);
}

TEST_CASE("The jump reaches the height of the high obstacles", "[player]") {
    Player player(PLAYER_X, GROUND_Y, PLAYER_SIZE);
    player.jump();

    float apex = GROUND_Y;
    for (int i = 0; i < 90; ++i) {
        player.update(1.0f / 60.0f);
        if (player.getY() < apex) {
            apex = player.getY();
        }
    }

    // Continuous value is JUMP_SPEED^2 / (2*GRAVITY) = 120 px; stepwise
    // integration loses a little, so check it is within 10 px of TOP_Y.
    REQUIRE_THAT(apex, Catch::Matchers::WithinAbs(TOP_Y, 10.0f));
}

TEST_CASE("The player is still in the air shortly after jumping", "[player]") {
    Player player(PLAYER_X, GROUND_Y, PLAYER_SIZE);
    player.jump();

    player.update(0.1f);   // 0.1 s, far from landing

    REQUIRE_FALSE(player.isOnGround());
}

TEST_CASE("jump() does nothing while already in the air", "[player]") {
    Player player(PLAYER_X, GROUND_Y, PLAYER_SIZE);
    player.jump();
    player.update(0.1f);
    float yBefore = player.getY();

    player.jump();            // ignored: not on the ground
    player.update(0.0f);      // no time passes

    REQUIRE(player.getY() == yBefore);
}

TEST_CASE("Landing is independent of the frame rate", "[player]") {
    Player slow(PLAYER_X, GROUND_Y, PLAYER_SIZE);
    Player fast(PLAYER_X, GROUND_Y, PLAYER_SIZE);
    slow.jump();
    fast.jump();

    for (int i = 0; i < 60; ++i) {
        slow.update(1.0f / 30.0f);    // 2 s at 30 fps
    }
    for (int i = 0; i < 240; ++i) {
        fast.update(1.0f / 120.0f);   // 2 s at 120 fps
    }

    REQUIRE(slow.isOnGround());
    REQUIRE(fast.isOnGround());
}
