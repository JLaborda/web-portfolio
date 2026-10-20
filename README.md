# web-portfolio
Web that shows my portfolio

## Spec Kit workflow

This repository follows GitHub Spec Kit. Commands are invoked in the Cursor
chat, not in the terminal. The order for each feature is:

1. `/speckit-specify` — `spec.md`, in a PR that contains only that file
2. `/speckit-plan` and `/speckit-tasks` — `plan.md` and `tasks.md`, in a
   second PR, after Jorge has merged the spec
3. `/speckit-implement` — one task, or a small cohesive group, per PR
4. `/speckit-converge` — repeat until `Converged`. The last PR stores the
   output in `specs/NNN-name/converge.md` (date, SHA, and verdict)

Jorge approves by merging into `develop`. In `spec.md` the Tech Lead
replaces `**Status**: Draft` with `Status: Approved by Jorge — PR #N` (no
date; the date is the merge commit). In `plan.md` and `tasks.md` that line
is the only status field. An implementation PR is not opened before the
tasks PR is merged. If converge appends tasks that stay inside the spec,
they are implemented in later PRs and converge is run again. If they would
change the spec's scope, another `spec.md` PR approved by Jorge comes
first. The principles are in `.specify/memory/constitution.md`. The bundled
workflow `.specify/workflows/speckit/workflow.yml` does not replace this
flow. `/speckit-taskstoissues` is not used.

Repository files, site content, and GitHub communication (commits, PR
titles and descriptions, reviews, and comments) are in English.

### Roles

- **Jorge (Product Owner):** approves the constitution, the `spec.md` PR,
  and the `plan.md` + `tasks.md` PR. He is the only person who merges.
- **Tech Lead:** `/speckit-specify`, `/speckit-plan`, and `/speckit-tasks`.
- **Web Developer:** `/speckit-implement` and `/speckit-converge`.
- **Reviewer:** QA review against `spec.md`, `tasks.md`, and the
  constitution before asking Jorge to merge.

### Branches

The spec and the plan live in `specs/NNN-name/` (`spec.md`, `plan.md`,
`tasks.md`). Their PRs come from branch `NNN-name`. Each implementation PR
comes from `NNN-name-tXX`, created from `develop`, and targets `develop`.
The description lists the ids it closes and `tasks.md` marks them `[X]`.
Features are merged one at a time. On a task branch, export
`SPECIFY_FEATURE_DIRECTORY=specs/NNN-name`. `SPECIFY_FEATURE` does not
locate the directory. `.specify/feature.json` is local and is not
committed.

`chore/`, `docs/`, `fix/`, and `ci/` are for changes with no new visible
behavior. They target `develop`, pass the same gates, and Jorge merges
them. Any new behavior requires a spec. `main` receives only releases from
`develop`, always merged by Jorge.
