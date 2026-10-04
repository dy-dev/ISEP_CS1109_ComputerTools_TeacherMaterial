# Corrigé enseignant — Split S3 (Runner console)

Version de référence du `runner.cpp` de S2 découpé selon le pattern
déclaration/définition, telle qu'attendue à la fin de la Phase B du TP S3.
**Usage enseignant uniquement** : à garder sous la main pour débloquer un
groupe en séance, ne pas distribuer aux étudiants.

## Arborescence

```
CS1109_Runner_S4_Start/   (maillon 03_S4_Start_equals_S3_Solution = corrigé S3)
├── CMakeLists.txt          add_executable + target_include_directories
├── include/
│   ├── Board.h             struct Position, constantes du monde, afficherEtat
│   └── Player.h            traiterCommande, verifierCollision (inclut Board.h)
└── src/
    ├── Board.cpp           définition des constantes + afficherEtat
    ├── Player.cpp          définition traiterCommande + verifierCollision
    └── main.cpp            orchestration (boucle de jeu), inclut les deux .h
```

## Répartition (mapping avec le TP)

- **B5 (Membre 1)** → `include/Board.h` + `src/Board.cpp` : la `struct Position`,
  les constantes du monde, la fonction `afficherEtat`.
- **B6 (Membre 2)** → `include/Player.h` + `src/Player.cpp` : `traiterCommande`
  et `verifierCollision`. `Player.h` inclut `Board.h` pour connaître `Position`.
- **B7 (Membre 3)** → `src/main.cpp` : le `main()` extrait du runner.cpp,
  inchangé sauf les deux `#include "Board.h"` / `#include "Player.h"` ajoutés en
  tête, et le fichier `runner.cpp` d'origine supprimé.

## Compiler et lancer

```
cmake -B build
cmake --build build
./build/runner
```

Compile sans avertissement avec `-Wall -Wextra`.

## Points d'attention fréquents en séance

- **Constantes** : `Board.h` les déclare avec `extern const`, `Board.cpp` les
  définit. Un groupe qui met la valeur (`const int LARGEUR = 40;`) directement
  dans le `.h` aura une erreur de définition multiple dès que deux `.cpp`
  incluent `Board.h`. C'est le piège classique — l'occasion d'expliquer la
  différence déclaration/définition sur une donnée.
- **Include de Board depuis Player** : si un groupe oublie `#include "Board.h"`
  dans `Player.h`, le compilateur ne connaît pas `Position` → erreur. Les
  include guards de `Board.h` rendent l'inclusion multiple sans danger.
- **CMakeLists** : les trois sources doivent être listées dans `add_executable`,
  et `target_include_directories(runner PRIVATE include)` est indispensable pour
  que `#include "Board.h"` soit trouvé.
