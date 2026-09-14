#!/bin/bash
#
# CS.1109 - Reset propre du repo prof
#
# Ce script réécrit l'historique du repo pour repartir sur des bases propres :
#   - Supprime l'historique actuel (commits + tags)
#   - Crée une nouvelle branche main orpheline avec les bons fichiers
#   - Fait 2 commits propres (init + starter S2)
#   - Force push pour écraser l'ancien historique distant
#   - Supprime la branche master distante si elle existe
#   - Retag starter-s02
#
# ATTENTION : ce script réécrit l'historique. À n'utiliser que si le repo est
# privé et pas encore partagé.
#
# À lancer depuis la racine du clone local du repo cs1109-teacher-materials.
#

set -e

# --- Vérifications préalables ---

if [ ! -d ".git" ]; then
    echo "ERREUR : ce dossier n'est pas un repo git."
    exit 1
fi

REPO_NAME=$(basename "$(pwd)")
if [ "$REPO_NAME" != "cs1109-teacher-materials" ]; then
    echo "AVERTISSEMENT : dossier '$REPO_NAME' au lieu de 'cs1109-teacher-materials'."
    read -p "Continuer ? [o/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Oo]$ ]]; then
        exit 1
    fi
fi

# --- Confirmation utilisateur ---

echo "=================================================================="
echo "  RESET PROPRE DU REPO cs1109-teacher-materials"
echo "=================================================================="
echo
echo "Ce script va :"
echo "  1. Supprimer tous les tags starter-* (locaux et distants)"
echo "  2. Créer une nouvelle branche main orpheline"
echo "  3. Recréer tous les fichiers proprement"
echo "  4. Faire 2 commits propres (init + starter S2)"
echo "  5. Force push sur origin/main (écrase l'historique distant)"
echo "  6. Supprimer la branche master distante si elle existe"
echo "  7. Poser le tag starter-s02 sur le commit propre"
echo
echo "ATTENTION : l'historique actuel sera DÉTRUIT sans possibilité de retour."
echo
read -p "Confirmer ? Tape 'reset' pour continuer : " CONFIRM
if [ "$CONFIRM" != "reset" ]; then
    echo "Abandon."
    exit 1
fi

echo
echo "=== Début du reset ==="
echo

# --- Étape 1 : suppression des tags existants ---

echo "[1/8] Suppression des tags starter-* existants..."

for tag in $(git tag -l 'starter-*'); do
    echo "  Suppression tag local : $tag"
    git tag -d "$tag" >/dev/null 2>&1 || true
    echo "  Suppression tag distant : $tag"
    git push --delete origin "$tag" 2>/dev/null || echo "    (déjà absent en distant)"
done

# --- Étape 2 : nettoyage complet de l'arbre de travail ---

echo "[2/8] Nettoyage de l'arbre de travail..."

# Sauvegarder le dossier scripts/ dans /tmp (on veut le garder)
if [ -d "scripts" ]; then
    cp -r scripts /tmp/cs1109_scripts_backup
    echo "  Scripts sauvegardés dans /tmp/cs1109_scripts_backup"
fi

# --- Étape 3 : création d'une branche main orpheline ---

echo "[3/8] Création d'une branche main orpheline (sans historique)..."

git checkout --orphan main-clean
git rm -rf . >/dev/null 2>&1 || true

# Nettoyer les fichiers restants qui ne sont pas tracked
find . -mindepth 1 -maxdepth 1 ! -name '.git' -exec rm -rf {} + 2>/dev/null || true

# Restaurer les scripts
if [ -d "/tmp/cs1109_scripts_backup" ]; then
    cp -r /tmp/cs1109_scripts_backup scripts
    chmod +x scripts/*.sh 2>/dev/null || true
    echo "  Scripts restaurés"
fi

# --- Étape 4 : création des fichiers propres (commit 1 : init) ---

echo "[4/8] Création des fichiers d'initialisation..."

# README.md racine (protocole du repo prof)
cat > README.md << 'EOF'
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
EOF

# .gitattributes (exclusions des archives)
cat > .gitattributes << 'EOF'
# Exclure les fichiers meta du repo prof des archives Git
# (git archive utilise ces règles pour les zip distribués aux étudiants)
README.md      export-ignore
scripts/       export-ignore
.gitattributes export-ignore
EOF

echo "  OK README.md et .gitattributes créés"

# --- Étape 5 : commit 1 d'initialisation ---

echo "[5/8] Commit initial (structure du repo prof)..."

git add README.md .gitattributes scripts/
git commit -m "Init repo prof : README protocole + gitattributes + scripts"

# --- Étape 6 : création des fichiers du starter S2 (commit 2) ---

echo "[6/8] Création des fichiers du starter S2..."

# CMakeLists.txt ultra-minimal
cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.20)
project(runner LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(runner src/runner.cpp)
EOF

# src/runner.cpp squelette
mkdir -p src
cat > src/runner.cpp << 'EOF'
#include <iostream>
#include <vector>
#include <string>

int main() {
    // TODO : menu de démarrage (Jouer / Quitter)

    // TODO : boucle de jeu si le joueur choisit Jouer

    return 0;
}
EOF

# .gitignore C++
cat > .gitignore << 'EOF'
# Fichiers objets et intermédiaires
*.o
*.obj
*.d
*.gch
*.pch

# Bibliothèques
*.lib
*.a
*.so
*.so.*
*.dylib
*.dll

# Exécutables
*.exe
*.out
*.app
runner

# Dossiers de build
build/
cmake-build-*/

# IDE
.vscode/
.idea/
.vs/
*.user

# Système
.DS_Store
Thumbs.db
EOF

git add CMakeLists.txt src/runner.cpp .gitignore
git commit -m "S2 starter : CMakeLists minimal + runner.cpp squelette + gitignore C++"

echo "  OK starter S2 commité"

# --- Étape 7 : renommage en main et force push ---

echo "[7/8] Renommage en main et force push..."

# Supprimer l'ancienne branche main locale si elle existe
git branch -D main 2>/dev/null || true

# Renommer la branche courante en main
git branch -m main-clean main

# Force push
git push -u origin main --force

echo "  OK main poussé (force)"

# Supprimer master distant si présent
echo "  Vérification et suppression de la branche master distante si elle existe..."
if git ls-remote --heads origin master | grep -q master; then
    git push --delete origin master 2>/dev/null && echo "    OK master distant supprimé" || \
        echo "    ATTENTION : impossible de supprimer master distant. Va dans Settings > Branches sur GitHub, mets main en default branch, puis relance : git push --delete origin master"
else
    echo "    (pas de branche master distante)"
fi

# --- Étape 8 : pose du tag starter-s02 et test du zip ---

echo "[8/8] Pose du tag starter-s02 et test du zip..."

TAG="starter-s02"
git tag "$TAG"
git push origin "$TAG"

echo "  OK tag $TAG posé"

# Test génération du zip
ZIP_OUT="/tmp/${TAG}.zip"
rm -f "$ZIP_OUT"
git archive --format=zip --output="$ZIP_OUT" --prefix="${TAG}/" "$TAG"

echo
echo "Contenu du zip généré :"
echo "---"
unzip -l "$ZIP_OUT"
echo "---"

# Nettoyage temporaire
rm -rf /tmp/cs1109_scripts_backup 2>/dev/null || true

echo
echo "=================================================================="
echo "  RESET TERMINÉ AVEC SUCCÈS"
echo "=================================================================="
echo
echo "État final :"
echo "  - Branche main avec 2 commits propres"
echo "  - Tag starter-s02 sur le 2e commit"
echo "  - Zip généré dans $ZIP_OUT"
echo
echo "Historique :"
git log --oneline --decorate
echo
echo "Vérifications à faire sur github.com :"
echo "  1. La branche par défaut du repo est bien main (Settings > Branches)"
echo "  2. Le README affiché sur la page du repo décrit bien le repo prof"
echo "  3. Le tag starter-s02 apparaît dans l'onglet Tags"
echo "  4. La branche master n'existe plus (sinon, à supprimer via l'UI)"
