#!/bin/bash
# CS.1109 — Met à jour UN starter depuis la source de vérité et repose son tag.
#
# Usage : ./scripts/1-update-starter.sh s02|s03|s04
#
# Conception : chaque tag starter-sXX est un instantané indépendant. Ce script
# compare la SOURCE au contenu du TAG existant (pas à main). S'il y a une
# différence, il crée un commit portant le nouveau contenu, y pose le tag, et
# ne fait avancer `main` QUE si c'est le starter le plus récent (s04).
# Sans réécriture d'historique : usage courant, sans danger.
set -e
source "$(dirname "$0")/lib.sh"

S="$1"
case "$S" in
  s02) SRC="01_S2_Starter/CS1109_Runner_Starter";                    MSG="S2 starter : squelette runner.cpp + CMakeLists minimal";;
  s03) SRC="02_S3_Start_equals_S2_Solution/CS1109_Runner_S3_Start";  MSG="S3 starter : runner console complet + examples/split_pattern";;
  s04) SRC="03_S4_Start_equals_S3_Solution/CS1109_Runner_S4_Start";  MSG="S4 starter : runner splitté Board/Player/main";;
  *) echo "Usage : $0 s02|s03|s04"; exit 1;;
esac
TAG="starter-$S"; LATEST="s04"

check_repo; check_src; check_clean
git fetch -q origin --tags

step "compare la source au tag $TAG"
# Exporte le contenu du tag (hors fichiers de protocole) pour le comparer à la source
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
if git rev-parse "$TAG" >/dev/null 2>&1; then
    git archive "$TAG" | tar -x -C "$T"
    # même exclusions que .gitattributes pour comparer à armes égales
    # copie de la source sans son README racine (même règle que place_starter)
    S2=$(mktemp -d)
    (cd "$CS1109_SRC/$SRC" && tar --exclude='./README.md' --exclude='./build' \
        --exclude='./cmake-build-*' --exclude='./.idea' -cf - .) | tar -xf - -C "$S2"
    if diff -rq "$T" "$S2" >/dev/null 2>&1; then
        info "aucun changement : $TAG est déjà à jour"
        rm -rf "$S2"; exit 0
    fi
    info "différences détectées → nouveau contenu pour $TAG"
    diff -rq "$T" "$S2" | sed 's/^/    /' || true
    rm -rf "$S2"
else
    info "tag $TAG absent → création"
fi

step "commit du nouveau contenu (branche de travail temporaire)"
# Part du commit du tag s'il existe (garde la lignée), sinon de main
BASE=$(git rev-parse "$TAG" 2>/dev/null || git rev-parse main)
git checkout -q -b "upd-$S" "$BASE"
wipe_tree
place_starter "$SRC"
git add -A
git commit -q -m "$MSG (mise à jour)"
NEW=$(git rev-parse HEAD)
git checkout -q main
git branch -D "upd-$S" >/dev/null

step "tag $TAG → $NEW"
retag "$TAG" "$MSG" "$NEW"

if [ "$S" = "$LATEST" ]; then
    step "$TAG est le starter le plus récent → main avance"
    git reset -q --hard "$NEW"
    git push -q origin main
    info "main = $TAG"
else
    info "main inchangé ($TAG n'est pas le plus récent)"
fi

echo; git log --oneline --decorate -4
echo; echo "Zip à distribuer : ./scripts/zip-starter.sh $TAG"
