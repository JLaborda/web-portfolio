# Convergence: Automated Post-deploy Verification

Feature: `specs/005-deploy-verification`

Command: `/speckit-converge`

Assessed commit: `38a02ace3c94432f47c510ebfd81fd46ddce74ba`

Date: 2026-10-23

This file is the T005 record in progress. `/speckit-converge` did not modify `spec.md` or `plan.md`. It appended `## Phase 5: Convergence` with T007 to `tasks.md`. `.specify/extensions.yml` is not present, so no before-converge or after-converge hooks ran. Account ids, bucket names, distribution ids, CloudFront hostnames, emails, and ARNs are omitted or written as `<redacted>`.

## Prerequisite check

```text
SPECIFY_FEATURE_DIRECTORY=specs/005-deploy-verification
.specify/scripts/bash/check-prerequisites.sh --json --require-spec --require-tasks --include-tasks
```

```json
{"FEATURE_DIR":"/workspace/specs/005-deploy-verification","AVAILABLE_DOCS":["tasks.md"]}
```

`spec.md`, `plan.md`, and `tasks.md` are present on disk.

## Live evidence collected (read-only GitHub API)

### T001 staging (first push after #42)

- Run: https://github.com/JLaborda/web-portfolio/actions/runs/39933030396
- Conclusion: `failure`
- Deploy step `Invalidate` failed with `AccessDenied` on `cloudfront:GetInvalidation` (IAM apply had not landed yet). `verify` was skipped (`needs: deploy`).
- Pull request #42 has no `github-actions[bot]` verify comment.

### T003 staging (present-mode probe)

- Run: https://github.com/JLaborda/web-portfolio/actions/runs/39940179261
- Conclusion: `success` (deploy and verify)
- Invalidate completed before `Record site URL` (Invalidate `2026-10-23T10:36:03Z`–`10:36:25Z`; Record started `10:36:25Z`). Workflow source places `aws cloudfront wait invalidation-completed` in the Invalidate step above Record.
- Verify comment on #51 (`github-actions[bot]`):

```text
Run: https://github.com/JLaborda/web-portfolio/actions/runs/39940179261
Environment: staging
Commit: 862dbf574101cde6420d0524225f6878a70f79a1

check | expected | actual | result
object index.html | exists | exists | pass
object posts/spec-005-probe/index.html | exists | exists | pass
home | 200 | 200 | pass
http redirect | 301 | 301 | pass
x-robots-tag | noindex | noindex | pass
```

### T004 staging (absent-mode probe)

- Run: https://github.com/JLaborda/web-portfolio/actions/runs/39941004921
- Conclusion: `success` (deploy and verify)
- Invalidate completed before `Record site URL` (Invalidate `10:43:27Z`–`10:43:49Z`; Record started `10:43:49Z`).
- Verify comment on #52 (`github-actions[bot]`):

```text
Run: https://github.com/JLaborda/web-portfolio/actions/runs/39941004921
Environment: staging
Commit: 38a02ace3c94432f47c510ebfd81fd46ddce74ba

check | expected | actual | result
object index.html | exists | exists | pass
object posts/spec-005-probe/index.html | 404 Not Found | 404 Not Found | pass
home | 200 | 200 | pass
http redirect | 301 | 301 | pass
x-robots-tag | noindex | noindex | pass
```

### Production release merge (#53)

- Release: merge pull request #53 (`develop` into `main`), head `7b7dc423e38f26e7ad664df97043593713eea186`
- Run: https://github.com/JLaborda/web-portfolio/actions/runs/39942404001
- Conclusion: `success` (deploy and verify)
- Invalidate completed before `Record site URL` (Invalidate `10:55:16Z`–`10:55:37Z`; Record started `10:55:37Z`). The Invalidate step log includes `aws cloudfront wait invalidation-completed`.
- Verify comment on #53 (`github-actions[bot]`):

```text
Run: https://github.com/JLaborda/web-portfolio/actions/runs/39942404001
Environment: production
Commit: 7b7dc423e38f26e7ad664df97043593713eea186

check | expected | actual | result
object index.html | exists | exists | pass
home | 200 | 200 | pass
http redirect | 301 | 301 | pass
x-robots-tag | absent | absent | pass
no page source changed
```

The release range nets out the probe add and delete, so verify reports no page-source keys beyond the always-present `index.html`, and production has no `x-robots-tag` header. That matches US1 scenario 3 for this release.

### Branch-protection live run (pending)

- Workflow file `.github/workflows/branch-protection.yml` is on `main` (same tree as the assessed `develop` tip).
- `gh run list --workflow=branch-protection.yml` returns no runs.
- This agent cannot start `workflow_dispatch` (`HTTP 403 Resource not accessible by integration`).
- **Pending:** first `workflow_dispatch` (or schedule) run on `main` that shows both branches matching contexts `gitleaks`, `hugo`, `lychee`, `terraform` and `enforce_admins` enabled. That URL is the proof that `BRANCH_PROTECTION_READ_TOKEN` works (T005 / SC-004 / US3). Not invented here.

### Spec 002 T020 (out of scope for this file)

Invalidate-wait-before-`site_url` is green on staging runs `39940179261`, `39941004921` and production run `39942404001`. Spec 002 task T020 remains `[ ]` and asks for a later update of `specs/002-aws-deployment/converge.md`. This feature does not edit that file.

## What was checked (code)

Assessed tree: `38a02ace3c94432f47c510ebfd81fd46ddce74ba` on `develop` (matches `main` after #53).

- FR-001: `verify` job `needs: deploy`, no `if:`, same environment expression as deploy, OIDC pins, `fetch-depth: 2`, no top-level `permissions`, no long-lived keys.
- FR-002: push-range `git diff --name-status -M`, HeadObject present/absent rules, rename handling (T006), no empty merge `diff-tree` form. Probe page removed from the tree.
- FR-003: curl home / redirect / robots checks in `deploy.yml`; live staging and production comments match.
- FR-004: verify permissions include `pull-requests: write`; comments on #51, #52, #53 carry run URL, environment, SHA, and check rows without account / bucket / distribution ids.
- FR-005: `branch-protection.yml` schedule `0 9 * * 1`, `workflow_dispatch`, GET-only, secret `BRANCH_PROTECTION_READ_TOKEN`, no write methods. **Live run pending** (above).
- FR-006: no `infra/` change in this feature's implementation path; HeadObject permissions pre-existed.
- FR-007: `needs: deploy` and `aws cloudfront wait invalidation-completed` before `site_url`; live order confirmed on the three green runs above.
- FR-008: no `gh pr merge` under `.github/workflows`; weekly job not added to required contexts in-repo.
- SC-001, SC-002, SC-003: staging present / absent / comments recorded above; production verify recorded above.
- SC-004: code present; **live proof pending** (T007).
- SC-005: Verification commands remain in `spec.md`; local gates run for this pull request.

## Convergence Findings

| ID | Gap Type | Severity | Source | Evidence | Remaining Work |
|----|----------|----------|--------|----------|----------------|
| F1 | missing | HIGH | SC-004 / US3 / T005 | Zero Actions runs for `branch-protection.yml`; dispatch returns HTTP 403 for this agent | T007: Jorge starts `workflow_dispatch` on `main`; record the green run in this file; set verdict `Converged` and mark T005 `[X]` |

**Summary metrics:**

- Requirements checked: 8 (FR-001 through FR-008)
- Success criteria checked: 5 (SC-001 through SC-005)
- Acceptance scenarios checked: 9 (US1/AC1–AC3, US2/AC1–AC3, US3/AC1–AC3)
- Plan decisions checked: 8 (verify after deploy, OIDC reuse, no IAM change, exact-string guard, branch-protection PAT, FR-022 wait dependency, five implementation branches, English-only)
- Constitution principles checked: 7 (I through VII)
- Tasks checked: T001 through T006 done in tree; T005 open until F1 closes; T007 appended
- Findings by gap type: missing 1, partial 0, contradicts 0, unrequested 0
- Findings by severity: CRITICAL 0, HIGH 1, MEDIUM 0, LOW 0

Outcome: `tasks_appended`.

## Next actions

1. Jorge runs `workflow_dispatch` for `branch-protection` on `main` (or waits for Monday 09:00 UTC schedule).
2. Implement T007: paste that run URL and matching summary into this file, set **Verdict: Converged**, mark T005 `[X]`, leave T007 `[X]`.
3. Jorge merges the converge pull request (no auto-merge).

## Verdict

Date: 2026-10-23

SHA: `38a02ace3c94432f47c510ebfd81fd46ddce74ba`

Verdict: **not Converged** — pending T007 (first `branch-protection.yml` live run on `main`).

T005 remains `[ ]` until that evidence is recorded and this verdict becomes `Converged`.
