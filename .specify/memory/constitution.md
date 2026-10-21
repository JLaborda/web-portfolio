<!--
Sync Impact Report
- Version change: 1.1.0 → 1.2.0
- Bump rationale: MINOR, and the version stays 1.2.0 because this
  amendment is not merged yet. Jorge still merges the spec, the converge,
  a constitution amendment, a pull request labeled `needs-human`, a
  non-feature pull request, and every release from develop to main. The
  new rule adds who merges an intermediate pull request. It narrows
  "Only Jorge MAY merge" and does not remove those remaining duties, so
  this is not a MAJOR redefinition.
- Follow-up on the unmerged 1.2.0 text, from review 5601953766:
  - Auto-merge is not enabled when a pull request is opened. The author
    runs `gh pr merge --auto --squash` only after a COMMENT review that
    starts with `QA verdict: APPROVED` and names the current head SHA,
    and only when the label `needs-human` is absent.
  - A later push or that label requires `gh pr merge --disable-auto`.
  - `spec.md` and `converge.md` keep `Status: Approved by Jorge — PR #N`.
    A plan, tasks, or other intermediate artifact merged with
    `needs-human` uses `Status: Approved by Jorge — PR #N`. Without that
    label, a pull request opened after this amendment merges uses
    `Status: Approved by Reviewer QA — PR #N`. Files already merged under
    v1.1.0, including specs/001 and the specs/002 plan and tasks, are not
    rewritten.
- Modified principles:
  - I. Spec-driven development and PO approval (merge authority)
  - III. AWS hosting as a constraint (region, DNS, and real AWS cost
    still need Jorge's approval, enforced with `needs-human`)
  - V. Scoped implementation PRs (review, then who merges)
  - VI. Explainable in an interview, and cheap (a cost exception still
    needs Jorge's approval, enforced with `needs-human`)
- Modified sections: Roles; Branches and releases (when a branch must be current)
- Added sections: none. The new rules sit inside principle I. Roles gains Scrum Master Dev.
- Removed sections: none
- Replaced v1.1.0 sentences:
  - "Only Jorge MAY merge. Any other person or bot MUST NOT merge."
  - "QA then verifies that the commit matches the review before asking Jorge to merge."
  - "The Reviewer MUST review ... before asking Jorge to merge."
  - "The QA review is recorded before Jorge's merge."
  - Roles: "He is the only person who merges."
  - Reviewer: "before asking Jorge to merge."
  - Branches: "before Jorge merges."
- Kept, and not replaced: Jorge merges the spec pull request, the converge
  pull request, a constitution amendment, a non-feature pull request, a
  flagged pull request, and every release from develop to main.
- Jorge's approval over region, DNS and costs: unchanged; enforced via needs-human.
- Only Jorge or the Scrum Master Dev may remove `needs-human`, and the
  removal is a pull request comment that states the reason.
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
exact line in the spec pull request description. It is description text,
not a GitHub label:

`Path: short (small change)`

Jorge's merge of that pull request approves the label. Nothing else
approves it. On the short path, `/speckit-clarify`,
`/speckit-checklist`, and `/speckit-analyze` are the only steps that MAY
be omitted.

v1.1.0 said: "Only Jorge MAY merge. Any other person or bot MUST NOT
merge." That sentence is replaced. It no longer covers an intermediate
pull request. The sentences that still give a merge to Jorge are listed
with the rules below, and they stay in force.

Jorge (Product Owner) approves and merges the spec pull request that
starts a feature and the converge pull request that closes it. He also
merges an amendment of this constitution, a non-feature pull request, a
pull request the Scrum Master Dev has flagged, and every release from
`develop` to `main`.

An intermediate pull request is every pull request between that spec pull
request and that converge pull request. That includes the plan and tasks
pull request, a clarify that changes the plan or the tasks, an
implementation task pull request, and the pull request that carries a
`qa: checklist` commit. A clarify that changes `spec.md` is a spec pull
request under rule 1 below, not an intermediate pull request. Jorge
does not merge an intermediate pull request by hand, unless it carries
the label `needs-human`.

Reviewer QA approves an intermediate pull request in a COMMENT review
that starts with `QA verdict: APPROVED` and names that pull request's
current full head SHA. All bots share one GitHub account, so GitHub
cannot enforce that review. This rule is the control. The verdict MUST
name the head SHA it approves. Nobody enables auto-merge when the pull
request is opened.

The pull request author is the agent that opened the pull request.
Reviewer QA never runs `gh pr merge`, with or without `--auto`. The
author runs `gh pr merge --auto --squash` only after that APPROVED
verdict is posted on the current head SHA, and only when the Scrum
Master Dev has not flagged the pull request. Before the command, the
author runs `gh pr view <n> --json labels` and does not enable
auto-merge if the label `needs-human` is present. GitHub then merges
when the required checks are green.

A push after that approval invalidates the verdict. The author first
runs `gh pr merge --disable-auto`, then pushes, then waits for a new
Reviewer QA verdict that names the new head SHA before running
`gh pr merge --auto --squash` again.

Exception: the Scrum Master Dev flags a step that needs Jorge's personal
verification. The flag is the GitHub label `needs-human` on the pull
request, plus a pull request comment that states the reason. The Scrum
Master Dev adds the label and the comment before Reviewer QA's verdict.
The label MUST exist in the repository. Whoever first needs it creates
it once with `gh label create needs-human`. While the label is present,
auto-merge stays off and the pull request waits for Jorge to merge it.
If the label is added after auto-merge was enabled, the author runs
`gh pr merge --disable-auto`. The flag covers a change to the AWS region,
a change to DNS or a custom domain, a step that creates or changes real
AWS resources or costs,
including bootstrap and apply, a step that changes IAM permissions or
secrets, and a step that changes branch protection. Only Jorge or the
Scrum Master Dev may remove `needs-human`. Whoever removes it MUST add a
pull request comment that states the reason. No other role may remove
the label.

When implementation of a spec is finished, Reviewer QA gives a final
sign-off on the converge pull request. Jorge then verifies the feature
personally. If he approves, he merges that close. If he does not approve,
the work returns to the point that needs it: the spec, through
`/speckit-clarify`, or the implementation, through a new task pull
request.

The repository setting "Allow auto-merge" MUST be enabled by Jorge, the
repository admin, before auto-merge can run. Until that setting is
enabled, the same author runs `gh pr merge --squash` without `--auto`.
That command is also forbidden at open time. The author runs it only
after `QA verdict: APPROVED` names the current head SHA and
`gh pr view <n> --json labels` shows no `needs-human` label. Reviewer QA
never runs `gh pr merge`. Jorge does not merge that intermediate pull
request by hand, unless that pull request carries `needs-human`. That
squash merge is not his approval of the start or of the close.

These v1.1.0 rules stay. At most one spec, plan, or constitution pull
request is open. A pull request MUST NOT depend on an unmerged pull
request. A spec pull request comes from branch `NNN-name`. The only commit
that may mark a `/speckit-checklist` item `[x]`, or add a waiver there, is
a commit titled `qa: checklist`.

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
   v1.1.0 told the Tech Lead to add `Status: Approved by Jorge — PR #N`
   to `plan.md` and to `tasks.md`. That sentence is replaced for a pull
   request opened after this 1.2.0 amendment merges, unless the pull
   request carries `needs-human`. Without that label, the Tech Lead MUST
   add `Status: Approved by Reviewer QA — PR #N` to `plan.md` and to
   `tasks.md`, and to any other intermediate artifact that carries a
   status line, with this pull request's number, as the only status field
   on each. A plan, tasks, or other intermediate artifact merged with
   `needs-human` uses `Status: Approved by Jorge — PR #N`. `spec.md` and
   `converge.md` keep
   `Status: Approved by Jorge — PR #N`. Artifacts already merged under
   v1.1.0 are not rewritten. That includes `specs/001-minimal-hugo-site`
   and the `plan.md` and `tasks.md` already on `develop` for
   `specs/002-aws-deployment`, which keep
   `Status: Approved by Jorge — PR #N`. Another status field MUST NOT be
   added. The line MUST NOT include a date. Except for the feature 001
   transition below, `spec.md` MUST already be on `develop` before this
   PR is opened, and this PR MUST NOT change it. Jorge merges the spec
   pull request before this plan and tasks pull request is opened. He
   does not approve or merge this pull request, unless the pull request
   carries `needs-human`. Then Jorge approves and merges it.
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
that review. QA then verifies that the commit matches the review. That
verification is recorded in the review. It is not, by itself, the
approval that arms auto-merge. That approval is the COMMENT review that
starts with `QA verdict: APPROVED` and names the current head SHA, and
it applies only when `needs-human` is absent. v1.1.0 said QA verifies
the commit "before asking Jorge to merge." That sentence is replaced:
Jorge is not asked to merge it, unless the label `needs-human` is
present. This limit does not apply to
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
`spec.md` has `Status: Approved by Jorge — PR #N`. For a pull request
opened after 1.2.0 merges, `plan.md`, `tasks.md`, and any other
intermediate artifact that carries a status line have
`Status: Approved by Jorge — PR #N` when that pull request carries
`needs-human`, and `Status: Approved by Reviewer QA — PR #N` when it
does not. Each has no other status.
`converge.md` has `Status: Approved by Jorge — PR #N`. Files already
merged under v1.1.0 are not rewritten, including `specs/001-minimal-hugo-site`
and the `plan.md` and `tasks.md` of `specs/002-aws-deployment`. On the
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
ignore rule. An intermediate pull request does not have auto-merge
enabled when it is opened. Its approval is a COMMENT review that starts
with `QA verdict: APPROVED` and names that pull request's current full
head SHA. The author who opened it runs `gh pr view <n> --json labels`
and runs `gh pr merge --auto --squash` only when that verdict matches
the current head and `needs-human` is absent. Reviewer QA does not run
`gh pr merge`. Before a later push, the author runs
`gh pr merge --disable-auto` if auto-merge is on, and the next enable
waits for a verdict that names the new head. If `needs-human` is added
after auto-merge was enabled, the author runs
`gh pr merge --disable-auto`. Jorge merges the spec pull request and,
after Reviewer QA's sign-off, the converge pull request.

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
  request that carries that change, whether it is a spec, plan, tasks, or
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
status with `Status: Approved by Jorge — PR #N` for that spec pull
request, and Jorge merges it. That line is not used on `plan.md` or
`tasks.md` in a pull request opened after 1.2.0 merges, unless that
pull request carries `needs-human`.

The last implementation PR of the feature is the one that gets
`Converged`. It MUST add `specs/NNN-name/converge.md` with the full output
of that final run, the date, the SHA of the commit it ran on, and the
verdict `Converged`. For a converge pull request opened after 1.2.0
merges, `converge.md` also carries
`Status: Approved by Jorge — PR #N` as its only status field, with no
date. The PR description MUST paste that verdict. QA MUST
block the PR if the file is missing or the verdict is not `Converged`.

Reviewer QA MUST review against `spec.md`, `plan.md`, `tasks.md`, the
checklist files when the full path applies, `converge.md` when it is the
last PR, and this constitution. v1.1.0 said that review comes "before
asking Jorge to merge." That sentence is replaced. On an intermediate
pull request, the review that allows the author to run
`gh pr merge --auto --squash` is a COMMENT review that starts with
`QA verdict: APPROVED` and names the current full head SHA. The author
MUST NOT run that command when the pull request is opened, after a push
that the verdict does not name, or while `needs-human` is present.
Jorge does not merge it unless that label is present. On the converge
pull request, the review is the final sign-off, and Jorge merges only
after it. Without that review on the current head, the pull request
MUST NOT be merged.

**Check:** the description lists the ids, `tasks.md` has them as `[X]`,
and there are no extra or missing ids. A PR that is not the converge PR
does not rewrite tasks or change `spec.md`. The last PR contains
`converge.md` with the date, the SHA, and `Converged`, and the description
repeats the verdict. If the file is missing or the verdict is anything
else, QA blocks the PR. v1.1.0 said "The QA review is recorded before
Jorge's merge." That sentence is replaced for an intermediate pull
request: the `QA verdict: APPROVED` review names the head that the
author later enables for auto-merge, unless that pull request carries
`needs-human`, and auto-merge is not enabled at open. On the converge
pull request, the review is still recorded before Jorge's merge.

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
  Approves and merges each spec pull request that starts a feature,
  including `Path: short (small change)` when that line is present, and
  the converge pull request that closes it. v1.1.0 said "He is the only
  person who merges." That sentence is replaced. He does not manually
  merge an intermediate pull request. He does merge one that carries
  the label `needs-human`, a non-feature pull request, and every release from
  `develop` to `main`. He enables the repository setting "Allow
  auto-merge".
- **Tech Lead.** On the full path, runs `/speckit-specify`,
  `/speckit-clarify`, `/speckit-plan`, `/speckit-checklist`,
  `/speckit-tasks`, and `/speckit-analyze`. When clarify finds nothing
  material, adds the `## Clarifications` section by hand. On a small
  change, puts `Path: short (small change)` in the spec PR description and
  runs `/speckit-specify`, `/speckit-plan`, and `/speckit-tasks`. Writes
  waivers on unchecked `checklists/requirements.md` items. After QA's
  review, applies the `/speckit-checklist` marks in a commit titled
  `qa: checklist` that links the review. Writes
  `Status: Approved by Jorge — PR #N` on `spec.md`. For a pull request
  opened after 1.2.0 merges, writes
  `Status: Approved by Jorge — PR #N` on `plan.md` and on `tasks.md`
  when the pull request carries `needs-human`, and
  `Status: Approved by Reviewer QA — PR #N` when it does not. The same
  split applies to any other intermediate artifact that carries a status
  line. Does not rewrite a status line already merged under
  v1.1.0. Does not enable auto-merge when opening a pull request.
  After a COMMENT review starts with `QA verdict: APPROVED` and names
  the current head SHA, runs `gh pr view <n> --json labels`. If
  `needs-human` is absent, runs `gh pr merge --auto --squash`. If
  "Allow auto-merge" is still off, runs `gh pr merge --squash` without
  `--auto` under the same checks. Before a later push, first runs
  `gh pr merge --disable-auto`, then pushes, and waits for a verdict
  that names the new head.
- **Web Developer.** Runs `/speckit-implement` and, on the feature's last
  PR, `/speckit-converge`. When implement stops on an unchecked checklist
  item, the Web Developer MAY answer yes only when every unchecked item
  carries a waiver the Reviewer has accepted. Does not enable auto-merge
  when opening a pull request. On an implementation pull request that is
  not the converge pull request, runs `gh pr merge --auto --squash` only
  after `QA verdict: APPROVED` names the current head SHA and
  `gh pr view <n> --json labels` shows no `needs-human`. If "Allow
  auto-merge" is still off, runs `gh pr merge --squash` without `--auto`
  under those same checks. Before a later push, first runs
  `gh pr merge --disable-auto`, then pushes, and waits for a verdict
  that names the new head. The converge pull request stays without
  auto-merge. The Web Developer does
  not run `gh pr merge` on it. Jorge merges it. `converge.md` carries
  `Status: Approved by Jorge — PR #N`.
- **Reviewer (QA).** Reviewer QA is this role. Reviews against `spec.md`,
  `checklists/requirements.md`, `plan.md`, `tasks.md`, the
  `/speckit-checklist` files when the full path applies, and this
  constitution. v1.1.0 said that review is done "before asking Jorge to
  merge." That sentence is replaced. The intermediate approval is a
  COMMENT review that starts with `QA verdict: APPROVED` and names the
  full head SHA. Reviewer QA never runs `gh pr merge`, with or without
  `--auto`, and does not enable auto-merge. The author enables it only
  after that verdict, and only when `needs-human` is absent. On the
  converge pull request, Reviewer QA gives
  the final sign-off and Jorge merges after his own verification.
  Accepts or rejects each waiver on
  `checklists/requirements.md`. Records each `/speckit-checklist` item as
  checked or waived, with reasons, in the GitHub review. After the
  `qa: checklist` commit, verifies that it matches that review. Checks the
  status line, the Clarifications text, the analyze report's head SHA and
  open findings, the task ids, and, on the last PR, that `converge.md`
  exists and says `Converged`.
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
  rebased onto that new `develop` before the pull request merges. v1.1.0
  said "before Jorge merges." That sentence is replaced, because an
  intermediate pull request merges by auto-merge, unless that pull
  request carries `needs-human`. The next pull request
  is opened only after that merge.
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
QA MUST check compliance with this constitution. v1.1.0 said "Before
asking for a merge." That sentence is replaced: Reviewer QA does not
ask Jorge to merge an intermediate pull request, unless that pull
request carries `needs-human`, and Reviewer QA does not run
`gh pr merge`. A PR that contradicts a principle MUST NOT be merged.

**Version**: 1.2.0 | **Ratified**: 2026-10-20 | **Last Amended**: 2026-10-21
