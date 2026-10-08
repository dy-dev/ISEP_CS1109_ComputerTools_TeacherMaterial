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
    // Bloc néon : lisible sur un décor chargé, là où un carré gris disparaît.
    // Corps sombre translucide, contour et liseré clairs.
    int x = static_cast<int>(m_x);
    int y = static_cast<int>(m_y);
    DrawRectangle(x, y, m_size, m_size, Color{ 20, 10, 30, 230 });
    DrawRectangleLinesEx(Rectangle{ m_x, m_y, static_cast<float>(m_size),
                                    static_cast<float>(m_size) }, 3.0f,
                         Color{ 0, 240, 255, 255 });
    DrawRectangle(x + 6, y + 6, m_size - 12, 4, Color{ 255, 60, 140, 255 });
}

bool Obstacle::isOffScreen() const {
    return m_x + m_size < 0.0f;
}
