"""Re-derive every headline number from the repo files; fail on mismatch."""
import re, pathlib, sys
sys.path.insert(0, str(pathlib.Path(__file__).parent/"data"))
from dataset import LABS8, STATUS8, MRROBOT_STATUS
root = pathlib.Path(__file__).resolve().parents[1]
ok = True
def check(label, cond, detail=""):
    global ok
    print(("PASS " if cond else "FAIL ") + label + (" | "+detail if detail else ""))
    ok = ok and cond
# 1. parity counts re-parsed from files vs transcribed STATUS8
name2lab = {"raven-lab":"Raven","moria-lab":"Moria","vikings-lab":"Vikings","matrix-lab":"Matrix",
 "wintermute-lab":"Wintermute","necromancer-lab":"Necromancer","gaara-lab":"Gaara","got-lab":"Game of Thrones"}
for d, short in name2lab.items():
    txt = (root/"labs"/d/"replica-parity.md").read_text(errors="ignore")
    rows = re.findall(r"\|\s*([^|]+)\|\s*[^|]*\|\s*[^|]*\|\s*(pass|partial|missing)", txt, flags=re.I)
    p = sum(1 for _,s in rows if s.lower()=="pass"); q = sum(1 for _,s in rows if s.lower()=="partial")
    tp = sum(1 for v in STATUS8[short] if v==1); tq = sum(1 for v in STATUS8[short] if v==0.5)
    check(f"parity {short}", (p,q)==(tp,tq), f"file={p}/{q} paper={tp}/{tq}")
tot_p = sum(v==1 for r in STATUS8.values() for v in r); tot_q = sum(v==0.5 for r in STATUS8.values() for v in r)
check("8-lab totals 73/15/0 of 88", (tot_p,tot_q)==(73,15), f"{tot_p}/{tot_q}/{88-tot_p-tot_q}")
mp = sum(1 for v in MRROBOT_STATUS if v==1); mq = sum(1 for v in MRROBOT_STATUS if v==0.5)
check("MrRobot file exists despite README claim", (root/"labs/mrrobot-lab/replica-parity.md").exists() and (root/"labs/mrrobot-lab/docker-compose.yml").exists(), f"parity={mp}/{mq}")
check("9-lab totals 81/18/0 of 99", (tot_p+mp, tot_q+mq)==(81,18))
ram = sum(l[3] for l in LABS8); cap = sum(l[4] for l in LABS8)
check("memory sums 8168/5248", (ram,cap)==(8168,5248), f"{ram}/{cap} saving={ram-cap} ({100*(ram-cap)/ram:.1f}%)")
# README table sums also 8168/5248?
readme = (root/"README.md").read_text()
check("README states 8 labs & mrrobot not converted (STALE vs files)", "eight finished labs" in readme and "was not converted" in readme)
# experiment files present
have = sorted(p.parent.name for p in root.glob("labs/*/experiment.md"))
check("experiment.md in 7 labs (none for raven/moria)", len(have)==7, ",".join(have))
print("\nALL OK" if ok else "\nMISMATCHES FOUND"); sys.exit(0 if ok else 1)
