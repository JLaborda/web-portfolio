<!--
Sync Impact Report
- Version change: 2.0.0 → 3.0.0
- Bump rationale: MAJOR. Principle I and the Roles section are redefined
  in a backward-incompatible way: (1) the Tech Lead writes each `docs:`
  pull request through one Cursor cloud agent on the Auto model for the
  whole repository (follow-ups on that agent), not through the GitHub
  API without a cloud agent; (2) that same agent is reused for all of
  the Tech Lead's pull requests and fixes in this repository, and is
  replaced only when its context becomes unmanageable; (3) the feature
  converge pull request title MUST be `chore(NNN): converge` (not a
  `docs:` title). A 2.0.0 docs pull request written via the GitHub API,
  or a converge titled as `docs:`, would not comply with 3.0.0.
- Decision: Jorge (Product Owner), 2026-10-23.
- Modified principles:
  - I. Spec-driven development and PO approval: one `docs:` pull request
    per feature (spec, checklists, plan and supporting files, tasks,
    ADR, and any constitution amendment that permits the feature's
    shape) is written by the Tech Lead through the repository's Cursor
    cloud agent on the Auto model. Reviewer QA does not review it.
    Jorge merges it. Fixes are follow-ups on that same agent and extra
    commits on the same pull request.
  - V. Scoped implementation PRs: the converge pull request title is
    exactly `chore(NNN): converge`. Reviewer QA reviews it; Jorge
    merges it. Intermediate code pull requests still use one cloud
    agent per pull request, reused for that pull request's fixes.
- Modified sections: Roles; Governance (version line).
- Unchanged: one `docs:` pull request per feature; Reviewer QA does not
  review docs; auto-merge of intermediate code pull requests after
  `QA verdict: APPROVED` on the current head SHA and no `needs-human`;
  Jorge merges constitution amendments, non-feature pull requests,
  `needs-human` pull requests, and every release to `main`. Branches
  stay protected.
- Not rewritten: files already merged under 1.1.0, 1.2.0, or 2.0.0,
  including prior `Status:` lines and prior converge titles.
- Added sections: none. Removed sections: none.
- Follow-up TODOs: none
- Templates and commands: unchanged. They read this file at runtime.
-->

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
exact line in the `docs:` pull request description. It is description text,
not a GitHub label:

`Path: short (small change)`

Jorge's merge of that pull request approves the label. Nothing else
approves it. On the short path, `/speckit-clarify`,
`/speckit-checklist`, and `/speckit-analyze` are the only steps that MAY
be omitted.

Jorge (Product Owner) approves and merges the `docs:` pull request that
starts a feature and the converge pull request that closes it. He also
merges an amendment of this constitution, a non-feature pull request, a
pull request that carries the label `needs-human`, and every release
from `develop` to `main`.

An intermediate pull request is an implementation task pull request
between that `docs:` pull request and the converge pull request.
Reviewer QA approves it in a COMMENT review that starts with
`QA verdict: APPROVED` and names its current full head SHA. All bots
share one GitHub account, so GitHub cannot enforce that review. This
rule is the control. Nobody enables auto-merge when the pull request is
opened.

Reviewer QA reviews each code pull request once, and that review flags
every finding. The author fixes them in one push. After that push,
Reviewer QA looks only at the new diff. For the Tech Lead's `docs:`
work in this repository, one Cursor cloud agent on the Auto model
serves the whole repository: it opens the `docs:` pull request, and
fixes arrive as follow-ups on that same agent. That agent is replaced
only when its context becomes unmanageable. For each intermediate
implementation pull request, one cloud agent serves that pull request
and is reused for its fixes.

The pull request author is the agent that opened the pull request.
Reviewer QA never runs `gh pr merge`, with or without `--auto`. The
author runs `gh pr view <n> --json labels` and, only when the APPROVED
verdict names the current head SHA and the label `needs-human` is
absent, runs `gh pr merge --auto --squash`. GitHub then merges when the
required checks are green. If the repository setting "Allow auto-merge"
is off, the author runs `gh pr merge --squash` under the same checks.

A push after that approval invalidates the verdict. The author first
runs `gh pr merge --disable-auto`, then pushes, then waits for a new
verdict that names the new head SHA.

Exception: the Scrum Master Dev flags a step that needs Jorge's personal
verification. The flag is the GitHub label `needs-human` on the pull
request, plus a pull request comment that states the reason, added
before Reviewer QA's verdict. While the label is present, auto-merge
stays off and Jorge merges. If the label is added after auto-merge was
enabled, the author runs `gh pr merge --disable-auto`. The flag covers a
change to the AWS region, a change to DNS or a custom domain, a step
that creates or changes real AWS resources or costs, including bootstrap
and apply, a step that changes IAM permissions or secrets, and a step
that changes branch protection. Only Jorge or the Scrum Master Dev may
remove `needs-human`, with a pull request comment that states the
reason.

When implementation of a spec is finished, the last pull request is the
converge pull request. Its title MUST be exactly `chore(NNN): converge`
(NNN is the feature number). Reviewer QA gives a final sign-off on that
pull request. Jorge then verifies the feature personally. If he
approves, he merges that close. If he does not approve, the work returns
to the point that needs it: the spec, through extra commits on a new
`docs:` pull request, or the implementation, through a new task pull
request.

These rules stay. At most one `docs:` pull request per feature is open.
A pull request MUST NOT depend on an unmerged pull request, except that
a `docs:` pull request MAY wait for a constitution amendment that
permits its shape. The `docs:` pull request comes from branch
`NNN-name`. Only Jorge's merge of the `docs:` pull request approves its
checklist marks and waivers.

Approval is recorded only as follows:

1. One pull request whose title starts with `docs:`, from branch
   `NNN-name`, with base `develop`. It carries every documentation file
   of the feature: `specs/NNN-name/spec.md`,
   `specs/NNN-name/checklists/requirements.md`, `plan.md` and every
   supporting file `/speckit-plan` wrote beside it, `tasks.md`, the
   `/speckit-checklist` files on the full path, and the feature's ADR
   under `docs/adr/` when there is one. It MAY also carry an amendment
   of this constitution when that amendment permits the feature's
   shape. It contains no product code, workflow, or `infra/` change.
   The Tech Lead writes it through this repository's Cursor cloud agent
   on the Auto model (one agent per repository for all of the Tech
   Lead's pull requests and fixes via follow-ups; switch agents only
   when that agent's context becomes unmanageable). There is one such
   `docs:` pull request per spec. Reviewer QA does not review it. Jorge
   reviews and merges it. Fixes go as follow-ups on that agent and as
   extra commits on the same pull request. `spec.md`, `plan.md`, and
   `tasks.md` each carry `Status: Approved by Jorge — PR #N` (N is that
   pull request's number) as the only status field, replacing
   `**Status**: Draft`. The line MUST NOT include a date. Every item in
   `checklists/requirements.md` and in the `/speckit-checklist` files
   MUST be `[x]`, or left unchecked with a waiver and a reason on that
   same line. The Tech Lead writes those marks and waivers. On the full
   path, the description pastes the `/speckit-analyze` report, which
   names the head SHA it ran on and leaves no CRITICAL or HIGH finding
   open; after a later commit that changes `spec.md`, `plan.md`, or
   `tasks.md`, the report is replaced. On the short path, the
   description contains `Path: short (small change)`, and the checklist
   files and the analyze report are not required.

   On the full path, `spec.md` MUST contain `## Clarifications`. When
   clarify accepts answers, it writes `### Session YYYY-MM-DD` and one
   bullet per answer: `- Q: <question> → A: <answer>`. When clarify finds
   nothing material, the Tech Lead adds this text by hand, with
   `YYYY-MM-DD` the day clarify ran:

   ```text
   ## Clarifications

   ### Session YYYY-MM-DD

   - No critical ambiguities found; no questions asked.
   ```

2. An implementation pull request MUST NOT be opened before that
   `docs:` pull request is merged into `develop`.

A later change to a merged `spec.md`, `plan.md`, or `tasks.md` is a new
`docs:` pull request from the same `NNN-name` branch, merged by Jorge,
except for the `tasks.md` lines an implementation pull request may add
under principle V.

`/speckit-implement` MUST stop and ask when any checklist item is
unchecked. The Web Developer MAY answer yes only when every unchecked item
carries a waiver that was in the merged `docs:` pull request. Otherwise
the answer MUST be no.

`/speckit-analyze` is read-only. A CRITICAL or HIGH finding, or a
checklist item, that requires a change to a requirement in `spec.md` is
fixed with an extra commit on the same `docs:` pull request, and analyze
is run again on the new head.

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

The `docs:` pull request comes from `NNN-name`. Each implementation PR
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

**Check:** the `docs:` pull request title starts with `docs:`, comes
from `NNN-name`, and has no product code, workflow, or `infra/` file.
On `develop`, `spec.md`, `plan.md`, and `tasks.md` of a feature merged
under 2.0.0 or 3.0.0 each have `Status: Approved by Jorge — PR #N` and
no other status. Every checklist item there is `[x]` or waived on its
line. On the full path, `spec.md` contains `## Clarifications` and
`### Session YYYY-MM-DD`, with either `- Q:` / `→ A:` bullets or the
exact line `- No critical ambiguities found; no questions asked.`, and
the description has an analyze report on the head SHA with no open
CRITICAL or HIGH finding. A short-path description contains the exact
line `Path: short (small change)`. A converge pull request merged under
3.0.0 is titled `chore(NNN): converge`. `converge.md` has
`Status: Approved by Jorge — PR #N`. Files merged under 1.1.0, 1.2.0, or
2.0.0 are not rewritten to the new converge title. No implementation pull request is opened before the
`docs:` merge. `git merge-base --is-ancestor origin/develop HEAD` exits
0 on its branch. Every feature pull request targets `develop`. `main`
has only merges from `develop` made by Jorge.
`git check-ignore -v .specify/feature.json` reports an ignore rule. An
intermediate pull request does not have auto-merge enabled when it is
opened; its author enables it only after a `QA verdict: APPROVED`
COMMENT review that names the current full head SHA, and only when
`needs-human` is absent. Reviewer QA does not run `gh pr merge`.

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
  plan. v1.1.0 said: "The bucket region and DNS MUST be decided in the
  deployment feature's plan, and that plan MUST have Jorge's approval
  before it is implemented." That approval is unchanged. Any change to
  the AWS region, to DNS or a custom domain, or to anything that creates
  real AWS resources or costs needs Jorge's explicit approval. The pull
  request that carries that change, whether it is a `docs:` or an
  implementation pull request, MUST carry the label `needs-human`. Jorge
  merges it. It never auto-merges. This constitution does not fix region
  or DNS.

**Check:** the plan role's policy does not allow apply or changes to S3 or
CloudFront; the deploy role's Environment requires protection and is not
available on PRs; the deployment feature's `plan.md` records region and
DNS with Jorge's approval. v1.1.0 said the plan "records region and DNS
with Jorge's approval." That check is unchanged. A pull request that
changes region, DNS, or a custom domain, or that creates real AWS
resources or costs, carries `needs-human`. Jorge approves and merges it.
`plan.md`, `tasks.md`, or another intermediate artifact in that pull
request uses `Status: Approved by Jorge — PR #N`. It never auto-merges.
gitleaks finds no static keys.

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
`tasks.md` only to mark `[X]` the ids it closes, or to add or update the
line of the task it closes, inside the scope of the merged `spec.md`. It
MUST NOT rewrite other tasks. No separate tasks pull request is needed
for that line.

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
NOT be implemented before a new `docs:` pull request under principle I,
merged by Jorge.

The last implementation PR of the feature is the one that gets
`Converged`. Its title MUST be exactly `chore(NNN): converge`. It MUST
add `specs/NNN-name/converge.md` with the full output of that final run,
the date, the SHA of the commit it ran on, and the verdict `Converged`.
`converge.md` also carries `Status: Approved by Jorge — PR #N` as its
only status field, with no date. The PR description MUST paste that
verdict. QA MUST block the PR if the file is missing, the verdict is
not `Converged`, or the title is not `chore(NNN): converge`.

Reviewer QA MUST review each code pull request against `spec.md`,
`plan.md`, `tasks.md`, the checklist files when the full path applies,
`converge.md` when it is the last PR, and this constitution, in one
round that flags every finding. After the fix push, it reviews only the
new diff. On an intermediate pull request, the review that allows the
author to run `gh pr merge --auto --squash` is a COMMENT review that
starts with `QA verdict: APPROVED` and names the current full head SHA.
On the converge pull request (`chore(NNN): converge`), the review is the
final sign-off, and Jorge merges only after it. Without that review on
the current head, a code pull request MUST NOT be merged.

**Check:** the description lists the ids, `tasks.md` has them as `[X]`,
and there are no extra or missing ids. A PR that is not the converge PR
changes `tasks.md` only for the ids it closes and does not change
`spec.md` or `plan.md`. The last PR is titled `chore(NNN): converge`,
contains `converge.md` with the date, the SHA, and `Converged`, and the
description repeats the verdict. If the file is missing, the title is
wrong, or the verdict is anything else, QA blocks the PR.

### VI. Explainable in an interview, and cheap

Solutions SHOULD be simple and documented, so they can be explained
end to end in an MLOps interview. The site's monthly cost MUST stay around
0–1 USD. v1.1.0 said this holds "unless an exception is documented in the
plan and approved by Jorge." That approval is unchanged. A pull request
that documents such an exception, or that creates real AWS resources or
costs, MUST carry `needs-human`. Jorge merges it. It never auto-merges.
An opaque service that hides the infrastructure MUST NOT be added
when a documented primitive meets the requirement.

**Check:** the feature's `plan.md` names the services and the expected
monthly cost; a service outside principle III is not implemented without
an amendment to this constitution or without Jorge's explicit approval in
that plan. v1.1.0 said the same sentence, ending "or without Jorge's
explicit approval in that plan." That approval is unchanged. The pull
request that carries the exception or the new service MUST have
`needs-human`, and Jorge merges it. It never auto-merges.

### VII. English only

All repository content MUST be in English. That includes specs, plans,
tasks, commit messages, and every other file committed to the repo. All
GitHub communication MUST be in English: pull request titles and
descriptions, reviews, and comments. Site content MUST be in English.

**Check:** a non-English sentence in a committed file, PR title, PR body,
review, or comment fails review. Pages under `content/` are English.

## Roles

- **Jorge (Product Owner).** Approves this constitution by merging it.
  Reviews and merges each feature's `docs:` pull request, including
  `Path: short (small change)` when that line is present, and the
  converge pull request that closes it. Merges a pull request that
  carries `needs-human`, a non-feature pull request, and every release
  from `develop` to `main`. Does not manually merge an intermediate
  pull request. Enables the repository setting "Allow auto-merge".
- **Tech Lead.** Runs `/speckit-specify`, `/speckit-clarify`,
  `/speckit-plan`, `/speckit-checklist`, `/speckit-tasks`, and
  `/speckit-analyze` on the full path, or specify, plan, and tasks on
  the short path. Writes each feature's `docs:` pull request (spec,
  plan, tasks, checklists, ADR when there is one, and a constitution
  amendment when needed) through this repository's Cursor cloud agent
  on the Auto model. One such agent serves all of the Tech Lead's pull
  requests and fixes in this repository via follow-ups; switch to a
  new agent only when that agent's context becomes unmanageable. One
  `docs:` pull request per spec. Includes the checklist marks and
  waivers, and `Status: Approved by Jorge — PR #N` on `spec.md`,
  `plan.md`, and `tasks.md`. Fixes with follow-ups and extra commits on
  the same pull request. Never enables auto-merge on a `docs:` pull
  request. Reviewer QA does not review `docs:` pull requests; Jorge
  merges them.
- **Web Developer.** Runs `/speckit-implement` and, on the feature's last
  PR, `/speckit-converge`, with one cloud agent per implementation pull
  request that is reused for that pull request's fixes. The converge
  pull request title is exactly `chore(NNN): converge`. When implement
  stops on an unchecked checklist item, MAY answer yes only when every
  unchecked item carries a waiver that was in the merged `docs:` pull
  request. Does not enable auto-merge when opening a pull request. On
  an implementation pull request that is not the converge pull request,
  runs `gh pr merge --auto --squash` only after `QA verdict: APPROVED`
  names the current head SHA and `gh pr view <n> --json labels` shows
  no `needs-human`. Before a later push, first runs
  `gh pr merge --disable-auto`. Does not run `gh pr merge` on the
  converge pull request. Jorge merges it after Reviewer QA's sign-off.
- **Reviewer (QA).** Reviews code pull requests only, never a `docs:`
  pull request. One review round flags every finding; after the fix
  push, reviews only the new diff. Reviews against `spec.md`,
  `checklists/requirements.md`, `plan.md`, `tasks.md`, the
  `/speckit-checklist` files when the full path applies, and this
  constitution. The intermediate approval is a COMMENT review that
  starts with `QA verdict: APPROVED` and names the full head SHA.
  Never runs `gh pr merge`, with or without `--auto`. On the converge
  pull request titled `chore(NNN): converge`, gives the final
  sign-off, checks that `converge.md` exists and says `Converged`, and
  Jorge merges after his own verification.
- **Scrum Master Dev.** Does not merge and does not run `gh pr merge`.
  When a step needs Jorge's personal verification, adds the label
  `needs-human` and a pull request comment with the reason, before
  Reviewer QA's verdict. The reason is a change to the AWS region, a
  change to DNS or a custom domain, real AWS resources or costs
  (including bootstrap and apply), IAM permissions or secrets, or branch
  protection. If the label does not exist yet, whoever first needs it
  creates it once with `gh label create needs-human`. If the label is
  added after auto-merge was enabled, the pull request author runs
  `gh pr merge --disable-auto`. Only Jorge or the Scrum Master Dev may
  remove `needs-human`. Whoever removes it MUST add a pull request
  comment that states the reason. No other role may remove the label.

## Branches and releases

Spec Kit numbers each feature as `NNN-name` and creates
`specs/NNN-name/spec.md`. `plan.md` and `tasks.md` live in that same
directory. New specs MUST live only there. A feature MUST NOT be opened
under `docs/specs/`.

- Branch `NNN-name` MUST be used for the feature's `docs:` pull request,
  which targets `develop`.
- Each implementation PR MUST use a short-lived branch `NNN-name-tXX`
  (for example `001-hugo-site-t01`), created from `develop`, with a PR to
  `develop`. It may close one task or a cohesive group; the ids go in the
  description and are marked `[X]` in `tasks.md`.
- Those PRs MUST be merged one at a time. Two features MUST NOT be merging
  into `develop` at the same time.
- At most one `docs:` pull request per feature MAY be open. A draft
  counts as open. The branch MUST already contain the merged `develop`:
  `git merge-base --is-ancestor origin/develop HEAD` exits 0. If
  `develop` moves while the pull request is open, the branch MUST be
  rebased onto that new `develop` before the pull request merges.
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

Before posting `QA verdict: APPROVED` or a converge sign-off, Reviewer
QA MUST check compliance with this constitution. Reviewer QA does not
run `gh pr merge`. A PR that contradicts a principle MUST NOT be merged.

**Version**: 3.0.0 | **Ratified**: 2026-10-20 | **Last Amended**: 2026-10-23
