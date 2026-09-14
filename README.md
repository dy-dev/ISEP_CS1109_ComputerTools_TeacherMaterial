# CS.1109 - Teacher Materials

Dépôt privé des starters distribués aux étudiants séance par séance pour
le module CS.1109 "Outils de développement" à l'ISEP.

## Principe

Chaque séance qui nécessite un starter a un tag Git dédié :

| Tag           | Séance | Contenu                                              |
|---------------|--------|------------------------------------------------------|
| `starter-s02` | S2     | CMakeLists minimal + runner.cpp squelette + gitignore |
| `starter-s03` | S3     | Exemple split_pattern (Score.h / Score.cpp)          |
| `starter-s04` | S4     | CMakeLists Raylib + main.cpp squelette Raylib        |
| `starter-s06` | S6     | Bloc CMake Catch2 + example_test.cpp                 |
| `starter-s07` | S7     | Dockerfile.example commenté                          |
| `starter-s08` | S8     | ci.yml.example commenté                              |

Les séances S5 et S9 n'ont pas de starter (les étudiants écrivent tout).

## Génération des archives à distribuer

Utiliser le script fourni :

    scripts/zip-starter.sh starter-s02

Le zip généré ne contient PAS le README.md, les scripts ni le .gitattributes
grâce aux règles définies dans `.gitattributes`.

Alternative en ligne de commande directe :

    git archive --format=zip --output=starter-s02.zip \
        --prefix=starter-s02/ starter-s02

## Structure du dépôt

Le tronc `main` du dépôt représente à tout moment le contenu du starter
le plus récent. Chaque tag correspond à un point stable dans le temps.

## Auteur

Dominique Yolin - ARCREANE
