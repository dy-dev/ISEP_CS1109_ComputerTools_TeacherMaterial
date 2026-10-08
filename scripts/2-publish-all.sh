#!/bin/bash
# CS.1109 — Republie les 3 starters (s02, s03, s04) depuis la source de vérité.
# Sans réécriture d'historique : 1 commit + 1 tag par maillon si ça a changé.
# Usage : ./scripts/2-publish-all.sh
set -e
D="$(dirname "$0")"
for s in s02 s03 s04; do
    "$D/1-update-starter.sh" "$s"
done
echo; echo "Les 3 starters sont publiés. Tags :"; git tag -l 'starter-*'
