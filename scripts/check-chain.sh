#!/bin/bash
# CS.1109 — Vérifie la chaîne code AVANT de publier :
#   - chaque maillon configure et compile (cmake) ;
#   - les sources propres au projet compilent sans warning (-Wall -Wextra) ;
#   - le monolithe S3 et le splitté S4 ont le même comportement ;
#   - les tests Catch2 passent, de la S06 au maillon final.
#
# Poste Windows + Cygwin : cmake et git sont des binaires Windows. Les builds se
# font sous C:\tmp\cs1109_check (un sous-dossier par maillon) et les chemins
# passés à cmake sont convertis par cygpath. Ne jamais builder sous le home
# Cygwin : cmake Windows n'a pas les droits d'y écrire.
#
# Usage : ./scripts/check-chain.sh            (ne touche pas au dépôt git)
#         ./scripts/check-chain.sh --quick    (saute les maillons Raylib, ~10 s)
set -e
source "$(dirname "$0")/lib.sh"
check_src
command -v cmake >/dev/null || die "cmake introuvable"
command -v g++   >/dev/null || die "g++ introuvable"

QUICK=0; [ "$1" = "--quick" ] && QUICK=1
ensure_writable "$CS1109_SRC"
ROOT="$(check_root)"
GEN="$(pick_generator)"
CC_OPTS="$(pick_compiler)"
MINGW_BIN="$(mingw_bin)"
if [ "$CC_OPTS" = "AUCUN" ]; then
    CC_OPTS=""
    is_cygwin && info "ATTENTION : aucun MinGW Windows trouvé. cmake va prendre le gcc de Cygwin, que ninja Windows ne peut pas lancer. Installe CLion (MinGW fourni) ou mets un gcc Windows dans le PATH."
fi
info "builds de vérification sous : $ROOT"
[ -n "$GEN" ] && info "générateur : Ninja" || info "générateur : défaut (multi-configuration)"
[ -n "$CC_OPTS" ] && info "compilateur imposé : MinGW (pas le gcc de Cygwin)"
[ -n "$MINGW_BIN" ] && info "DLL d'exécution MinGW : $MINGW_BIN"
ok=1

# --- maillons console : compilation directe g++, warnings bloquants ----------
console_build() {   # <dossier> <label> <fichiers g++...>
    local d="$CS1109_SRC/$1" lbl="$2"; shift 2
    step "$lbl"
    local log="$ROOT/$lbl.log"
    ( cd "$d" && g++ -std=c++17 -Wall -Wextra "$@" -o "$ROOT/$lbl" ) 2>"$log" \
        && { [ -s "$log" ] && { info "warnings :"; show_tail "$log"; ok=0; } || info "g++ -Wall -Wextra : OK"; } \
        || { info "g++ : ÉCHEC"; show_tail "$log"; ok=0; }
}
console_build "01_S2_Starter/CS1109_Runner_Starter"                   S2 runner.cpp
console_build "02_S3_Start_equals_S2_Solution/CS1109_Runner_S3_Start" S3 runner.cpp
console_build "03_S4_Start_equals_S3_Solution/CS1109_Runner_S4_Start" S4 -Iinclude src/main.cpp src/Board.cpp src/Player.cpp

step "cohérence : S3 (monolithe) == S4 (splitté) ?"
printf 'q\n' | "$ROOT/S3" > "$ROOT/o3" 2>&1 || true
printf 'q\n' | "$ROOT/S4" > "$ROOT/o4" 2>&1 || true
if diff -q "$ROOT/o3" "$ROOT/o4" >/dev/null; then
    info "sorties identiques : le split ne change rien"
else
    info "SORTIES DIFFÉRENTES — régression dans le split :"; diff "$ROOT/o3" "$ROOT/o4" | head; ok=0
fi

# --- maillons Raylib : configure + build cmake, puis tests quand ils existent -
raylib_build() {   # <dossier> <label> <tests:0|1>
    local d="$CS1109_SRC/$1" lbl="$2" wants_tests="$3"
    step "$lbl"
    if [ $QUICK = 1 ]; then info "(--quick : build Raylib sauté)"; return; fi
    local b="$ROOT/$lbl" log="$ROOT/$lbl.log"
    rm -rf "$b"; mkdir -p "$b"
    ( cd "$d" && cmake -B "$(winpath "$b")" -S "$(winpath "$PWD")" $GEN $CC_OPTS -DCMAKE_BUILD_TYPE=Release >"$log" 2>&1 \
               && cmake --build "$(winpath "$b")" --config Release --parallel >>"$log" 2>&1 ) \
        && info "cmake configure + build : OK" || { info "cmake : ÉCHEC"; show_tail "$log"; ok=0; return; }
    if [ "$wants_tests" = 1 ]; then
        local tbin; tbin="$(find_built "$b" runner_tests)"
        if [ -n "$tbin" ] && [ -x "$tbin" ]; then
            ( PATH="${MINGW_BIN:+$MINGW_BIN:}$PATH" "$tbin" >"$ROOT/$lbl.tests" 2>&1 ) \
                && info "tests Catch2 : $(grep -E 'All tests passed' "$ROOT/$lbl.tests" | head -1)" \
                || { info "tests Catch2 : ÉCHEC"; show_tail "$ROOT/$lbl.tests"; ok=0; }
        else
            info "runner_tests introuvable dans $b (ni à la racine, ni dans Debug/ ou Release/)"; ok=0
        fi
    fi
}
raylib_build "04_S5_Start_equals_S4_Solution/CS1109_Runner_S5_Start"  S05 0
raylib_build "05_S6_Start_equals_S5_Solution/CS1109_Runner_S6_Start"  S06 0
raylib_build "05b_S6_Starter_with_bugs/CS1109_Runner_S6_Start"        S06b 0
raylib_build "06_S7_Start_equals_S6_Solution/CS1109_Runner_S7_Start"  S07 1
raylib_build "07_S8_Start_equals_S7_Solution/CS1109_Runner_S8_Start"  S08 1
raylib_build "08_S9_Start_equals_S8_Solution/CS1109_Runner_S9_Start"  S09 1
raylib_build "09_Final_equals_S9_Solution/CS1109_Runner_Final"        FINAL 1

# --- cohérences transverses --------------------------------------------------
step "mécanique de saut : gravité partout, plus de compteur"
if grep -rq "jumpTimer\|JUMP_DURATION\|isInAir" "$CS1109_SRC" --include=*.cpp --include=*.h; then
    info "RESTE du saut par compteur :"; grep -rn "jumpTimer\|JUMP_DURATION\|isInAir" "$CS1109_SRC" --include=*.cpp --include=*.h | head; ok=0
else
    info "aucun jumpTimer / JUMP_DURATION / isInAir"
fi

step "starter S6 : les 3 bugs sont bien en place"
B="$CS1109_SRC/05b_S6_Starter_with_bugs/CS1109_Runner_S6_Start"
grep -q "m_x -= SPEED;"            "$B/src/Obstacle.cpp" && info "bug 1 (obstacle sans * dt) présent"      || { info "bug 1 ABSENT"; ok=0; }
grep -q "m_velocityY -= GRAVITY"   "$B/src/Player.cpp"   && info "bug 2 (gravité inversée) présent"        || { info "bug 2 ABSENT"; ok=0; }
grep -q "cooldown active: ignore"  "$B/src/main.cpp"     && info "bug 3 (hitCooldown figé) présent"        || { info "bug 3 ABSENT"; ok=0; }

echo
[ $ok = 1 ] && echo "CHAÎNE OK — tu peux publier." || die "chaîne INVALIDE — ne publie pas."
