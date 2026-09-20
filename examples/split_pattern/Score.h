// Score.h - Standalone example of the declaration/definition pattern
//
// This file shows the .h/.cpp pattern on a small self-contained class.
// It is NOT meant to be integrated into the runner. It is a reference to
// read before writing Board.h or Player.h.
//
// Key point: the .h file holds only the DECLARATIONS (method names,
// signatures, members). The DEFINITIONS (method bodies) live in Score.cpp.

#ifndef SCORE_H
#define SCORE_H

class Score {
public:
    // Constructor: initialises the counter to 0.
    Score();

    // Adds points to the score (1 by default).
    void increment(int points = 1);

    // Returns the current score value.
    // The `const` keyword promises not to modify the object: this method can
    // be called on a const Score.
    int value() const;

    // Resets the score to zero.
    void reset();

private:
    // Convention: private members are prefixed with `m_` to tell them apart
    // from local variables and parameters.
    int m_value;
};

#endif // SCORE_H
