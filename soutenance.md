# Soutenance CS.1109 — plan et répartition

Durée : 20 minutes. Quatre blocs de cinq minutes. Un membre par bloc, les
autres prêts à compléter. Le git log est ouvert dans un onglet : chaque
membre doit pouvoir expliquer ses commits.

## 0–5 min — Démonstration          ·  <Nom>
- Lancer `./build/runner` depuis un terminal (pas depuis l'IDE).
- Montrer : le saut, une collision, le compteur de vies, le game over.
- Secours : la vidéo `demo.mp4` si la machine refuse d'ouvrir la fenêtre.

## 5–10 min — Architecture          ·  <Nom>
- Schéma au tableau ou slide : GameObject → Player / Obstacle ; main tient
  un vector<unique_ptr<GameObject>>.
- Pourquoi runner_core est séparé de main : les tests, Docker.
- Un aller-retour dans le code : Player::update, puis le test qui le couvre.

## 10–15 min — Retour d'expérience  ·  <Nom>
- Le conflit de la S3 et comment on l'a résolu.
- Les trois bugs de la S6 : lequel a pris le plus de temps, et pourquoi.
- Ce qu'on ferait autrement avec deux semaines de plus.

## 15–20 min — Questions            ·  Tous
Trois questions qu'on a préparées :
1. Pourquoi une hiérarchie GameObject plutôt que deux vectors séparés ?
2. Que se passe-t-il si on retire `* dt` dans Obstacle::update — et quel test
   le voit ?
3. Comment la CI garantit-elle qu'un merge ne casse pas main ?

## Avant le jour J
- [ ] `./build.sh` passe sur la machine de démo, depuis un clone frais.
- [ ] `demo.mp4` enregistrée (30 s).
- [ ] Badge CI vert sur main.
- [ ] Chacun a relu le git log et sait défendre ses commits.
