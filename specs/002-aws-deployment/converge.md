# Convergence: AWS Deployment

Feature: `specs/002-aws-deployment`

Command: `/speckit-converge`

Status: Approved by Jorge — PR #31

Assessed commit: `d224c53c30822368fa4e2c9b27a42331a04973b9`

Date: 2026-10-22

This file is the T016 record. The FR-020 read is first. The verdict is last. `/speckit-converge` did not modify `spec.md` or `plan.md`. `origin/develop` is still `d224c53c30822368fa4e2c9b27a42331a04973b9`, so the implementation SHA did not move. Phase 7 is already at the end of `tasks.md`. This update closes T017 with Jorge's admin output and leaves T018 open. No new phase was appended. The verdict is not `Converged`.

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

FR-020 is met. Jorge ran this as repository admin on 2026-10-22 at 13:24 Europe/Madrid (11:24 UTC), once with `$b=develop` and once with `$b=main`:

```bash
gh api repos/JLaborda/web-portfolio/branches/$b/protection --jq '{checks: .required_status_checks.contexts, enforce_admins: .enforce_admins.enabled}'
```

Stdout was identical for `develop` and for `main`:

```json
{"checks": ["hugo","lychee","gitleaks","terraform"], "enforce_admins": true}
```

The contexts are `hugo`, `lychee`, `gitleaks`, and `terraform`. `.enforce_admins.enabled` is `true`. Jorge did not include a separate numeric exit code in the report. This session did not re-run the admin route.

## Public sites

No AWS account id, distribution id, or ARN is recorded. The hostnames are the public site URLs.

### Jorge, 13:14 Europe/Madrid (11:14 UTC)

After the production deploy from pull request #30. Jorge's curls:

- Production `https://d3kitcqjidoveq.cloudfront.net/`: HTTP 200, no `x-robots-tag`, `last-modified` 11:13 GMT.
- Production `http://d3kitcqjidoveq.cloudfront.net/`: HTTP 301 to the HTTPS URL.
- Production `https://d3kitcqjidoveq.cloudfront.net/posts/`: HTTP 200.
- Staging `https://d27iuevzdct8et.cloudfront.net/`: HTTP 200, `x-robots-tag: noindex`.

Those four results show both home pages and the production posts index were live after that deploy. They do not show a page that was removed from the build. They do not apply to US3/AC2 or SC-002. They also do not contain the Actions job output, so they are not the US3/AC3 proof. US3/AC3 is the log line in the next section. Jorge's production `last-modified` of 11:13 GMT matches that production run.

### This session, 2026-10-22T11:31:17Z (13:31 Europe/Madrid)

`curl -sS -D - -o /tmp/curlbody --max-redirs 0`. Relevant header lines:

Production `https://d3kitcqjidoveq.cloudfront.net/`:

```text
HTTP/2 200
content-type: text/html
last-modified: Thu, 22 Oct 2026 11:13:00 GMT
cache-control: public, max-age=0, must-revalidate
```

No `x-robots-tag` header. The body contains `Jorge D. Laborda Sicilia` and does not contain a password form.

Production `http://d3kitcqjidoveq.cloudfront.net/`:

```text
HTTP/1.1 301 Moved Permanently
Location: https://d3kitcqjidoveq.cloudfront.net/
```

`curl` exit 47 is `--max-redirs 0` stopping on that redirect.

Production `https://d3kitcqjidoveq.cloudfront.net/posts/`:

```text
HTTP/2 200
content-type: text/html
last-modified: Thu, 22 Oct 2026 11:12:58 GMT
cache-control: public, max-age=0, must-revalidate
```

Production `/robots.txt`:

```text
HTTP/2 200
content-type: text/plain
cache-control: public, max-age=0, must-revalidate
```

```text
User-agent: *
Allow: /
```

Production fingerprinted stylesheet: `HTTP/2 200`, `content-type: text/css`, `last-modified: Thu, 22 Oct 2026 11:12:54 GMT`, `cache-control: public, max-age=31536000, immutable`.

Production `/favicon.ico`: `HTTP/2 200`, `content-type: image/vnd.microsoft.icon`, `cache-control: public, max-age=3600`.

Staging `https://d27iuevzdct8et.cloudfront.net/`:

```text
HTTP/2 200
content-type: text/html
last-modified: Thu, 22 Oct 2026 10:43:52 GMT
cache-control: public, max-age=0, must-revalidate
x-robots-tag: noindex
```

The body contains `Jorge D. Laborda Sicilia` and does not contain a password form.

Staging `http://d27iuevzdct8et.cloudfront.net/`:

```text
HTTP/1.1 301 Moved Permanently
Location: https://d27iuevzdct8et.cloudfront.net/
x-robots-tag: noindex
```

Staging `https://d27iuevzdct8et.cloudfront.net/posts/`: `HTTP/2 200`, `content-type: text/html`, `cache-control: public, max-age=0, must-revalidate`, `x-robots-tag: noindex`, `last-modified: Thu, 22 Oct 2026 10:43:50 GMT`.

Staging `/robots.txt`:

```text
HTTP/2 200
content-type: text/plain
cache-control: public, max-age=0, must-revalidate
x-robots-tag: noindex
```

```text
User-agent: *
Disallow: /
```

Staging fingerprinted stylesheet: `HTTP/2 200`, `content-type: text/css`, `cache-control: public, max-age=31536000, immutable`, `x-robots-tag: noindex`.

Staging `/favicon.ico`: `HTTP/2 200`, `content-type: image/vnd.microsoft.icon`, `cache-control: public, max-age=3600`, `x-robots-tag: noindex`.

The two hostnames differ. `git log --diff-filter=D --name-only origin/main -- content` lists no deleted file, so there is no removed page on `main` to curl.

## US3/AC3 — deploy log site URL

Verified from the successful `deploy.yml` runs. Both are `event: push`. The proof is the expanded log line `site_url=https://…cloudfront.net`. The earlier log lines echo the unexpanded script `echo "site_url=${SITE_URL}"` and are not the proof.

Staging, run `39765229871`, https://github.com/JLaborda/web-portfolio/actions/runs/39765229871

- `workflowName`: deploy
- `event`: push
- `headBranch`: develop
- `headSha`: `d224c53c30822368fa4e2c9b27a42331a04973b9`
- `conclusion`: success
- `createdAt`: 2026-10-22T10:43:25Z
- `displayTitle`: Add the Hugo deploy workflow for staging and production (#29)
- Log, step `Invalidate and record site URL`, 2026-10-22T10:44:05.0073121Z: `site_url=https://d27iuevzdct8et.cloudfront.net`

Production, run `39768850371`, https://github.com/JLaborda/web-portfolio/actions/runs/39768850371

- `workflowName`: deploy
- `event`: push
- `headBranch`: main
- `headSha`: `2292272cdb129fa1eb50c493e6e0751528734f0b`
- `conclusion`: success
- `createdAt`: 2026-10-22T11:12:35Z
- `displayTitle`: Release 002: AWS deployment (#30)
- Log, step `Invalidate and record site URL`, 2026-10-22T11:13:12.3924995Z: `site_url=https://d3kitcqjidoveq.cloudfront.net`

`grep -F 'site_url=${SITE_URL}' .github/workflows/deploy.yml` exits 0. `site_url=${{ vars.SITE_URL }}` is absent from that file.

## US3/AC2 and SC-002 — not verified

Jorge's 13:14 curls do not apply here. They are 200 and 301 responses for `/`, `/posts/`, and the HTTP redirect. They do not name a page that was removed from the build.

The add-page, deploy, delete, deploy cycle has never been run. One `--delete` on `aws s3 sync` in `deploy.yml` is the implementation. It is not a live result. `git log --diff-filter=D` on `origin/main` for `content/` lists no deleted file. This session has no AWS credentials, so `head-object` was not run. These items are a finding. They are not counted as verified.

Jorge runs this on staging. It needs two pull requests merged into `develop`. A direct push to `develop` is not the path: the spec says protection rejects it, including a push by Jorge, and a deploy follows a merge. This session did not open those pull requests and did not push to `develop`.

`SITE_URL` is `https://d27iuevzdct8et.cloudfront.net` with no trailing slash. `BUCKET_NAME` is the staging environment variable. Do not commit the bucket name.

1. Open a pull request into `develop` that adds `content/posts/spec-002-remove.md`. The file is a normal Hugo post whose body contains the string `spec-002-remove`. Merge it. The merge pushes `develop` and runs `deploy.yml` (staging). Wait until that run's conclusion is `success`.
2. After that deploy:

```bash
export SITE_URL=https://d27iuevzdct8et.cloudfront.net
aws s3api head-object --bucket "$BUCKET_NAME" --key posts/spec-002-remove/index.html
curl -fsS "${SITE_URL}/posts/spec-002-remove/" | grep -F 'spec-002-remove'
```

Expected: `head-object` exits 0, and `curl` prints a line containing `spec-002-remove`. Record both.

3. Open a second pull request into `develop` that deletes `content/posts/spec-002-remove.md`. Merge it. Wait until the next staging `deploy.yml` run's conclusion is `success`.
4. After that deploy:

```bash
export SITE_URL=https://d27iuevzdct8et.cloudfront.net
if aws s3api head-object --bucket "$BUCKET_NAME" --key posts/spec-002-remove/index.html; then exit 1; fi
if curl -fsS "${SITE_URL}/posts/spec-002-remove/" | grep -F 'spec-002-remove'; then exit 1; fi
```

Expected: both commands exit 0. `head-object` fails because the key is gone, and `curl` does not return the old page. Record both.

## What was checked

The implementation assessed is `d224c53c30822368fa4e2c9b27a42331a04973b9`. `git fetch origin develop` on 2026-10-22 still resolves `origin/develop` to that SHA. The production deploy SHA is `2292272cdb129fa1eb50c493e6e0751528734f0b` (the `main` commit of run `39768850371`). Documentation commits on `002-aws-deployment-t04` are not a new implementation SHA.

Positive checks that do not need AWS were run on that implementation with Hugo extended 0.145.0, lychee 0.24.2, mikefarah yq 4.54.1, Terraform 1.16.6, tflint 0.64.0, gitleaks 8.30.1, and actionlint 1.7.12.

- FR-001: `deploy.yml` pushes `develop` to staging and `main` to production. `.on` has no `pull_request`. Both public hostnames returned the Hugo home page. The two successful deploys above are `push` events.
- FR-002 and FR-003: the public URLs are `*.cloudfront.net` hostnames, HTTP returns 301, and HTTPS returns 200. Block Public Access and Origin Access Control were not re-read; this session has no AWS credentials. Those resources shipped in pull request #27 (`infra/site`: private bucket, origin access control, CloudFront distribution). Live `get-public-access-block` and `get-distribution` were not pasted in #27 or here. The public behavior above matches the applied stacks.
- FR-004: `https://d3kitcqjidoveq.cloudfront.net/posts/` and `https://d27iuevzdct8et.cloudfront.net/posts/` returned 200.
- FR-005: staging `/robots.txt` is `Disallow: /` and the home page sends `x-robots-tag: noindex`. Production `/robots.txt` is `Allow: /` and does not contain `Disallow: /`. Production sends no `x-robots-tag`. Neither home page has a password form.
- FR-006, FR-007, FR-008: `terraform version` is v1.16.6. The provider pin `6.69.1` and `use_lockfile = true` are in both stacks. The `backend "s3"` blocks contain `region = "eu-west-1"` and `use_lockfile = true` and no `bucket` or `key` argument. `infra/site` has one `aws_iam_role_policy`. `terraform fmt -check -recursive`, `validate` in both directories, and tflint with AWS ruleset 0.49.0 exited 0.
- FR-009: `deploy.yml` and `terraform.yml` do not contain `terraform apply`.
- FR-010 and FR-011: no new IAM is in this pull request. The role trust text remains in `infra/shared` from `t02`, merged as pull request #27. Jorge ran the live T010 `iam:SimulatePrincipalPolicy` script on 2026-10-22 from head `22fe035`: 31 of 31 rows match. That simulation was not re-run here.
- FR-012: the budget resource `web-portfolio-monthly` (1 USD) remains in `infra/shared` and was applied in the T009 bootstrap recorded on pull request #27. The Budgets describe API was not pasted in #27 and was not re-called here. No email address was committed.
- FR-013: `git check-ignore -q --no-index` still matches the spec's ignore rules for `.terraform/`, tfstate, and tfvars, and does not ignore `*.tfvars.example` or `.terraform.lock.hcl`.
- FR-014: checkout pin `3d3c42e5aac5ba805825da76410c181273ba90b1` and credentials action pin `e1253824e5c10ff9df46874f81ed3ec929e19cfd` are in `deploy.yml`, with audience `sts.amazonaws.com` and region `eu-west-1`. Re-read on 2026-10-22: staging deployment branch policy names sort equal to `["develop"]`; production names sort equal to `["main"]`; both environments have a `branch_policy` protection rule and no `required_reviewers` rule. The Environments API returned `wait_timer: null` for staging and for production. Bootstrap sent `"wait_timer": 0`. This file does not treat `null` as proof that the stored value is 0.
- FR-015: the `HUGO_VERSION:` key count is 1. `deploy.yml` reads it with `yq '.env.HUGO_VERSION' .github/workflows/ci.yml`, builds with `hugo --gc --minify --panicOnWarning --baseURL "${SITE_URL}/"`, syncs, and invalidates `/*`. The file contains `site_url=${SITE_URL}` and does not contain `site_url=${{ vars.SITE_URL }}`.
- FR-016: live Cache-Control is `public, max-age=0, must-revalidate` for HTML, `public, max-age=31536000, immutable` for the fingerprinted stylesheet, and `public, max-age=3600` for `favicon.ico`, on both hostnames. `deploy.yml` has one `--delete`.
- FR-017: the `terraform.yml` branch filter, the pull request event with no `paths` filter, and the absence of the plan summary strings were checked on the implementation. `cut -d: -f5` and the state-bucket backend flag are present.
- FR-018: `ci.yml` still defines `hugo`, `lychee`, and `gitleaks`. This feature does not redefine them. Jorge's admin output lists those three contexts plus `terraform` on `develop` and on `main`.
- FR-019 and FR-021: bootstrap and the first-infra merge order were completed on `t02` and recorded on pull request #27 (Terraform re-run `39623926947` green, three `No changes` summaries). They were not repeated.
- FR-020: met. Jorge's admin stdout at 13:24 Europe/Madrid is recorded above.
- SC-001: both hostnames answered HTTPS 200 on this run. They are different hostnames.
- SC-002: not verified. See the section above.
- SC-003: recorded under FR-005.
- SC-004: the 1 USD budget is the T005 resource applied in the T009 bootstrap on pull request #27. The email-when-spend-exceeds-1 path was not fired on this run. No email address was committed. The Budgets describe API was not re-called.
- SC-005: the offline commands in Verification were re-run on the implementation commit. The public curls in this file were run at 11:31 UTC. Jorge ran the admin FR-020 command at 11:24 UTC. The AWS read commands were not run in this session.

Local commands on the implementation commit: `actionlint` exit 0; `hugo --gc --minify --panicOnWarning --baseURL /` exit 0 (17 pages); `lychee --offline --root-dir public public` 208 total, 0 errors; the external lychee command from `ci.yml` exit 0; `gitleaks detect` no leaks; `terraform fmt -check -recursive` exit 0; `terraform validate` success in `infra/shared` and `infra/site`; `tflint` exit 0 in both directories.

Acceptance scenarios with recorded evidence: US1/AC1, US1/AC2, US1/AC3, US2/AC1, US2/AC2, US2/AC3, US3/AC1 (budget and T010 from pull request #27; the email was not fired here), US3/AC3 (the two run logs above; Jorge's 13:14 production curl matches that deploy's `last-modified` of 11:13 GMT). US3/AC2 has no live evidence.

T016 stays `[X]`. Its admin output is the FR-020 section above. Its required verdict `Converged` is still absent. T017 is `[X]` because that output is pasted. T018 stays open.

## Convergence Findings

| ID | Gap Type | Severity | Source | Evidence | Remaining Work |
|----|----------|----------|--------|----------|----------------|
| F2 | missing | HIGH | SC-002, US3/AC2 | No add, deploy, delete, deploy cycle. Jorge's 13:14 curls are `/`, `/posts/`, and the HTTP redirect. `content/` on `origin/main` has no deleted file. No `head-object` result | Record the two-merge staging cycle in T018 |

**Summary metrics:**

- Requirements checked: 21 (FR-001 through FR-021). FR-020 is met from Jorge's admin stdout.
- Success criteria checked: 5 (SC-001 through SC-005). SC-002 is missing.
- Acceptance scenarios checked: 9 (US1/AC1–AC3, US2/AC1–AC3, US3/AC1–AC3). 8 have recorded evidence. US3/AC2 does not.
- Edge cases checked: 9. `enforce_admins` true is Jorge's admin value. A rejected direct push was not performed in this run.
- Plan decisions checked: 12 (region `eu-west-1`, no custom DNS, Terraform 1.16.6, AWS provider 6.69.1, tflint 0.64.0 with AWS ruleset 0.49.0, Hugo version read from `ci.yml`, checkout `3d3c42e5aac5ba805825da76410c181273ba90b1`, `configure-aws-credentials` `e1253824e5c10ff9df46874f81ed3ec929e19cfd`, mikefarah yq 4.54.1, partial S3 backend, three OIDC roles, budget 1 USD, expected cost 0–1 USD)
- Constitution principles checked: 7 (I through VII). `Status: Approved by Jorge — PR #31` is the only status field. No constitution MUST is recorded as a code violation. The verdict is not `Converged`, which matches principle V's rule that QA blocks until it is.
- Tasks checked: T001 through T018. T001–T017 match the evidence in this file. T018 does not.
- Findings by gap type: missing 1, partial 0, contradicts 0, unrequested 0
- Findings by severity: CRITICAL 0, HIGH 1, MEDIUM 0, LOW 0

Outcome: not `Converged`. T018 remains from Phase 7. No new phase was appended.

## Not an actionable finding

Pull request #30 received review notes about `deploy.yml` concurrency and about waiting for the CloudFront invalidation. Those notes are not requirements in `spec.md`, `plan.md`, or `tasks.md`. This run does not change `deploy.yml` and does not append a task for them. Friday's retro or a later spec can take them up.

## Next actions

T017 is done. T018 (SC-002, US3/AC2) stays open and fits the approved spec. `/speckit-implement` completes it after the two staging merges and the `head-object` and `curl` results are in this file. A follow-up `/speckit-converge` writes `Converged` only when that evidence is in the file. This pull request is not the `Converged` close.

## Verdict

Date: 2026-10-22

SHA: `d224c53c30822368fa4e2c9b27a42331a04973b9`

`origin/develop` has not moved past that SHA. The production deploy SHA is `2292272cdb129fa1eb50c493e6e0751528734f0b`.

Not converged. FR-020 is met from Jorge's admin stdout at 13:24 Europe/Madrid. US3/AC2 and SC-002 have no live remove-page evidence.

Verdict: Not converged
