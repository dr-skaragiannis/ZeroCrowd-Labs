# Example idea briefs

These are operator messages and the kind of design they should produce. They are not labs in the repository.

## One host, a new setting

Operator:

```text
Use designing-lab-scenarios.
Twist: a night clinic. The public page is on port 80. Patient files stay on a database that is not published. Two nurses have accounts and only one of them is an administrator.
```

The skill starts from the single-host pattern (web and SSH published, database on loopback). It invents host and account names. It records two human users, one in the sudo group. It does not include a password or a way to reach the database from outside the host.

## Two hosts from one sentence

Operator:

```text
Use designing-lab-scenarios.
Scale: two hosts
Twist: an observatory dome and a separate clock house. The dome serves a status page. The clock house has no web server.
```

The skill starts from the two-host pattern. One container publishes HTTP and SSH. The other publishes SSH only. Both sit on one bridge with a memory cap under a stated guest size. The premise is the observatory, not the source lab's story.

## Same labs, different twist

A second message that only changes the twist produces a different brief:

```text
Use designing-lab-scenarios.
Twist: the clock house is removed. One host remains, and mail listens on loopback for local notices.
```

Scale drops to one host. Mail is added as a loopback service and is absent from the published port list. Account names are new again.
