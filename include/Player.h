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

    // --- optional sprite (bonus) ---
    // Loads the two poses; call once after InitWindow.
    void loadSprites();
    void unloadSprites();

private:
    float m_velocityY;   // pixels per second, negative upwards

    // Two still images, picked from the state: no animation timer.
    float m_distance = 0.0f;   // distance parcourue par le décor, en pixels :
                               // c'est elle qui choisit la pose de course,
                               // jamais un compteur de temps.

    Texture2D m_runTextures[3]{};   // trois poses de course
    Texture2D m_jumpTexture{};      // montée
    Texture2D m_fallTexture{};      // descente
    bool      m_hasSprites = false;
};

#endif  // PLAYER_H
