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
`/speckit-implement`, `/speckit-converge`. The Tech Lead MUST put this
exact line in the spec pull request description. It is description text,
not a GitHub label:

`Path: short (small change)`

Jorge's merge of that pull request approves the label. Nothing else
approves it. On the short path, `/speckit-clarify`,
`/speckit-checklist`, and `/speckit-analyze` are the only steps that MAY
be omitted.

Only Jorge MAY merge. Any other person or bot MUST NOT merge.

Approval is recorded only as follows, and in this order:

1. A PR from branch `NNN-name`, with base `develop`, that contains exactly
   `specs/NNN-name/spec.md` and
   `specs/NNN-name/checklists/requirements.md`. No other file. `spec.md` is
   the result of `/speckit-specify`. On the full path it is also the result
   of `/speckit-clarify`. `checklists/requirements.md` is the spec-quality
   checklist `/speckit-specify` writes. `/speckit-specify` and
   `/speckit-clarify` maintain it, and they MAY mark its items `[x]`.
   Every item MUST be `[x]`, or left unchecked with a waiver and a reason
   on that same line. Checklist files from `/speckit-checklist` MUST NOT
   be in this PR. In that PR the Tech Lead MUST replace the template field
   `**Status**: Draft` with
   `Status: Approved by Jorge — PR #N`
   (N is that PR's number). The field is replaced: `Status: Draft` MUST NOT
   remain, and a second status field MUST NOT be added. The line MUST NOT
   include a date. The approval date is the merge commit in git history.
   Jorge merges it.

   On the full path, `spec.md` MUST contain `## Clarifications`. When
   clarify accepts answers, it writes `### Session YYYY-MM-DD` and one
   bullet per answer: `- Q: <question> → A: <answer>`. When clarify finds
   nothing material, it writes nothing. The Tech Lead MUST then add this
   text by hand, with `YYYY-MM-DD` the day clarify ran:

   ```text
   ## Clarifications

   ### Session YYYY-MM-DD

   - No critical ambiguities found; no questions asked.
   ```

   On the short path, clarify is not run, that section is not required, and
   the description contains the line `Path: short (small change)`.
2. Then a second PR from the same branch `NNN-name`. It MUST contain
   `plan.md`, every supporting file `/speckit-plan` wrote beside it, and
   `tasks.md`. On the full path it MUST also contain the checklist files
   `/speckit-checklist` wrote. Except for feature 001 below, it MUST NOT
   add or rewrite `checklists/requirements.md`, which landed in the spec
   PR. Every item
   in the `/speckit-checklist` files MUST be `[x]`, or left unchecked with
   a waiver and a reason on that same line. No commit except the
   `qa: checklist` commit below may mark an item `[x]` or add a waiver in
   those files. The description MUST paste the `/speckit-analyze`
   report. That report MUST name the full head SHA it ran on and MUST leave
   no CRITICAL or HIGH finding open. After any later push that changes
   `spec.md`, `plan.md`, or `tasks.md`, analyze MUST be run again on that
   new head and the description MUST replace the report. On the short path,
   those checklist files and the analyze report are not required, and the
   description MUST quote `Path: short (small change)` from the merged spec
   PR. `plan.md` and `tasks.md` have no `Status` field in their templates.
   The Tech Lead MUST add the same approval line to each, with this second
   PR's number, as the only status field. Another status field MUST NOT be
   added. Except for the feature 001 transition below, `spec.md` MUST
   already be on `develop` before this PR is opened, and this PR MUST NOT
   change it. Jorge approves the spec before the plan and the tasks.
3. An implementation PR MUST NOT be opened before the `tasks.md` PR is
   merged into `develop`.

A waiver on `checklists/requirements.md` leaves the item as `- [ ]` and
puts the reason on that same line. The Tech Lead writes it. The Reviewer
accepts or rejects it in the review. An unchecked item whose waiver the
Reviewer has not accepted blocks the pull request.

For a file from `/speckit-checklist`, QA records each item in its GitHub
review as checked or waived, with the reason for each waiver. QA cannot
push. The pull request author applies exactly those marks in one commit
on branch `NNN-name` titled `qa: checklist`, and the commit message links
that review. QA then verifies that the commit matches the review before
asking Jorge to merge. This limit does not apply to
`checklists/requirements.md`, which specify and clarify maintain.

`/speckit-implement` MUST stop and ask when any checklist item is
unchecked. The Web Developer MAY answer yes only when every unchecked item
carries a waiver the Reviewer has accepted. Otherwise the answer MUST be
no.

`/speckit-analyze` is read-only. A CRITICAL or HIGH finding, or a checklist
item, that requires a change to a requirement in `spec.md` MUST NOT be
fixed in the plan pull request. That plan pull request MUST be closed. A
draft still counts as open, so converting it to a draft does not free the
slot. A spec pull request is then opened under rule 1. After Jorge merges
it, the plan pull request is opened again from that merge, and analyze is
run on the new head. At most one of those pull requests is open at a time.

**Feature 001.** This is the only transition, and later features have no
exception. `specs/001-minimal-hugo-site/spec.md` was approved under
constitution 1.0.0. It has no `## Clarifications` section and no short-path
label. From the plan onward, feature 001 MUST follow the full path. It
MUST NOT open a new spec pull request for this transition.
`/speckit-clarify` ran on 2026-10-20 and found no critical ambiguities. The
001 plan pull request MUST append only this text to that `spec.md`:

```text
## Clarifications

### Session 2026-10-20

- No critical ambiguities found; no questions asked.
```

That pull request MUST also add
`specs/001-minimal-hugo-site/checklists/requirements.md`, with every item
`[x]` or waived with a reason. Neither change alters a requirement, so no
new spec approval is required. QA MUST verify that the diff to `spec.md`
is only that Clarifications section.

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
The spec PR diff lists exactly `spec.md` and
`checklists/requirements.md`, and every item there is `[x]` or waived on
its line. On the full path, `spec.md` contains `## Clarifications` and
`### Session YYYY-MM-DD`, with either `- Q:` / `→ A:` bullets or the exact
line `- No critical ambiguities found; no questions asked.` A short-path
spec PR description contains the exact line `Path: short (small change)`.
`plan.md` and `tasks.md` have their PR's line and no other status. On the
full path, `[x]` marks and waivers in `/speckit-checklist` files appear
only in a commit titled `qa: checklist` that links the QA review, that
review records the same checked and waived items, the analyze report names the
head SHA, and that report has no open CRITICAL or HIGH finding. For
feature 001, the plan PR diff to `spec.md` is only the Session 2026-10-20
block above, and it adds `checklists/requirements.md`. No implementation
PR is open before that second merge. At most one spec, plan, or
constitution PR is open.
`git merge-base --is-ancestor origin/develop HEAD` exits 0 on its branch.
Every feature PR targets `develop`. `main` has only merges from `develop`
made by Jorge. `git check-ignore -v .specify/feature.json` reports an
ignore rule.

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
NOT be implemented before a new spec PR. That PR follows principle I,
including `checklists/requirements.md` and the path choice, replaces the
status with `Status: Approved by Jorge — PR #N` for that PR, and Jorge
merges it.

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
  Approves each spec PR, including `Path: short (small change)` when that
  line is present, and, after that, the plan and tasks PR. He is the only
  person who merges. Releases from `develop` to `main` are always merged
  by Jorge.
- **Tech Lead.** On the full path, runs `/speckit-specify`,
  `/speckit-clarify`, `/speckit-plan`, `/speckit-checklist`,
  `/speckit-tasks`, and `/speckit-analyze`. When clarify finds nothing
  material, adds the `## Clarifications` section by hand. On a small
  change, puts `Path: short (small change)` in the spec PR description and
  runs `/speckit-specify`, `/speckit-plan`, and `/speckit-tasks`. Writes
  waivers on unchecked `checklists/requirements.md` items. After QA's
  review, applies the `/speckit-checklist` marks in a commit titled
  `qa: checklist` that links the review. Writes the
  `Status: Approved by Jorge — PR #N` line in those PRs.
- **Web Developer.** Runs `/speckit-implement` and, on the feature's last
  PR, `/speckit-converge`. When implement stops on an unchecked checklist
  item, the Web Developer MAY answer yes only when every unchecked item
  carries a waiver the Reviewer has accepted.
- **Reviewer.** Reviews against `spec.md`,
  `checklists/requirements.md`, `plan.md`, `tasks.md`, the
  `/speckit-checklist` files when the full path applies, and this
  constitution before asking Jorge to merge. Accepts or rejects each
  waiver on `checklists/requirements.md`. Records each
  `/speckit-checklist` item as checked or waived, with reasons, in the
  GitHub review. After the `qa: checklist` commit, verifies that it matches
  that review. Checks the status line, the Clarifications text, the analyze
  report's head SHA and open findings, the task ids, and, on the last PR,
  that `converge.md` exists and says `Converged`.

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
- At most one spec, plan, or constitution pull request MAY be open. A
  draft counts as open. The branch MUST already contain the merged
  `develop`: `git merge-base --is-ancestor origin/develop HEAD` exits 0.
  If `develop` moves while the pull request is open, the branch MUST be
  rebased onto that new `develop` before Jorge merges. The next pull
  request is opened only after that merge.
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
ratification date is 2026-10-20 and does not change. The last-amended date
is the date Jorge merges the amendment. If that merge falls on a later day
than the date written in the pull request, the same pull request MUST set
the last-amended date to the merge date before it is merged.

Before asking for a merge, the Reviewer MUST check compliance with this
constitution. A PR that contradicts a principle MUST NOT be merged.

**Version**: 1.1.0 | **Ratified**: 2026-10-20 | **Last Amended**: 2026-10-20
