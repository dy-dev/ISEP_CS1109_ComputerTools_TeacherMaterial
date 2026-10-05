#!/bin/bash
# Fonctions communes aux scripts CS.1109. À sourcer, pas à exécuter.

EXPECTED_REPO="ISEP_CS1109_ComputerTools_TeacherMaterial"

# Dossier source de vérité : la chaîne code (3_CODE_GIT du dossier de référence).
# Surchargeable : CS1109_SRC=/chemin/vers/3_CODE_GIT ./scripts/xxx.sh
CS1109_SRC="${CS1109_SRC:-$HOME/CS1109_2026/CS1109_Outils_Dev/3_CODE_GIT}"

die() { echo "ERREUR : $*" >&2; exit 1; }

# --- poste Windows + shell Cygwin -------------------------------------------
# cmake et git sont des binaires WINDOWS : ils ne comprennent pas les chemins
# Cygwin (/home/..., /tmp/...). Deux conséquences, traitées ici :
#   - tout chemin passé à cmake doit être converti par cygpath -w ;
#   - les builds de vérification se font sous C:\tmp\cs1109_check, jamais sous
#     le home Cygwin (cmake Windows n'a pas les droits ACL d'y écrire) ni sous
#     un /tmp Cygwin (qui ne désigne pas le même dossier que C:\tmp).
is_cygwin() { case "$(uname -s)" in CYGWIN*|MINGW*|MSYS*) return 0;; *) return 1;; esac; }

# Convertit un chemin pour un outil Windows ; sans effet ailleurs.
winpath() { if is_cygwin; then cygpath -w "$1"; else echo "$1"; fi; }

# Racine des builds de vérification, un sous-dossier par maillon.
check_root() {
    if is_cygwin; then
        mkdir -p /cygdrive/c/tmp/cs1109_check
        echo "/cygdrive/c/tmp/cs1109_check"
    else
        mkdir -p "${TMPDIR:-/tmp}/cs1109_check"
        echo "${TMPDIR:-/tmp}/cs1109_check"
    fi
}

# Les dossiers synchronisés par OneDrive arrivent en lecture seule : sans ça,
# l'archivage et les copies échouent avec "Permission denied".
ensure_writable() { chmod -R u+w "$1" 2>/dev/null || true; }

# Générateur : on force Ninja quand il est disponible (mono-configuration, le
# binaire atterrit à la racine du dossier de build). Sans Ninja, cmake choisit
# Visual Studio, qui est multi-configuration et place les binaires dans un
# sous-dossier Debug/ ou Release/ — d'où find_built ci-dessous.
# Ninja est cherché dans le PATH, puis dans les installations CLion usuelles.
pick_generator() {
    if command -v ninja >/dev/null 2>&1; then echo "-G Ninja"; return; fi
    for c in "$LOCALAPPDATA/Programs/CLion/bin/ninja/win/x64/ninja.exe" \
             "/cygdrive/c/Users/$USER/AppData/Local/Programs/CLion/bin/ninja/win/x64/ninja.exe" \
             "/cygdrive/c/Program Files/JetBrains/CLion/bin/ninja/win/x64/ninja.exe"; do
        [ -x "$c" ] && { echo "-G Ninja -DCMAKE_MAKE_PROGRAM=$(winpath "$c")"; return; }
    done
    echo ""   # pas de Ninja : générateur par défaut
}

# Compilateur : sous Cygwin, cmake trouve d'abord /usr/bin/cc (le gcc Cygwin).
# C'est un lien symbolique que le ninja Windows ne sait pas lancer : la
# configuration meurt sur « CreateProcess: Access is denied ». On impose donc
# un compilateur Windows — le MinGW livré avec CLion, ou celui du PATH.
pick_compiler() {
    is_cygwin || return 0
    local c
    for c in "$LOCALAPPDATA/Programs/CLion/bin/mingw/bin" \
             "/cygdrive/c/Users/$USER/AppData/Local/Programs/CLion/bin/mingw/bin" \
             "/cygdrive/c/Program Files/JetBrains/CLion/bin/mingw/bin" \
             "/cygdrive/c/mingw64/bin" "/cygdrive/c/msys64/mingw64/bin"; do
        if [ -x "$c/gcc.exe" ] && [ -x "$c/g++.exe" ]; then
            echo "-DCMAKE_C_COMPILER=$(winpath "$c/gcc.exe") -DCMAKE_CXX_COMPILER=$(winpath "$c/g++.exe")"
            return 0
        fi
    done
    echo "AUCUN"   # signalé par check-chain : rien à proposer
}

# Dossier bin du MinGW retenu (vide hors Cygwin). Un exécutable produit par
# MinGW a besoin de ses DLL d'exécution (libstdc++-6, libgcc_s_seh-1,
# libwinpthread-1) : sans ce dossier dans le PATH, il meurt au démarrage sans
# rien afficher — un log de test vide est le symptôme.
mingw_bin() {
    is_cygwin || return 0
    local c
    for c in "$LOCALAPPDATA/Programs/CLion/bin/mingw/bin" \
             "/cygdrive/c/Users/$USER/AppData/Local/Programs/CLion/bin/mingw/bin" \
             "/cygdrive/c/Program Files/JetBrains/CLion/bin/mingw/bin" \
             "/cygdrive/c/mingw64/bin" "/cygdrive/c/msys64/mingw64/bin"; do
        [ -x "$c/g++.exe" ] && { echo "$c"; return 0; }
    done
}

# Retrouve un exécutable dans un dossier de build, quel que soit le générateur
# (racine avec Ninja/Make, sous-dossier Debug|Release avec Visual Studio).
find_built() {   # <dossier_build> <nom_sans_extension>
    local b="$1" n="$2"
    for p in "$b/$n" "$b/$n.exe" "$b/Debug/$n.exe" "$b/Release/$n.exe" "$b/Debug/$n" "$b/Release/$n"; do
        [ -x "$p" ] && { echo "$p"; return 0; }
    done
    find "$b" -maxdepth 2 -name "$n" -o -maxdepth 2 -name "$n.exe" 2>/dev/null | head -1
}

# Les 15 dernières lignes d'un log de build raté : de quoi diagnostiquer sans
# ouvrir le fichier.
show_tail() {
    if [ ! -s "$1" ]; then
        echo "  --- $1 est VIDE : le programme n'a produit aucune sortie."
        echo "      Cause la plus fréquente sous Windows : les DLL d'exécution de MinGW"
        echo "      (libstdc++-6.dll, libgcc_s_seh-1.dll, libwinpthread-1.dll) ne sont pas"
        echo "      dans le PATH. Vérifier que mingw_bin() trouve bien le MinGW de CLion."
        return
    fi
    echo "  --- 15 dernières lignes de $1 ---"; tail -15 "$1" | sed 's/^/  /'
}
info() { echo "  $*"; }
step() { echo; echo "=== $* ==="; }

# Fins de ligne : Git for Windows convertit LF→CRLF par défaut (core.autocrlf).
# Conséquence ici : la source est comparée à un tag converti, donc tout paraît
# différent, puis le commit ne trouve rien à committer. On désactive la
# conversion sur CE dépôt, sans toucher à la configuration globale.
fix_eol_config() {
    git config core.autocrlf false
    git config core.eol lf
}

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
    # scripts/ est resynchronisé depuis le dossier de référence à chaque appel :
    # ses modifications sont attendues et ne doivent pas bloquer une publication.
    local dirty
    dirty="$(git status --porcelain --untracked-files=no | grep -v ' scripts/' || true)"
    if [ -n "$dirty" ]; then
        echo "Le dépôt a des modifications non commitées :"; echo "$dirty"
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
