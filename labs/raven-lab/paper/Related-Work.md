# Related Work

The procedure sits between two literatures. One asks how to package and check a computing environment. The other asks how a language-model agent should act, and how that action should be scored. The papers below were checked against a publisher record or a conference proceedings page. Preprints that exist only on arXiv were left out.

## Environments, containers, and parity

Boettiger (2015) reviewed why computational work fails to rerun, and described Docker as a way to combine operating-system virtualization with a versioned build. That is the attraction of replacing a heavy virtual appliance with a container. The same framing leaves the limit this project keeps explicit: a container is not a second machine, and it shares the host kernel. Boettiger did not give an agent a parity checklist for listeners, accounts, cron, or mail.

Nüst et al. (2020) gave ten rules for Dockerfiles, including a stated base image and specified software versions. The replica's pinned Debian revisions follow that rule. The paper does not say what an agent should do when the guest's revisions exist only on a dated snapshot, and it does not score a container against a virtual machine.

Felter et al. (2015) compared KVM with Docker on performance and found that containers matched or exceeded virtual machines in almost all of their cases. Naik (2016) discussed moving a small deployment from virtual machines toward Docker and measured operational overhead in simulation. Both papers support the resource motive for the replica. Neither defines pass, partial, and missing for one appliance's users, sudoers, database, and mail, and neither is evidence that a shared kernel may be scored as reproduced.

Lamb and Zacchiroli (2022) describe reproducible builds as a check that binaries correspond to a fixed source environment. Caneill et al. (2017) show that Debian's own history spans about two decades and is not what a current mirror serves. Those results motivate naming a snapshot when an end-of-life suite has left the active mirrors. They do not state the apt stop conditions an agent needs: when `Check-Valid-Until` may be disabled, when `trusted=yes` is limited to an archived suite, and when that repair must remain a gap in the parity report.

Guerriero et al. (2019) reported that infrastructure-as-code still lacks practical tests. Hummer et al. (2013) tested whether configuration automations are idempotent. Shambaugh et al. (2016) verified determinacy of Puppet configurations with a solver. The parity skill is a weaker, empirical check of the same instinct. The agent may not infer listeners from a Dockerfile when the container is not running, and a later start must not import the application database again. This paper does not claim a soundness result.

## What the language model is asked to do

Haynes et al. (2009) evaluated a surgical checklist whose relevant feature here is its form: a short list of required actions and a point at which the team confirms them before continuing. The skills use that form. The clinical effect sizes are not transferred to agent performance.

Yao et al. (2023) presented ReAct. The model interleaves a reasoning trace with actions in an external environment. On the interactive benchmarks in that paper, ReAct raised absolute success by 34 percentage points on ALFWorld and by 10 percentage points on WebShop relative to the imitation and reinforcement-learning baselines. The procedure in ReAct is generated during the episode. A skill is external to the episode. The agent is supposed to read it before it imports an appliance, edits a disk, rewrites apt sources, or marks a parity row. ReAct does not measure that reading, and it does not supply the stop conditions for an OVA-to-container conversion.

Jimenez et al. (2024) introduced SWE-bench, 2,294 software-engineering tasks from 12 Python repositories. Claude 2, the strongest model they evaluated, resolved 1.96% of the issues. The useful lesson is the outcome definition: success is a completed result under a check, not a plausible narrative. The check in this project is the parity template. A replica that answers HTTP with the wrong database engine, or a report that marks the shared kernel as a pass, is not a success.

Taken together, the literature supports the shape of the problem and does not replace the procedure. Containers are a serious way to package an environment and still share a kernel with the host (Boettiger, 2015; Felter et al., 2015; Nüst et al., 2020). Historical Debian suites have to be named (Caneill et al., 2017; Lamb & Zacchiroli, 2022). Declared infrastructure still needs an independent check (Guerriero et al., 2019; Hummer et al., 2013; Shambaugh et al., 2016). A language model can use tools, and its success can be defined as a completed check rather than a narrative (Haynes et al., 2009; Jimenez et al., 2024; Yao et al., 2023). None of those papers states the six-skill order, the parity rows, or the apt and Sendmail stop conditions used to convert an owned OVA into a Docker replica.

## References

Boettiger, C. (2015). An introduction to Docker for reproducible research. *ACM SIGOPS Operating Systems Review, 49*(1), 71–79. https://doi.org/10.1145/2723872.2723882

Caneill, M., Germán, D. M., & Zacchiroli, S. (2017). The Debsources dataset: Two decades of free and open source software. *Empirical Software Engineering, 22*(3), 1405–1437. https://doi.org/10.1007/s10664-016-9461-5

Felter, W., Ferreira, A., Rajamony, R., & Rubio, J. (2015). An updated performance comparison of virtual machines and Linux containers. In *2015 IEEE International Symposium on Performance Analysis of Systems and Software (ISPASS)* (pp. 171–172). IEEE. https://doi.org/10.1109/ISPASS.2015.7095802

Guerriero, M., Garriga, M., Tamburri, D. A., & Palomba, F. (2019). Adoption, support, and challenges of infrastructure-as-code: Insights from industry. In *2019 IEEE International Conference on Software Maintenance and Evolution (ICSME)* (pp. 580–589). IEEE. https://doi.org/10.1109/ICSME.2019.00092

Haynes, A. B., Weiser, T. G., Berry, W. R., Lipsitz, S. R., Breizat, A.-H. S., Dellinger, E. P., Herbosa, T., Joseph, S., Kibatala, P. L., Lapitan, M. C. M., Merry, A. F., Moorthy, K., Reznick, R. K., Taylor, B., & Gawande, A. A. (2009). A surgical safety checklist to reduce morbidity and mortality in a global population. *The New England Journal of Medicine, 360*(5), 491–499. https://doi.org/10.1056/NEJMsa0810119

Hummer, W., Rosenberg, F., Oliveira, F., & Eilam, T. (2013). Testing idempotence for infrastructure as code. In D. Eyers & K. Schwan (Eds.), *Middleware 2013* (Lecture Notes in Computer Science, Vol. 8275, pp. 368–388). Springer. https://doi.org/10.1007/978-3-642-45065-5_19

Jimenez, C. E., Yang, J., Wettig, A., Yao, S., Pei, K., Press, O., & Narasimhan, K. (2024). SWE-bench: Can language models resolve real-world GitHub issues? In *The Twelfth International Conference on Learning Representations*. https://proceedings.iclr.cc/paper_files/paper/2024/hash/edac78c3e300629acfe6cbe9ca88fb84-Abstract-Conference.html

Lamb, C., & Zacchiroli, S. (2022). Reproducible builds: Increasing the integrity of software supply chains. *IEEE Software, 39*(2), 62–70. https://doi.org/10.1109/MS.2021.3073045

Naik, N. (2016). Migrating from virtualization to Dockerization in the cloud: Simulation and evaluation of distributed systems. In *2016 IEEE 10th International Symposium on the Maintenance and Evolution of Service-Oriented and Cloud-Based Environments (MESOCA)* (pp. 1–8). IEEE. https://doi.org/10.1109/MESOCA.2016.9

Nüst, D., Sochat, V., Marwick, B., Eglen, S. J., Head, T., Hirst, T., & Evans, B. D. (2020). Ten simple rules for writing Dockerfiles for reproducible data science. *PLOS Computational Biology, 16*(11), Article e1008316. https://doi.org/10.1371/journal.pcbi.1008316

Shambaugh, R., Weiss, A., & Guha, A. (2016). Rehearsal: A configuration verification tool for Puppet. In *Proceedings of the 37th ACM SIGPLAN Conference on Programming Language Design and Implementation* (pp. 416–430). Association for Computing Machinery. https://doi.org/10.1145/2908080.2908083

Yao, S., Zhao, J., Yu, D., Du, N., Shafran, I., Narasimhan, K., & Cao, Y. (2023). ReAct: Synergizing reasoning and acting in language models. In *The Eleventh International Conference on Learning Representations*. https://iclr.cc/virtual/2023/poster/11003
