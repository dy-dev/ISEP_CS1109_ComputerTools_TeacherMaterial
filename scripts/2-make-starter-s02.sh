#!/bin/bash
#
# CS.1109 - Création du starter S2
#
# Ce script crée les fichiers du starter S2, les commite et pose le tag
# starter-s02, puis génère un zip de test pour vérifier ce qui sera
# distribué aux étudiants.
#
# Prérequis : avoir lancé ./scripts/1-init-repo.sh au préalable.
#
# À lancer depuis la racine du clone local du repo cs1109-teacher-materials.
#

set -e

TAG="starter-s02"

# --- Vérifications préalables ---

if [ ! -d ".git" ]; then
    echo "ERREUR : ce dossier n'est pas un repo git."
    exit 1
fi

if [ ! -f ".gitattributes" ]; then
    echo "ERREUR : .gitattributes absent."
    echo "Lance d'abord ./scripts/1-init-repo.sh"
    exit 1
fi

# Vérifier si le tag existe déjà
if git rev-parse "$TAG" >/dev/null 2>&1; then
    echo "Le tag $TAG existe déjà."
    read -p "Le supprimer et le refaire ? [o/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Oo]$ ]]; then
        exit 1
    fi
    echo "Suppression du tag existant (local + distant)..."
    git tag -d "$TAG" 2>/dev/null || true
    git push --delete origin "$TAG" 2>/dev/null || true
fi

echo "=== Création du starter S2 ==="
echo

# --- Étape 1 : CMakeLists.txt ultra-minimal ---

echo "[1/5] Création du CMakeLists.txt ultra-minimal..."

cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.20)
project(runner LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(runner src/runner.cpp)
EOF
echo "  OK CMakeLists.txt créé"

# --- Étape 2 : src/runner.cpp squelette ---

echo "[2/5] Création du squelette src/runner.cpp..."

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
echo "  OK src/runner.cpp créé"

# --- Étape 3 : .gitignore C++ ---

echo "[3/5] Création du .gitignore C++..."

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
echo "  OK .gitignore créé"

# --- Étape 4 : commit et tag ---

echo "[4/5] Commit et pose du tag $TAG..."

git add CMakeLists.txt src/runner.cpp .gitignore
git commit -m "S2 starter : CMakeLists minimal + runner.cpp squelette + gitignore C++"

BRANCH=$(git rev-parse --abbrev-ref HEAD)
git push origin "$BRANCH"

git tag "$TAG"
git push origin "$TAG"
echo "  OK tag $TAG posé et poussé"

# --- Étape 5 : test de génération du zip ---

echo "[5/5] Test de génération du zip..."

ZIP_OUT="/tmp/${TAG}.zip"
rm -f "$ZIP_OUT"
git archive --format=zip --output="$ZIP_OUT" --prefix="${TAG}/" "$TAG"

echo
echo "Contenu du zip généré ($ZIP_OUT) :"
echo "---"
unzip -l "$ZIP_OUT"
echo "---"

echo
echo "=== Starter S2 créé ==="
echo
echo "Vérifications à faire manuellement :"
echo "  1. Le zip contient bien : CMakeLists.txt, src/runner.cpp, .gitignore, README.md"
echo "  2. Le zip ne contient PAS : _prof/, scripts/, .gitattributes"
echo
echo "Pour re-générer un zip plus tard :"
echo "  ./scripts/zip-starter.sh $TAG"
echo
echo "Pour distribuer aux étudiants : uploader $ZIP_OUT sur Moodle S2."
