#!/bin/bash
# CS.1109 — Vérifie la chaîne code AVANT de publier :
#   chaque maillon compile (cmake), sans warning (-Wall -Wextra),
#   et le monolithe S3 == le splitté S4 en comportement.
# Usage : ./scripts/check-chain.sh   (ne touche pas au dépôt git)
#
# Cygwin : cmake est le binaire Windows. Il n'écrit pas dans le home Cygwin
# (ACL) et ne lit pas les chemins /cygdrive. On construit donc sous C:\tmp,
# un dossier par maillon, avec les chemins convertis par cygpath.
set -e
source "$(dirname "$0")/lib.sh"
check_src
command -v cmake >/dev/null || die "cmake introuvable"
command -v g++   >/dev/null || die "g++ introuvable"

T=$(mktemp -d)

if command -v cygpath >/dev/null 2>&1; then
    BROOT="/cygdrive/c/tmp/cs1109_check"
    native() { cygpath -w "$1"; }
    info "cmake Windows détecté : build sous C:\\tmp\\cs1109_check"
else
    BROOT="$T/builds"
    native() { printf '%s' "$1"; }
fi
mkdir -p "$BROOT"
trap 'rm -rf "$T" "$BROOT"' EXIT

ok=1

build() {  # <dossier> <label> <fichiers_pour_g++...>
    local d="$CS1109_SRC/$1" lbl="$2"; shift 2
    step "$lbl"

    # --- cmake : un dossier de build distinct par maillon ---
    local bu="$BROOT/$lbl"
    rm -rf "$bu"; mkdir -p "$bu"
    local bn sn
    bn=$(native "$bu")
    sn=$(native "$d")
    ( cmake -B "$bn" -S "$sn" >"$T/cm.txt" 2>&1 \
      && cmake --build "$bn" >>"$T/cm.txt" 2>&1 ) \
        && info "cmake : OK" \
        || { info "cmake : ÉCHEC"; sed 's/^/      /' "$T/cm.txt" | tail -15; ok=0; }
    rm -rf "$bu"

    # --- g++ direct : contrôle des warnings ---
    ( cd "$d" && g++ -std=c++17 -Wall -Wextra "$@" -o "$T/$lbl" 2>"$T/w.txt" ) \
        && { [ -s "$T/w.txt" ] && { info "warnings :"; cat "$T/w.txt"; ok=0; } || info "-Wall -Wextra : OK"; } \
        || { info "g++ : ÉCHEC"; cat "$T/w.txt"; ok=0; }
}

build "01_S2_Starter/CS1109_Runner_Starter"                   S2 runner.cpp
build "02_S3_Start_equals_S2_Solution/CS1109_Runner_S3_Start" S3 runner.cpp
build "03_S4_Start_equals_S3_Solution/CS1109_Runner_S4_Start" S4 -Iinclude src/main.cpp src/Board.cpp src/Player.cpp

step "cohérence : S3 (monolithe) == S4 (splitté) ?"
printf 'q\n' | "$T/S3" > "$T/o3" 2>&1 || true
printf 'q\n' | "$T/S4" > "$T/o4" 2>&1 || true
if diff -q "$T/o3" "$T/o4" >/dev/null; then
    info "sorties identiques : le split ne change rien ✔"
else
    info "SORTIES DIFFÉRENTES — régression dans le split :"
    diff "$T/o3" "$T/o4" | head
    ok=0
fi

echo
[ $ok = 1 ] && echo "CHAÎNE OK — tu peux publier." || die "chaîne INVALIDE — ne publie pas."
