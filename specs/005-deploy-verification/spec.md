# Feature Specification: Automated Post-deploy Verification

**Feature Branch**: `005-deploy-verification`

**Created**: 2026-10-23

Status: Draft — pending Jorge's approval

**Input**: User description: "After each deploy to staging and production, verify the published artifacts and the public URL in GitHub Actions with the existing OIDC deploy role, comment the result on the merged pull request, and read branch protection for develop and main on a weekly schedule. Do not add long-lived AWS keys. Do not change branch protection."

Numbers 003 and 004 are reserved for the Now page and its automation. They are not in this repository yet. This feature is 005. `docs/adr/` has no earlier file on `develop`, so the decision record is ADR 001.

## Context

Jorge (Product Owner) verifies every deploy by hand. The deploy workflow assumes an OIDC role, syncs the site, and creates a CloudFront invalidation. Nothing in that run checks the objects or the public URL. The agents that open pull requests have no AWS credentials, and constitution III forbids long-lived AWS keys, so they cannot run `aws s3api head-object` themselves.

On 2026-10-23, `GET /repos/JLaborda/web-portfolio/branches/develop/protection` with the credential available to repository automation returned HTTP 403 and the message `Resource not accessible by integration`. `GITHUB_TOKEN` cannot read branch protection. The four required status checks and `enforce_admins` are visible only to a credential GitHub treats as an administrator.

The product owner listed manual S3 HeadObject checks on 22 October 2026 at 10:49, 13:24, and 16:54, and on 23 October 2026 at 08:45. This repository confirms two of those moments in `specs/002-aws-deployment/converge.md`. At 13:24 Europe/Madrid on 22 October, Jorge read branch protection on `develop` and on `main`. At 08:45 Europe/Madrid on 23 October, his local HeadObject for the removed T018 key returned `404 Not Found`. Pull request #33 merged at 2026-10-22T15:05:19Z. That 08:45 check is 15 hours 40 minutes later. The product owner described the wait as about 15.5 hours. The goal of this feature is to remove those manual checks from the normal deploy path.

The S3 permission is already on the deploy role. The gap is that no job assumes the role to run the check, and that no allowed credential reads branch protection on a schedule.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A deploy checks itself (Priority: P1)

Jorge merges a pull request. Staging or production publishes that commit. The same Actions run checks the objects that the commit should have published, checks a removed page is gone, and checks the public URL. He does not open a terminal to run HeadObject.

**Why this priority**: The manual object check is what held pull request #33 open for about 15.5 hours after the deploy. Without this check in the run, the other stories still leave Jorge as the verifier.

**Independent Test**: Merge a content change to `develop`. The deploy run fails if `index.html` is missing, if a page the commit edited is missing, if a page the commit deleted is still present or returns 403, or if the public URL checks do not match the environment. The run passes when every check matches. Jorge runs no AWS command.

**Acceptance Scenarios**:

1. **Given** a commit that edits a published page and is merged to `develop`, **When** the staging deploy run finishes, **Then** the run has checked `index.html` and that page's object, the public home page returned 200, HTTP redirected to HTTPS with 301, and the staging response included `x-robots-tag: noindex`.
2. **Given** a commit that deletes a published page, **When** that environment's deploy run finishes, **Then** HeadObject for the removed object reported `404 Not Found`, and a `403` failed the run.
3. **Given** the same kind of commit merged to `main`, **When** the production deploy run finishes, **Then** the same object and URL checks run against production, and the production response has no `x-robots-tag` header.
4. **Given** any mismatch, **When** the verification job finishes, **Then** the Actions run is failed.

---

### User Story 2 - The merged pull request shows the result (Priority: P2)

The pull request whose merge triggered the deploy receives a comment. Jorge can read the result next to the change. The comment does not contain an account id, a bucket name, a distribution id, or an email address.

**Why this priority**: A green run that only exists in the Actions log is easy to miss. The comment is the record on the change that was deployed.

**Independent Test**: After a merge deploy, the pull request has a comment with the run URL, the environment, the commit SHA, and one line per check with the expected value and the actual value. A search of that comment finds none of the four forbidden identifiers.

**Acceptance Scenarios**:

1. **Given** a successful staging deploy of a merged pull request, **When** the verification job completes, **Then** that pull request has a comment with the run URL, `staging`, the full commit SHA, and each check's expected and actual values.
2. **Given** a failed check, **When** the job completes, **Then** the comment is still posted and the run is failed.
3. **Given** the comment and the job summary, **When** a reviewer searches them, **Then** neither text contains an account id, a bucket name, a distribution id, or an email address.

---

### User Story 3 - Branch protection is read on a schedule (Priority: P3)

Once a week, and whenever someone starts the workflow by hand, a read-only job checks that `develop` and `main` still require `hugo`, `lychee`, `gitleaks`, and `terraform`, and that administrators are not exempt. The job writes the result to the job summary. It does not change the protection rule.

**Why this priority**: The 13:24 read on 22 October happened because automation received 403. The deploy check can ship before this read exists. The read is still required, because a silent drop of a required check would not fail a deploy.

**Independent Test**: Run the workflow with `workflow_dispatch`. The summary shows both branches. The run fails if a context is missing, if an extra context is required, or if `enforce_admins` is not enabled. The protection rule is unchanged afterwards.

**Acceptance Scenarios**:

1. **Given** the protection recorded for feature 002, **When** the scheduled job runs, **Then** the summary shows the four contexts and `enforce_admins` enabled for `develop` and for `main`, and the run succeeds.
2. **Given** a required context removed from `main`, **When** the job runs, **Then** the run fails and the summary shows the actual contexts.
3. **Given** the job, **When** it finishes, **Then** it has not called a write method on the branch protection API.

### Edge Cases

- A commit that does not change a published page still checks `index.html`, the home-page status, the HTTP to HTTPS redirect, and the robots header. The summary says that no page source changed.
- `content/posts/welcome.md` is a draft (`draft: true`). Editing or deleting that file does not add `posts/welcome/index.html` to either set. Feature 001 requires that object to stay unpublished.
- A commit that changes a published page into a draft expects the old object to be absent. The new draft is not expected to be present.
- A removed object that returns `403` fails the job. `s3:ListBucket` is what makes a missing key return `404 Not Found` instead of `403`. The T018 cycle in spec 002 is the example: key `posts/spec-002-remove/index.html` returned `404 Not Found`.
- HeadObject exit 254 is not, by itself, a pass. The stderr must contain `(404)` and `Not Found`. Exit 0 on an absent key is a failure.
- The deploy job's failure skips verification (`needs: deploy`, with no `if: always()`). The run is already failed. Verification does not comment on a commit that was not published.
- The commits API returns no pull request for the deployed SHA. The job still writes the summary, then exits 1. It does not comment on a different pull request.
- A re-run posts a second comment. It does not edit or delete the first comment.
- `SITE_URL`, `BUCKET_NAME`, `DISTRIBUTION_ID`, or `AWS_ROLE_ARN` is empty. The job prints `::error::<name> is empty` and exits 1. It does not print the value.
- The branch-protection secret is empty, or the API returns 403. The job writes the HTTP status in the summary and exits 1. It does not fall back to `GITHUB_TOKEN`.
- The weekly job is not a required status check. Putting it on the required list would change branch protection, which this feature does not do.
- Verification does not run on `pull_request`. A pull request does not deploy. The comment appears after the merge deploy.
- Spec 002 FR-022 is not on `develop` yet. Today's deploy job creates the invalidation and does not wait for it. A verification job that ran before that wait would race the invalidation. The implementation pull request stays closed until FR-022 is implemented.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `.github/workflows/deploy.yml` gains a job named `verify`. It runs on the existing `push` to `develop` and `main`. The workflow gains no `pull_request` trigger and no top-level `permissions` key. The job `deploy` keeps exactly `id-token: write` and `contents: read`. The job `verify` sets `needs: deploy` and does not set `if: always()`. Its `environment` is the same expression the deploy job already uses: `${{ github.ref_name == 'main' && 'production' || 'staging' }}`. It assumes `vars.AWS_ROLE_ARN` with `aws-actions/configure-aws-credentials` at commit `e1253824e5c10ff9df46874f81ed3ec929e19cfd`, region `eu-west-1`, audience `sts.amazonaws.com`. That is the existing OIDC deploy role for the GitHub Environment. The job does not assume `web-portfolio-plan`. The workflow does not contain `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, or `terraform apply`. Checkout in `verify` uses `actions/checkout` at `3d3c42e5aac5ba805825da76410c181273ba90b1` with `fetch-depth: 2`. Any failed check fails the job, and therefore the run. **Acceptance**: the FR-001 block in Verification exits 0.

- **FR-002**: The job `verify` checks a set of S3 object keys with `aws s3api head-object`. The bucket is `BUCKET_NAME` from the GitHub Environment. The bucket name is not written to the summary or the comment. The present set always contains `index.html`. Other keys come from `git diff-tree --no-commit-id --name-status -r HEAD` (fetch-depth 2, so the parent exists). A path is a page source when it matches `content/` and ends in `.md`. Front matter is the text between the opening line `---` and the next line that is exactly `---`. A line `draft: true` (optional quotes, no extra words) marks a draft. A line `slug: <value>` sets the last URL segment. The object key is derived as follows. `content/<dir>/_index.md` and `content/<dir>/index.md` use `<dir>/index.html` (`content/_index.md` uses `index.html`). Any other file uses `<dir>/<slug-or-filename>/index.html`, with `slug` winning over the filename when it is set. Status `A` or `M` on a non-draft expects the key present (HeadObject exit 0). Status `D` on a non-draft parent blob expects the key absent. Status `M` whose new blob is a draft and whose parent blob was not a draft expects the key absent. A draft that was never published is in neither set. A rename expects the old key absent when the old blob was published and the new key present when the new blob is published. Absent means HeadObject's stderr contains `(404)` and `Not Found`, and does not contain `(403)`. Exit 0 on an absent key fails the job. The T018 key `posts/spec-002-remove/index.html` is the absent-mode example. When the diff has no published page, the present set is exactly `index.html` and the summary says that no page source changed. **Acceptance**: the FR-002 block in Verification exits 0, including the oracle rows.

- **FR-003**: The same job checks the public URL with curl. `SITE_URL` has no trailing slash, as spec 002 requires. `curl -sS -o /dev/null -w '%{http_code}' "${SITE_URL}/"` equals `200`. `curl -sI -o /dev/null -w '%{http_code}' "http://${SITE_URL#https://}/"` equals `301` (no `-L`, so the first status is the redirect). On `staging`, `curl -fsSI "${SITE_URL}/"` has a header line matching `^x-robots-tag: noindex` (comparison is case-insensitive). On `production`, that response has no header line matching `^x-robots-tag:`. Any other environment name fails the job. **Acceptance**: the FR-003 block in Verification exits 0.

- **FR-004**: The job writes every check to the job summary and posts the same rows as a comment on the pull request whose merge triggered the deploy. The pull request list is `GET /repos/JLaborda/web-portfolio/commits/${GITHUB_SHA}/pulls`. The job comments on each returned number. An empty list fails the job after the summary is written. The comment and the summary include the run URL (`${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}`), the environment name (`staging` or `production`), the full commit SHA, and each check with its expected value and its actual value. They do not include an account id, a bucket name, a distribution id, or an email address. Before the post, a guard on the comment file and on the summary file exits 1 when the text matches `[0-9]{12}`, `@`, `BUCKET_NAME`, `DISTRIBUTION_ID`, or `arn:aws`. The comment step uses `GH_TOKEN` from `github.token`. The job's permissions are exactly `id-token: write`, `contents: read`, and `pull-requests: write`. The deploy job does not gain `pull-requests`. A failed check still posts the comment, then the job exits 1. A failed comment API call exits 1 as well. **Acceptance**: the FR-004 block in Verification exits 0.

- **FR-005**: A workflow `.github/workflows/branch-protection.yml` has one job named `branch-protection`. It runs on `schedule` with cron `0 9 * * 1` (Monday 09:00 UTC) and on `workflow_dispatch`. It has no `pull_request` trigger and no `push` trigger. It reads protection for `develop` and for `main` with `GET /repos/JLaborda/web-portfolio/branches/{branch}/protection`. For each branch the sorted `required_status_checks.contexts` equal `gitleaks`, `hugo`, `lychee`, and `terraform`, and `.enforce_admins.enabled` is true. The job writes both results to the job summary, then exits 1 if either branch mismatched or if the HTTP status was not 200. A 403 is a failed check, not a skip. The workflow file does not contain an HTTP method that writes protection (`PUT`, `PATCH`, `DELETE`, or `POST` against the protection URL). This job is not added to the required status checks. The credential is [NEEDS CLARIFICATION: which credential reads branch protection. Option A (recommended): a fine-grained personal access token with Administration read-only on this repository only, stored as the repository secret `BRANCH_PROTECTION_READ_TOKEN`, created by Jorge (needs-human). Option B: a GitHub App installed on this repository only, with Administration read. `GITHUB_TOKEN` returns 403 and must not be used for this call. The implementation of this job waits until Jorge chooses. The Verification block for option A is the acceptance check when he chooses A. If he chooses B, `/speckit-clarify` replaces the secret name and keeps the same assertions.] The job's `GITHUB_TOKEN` permissions are `contents: read` only. When option A is chosen, an empty secret prints `::error::BRANCH_PROTECTION_READ_TOKEN is unset` and exits 1, and the workflow does not reference `github.token` or `secrets.GITHUB_TOKEN`. **Acceptance**: the FR-005 "now" block in Verification exits 0 on this spec pull request. After Jorge chooses, the implementation block exits 0. The option A block exits 0 only when he chooses A.

- **FR-006**: Inspected on `develop` at `fe5f5329065e2fbfdb248f542bf6cc5ac2a1258f`. `HeadObject` is authorized by `s3:GetObject` on the object. A missing key returns `404 Not Found` when the caller also has `s3:ListBucket` on the bucket, and `403 Forbidden` when the caller does not. Both deploy roles already have both actions, scoped to that environment's bucket, with no wildcard action and no wildcard resource. In `infra/shared/iam.tf`, `aws_iam_role_policy.staging_deploy` (policy name `web-portfolio-staging-deploy`) has statement `ListStagingBucket` allowing `s3:ListBucket` on `arn:aws:s3:::${local.staging_bucket}`, and statement `WriteStagingObjects` allowing `s3:DeleteObject`, `s3:GetObject`, and `s3:PutObject` on `arn:aws:s3:::${local.staging_bucket}/*`. `aws_iam_role_policy.production_deploy` (policy name `web-portfolio-production-deploy`) has the same shape for `local.production_bucket` (`ListProductionBucket`, `WriteProductionObjects`). `local.staging_bucket` is `web-portfolio-staging-${local.account_id}` and `local.production_bucket` is `web-portfolio-production-${local.account_id}`. The account id is not written in this spec. In `infra/site/cdn.tf`, `aws_iam_role_policy.invalidate` (policy name `cloudfront-create-invalidation`) allows only `cloudfront:CreateInvalidation` on that stack's distribution ARN. It allows no S3 action. `infra/site/bucket.tf` allows `s3:GetObject` to `cloudfront.amazonaws.com` only, under the distribution source ARN. The T018 object was SSE-S3 (`AES256`), and the site bucket declares no KMS key, so HeadObject does not need `kms:Decrypt`. This feature adds no IAM action, no policy, and no rename. The implementation pull request does not change `infra/`. `terraform plan` is not an acceptance check for this feature, because there is no Terraform diff to show. Spec 002 FR-022's `cloudfront:GetInvalidation` addition is a different change, on pull request #35's implementation, and is not an S3 gap. **Acceptance**: the FR-006 block in Verification exits 0. A diff under `infra/` fails it.

- **FR-007**: Spec 002 FR-022, in open pull request #35 (https://github.com/JLaborda/web-portfolio/pull/35), adds branch-scoped concurrency `group: deploy-${{ github.ref }}` with `cancel-in-progress: false`, stores the invalidation id, and runs `aws cloudfront wait invalidation-completed` before `site_url` is written or printed. The job `verify` uses `needs: deploy`, so it starts only after that wait has exited 0. The Web Developer does not open the implementation pull request until FR-022 is on `develop` and the `deploy.yml` change it requires is merged. This spec pull request does not edit `deploy.yml` and does not make its own merge wait on #35. **Acceptance**: the FR-007 block in Verification exits 0 on this spec pull request (no `deploy.yml` diff, and the spec names the dependency). On the implementation pull request, `needs: deploy` is present and the wait command from FR-022 appears in the deploy job above `site_url`.

- **FR-008**: This feature does not automate a merge Jorge makes. The workflows do not contain `gh pr merge`. It does not change branch protection. It does not add an AWS resource, an IAM action, a custom domain, an ACM certificate, or a Route 53 record. It does not probe the SmartWealthAI repository and it does not probe health-stream-xai. A page of this site whose source is `content/projects/smartwealthai.md` remains an ordinary page of this site when that file changes, and FR-002 applies to it. The weekly workflow is not added to the required contexts `hugo`, `lychee`, `gitleaks`, and `terraform`. **Acceptance**: the FR-008 block in Verification exits 0.

### Key Entities

- **Verification report**: The environment name, the commit SHA, the run URL, and one row per check (name, expected, actual). Stored as the job summary and as the pull request comment.
- **Expected object**: An S3 key in the present set or the absent set, derived from the commit's page sources, plus `index.html` always present.
- **Branch-protection snapshot**: For `develop` and for `main`, the sorted required contexts and whether `enforce_admins` is enabled. Read-only.
- **Deploy role**: The existing role `web-portfolio-staging-deploy` or `web-portfolio-production-deploy`, assumed through the GitHub Environment. Not a new role.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: After a deploy to staging, and after a deploy to production, that deploy's own run records a pass or a fail for the live home page and for every expected artifact. A mismatch fails the run. Jorge does not run a separate object check for that deploy.
- **SC-002**: When a published page is removed, the same run records that the object is missing. A forbidden response fails the run. The removed page's text is not treated as a successful fetch.
- **SC-003**: The pull request that was merged shows the run link, the environment, the commit, and each check's expected and actual values. A reviewer can confirm that the note has no account identifier, storage-bucket name, distribution identifier, or email address.
- **SC-004**: A weekly run, and a run started by hand, records whether both protected branches still require the four existing gates and still apply them to administrators. Drift fails the run. The run does not change the protection settings.
- **SC-005**: A reviewer can run every command in Verification and compare it to the expected result named there.

## Verification

Commands marked "now" run on this spec pull request, from the repository root. Commands marked "implementation" run on the implementation pull request, after FR-007's dependency is on `develop`. `yq` in those commands is mikefarah yq 4.54.1, the pin `.github/workflows/deploy.yml` already installs. `ACCOUNT` is never printed.

- **FR-001** (implementation):

  ```bash
  yq -e '[.on.push.branches[] | select(. == "develop" or . == "main")] | unique | length == 2' .github/workflows/deploy.yml
  if yq -e '.on | has("pull_request")' .github/workflows/deploy.yml >/dev/null; then exit 1; fi
  if yq -e '. | has("permissions")' .github/workflows/deploy.yml >/dev/null; then exit 1; fi
  yq -e '.jobs.deploy.permissions == {"contents": "read", "id-token": "write"}' .github/workflows/deploy.yml
  yq -e '.jobs.verify.needs == "deploy"' .github/workflows/deploy.yml
  if yq -e '.jobs.verify | has("if")' .github/workflows/deploy.yml >/dev/null; then exit 1; fi
  yq -e '.jobs.verify.environment == .jobs.deploy.environment' .github/workflows/deploy.yml
  grep -F "github.ref_name == 'main' && 'production' || 'staging'" .github/workflows/deploy.yml
  test "$(grep -F -c "github.ref_name == 'main' && 'production' || 'staging'" .github/workflows/deploy.yml)" = 2
  grep -F 'e1253824e5c10ff9df46874f81ed3ec929e19cfd' .github/workflows/deploy.yml
  grep -F '3d3c42e5aac5ba805825da76410c181273ba90b1' .github/workflows/deploy.yml
  grep -F 'fetch-depth: 2' .github/workflows/deploy.yml
  grep -F 'aws-region: eu-west-1' .github/workflows/deploy.yml
  grep -F 'audience: sts.amazonaws.com' .github/workflows/deploy.yml
  if grep -E 'AWS_ACCESS_KEY_ID|AWS_SECRET_ACCESS_KEY|terraform apply' .github/workflows/deploy.yml; then exit 1; fi
  ```

  Expected: every command exits 0. The two `has(...)` guards do not take the `exit 1` branch. The environment expression occurs twice. The key-name guard prints nothing.

- **FR-002** (implementation): the job contains `git diff-tree --no-commit-id --name-status -r HEAD` and `aws s3api head-object`. The oracle below is the mapping. A reviewer applies it to these fixtures. `draft: true` is a front-matter line. The parent column is the blob at `HEAD^` when the status is not `A`.

  | Path | Status | Parent draft | New draft | Key | Set |
  | --- | --- | --- | --- | --- | --- |
  | `content/about.md` | M | no | no | `about/index.html` | present |
  | `content/posts/_index.md` | M | no | no | `posts/index.html` | present |
  | `content/projects/smartwealthai.md` | A | — | no | `projects/smartwealthai/index.html` | present |
  | `content/posts/welcome.md` | M | yes | yes | — | neither |
  | `content/posts/spec-002-remove.md` | D | no | — | `posts/spec-002-remove/index.html` | absent |
  | `content/now.md` | M | no | yes | `now/index.html` | absent |

  ```bash
  grep -F 'git diff-tree --no-commit-id --name-status -r HEAD' .github/workflows/deploy.yml
  grep -F 'aws s3api head-object' .github/workflows/deploy.yml
  grep -F '(404)' .github/workflows/deploy.yml
  grep -F 'Not Found' .github/workflows/deploy.yml
  grep -F '(403)' .github/workflows/deploy.yml
  ```

  Expected: each `grep -F` exits 0. Present rows fail the run when HeadObject exits non-zero. The absent row passes only when stderr contains `(404)` and `Not Found` and does not contain `(403)`. The welcome row adds no key.

- **FR-003** (implementation):

  ```bash
  grep -F 'curl -sS -o /dev/null -w' .github/workflows/deploy.yml
  grep -F 'curl -sI -o /dev/null -w' .github/workflows/deploy.yml
  grep -F 'x-robots-tag: noindex' .github/workflows/deploy.yml
  grep -F 'x-robots-tag:' .github/workflows/deploy.yml
  ```

  Expected: each `grep -F` exits 0. Against a live deploy, the home page status is `200`, the HTTP status without `-L` is `301`, staging has the noindex header, and production has no `x-robots-tag` header. The live curl is the one in FR-003. It uses `SITE_URL` from the environment and does not hard-code a hostname.

- **FR-004** (implementation):

  ```bash
  yq -e '.jobs.verify.permissions == {"contents": "read", "id-token": "write", "pull-requests": "write"}' .github/workflows/deploy.yml
  if yq -e '.jobs.deploy.permissions | has("pull-requests")' .github/workflows/deploy.yml >/dev/null; then exit 1; fi
  grep -F 'commits/${GITHUB_SHA}/pulls' .github/workflows/deploy.yml
  grep -F 'actions/runs/${GITHUB_RUN_ID}' .github/workflows/deploy.yml
  grep -F 'BUCKET_NAME|DISTRIBUTION_ID' .github/workflows/deploy.yml
  if grep -E 'web-portfolio-(staging|production)-[0-9]{12}' .github/workflows/deploy.yml; then exit 1; fi
  ```

  Expected: `yq` prints `true` and exits 0. The `pull-requests` guard does not take the `exit 1` branch. The two `grep -F` commands for the API path and the run URL exit 0. The guard pattern `BUCKET_NAME|DISTRIBUTION_ID` is present in the workflow so the comment file and the summary file are rejected when they contain those names. The literal bucket-name guard prints nothing.

- **FR-005** (now): the workflow file is not part of this spec pull request. The spec records the cron, the four contexts, and the open credential question.

  ```bash
  test ! -e .github/workflows/branch-protection.yml
  grep -F '0 9 * * 1' specs/005-deploy-verification/spec.md
  grep -F '[NEEDS CLARIFICATION:' specs/005-deploy-verification/spec.md
  grep -F 'BRANCH_PROTECTION_READ_TOKEN' specs/005-deploy-verification/spec.md
  ```

  Expected: the workflow file is absent. Each `grep -F` exits 0.

  **FR-005** (implementation):

  ```bash
  test -f .github/workflows/branch-protection.yml
  yq -e '.on.schedule[0].cron == "0 9 * * 1"' .github/workflows/branch-protection.yml
  yq -e '.on | has("workflow_dispatch")' .github/workflows/branch-protection.yml
  if yq -e '.on | (has("pull_request") or has("push"))' .github/workflows/branch-protection.yml >/dev/null; then exit 1; fi
  yq -e '.jobs | has("branch-protection")' .github/workflows/branch-protection.yml
  grep -F 'enforce_admins' .github/workflows/branch-protection.yml
  grep -F 'gitleaks' .github/workflows/branch-protection.yml
  grep -F 'hugo' .github/workflows/branch-protection.yml
  grep -F 'lychee' .github/workflows/branch-protection.yml
  grep -F 'terraform' .github/workflows/branch-protection.yml
  if grep -E -- '-X PUT|-X POST|-X PATCH|-X DELETE|method: PUT|method: POST|method: PATCH|method: DELETE|--method PUT|--method POST|--method PATCH|--method DELETE' .github/workflows/branch-protection.yml; then exit 1; fi
  ```

  Expected: the file exists. Each `yq -e` prints `true` and exits 0. The trigger guard does not take the `exit 1` branch. Each context grep exits 0. The write-method guard prints nothing. `yq` is mikefarah yq 4.54.1, the same pin the deploy workflow already installs.

  Option A, after Jorge chooses A (implementation):

  ```bash
  grep -F 'secrets.BRANCH_PROTECTION_READ_TOKEN' .github/workflows/branch-protection.yml
  grep -F 'BRANCH_PROTECTION_READ_TOKEN is unset' .github/workflows/branch-protection.yml
  if grep -E 'github\.token|secrets\.GITHUB_TOKEN' .github/workflows/branch-protection.yml; then exit 1; fi
  ```

  Expected: the two `grep -F` commands exit 0. The token guard prints nothing. Jorge creates the repository secret. The workflow file does not contain the token value.

- **FR-006** (now):

  ```bash
  if git diff --name-only origin/develop...HEAD -- infra | grep -q .; then exit 1; fi
  python3 - <<'PY'
  import pathlib, re, sys
  shared = pathlib.Path("infra/shared/iam.tf").read_text()
  site = pathlib.Path("infra/site/cdn.tf").read_text()

  def doc(src, name):
      m = re.search(r'data "aws_iam_policy_document" "%s" \{(.*?)\n\}' % name, src, re.S)
      if not m:
          sys.exit("missing document %s" % name)
      return m.group(1)

  for name, local in (
      ("staging_deploy", "local.staging_bucket"),
      ("production_deploy", "local.production_bucket"),
  ):
      body = doc(shared, name)
      if "s3:*" in body or re.search(r'resources\s*=\s*\[\s*"\*"\s*\]', body):
          sys.exit("%s has a wildcard" % name)
      list_res = "arn:aws:s3:::${%s}" % local
      obj_res = list_res + "/*"
      statements = re.findall(r"statement \{(.*?)\n  \}", body, re.S)
      found_list = found_get = False
      for st in statements:
          if '"s3:ListBucket"' in st:
              found_list = True
              if obj_res in st or list_res not in st:
                  sys.exit("%s ListBucket resource" % name)
          if '"s3:GetObject"' in st:
              found_get = True
              if obj_res not in st:
                  sys.exit("%s GetObject resource" % name)
              if re.search(r'arn:aws:s3:::\$\{%s\}"' % re.escape(local), st):
                  sys.exit("%s GetObject on bucket ARN" % name)
      if not found_list or not found_get:
          sys.exit("%s missing action" % name)
  inv = doc(site, "invalidate")
  if "s3:" in inv or "cloudfront:GetInvalidation" in inv:
      sys.exit("invalidate policy is not S3-clean")
  if "cloudfront:CreateInvalidation" not in inv:
      sys.exit("missing CreateInvalidation")
  if 'name   = "cloudfront-create-invalidation"' not in site:
      sys.exit("invalidate policy renamed")
  if 'name   = "web-portfolio-staging-deploy"' not in shared:
      sys.exit("staging policy renamed")
  if 'name   = "web-portfolio-production-deploy"' not in shared:
      sys.exit("production policy renamed")
  print("iam-ok")
  PY
  ```

  Expected: the diff guard exits 0. The script prints `iam-ok` and exits 0. ListBucket is on the bucket ARN. GetObject is on the object ARN. The invalidate policy grants no S3 action and is still named `cloudfront-create-invalidation`.

- **FR-007** (now):

  ```bash
  if git diff --name-only origin/develop...HEAD -- .github/workflows/deploy.yml | grep -q .; then exit 1; fi
  python3 - <<'PY'
  import pathlib, sys
  text = pathlib.Path("specs/005-deploy-verification/spec.md").read_text()
  # Each string has to appear in the requirement, not only inside this script.
  for needle in (
      "https://github.com/JLaborda/web-portfolio/pull/35",
      "aws cloudfront wait invalidation-completed",
      "needs: deploy",
      "FR-022",
  ):
      if text.count(needle) < 2:
          sys.exit("missing from the requirement text: %s" % needle)
  print("dependency-ok")
  PY
  ```

  Expected: `deploy.yml` is not in the diff. The script prints `dependency-ok` and exits 0.

- **FR-008** (now): this pull request adds no workflow file. The forbidden command is named in the requirement so a later review can search for it. The search target on this pull request is the workflow directory.

  ```bash
  if git diff --name-only origin/develop...HEAD -- .github | grep -q .; then exit 1; fi
  ```

  Expected: no path under `.github` is in the diff, so the guard exits 0.

  **FR-008** (implementation):

  ```bash
  if grep -R -n 'gh pr merge' .github/workflows; then exit 1; fi
  ```

  Expected: the guard exits 0. A workflow that runs `gh pr merge` makes the guard exit 1. The branch-protection workflow still has no write method (FR-005).

- **Identifiers** (now): the patterns live in this script as escaped expressions, so the script source is not itself a literal account id, email, or hostname.

  ```bash
  python3 - <<'PY'
  import pathlib, re, sys
  roots = [pathlib.Path("specs/005-deploy-verification"), pathlib.Path("docs/adr/001-post-deploy-verification.md")]
  files = []
  for root in roots:
      files.extend(root.rglob("*") if root.is_dir() else [root])
  account = re.compile(r"(?<![0-9A-Fa-f])[0-9]{12}(?![0-9A-Fa-f])")
  email = re.compile(r"@[A-Za-z0-9.-]+\.[A-Za-z]{2,}")
  host = re.compile(r"cloudfront\.net")
  bad = []
  for path in files:
      if not path.is_file():
          continue
      for i, line in enumerate(path.read_text().splitlines(), 1):
          if account.search(line) or email.search(line) or host.search(line):
              bad.append("%s:%s" % (path, i))
  if bad:
      sys.exit("\n".join(bad))
  print("identifiers-ok")
  PY
  ```

  Expected: the script prints `identifiers-ok` and exits 0. The spec names each bucket as a Terraform interpolation. It does not name a literal bucket, a distribution hostname, or an email address.

## Dependency

Implementation of the job `verify` depends on spec 002 FR-022. That requirement is open pull request #35 (https://github.com/JLaborda/web-portfolio/pull/35, branch `followup-002-clarify`). FR-022 adds `concurrency` (`group: deploy-${{ github.ref }}`, `cancel-in-progress: false`) and `aws cloudfront wait invalidation-completed` before the deploy job reports the site URL. It also adds `cloudfront:GetInvalidation` on the existing invalidate policy. That IAM change belongs to FR-022. This feature does not add it and does not replace it.

`needs: deploy` is what places verification after the invalidation wait. Until the wait is in `deploy.yml`, verification would run when `create-invalidation` returns, which is before the invalidation finishes. The Web Developer does not open the implementation pull request until FR-022 is merged to `develop` and the workflow change is merged. This spec pull request does not edit the workflow, so its merge does not depend on #35. Constitution I says a pull request must not depend on an unmerged pull request. That rule is kept for this pull request. The dependency is on the later implementation.

## Out of Scope

- Automating any merge Jorge does, including `gh pr merge` and auto-merge.
- Changing branch protection, including adding this feature's weekly job to the required status checks.
- New AWS resources. No new role, no new bucket, no new distribution, and no new IAM statement. FR-006 records that the statements HeadObject needs are already present.
- A custom domain, an ACM certificate, and Route 53.
- Checks that deploy or probe the SmartWealthAI repository, or health-stream-xai.
- The Now page and its automation. Those are reserved as specs 003 and 004.
- Applying Terraform from GitHub Actions.
- Long-lived AWS keys.

## Assumptions

- The weekly minute is Monday 09:00 UTC (`0 9 * * 1`). GitHub schedules are UTC. The day is a default so the cron is testable. It does not change the credential question.
- Page sources are single Markdown files under `content/`, which is this site's layout. Hugo writes pretty URLs, so the object key ends in `index.html`. `uglyURLs` is unset.
- `SITE_URL`, `BUCKET_NAME`, `DISTRIBUTION_ID`, and `AWS_ROLE_ARN` are the GitHub Environment variables spec 002 already required. This feature reads them. It does not create them and it does not commit their values.
- The comment is posted with the job's `GITHUB_TOKEN`. Finding the pull request from the commit SHA uses the commits API, which `pull-requests: write` is allowed to call.
- A squash merge's commit on the branch is the SHA `GITHUB_SHA` sees, and GitHub associates that SHA with the pull request. That is the association this repository uses.
- Europe/Madrid on 22 and 23 October 2026 is CEST (UTC+2). Daylight-saving time in Spain ends on 25 October 2026. The 08:45 check is 06:45 UTC.
- Option A is the recommendation. It is not a decision. Jorge's answer in `/speckit-clarify` is the decision. He creates the secret. That creation is `needs-human`.
- ADR 001 records the same decision with status Proposed. It does not add a requirement beyond this spec.
