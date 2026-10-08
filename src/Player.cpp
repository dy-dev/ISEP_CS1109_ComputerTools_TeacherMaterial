// src/Player.cpp

#include "Player.h"

#include "Board.h"

Player::Player(float x, float y, int size)
    : GameObject(x, y, size), m_velocityY(0.0f) {}

void Player::handleInput() {
    if (IsKeyPressed(KEY_SPACE)) {
        jump();
    }
}

void Player::jump() {
    if (isOnGround()) {
        m_velocityY = JUMP_SPEED;
    }
}

void Player::update(float dt) {
    m_velocityY += GRAVITY * dt;   // gravity pulls the vertical speed down
    m_y += m_velocityY * dt;       // the speed moves the player

    if (m_y >= GROUND_Y) {         // landed: snap back, never compare floats with ==
        m_y = GROUND_Y;
        m_velocityY = 0.0f;
    }
}

void Player::draw() const {
    DrawRectangle(static_cast<int>(m_x), static_cast<int>(m_y), m_size, m_size, RED);
}

bool Player::isOnGround() const {
    return m_y >= GROUND_Y;
}
