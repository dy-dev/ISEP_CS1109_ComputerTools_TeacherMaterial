// src/GameObject.cpp

#include "GameObject.h"

GameObject::GameObject(float x, float y, int size)
    : m_x(x), m_y(y), m_size(size) {
}

Rectangle GameObject::getBounds() const {
    return Rectangle{ m_x, m_y, static_cast<float>(m_size), static_cast<float>(m_size) };
}

float GameObject::getX() const {
    return m_x;
}

float GameObject::getY() const {
    return m_y;
}
