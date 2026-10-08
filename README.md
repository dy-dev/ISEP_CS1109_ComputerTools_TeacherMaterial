# CS.1109 — Teacher Materials

Dépôt privé des points de départ (starters) distribués aux étudiants,
séance par séance, pour le module CS.1109 « Outils de développement » (ISEP).

## Principe : un tag par point de départ

| Tag           | Séance | Contenu                                          |
|---------------|--------|--------------------------------------------------|
| `starter-s02` | S2     | Squelette runner.cpp + CMakeLists minimal        |
| `starter-s03` | S3     | Runner console complet + examples/split_pattern  |
| `starter-s04` | S4     | Runner splitté Board / Player / main             |
| `starter-s05` | S5     | Runner Raylib : fenêtre, saut, obstacles, HUD    |
| `solution-s05`| —      | Corrigé S5 propre (POO). Aucune séance n'en part |
| `starter-s06` | S6     | Runner POO avec 3 bugs plantés (à déboguer)      |
| `starter-s07` | S7     | Runner POO corrigé + tests Catch2                |
| `starter-s08` | S8     | + Dockerfile multi-stage (tests en conteneur)    |
| `starter-s09` | S9     | + workflow GitHub Actions + badge                |
| `final`       | S10    | Projet finalisé : clang-format, build.sh, README, soutenance.md |
| `bonus-s05`   | —      | Bonus facultatif S5 : sprites et décor parallaxe. Greffé sur `solution-s05`, hors chaîne |

## L'historique raconte le cours

Les commits forment une ligne, chaque maillon greffé sur le précédent. On peut
donc lire ce qu'une séance ajoute :

    git log --oneline --graph
    git diff starter-s05 solution-s05     # ce que la POO change
    git diff solution-s05 starter-s06     # les 3 bugs plantés, 3 lignes
    git diff solution-s05 bonus-s05       # le bonus : seulement draw() et le décor

Règle : le point de départ d'une séance = le corrigé de la précédente.
Exception S6 : le starter est le corrigé S5 dans lequel 3 bugs ont été plantés
(le corrigé S5 sans bugs est 05_, le starter distribué est 05b_).
Le tronc `main` = le starter le plus récent.

## Historique

La branche `main_deprecated` contient l'ancien historique (versions
françaises du runner), conservé pour référence. Ne pas travailler dessus.

## Mettre à jour le dépôt

Le code n'est PAS écrit ici à la main. La source de vérité est le dossier
`3_CODE_GIT/` du dossier de référence CS1109_Outils_Dev. Pour publier :

    cs1109 publish              # vérifie la chaîne puis republie tout, dans l'ordre
    cs1109 zip starter-s03      # génère le zip à distribuer

Republier un seul maillon casse la linéarité des suivants : après avoir modifié
un maillon, relancer la publication complète.

## Auteur

Dominique Yolin — ARCREANE
