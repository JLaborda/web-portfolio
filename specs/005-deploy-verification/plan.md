# Implementation Plan: Automated Post-deploy Verification

**Branch**: `005-deploy-verification` | **Date**: 2026-10-23 | **Spec**: [spec.md](./spec.md)

Status: Approved by Jorge — PR #36

**Input**: Feature specification from `/specs/005-deploy-verification/spec.md`

## Summary

Add a `verify` job to `.github/workflows/deploy.yml` that runs after `deploy` on every push to `develop` (staging) and `main` (production). It assumes the environment's existing OIDC deploy role, checks the S3 objects the push range should have published or removed with `aws s3api head-object`, checks the public URL with `curl`, writes a job summary, and comments the same rows on the merged pull request. Add a second workflow, `.github/workflows/branch-protection.yml`, that reads branch protection for `develop` and `main` weekly and on `workflow_dispatch` with the repository secret `BRANCH_PROTECTION_READ_TOKEN`. No IAM, Terraform, or branch-protection change. The decision record is [ADR 001](../../docs/adr/001-post-deploy-verification.md).

Under constitution 2.0.0 this plan, `tasks.md`, and the ADR ship in the same `docs:` pull request as `spec.md` (PR #36). Jorge merges it. Reviewer QA's approving review of the spec (review 5625418778, head `adfaffefdc0e9eca7a34464aeb4ad4c3fc906af9`) left four non-blocking notes. Each is resolved below under "QA notes from PR #36".

## Technical Context

**Language/Version**: Bash in GitHub Actions `run:` steps. Python 3 (preinstalled on `ubuntu-latest`) only inside the verify step to parse front matter and build the key sets. mikefarah `yq` 4.54.1, the pin `deploy.yml` already installs, for workflow checks.

**Primary Dependencies**: `actions/checkout` `3d3c42e5aac5ba805825da76410c181273ba90b1` (v7.0.1). `aws-actions/configure-aws-credentials` `e1253824e5c10ff9df46874f81ed3ec929e19cfd` (v6.3.0), region `eu-west-1`, audience `sts.amazonaws.com`. AWS CLI v2 and `gh` from the runner image. No new action.

**Storage**: None. Results live in the job summary and in a pull request comment.

**Testing**: The Verification commands in [spec.md](./spec.md), plus the oracle dry run in T001 and the live evidence in T003–T005. No test framework.

**Target Platform**: GitHub Actions `ubuntu-latest`.

**Project Type**: Static site CI/CD. No change to the Hugo tree or to `infra/`.

**Performance Goals**: The `verify` job adds well under two minutes to a deploy run (one HeadObject per expected key and three curl calls).

**Constraints**: English only. No long-lived AWS keys. No IAM action added. No literal account id, bucket name, distribution id, hostname, or email in the repository, the summary, or the comment. `verify` waits for spec 002 FR-022 (invalidation wait) to be on `develop`.

**Scale/Scope**: One new job, one new workflow, two environments, two protected branches.

## Constitution Check

| Principle | Gate | Result |
|-----------|------|--------|
| I. Spec-driven, PO approval | Spec, checklist, plan, tasks, and ADR are in one `docs:` pull request (#36), merged by Jorge. No implementation pull request opens before that merge. `spec.md`, `plan.md`, and `tasks.md` carry `Status: Approved by Jorge — PR #36`. | Pass (requires constitution 2.0.0 merged first) |
| II. Fixed stack | No theme, layout, asset, or Hugo pin change. | Pass |
| III. AWS hosting | Reuses the existing OIDC deploy role per GitHub Environment. No new role, policy, action, or long-lived key. `infra/` is untouched (FR-006). | Pass |
| IV. Verifiable CI | The four required checks are unchanged. The weekly job is not made required (FR-005, FR-008). | Pass |
| V. Scoped PRs | Five implementation branches `005-deploy-verification-t01` to `t05`, listed in [tasks.md](./tasks.md). `t05` commits `converge.md`. | Pass |
| VI. Explainable and cheap | HeadObject and curl calls only; cost is effectively 0 USD. | Pass |
| VII. English | All files English. | Pass |

## Project Structure

```text
specs/005-deploy-verification/
├── spec.md
├── checklists/requirements.md
├── plan.md
├── tasks.md
└── converge.md              # written by t05
docs/adr/
└── 001-post-deploy-verification.md
.github/workflows/
├── deploy.yml               # t01 adds the verify job
└── branch-protection.yml    # t02, new
```

## Design

### verify job (FR-001, FR-007)

- `needs: deploy`, no `if:`. Same `environment` expression as `deploy`. Permissions exactly `id-token: write`, `contents: read`, `pull-requests: write`. `deploy` keeps `id-token: write` and `contents: read`.
- `env` reads `SITE_URL`, `BUCKET_NAME`, `DISTRIBUTION_ID`, `AWS_ROLE_ARN` from `vars`, and `BEFORE: ${{ github.event.before }}`. The first step reuses the existing empty-variable loop (`::error::%s is empty`) so values are never printed.
- Checkout with `fetch-depth: 2`, then `configure-aws-credentials` with `vars.AWS_ROLE_ARN`.
- Masking: the first AWS step runs `aws sts get-caller-identity --query Account --output text`, then emits `::add-mask::` for the account id, `BUCKET_NAME`, and `DISTRIBUTION_ID` before any other command can print them.
- `verify` starts only after `deploy` succeeds. Once FR-022 is on `develop`, `deploy` succeeds only after `aws cloudfront wait invalidation-completed` exits 0, so the checks never race the invalidation.

### Push range and key sets (FR-002)

1. If `BEFORE` is forty zeros, exit 1.
2. `git fetch --no-tags origin "$BEFORE"`. The parent-blob reads rely on this explicit fetch, not on `fetch-depth: 2`. On a release merge to `main`, `$BEFORE` is the previous `main` tip, which is generally not within depth 2 of `GITHUB_SHA` (QA note 2).
3. `git diff --name-status -M "$BEFORE" "$GITHUB_SHA"`. Never `git diff-tree ... HEAD`.
4. For each path under `content/` ending in `.md`:
   - New blob: `git show "$GITHUB_SHA:<new path>"`.
   - Parent blob: `git show "$BEFORE:<old path>"`. "Parent blob" in FR-002 always means the blob at `$BEFORE`, never `HEAD^`. On a squash push the two are the same commit; on a release merge `HEAD^` is the first parent only by GitHub's push semantics, and the spec's range is defined by `$BEFORE` (QA note 1).
   - Front matter: lines between an opening `---` and the next exact `---`. A first line `+++` or a `url:` key exits 1 and names the path.
   - Draft: a line matching `^draft:\s*["']?true["']?\s*$`.
   - Key: `content/_index.md` → `index.html`; `content/<dir>/_index.md` or `content/<dir>/index.md` → `<dir>/index.html`; otherwise `<dir>/<slug or filename stem>/index.html`.
   - `A`/`M`, new not draft → present. `D`, parent not draft → absent. `M`, parent not draft and new draft → absent. `R*` → derive old and new keys; equal keys follow the same rules as `M` for that one key; differing keys → old absent if parent published, new present if new published. Never put the same key in both sets (issue #44). Never-published drafts → neither set.
5. `index.html` is always in the present set. If no page source changed, the summary says so.
6. Present: `aws s3api head-object --bucket "$BUCKET_NAME" --key "$key"` exits 0. Absent: exit non-zero and stderr contains `(404)` and `Not Found` and not `(403)`. Exit 0 on an absent key fails.

The key derivation is a small Python block inside the step, so it can be run locally against the spec's oracle rows (T001 dry run).

### URL checks (FR-003)

`curl -sS -o /dev/null -w '%{http_code}' "${SITE_URL}/"` = `200`. `curl -sI -o /dev/null -w '%{http_code}' "http://${SITE_URL#https://}/"` = `301`. Staging: `curl -fsSI "${SITE_URL}/"` has a case-insensitive `^x-robots-tag: noindex` line. Production: no `^x-robots-tag:` line. Any other environment name fails.

### Report, guard, and comment (FR-004)

- Rows (`check | expected | actual | result`) are appended to a report file. The header has the run URL `${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}`, the environment, and the full SHA.
- Guard: `grep -F` for each of the three masked values against the report file. Also reject `@` addresses and `arn:aws`. No twelve-digit regex. If the guard fails, write a redacted failure line to the summary and exit 1 without commenting.
- Otherwise copy the report to `$GITHUB_STEP_SUMMARY`, list pull requests with `gh api "repos/${GITHUB_REPOSITORY}/commits/${GITHUB_SHA}/pulls" --jq '.[].number'`, and `gh pr comment <n> --body-file` for each (`GH_TOKEN: ${{ github.token }}`). An empty list or a failed comment exits 1. A failed check still comments, then exits 1.
- The spec's FR-004 now-fixture uses a 44-character "SHA". The implementation's fixture in T001 uses a real 40-character SHA (QA note 3, cosmetic; the spec fixture is left as is).

### branch-protection workflow (FR-005)

- Triggers: `schedule` `0 9 * * 1` and `workflow_dispatch` only. `permissions: contents: read`. One job `branch-protection`.
- For `develop` and `main`: `curl -sS -o body.json -w '%{http_code}' -H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json' https://api.github.com/repos/JLaborda/web-portfolio/branches/$b/protection`. Compare sorted `.required_status_checks.contexts` to `gitleaks hugo lychee terraform` and `.enforce_admins.enabled` to `true` with `jq`. Write status and values to the summary, then exit 1 on any mismatch or non-200.
- `TOKEN` is `secrets.BRANCH_PROTECTION_READ_TOKEN`. Empty → `::error::BRANCH_PROTECTION_READ_TOKEN is unset`, exit 1. No `github.token` fallback. No write method.
- `schedule` and `workflow_dispatch` only work once the workflow file is on the default branch (`main`). `t02` is therefore verified with the spec's static FR-005 checks. The first live run is a `workflow_dispatch` after Jorge releases `develop` to `main`, recorded in T005.
- The secret's existence is not visible to agents. Jorge's merge of PR #36 (`needs-human`) confirms it, and the first `workflow_dispatch` run on `main` is the proof (QA note 4).

## QA notes from PR #36

1. FR-002 "parent blob" = blob at `$BEFORE` (`git show "$BEFORE:<path>"`), not `HEAD^`. Pinned in "Push range and key sets".
2. `fetch-depth: 2` stays (FR-001), but parent-blob reads rely on `git fetch --no-tags origin "$BEFORE"`. Pinned above.
3. FR-004 fixture "SHA" is 44 characters. Cosmetic. T001 uses a 40-character SHA.
4. `BRANCH_PROTECTION_READ_TOKEN` cannot be read by agents. Proof is Jorge's merge plus the first `workflow_dispatch` run on `main` (T005).

## Delivery order

1. Constitution 2.0.0 merged, then PR #36 merged by Jorge.
2. Spec 002 FR-022 (`deploy.yml` invalidation wait and concurrency) on `develop`. `t01` does not open before that.
3. `t01` verify job → first staging verify run comments on `t01`'s own pull request.
4. `t02` branch-protection workflow (`needs-human`).
5. `t03` adds a probe page, `t04` removes it: live present and absent evidence on staging.
6. Jorge releases `develop` to `main`: production verify run and first `workflow_dispatch` of the weekly check.
7. `t05` converge.

## Complexity Tracking

No constitution violations require justification.
