#!/bin/bash
# CS.1109 — lanceur unique. À exécuter depuis N'IMPORTE OÙ, y compris le
# dossier de référence : il se charge de tout.
#
#   cs1109.sh check            vérifie la chaîne (builds + tests)
#   cs1109.sh check --quick    vérifie sans les builds Raylib (~10 s)
#   cs1109.sh publish          vérifie PUIS publie les 9 tags
#   cs1109.sh rebuild          archive l'ancien main et reconstruit (1re fois)
#   cs1109.sh zip starter-s06  génère le zip étudiant d'un tag
#   cs1109.sh status           état du dépôt et des tags
#
# Il fait à chaque fois, sans qu'on ait à y penser :
#   - retrouve le dossier de référence et le dépôt cloné ;
#   - recopie les scripts du dossier de référence vers le clone (le clone n'est
#     jamais la source : le dossier de référence l'est) ;
#   - purge les caches CMake pollués avant une vérification ;
#   - exporte CS1109_SRC.
set -e

# --- où sont les choses -----------------------------------------------------
# Surchargeable : CS1109_REF=... CS1109_REPO=... cs1109.sh ...
# Par défaut, le dossier de référence est celui qui contient ce script.
HERE="$(cd "$(dirname "$0")" && pwd)"
CS1109_REF="${CS1109_REF:-$(cd "$HERE/../.." && pwd)}"      # …/CS1109_Outils_Dev
CS1109_REPO="${CS1109_REPO:-/cygdrive/c/tmp/ISEP_CS1109_ComputerTools_TeacherMaterial}"
export CS1109_SRC="${CS1109_SRC:-$CS1109_REF/3_CODE_GIT}"

die() { echo "ERREUR : $*" >&2; exit 1; }
say() { echo "  $*"; }
usage() { sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit "${1:-0}"; }

CMD="${1:-}"; shift 2>/dev/null || true
case "$CMD" in ""|-h|--help|help) usage ;; esac
case "$CMD" in check|publish|rebuild|zip|status) ;; *) echo "commande inconnue : $CMD"; echo; usage 1 ;; esac

[ -d "$CS1109_SRC" ] || die "source de vérité introuvable : $CS1109_SRC
  Lance avec : CS1109_REF=/cygdrive/x $0 $*"
[ -d "$CS1109_REPO/.git" ] || die "dépôt introuvable : $CS1109_REPO
  Clone-le d'abord :
    cd /cygdrive/c/tmp && git clone <url> ISEP_CS1109_ComputerTools_TeacherMaterial
  ou lance avec : CS1109_REPO=/chemin/vers/le/clone $0 $*"

# --- les scripts du clone viennent TOUJOURS du dossier de référence ---------
sync_scripts() {
    rm -rf "$CS1109_REPO/scripts"
    cp -r "$CS1109_REF/2_PROFS/Scripts_Git" "$CS1109_REPO/scripts"
    chmod +x "$CS1109_REPO/scripts/"*.sh
    say "scripts synchronisés depuis $CS1109_REF/2_PROFS/Scripts_Git"
}

purge_cache() {
    local d
    if [ -d /cygdrive/c/tmp/cs1109_check ]; then d=/cygdrive/c/tmp/cs1109_check; else d="${TMPDIR:-/tmp}/cs1109_check"; fi
    rm -rf "$d"; say "caches CMake purgés ($d)"
}

case "$CMD" in
  check)
      sync_scripts; [ "$1" = "--quick" ] || purge_cache
      cd "$CS1109_REPO"; ./scripts/check-chain.sh "$@" ;;
  publish)
      sync_scripts; purge_cache
      cd "$CS1109_REPO"
      ./scripts/check-chain.sh || die "chaîne invalide : rien n'a été publié."
      ./scripts/2-publish-all.sh
      echo; say "pense à vérifier les tags sur GitHub (onglet Tags)." ;;
  rebuild)
      sync_scripts; purge_cache
      cd "$CS1109_REPO"
      ./scripts/check-chain.sh || die "chaîne invalide : rien n'a été reconstruit."
      ./scripts/0-archive-and-rebuild.sh ;;
  zip)
      [ -n "$1" ] || die "usage : $0 zip starter-s06"
      sync_scripts; cd "$CS1109_REPO"; ./scripts/zip-starter.sh "$1" ;;
  status)
      cd "$CS1109_REPO"
      say "dépôt     : $CS1109_REPO"
      say "référence : $CS1109_REF"
      say "branche   : $(git rev-parse --abbrev-ref HEAD) — $(git log -1 --format='%h %s')"
      echo; echo "  tags publiés :"; git tag -l 'starter-*' 'final' | grep -v '_deprecated$' | sed 's/^/    /'
      echo; echo "  tags archivés :"; git tag -l '*_deprecated' | sed 's/^/    /' ;;
esac
