# Convergence: AWS Deployment

Feature: `specs/002-aws-deployment`

Command: `/speckit-converge`

Assessed commit: `5e20f1ddc5f99c899127f22cf6c99b1acaae5ff9`

Date: 2026-10-23

This file is the T016 and T017 record. `/speckit-converge` did not modify `spec.md` or `plan.md`, and it did not append a phase to `tasks.md`. `.specify/extensions.yml` is not present, so no before-converge or after-converge hooks ran.

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

## Verdict

Date: 2026-10-23

SHA: `5e20f1ddc5f99c899127f22cf6c99b1acaae5ff9`

**"✅ Converged — the implementation satisfies the spec, plan, and tasks."**

Verdict: Converged
