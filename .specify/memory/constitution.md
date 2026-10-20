# web-portfolio Constitution

## Core Principles

### I. Spec-driven development and PO approval

Development MUST NOT start without a `spec.md` approved by Jorge (Product
Owner). `/speckit-constitution` is set once for the project. A later
amendment is its own pull request and is not a feature step.

A feature MUST follow the full path, in this order: `/speckit-specify`,
`/speckit-clarify`, `/speckit-plan`, `/speckit-checklist`,
`/speckit-tasks`, `/speckit-analyze`, `/speckit-implement`,
`/speckit-converge`. On that path a step MUST NOT be skipped.

The short path MAY be used only for a small change. It is, in this order:
`/speckit-specify`, `/speckit-plan`, `/speckit-tasks`,
`/speckit-implement`, `/speckit-converge`. The Tech Lead MUST label that
choice in the spec pull request description as a small change that uses
the short path. Jorge's merge of that pull request approves the label.
Nothing else approves it. On the short path, `/speckit-clarify`,
`/speckit-checklist`, and `/speckit-analyze` are the only steps that MAY
be omitted.

Only Jorge MAY merge. Any other person or bot MUST NOT merge.

Approval is recorded only as follows, and in this order:

1. A PR from branch `NNN-name`, with base `develop`, that contains only
   `specs/NNN-name/spec.md`. That file is the result of
   `/speckit-specify`. On the full path it is also the result of
   `/speckit-clarify`, and it MUST contain the Clarifications section that
   command writes. When clarify accepts answers, that section records each
   one. When clarify finds nothing material, that section states that no
   material ambiguity remained. On the short path, clarify is not run, that
   section is not required, and the description carries the small-change
   label. In that PR the Tech Lead MUST replace the template field
   `**Status**: Draft` with
   `Status: Approved by Jorge — PR #N`
   (N is that PR's number). The field is replaced: `Status: Draft` MUST NOT
   remain, and a second status field MUST NOT be added. The line MUST NOT
   include a date. The approval date is the merge commit in git history.
   Jorge merges it.
2. Then a second PR from the same branch `NNN-name`. It MUST contain
   `plan.md`, every supporting file `/speckit-plan` wrote beside it, and
   `tasks.md`. On the full path it MUST also contain `checklists/*.md`
   from `/speckit-checklist`. Every item in those files MUST be marked
   `[x]`, or left unchecked with an explicit waiver and a reason written
   on that item. The agent MUST NOT mark an item `[x]`. The reviewer does.
   The description MUST paste the `/speckit-analyze` report, and that
   report MUST leave no CRITICAL or HIGH finding open. On the short path,
   the checklist files and the analyze report are not required, and the
   description MUST point at the merged spec's small-change label. Those
   templates have no `Status` field. The Tech Lead MUST add the same line
   to `plan.md` and to `tasks.md`, with this second PR's number, as the
   only status field. Another status field MUST NOT be added. `spec.md`
   MUST already be on `develop` before this PR is opened: Jorge approves
   the spec before the plan and the tasks.
3. An implementation PR MUST NOT be opened before the `tasks.md` PR is
   merged into `develop`.

Spec, plan, and tasks PRs come from `NNN-name`. Each implementation PR
comes from a short-lived branch `NNN-name-tXX`, created from `develop`,
and targets `develop`. The `NNN-` prefix is a human convention so the
branch can be read next to `specs/NNN-name/`. Spec Kit 1.2.2 scripts do
not resolve the directory from the git branch name.

In `get_feature_paths()` (`.specify/scripts/bash/common.sh`) the directory
comes only from `SPECIFY_FEATURE_DIRECTORY` or from `.specify/feature.json`.
On a task branch, before those scripts, the session MUST export
`SPECIFY_FEATURE_DIRECTORY=specs/NNN-name`. Without that, and without
`feature.json`, the script exits with an error. `SPECIFY_FEATURE` is
optional: `get_current_branch()` only copies it to `CURRENT_BRANCH`. It
MUST NOT be used on its own to find the feature.

`.specify/feature.json` is per-developer state. `_persist_feature_json`
rewrites it when `SPECIFY_FEATURE_DIRECTORY` is used, except with
`--paths-only` or `--no-persist`. It MUST NOT be committed. It is ignored
in `.gitignore` and in `.specify/.gitignore`.

PRs for one feature MUST be merged one at a time. Work from two features
MUST NOT be merged in parallel. `main` MUST receive only releases from
`develop`, and Jorge MUST perform that merge.

`.specify/workflows/speckit/workflow.yml` does not govern this repo: it
ends at implement, it does not include converge, and its integration list
is advisory (it does not name `cursor-agent`). This constitution's flow
governs. `/speckit-taskstoissues` is deprecated in 1.2.2 and MUST NOT be
used.

**Check:** on `develop`, `spec.md` has
`Status: Approved by Jorge — PR #N` and does not have `Status: Draft`.
On the full path that file contains a Clarifications section. `plan.md`
and `tasks.md` have their PR's line and no other status. On the full path
every checklist item is `[x]` or waived with a reason, and the plan PR
description's analyze report has no open CRITICAL or HIGH finding. No
implementation PR is open before that second merge. At most one spec,
plan, or constitution PR is open, and its branch is based on the already
merged `develop`. Every feature PR targets `develop`. `main` has only
merges from `develop` made by Jorge.
`git check-ignore -v .specify/feature.json` reports an ignore rule.

### II. Fixed stack

The site MUST be built with Hugo extended at a version pinned in one
place and documented. The PaperMod theme MUST be a git submodule at
`themes/PaperMod` pinned to a release tag, not a branch. The theme MUST
NOT be edited.

The customization limit applies to theme overrides and to project CSS or
JS: those MUST live only in `layouts/` or `assets/`. It MUST NOT apply to
configuration or content. `hugo.yaml`, `content/`, `static/` (including a
PDF or images), and `i18n/` are allowed.

**Check:** the submodule pointer is a tag; the diff does not modify files
inside `themes/PaperMod` except that pointer; there is no project CSS or
JS outside `layouts/` and `assets/`. `hugo.yaml`, `content/`, `static/`,
and `i18n/` do not count as theme edits.

### III. AWS hosting as a constraint

Hosting MUST be AWS, with these rules:

- A private S3 bucket (Block Public Access enabled) and CloudFront with
  Origin Access Control (OAC). The ACM certificate MUST be in `us-east-1`.
- Infrastructure MUST be defined with Terraform and remote state.
- GitHub Actions MUST authenticate with OIDC. Long-lived AWS keys MUST NOT
  be used. Permissions MUST be least privilege.
- Two distinct OIDC roles MUST exist. The PR role MUST be read-only and
  MUST be used for `terraform plan`; that role MUST NOT be able to apply
  or deploy. The apply/deploy role MUST be a different role, and MUST be
  restricted to `main` (or to `develop`, if a later decision moves deploys
  there) through a protected GitHub Environment.
- An AWS Budgets alert of about 1 USD per month MUST exist.
- The bucket region and DNS MUST be decided in the deployment feature's
  plan, and that plan MUST have Jorge's approval before it is implemented.
  This constitution does not fix region or DNS.

**Check:** the plan role's policy does not allow apply or changes to S3 or
CloudFront; the deploy role's Environment requires protection and is not
available on PRs; the deployment feature's `plan.md` records region and
DNS with Jorge's approval; gitleaks finds no static keys.

### IV. Verifiable quality in CI

These gates MUST pass before a merge, on feature PRs and on non-feature
PRs:

- `hugo --gc --minify --panicOnWarning` finishes with no errors. In CI the
  site MUST be built with a relative or local `baseURL` (for example
  `--baseURL /`).
- Internal links MUST be checked with lychee against `public/` using
  `--root-dir` (pointing at `public/`) so site-absolute paths resolve
  locally. A broken internal link MUST fail CI. A broken external link
  MUST NOT fail the merge: lychee MUST treat it only as a warning.
- The gitleaks secret scan MUST pass. The test that proves the gate fails
  MUST use a synthetic secret that the gitleaks ruleset actually detects.
  `AKIAIOSFODNN7EXAMPLE` MUST NOT be used: the default rules allowlist it,
  so the test would not fail.
- On PRs that touch Terraform, `terraform fmt -check`, `terraform validate`,
  `tflint`, and `terraform plan` MUST run (the last one with the read-only
  OIDC role from principle III).

Every acceptance criterion MUST be checkable in CI or by a concrete manual
step described in `spec.md` or `tasks.md`. A required gate in the red MUST
block the merge. Once those workflows exist, `develop` and `main` MUST
have branch protection with those checks required. Jorge SHOULD NOT bypass
that protection, even as an admin. Turning the protection on is an
acceptance criterion of the spec that introduces CI.

**Check:** a missing shortcode, a broken internal link (for example
`[x](/does-not-exist/)`) or the synthetic secret makes the matching job
fail; without them, the job passes. `lychee` is invoked with `--root-dir`
on the `public/` built with `--baseURL /`. A broken external link stays a
warning and the job stays green.

### V. Scoped implementation PRs

Each implementation PR MUST be small and MUST cover one task or a small
cohesive group of tasks from `tasks.md`. It MUST come from branch
`NNN-name-tXX`, created from `develop`, with base `develop`.

That PR MUST link `spec.md` and `tasks.md`. It MUST explain which
acceptance criteria it covers and how to test them. It MUST list in the
description the task ids it closes (for example `T012`, `T013`). It MUST
mark those same ids done (`[X]`) in `specs/NNN-name/tasks.md`, in the same
change. The ids in the description and in `tasks.md` MUST match.

Except for the converge case below, an implementation PR MUST change
`tasks.md` only to mark `[X]` the ids it closes.

`/speckit-converge` reads `spec.md`, `plan.md`, and `tasks.md`. If work
remains, the result is `tasks_appended`: it only appends
`## Phase N: Convergence` at the end of `tasks.md`. It MUST NOT rewrite
existing tasks and MUST NOT modify `spec.md` or `plan.md`. If no work
remains, the result is `Converged` and `tasks.md` does not change. The
skill does not save that output to a file: the PR MUST do so, as stated
below.

If the appended tasks fit inside the already approved `spec.md`, they stay
in `tasks.md` and MUST be implemented in later `NNN-name-tXX` PRs, under
the same rules. `/speckit-converge` MUST then be run again until
`Converged`.

If an appended task would require changing the scope of `spec.md`, it MUST
NOT be implemented before a new spec PR. That PR only updates `spec.md`,
follows principle I (the full path, unless the Tech Lead labels a small
change and Jorge's merge approves the short path), replaces the status
with `Status: Approved by Jorge — PR #N` for that PR, and Jorge merges it.

The last implementation PR of the feature is the one that gets
`Converged`. It MUST add `specs/NNN-name/converge.md` with the full output
of that final run, the date, the SHA of the commit it ran on, and the
verdict `Converged`. The PR description MUST paste that verdict. QA MUST
block the PR if the file is missing or the verdict is not `Converged`.

The Reviewer MUST review against `spec.md`, `plan.md`, `tasks.md`, the
checklist files when the full path applies, `converge.md` when it is the
last PR, and this constitution before asking Jorge to merge.
Without that review, the PR MUST NOT be merged.

**Check:** the description lists the ids, `tasks.md` has them as `[X]`,
and there are no extra or missing ids. A PR that is not the converge PR
does not rewrite tasks or change `spec.md`. The last PR contains
`converge.md` with the date, the SHA, and `Converged`, and the description
repeats the verdict. If the file is missing or the verdict is anything
else, QA blocks the PR. The QA review is recorded before Jorge's merge.

### VI. Explainable in an interview, and cheap

Solutions SHOULD be simple and documented, so they can be explained
end to end in an MLOps interview. The site's monthly cost MUST stay around
0–1 USD, unless an exception is documented in the plan and approved by
Jorge. An opaque service that hides the infrastructure MUST NOT be added
when a documented primitive meets the requirement.

**Check:** the feature's `plan.md` names the services and the expected
monthly cost; a service outside principle III is not implemented without
an amendment to this constitution or without Jorge's explicit approval in
that plan.

### VII. English only

All repository content MUST be in English. That includes specs, plans,
tasks, commit messages, and every other file committed to the repo. All
GitHub communication MUST be in English: pull request titles and
descriptions, reviews, and comments. Site content MUST be in English.

**Check:** a non-English sentence in a committed file, PR title, PR body,
review, or comment fails review. Pages under `content/` are English.

## Roles

- **Jorge (Product Owner).** Approves this constitution by merging it.
  Approves each `spec.md` in its PR, including a short-path label when one
  is present, and, after that, the plan and tasks PR. He is the only person
  who merges. Releases from `develop` to `main` are always merged by Jorge.
- **Tech Lead.** On the full path, runs `/speckit-specify`,
  `/speckit-clarify`, `/speckit-plan`, `/speckit-checklist`,
  `/speckit-tasks`, and `/speckit-analyze`. On a small change, labels the
  short path in the spec PR and runs `/speckit-specify`, `/speckit-plan`,
  and `/speckit-tasks`. Writes the `Status: Approved by Jorge — PR #N`
  line in those PRs.
- **Web Developer.** Runs `/speckit-implement` and, on the feature's last
  PR, `/speckit-converge`.
- **Reviewer.** Reviews against `spec.md`, `plan.md`, `tasks.md`, the
  checklist files when the full path applies, and this constitution before
  asking Jorge to merge. Checks that `Status: Approved by Jorge — PR #N`
  replaces `Status: Draft`, that checklist items are `[x]` or waived with
  a reason, that the analyze report has no open CRITICAL or HIGH finding,
  checks the task ids, and, on the last PR, checks that `converge.md`
  exists and says `Converged`. The reviewer marks checklist items `[x]`.

## Branches and releases

Spec Kit numbers each feature as `NNN-name` and creates
`specs/NNN-name/spec.md`. `plan.md` and `tasks.md` live in that same
directory. New specs MUST live only there. A feature MUST NOT be opened
under `docs/specs/`.

- Branch `NNN-name` MUST be used for the `spec.md` PR and for the later
  `plan.md` + `tasks.md` PR. Both target `develop`.
- Each implementation PR MUST use a short-lived branch `NNN-name-tXX`
  (for example `001-hugo-site-t01`), created from `develop`, with a PR to
  `develop`. It may close one task or a cohesive group; the ids go in the
  description and are marked `[X]` in `tasks.md`.
- Those PRs MUST be merged one at a time. Two features MUST NOT be merging
  into `develop` at the same time.
- At most one spec, plan, or constitution pull request MAY be open. It
  MUST be based on what is already merged in `develop`. The next one is
  opened only after Jorge merges the previous one.
- On a branch `NNN-name-tXX` the session MUST export
  `SPECIFY_FEATURE_DIRECTORY=specs/NNN-name` before the scripts.
  `SPECIFY_FEATURE` is optional and does not locate the directory.
  `.specify/feature.json` is local state, gitignored, and MUST NOT be
  committed.

### Non-feature branches

`chore/`, `docs/`, `fix/`, and `ci/` MAY be used for a change with no new
user-visible behavior (tooling, process documentation, fixes that do not
change the product, CI). The PR MUST target `develop`, MUST pass the same
CI gates, and Jorge MUST merge it. Any new behavior MUST have a spec
(`specs/NNN-name/`) and MUST NOT land on these branches.

Amendments to this constitution follow that rule (`chore/` or `docs/`)
unless they change visible behavior, in which case they require a spec.
The `develop` → `main` release is not a feature branch: it MUST pass the
same gates and only Jorge MUST merge it.

## Governance

This constitution overrides informal practice. An amendment MUST be
proposed in a pull request to `develop` and MUST be approved and merged by
Jorge. Until that merge, the amendment is not in force.

Versioning MUST follow Semantic Versioning:

- **MAJOR:** a principle or governance rule is removed or redefined in a
  backward-incompatible way.
- **MINOR:** a principle or section is added, or a rule is materially
  expanded.
- **PATCH:** clarifications, wording fixes, or changes that do not change
  the meaning.

Each amendment after ratification MUST update the version line and the
last-amended date. Version 1.0.0 was ratified when Jorge merged it. The
ratification date is 2026-10-20 and does not change. This amendment is
1.1.0. Its last-amended date is 2026-10-20.

Before asking for a merge, the Reviewer MUST check compliance with this
constitution. A PR that contradicts a principle MUST NOT be merged.

**Version**: 1.1.0 | **Ratified**: 2026-10-20 | **Last Amended**: 2026-10-20
