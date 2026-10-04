#!/bin/bash
# CS.1109 — Génère le zip à distribuer aux étudiants pour un tag.
# Usage : ./scripts/zip-starter.sh starter-s03
# Sortie : ~/cs1109_zips/<tag>.zip (exclut README/scripts/_prof via .gitattributes)
set -e
[ -n "$1" ] || { echo "Usage : $0 <tag>"; echo "Tags :"; git tag -l 'starter-*' | sed 's/^/  /'; exit 1; }
TAG="$1"
[ -d ".git" ] || { echo "ERREUR : pas un dépôt git."; exit 1; }
git rev-parse "$TAG" >/dev/null 2>&1 || { echo "ERREUR : tag $TAG inexistant."; git tag -l 'starter-*'; exit 1; }

# Génère en relatif (Git Windows n'aime pas les chemins Cygwin), puis déplace
TMP="${TAG}.zip"; rm -f "$TMP"
git archive --format=zip --output="$TMP" --prefix="${TAG}/" "$TAG"
OUT="$HOME/cs1109_zips"; mkdir -p "$OUT"; mv "$TMP" "$OUT/${TAG}.zip"

echo "Généré : $OUT/${TAG}.zip"; echo; unzip -l "$OUT/${TAG}.zip"
command -v cygpath >/dev/null 2>&1 && echo && echo "Chemin Windows : $(cygpath -w "$OUT/${TAG}.zip")"
