"""Generate all paper figures (PDF for LaTeX + PNG for inspection).

Visual rules enforced throughout (fixed after a layout audit):
  * no text is drawn on top of another text, marker, bar, or box edge;
  * labs sharing identical coordinates share ONE joint label;
  * labels that would leave the axes are placed inside, with leader lines;
  * minimum effective font size is 7 pt at the printed size -- full-width
    figures are drawn at 7.2 in and single-column figures at 3.4 in
    (the exact \\textwidth / \\columnwidth they are printed at);
  * diagram titles are wrapped inside the canvas, never single long lines.
"""
import sys; sys.path.insert(0, "/home/user/ZeroCrowd-Labs/paper/data")
from dataset import *
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch
from matplotlib.colors import ListedColormap, BoundaryNorm
import numpy as np, pathlib

OUT = pathlib.Path("/home/user/ZeroCrowd-Labs/paper/figures"); OUT.mkdir(parents=True, exist_ok=True)
plt.rcParams.update({
    "font.family": "DejaVu Sans", "font.size": 9,
    "axes.titlesize": 9.5, "axes.labelsize": 9,
    "xtick.labelsize": 8, "ytick.labelsize": 8, "legend.fontsize": 8,
    "figure.dpi": 300, "savefig.dpi": 300,
    "axes.spines.top": False, "axes.spines.right": False, "axes.linewidth": 0.8,
})
C_PASS = "#009E73"; C_PART = "#E69F00"; C_BLUE = "#0072B2"; C_GREY = "#666666"
LBL = 7.6  # point / value label size (pt at printed size)
labs = [l[0] for l in LABS8]
ram = np.array([l[3] for l in LABS8], float); cap = np.array([l[4] for l in LABS8], float)
passes = np.array([sum(1 for v in STATUS8[l] if v == 1) for l in labs], float)
partials = 11 - passes
short = [l.replace("Game of Thrones", "Game of\nThrones") for l in labs]

def save(fig, name):
    for ext in ("png", "pdf"):
        fig.savefig(OUT / f"{name}.{ext}", bbox_inches="tight", pad_inches=0.06)
    plt.close(fig); print("wrote", name)

# ---------------------------------------------------------------- F3 memory
fig, ax = plt.subplots(figsize=(7.2, 3.1)); x = np.arange(len(labs)); w = .38
ax.bar(x - w/2, ram, w, label="Guest RAM (VirtualBox allocation)", color=C_BLUE, edgecolor="white")
ax.bar(x + w/2, cap, w, label="Replica memory cap (Compose mem_limit)", color=C_PASS, edgecolor="white")
for i, (r, c) in enumerate(zip(ram, cap)):
    ax.text(i - w/2, r + 55, f"{int(r)}", ha="center", fontsize=LBL)
    ax.text(i + w/2, c + 55, f"{int(c)}", ha="center", fontsize=LBL)
ax.set_xticks(x); ax.set_xticklabels(short, fontsize=7.6, rotation=18, ha="right", rotation_mode="anchor")
ax.set_ylabel("Memory (MB)"); ax.set_ylim(0, 2400)
ax.legend(frameon=False, loc="upper left"); ax.grid(axis="y", alpha=.25)
ax.set_title("Configured memory: guest allocation vs. replica cap\n"
             "(totals 8,168 vs. 5,248 MB, $-$35.7\u2009%)", loc="left", fontsize=9.5)
save(fig, "fig03_memory_grouped")

# ------------------------------------------------------- F4 stacked parity
fig, ax = plt.subplots(figsize=(7.2, 3.1)); x = np.arange(len(labs))
ax.bar(x, passes, .55, label="Pass", color=C_PASS, edgecolor="white")
ax.bar(x, partials, .55, bottom=passes, label="Partial", color=C_PART, edgecolor="white")
for i, (p, q) in enumerate(zip(passes, partials)):
    ax.text(i, p/2, f"{int(p)}", ha="center", va="center", color="white",
            fontweight="bold", fontsize=8.5)
    if q > 0:
        ax.text(i, p + q/2, f"{int(q)}", ha="center", va="center",
                fontsize=8.5, fontweight="bold")
ax.set_xticks(x); ax.set_xticklabels(short, fontsize=7.6, rotation=18, ha="right", rotation_mode="anchor")
ax.set_ylabel("Parity rows (of 11)"); ax.set_ylim(0, 11.9); ax.set_yticks(range(0, 12, 2))
ax.legend(frameon=True, facecolor="white", framealpha=.95, edgecolor="none",
          loc="lower left", bbox_to_anchor=(-.015, .01), ncol=2)
ax.grid(axis="y", alpha=.25)
ax.set_title("Parity outcome per lab (n\u2009=\u200911 rows/lab; 73 pass, 15 partial, 0 missing)",
             loc="left", fontsize=9.5)
save(fig, "fig04_parity_stacked")

# ------------------------------------------------------------- F5 heatmap
M = np.array([[STATUS8[l][i] for i in range(len(AREAS))] for l in labs], float)
fig, ax = plt.subplots(figsize=(7.2, 3.7))
cmap = ListedColormap([C_PART, C_PASS]); norm = BoundaryNorm([0, 0.75, 1.01], cmap.N)
ax.imshow(np.where(M == 1, 1, 0.5), cmap=cmap, norm=norm, aspect="auto")
ax.set_xticks(range(len(AREAS)))
ax.set_xticklabels(AREAS, fontsize=7.4, rotation=30, ha="right", rotation_mode="anchor")
ax.set_yticks(range(len(labs))); ax.set_yticklabels(labs, fontsize=8.5)
for i in range(len(labs)):
    for j in range(len(AREAS)):
        ax.text(j, i, "P" if M[i, j] == 1 else "\u25d0", ha="center", va="center",
                color="white", fontsize=9, fontweight="bold")
ax.set_xticks(np.arange(-.5, len(AREAS), 1), minor=True)
ax.set_yticks(np.arange(-.5, len(labs), 1), minor=True)
ax.grid(which="minor", color="white", linewidth=1.2); ax.tick_params(which="minor", length=0)
ax.set_title("Parity heatmap: P\u2009=\u2009pass, \u25d0\u2009=\u2009partial (no cell is missing)",
             loc="left", fontsize=9.5)
save(fig, "fig05_heatmap")

# ------------------------------------------------- F6 scatter RAM vs cap
# Distinct coordinates only: (512,384), (512,512), (1024,512) and
# (1512,1408), (2048,1024) -- labs sharing a point share one joint label.
fig, ax = plt.subplots(figsize=(3.4, 3.35))
ax.plot([0, 2350], [0, 2350], "--", color=C_GREY, lw=1, label="cap = guest RAM")
ax.scatter(ram, cap, s=52, color=C_BLUE, edgecolor="white", zorder=3)
joint = [  # (x, y, label, offset, ha)
    (512, 512, "Raven", (8, 6), "left"),
    (512, 384, "Matrix \u00b7 Necromancer", (8, -4), "left"),
    (1024, 512, "Moria \u00b7 Vikings \u00b7 Gaara", (-8, 10), "right"),
    (1512, 1408, "Game of Thrones", (8, 5), "left"),
    (2048, 1024, "Wintermute", (-8, -4), "right"),
]
for px, py, text, off, ha in joint:
    ax.annotate(text, (px, py), textcoords="offset points", xytext=off,
                ha=ha, va="center", fontsize=LBL)
ax.set_xlabel("Guest RAM (MB)", fontsize=8.5); ax.set_ylabel("Replica cap (MB)", fontsize=8.5)
ax.tick_params(labelsize=7.5)
ax.set_xlim(0, 2400); ax.set_ylim(0, 2400); ax.grid(alpha=.25)
ax.legend(frameon=False, fontsize=7, loc="upper left")
ax.set_title("Guest allocation vs. replica cap\n(Spearman \u03c1\u2009=\u20090.87, n\u2009=\u20098)",
             fontsize=9, loc="left")
save(fig, "fig06_scatter_ram_cap")

# -------------------------------------------------- F7 Raven longitudinal
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(7.2, 3.0),
                               gridspec_kw={"width_ratios": [1, 1.45]})
cats = ["Pass", "Partial", "Missing"]; r1 = [5, 6, 0]; r2 = [11, 0, 0]
x = np.arange(3); w = .36
ax1.bar(x - w/2, r1, w, label="Round 1 (before rules)", color=C_PART, edgecolor="white")
ax1.bar(x + w/2, r2, w, label="Round 2 (after rules)", color=C_PASS, edgecolor="white")
for xi, v in zip(x - w/2, r1):
    if v: ax1.text(xi, v + .3, str(v), ha="center", fontsize=LBL)
for xi, v in zip(x + w/2, r2):
    if v: ax1.text(xi, v + .3, str(v), ha="center", fontsize=LBL)
ax1.set_xticks(x); ax1.set_xticklabels(cats, fontsize=8)
ax1.set_ylim(0, 14.6); ax1.set_ylabel("Rows (of 11)")
ax1.legend(frameon=False, fontsize=7.5, loc="upper right")
ax1.grid(axis="y", alpha=.25)
ax1.set_title("(a) Raven parity by round", fontsize=9.5, loc="left")
areas_short = ["Ports", "Loopback", "Packages", "Users", "Sudoers", "Vhosts",
               "Web", "DB", "Cron", "Mail", "App URL"]
before = [0.5, 1, 0.5, 1, 1, 1, 1, 0.5, 0.5, 0.5, 0.5]; after = [1]*11
y = np.arange(len(areas_short))
for yi, (b, a) in enumerate(zip(before, after)):
    ax2.plot([b, a], [yi, yi], color="#999999", lw=1, zorder=1)
ax2.plot(before, y, "o", color=C_PART, label="Round 1", zorder=2, ms=6)
ax2.plot(after, y, "s", color=C_PASS, label="Round 2", zorder=2, ms=6)
ax2.set_yticks(y); ax2.set_yticklabels(areas_short, fontsize=7.6)
ax2.set_xticks([0.5, 1]); ax2.set_xticklabels(["Partial", "Pass"], fontsize=8)
ax2.set_xlim(.35, 1.12); ax2.grid(alpha=.25)
ax2.legend(frameon=True, facecolor="white", framealpha=.95, edgecolor="none",
           fontsize=7.5, loc="center left", bbox_to_anchor=(.02, .42))
ax2.set_title("(b) Row-level movement (6 rows partial \u2192 pass)", fontsize=9.5, loc="left")
save(fig, "fig07_raven_longitudinal")

# ------------------------------------------------------------- F8 radar
rates = np.array([np.mean([STATUS8[l][i] == 1 for l in labs]) for i in range(len(AREAS))]) * 100
labels_r = ["Listening\nports", "Loopback\nunpublished", "Package\nversions", "Users",
            "Sudoers", "Virtual\nhosts", "Web\npaths", "Databases", "Cron", "Mail",
            "Application\nURL"]
ang = np.linspace(0, 2*np.pi, len(AREAS), endpoint=False)
rates_c = np.concatenate([rates, [rates[0]]]); ang_c = np.concatenate([ang, [ang[0]]])
fig, ax = plt.subplots(figsize=(3.4, 3.75), subplot_kw=dict(polar=True))
ax.plot(ang_c, rates_c, color=C_BLUE, lw=2); ax.fill(ang_c, rates_c, color=C_BLUE, alpha=.18)
ax.set_ylim(0, 100); ax.set_yticks([25, 50, 75, 100])
ax.set_yticklabels(["25%", "50%", "75%", "100%"], fontsize=6.8, color="#444444")
ax.set_rlabel_position(140)
ax.set_xticks(ang); ax.set_xticklabels([])
for a, lab in zip(ang, labels_r):  # manual labels: never clipped, never on the polygon
    ca, sa = np.cos(a), np.sin(a)
    ha = "left" if ca > .25 else ("right" if ca < -.25 else "center")
    va = "bottom" if sa > .25 else ("top" if sa < -.25 else "center")
    ax.text(a, 121, lab, ha=ha, va=va, fontsize=7.4, clip_on=False)
ax.grid(color="#BBBBBB", lw=.7)
ax.set_title("Strict pass rate by parity area (8 labs)\n"
             "Package versions (25%) and listening ports (50%) lag", fontsize=8.8, pad=30)
save(fig, "fig08_radar_areas")

# ------------------------------------------------------------ F9 lookup
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(7.2, 3.15),
                               gridspec_kw={"width_ratios": [1, 1.25]})
names = ["Skills", "Raven", "Moria", "Vikings", "Matrix", "Winter.", "Necro.", "Gaara", "GoT"]
hits = [23] + [e[2] for e in EXP_A]
cols = [C_BLUE] + [C_PART]*len(EXP_A)
ax1.bar(range(len(names)), hits, color=cols, edgecolor="white")
for i, v in enumerate(hits):
    ax1.text(i, v + .6, str(v), ha="center", fontsize=LBL)
ax1.set_xticks(range(len(names)))
ax1.set_xticklabels(names, fontsize=7.6, rotation=38, ha="right", rotation_mode="anchor")
ax1.set_ylabel("Rule sentences found (of 23)"); ax1.set_ylim(0, 26.5)
ax1.grid(axis="y", alpha=.25)
ax1.set_title("(a) Coverage: where the 23 rules live", fontsize=9.5, loc="left")
med = [EXP_A_SKILL_MEDIAN] + [e[3] for e in EXP_A]
ax2.bar(range(len(names)), med, color=cols, edgecolor="white")
ax2.set_xticks(range(len(names)))
ax2.set_xticklabels(names, fontsize=7.6, rotation=38, ha="right", rotation_mode="anchor")
ax2.set_ylabel("Median file-read time (ms), 5 reps"); ax2.set_ylim(0, 6)
ax2.grid(axis="y", alpha=.25)
ax2.set_title("(b) Lookup time (file read only \u2014 not agent latency)", fontsize=9.5, loc="left")
save(fig, "fig09_lookup")

# -------------------------------------------------- F10 exploratory scatter
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(7.2, 3.15))
ncont = np.array([l[5] for l in LABS8], float)
ax1.scatter(ncont, passes, s=58, color=C_BLUE, edgecolor="white", zorder=3)
off_a = {"Raven": (7, 6, "left"), "Moria": (7, -13, "left"), "Gaara": (7, 4, "left"),
         "Vikings": (7, 6, "left"), "Matrix": (7, -13, "left"),
         "Necromancer": (7, -14, "left"), "Wintermute": (7, 7, "left"),
         "Game of Thrones": (-7, 6, "right")}
for i, l in enumerate(labs):
    ox, oy, ha = off_a[l]
    ax1.annotate(l, (ncont[i], passes[i]), textcoords="offset points",
                 xytext=(ox, oy), ha=ha, va="center", fontsize=LBL)
ax1.set_xlabel("Containers in replica (complexity proxy)")
ax1.set_ylabel("Pass rows (of 11)"); ax1.set_xticks([1, 2, 9])
ax1.set_xlim(.4, 9.8); ax1.set_ylim(6.1, 12.1); ax1.grid(alpha=.25)
ax1.set_title("(a) Topology complexity vs. fidelity\n(Spearman \u03c1\u2009=\u2009\u22120.72, n\u2009=\u20098, exploratory)",
              fontsize=9.5, loc="left")
saving = 100 * (1 - cap/ram)
ax2.scatter(saving, passes, s=58, color=C_PASS, edgecolor="white", zorder=3)
off_b = {"Raven": (7, 4, "left"), "Game of Thrones": (7, 3, "left"),
         "Matrix": (-8, 4, "right"), "Necromancer": (7, -13, "left"),
         "Moria": (-8, 4, "right"), "Gaara": (-8, 4, "right"),
         "Vikings": (-8, 4, "right"), "Wintermute": (-8, 4, "right")}
for i, l in enumerate(labs):
    ox, oy, ha = off_b[l]
    ax2.annotate(l, (saving[i], passes[i]), textcoords="offset points",
                 xytext=(ox, oy), ha=ha, va="center", fontsize=LBL)
ax2.set_xlabel("Configured memory saving (%)"); ax2.set_ylabel("Pass rows (of 11)")
ax2.set_xlim(-6, 60); ax2.set_ylim(6.1, 12.1); ax2.grid(alpha=.25)
ax2.set_title("(b) Memory saving vs. fidelity\n(\u03c1\u2009=\u20090.14 \u2014 no evident trade-off)",
              fontsize=9.5, loc="left")
save(fig, "fig10_scatter_exploratory")

# ------------------------------------------- F1 deployment diagram
fig, ax = plt.subplots(figsize=(7.2, 4.3)); ax.set_xlim(0, 10); ax.set_ylim(0, 5.6); ax.axis("off")
def box(x, y, w, h, text, fc, fs=7.3, ec="#333333"):
    ax.add_patch(FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.06", fc=fc, ec=ec, lw=.8))
    ax.text(x + w/2, y + h/2, text, ha="center", va="center", fontsize=fs, linespacing=1.45)
def arrow(x1, y1, x2, y2):
    ax.add_patch(FancyArrowPatch((x1, y1), (x2, y2), arrowstyle="->", mutation_scale=10,
                                 color="#333333", lw=.9, shrinkA=2, shrinkB=2))
ax.text(5, 5.42, "Deployment architecture \u2014 from owned appliance to scored container replica",
        ha="center", fontsize=9.5, fontweight="bold")
ax.text(5, 5.12, "Addresses are Compose configuration, not measured traffic",
        ha="center", fontsize=7.6, color=C_GREY)
box(.15, 3.85, 2.25, 1.05, "OWNED VulnHub\nOVAs / VM disks\n(VirtualBox guests)", "#DDEBF7", fs=7.1)
box(2.62, 3.85, 2.25, 1.05, "OFFLINE INVENTORY\nlisteners \u00b7 users\npackages \u00b7 web \u00b7 DB\ncron \u00b7 mail (redacted)", "#FFF2CC", fs=7.1)
box(5.09, 3.85, 2.25, 1.05, "SKILL-GUIDED BUILD\npinned base + versions\nloopback unpublished\nsupervisord (foreground)", "#E2EFDA", fs=7.1)
box(7.56, 3.85, 2.29, 1.05, "11-ROW PARITY SCORE\npass / partial / missing\n+ gap register", "#FCE4E4", fs=7.1)
arrow(2.42, 4.38, 2.60, 4.38); arrow(4.89, 4.38, 5.07, 4.38); arrow(7.36, 4.38, 7.54, 4.38)
box(.10, 1.05, 1.90, 2.30, "HOST\nWindows + WSL2\nWSL kernel 6.18.x\n(shared by all\ncontainers)\nDocker engine", "#EEEEEE", fs=7.1)
box(2.15, 1.05, 5.30, 2.30,
    "DOCKER COMPOSE DEPLOYMENT \u2014 one project per lab\n"
    "Raven 172.30.10.10 \u00b7 Moria 172.30.11.10\n"
    "Vikings 172.31.10.10 \u00b7 Matrix .11.10\n"
    "Wintermute .12.10/.20 \u00b7 Necromancer .14.10\n"
    "Gaara .15.10 \u00b7 Game of Thrones .16.10\u2013.90\n"
    "(9 containers) \u00b7 Published 10.88.10.10\u2013.17\n"
    "(Moria: 127.0.0.1)", "#E2EFDA", fs=7.0)
box(7.60, 1.05, 2.30, 2.30,
    "LEARNER / EVALUATOR\nbrowser + SSH\nto published\naddress only\n\nDB / mail / loopback\nNOT reachable", "#DDEBF7", fs=7.1)
arrow(6.21, 3.83, 6.21, 3.37)   # build -> deployment
arrow(7.58, 2.20, 7.47, 2.20)   # learner -> deployment
ax.text(5, .62, "One Compose project per lab on a dedicated bridge subnet; guest port numbers are preserved.",
        ha="center", fontsize=7.6, color=C_GREY)
save(fig, "fig01_deployment")

# ------------------------------------------- F2 methodology workflow
fig, ax = plt.subplots(figsize=(7.2, 3.7)); ax.set_xlim(0, 10); ax.set_ylim(0, 4.9); ax.axis("off")
ax.text(5, 4.62, "Six-skill conversion pipeline", ha="center", fontsize=10, fontweight="bold")
ax.text(5, 4.28, "Step 2 applies only when the guest password is unknown. "
                 "Scoring feeds corrections back into the skills.",
        ha="center", fontsize=7.6, color=C_GREY)
steps = [("1 IMPORT", "existing NAT\nnetwork only"), ("2 RECOVER*", "offline admin\non disk clone"),
         ("3 REPAIR APT", "archive / vault\n+ Check-Valid-\nUntil off"),
         ("4 INVENTORY", "11 fact groups\nsecrets redacted"),
         ("5 BUILD", "pinned replica\nmem cap \u2264 guest"),
         ("6 SCORE", "11 rows +\ngap register")]
for i, (t, s) in enumerate(steps):
    bx = .15 + i * 1.63
    box(bx, 2.80, 1.45, 1.02, f"{t}\n{s}", "#DDEBF7" if i < 5 else "#FCE4E4", fs=7)
    if i < 5: arrow(bx + 1.45, 3.31, bx + 1.63, 3.31)
box(1.20, .95, 3.20, .95, "Trap / partial row?\nWrite rule back into skill", "#FFF2CC", fs=7.3)
box(5.60, .95, 3.20, .95, "Deliverables: parity report\ngap list \u00b7 student module", "#E2EFDA", fs=7.3)
arrow(8.90, 2.78, 7.55, 1.92); arrow(4.42, 1.42, 5.58, 1.42)
ax.text(5, .45, "Stop conditions at every step (Section 2.2, Table 3). "
                "A trap discovered in Step 6 is not finished until it is written back.",
        ha="center", fontsize=7.4, color=C_GREY)
save(fig, "fig02_methodology")
print("done")

