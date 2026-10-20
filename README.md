# web-portfolio
Web that shows my portfolio

## Spec Kit workflow

This repository follows GitHub Spec Kit. Commands are invoked in the Cursor
chat, not in the terminal. `/speckit-constitution` is set once for the
project. A feature uses the full path:

1. `/speckit-specify` and `/speckit-clarify` — one PR containing exactly
   `spec.md` and `checklists/requirements.md`. Every item in that checklist
   is `[x]` or waived on its line. On the full path, `spec.md` has
   `## Clarifications`. If clarify found nothing material, the Tech Lead
   adds `### Session YYYY-MM-DD` and
   `- No critical ambiguities found; no questions asked.`
2. `/speckit-plan`, `/speckit-checklist`, `/speckit-tasks`, and
   `/speckit-analyze` — a second PR, after Jorge has merged the spec, with
   `plan.md`, the plan's supporting files, the `/speckit-checklist` files,
   and `tasks.md`. QA records each `/speckit-checklist` item as checked or
   waived, with reasons, in its GitHub review. The pull request author
   applies exactly those marks in a commit titled `qa: checklist` that
   links the review, and QA verifies the commit matches. The PR
   description pastes the analyze report, names the head SHA, and leaves
   no CRITICAL or HIGH finding open. A finding that changes a requirement
   closes this PR; a spec PR lands first; then the plan PR opens again
3. `/speckit-implement` — one task, or a small cohesive group, per PR. It
   stops on an unchecked checklist item. The answer yes is allowed only
   when every unchecked item has a waiver the reviewer accepted
4. `/speckit-converge` — repeat until `Converged`. The last PR stores the
   output in `specs/NNN-name/converge.md` (date, SHA, and verdict)

A small change MAY use the short path: `/speckit-specify`, `/speckit-plan`,
`/speckit-tasks`, `/speckit-implement`, `/speckit-converge`. The spec PR
description contains the exact line `Path: short (small change)`. Jorge's
merge approves it. Clarify, checklist, and analyze are omitted only then.

Feature 001 was approved under constitution 1.0.0. Its plan PR follows the
full path and is the one place that appends `## Clarifications` /
`### Session 2026-10-20` /
`- No critical ambiguities found; no questions asked.` and adds
`checklists/requirements.md`. That diff changes no requirement. Later
features have no such exception.

Jorge approves by merging into `develop`. In `spec.md` the Tech Lead
replaces `**Status**: Draft` with `Status: Approved by Jorge — PR #N` (no
date; the date is the merge commit). In `plan.md` and `tasks.md` that line
is the only status field. An implementation PR is not opened before the
tasks PR is merged. Only one spec, plan, or constitution PR is open at a
time, including a draft. Its branch already contains merged `develop`
(`git merge-base --is-ancestor origin/develop HEAD`). If `develop` moves,
the branch is rebased before Jorge merges. If converge appends tasks that
stay inside the spec, they are implemented in later PRs and converge is
run again. If they would change the spec's scope, another spec PR approved
by Jorge comes first. The principles are in
`.specify/memory/constitution.md` (v1.1.0). The bundled workflow
`.specify/workflows/speckit/workflow.yml` does not replace this flow.
`/speckit-taskstoissues` is not used.

Repository files, site content, and GitHub communication (commits, PR
titles and descriptions, reviews, and comments) are in English.

### Roles

- **Jorge (Product Owner):** approves the constitution, the spec PR
  (including `Path: short (small change)` when present), and the plan PR.
  He is the only person who merges.
- **Tech Lead:** the specify, clarify, plan, checklist, tasks, and analyze
  steps. Adds the empty Clarifications section by hand. Writes waivers
  on `checklists/requirements.md`. Applies QA's checklist marks in the
  `qa: checklist` commit. On a small change, the short path and its
  description line.
- **Web Developer:** `/speckit-implement` and `/speckit-converge`. Answers
  yes to an unchecked checklist only when the reviewer has accepted a
  waiver on every such item.
- **Reviewer:** QA review against the spec, `checklists/requirements.md`,
  the plan, the tasks, the `/speckit-checklist` files, and the constitution
  before asking Jorge to merge. Records `/speckit-checklist` results in
  the GitHub review, then verifies the author's `qa: checklist` commit
  matches that review.

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
