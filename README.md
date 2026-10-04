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
