# Validation audit — ZeroCrowd-Labs paper

Date: 2026-10-14. Auditor: automated script `paper/validate.py`, rerun
against the live repository files. It re-parses every
`labs/*/replica-parity.md`, the Compose memory/address configuration,
`README.md`, and `labs/*/experiment.md`. All checks pass (`ALL OK`).

## Verified headline numbers (primary corpus, 8 labs)

| Claim | Source files | Recomputed |
| --- | --- | --- |
| Parity rows | 8 × `replica-parity.md` | 88 rows |
| Pass / partial / missing | same | **73 / 15 / 0 (83.0%)** |
| Wilson 95% interval for 73/88 | computed | [73.8, 89.4] |
| Guest RAM sum | README table + parity/Compose | 8,168 MB |
| Replica cap sum | Compose `mem_limit` | 5,248 MB |
| Configured reduction | — | 2,920 MB = 35.7% (caps, not residency) |
| Package-version partials | parity tables | 6 of 8 labs |
| Listening-port partials | parity tables | 4 of 8 labs |
| Perfect areas (8/8) | parity tables | loopback, users, sudoers, app URL |

Per-lab pass/partial: Raven 11/0 · Moria 11/0 · Gaara 10/1 ·
Vikings 9/2 · Matrix 9/2 · Wintermute 8/3 · Necromancer 8/3 ·
Game of Thrones 7/4. Exploratory Spearman (n=8, reported as
exploratory only): guest RAM vs cap ρ=0.87; containers vs pass rows
ρ=−0.72; memory saving vs pass rows ρ=0.14.

## Corrections applied (paper does not inherit these errors)

1. **MrRobot status.** `README.md` says MrRobot "was not converted",
   has no Compose project, and is excluded from the scores. The
   repository contradicts it: `labs/mrrobot-lab/docker-compose.yml`,
   `replica/compose.yaml`, a built-and-running `replica-parity.md`
   (**8 pass / 3 partial / 0 missing**, Ubuntu 14.04), and an
   `experiment.md` all exist. The paper therefore uses the README's
   eight labs as the primary corpus and adds MrRobot as a sensitivity
   corpus: **9 labs, 99 rows, 81 pass / 18 partial / 0 missing
   (81.8%)**, memory 8,680 vs 5,632 MB. No conclusion changes
   direction. A correction note has been added to `README.md`.
2. **Three address layers** were kept distinct: container bridge
   (172.30/172.31.*), dedicated published (10.88.10.*), and student
   host-only (192.168.56.*). Draft text that mixed them was corrected.
3. **Three lookup runs are not interchangeable.** Cross-lab
   Experiment A (skills median 2.539 ms), per-lab Experiment B
   (0.562–4.284 ms replica medians; present for 7 labs — Raven and
   Moria have no `experiment.md`), and an older Raven-only draft
   lookup (1.014 vs 143.469 ms, 8 files) used different corpora. The
   paper reports A and B separately and never pools the timings.
   All are file-read times of a script that already knows the target
   sentence — **not** agent latency; the paper claims no speedup.

## Claim boundaries enforced in the text

- Memory = Compose/VirtualBox configuration, never measured RSS.
- Raven 5/6 → 11/0 is a single-case, same-scorer before/after;
  rows are not independent trials; no statistical test is applied.
- No second agent was run or timed; no resolve rate is reported.
- Inventories for Gaara, Matrix, Wintermute, Necromancer and Game of
  Thrones come from config/unit files of unbooted guests (provenance
  graded in Table 4); Raven/Moria/Vikings are live inventories.
- Kernel/init/archive differences are never scored as passes; they
  are carried in every lab's explicit gap register.

## Reproduce

```bash
python3 paper/validate.py          # re-derives every headline number
python3 paper/make_figures.py      # regenerates all 10 figures (PNG+PDF)
bash    paper/build.sh             # compiles paper/main.tex to PDF
```
