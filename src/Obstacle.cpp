// src/Obstacle.cpp

#include "Obstacle.h"

#include "Board.h"

Obstacle::Obstacle(float x, float y, int size)
    : GameObject(x, y, size) {
}

void Obstacle::update(float dt) {
    m_x -= SPEED * dt;
}

void Obstacle::draw() const {
    DrawRectangle(static_cast<int>(m_x), static_cast<int>(m_y), m_size, m_size, DARKGRAY);
}

bool Obstacle::isOffScreen() const {
    return m_x + m_size < 0.0f;
}
