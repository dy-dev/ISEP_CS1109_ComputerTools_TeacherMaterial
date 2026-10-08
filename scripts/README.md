# Scripts de mise à jour du dépôt Git prof
# ISEP_CS1109_ComputerTools_TeacherMaterial

## L'idée en une phrase
Le code n'est jamais écrit dans le dépôt à la main. La SOURCE DE VÉRITÉ est
`3_CODE_GIT/` (dans ce dossier de référence). Les scripts la lisent et
publient dans le dépôt. Pour changer le code : modifie `3_CODE_GIT/`, puis
relance un script.

## Mise en place (une fois)

1. Dézippe CS1109_DOSSIER_COMPLET.zip dans `~/CS1109_2026` — les scripts
   cherchent la source ici par défaut :
   `~/CS1109_2026/CS1109_Outils_Dev/3_CODE_GIT`
   (autre chemin : `CS1109_SRC=/mon/chemin/3_CODE_GIT ./scripts/xxx.sh`)
2. Clone le dépôt et copie ces scripts dedans :
       git clone git@github.com:dy-dev/ISEP_CS1109_ComputerTools_TeacherMaterial.git
       cd ISEP_CS1109_ComputerTools_TeacherMaterial
       cp -r <ce_dossier> scripts/  &&  chmod +x scripts/*.sh
3. Première publication (le dépôt contient encore les vieux runner.cpp FR) :
       ./scripts/check-chain.sh              # vérifie que la source compile et est cohérente
       ./scripts/0-archive-and-rebuild.sh    # archive l'ancien main, reconstruit un main propre

## Usage courant

    ./scripts/check-chain.sh              # AVANT de publier : compile + cohérence
    ./scripts/1-update-starter.sh s03     # republie un starter modifié
    ./scripts/2-publish-all.sh            # republie s02, s03, s04
    ./scripts/zip-starter.sh starter-s03  # le zip à mettre sur Moodle

## Ce que fait chaque script

| Script                     | Rôle                                                              | Perte de données |
|----------------------------|-------------------------------------------------------------------|------------------|
| check-chain.sh             | compile les 3 maillons, -Wall -Wextra, vérifie S3 == S4            | aucune           |
| 0-archive-and-rebuild.sh   | ancien main → main_deprecated, anciens tags → *_deprecated, puis main propre + 3 tags | **aucune** — tout est archivé |
| 1-update-starter.sh        | met à jour UN tag ; main n'avance que pour le plus récent          | aucune           |
| 2-publish-all.sh           | enchaîne 1-update-starter sur s02, s03, s04                         | aucune           |
| zip-starter.sh             | archive d'un tag → ~/cs1109_zips/, sans README/scripts prof        | aucune           |
| lib.sh                     | fonctions communes (ne pas lancer)                                  | —                |

## Pourquoi archiver plutôt que reset

`0-archive-and-rebuild.sh` NE détruit rien : l'ancien `main` devient
`main_deprecated`, les anciens tags deviennent `starter-sXX_deprecated`. Un
collègue qui avait cloné retrouve tout. Il n'y a donc aucun risque à le
lancer même si le dépôt est public ou déjà cloné.

Le script imprime à la fin le message à envoyer aux collègues :

    git fetch origin
    git branch -m main main_old_local     # garde leur copie locale
    git checkout -b main origin/main

Leurs modifications locales non poussées restent dans main_old_local.

## Le protocole du dépôt

- Un tag `starter-sXX` par point de départ. Les étudiants reçoivent le zip
  d'un tag, jamais le dépôt.
- `main` = le starter le plus récent.
- Exclus des zips (`.gitattributes` export-ignore) : README racine, scripts/,
  _prof/. Le README de `examples/split_pattern` est inclus (contenu étudiant).

## Sur Cygwin
`zip-starter.sh` génère en chemin relatif puis déplace (Git Windows ne lit pas
les chemins Cygwin). Lance les scripts depuis un terminal Cygwin ou Git Bash.
