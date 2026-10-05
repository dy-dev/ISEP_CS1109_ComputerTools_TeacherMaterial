// include/Obstacle.h
//
// Obstacle: a GameObject that scrolls to the left at a constant speed and
// reports when it has left the screen.

#ifndef OBSTACLE_H
#define OBSTACLE_H

#include "GameObject.h"

class Obstacle : public GameObject {
public:
    Obstacle(float x, float y, int size);

    void update(float dt) override;
    void draw() const override;

    // True once the obstacle is entirely past the left edge.
    bool isOffScreen() const;
};

#endif  // OBSTACLE_H
