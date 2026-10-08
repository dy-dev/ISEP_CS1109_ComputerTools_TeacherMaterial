// include/Player.h
//
// Player: a GameObject that jumps on Space and falls back under gravity.
// The vertical speed lives inside the object instead of being scattered
// across main.

#ifndef PLAYER_H
#define PLAYER_H

#include "GameObject.h"

class Player : public GameObject {
public:
    Player(float x, float y, int size);

    // Reads the keyboard: calls jump() on Space.
    void handleInput();

    // Gives the player an upward speed if it is on the ground. Pure logic,
    // no Raylib: this is what the tests exercise.
    void jump();

    // Applies gravity to the vertical speed, moves the player, and puts it
    // back on the ground when it lands. Pure logic, no Raylib call.
    void update(float dt) override;

    void draw() const override;

    bool isOnGround() const;

private:
    float m_velocityY;   // pixels per second, negative upwards
};

#endif  // PLAYER_H
