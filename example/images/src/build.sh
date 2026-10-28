#!/bin/sh
# Compile les images TikZ de l'exemple dans ../ :
#   PDF pour Beamer, SVG pour reveal.js (une image par page).
# Le .qmd les référence sans extension (`![](images/reseau)`) : Beamer prend
# le .pdf, reveal.js le .svg (default-image-extension de l'extension).
# Prérequis : xelatex et pdftocairo (fourni avec MiKTeX / TeX Live / poppler).
set -e
cd "$(dirname "$0")"
for src in *.tex; do
  name="${src%.tex}"
  xelatex -interaction=nonstopmode -halt-on-error -output-directory=.. "$src" >/dev/null
  pages=$(pdfinfo "../$name.pdf" | sed -n 's/^Pages: *//p')
  if [ "$pages" = 1 ]; then
    pdftocairo -svg "../$name.pdf" "../$name.svg"
  else
    # Image animée : kmeans.svg (page 1, image par défaut), kmeans-2.svg, ...
    pdftocairo -svg -f 1 -l 1 "../$name.pdf" "../$name.svg"
    i=2
    while [ "$i" -le "$pages" ]; do
      pdftocairo -svg -f "$i" -l "$i" "../$name.pdf" "../$name-$i.svg"
      i=$((i + 1))
    done
  fi
done
rm -f ../*.aux ../*.log
