#!/bin/bash
# CS.1109 — Republie les 9 tags (s02…s09 + final) depuis la source de vérité.
# Sans réécriture d'historique : 1 commit + 1 tag par maillon si ça a changé.
# Usage : ./scripts/2-publish-all.sh
set -e
D="$(dirname "$0")"
for s in s02 s03 s04 s05 s06 s07 s08 s09 final; do
    "$D/1-update-starter.sh" "$s"
done
echo; echo "Publication terminée. Tags :"; git tag -l 'starter-*' 'final' | grep -v '_deprecated$'
