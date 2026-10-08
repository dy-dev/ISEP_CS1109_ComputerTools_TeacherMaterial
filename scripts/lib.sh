#!/bin/bash
# Fonctions communes aux scripts CS.1109. À sourcer, pas à exécuter.

EXPECTED_REPO="ISEP_CS1109_ComputerTools_TeacherMaterial"

# Dossier source de vérité : la chaîne code (3_CODE_GIT du dossier de référence).
# Surchargeable : CS1109_SRC=/chemin/vers/3_CODE_GIT ./scripts/xxx.sh
CS1109_SRC="${CS1109_SRC:-$HOME/CS1109_2026/CS1109_Outils_Dev/3_CODE_GIT}"

die() { echo "ERREUR : $*" >&2; exit 1; }
info() { echo "  $*"; }
step() { echo; echo "=== $* ==="; }

check_repo() {
    [ -d ".git" ] || die "ce dossier n'est pas un dépôt git. Place-toi à la racine du clone."
    local name; name=$(basename "$(pwd)")
    if [ "$name" != "$EXPECTED_REPO" ]; then
        echo "AVERTISSEMENT : dossier '$name' (attendu : '$EXPECTED_REPO')."
        read -p "Continuer ? [o/N] " -n 1 -r; echo
        [[ $REPLY =~ ^[Oo]$ ]] || exit 1
    fi
}

check_src() {
    [ -d "$CS1109_SRC" ] || die "source de vérité introuvable : $CS1109_SRC
  Dézippe CS1109_DOSSIER_COMPLET.zip dans ~/CS1109_2026, ou lance avec :
  CS1109_SRC=/chemin/vers/3_CODE_GIT $0"
    info "source de vérité : $CS1109_SRC"
}

check_clean() {
    # Seuls les fichiers TRACKÉS modifiés bloquent. Les fichiers non-trackés
    # (ex. scripts/ fraîchement copié) sont normaux à la première utilisation.
    if [ -n "$(git status --porcelain --untracked-files=no)" ]; then
        echo "Le dépôt a des modifications non commitées :"; git status --short --untracked-files=no
        read -p "Continuer quand même ? [o/N] " -n 1 -r; echo
        [[ $REPLY =~ ^[Oo]$ ]] || exit 1
    fi
}

# Vide l'arbre de travail SAUF .git, scripts/, _prof/, .gitattributes, README.md
wipe_tree() {
    find . -mindepth 1 -maxdepth 1 \
        ! -name '.git' ! -name 'scripts' ! -name '_prof' \
        ! -name '.gitattributes' ! -name 'README.md' \
        -exec rm -rf {} + 2>/dev/null || true
}

# Copie un maillon (dossier source) dans l'arbre de travail
# usage: place_starter <dossier_source_relatif_a_CS1109_SRC>
place_starter() {
    local src="$CS1109_SRC/$1"
    [ -d "$src" ] || die "maillon introuvable : $src"
    # copie tout SAUF le README.md racine du maillon : dans le repo, le README
    # racine est celui du protocole prof (export-ignore), pas celui du starter.
    (cd "$src" && tar --exclude='./README.md' --exclude='./build' \
        --exclude='./cmake-build-*' --exclude='./.idea' -cf - .) | tar -xf -
    info "placé : $1"
}

# Pose (ou remplace) un tag et le pousse
retag() {
    local tag="$1"
    if git rev-parse "$tag" >/dev/null 2>&1; then
        info "tag $tag existe → remplacement"
        git tag -d "$tag" >/dev/null
        git push --delete origin "$tag" 2>/dev/null || true
    fi
    git tag -a "$tag" -m "$2" ${3:+"$3"}
    git push origin "$tag"
    info "tag $tag posé et poussé"
}
