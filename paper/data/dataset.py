"""Single source of truth for the paper. Every number below was transcribed
from labs/*/replica-parity.md, labs/*/vm-inventory.md, README.md and
labs/*/experiment.md on 2026-10-14 and cross-checked by validate.py."""
# name, guest OS, guest kernel, guest RAM MB, replica cap MB, containers,
# published address, bridge subnet, provenance of inventory, pass, partial
LABS8 = [
 # name,        guest_os,                 guest_kernel,      ram,  cap, ncont, published,      subnet,            provenance
 ("Raven",      "Debian 8.11 (jessie)",   "3.16.0-6-amd64",   512,  512, 1, "10.88.10.10",  "172.30.10.0/24",  "live (serial)"),
 ("Moria",      "CentOS 7.3.1611",        "3.10.0-514.el7",  1024,  512, 1, "127.0.0.1",    "172.30.11.0/24",  "live (serial)"),
 ("Vikings",    "Ubuntu 18.04 (bionic)",  "4.15.0-154-gen.", 1024,  512, 1, "10.88.10.11",  "172.31.10.0/24",  "live (booted)"),
 ("Matrix",     "Porteus 4.0 (Slackware)","not collected",    512,  384, 1, "10.88.10.12",  "172.31.11.0/24",  "config only"),
 ("Wintermute", "Debian 9 + Ubuntu 16.04","4.9.0-6 / 4.4.0-116", 2048, 1024, 2, "10.88.10.13/.14", "172.31.12.0/24", "config only"),
 ("Necromancer","OpenBSD 5.9 (GENERIC)",  "OpenBSD 5.9",      512,  384, 1, "10.88.10.15",  "172.31.14.0/24",  "config only"),
 ("Gaara",      "Debian 10 (buster)",     "4.19.0-13-amd64", 1024,  512, 1, "10.88.10.16",  "172.31.15.0/24",  "config only"),
 ("Game of Thrones", "Debian 9 (stretch)", "4.9.0-3-amd64",  1512, 1408, 9, "10.88.10.17",  "172.31.16.0/24",  "config only"),
]
AREAS = ["Listening ports","Loopback unpublished","Package versions","Users","Sudoers",
         "Virtual hosts","Web paths","Databases","Cron","Mail","Application URL"]
# 1=pass, 0.5=partial, 0=missing  (order = AREAS), from replica-parity.md
STATUS8 = {
 "Raven":           [1,1,1,1,1,1,1,1,1,1,1],
 "Moria":           [1,1,1,1,1,1,1,1,1,1,1],
 "Vikings":         [0.5,1,0.5,1,1,1,1,1,1,1,1],
 "Matrix":          [0.5,1,0.5,1,1,1,1,1,1,1,1],
 "Wintermute":      [0.5,1,0.5,1,1,1,1,1,1,0.5,1],
 "Necromancer":     [1,1,0.5,1,1,0.5,1,1,0.5,1,1],
 "Gaara":           [1,1,0.5,1,1,1,1,1,1,1,1],
 "Game of Thrones": [0.5,1,0.5,1,1,1,0.5,0.5,1,1,1],
}
MRROBOT = ("MrRobot", "Ubuntu 14.04.2 (trusty)", "3.13.0-55-gen.", 512, 384, 1, "10.88.10.18", "172.31.17.0/24", "config only")
MRROBOT_STATUS = [1,1,0.5,0.5,1,1,1,1,1,1,0.5]
# Experiment A (README.md, 13 Oct 2026): 23 rule sentences, 5 repetitions
EXP_A_SKILL_MEDIAN = 2.539
EXP_A = [  # lab, files, hits, median ms
 ("Raven",8,1,5.076),("Moria",5,0,3.123),("Vikings",6,1,3.532),("Matrix",6,1,3.589),
 ("Wintermute",9,1,4.862),("Necromancer",9,1,4.835),("Gaara",7,1,3.641),("Game of Thrones",9,1,4.553)]
# Experiment B (labs/*/experiment.md): skills median, replica median (ms)
EXP_B = {  # lab: (skills_median, replica_median, replica_files)
 "Gaara":(1.900,3.461,7),"Game of Thrones":(1.874,4.284,9),"Matrix":(0.593,0.562,6),
 "MrRobot":(2.129,4.050,8),"Necromancer":(1.724,4.127,9),"Vikings":(0.618,0.635,6),
 "Wintermute":(0.758,1.039,9)}
