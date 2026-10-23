# Convergence: Automated Post-deploy Verification

Feature: `specs/005-deploy-verification`

Command: `/speckit-converge`

Status: Approved by Jorge — PR #54

Assessed commit: `38a02ace3c94432f47c510ebfd81fd46ddce74ba`

Date: 2026-10-23

This file is the T005 and T007 record. `/speckit-converge` did not modify `spec.md` or `plan.md`, and it did not append a further phase to `tasks.md` on this re-run. `.specify/extensions.yml` is not present, so no before-converge or after-converge hooks ran. Account ids, bucket names, distribution ids, CloudFront hostnames, emails, and ARNs are omitted or written as `<redacted>`.

## Prerequisite check

```text
SPECIFY_FEATURE_DIRECTORY=specs/005-deploy-verification
.specify/scripts/bash/check-prerequisites.sh --json --require-spec --require-tasks --include-tasks
```

```json
{"FEATURE_DIR":"/workspace/specs/005-deploy-verification","AVAILABLE_DOCS":["tasks.md"]}
```

`spec.md`, `plan.md`, and `tasks.md` are present on disk.

## Live evidence (read-only GitHub API)

### T001 staging (first push after #42)

- Run: https://github.com/JLaborda/web-portfolio/actions/runs/39933030396
- Conclusion: `failure`
- Deploy step `Invalidate` failed with `AccessDenied` on `cloudfront:GetInvalidation` (IAM apply had not landed yet). `verify` was skipped (`needs: deploy`).
- Pull request #42 has no `github-actions[bot]` verify comment.

### T003 staging (present-mode probe)

- Run: https://github.com/JLaborda/web-portfolio/actions/runs/39940179261
- Conclusion: `success` (deploy and verify)
- Invalidate completed before `Record site URL` (Invalidate `2026-10-23T10:36:03Z`–`10:36:25Z`; Record started `10:36:25Z`). The Invalidate step runs `aws cloudfront wait invalidation-completed` before that Record step.
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
- Invalidate completed before `Record site URL` (Invalidate `10:55:16Z`–`10:55:37Z`; Record started `10:55:37Z`).
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

The release range nets out the probe add and delete, so verify reports no page-source keys beyond always-present `index.html`, and production has no `x-robots-tag`. That matches US1 scenario 3 for this release.

### Branch-protection live runs (T007 / SC-004 / US3)

Both runs are `workflow_dispatch` on `main` at `7b7dc423e38f26e7ad664df97043593713eea186`. Verified with the GitHub API before this write.

1. **Failed first attempt** — https://github.com/JLaborda/web-portfolio/actions/runs/39948534796  
   - Conclusion: `failure`  
   - Job `branch-protection`: step `Read branch protection` failed (exit 1).  
   - Cause: `BRANCH_PROTECTION_READ_TOKEN` had no repository access, so the protection GET returned HTTP 403 (same class of failure as automation without Administration read). The token was fixed afterward.

2. **Green proof run** — https://github.com/JLaborda/web-portfolio/actions/runs/39949711442  
   - Conclusion: `success`  
   - Job `branch-protection`: step `Read branch protection` succeeded.  
   - Per the workflow, exit 0 means both `develop` and `main` returned HTTP 200, sorted `required_status_checks.contexts` equaled `["gitleaks","hugo","lychee","terraform"]`, and `enforce_admins.enabled` was `true`.  
   - This run is the proof that `BRANCH_PROTECTION_READ_TOKEN` works. The weekly job is not a required status check.

### Spec 002 T020 (out of scope)

Invalidate-wait-before-`site_url` is green on staging runs `39940179261`, `39941004921` and production run `39942404001`. Spec 002 task T020 remains `[ ]` and belongs in a later update of `specs/002-aws-deployment/converge.md`. This feature does not edit that file.

## What was checked (code)

Assessed tree tip before this converge record: `38a02ace3c94432f47c510ebfd81fd46ddce74ba` on `develop` (same content as `main` after #53 for workflows and site).

- FR-001: `verify` job `needs: deploy`, no `if:`, same environment expression as deploy, OIDC pins, `fetch-depth: 2`, no top-level `permissions`, no long-lived keys.
- FR-002: push-range diff, HeadObject present/absent rules, rename handling (T006). Probe page absent from the tree.
- FR-003: curl home / redirect / robots checks; live staging and production comments match.
- FR-004: verify comments on #51, #52, #53 carry run URL, environment, SHA, and check rows without account / bucket / distribution ids.
- FR-005: `branch-protection.yml` schedule `0 9 * * 1`, `workflow_dispatch`, GET-only, secret `BRANCH_PROTECTION_READ_TOKEN`. Live green run `39949711442` recorded above.
- FR-006: no `infra/` change required for this feature; HeadObject permissions pre-existed.
- FR-007: `needs: deploy` and `aws cloudfront wait invalidation-completed` before `site_url`; live order confirmed on the three green deploy runs above.
- FR-008: no `gh pr merge` under `.github/workflows`; weekly job not added to required contexts in-repo.
- SC-001 through SC-005: staging present/absent, production verify, PR comments, and branch-protection live proof recorded above.
- Constitution I–VII: scoped docs PR, fixed stack untouched, OIDC-only, CI gates unchanged, English-only, no cost-adding infra in this feature.

## Convergence Findings

No actionable findings.

| ID | Gap Type | Severity | Source | Evidence | Remaining Work |
|----|----------|----------|--------|----------|----------------|
| — | — | — | — | Workflows, staging/production verify evidence, and branch-protection run `39949711442` match the spec | — |

**Summary metrics:**

- Requirements checked: 8 (FR-001 through FR-008)
- Success criteria checked: 5 (SC-001 through SC-005)
- Acceptance scenarios checked: 9 (US1/AC1–AC3, US2/AC1–AC3, US3/AC1–AC3)
- Plan decisions checked: 8 (verify after deploy, OIDC reuse, no IAM change in 005, exact-string guard, branch-protection PAT, FR-022 wait dependency, implementation task branches, English-only)
- Constitution principles checked: 7 (I through VII)
- Tasks checked: T001–T004, T006 done; T005 and T007 closed by this record
- Findings by gap type: missing 0, partial 0, contradicts 0, unrequested 0
- Findings by severity: CRITICAL 0, HIGH 0, MEDIUM 0, LOW 0

Outcome: `converged`.

## Next actions

No further `/speckit-implement` pass is needed for feature 005's specified scope. Jorge reviews and merges this converge pull request. Auto-merge is not enabled. Spec 002 T020 remains for a separate 002 converge update.

## Verdict

Date: 2026-10-23

SHA: `38a02ace3c94432f47c510ebfd81fd46ddce74ba`

**"✅ Converged — the implementation satisfies the spec, plan, and tasks."**

Verdict: Converged
