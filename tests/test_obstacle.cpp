// tests/test_obstacle.cpp
//
// Obstacle logic, tested without any window: update() is pure arithmetic.

#include <catch2/catch_test_macros.hpp>
#include <catch2/matchers/catch_matchers_floating_point.hpp>

#include "Board.h"
#include "Obstacle.h"

TEST_CASE("An obstacle scrolls left at SPEED pixels per second", "[obstacle]") {
    Obstacle obs(1000.0f, GROUND_Y, PLAYER_SIZE);

    obs.update(1.0f);   // one full second

    REQUIRE_THAT(obs.getX(), Catch::Matchers::WithinAbs(1000.0f - SPEED, 0.001f));
}

TEST_CASE("Scrolling scales with the frame time", "[obstacle]") {
    Obstacle obs(500.0f, GROUND_Y, PLAYER_SIZE);

    obs.update(0.5f);   // half a second

    REQUIRE_THAT(obs.getX(), Catch::Matchers::WithinAbs(500.0f - SPEED * 0.5f, 0.001f));
}

TEST_CASE("An obstacle is off screen once entirely past the left edge", "[obstacle]") {
    Obstacle onScreen(10.0f, GROUND_Y, PLAYER_SIZE);
    Obstacle offScreen(-static_cast<float>(PLAYER_SIZE) - 1.0f, GROUND_Y, PLAYER_SIZE);

    REQUIRE_FALSE(onScreen.isOffScreen());
    REQUIRE(offScreen.isOffScreen());
}
