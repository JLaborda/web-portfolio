# Convergence: AWS Deployment

Feature: `specs/002-aws-deployment`

Command: `/speckit-converge`

Status: T016/T017 approved by Jorge — PR #34. T020 re-converge recorded below (PR pending Jorge merge).

Assessed commit (T016/T017): `5e20f1ddc5f99c899127f22cf6c99b1acaae5ff9`

Assessed commit (T020 re-converge): `e8fb157b112c2680d333d1a036696a2678a336f9`

Date: 2026-10-23

This file is the T016, T017, and T020 record. `/speckit-converge` did not modify `spec.md` or `plan.md`, and it did not append a phase to `tasks.md`. `.specify/extensions.yml` is not present, so no before-converge or after-converge hooks ran. Account ids, bucket names, distribution ids, and ARNs with an account id are omitted or written as `<redacted>`.

## Prerequisite check

```text
SPECIFY_FEATURE_DIRECTORY=specs/002-aws-deployment
.specify/scripts/bash/check-prerequisites.sh --json --require-spec --require-tasks --include-tasks
```

```json
{"FEATURE_DIR":"/workspace/specs/002-aws-deployment","AVAILABLE_DOCS":["research.md","data-model.md","contracts/","quickstart.md","tasks.md"]}
```

`spec.md`, `plan.md`, and `tasks.md` are present.

## FR-020

Jorge, repository admin, on 2026-10-22 at 13:24 Europe/Madrid (11:24 UTC), with `$b` set to `develop` and to `main`:

```bash
gh api repos/JLaborda/web-portfolio/branches/$b/protection --jq '{checks: .required_status_checks.contexts, enforce_admins: .enforce_admins.enabled}'
```

Stdout was identical for `develop` and for `main`:

```json
{"checks": ["hugo","lychee","gitleaks","terraform"], "enforce_admins": true}
```

The contexts are `hugo`, `lychee`, `gitleaks`, and `terraform`. `.enforce_admins.enabled` is `true`.

## US3/AC2, US3/AC3, and SC-002

T018 is the page-removal cycle on staging. The add half is pull request #32. The deletion half is pull request #33.

Add, pull request #32, deploy run `39778307366`, conclusion `success`, push of `500428731633dda52c2cf459d317edaae58516d4`:

- `site_url=https://d27iuevzdct8et.cloudfront.net`
- `curl -sS -o /dev/null -w '%{http_code}' https://d27iuevzdct8et.cloudfront.net/posts/spec-002-remove/` printed `200`
- `curl -fsS` of that URL piped to `grep -F spec-002-remove` exited 0. The page contains `spec-002-remove`
- Jorge, locally, key `posts/spec-002-remove/index.html` on the staging bucket (bucket name redacted): object present, exit 0. `LastModified` 2026-10-22T12:26:32Z, `ContentLength` 8279, `ETag` `"c6a017a007fa8c9b6dcaabd3d7ccdb6a"`, `ContentType` `text/html`, `ServerSideEncryption` `AES256`

Delete, pull request #33, deploy run `39801509001`, conclusion `success`, push of `5e20f1ddc5f99c899127f22cf6c99b1acaae5ff9`:

- `site_url=https://d27iuevzdct8et.cloudfront.net`
- Sync log, bucket name redacted: `delete: s3://<redacted>/posts/spec-002-remove/index.html`
- `if curl -fsS "https://d27iuevzdct8et.cloudfront.net/posts/spec-002-remove/" | grep -F 'spec-002-remove'; then exit 1; fi; echo exit=$?` printed `curl: (22) The requested URL returned error: 403` and `exit=0`
- `curl -sS -o /dev/null -w '%{http_code}'` on that URL printed `403`
- Jorge ran `if aws s3api head-object --bucket "$BUCKET_NAME" --key posts/spec-002-remove/index.html; then exit 1; fi` locally on the staging bucket (name redacted) at 08:45 Europe/Madrid on 2026-10-23. The call printed `An error occurred (404) when calling the HeadObject operation: Not Found` and `exit=254`. The `if` does not take the `exit 1` branch, so the check passes

`content/posts/spec-002-remove.md` is not on the assessed commit. `.github/workflows/deploy.yml` contains one `--delete`.

US3/AC3 also has the earlier successful deploy logs:

- Staging run `39765229871`, push of `d224c53c30822368fa4e2c9b27a42331a04973b9`: `site_url=https://d27iuevzdct8et.cloudfront.net`
- Production run `39768850371`, push of `2292272cdb129fa1eb50c493e6e0751528734f0b`: `site_url=https://d3kitcqjidoveq.cloudfront.net`

`.github/workflows/deploy.yml` contains `site_url=${SITE_URL}` and does not contain `site_url=${{ vars.SITE_URL }}`. It has no `pull_request` trigger.

## What was checked

The implementation assessed is `5e20f1ddc5f99c899127f22cf6c99b1acaae5ff9` on `develop`.

- FR-001 through FR-005, FR-015, FR-016, and FR-018: `deploy.yml` pushes `develop` and `main`, has one `--delete`, writes `robots.txt` by branch, and prints `site_url=${SITE_URL}`. The public staging and production deploys above succeeded. The removal cycle is recorded under SC-002.
- FR-006 through FR-013, FR-017, FR-019, and FR-021: the Terraform stacks, ignore rules, and bootstrap order shipped in the merged `t01` and `t02` pull requests. This run does not change them. `deploy.yml` and `terraform.yml` do not contain `terraform apply`.
- FR-014: checkout pin `3d3c42e5aac5ba805825da76410c181273ba90b1` and credentials pin `e1253824e5c10ff9df46874f81ed3ec929e19cfd` are in `deploy.yml`. The `HUGO_VERSION:` key count under `.github/workflows` is 1.
- FR-020: recorded above.
- SC-001 and SC-003: the two hostnames differ. Staging sends `x-robots-tag: noindex`. The removal URL returned 403 and did not contain `spec-002-remove`.
- SC-002: recorded above.
- SC-004: the 1 USD budget remains the `infra/shared` resource from T005. No email address is committed.
- SC-005: the commands in this run are listed under Checks.

## Checks

Run on this branch before the pull request, with Hugo extended 0.145.0, lychee 0.24.2, gitleaks 8.30.1, and actionlint 1.7.12:

- `hugo --gc --minify --panicOnWarning --baseURL /` exit 0, 17 pages
- `lychee --offline --root-dir public public` exit 0, 208 total, 0 errors
- `gitleaks detect --redact --log-opts="origin/develop..HEAD"` exit 0, no leaks
- `actionlint .github/workflows/*.yml` exit 0

## Convergence Findings

No actionable findings.

| ID | Gap Type | Severity | Source | Evidence | Remaining Work |
|----|----------|----------|--------|----------|----------------|
| — | — | — | — | The site, workflows, Terraform, branch protection, and the T018 removal cycle match the spec | — |

**Summary metrics:**

- Requirements checked: 21 (FR-001 through FR-021)
- Success criteria checked: 5 (SC-001 through SC-005)
- Acceptance scenarios checked: 9 (US1/AC1–AC3, US2/AC1–AC3, US3/AC1–AC3)
- Plan decisions checked: 12 (region `eu-west-1`, no custom DNS, Terraform 1.16.6, AWS provider 6.69.1, tflint 0.64.0 with AWS ruleset 0.49.0, Hugo version read from `ci.yml`, checkout `3d3c42e5aac5ba805825da76410c181273ba90b1`, `configure-aws-credentials` `e1253824e5c10ff9df46874f81ed3ec929e19cfd`, mikefarah yq 4.54.1, partial S3 backend, three OIDC roles, budget 1 USD, expected cost 0–1 USD)
- Constitution principles checked: 7 (I through VII)
- Tasks checked: T001 through T018. T016 and T017 are closed by this record. T018 is closed by pull requests #32 and #33.
- Findings by gap type: missing 0, partial 0, contradicts 0, unrequested 0
- Findings by severity: CRITICAL 0, HIGH 0, MEDIUM 0, LOW 0

Outcome: `converged`.

## Next actions

No further `/speckit-implement` pass is needed for feature 002. Jorge reviews this converge pull request. It carries `needs-human`. Auto-merge is not enabled.

## Verdict (T016/T017)

Date: 2026-10-23

SHA: `5e20f1ddc5f99c899127f22cf6c99b1acaae5ff9`

**"✅ Converged — the implementation satisfies the spec, plan, and tasks."**

Verdict: Converged

## T020 — First successful deploys after T019 (FR-022)

T019 landed as merge commit `5f46161efc88c80e9e59090a23b0ce51902eec02` (pull request #39, `002-aws-deployment-t07`, merged 2026-10-23T08:39:23Z).

Method: list `deploy.yml` runs via the GitHub API; keep only runs whose `head_sha` has `5f46161efc88c80e9e59090a23b0ce51902eec02` as an ancestor (`git merge-base --is-ancestor`); take the earliest `conclusion: success` on `develop` (staging) and on `main` (production). Do not treat earlier green runs that lack T019, or post-T019 failures at Invalidate, as this evidence.

The first push of T019 itself (run `39926189148`, head `5f46161efc88c80e9e59090a23b0ce51902eec02`) failed at step `Invalidate` before IAM `cloudfront:GetInvalidation` was applied. That failure is accepted by FR-022 / T020. Later failures `39933030396` and `39938609717` also failed at Invalidate before the successful runs below.

### Staging (develop) — first success including T019

| Field | Value |
|-------|-------|
| Run id | `39940179261` |
| Link | https://github.com/JLaborda/web-portfolio/actions/runs/39940179261 |
| Head SHA | `862dbf574101cde6420d0524225f6878a70f79a1` |
| Branch | `develop` |
| Conclusion | `success` |
| Created | `2026-10-23T10:35:23Z` |

Deploy job step order and timestamps (UTC):

| Step | Started | Completed | Conclusion |
|------|---------|-----------|------------|
| Invalidate | `2026-10-23T10:36:03Z` | `2026-10-23T10:36:25Z` | `success` |
| Record site URL | `2026-10-23T10:36:25Z` | `2026-10-23T10:36:25Z` | `success` |

Log order on the deploy job: the Invalidate step runs `aws cloudfront wait invalidation-completed` (script echo `2026-10-23T10:36:03.8120031Z`); that step completes at `10:36:25Z` before Record site URL starts; first printed `site_url=` line is `2026-10-23T10:36:25.7010624Z` → `site_url=https://d27iuevzdct8et.cloudfront.net`. Invalidate finished before `site_url` was produced or used.

### Production (main) — first success including T019

| Field | Value |
|-------|-------|
| Run id | `39942404001` |
| Link | https://github.com/JLaborda/web-portfolio/actions/runs/39942404001 |
| Head SHA | `7b7dc423e38f26e7ad664df97043593713eea186` |
| Branch | `main` |
| Conclusion | `success` |
| Created | `2026-10-23T10:54:44Z` |

Deploy job step order and timestamps (UTC):

| Step | Started | Completed | Conclusion |
|------|---------|-----------|------------|
| Invalidate | `2026-10-23T10:55:16Z` | `2026-10-23T10:55:37Z` | `success` |
| Record site URL | `2026-10-23T10:55:37Z` | `2026-10-23T10:55:37Z` | `success` |

Log order on the deploy job: wait command echo `2026-10-23T10:55:16.0676278Z`; Invalidate completes at `10:55:37Z` before Record site URL; first printed `site_url=` line is `2026-10-23T10:55:37.5767096Z` → `site_url=https://d3kitcqjidoveq.cloudfront.net`. Invalidate finished before `site_url` was produced or used. No earlier successful `main` run contains T019 (prior success `39768850371` is from 2026-10-22, before T019).

## `/speckit-converge` re-run (T020)

Date: 2026-10-23

Assessed SHA: `e8fb157b112c2680d333d1a036696a2678a336f9`

### Prerequisite check

```text
SPECIFY_FEATURE_DIRECTORY=specs/002-aws-deployment
.specify/scripts/bash/check-prerequisites.sh --json --require-spec --require-tasks --include-tasks
```

```json
{"FEATURE_DIR":"/workspace/specs/002-aws-deployment","AVAILABLE_DOCS":["research.md","data-model.md","contracts/","quickstart.md","tasks.md"]}
```

`spec.md`, `plan.md`, and `tasks.md` are present. `.specify/extensions.yml` is not present; no before-converge or after-converge hooks ran.

### What was checked (re-run)

- FR-001 through FR-021: still satisfied as in the T016/T017 record above (workflows, Terraform layout, hostnames, branch protection, T018 removal cycle).
- FR-022: `.github/workflows/deploy.yml` has `group: deploy-${{ github.ref }}`, `cancel-in-progress: false`, stores `Invalidation.Id`, runs `aws cloudfront wait invalidation-completed` before any `site_url=${SITE_URL}`. `infra/site/cdn.tf` grants `cloudfront:CreateInvalidation` and `cloudfront:GetInvalidation` on `aws_cloudfront_distribution.site.arn` only; policy `name` remains `cloudfront-create-invalidation`. `infra/shared` deploy policies allow only S3 on the environment bucket; no `GetInvalidation` in `infra/shared`. T020 run evidence above shows wait completing before `site_url=` on both environments.
- SC-001 through SC-005; US1/AC1–AC3, US2/AC1–AC3, US3/AC1–AC3: unchanged from the prior record.
- Constitution I–VII: no MUST violations found in scope.
- Tasks T001–T020: T019 code is present; T020 evidence is recorded in this section.

### Convergence Findings

No actionable findings. `/speckit-converge` did not append a Convergence phase to `tasks.md`.

| ID | Gap Type | Severity | Source | Evidence | Remaining Work |
|----|----------|----------|--------|----------|----------------|
| — | — | — | — | FR-022 and first successful post-T019 deploys match the spec | — |

**Summary metrics:**

- Requirements checked: 22 (FR-001 through FR-022)
- Success criteria checked: 5 (SC-001 through SC-005)
- Acceptance scenarios checked: 9 (US1/AC1–AC3, US2/AC1–AC3, US3/AC1–AC3)
- Plan decisions checked: 13 (prior 12 plus FR-022 concurrency / invalidation wait / GetInvalidation on site invalidate policy)
- Constitution principles checked: 7 (I through VII)
- Tasks checked: T001 through T020
- Findings by gap type: missing 0, partial 0, contradicts 0, unrequested 0
- Findings by severity: CRITICAL 0, HIGH 0, MEDIUM 0, LOW 0

Outcome: `converged`.

### Verdict (T020 re-converge)

Date: 2026-10-23

SHA: `e8fb157b112c2680d333d1a036696a2678a336f9`

**"✅ Converged — the implementation satisfies the spec, plan, and tasks."**

Verdict: Converged
