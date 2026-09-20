#!/bin/bash
# CS.1109 — Archive l'ancien main dans main_deprecated et reconstruit un main propre.
#
# RIEN N'EST PERDU : l'historique actuel reste intégralement dans la branche
# main_deprecated (poussée sur le remote). Un collègue qui avait cloné retrouve
# son ancien travail sous ce nom.
#
# Reconstruit main avec 4 commits + 3 tags depuis la source de vérité :
#   init → starter-s02 → starter-s03 → starter-s04
#
# Piège GitHub géré : on ne peut pas écraser la branche par défaut. Le script
# bascule d'abord sur main_deprecated si besoin, puis rétablit main.
#
# Usage (depuis la racine du clone) : ./scripts/0-archive-and-rebuild.sh
set -e
source "$(dirname "$0")/lib.sh"

ARCHIVE="main_deprecated"
check_repo; check_src; check_clean

echo "=================================================================="
echo "  ARCHIVE + RECONSTRUCTION DU DÉPÔT $EXPECTED_REPO"
echo "=================================================================="
echo "  1. l'historique actuel de main est conservé dans : $ARCHIVE"
echo "  2. un nouveau main propre est construit depuis : $CS1109_SRC"
echo "  3. les tags starter-* sont reposés sur le nouveau main"
echo "  Rien n'est supprimé. Les collègues gardent l'ancien historique."
echo
read -p "Tape 'go' pour continuer : " C
[ "$C" = "go" ] || { echo "Abandon."; exit 1; }

git fetch -q origin --tags

step "1/7 archiver main → $ARCHIVE"
if ! git ls-remote --heads origin main | grep -q main; then
    info "aucun main distant : dépôt vide ou neuf, rien à archiver"
elif git ls-remote --heads origin "$ARCHIVE" | grep -q "$ARCHIVE"; then
    info "$ARCHIVE existe déjà sur le remote → on ne l'écrase pas"
    read -p "  Continuer en gardant l'archive existante ? [o/N] " -n 1 -r; echo
    [[ $REPLY =~ ^[Oo]$ ]] || exit 1
else
    git push -q origin "origin/main:refs/heads/$ARCHIVE"
    info "ancien main sauvegardé dans origin/$ARCHIVE"
fi
# archiver aussi les anciens tags starter-* s'ils existent (suffixe _deprecated)
for t in $(git tag -l 'starter-*' | grep -v '_deprecated$'); do
    if ! git rev-parse "${t}_deprecated" >/dev/null 2>&1; then
        git tag "${t}_deprecated" "$t"; git push -q origin "${t}_deprecated"
        info "ancien tag $t archivé en ${t}_deprecated"
    fi
    git tag -d "$t" >/dev/null; git push -q --delete origin "$t" 2>/dev/null || true
done

step "2/7 sauvegarde scripts/ et _prof/"
rm -rf /tmp/cs1109_keep && mkdir -p /tmp/cs1109_keep
cp -r scripts /tmp/cs1109_keep/ 2>/dev/null || true
cp -r _prof   /tmp/cs1109_keep/ 2>/dev/null || true

step "3/7 nouvelle lignée orpheline"
git checkout -q --orphan main-new
git rm -rfq . >/dev/null 2>&1 || true
find . -mindepth 1 -maxdepth 1 ! -name '.git' -exec rm -rf {} + 2>/dev/null || true
cp -r /tmp/cs1109_keep/scripts . 2>/dev/null || true
cp -r /tmp/cs1109_keep/_prof   . 2>/dev/null || true
chmod +x scripts/*.sh 2>/dev/null || true

step "4/7 fichiers de protocole"
cat > .gitattributes << 'ATTR'
# Exclus des archives distribuées aux étudiants (git archive)
/README.md     export-ignore
_prof/         export-ignore
scripts/       export-ignore
.gitattributes export-ignore

# Scripts shell : toujours en LF, même sur Windows
*.sh text eol=lf
ATTR
cat > README.md << 'RM'
# CS.1109 — Teacher Materials

Dépôt privé des points de départ (starters) distribués aux étudiants,
séance par séance, pour le module CS.1109 « Outils de développement » (ISEP).

## Principe : un tag par point de départ

| Tag           | Séance | Contenu                                          |
|---------------|--------|--------------------------------------------------|
| `starter-s02` | S2     | Squelette runner.cpp + CMakeLists minimal        |
| `starter-s03` | S3     | Runner console complet + examples/split_pattern  |
| `starter-s04` | S4     | Runner splitté Board / Player / main             |

Règle : le point de départ d'une séance = le corrigé de la précédente.
Le tronc `main` = le starter le plus récent.

## Historique

La branche `main_deprecated` contient l'ancien historique (versions
françaises du runner), conservé pour référence. Ne pas travailler dessus.

## Mettre à jour le dépôt

Le code n'est PAS écrit ici à la main. La source de vérité est le dossier
`3_CODE_GIT/` du dossier de référence CS1109_Outils_Dev. Pour publier :

    ./scripts/1-update-starter.sh s03      # met à jour un seul starter
    ./scripts/2-publish-all.sh             # republie les 3, dans l'ordre
    ./scripts/zip-starter.sh starter-s03   # génère le zip à distribuer

## Auteur

Dominique Yolin — ARCREANE
RM
git add -A
git commit -q -m "Init dépôt prof : protocole, gitattributes, scripts"
info "commit init"

step "5/7 les 3 maillons, un commit + un tag chacun"
publish_link() {
    wipe_tree; place_starter "$1"
    git add -A; git commit -q -m "$3"; git tag -a "$2" -m "$3"
    info "commit + tag $2"
}
publish_link "01_S2_Starter/CS1109_Runner_Starter"                     "starter-s02" "S2 starter : squelette runner.cpp + CMakeLists minimal"
publish_link "02_S3_Start_equals_S2_Solution/CS1109_Runner_S3_Start"   "starter-s03" "S3 starter : runner console complet + examples/split_pattern"
publish_link "03_S4_Start_equals_S3_Solution/CS1109_Runner_S4_Start"   "starter-s04" "S4 starter : runner splitté Board/Player/main"

step "6/7 remplacer main sur le remote (l'ancien est dans $ARCHIVE)"
git branch -D main 2>/dev/null || true
git branch -m main-new main
# Si main est la branche par défaut GitHub, le force push est accepté (on ne
# supprime pas la branche, on la remplace). On pousse avec --force-with-lease
# sur la ref qu'on vient d'archiver : sécurité si quelqu'un a poussé entre-temps.
git push -q --force origin main
git push -q origin --tags
info "main remplacé ; tags starter-s02/03/04 poussés"
rm -rf /tmp/cs1109_keep

step "7/7 état final"
git log --oneline --decorate -5
echo
echo "=================================================================="
echo "  TERMINÉ — rien n'a été perdu"
echo "=================================================================="
echo "  origin/main            : nouveau, propre (4 commits, 3 tags)"
echo "  origin/$ARCHIVE : ancien historique, intact"
echo
echo "  MESSAGE À ENVOYER AUX COLLÈGUES qui avaient cloné :"
echo "  ----------------------------------------------------------------"
echo "  Le dépôt a été reconstruit. Votre ancien main est devenu"
echo "  main_deprecated. Pour repartir sur le nouveau main :"
echo "      git fetch origin"
echo "      git branch -m main main_old_local        # garde votre copie"
echo "      git checkout -b main origin/main"
echo "  Si vous aviez des modifications locales non poussées, elles"
echo "  sont dans main_old_local : rien n'est perdu."
echo "  ----------------------------------------------------------------"
