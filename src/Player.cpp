// src/Player.cpp

#include "Player.h"

#include "Board.h"

Player::Player(float x, float y, int size)
    : GameObject(x, y, size), m_velocityY(0.0f) {
}

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
    m_distance += SPEED * dt;      // the ground slides by: this drives the stride
    m_velocityY += GRAVITY * dt;   // gravity pulls the vertical speed down
    m_y += m_velocityY * dt;       // the speed moves the player

    if (m_y >= GROUND_Y) {         // landed: snap back, never compare floats with ==
        m_y = GROUND_Y;
        m_velocityY = 0.0f;
    }
}

void Player::draw() const {
    if (!m_hasSprites) {   // no sprite loaded: the plain square still works
        DrawRectangle(static_cast<int>(m_x), static_cast<int>(m_y), m_size, m_size, RED);
        return;
    }

    // The pose comes from the state the object already holds:
    //   - in the air, rising or falling, from the vertical speed;
    //   - on the ground, from the distance covered, not from a clock. One
    //     stride every 60 pixels: the legs follow the scenery, so the run
    //     never looks out of step whatever the frame rate.
    const Texture2D* tex;
    if (!isOnGround()) {
        tex = (m_velocityY < 0.0f) ? &m_jumpTexture : &m_fallTexture;
    } else {
        int stride = static_cast<int>(m_distance / 60.0f) % 3;
        tex = &m_runTextures[stride];
    }

    // The sprite is drawn larger than the collision box and anchored on the
    // ground, feet at the bottom of the box: a character the size of its
    // hitbox looks tiny against the scenery.
    const float DRAW_SCALE = 2.2f;
    float h = m_size * DRAW_SCALE;
    float w = h * tex->width / tex->height;
    float x = m_x + (m_size - w) * 0.5f;      // centré sur la boîte
    float y = m_y + m_size - h;               // pieds posés au sol
    DrawTextureEx(*tex, Vector2{ x, y }, 0.0f, h / tex->height, WHITE);
}

void Player::loadSprites() {
    m_runTextures[0] = LoadTexture("resources/player_run0.png");
    m_runTextures[1] = LoadTexture("resources/player_run1.png");
    m_runTextures[2] = LoadTexture("resources/player_run2.png");
    m_jumpTexture    = LoadTexture("resources/player_jump.png");
    m_fallTexture    = LoadTexture("resources/player_fall.png");
    m_hasSprites = m_runTextures[0].id > 0 && m_runTextures[1].id > 0 &&
                   m_runTextures[2].id > 0 && m_jumpTexture.id > 0 && m_fallTexture.id > 0;
}

void Player::unloadSprites() {
    if (!m_hasSprites) return;
    for (Texture2D& t : m_runTextures) UnloadTexture(t);
    UnloadTexture(m_jumpTexture);
    UnloadTexture(m_fallTexture);
    m_hasSprites = false;
}

bool Player::isOnGround() const {
    return m_y >= GROUND_Y;
}
