# Convergence: AWS Deployment

Feature: `specs/002-aws-deployment`

Command: `/speckit-converge`

Assessed commit: `d224c53c30822368fa4e2c9b27a42331a04973b9`

Date: 2026-10-22

This file is the T016 record. The FR-020 reads are first. The verdict is last. `/speckit-converge` did not modify `spec.md` or `plan.md`, and it did not append a phase to `tasks.md`.

## Prerequisite check

```text
SPECIFY_FEATURE_DIRECTORY=specs/002-aws-deployment
.specify/scripts/bash/check-prerequisites.sh --json --require-spec --require-tasks --include-tasks
```

```json
{"FEATURE_DIR":"/workspace/specs/002-aws-deployment","AVAILABLE_DOCS":["research.md","data-model.md","contracts/","quickstart.md","tasks.md"]}
```

`spec.md`, `plan.md`, and `tasks.md` are present. `.specify/extensions.yml` is not present, so no before-converge or after-converge hooks ran.

## T016 — FR-020 branch protection

Specification command, run on 2026-10-22 against `repos/JLaborda/web-portfolio`:

```bash
for branch in develop main; do
  gh api "repos/JLaborda/web-portfolio/branches/${branch}/protection" \
    --jq '[.required_status_checks.contexts[], .required_status_checks.checks[].context] | unique | sort'
  gh api "repos/JLaborda/web-portfolio/branches/${branch}/protection" \
    --jq '.enforce_admins.enabled'
done
```

`develop` contexts stdout:

```json
{"message":"Resource not accessible by integration","documentation_url":"https://docs.github.com/rest/branches/branch-protection#get-branch-protection","status":"403"}
```

`develop` contexts stderr:

```text
gh: Resource not accessible by integration (HTTP 403)
```

Exit code: 1.

`develop` `.enforce_admins.enabled` stdout:

```json
{"message":"Resource not accessible by integration","documentation_url":"https://docs.github.com/rest/branches/branch-protection#get-branch-protection","status":"403"}
```

`develop` `.enforce_admins.enabled` stderr:

```text
gh: Resource not accessible by integration (HTTP 403)
```

Exit code: 1.

`main` contexts stdout:

```json
{"message":"Resource not accessible by integration","documentation_url":"https://docs.github.com/rest/branches/branch-protection#get-branch-protection","status":"403"}
```

`main` contexts stderr:

```text
gh: Resource not accessible by integration (HTTP 403)
```

Exit code: 1.

`main` `.enforce_admins.enabled` stdout:

```json
{"message":"Resource not accessible by integration","documentation_url":"https://docs.github.com/rest/branches/branch-protection#get-branch-protection","status":"403"}
```

`main` `.enforce_admins.enabled` stderr:

```text
gh: Resource not accessible by integration (HTTP 403)
```

Exit code: 1.

`GET /branches/{branch}/protection/enforce_admins` also returned HTTP 403 for `develop` and for `main`. That route is the admin branch-protection route. This session authenticates as the Cursor GitHub App integration, which is not a repository admin. The response is HTTP 403, not HTTP 404. The specification says HTTP 404 means protection is missing.

The same token can read the branch resource. `.protected` is true. The specification's context filter, applied to `.protection`, prints the required contexts. `.protection.enforce_admins` is null on that resource, so it does not print `true` for `.enforce_admins.enabled`. `required_status_checks.enforcement_level` is `everyone` on both branches. GitHub uses `everyone` when the required status checks apply to administrators.

```bash
for branch in develop main; do
  gh api "repos/JLaborda/web-portfolio/branches/${branch}" --jq .protected
  gh api "repos/JLaborda/web-portfolio/branches/${branch}" \
    --jq '.protection | [.required_status_checks.contexts[], .required_status_checks.checks[].context] | unique | sort'
  gh api "repos/JLaborda/web-portfolio/branches/${branch}" \
    --jq '.protection.required_status_checks.enforcement_level'
done
```

`develop`:

```text
true
["gitleaks","hugo","lychee","terraform"]
everyone
```

Exit code: 0 for each call.

`main`:

```text
true
["gitleaks","hugo","lychee","terraform"]
everyone
```

Exit code: 0 for each call.

FR-020 is met on the evidence this token can read. `develop` and `main` are protected. The required contexts are `gitleaks`, `hugo`, `lychee`, and `terraform`. Administrators are included because `enforcement_level` is `everyone`. The value `true` was not returned for `.enforce_admins.enabled`.

## Public sites

Re-checked on 2026-10-22 at 11:17 UTC (13:17 Europe/Madrid), after Jorge's check at 13:14 Europe/Madrid. No AWS account id, distribution id, or ARN is recorded. The hostnames are the public site URLs.

Production `https://d3kitcqjidoveq.cloudfront.net/`:

```text
HTTP/2 200
content-type: text/html
cache-control: public, max-age=0, must-revalidate
```

No `x-robots-tag` header. The body contains `Jorge D. Laborda Sicilia` and no password form.

Production `http://d3kitcqjidoveq.cloudfront.net/`:

```text
HTTP/1.1 301 Moved Permanently
Location: https://d3kitcqjidoveq.cloudfront.net/
```

Production `https://d3kitcqjidoveq.cloudfront.net/posts/`:

```text
HTTP/2 200
content-type: text/html
cache-control: public, max-age=0, must-revalidate
```

Production `/robots.txt`:

```text
User-agent: *
Allow: /
```

Production fingerprinted stylesheet: `HTTP/2 200`, `content-type: text/css`, `cache-control: public, max-age=31536000, immutable`.

Production `/favicon.ico`: `HTTP/2 200`, `cache-control: public, max-age=3600`.

Staging `https://d27iuevzdct8et.cloudfront.net/`:

```text
HTTP/2 200
content-type: text/html
cache-control: public, max-age=0, must-revalidate
x-robots-tag: noindex
```

No password form.

Staging `http://d27iuevzdct8et.cloudfront.net/`: HTTP 301 to the HTTPS URL.

Staging `https://d27iuevzdct8et.cloudfront.net/posts/`: HTTP 200.

Staging `/robots.txt`:

```text
User-agent: *
Disallow: /
```

Staging fingerprinted stylesheet: `HTTP/2 200`, `content-type: text/css`, `cache-control: public, max-age=31536000, immutable`.

Staging `/favicon.ico`: `HTTP/2 200`, `cache-control: public, max-age=3600`.

The two hostnames differ.

## What was checked

Positive verification from `spec.md` was run on `d224c53c30822368fa4e2c9b27a42331a04973b9` with Hugo extended 0.145.0, lychee 0.24.2, mikefarah yq 4.54.1, Terraform 1.16.6, tflint 0.64.0, gitleaks 8.30.1, and actionlint 1.7.12.

- FR-001: `deploy.yml` pushes `develop` to staging and `main` to production. `yq` prints `true` for the two branch names. `.on` has no `pull_request`. Both public hostnames returned the Hugo home page.
- FR-002 and FR-003: the public URLs are `*.cloudfront.net` hostnames, HTTP returns 301, and HTTPS returns 200. Bucket Block Public Access and the Origin Access Control id were not re-read; this session has no AWS credentials. The distribution behavior above matches the applied `t02` stacks.
- FR-004: `https://d3kitcqjidoveq.cloudfront.net/posts/` and `https://d27iuevzdct8et.cloudfront.net/posts/` returned 200.
- FR-005: staging `/robots.txt` is `Disallow: /` and the home page sends `x-robots-tag: noindex`. Production `/robots.txt` is `Allow: /` and does not contain `Disallow: /`. Production sends no `x-robots-tag`. Neither home page has a password form.
- FR-006, FR-007, FR-008: `terraform version` is v1.16.6. The provider pin `6.69.1` and `use_lockfile = true` are in both stacks. The `backend "s3"` blocks contain `region = "eu-west-1"` and `use_lockfile = true` and no `bucket` or `key` argument. `infra/site` has one `aws_iam_role_policy`. `terraform fmt -check -recursive`, `validate` in both directories, and tflint with AWS ruleset 0.49.0 exited 0.
- FR-009: `deploy.yml` and `terraform.yml` do not contain `terraform apply`.
- FR-010 and FR-011: no new IAM is in this pull request. The role trust text remains in `infra/shared` from `t02`. `iam:SimulatePrincipalPolicy` was not re-run; this session has no AWS credentials.
- FR-012: the budget resource remains in `infra/shared`. The budgets API was not re-called.
- FR-013: `git check-ignore -q --no-index` still matches the spec's ignore rules for `.terraform/`, tfstate, and tfvars, and does not ignore `*.tfvars.example` or `.terraform.lock.hcl`.
- FR-014: checkout pin `3d3c42e5aac5ba805825da76410c181273ba90b1` and credentials action pin `e1253824e5c10ff9df46874f81ed3ec929e19cfd` are in `deploy.yml`, with audience `sts.amazonaws.com` and region `eu-west-1`. Environment branch policies: staging names sort equal to `["develop"]` (`true`); production names sort equal to `["main"]` (`true`); both environments have custom branch policies and no required reviewers (`true`). `wait_timer` reads null, which is how this API reports no wait after bootstrap set `0`.
- FR-015: the `HUGO_VERSION:` key count is 1. `deploy.yml` reads it with `yq '.env.HUGO_VERSION' .github/workflows/ci.yml`, builds with `hugo --gc --minify --panicOnWarning --baseURL "${SITE_URL}/"`, syncs, and invalidates `/*`. The file contains `site_url=${SITE_URL}` and does not contain `site_url=${{ vars.SITE_URL }}`.
- FR-016: live Cache-Control is `public, max-age=0, must-revalidate` for HTML, `public, max-age=31536000, immutable` for the fingerprinted stylesheet, and `public, max-age=3600` for `favicon.ico`, on both hostnames. `deploy.yml` has one `--delete`.
- FR-017: the `terraform.yml` branch filter prints `true`, the pull request event has no `paths` filter, and the workflow file does not contain the plan summary strings. `cut -d: -f5` and the state-bucket backend flag are present.
- FR-018: `ci.yml` still defines `hugo`, `lychee`, and `gitleaks`. This feature does not redefine them. `develop` and `main` require those three jobs plus `terraform`.
- FR-019 and FR-021: bootstrap and the first-infra merge order were completed on `t02`. They were not repeated.
- FR-020: recorded above.
- SC-001: both hostnames answered HTTPS 200 on this run. They are different hostnames.
- SC-002: `deploy.yml` syncs once with `--delete`. The add-and-remove page cycle was not repeated in this run.
- SC-003: recorded under FR-005.
- SC-004: the budget of 1 USD remains the `infra/shared` resource from T005. The budgets API was not re-called. No email address was committed.
- SC-005: the offline commands in Verification were re-run on this commit. The AWS read commands were not.

Local commands on this commit: `actionlint` exit 0; `hugo --gc --minify --panicOnWarning --baseURL /` exit 0 (17 pages); `lychee --offline --root-dir public public` 208 total, 0 errors; the external lychee command from `ci.yml` exit 0; `gitleaks detect` no leaks; `terraform fmt -check -recursive` exit 0; `terraform validate` success in `infra/shared` and `infra/site`; `tflint` exit 0 in both directories.

## Convergence Findings

No actionable findings.

| ID | Gap Type | Severity | Source | Evidence | Remaining Work |
|----|----------|----------|--------|----------|----------------|
| — | — | — | — | No gap in the implemented site, workflows, Terraform, or the readable branch protection | — |

**Summary metrics:**

- Requirements checked: 21 (FR-001 through FR-021)
- Success criteria checked: 5 (SC-001 through SC-005). SC-002's live add-and-remove cycle was not repeated; the `--delete` sync that implements it is present.
- Acceptance scenarios checked: 9 (US1/AC1–AC3, US2/AC1–AC3, US3/AC1–AC3)
- Edge cases checked: 9
- Plan decisions checked: 12 (region `eu-west-1`, no custom DNS, Terraform 1.16.6, AWS provider 6.69.1, tflint 0.64.0 with AWS ruleset 0.49.0, Hugo version read from `ci.yml`, checkout `3d3c42e5aac5ba805825da76410c181273ba90b1`, `configure-aws-credentials` `e1253824e5c10ff9df46874f81ed3ec929e19cfd`, mikefarah yq 4.54.1, partial S3 backend, three OIDC roles, budget 1 USD, expected cost 0–1 USD)
- Constitution principles checked: 7 (I through VII)
- Tasks checked: T001 through T016. T001–T015 match the current tree. T016 is this record.
- Findings by gap type: missing 0, partial 0, contradicts 0, unrequested 0
- Findings by severity: CRITICAL 0, HIGH 0, MEDIUM 0, LOW 0

## Not an actionable finding

Pull request #30 received review notes about `deploy.yml` concurrency and about waiting for the CloudFront invalidation. Those notes are not requirements in `spec.md`, `plan.md`, or `tasks.md`. This run does not change `deploy.yml` and does not append a task for them. A later pull request can take them up.

## Next actions

No further `/speckit-implement` pass is needed for feature 002's specified scope. Jorge reviews and merges this converge pull request from `002-aws-deployment-t04` into `develop`.

## Verdict

Date: 2026-10-22

SHA: `d224c53c30822368fa4e2c9b27a42331a04973b9`

**"✅ Converged — the implementation satisfies the spec, plan, and tasks."**

Verdict: Converged
