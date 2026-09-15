#!/bin/bash
#
# CS.1109 - Générateur d'archive zip pour un tag donné
#
# Utilisation :
#   ./scripts/zip-starter.sh starter-s02
#
# Génère le zip dans ~/cs1109_zips/<tag>.zip et affiche son contenu.
#
# Note technique : sur Cygwin avec Git natif Windows, on génère d'abord
# dans le dossier courant (chemin relatif compris par Git Windows) puis
# on déplace avec mv (commande Cygwin).
#

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <tag>"
    echo
    echo "Exemples :"
    echo "  $0 starter-s02"
    echo "  $0 starter-s03"
    echo
    echo "Tags disponibles :"
    git tag -l 'starter-*' | sed 's/^/  /'
    exit 1
fi

TAG="$1"

if [ ! -d ".git" ]; then
    echo "ERREUR : ce dossier n'est pas un repo git."
    exit 1
fi

if ! git rev-parse "$TAG" >/dev/null 2>&1; then
    echo "ERREUR : le tag $TAG n'existe pas."
    echo
    echo "Tags disponibles :"
    git tag -l 'starter-*' | sed 's/^/  /'
    exit 1
fi

# Étape 1 : générer dans le dossier courant (chemin relatif)
# C'est le seul chemin que Git natif Windows sait interpréter à coup sûr
TEMP_ZIP="${TAG}.zip"
rm -f "$TEMP_ZIP"

git archive --format=zip --output="$TEMP_ZIP" --prefix="${TAG}/" "$TAG"

if [ ! -f "$TEMP_ZIP" ]; then
    echo "ERREUR : git archive n'a pas créé le fichier $TEMP_ZIP dans le dossier courant."
    echo "Vérifie ta version de git : which git"
    exit 1
fi

# Étape 2 : déplacer vers $HOME/cs1109_zips/ (mv Cygwin, chemins Unix OK)
ZIP_DIR="$HOME/cs1109_zips"
mkdir -p "$ZIP_DIR"

FINAL_ZIP="$ZIP_DIR/${TAG}.zip"
mv "$TEMP_ZIP" "$FINAL_ZIP"

# Étape 3 : afficher le contenu et les infos
echo "Généré : $FINAL_ZIP"
echo "Taille : $(du -h "$FINAL_ZIP" | cut -f1)"
echo
echo "Contenu :"
echo "---"
unzip -l "$FINAL_ZIP"
echo "---"
echo
echo "Prêt à distribuer aux étudiants."

# Chemin Windows utilisable dans l'explorateur pour uploader sur Moodle
if command -v cygpath >/dev/null 2>&1; then
    WIN_PATH=$(cygpath -w "$FINAL_ZIP")
    echo "Chemin Windows : $WIN_PATH"
fi
