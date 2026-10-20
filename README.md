# web-portfolio
Web that shows my portfolio

## Spec Kit workflow

This repository follows GitHub Spec Kit. Commands are invoked in the Cursor
chat, not in the terminal. `/speckit-constitution` is set once for the
project. A feature uses the full path:

1. `/speckit-specify` and `/speckit-clarify` — `spec.md` only, including
   the Clarifications section clarify writes, in one PR
2. `/speckit-plan`, `/speckit-checklist`, `/speckit-tasks`, and
   `/speckit-analyze` — `plan.md`, the plan's supporting files,
   `checklists/*.md`, and `tasks.md`, in a second PR after Jorge has
   merged the spec. Every checklist item is `[x]` or waived on that item
   with a reason. The reviewer marks `[x]`. The PR description pastes the
   analyze report, with no CRITICAL or HIGH finding left open
3. `/speckit-implement` — one task, or a small cohesive group, per PR
4. `/speckit-converge` — repeat until `Converged`. The last PR stores the
   output in `specs/NNN-name/converge.md` (date, SHA, and verdict)

A small change MAY use the short path: `/speckit-specify`, `/speckit-plan`,
`/speckit-tasks`, `/speckit-implement`, `/speckit-converge`. The Tech Lead
labels that choice in the spec PR. Jorge's merge approves it. Clarify,
checklist, and analyze are omitted only in that case.

Jorge approves by merging into `develop`. In `spec.md` the Tech Lead
replaces `**Status**: Draft` with `Status: Approved by Jorge — PR #N` (no
date; the date is the merge commit). In `plan.md` and `tasks.md` that line
is the only status field. An implementation PR is not opened before the
tasks PR is merged. Only one spec, plan, or constitution PR is open at a
time, and it is based on what is already merged in `develop`. If converge
appends tasks that stay inside the spec, they are implemented in later PRs
and converge is run again. If they would change the spec's scope, another
`spec.md` PR approved by Jorge comes first. The principles are in
`.specify/memory/constitution.md` (v1.1.0). The bundled workflow
`.specify/workflows/speckit/workflow.yml` does not replace this flow.
`/speckit-taskstoissues` is not used.

Repository files, site content, and GitHub communication (commits, PR
titles and descriptions, reviews, and comments) are in English.

### Roles

- **Jorge (Product Owner):** approves the constitution, the `spec.md` PR
  (including a short-path label), and the plan PR. He is the only person
  who merges.
- **Tech Lead:** the specify, clarify, plan, checklist, tasks, and analyze
  steps. On a small change, the short path and its label.
- **Web Developer:** `/speckit-implement` and `/speckit-converge`.
- **Reviewer:** QA review against `spec.md`, `plan.md`, `tasks.md`, the
  checklist files when the full path applies, and the constitution before
  asking Jorge to merge. The reviewer marks checklist items `[x]`.

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
