#!/usr/bin/env bash
# Build paper/main.tex -> paper/ZeroCrowd-Labs-paper.pdf
# Requires: node, and the texlive.js assets (npm package "texlive", GPL) in
# paper/tools/texlive-js/  (pdftex-worker.js + texlive/). See README-paper.md.
set -euo pipefail
cd "$(dirname "$0")"
export TEXLIVE_JS_DIR="$PWD/tools/texlive-js"
EXTRA=()
for f in figures/*.pdf; do EXTRA+=("$f::/$f"); done
node tools/compile.cjs main.tex ZeroCrowd-Labs-paper.pdf \
  elsarticle.cls::/elsarticle.cls booktabs.sty::/booktabs.sty "${EXTRA[@]}"
