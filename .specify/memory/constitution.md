<!--
Sync Impact Report
- Version change: 3.1.0 → 4.0.0
- Bump rationale: MAJOR. Process rules are redefined for the software
  factory. Former dual-role team titles are removed; only Manager,
  Planner, Builder, Reviewer, Merge Triage, and Auditor remain. Merge
  authority moves from Jorge's blanket merge of docs/release/
  needs-human PRs and author-driven auto-merge after QA to Merge
  Triage classification (green / yellow / red). Spec Kit path is set
  by Jorge in the issue brief. Strict TDD commit order is required.
  Dual-role and auto-merge author rules from 3.x are incompatible
  with this model.
- Decision: Jorge (Product Owner), 2026-11-13, issue #101.
- Modified principles:
  - I. Spec-driven development and PO approval → Spec-driven development
    and software factory approval (roles, merge chain, path selection,
    TDD, Merge Triage).
  - III. AWS hosting as a constraint: merge/`needs-human` wording
    aligned with Merge Triage red/yellow rules; substance unchanged.
  - V. Scoped implementation PRs: Reviewer and Merge Triage replace
    the former QA dual-role and author auto-merge; strict TDD commit
    order added.
  - VI. Explainable in an interview, and cheap: cost/budget exceptions
    classified at least yellow; Jorge merges yellow/red.
- Modified sections:
  - Roles: Manager, Planner, Builder, Reviewer, Merge Triage, Auditor
    (old team roles removed).
  - Branches and releases: Merge Triage merges green; yellow/red to
    Jorge with `needs-human`.
  - Governance: Reviewer compliance check; constitution amendments
    always red.
- Unchanged in substance: Principles II, IV, VII; Spec Kit path step
  lists; feature branch naming; `SPECIFY_FEATURE_DIRECTORY`; English
  only; ratification date 2026-10-20.
- Not rewritten: merged specs under earlier versions.
- Added sections: none. Removed sections: none.
- Templates and commands: no role names in `.specify/templates/` or
  commands; no sync edits required. Listed for completeness:
  checklist-template.md, constitution-template.md, plan-template.md,
  spec-template.md, tasks-template.md — unchanged.
- Follow-up TODOs: none
-->

# web-portfolio Constitution

## Core Principles

### I. Spec-driven development and software factory approval

Development MUST NOT start without a `spec.md` approved through the
software factory chain below. `/speckit-constitution` is set once for
the project. A later amendment is its own pull request and is not a
feature step. Constitution amendments are always red (Merge Triage
MUST NOT merge them; Jorge merges).

The software factory roles are the only process roles named in this
constitution: Manager, Planner, Builder, Reviewer, Merge Triage, and
Auditor. The chain for a feature is:

Manager → Planner → Merge Triage (`docs:` PR) → Builder → Reviewer →
Merge Triage (code PR).

Merge Triage escalates yellow and red classifications to the Manager
and confirms every merge to the Manager. After each merge that unlocks
the next task, the Manager hands the Builder that task. The Auditor
only reads the activity log. The Manager is the only factory role that
talks to Jorge (Product Owner).

Jorge sets the Spec Kit path in the issue brief: full or short. The
Planner MUST follow that path. Nothing else chooses the path.

The full path, in this order: `/speckit-specify`, `/speckit-clarify`,
`/speckit-plan`, `/speckit-checklist`, `/speckit-tasks`,
`/speckit-analyze`, `/speckit-implement`, `/speckit-converge`. On that
path a step MUST NOT be skipped.

The short path, in this order: `/speckit-specify`, `/speckit-plan`,
`/speckit-tasks`, `/speckit-implement`, `/speckit-converge`. On the
short path, `/speckit-clarify`, `/speckit-checklist`, and
`/speckit-analyze` are the only steps that MAY be omitted. The Planner
MUST put this exact line in the `docs:` pull request description. It is
description text, not a GitHub label:

`Path: short (small change)`

Jorge's merge of a yellow or red `docs:` pull request, or Merge
Triage's merge of a green `docs:` pull request, approves that path
label. Nothing else approves it.

#### Merge Triage classification

Merge Triage classifies every pull request and the `develop` → `main`
release as green, yellow, or red.

- **Green:** Merge Triage merges. That includes green `docs:` PRs,
  green code PRs (including converge), and a green `develop` → `main`
  release.
- **Yellow or red:** Merge Triage MUST NOT merge. It escalates to the
  Manager, applies the GitHub label `needs-human`, and Jorge merges.

Always red:

- Changes to AWS infrastructure, IAM, or OIDC.
- Changes to CI workflows or branch protection.
- Amendments to this constitution.

Always at least yellow:

- Changes to AWS cost or budget.
- New dependencies.

Other `needs-human` cases from principles III and VI (region, DNS,
custom domain, real AWS resources or costs, secrets) remain at least
yellow and MAY be red when they also match an always-red rule above.
If the label `needs-human` does not exist yet, whoever first needs it
creates it once with `gh label create needs-human`. Only Jorge or the
Manager may remove `needs-human`, with a pull request comment that
states the reason.

#### Spec Kit docs and implementation flow

An intermediate pull request is an implementation task pull request
between the feature's `docs:` pull request and the converge pull
request. Reviewer reviews each code pull request once and flags every
finding. The Builder fixes them in one push. After that push, Reviewer
looks only at the new diff. Reviewer NEVER merges and NEVER runs
`gh pr merge`. Merge Triage merges only when the classification is
green and Reviewer's verdict on the current head allows it.

For the Planner's `docs:` work in this repository, one Cursor cloud
agent on the Auto model serves the whole repository: it opens the
`docs:` pull request, and fixes arrive as follow-ups on that same
agent. That agent is replaced only when its context becomes
unmanageable. For each intermediate implementation pull request, one
cloud agent serves that pull request and is reused for its fixes.

The pull request author is the agent that opened the pull request.
Nobody enables auto-merge when the pull request is opened. Merge Triage
is the role that merges green code and green `docs:` pull requests;
authors MUST NOT run `gh pr merge` to land factory work.

Strict TDD: each Builder task MUST have a commit that adds the failing
test before the commit that adds the implementation. Reviewer MUST
check that order in the pull request history. A code pull request that
lacks that order MUST NOT be classified green.

When implementation of a spec is finished, the last pull request is the
converge pull request. Its title MUST be exactly `chore(NNN): converge`
(NNN is the feature number). Reviewer gives a final sign-off on that
pull request. Merge Triage merges it when green; yellow or red goes to
Jorge with `needs-human`. If Jorge does not approve a yellow/red
converge, or the Manager returns the work, it returns to the point that
needs it: the spec, through extra commits on a new `docs:` pull
request, or the implementation, through a new task pull request.

These rules stay. At most one `docs:` pull request per feature is open.
A pull request MUST NOT depend on an unmerged pull request, except that
a `docs:` pull request MAY wait for a constitution amendment that
permits its shape. The `docs:` pull request comes from branch
`NNN-name`. Only the merge of the `docs:` pull request (by Merge Triage
when green, or by Jorge when yellow or red) approves its checklist
marks and waivers.

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
   The Planner writes it through this repository's Cursor cloud agent
   on the Auto model (one agent per repository for all of the Planner's
   pull requests and fixes via follow-ups; switch agents only when that
   agent's context becomes unmanageable). There is one such `docs:`
   pull request per spec. Reviewer does not review it. Merge Triage
   classifies it; green merges, yellow or red go to Jorge with
   `needs-human`. Fixes go as follow-ups on that agent and as extra
   commits on the same pull request. `spec.md`, `plan.md`, and
   `tasks.md` each carry `Status: Approved by Jorge — PR #N` (N is that
   pull request's number) as the only status field, replacing
   `**Status**: Draft`. The line MUST NOT include a date. Every item in
   `checklists/requirements.md` and in the `/speckit-checklist` files
   MUST be `[x]`, or left unchecked with a waiver and a reason on that
   same line. The Planner writes those marks and waivers. On the full
   path, the description pastes the `/speckit-analyze` report, which
   names the head SHA it ran on and leaves no CRITICAL or HIGH finding
   open; after a later commit that changes `spec.md`, `plan.md`, or
   `tasks.md`, the report is replaced. On the short path, the
   description contains `Path: short (small change)`, and the checklist
   files and the analyze report are not required.

   On the full path, `spec.md` MUST contain `## Clarifications`. When
   clarify accepts answers, it writes `### Session YYYY-MM-DD` and one
   bullet per answer: `- Q: <question> → A: <answer>`. When clarify finds
   nothing material, the Planner adds this text by hand, with
   `YYYY-MM-DD` the day clarify ran:

   ```text
   ## Clarifications

   ### Session YYYY-MM-DD

   - No critical ambiguities found; no questions asked.
   ```

2. An implementation pull request MUST NOT be opened before that
   `docs:` pull request is merged into `develop`.

A later change to a merged `spec.md`, `plan.md`, or `tasks.md` is a new
`docs:` pull request from the same `NNN-name` branch, classified by
Merge Triage, except for the `tasks.md` lines an implementation pull
request may add under principle V.

`/speckit-implement` MUST stop and ask when any checklist item is
unchecked. The Builder MAY answer yes only when every unchecked item
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
new spec approval is required. Reviewer MUST verify that the diff to
`spec.md` is only that Clarifications section.

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
`develop`. Merge Triage merges a green release; yellow or red releases
go to Jorge with `needs-human`.

`.specify/workflows/speckit/workflow.yml` does not govern this repo: it
ends at implement, it does not include converge, and its integration list
is advisory (it does not name `cursor-agent`). This constitution's flow
governs. `/speckit-taskstoissues` is deprecated in 1.2.2 and MUST NOT be
used.

**Check:** the `docs:` pull request title starts with `docs:`, comes
from `NNN-name`, and has no product code, workflow, or `infra/` file.
On `develop`, `spec.md`, `plan.md`, and `tasks.md` of a feature merged
under 2.0.0, 3.0.0, or 4.0.0 each have
`Status: Approved by Jorge — PR #N` and no other status. Every checklist
item there is `[x]` or waived on its line. On the full path, `spec.md`
contains `## Clarifications` and `### Session YYYY-MM-DD`, with either
`- Q:` / `→ A:` bullets or the exact line
`- No critical ambiguities found; no questions asked.`, and the
description has an analyze report on the head SHA with no open CRITICAL
or HIGH finding. A short-path description contains the exact line
`Path: short (small change)`. A converge pull request merged under 3.0.0
or 4.0.0 is titled `chore(NNN): converge`. `converge.md` has
`Status: Approved by Jorge — PR #N`. Files merged under 1.1.0, 1.2.0, or
2.0.0 are not rewritten to the new converge title. No implementation
pull request is opened before the `docs:` merge.
`git merge-base --is-ancestor origin/develop HEAD` exits 0 on its
branch. Every feature pull request targets `develop`. `main` has only
merges from `develop` made by Merge Triage (green) or Jorge
(yellow/red). `git check-ignore -v .specify/feature.json` reports an
ignore rule. The constitution names only Manager, Planner, Builder,
Reviewer, Merge Triage, and Auditor as factory process roles. Each
Builder task history shows a failing-test commit before the
implementation commit. Merge Triage merges only green; yellow and red
carry `needs-human` for Jorge.

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
- The bucket region MUST be decided in the deployment feature's plan.
  DNS and a custom domain SHOULD be decided there too. When that plan
  deferred DNS or a custom domain (as spec 002 did), a later feature
  MAY record the decision in its own plan and ADR, with the merge of
  that feature's `docs:` pull request. v1.1.0 said the deployment plan
  "MUST have Jorge's approval before it is implemented." That approval
  is unchanged for region and for any DNS work. Any change to the AWS
  region, to DNS or a custom domain, or to anything that creates real
  AWS resources or costs needs Jorge's explicit approval through the
  factory. The pull request that carries that change, whether it is a
  `docs:` or an implementation pull request, MUST be classified at least
  yellow and MUST carry `needs-human`. Changes to AWS infrastructure,
  IAM, or OIDC are always red. AWS cost or budget changes are always at
  least yellow. Jorge merges yellow and red. They never auto-merge. This
  constitution does not fix region or DNS names.

**Check:** the plan role's policy does not allow apply or changes to S3 or
CloudFront; the deploy role's Environment requires protection and is not
available on PRs; the deployment feature's `plan.md` records region with
Jorge's approval, and DNS is recorded either there or in a later
feature's plan/ADR that was merged. A pull request that changes region,
DNS, or a custom domain, or that creates real AWS resources or costs,
carries `needs-human` and is yellow or red. Jorge merges it.
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
acceptance criterion of the spec that introduces CI. Changes to CI
workflows or branch protection are always red under principle I.

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
merged by Merge Triage when green or by Jorge when yellow or red.

The last implementation PR of the feature is the one that gets
`Converged`. Its title MUST be exactly `chore(NNN): converge`. It MUST
add `specs/NNN-name/converge.md` with the full output of that final run,
the date, the SHA of the commit it ran on, and the verdict `Converged`.
`converge.md` also carries `Status: Approved by Jorge — PR #N` as its
only status field, with no date. The PR description MUST paste that
verdict. Reviewer MUST block the PR if the file is missing, the verdict
is not `Converged`, or the title is not `chore(NNN): converge`.

Each Builder task in the PR MUST include a commit with the failing test
before the commit with the implementation. Reviewer MUST verify that
order in the history.

Reviewer MUST review each code pull request against `spec.md`,
`plan.md`, `tasks.md`, the checklist files when the full path applies,
`converge.md` when it is the last PR, and this constitution, in one
round that flags every finding. After the fix push, it reviews only the
new diff. On an intermediate pull request, the review that allows Merge
Triage to classify the PR is a COMMENT review that starts with
`QA verdict: APPROVED` and names the current full head SHA. On the
converge pull request (`chore(NNN): converge`), the review is the final
sign-off. Without that review on the current head, a code pull request
MUST NOT be merged. Reviewer NEVER runs `gh pr merge`. Merge Triage
merges green code PRs; yellow and red go to Jorge with `needs-human`.

**Check:** the description lists the ids, `tasks.md` has them as `[X]`,
and there are no extra or missing ids. A PR that is not the converge PR
changes `tasks.md` only for the ids it closes and does not change
`spec.md` or `plan.md`. The last PR is titled `chore(NNN): converge`,
contains `converge.md` with the date, the SHA, and `Converged`, and the
description repeats the verdict. If the file is missing, the title is
wrong, or the verdict is anything else, Reviewer blocks the PR. The
commit history for each task shows failing test then implementation.

### VI. Explainable in an interview, and cheap

Solutions SHOULD be simple and documented, so they can be explained
end to end in an MLOps interview. The site's monthly cost MUST stay around
0–1 USD. v1.1.0 said this holds "unless an exception is documented in the
plan and approved by Jorge." That approval is unchanged. A pull request
that documents such an exception, or that creates real AWS resources or
costs, MUST be classified at least yellow, MUST carry `needs-human`, and
Jorge merges it. AWS cost or budget changes are always at least yellow.
New dependencies are always at least yellow. It never auto-merges. An
opaque service that hides the infrastructure MUST NOT be added when a
documented primitive meets the requirement.

**Check:** the feature's `plan.md` names the services and the expected
monthly cost; a service outside principle III is not implemented without
an amendment to this constitution or without Jorge's explicit approval in
that plan. v1.1.0 said the same sentence, ending "or without Jorge's
explicit approval in that plan." That approval is unchanged. The pull
request that carries the exception or the new service MUST have
`needs-human`, MUST be yellow or red, and Jorge merges it. It never
auto-merges.

### VII. English only

All repository content MUST be in English. That includes specs, plans,
tasks, commit messages, and every other file committed to the repo. All
GitHub communication MUST be in English: pull request titles and
descriptions, reviews, and comments. Site content MUST be in English.

**Check:** a non-English sentence in a committed file, PR title, PR body,
review, or comment fails review. Pages under `content/` are English.

## Roles

- **Jorge (Product Owner).** Approves this constitution by merging it
  (always red). Sets the Spec Kit path (full or short) in each issue
  brief. Merges every yellow or red pull request and every yellow or red
  `develop` → `main` release after Merge Triage applies `needs-human`.
  Talks to the factory only through the Manager. Does not merge green
  factory pull requests; Merge Triage does.
- **Manager.** Only factory role that talks to Jorge. Receives Merge
  Triage escalations and merge confirmations. After each merge that
  unlocks work, hands the Builder the next task. May remove
  `needs-human` with Jorge, with a pull request comment that states the
  reason.
- **Planner.** Follows the Spec Kit path Jorge set in the issue brief.
  Runs `/speckit-specify`, `/speckit-clarify`, `/speckit-plan`,
  `/speckit-checklist`, `/speckit-tasks`, and `/speckit-analyze` on the
  full path, or specify, plan, and tasks on the short path. Writes each
  feature's `docs:` pull request (spec, plan, tasks, checklists, ADR
  when there is one, and a constitution amendment when needed) through
  this repository's Cursor cloud agent on the Auto model. One such agent
  serves all of the Planner's pull requests and fixes in this repository
  via follow-ups; switch to a new agent only when that agent's context
  becomes unmanageable. One `docs:` pull request per spec. Includes the
  checklist marks and waivers, and `Status: Approved by Jorge — PR #N`
  on `spec.md`, `plan.md`, and `tasks.md`. Fixes with follow-ups and
  extra commits on the same pull request. Never enables auto-merge on a
  `docs:` pull request. Reviewer does not review `docs:` pull requests;
  Merge Triage classifies and merges green ones.
- **Builder.** Runs `/speckit-implement` and, on the feature's last PR,
  `/speckit-converge`, with one cloud agent per implementation pull
  request that is reused for that pull request's fixes. Receives each
  task from the Manager after the prior merge. For each task, commits
  the failing test before the implementation. The converge pull request
  title is exactly `chore(NNN): converge`. When implement stops on an
  unchecked checklist item, MAY answer yes only when every unchecked
  item carries a waiver that was in the merged `docs:` pull request.
  Does not enable auto-merge when opening a pull request. Does not run
  `gh pr merge`; Merge Triage merges green code PRs.
- **Reviewer.** Reviews code pull requests only, never a `docs:` pull
  request. One review round flags every finding; after the fix push,
  reviews only the new diff. Reviews against `spec.md`,
  `checklists/requirements.md`, `plan.md`, `tasks.md`, the
  `/speckit-checklist` files when the full path applies, this
  constitution, and the strict TDD commit order (failing test before
  implementation). The intermediate approval is a COMMENT review that
  starts with `QA verdict: APPROVED` and names the full head SHA. Never
  runs `gh pr merge`, with or without `--auto`. On the converge pull
  request titled `chore(NNN): converge`, gives the final sign-off and
  checks that `converge.md` exists and says `Converged`.
- **Merge Triage.** Classifies every pull request and the
  `develop` → `main` release as green, yellow, or red. Merges green
  `docs:` PRs, green code PRs, and a green release. Escalates yellow and
  red to the Manager, applies `needs-human`, and leaves the merge to
  Jorge. Confirms every merge to the Manager. MUST treat constitution
  amendments, AWS infra/IAM/OIDC changes, and CI workflow or branch
  protection changes as always red; AWS cost/budget changes and new
  dependencies as always at least yellow.
- **Auditor.** Only reads the activity log. Does not open pull requests,
  review, merge, or talk to Jorge.

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
CI gates, and Merge Triage MUST classify it: green merges; yellow or red
go to Jorge with `needs-human`. Any new behavior MUST have a spec
(`specs/NNN-name/`) and MUST NOT land on these branches.

Amendments to this constitution follow that rule (`chore/` or `docs/`)
unless they change visible behavior, in which case they require a spec.
They are always red. The `develop` → `main` release is not a feature
branch: it MUST pass the same gates; Merge Triage merges it when green,
and Jorge merges it when yellow or red.

## Governance

This constitution overrides informal practice. An amendment MUST be
proposed in a pull request to `develop` and MUST be approved and merged by
Jorge (always red). Until that merge, the amendment is not in force.

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
MUST check compliance with this constitution. Reviewer does not run
`gh pr merge`. A PR that contradicts a principle MUST NOT be merged.

**Version**: 4.0.0 | **Ratified**: 2026-10-20 | **Last Amended**: 2026-11-13
