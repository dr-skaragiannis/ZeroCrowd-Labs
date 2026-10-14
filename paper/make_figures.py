import sys; sys.path.insert(0,"/home/user/ZeroCrowd-Labs/paper/data")
from dataset import *
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch
import numpy as np, pathlib
OUT = pathlib.Path("/home/user/ZeroCrowd-Labs/paper/figures"); OUT.mkdir(parents=True, exist_ok=True)
plt.rcParams.update({"font.family":"DejaVu Sans","font.size":8,"axes.titlesize":9,"axes.labelsize":8,
 "xtick.labelsize":7,"ytick.labelsize":7,"legend.fontsize":7,"figure.dpi":300,"savefig.dpi":300,
 "axes.spines.top":False,"axes.spines.right":False})
C_PASS="#009E73"; C_PART="#E69F00"; C_MISS="#CC79A7"; C_BLUE="#0072B2"; C_GREY="#666666"
labs=[l[0] for l in LABS8]; ram=np.array([l[3] for l in LABS8],float); cap=np.array([l[4] for l in LABS8],float)
passes=np.array([sum(1 for v in STATUS8[l] if v==1) for l in labs],float); partials=11-passes
def save(fig,name):
    for ext in ("png","pdf"):
        fig.savefig(OUT/f"{name}.{ext}", bbox_inches="tight")
    plt.close(fig); print("wrote",name)
# F3 grouped RAM
fig,ax=plt.subplots(figsize=(7.2,3.0)); x=np.arange(len(labs)); w=.38
ax.bar(x-w/2,ram,w,label="Guest RAM (VirtualBox allocation)",color=C_BLUE,edgecolor="white")
ax.bar(x+w/2,cap,w,label="Replica memory cap (Compose mem_limit)",color=C_PASS,edgecolor="white")
for i,(r,c) in enumerate(zip(ram,cap)):
    ax.text(i-w/2,r+40,f"{int(r)}",ha="center",fontsize=6); ax.text(i+w/2,c+40,f"{int(c)}",ha="center",fontsize=6)
ax.set_xticks(x); ax.set_xticklabels([l.replace("Game of Thrones","Game of\nThrones") for l in labs],fontsize=6.5)
ax.set_ylabel("Memory (MB)"); ax.set_ylim(0,2350); ax.legend(frameon=False,loc="upper right"); ax.grid(axis="y",alpha=.25)
ax.set_title("Configured memory: guest allocation vs. replica cap (total 8,168 vs. 5,248 MB, −35.7%)",loc="left",fontsize=8)
save(fig,"fig03_memory_grouped")
# F4 stacked parity
fig,ax=plt.subplots(figsize=(7.2,3.0)); x=np.arange(len(labs))
ax.bar(x,passes,.55,label="Pass",color=C_PASS,edgecolor="white"); ax.bar(x,partials,.55,bottom=passes,label="Partial",color=C_PART,edgecolor="white")
for i,(p,q) in enumerate(zip(passes,partials)): ax.text(i,p/2,f"{int(p)}",ha="center",va="center",color="white",fontweight="bold",fontsize=7); 
for i,(p,q) in enumerate(zip(passes,partials)):
    if q>0: ax.text(i,p+q/2,f"{int(q)}",ha="center",va="center",fontsize=7,fontweight="bold")
ax.set_xticks(x); ax.set_xticklabels([l.replace("Game of Thrones","Game of\nThrones") for l in labs],fontsize=6.5)
ax.set_ylabel("Parity rows (of 11)"); ax.set_ylim(0,11.8); ax.set_yticks(range(0,12,2)); ax.legend(frameon=False,ncol=2); ax.grid(axis="y",alpha=.25)
ax.set_title("Parity outcome per lab (n=11 rows/lab; 73 pass, 15 partial, 0 missing)",loc="left",fontsize=8)
save(fig,"fig04_parity_stacked")
# F5 heatmap
M=np.array([[STATUS8[l][i] for i in range(len(AREAS))] for l in labs],float)
fig,ax=plt.subplots(figsize=(7.2,3.6))
from matplotlib.colors import ListedColormap, BoundaryNorm
cmap=ListedColormap([C_PART,C_PASS]); # 0.5 -> first, 1 -> second via norm
norm=BoundaryNorm([0,0.75,1.01],cmap.N)
ax.imshow(np.where(M==1,1,0.5),cmap=cmap,norm=norm,aspect="auto")
ax.set_xticks(range(len(AREAS))); ax.set_xticklabels([a.replace(" ","\n") for a in AREAS],fontsize=5.8)
ax.set_yticks(range(len(labs))); ax.set_yticklabels(labs,fontsize=7)
for i in range(len(labs)):
    for j in range(len(AREAS)): ax.text(j,i,"P" if M[i,j]==1 else "◐",ha="center",va="center",color="white",fontsize=7,fontweight="bold")
ax.set_xticks(np.arange(-.5,len(AREAS),1),minor=True); ax.set_yticks(np.arange(-.5,len(labs),1),minor=True)
ax.grid(which="minor",color="white",linewidth=1.2); ax.tick_params(which="minor",length=0)
ax.set_title("Parity heatmap: P = pass, ◐ = partial (no cell is missing)",loc="left",fontsize=8)
save(fig,"fig05_heatmap")
# F6 scatter RAM vs cap
fig,ax=plt.subplots(figsize=(3.4,3.2))
ax.plot([0,2200],[0,2200],"--",color=C_GREY,lw=1,label="cap = guest RAM")
ax.scatter(ram,cap,s=55,color=C_BLUE,edgecolor="white",zorder=3)
for i,l in enumerate(labs): ax.annotate(l,(ram[i],cap[i]),textcoords="offset points",xytext=(5,5),fontsize=6)
ax.set_xlabel("Guest RAM (MB)"); ax.set_ylabel("Replica cap (MB)"); ax.set_xlim(0,2300); ax.set_ylim(0,2300); ax.grid(alpha=.25); ax.legend(frameon=False,fontsize=6)
ax.set_title("Guest allocation vs. replica cap\n(Spearman ρ=0.87, n=8)",fontsize=8,loc="left")
save(fig,"fig06_scatter_ram_cap")
# F7 Raven longitudinal
fig,(ax1,ax2)=plt.subplots(1,2,figsize=(7.2,2.8),gridspec_kw={"width_ratios":[1,1.4]})
cats=["Pass","Partial","Missing"]; r1=[5,6,0]; r2=[11,0,0]; x=np.arange(3); w=.36
ax1.bar(x-w/2,r1,w,label="Round 1 (before rules)",color=C_PART,edgecolor="white"); ax1.bar(x+w/2,r2,w,label="Round 2 (after rules)",color=C_PASS,edgecolor="white")
ax1.set_xticks(x); ax1.set_xticklabels(cats); ax1.set_ylim(0,12); ax1.set_ylabel("Rows (of 11)"); ax1.legend(frameon=False,fontsize=6); ax1.grid(axis="y",alpha=.25)
ax1.set_title("(a) Raven parity by round",fontsize=8,loc="left")
areas_short=["Ports","Loopback","Packages","Users","Sudoers","Vhosts","Web","DB","Cron","Mail","App URL"]
before=[0.5,1,0.5,1,1,1,1,0.5,0.5,0.5,0.5]; after=[1]*11; y=np.arange(len(areas_short))
for yi,(b,a) in enumerate(zip(before,after)):
    ax2.plot([b,a],[yi,yi],color="#999999",lw=1,zorder=1)
ax2.plot(before,y,"o",color=C_PART,label="Round 1",zorder=2); ax2.plot(after,y,"s",color=C_PASS,label="Round 2",zorder=2)
ax2.set_yticks(y); ax2.set_yticklabels(areas_short,fontsize=6); ax2.set_xticks([0.5,1]); ax2.set_xticklabels(["Partial","Pass"]); ax2.set_xlim(.35,1.1); ax2.grid(alpha=.25); ax2.legend(frameon=False,fontsize=6)
ax2.set_title("(b) Row-level movement (6 rows partial → pass)",fontsize=8,loc="left")
save(fig,"fig07_raven_longitudinal")
# F8 radar
rates=np.array([np.mean([STATUS8[l][i]==1 for l in labs]) for i in range(len(AREAS))])*100
labels_r=[a.replace("Loopback unpublished","Loopback\nunpublished").replace("Package versions","Package\nversions").replace("Application URL","Application\nURL").replace("Listening ports","Listening\nports").replace("Virtual hosts","Virtual\nhosts") for a in AREAS]
ang=np.linspace(0,2*np.pi,len(AREAS),endpoint=False).tolist(); rates_c=np.concatenate([rates,[rates[0]]]); ang_c=ang+[ang[0]]
fig,ax=plt.subplots(figsize=(4.2,4.2),subplot_kw=dict(polar=True))
ax.plot(ang_c,rates_c,color=C_BLUE,lw=2); ax.fill(ang_c,rates_c,color=C_BLUE,alpha=.18)
ax.set_xticks(ang); ax.set_xticklabels(labels_r,fontsize=6); ax.set_ylim(0,100); ax.set_yticks([25,50,75,100]); ax.set_yticklabels(["25%","50%","75%","100%"],fontsize=6)
ax.set_title("Strict pass rate by parity area (8 labs)\nPackage versions (25%) and listening ports (50%) lag",fontsize=8,pad=18)
save(fig,"fig08_radar_areas")
# F9 lookup Exp A
fig,(ax1,ax2)=plt.subplots(1,2,figsize=(7.2,2.9),gridspec_kw={"width_ratios":[1,1.3]})
names=["Skills\ncorpus"]+[e[0].replace("Game of Thrones","GoT").replace("Necromancer","Necro.").replace("Wintermute","Winter.") for e in EXP_A]; hits=[23]+[e[2] for e in EXP_A]
cols=[C_BLUE]+[C_PART]*len(EXP_A); ax1.bar(range(len(names)),hits,color=cols,edgecolor="white")
ax1.set_xticks(range(len(names))); ax1.set_xticklabels(names,fontsize=5.5,rotation=35,ha="left"); ax1.set_ylabel("Rule sentences found (of 23)"); ax1.set_ylim(0,25); ax1.grid(axis="y",alpha=.25)
ax1.set_title("(a) Coverage: where the 23 rules live",fontsize=8,loc="left")
med=[EXP_A_SKILL_MEDIAN]+[e[3] for e in EXP_A]; ax2.bar(range(len(names)),med,color=cols,edgecolor="white")
ax2.set_xticks(range(len(names))); ax2.set_xticklabels(names,fontsize=5.5,rotation=35,ha="left"); ax2.set_ylabel("Median file-read time (ms), 5 reps"); ax2.set_ylim(0,6); ax2.grid(axis="y",alpha=.25)
ax2.set_title("(b) Lookup time (file read only — not agent latency)",fontsize=8,loc="left")
save(fig,"fig09_lookup")
# F10 exploratory scatter
fig,(ax1,ax2)=plt.subplots(1,2,figsize=(7.2,2.9))
ncont=np.array([l[5] for l in LABS8],float)
ax1.scatter(ncont,passes,s=60,color=C_BLUE,edgecolor="white")
OFF={"Raven":(5,5),"Moria":(5,-11),"Gaara":(5,3),"Vikings":(5,5),"Matrix":(5,-11),"Necromancer":(5,3),"Wintermute":(5,3)}
for i,l in enumerate(labs): ax1.annotate(l,(ncont[i],passes[i]),textcoords="offset points",xytext=OFF.get(l,(4,4)),fontsize=6)
ax1.set_xlabel("Containers in replica (complexity proxy)"); ax1.set_ylabel("Pass rows (of 11)"); ax1.set_xticks([1,2,9]); ax1.set_ylim(6,11.8); ax1.grid(alpha=.25)
ax1.set_title("(a) Topology complexity vs. fidelity\n(Spearman ρ=−0.72, n=8, exploratory)",fontsize=8,loc="left")
saving=100*(1-cap/ram); ax2.scatter(saving,passes,s=60,color=C_PASS,edgecolor="white")
for i,l in enumerate(labs): ax2.annotate(l,(saving[i],passes[i]),textcoords="offset points",xytext=(4,4),fontsize=6)
ax2.set_xlabel("Configured memory saving (%)"); ax2.set_ylabel("Pass rows (of 11)"); ax2.set_ylim(6,11.8); ax2.grid(alpha=.25)
ax2.set_title("(b) Memory saving vs. fidelity\n(ρ=0.14 — no evident trade-off)",fontsize=8,loc="left")
save(fig,"fig10_scatter_exploratory")
# F1 deployment diagram
fig,ax=plt.subplots(figsize=(7.2,3.8)); ax.set_xlim(0,10); ax.set_ylim(0,5.2); ax.axis("off")
def box(x,y,w,h,text,fc,fs=6.5,ec="#333333"):
    ax.add_patch(FancyBboxPatch((x,y),w,h,boxstyle="round,pad=0.06",fc=fc,ec=ec,lw=.8))
    ax.text(x+w/2,y+h/2,text,ha="center",va="center",fontsize=fs)
def arrow(x1,y1,x2,y2):
    ax.add_patch(FancyArrowPatch((x1,y1),(x2,y2),arrowstyle="->",mutation_scale=9,color="#333333",lw=.9))
box(.2,3.9,2.2,1.0,"OWNED VulnHub\nOVAs / VM disks\n(VirtualBox guests)","#DDEBF7")
box(3.0,3.9,2.2,1.0,"OFFLINE INVENTORY\nlisteners · users · packages\nweb · DB · cron · mail\n(secrets redacted)","#FFF2CC")
box(5.8,3.9,2.2,1.0,"SKILL-GUIDED BUILD\npinned base image + versions\nloopback stays unpublished\nsupervisord (foreground)","#E2EFDA")
box(8.3,3.9,1.5,1.0,"11-ROW\nPARITY\nSCORE\npass/partial/\nmissing + gaps","#FCE4E4")
arrow(2.4,4.4,3.0,4.4); arrow(5.2,4.4,5.8,4.4); arrow(8.0,4.4,8.3,4.4)
box(.2,.9,2.2,2.2,"HOST\nWindows + WSL2\nWSL kernel 6.18.x\n(shared by all containers)\nDocker engine","#EEEEEE")
box(3.0,.9,4.9,2.2,"DOCKER COMPOSE DEPLOYMENT (one project per lab)\nRaven 172.30.10.10 · Moria 172.30.11.10 · Vikings 172.31.10.10\nMatrix .11.10 · Wintermute .12.10/.20 · Necromancer .14.10\nGaara .15.10 · Game of Thrones .16.10–.90 (9 containers)\nPublished only on 10.88.10.10–.17 (Moria: 127.0.0.1)","#E2EFDA",fs=6)
box(8.3,.9,1.5,2.2,"LEARNER /\nEVALUATOR\nbrowser + SSH\nto published\naddress only\n\nDB / mail /\nloopback NOT\nreachable","#DDEBF7",fs=6)
arrow(6.9,3.9,6.9,3.1); arrow(8.3,2.0,7.9,2.0)
ax.text(5,5.05,"Deployment architecture — from owned appliance to scored container replica (addresses are Compose configuration, not measured traffic)",ha="center",fontsize=7.5,fontweight="bold")
save(fig,"fig01_deployment")
# F2 methodology workflow
fig,ax=plt.subplots(figsize=(7.2,3.4)); ax.set_xlim(0,10); ax.set_ylim(0,4.6); ax.axis("off")
steps=[("1 IMPORT","existing NAT\nnetwork only"),("2 RECOVER*","offline admin\non disk clone"),("3 REPAIR APT","archive / vault\n+ Check-Valid-\nUntil off"),("4 INVENTORY","11 fact groups\nsecrets redacted"),("5 BUILD","pinned replica\nmem cap ≤ guest"),("6 SCORE","11 rows +\ngap register")]
for i,(t,s) in enumerate(steps):
    x=.15+i*1.63; box(x,2.6,1.45,.95,f"{t}\n{s}","#DDEBF7" if i<5 else "#FCE4E4",fs=6)
    if i<5: arrow(x+1.45,3.05,x+1.63,3.05)
box(1.2,.7,3.2,.9,"Trap / partial row?\nWrite rule back into skill","#FFF2CC",fs=6.5)
box(5.6,.7,3.2,.9,"Deliverables: parity report\ngap list · student module","#E2EFDA",fs=6.5)
arrow(8.9,2.6,7.6,1.6); arrow(4.4,1.15,5.6,1.15)
ax.text(5,4.35,"Six-skill conversion pipeline (*Step 2 only when the guest password is unknown).  Scoring feeds corrections back into the skills.",ha="center",fontsize=7.5,fontweight="bold")
ax.text(5,.25,"Stop conditions at every step (Section 2.2, Table 3).  A trap discovered in Step 6 is not finished until it is written back.",ha="center",fontsize=6.5,color=C_GREY)
save(fig,"fig02_methodology")
print("done")
