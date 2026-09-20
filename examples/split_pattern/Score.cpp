// Score.cpp - Definition of the methods declared in Score.h
//
// The implementation lives here, outside the header. A file that uses Score
// includes Score.h (never Score.cpp), and the compiler links the calls to the
// definitions at link time.

#include "Score.h"

// Constructor: the initialisation list `: m_value(0)` is preferable to an
// assignment in the body. It builds the member directly with the right value,
// instead of a default construction followed by an assignment.
Score::Score()
    : m_value(0) {
}

// The full name `Score::increment` says this function is the increment method
// of the Score class. Without the prefix, the compiler would take it for an
// unrelated free function.
void Score::increment(int points) {
    m_value += points;
}

int Score::value() const {
    return m_value;
}

void Score::reset() {
    m_value = 0;
}
