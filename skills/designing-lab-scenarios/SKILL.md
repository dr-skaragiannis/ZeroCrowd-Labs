---
name: designing-lab-scenarios
description: >-
  Designs a new cybersecurity lab scenario from ZeroCrowd-Labs inventories,
  Compose topology, and account tables. Use when the user asks for a new
  scenario, a training environment, a lab idea, or an exercise based on the
  existing VulnHub-to-Docker labs, including when they supply a setting,
  twist, or idea brief as context.
---

# Design a lab scenario from ZeroCrowd-Labs

Read the finished labs and write a **new** scenario. Reuse their shapes: who can log in, which ports are published, which stay on loopback, how many hosts share a bridge, and how mail, cron, and databases are placed. Invent the story, the host names, and the account names.

The scenario is a build brief for a later replica. It is a description of services, roles, and exposure. It is not a solution.

## Do not produce

- An exploit, payload, attack chain, or step that gains a shell or root.
- A flag, a password, a hash, a community string, or a copy of one from a lab file.
- A writeup of an existing lab, including its challenge path.
- Contents of `operator.pass`, `shadow-users.txt`, web trees, or home directories. Read `vm-inventory.md`, `replica-parity.md`, and `docker-compose.yml` only.

If the user asks for a solution, still deliver the design brief and omit the solution.

## Where the labs are

Root: `ZeroCrowd-Labs/`. If the workspace is elsewhere, use `C:\Users\bloodraven\Projects\ZeroCrowd-Labs`.

| Read | Use it for |
| --- | --- |
| `README.md` | The eleven-row checklist, memory-cap rule, and the six-step build order |
| `labs/<lab>/vm-inventory.md` | Listeners, users, sudoers, packages, web, databases, cron, mail |
| `labs/<lab>/docker-compose.yml` and `labs/<lab>/replica/compose.yaml` | Hosts, bridge subnet, published addresses, memory caps |
| `labs/<lab>/replica-parity.md` | What matched and which substitutions stayed partial |

Skip `mrrobot-lab`. It has no replica. Skip disk images.

## Patterns you may reuse

Name the source pattern in the brief. Do not copy its names.

| Pattern | Labs that show it | Shape to reuse |
| --- | --- | --- |
| Single host, web and SSH published | gaara-lab, vikings-lab, raven-lab | One container, ports 22 and 80 on a dedicated address, other services on loopback |
| Loopback application | necromancer-lab | SSH published, HTTP and auxiliary ports bound to 127.0.0.1 and absent from Compose ports |
| Two cooperating hosts | wintermute-lab | Two containers, two publish addresses, one bridge, different port sets |
| Many small services | got-lab | Several containers on one bridge, one published port each, total memory under the guest RAM |
| High port beside port 80 | matrix-lab | The same program family on 80 and on a second non-privileged port |
| Local database and local mail | raven-lab, moria-lab | Database and SMTP listen on 127.0.0.1 and are not in the published port list |

Account facts to lift as **counts and roles**, then rename: uid 0 with a shell, one or more human users with home directories, a nologin service account, an operator in group `sudo` or `wheel`. Record sudo as "full" or "group" without pasting a rule that contains a password.

## Idea brief

The user turns one scenario into another by filling this brief. A single sentence is enough. Treat that sentence as **Twist**, and choose the closest pattern above for anything they left blank. Say which blanks you filled.

```text
Working title:
Setting (one sentence):
Audience: student lab | range exercise | builder test
Scale: one host | two hosts | many services
Pattern to start from (optional lab name):
Services to include:
Services to keep off the published address:
Memory cap (optional):
Twist (the new idea):
Tone:
Avoid:
```

**Twist** is the only required new idea. Examples of a twist: "a harbor office and a lighthouse on two hosts", "mail stays inside the host", "three people share one web server and only one of them is an administrator". The twist changes names, topology, or exposure. It does not request an attack path.

When the user gives several twists in one message, write one scenario per twist, each with its own pattern line.

## Procedure

Copy this checklist and update it as you go:

```text
Scenario progress:
- [ ] Idea brief recorded, blanks filled from a named pattern
- [ ] Inventories and Compose files read for that pattern
- [ ] Accounts, ports, and networks abstracted (no secrets copied)
- [ ] New names assigned
- [ ] Design brief written from the template
- [ ] Output checked for exploit steps, flags, and passwords
```

1. Record the idea brief. Pick one source pattern and list the files you will read.
2. From those files, extract only: host count, published ports, loopback ports, bridge layout, memory cap, user count and shells, whether sudo is a group rule, whether a database or mail listener exists, and whether cron has jobs. Do not copy page text.
3. Apply the twist. Change host names, account names, and the story. Keep the exposure shape unless the twist changes it.
4. Write the design brief below. Set a memory cap at or below a stated guest size. Leave the host kernel as a known gap, matching the existing labs.
5. Re-read the brief. Delete any sentence that tells the reader how to compromise a service.

## Design brief template

```markdown
# <Working title>

Source pattern: <lab or pattern name>
Twist: <one sentence>

## Premise
<Two or three sentences. Who operates this network, and what a student is asked to map.>

## Topology
| Host | Role | Address | Published ports | Loopback only | Memory cap |
| --- | --- | --- | --- | --- | --- |

Bridge: <subnet>

## Accounts
| Name | uid | Shell | Admin | Purpose |
| --- | --- | --- | --- | --- |

Sudo: <full for root, group, or a single named command>. No passwords.

## Services
| Host | Program | Bind | Why it is there |
| --- | --- | --- | --- |

## Schedule and data
- Cron: <job present or none, command name only>
- Database: <engine and bind, or none>
- Mail: <bind, or none>
- Web roots: <path names only>

## What the student practices
- <Exposure: which ports are reachable from the lab address>
- <Accounts: who can administer the host>
- <Boundary: which service stays on loopback>

## Build notes for a later replica
Follow the six ZeroCrowd-Labs skills in order: import, offline admin, inventory, archive package repair, Compose build, eleven-row parity. Guest kernel, archive apt, and a supervisor in place of init stay explicit gaps.

## Out of scope
This brief has no attack steps, flags, or credentials.
```

## Operator instructions

Use the skill by name and paste an idea brief in the same message.

```text
Use designing-lab-scenarios.

Working title: Harbor watch
Setting: A port authority with a public desk and a private radio room.
Scale: two hosts
Services to include: web, ssh
Services to keep off the published address: database
Twist: The radio room accepts mail only from itself.
Tone: coastal, short
```

A shorter message is valid:

```text
Use designing-lab-scenarios.
Twist: a single library host where the catalog is on port 80 and SSH is the only other published port.
```

To get a different scenario from the same labs, change **Twist**, **Scale**, or **Services to keep off the published address**. Leave the lab files unread by the operator. The skill rereads them.

Further examples of briefs and the kind of brief they produce: [examples.md](examples.md).
