// src/Board.cpp

#include "Board.h"

#include <string>

#include "raylib.h"

const int   SCREEN_WIDTH  = 1024;
const int   SCREEN_HEIGHT = 576;
const int   PLAYER_SIZE   = 40;
const float PLAYER_X      = 120.0f;
const float GROUND_LINE   = 500.0f;
const float GROUND_Y      = GROUND_LINE - PLAYER_SIZE;
const float TOP_Y         = GROUND_Y - 120.0f;
const float SPEED         = 300.0f;
const float GRAVITY       = 1500.0f;
const float JUMP_SPEED    = -600.0f;   // apex = JUMP_SPEED^2 / (2*GRAVITY) = 120 px = TOP_Y
const int   LIVES_INIT    = 3;

void drawBoard(int score, int lives) {
    if (sceneryLoaded()) {
        // Le décor fournit déjà un sol : une ligne discrète suffit à marquer
        // la limite sur laquelle le joueur se pose.
        DrawRectangle(0, static_cast<int>(GROUND_LINE), SCREEN_WIDTH, 2,
                      Color{ 255, 120, 180, 160 });
    } else {
        DrawRectangle(0, static_cast<int>(GROUND_LINE),
                      SCREEN_WIDTH, SCREEN_HEIGHT - static_cast<int>(GROUND_LINE), DARKGREEN);
    }

    std::string scoreText = "Score: " + std::to_string(score);
    std::string livesText = "Lives: " + std::to_string(lives);
    DrawText(scoreText.c_str(), 10, 10, 20, BLACK);
    DrawText(livesText.c_str(), SCREEN_WIDTH - 110, 10, 20, BLACK);
}


// ---------------------------------------------------------------------------
// Optional scenery: three layers scrolling at different speeds. The farther a
// layer is, the slower it moves — that is what gives the depth impression.
// Nothing here is required by the game: remove the four functions and the
// Runner still runs.
// ---------------------------------------------------------------------------
namespace {
struct Layer {
    Texture2D texture;
    float     offset;   // horizontal scrolling, in pixels
    float     factor;   // fraction of SPEED: 0.2 = five times slower
};

// Facteur d'agrandissement d'une couche : elle occupe toute la hauteur.
float layerScale(const Layer& l) {
    return static_cast<float>(SCREEN_HEIGHT) / l.texture.height;
}

// Largeur d'une tuile UNE FOIS DESSINÉE. C'est elle qui sert au rebouclage :
// reboucler sur une autre valeur que la largeur affichée fait sauter l'image.
float tileWidth(const Layer& l) {
    return l.texture.width * layerScale(l);
}
Layer g_layers[3];
bool  g_sceneryLoaded = false;
}  // namespace

bool sceneryLoaded() { return g_sceneryLoaded; }

namespace {
}  // namespace

void loadScenery() {
    g_layers[0] = { LoadTexture("resources/bg_far.png"),  0.0f, 0.2f };
    g_layers[1] = { LoadTexture("resources/bg_mid.png"),  0.0f, 0.5f };
    g_layers[2] = { LoadTexture("resources/bg_near.png"), 0.0f, 0.8f };
    g_sceneryLoaded = g_layers[0].texture.id > 0;
}

void updateScenery(float dt) {
    if (!g_sceneryLoaded) return;
    for (Layer& l : g_layers) {
        l.offset -= SPEED * l.factor * dt;
        const float w = tileWidth(l);
        // while, pas if : un dt anormalement grand (fenêtre déplacée, machine
        // qui rame) peut dépasser plusieurs largeurs d'un coup.
        while (l.offset <= -w) l.offset += w;
    }
}

void drawScenery() {
    if (!g_sceneryLoaded) {
        ClearBackground(RAYWHITE);
        return;
    }
    for (const Layer& l : g_layers) {
        const float scale = layerScale(l);
        const float w     = tileWidth(l);
        // On part d'une tuile avant le bord gauche : offset est dans ]-w, 0],
        // donc une seule tuile suffirait à gauche, mais partir de offset - w
        // garantit l'absence de bande vide si offset dérive.
        for (float x = l.offset - w; x < SCREEN_WIDTH; x += w) {
            DrawTextureEx(l.texture, Vector2{ x, 0.0f }, 0.0f, scale, WHITE);
        }
    }
}

void unloadScenery() {
    if (!g_sceneryLoaded) return;
    for (Layer& l : g_layers) UnloadTexture(l.texture);
    g_sceneryLoaded = false;
}
