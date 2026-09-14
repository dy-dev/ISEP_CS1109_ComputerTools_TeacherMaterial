#!/bin/bash
#
# CS.1109 - Générateur d'archive zip pour un tag donné
#
# Utilisation :
#   ./scripts/zip-starter.sh starter-s02
#
# Génère le zip dans /tmp/<tag>.zip et affiche son contenu pour vérification.
#

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <tag>"
    echo
    echo "Exemples :"
    echo "  $0 starter-s02"
    echo "  $0 starter-s03"
    echo "  $0 starter-s04"
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

ZIP_OUT="/tmp/${TAG}.zip"
rm -f "$ZIP_OUT"

git archive --format=zip --output="$ZIP_OUT" --prefix="${TAG}/" "$TAG"

echo "Généré : $ZIP_OUT"
echo
echo "Contenu :"
echo "---"
unzip -l "$ZIP_OUT"
echo "---"
echo
echo "Prêt à distribuer aux étudiants."
