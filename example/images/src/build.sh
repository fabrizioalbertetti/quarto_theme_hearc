#!/bin/sh
# Compile les images TikZ de l'exemple en SVG dans ../ (une image par page).
# Prérequis : xelatex et pdftocairo (fourni avec MiKTeX / TeX Live / poppler).
set -e
cd "$(dirname "$0")"
tmp=$(mktemp -d)
for src in *.tex; do
  name="${src%.tex}"
  xelatex -interaction=nonstopmode -halt-on-error -output-directory="$tmp" "$src" >/dev/null
  pages=$(pdfinfo "$tmp/$name.pdf" | sed -n 's/^Pages: *//p')
  if [ "$pages" = 1 ]; then
    pdftocairo -svg "$tmp/$name.pdf" "../$name.svg"
  else
    # Image animée : kmeans.svg (page 1), kmeans-2.svg, kmeans-3.svg...
    pdftocairo -svg -f 1 -l 1 "$tmp/$name.pdf" "../$name.svg"
    i=2
    while [ "$i" -le "$pages" ]; do
      pdftocairo -svg -f "$i" -l "$i" "$tmp/$name.pdf" "../$name-$i.svg"
      i=$((i + 1))
    done
  fi
done
rm -rf "$tmp"
