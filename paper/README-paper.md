# Paper — build and submission notes

Manuscript: **"From Owned Virtual Appliances to Scored Container
Replicas"**, targeted at *Computers & Security* (Elsevier).

## Files

| File | What it is |
| --- | --- |
| `main.tex` | Complete manuscript. Elsevier `elsarticle`, model **3p, two-column, author–year (APA-style) references**, numbered sections 1–6 as requested: Introduction (problem, contributions, related work, structure) · Methodology · Implementation—Mechanics · Evaluation · Discussion · Conclusion, plus Acknowledgements, CRediT, competing-interest and data-availability statements. |
| `ZeroCrowd-Labs-paper.pdf` | **Compiled PDF (21 pages, two-column)** — the deliverable. |
| `elsarticle.cls`, `booktabs.sty` | The genuine Elsevier class (© Elsevier Ltd, LPPL) and booktabs, vendored so the manuscript compiles standalone. |
| `figures/` | All 10 figures as PDF (used in the paper) + PNG. Regenerate: `python3 make_figures.py` (needs matplotlib/numpy/scipy; single data source: `data/dataset.py`). |
| `data/dataset.py` | The one validated dataset table every figure/table derives from. |
| `validate.py` | Audit script; re-derives every headline number from `labs/*` and fails on mismatch. See `VALIDATION.md`. |
| `make_figures.py` | All plots: grouped bars, stacked bars, parity heatmap, scatter plots, radar (spider) chart, Raven dumbbell, lookup bars, and the two architecture/workflow diagrams. Every figure is captioned and explained in the text where it appears. |
| `highlights.txt` | Elsevier highlights (5 bullets, ≤85 chars each) — submit as the separate highlights file. `figures/fig01_deployment.pdf` may serve as the graphical abstract. |
| `build.sh`, `tools/compile.cjs`, `tools/worker.cjs` | Reproducible build (below). |
| `VALIDATION.md` | Full validation audit, corrections, and claim boundaries. |

## How the PDF was compiled here (and how to compile on TeX Live)

This sandbox has no system TeX and its package mirrors are unreachable,
so the PDF was produced with a **real pdfTeX engine** (pdfTeX 1.40.11,
TeX Live 2010) compiled to JavaScript — the GPL `texlive` npm package
(manuels/texlive.js) — driven in Node with a fresh worker per pass and
the `.aux` carried between passes (3 passes, exactly like
`pdflatex × 3`). The engine's TeX tree (63 MB) is a local build asset
in `tools/texlive-js/` and is **git-ignored**; fetch it with
`npm pack texlive` and copy `pdftex-worker.js` + `texlive/` there,
then run `bash paper/build.sh`.

On any standard TeX Live / Overleaf installation the same result is
obtained with no changes other than (optionally) adding `times` to the
class options (this sandbox's TeX tree lacks URW Times metrics, so the
sandbox build uses Computer Modern — visually near-identical at 3p):

```bash
pdflatex main.tex && pdflatex main.tex && pdflatex main.tex
# main.tex, elsarticle.cls, booktabs.sty and figures/*.pdf in one folder
```

Bibliography is a manual APA-style `thebibliography` (25 references,
all IEEE/ACM/Springer/Elsevier/USENIX/MDPI or equivalent Q1–Q2 /
CORE A–B venues, verified against publisher/proceedings records;
**no arXiv-only sources**), cited with natbib author–year commands, as
Computers & Security's APA-style submissions require.

## Before submission (author checklist)

1. Replace "ZeroCrowd-Labs Project Team" with the real author list,
   affiliations, and corresponding-author e-mail in `main.tex`;
   complete the CRediT statement with individual names/roles.
2. Fix the stale MrRobot sentence in the repository `README.md`
   (a correction note has already been added; see `VALIDATION.md`).
3. Upload `highlights.txt` as the separate highlights file; consider
   `fig01_deployment` as the graphical abstract.
4. Confirm the repository URL/DOI for the Data Availability statement
   once the artifact repo is public.

## Scope of the numbers

21 two-column pages, 11 tables, 10 figures, ≈10,600 words, 25
references. Every quantitative claim is traceable to
`labs/*/replica-parity.md`, `vm-inventory.md`, Compose files, or
`experiment.md`, and is re-checked by `validate.py`.
