// include/GameObject.h
//
// GameObject: the base class of everything that lives in the game world.
// It owns a position and a size, and declares the three operations every
// object must provide: update itself, draw itself, expose its bounds.
//
// update and draw are pure virtual: GameObject itself cannot be instantiated,
// only its derived classes (Player, Obstacle) can. The virtual destructor is
// what makes deleting through a GameObject* safe.

#ifndef GAMEOBJECT_H
#define GAMEOBJECT_H

#include "raylib.h"

class GameObject {
public:
    GameObject(float x, float y, int size);
    virtual ~GameObject() = default;

    // Advances the object by dt seconds. Pure logic: no Raylib call here.
    virtual void update(float dt) = 0;

    // Draws the object at its current position. Raylib calls only.
    virtual void draw() const = 0;

    // Axis-aligned bounding box, used for collisions.
    Rectangle getBounds() const;

    float getX() const;
    float getY() const;

protected:
    float m_x;
    float m_y;
    int m_size;
};

#endif  // GAMEOBJECT_H
