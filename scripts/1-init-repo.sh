#!/bin/bash
#
# CS.1109 - Init du repo prof cs1109-teacher-materials
#
# Ce script initialise la structure de base du repo prof :
#   - README.md de vitrine (visible sur GitHub, minimal)
#   - _prof/README.md (protocole complet pour toi)
#   - .gitattributes (exclut _prof/ et scripts/ des archives distribuées)
#
# À lancer depuis la racine du clone local du repo cs1109-teacher-materials.
#

set -e

# --- Vérifications préalables ---

if [ ! -d ".git" ]; then
    echo "ERREUR : ce dossier n'est pas un repo git."
    echo "Clone d'abord le repo avec :"
    echo "  git clone git@github.com:<ton-user>/cs1109-teacher-materials.git"
    echo "  cd cs1109-teacher-materials"
    echo "Puis relance ce script."
    exit 1
fi

REPO_NAME=$(basename "$(pwd)")
if [ "$REPO_NAME" != "cs1109-teacher-materials" ]; then
    echo "AVERTISSEMENT : le dossier courant s'appelle '$REPO_NAME' au lieu de 'cs1109-teacher-materials'."
    read -p "Continuer quand même ? [o/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Oo]$ ]]; then
        exit 1
    fi
fi

echo "=== Initialisation du repo prof cs1109-teacher-materials ==="
echo

# --- Étape 1 : dossier _prof/ pour le README de protocole ---

echo "[1/4] Création du dossier _prof/ et du README de protocole..."
mkdir -p _prof

cat > _prof/README.md << 'EOF'
# CS.1109 - Protocole de distribution des starters

Ce dépôt privé contient les starters distribués aux étudiants séance par
séance pour le module CS.1109 "Outils de développement" à l'ISEP.

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

Le zip généré ne contient PAS le dossier `_prof/` ni le dossier `scripts/`
grâce au fichier `.gitattributes` à la racine.

Alternative en ligne de commande directe :

    git archive --format=zip --output=starter-s02.zip \
        --prefix=starter-s02/ starter-s02

## Structure du dépôt

Le tronc `main` du dépôt représente à tout moment le contenu du starter
le plus récent. Chaque tag correspond à un point stable dans le temps.

Le dossier `_prof/` contient toute la documentation destinée à l'enseignant.
Il est exclu des archives distribuées via `.gitattributes`.

## Auteur

Dominique Yolin - ARCREANE
EOF
echo "  OK _prof/README.md créé"

# --- Étape 2 : README vitrine à la racine ---

echo "[2/4] Création du README de vitrine à la racine..."

cat > README.md << 'EOF'
# CS.1109 - Runner

Projet de jeu Runner en C++ pour le module CS.1109 à l'ISEP.

## Compilation

Ouvrir le projet dans CLion et lancer un Build (Ctrl+F9).

Ou en ligne de commande :

    cmake -B build
    cmake --build build

## Exécution

    ./build/runner
EOF
echo "  OK README.md (vitrine) créé"

# --- Étape 3 : .gitattributes pour exclure _prof/ et scripts/ des zips ---

echo "[3/4] Création du .gitattributes pour filtrer les archives..."

cat > .gitattributes << 'EOF'
# Exclure les dossiers prof et scripts des archives Git
# (git archive utilise ces règles pour les zip distribués aux étudiants)
_prof/         export-ignore
scripts/       export-ignore
.gitattributes export-ignore
.gitignore     export-ignore
EOF
echo "  OK .gitattributes créé"

# --- Étape 4 : commit et push ---

echo "[4/4] Commit initial et push..."

git add _prof/README.md README.md .gitattributes
git commit -m "Init repo prof : README vitrine + protocole dans _prof/ + gitattributes"

# Détection de la branche par défaut (main ou master)
BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "  Branche courante : $BRANCH"
git push origin "$BRANCH"

echo
echo "=== Init terminé ==="
echo
echo "Prochaine étape : lancer ./scripts/2-make-starter-s02.sh"
echo "pour créer le starter de la S2."
