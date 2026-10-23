# Feature Specification: Automated Post-deploy Verification

**Feature Branch**: `005-deploy-verification`

**Created**: 2026-10-23

Status: Approved by Jorge — PR #36

**Input**: User description: "After each deploy to staging and production, verify the published artifacts and the public URL in GitHub Actions with the existing OIDC deploy role, comment the result on the merged pull request, and read branch protection for develop and main on a weekly schedule. Do not add long-lived AWS keys. Do not change branch protection."

Numbers 003 and 004 are reserved for the Now page and its automation. They are not in this repository yet. This feature is 005.

## Clarifications

### Session 2026-10-23

- Q: Which credential reads branch protection? → A: Option A, a fine-grained PAT with Administration: Read-only on JLaborda/web-portfolio only, stored as repo secret `BRANCH_PROTECTION_READ_TOKEN` (already created by Jorge on 2026-10-23; expiry handled by the weekly check failing visibly).

## Context

Jorge (Product Owner) verifies every deploy by hand. The deploy workflow assumes an OIDC role, syncs the site, and creates a CloudFront invalidation. Nothing in that run checks the objects or the public URL. The agents that open pull requests have no AWS credentials, and constitution III forbids long-lived AWS keys, so they cannot run `aws s3api head-object` themselves.

On 2026-10-23, `GET /repos/JLaborda/web-portfolio/branches/develop/protection` with the credential available to repository automation returned HTTP 403 and the message `Resource not accessible by integration`. `GITHUB_TOKEN` cannot read branch protection. The four required status checks and `enforce_admins` are visible only to a credential GitHub treats as an administrator. The weekly job uses the repository secret named in the Clarifications session.

The product owner listed manual S3 HeadObject checks on 22 October 2026 at 10:49, 13:24, and 16:54, and on 23 October 2026 at 08:45. This repository confirms two of those moments in `specs/002-aws-deployment/converge.md`. At 13:24 Europe/Madrid on 22 October, Jorge read branch protection on `develop` and on `main`. At 08:45 Europe/Madrid on 23 October, his local HeadObject for the removed T018 key returned `404 Not Found`. Pull request #33 merged at 2026-10-22T15:05:19Z. That 08:45 check is 15 hours 40 minutes later. The product owner described the wait as about 15.5 hours. The goal of this feature is to remove those manual checks from the normal deploy path.

The S3 permission is already on the deploy role. The gap is that no job assumes the role to run the check, and that no allowed credential reads branch protection on a schedule.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A deploy checks itself (Priority: P1)

Jorge merges a pull request. Staging or production publishes that commit. The same Actions run checks the objects that the commit should have published, checks a removed page is gone, and checks the public URL. He does not open a terminal to run HeadObject.

**Why this priority**: The manual object check is what held pull request #33 open for about 15.5 hours after the deploy. Without this check in the run, the other stories still leave Jorge as the verifier.

**Independent Test**: Merge a content change to `develop`. The deploy run fails if `index.html` is missing, if a page the push edited is missing, if a page the push deleted is still present or returns 403, or if the public URL checks do not match the environment. The same checks apply when `develop` is merged to `main` and the push is a merge commit. The run passes when every check matches. Jorge runs no AWS command.

**Acceptance Scenarios**:

1. **Given** a commit that edits a published page and is merged to `develop`, **When** the staging deploy run finishes, **Then** the run has checked `index.html` and that page's object, the public home page returned 200, HTTP redirected to HTTPS with 301, and the staging response included `x-robots-tag: noindex`.
2. **Given** a commit that deletes a published page, **When** that environment's deploy run finishes, **Then** HeadObject for the removed object reported `404 Not Found`, and a `403` failed the run.
3. **Given** a release merge of `develop` into `main`, including pages changed in earlier commits of that range, **When** the production deploy run finishes, **Then** the same object and URL checks run against production for every page in that before/after range, and the production response has no `x-robots-tag` header.
4. **Given** any mismatch, **When** the verification job finishes, **Then** the Actions run is failed.

---

### User Story 2 - The merged pull request shows the result (Priority: P2)

The pull request whose merge triggered the deploy receives a comment. Jorge can read the result next to the change. The comment does not contain an account id, a bucket name, a distribution id, or an email address.

**Why this priority**: A green run that only exists in the Actions log is easy to miss. The comment is the record on the change that was deployed.

**Independent Test**: After a merge deploy, the pull request has a comment with the run URL, the environment, the commit SHA, and one line per check with the expected value and the actual value. A search of that comment finds none of the four forbidden values. A commit SHA or a run id that happens to contain twelve digits does not fail the run.

**Acceptance Scenarios**:

1. **Given** a successful staging deploy of a merged pull request, **When** the verification job completes, **Then** that pull request has a comment with the run URL, `staging`, the full commit SHA, and each check's expected and actual values.
2. **Given** a failed check, **When** the job completes, **Then** the comment is still posted and the run is failed.
3. **Given** the comment and the job summary, **When** a reviewer searches them, **Then** neither text contains the account id, the bucket name, or the distribution id for that environment.

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
- A release to `main` is a merge commit. `git diff-tree` without a range prints nothing for that commit. The changed pages are the diff from `github.event.before` to `github.sha`. Release `2292272cdb129fa1eb50c493e6e0751528734f0b` is the example: the range lists `content/about.md`, and `git diff-tree --no-commit-id --name-status -r` of that commit prints nothing.
- `content/posts/welcome.md` is a draft (`draft: true`). Editing or deleting that file does not add `posts/welcome/index.html` to either set. Feature 001 requires that object to stay unpublished. That file is in the release `2292272cdb` range and stays out of both sets.
- A commit that changes a published page into a draft expects the old object to be absent. The new draft is not expected to be present.
- A changed page whose front matter opens with `+++`, or whose front matter contains a `url:` key, fails the job. The job names the path and does not invent an object key. This site does not use those forms.
- A removed object that returns `403` fails the job. `s3:ListBucket` is what makes a missing key return `404 Not Found` instead of `403`. The T018 cycle in spec 002 is the example: key `posts/spec-002-remove/index.html` returned `404 Not Found`.
- HeadObject exit 254 is not, by itself, a pass. The stderr must contain `(404)` and `Not Found`. Exit 0 on an absent key is a failure.
- The deploy job's failure skips verification (`needs: deploy`, with no `if: always()`). The run is already failed. Verification does not comment on a commit that was not published.
- The commits API returns no pull request for the deployed SHA. The job still writes the summary, then exits 1. It does not comment on a different pull request.
- A re-run posts a second comment. It does not edit or delete the first comment.
- `SITE_URL`, `BUCKET_NAME`, `DISTRIBUTION_ID`, or `AWS_ROLE_ARN` is empty. The job prints `::error::<name> is empty` and exits 1. It does not print the value.
- The comment or the summary contains the account id, the bucket name, or the distribution id. The job exits 1. A commit SHA or a run id that contains twelve digits does not, by itself, fail the job.
- `BRANCH_PROTECTION_READ_TOKEN` is empty, rejected, or expired. The job writes the HTTP status in the summary and exits 1. It does not fall back to `GITHUB_TOKEN`. That failure is the visible signal that the token needs a replacement.
- The weekly job is not a required status check. Putting it on the required list would change branch protection, which this feature does not do.
- If branch protection is later replaced by rulesets, `GET /repos/JLaborda/web-portfolio/branches/{branch}/protection` returns 404. The job records 404 and fails. It does not treat 404 as success. Restoring the classic protection endpoint is a separate change.
- Verification does not run on `pull_request`. A pull request does not deploy. The comment appears after the merge deploy.
- Spec 002 FR-022 is merged. Its `deploy.yml` change, including the invalidation wait, is still in progress. The `verify` job is not added in a pull request that merges before that wait is in the deploy job. Until the wait exists, a job that ran at the end of today's deploy would start when `create-invalidation` returns, which is before the invalidation finishes.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `.github/workflows/deploy.yml` gains a job named `verify`. It runs on the existing `push` to `develop` and `main`. The workflow gains no `pull_request` trigger and no top-level `permissions` key. The job `deploy` keeps exactly `id-token: write` and `contents: read`. The job `verify` sets `needs: deploy` and does not set `if: always()`. Its `environment` is the same expression the deploy job already uses: `${{ github.ref_name == 'main' && 'production' || 'staging' }}`. It assumes `vars.AWS_ROLE_ARN` with `aws-actions/configure-aws-credentials` at commit `e1253824e5c10ff9df46874f81ed3ec929e19cfd`, region `eu-west-1`, audience `sts.amazonaws.com`. That is the existing OIDC deploy role for the GitHub Environment. The job does not assume `web-portfolio-plan`. The workflow does not contain `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, or `terraform apply`. Checkout in `verify` uses `actions/checkout` at `3d3c42e5aac5ba805825da76410c181273ba90b1` with `fetch-depth: 2`. Any failed check fails the job, and therefore the run. **Acceptance**: the FR-001 block in Verification exits 0.

- **FR-002**: The job `verify` checks a set of S3 object keys with `aws s3api head-object`. The bucket is `BUCKET_NAME` from the GitHub Environment. The bucket name is not written to the summary or the comment. The present set always contains `index.html`. Other keys come from the push range, not from the last commit alone. The job fetches `github.event.before` with `git fetch --no-tags origin "$BEFORE"` and runs `git diff --name-status -M "$BEFORE" "$GITHUB_SHA"`. `BEFORE` is `${{ github.event.before }}`. If that value is `0000000000000000000000000000000000000000`, the job exits 1. For a squash push to `develop`, the range is that one commit. For a release merge of `develop` into `main`, `github.event.before` is the first parent of the merge commit, and the diff lists every file the merge brings onto `main`, including files changed in earlier commits. The job does not use `git diff-tree --no-commit-id --name-status -r HEAD`. That command prints nothing for merge commit `2292272cdb129fa1eb50c493e6e0751528734f0b`, while `git diff --name-status -M 2292272cdb129fa1eb50c493e6e0751528734f0b^1 2292272cdb129fa1eb50c493e6e0751528734f0b` lists `content/about.md`. A path is a page source when it matches `content/` and ends in `.md`. Front matter is the text between the opening line `---` and the next line that is exactly `---`. A line `draft: true` (optional quotes, no extra words) marks a draft. A line `slug: <value>` sets the last URL segment. The object key is derived as follows. `content/<dir>/_index.md` and `content/<dir>/index.md` use `<dir>/index.html` (`content/_index.md` uses `index.html`). Any other file uses `<dir>/<slug-or-filename>/index.html`, with `slug` winning over the filename when it is set. Status `A` or `M` on a non-draft expects the key present (HeadObject exit 0). Status `D` on a non-draft parent blob expects the key absent. Status `M` whose new blob is a draft and whose parent blob was not a draft expects the key absent. A draft that was never published is in neither set. A rename (`-M`) expects the old key absent when the old blob was published and the new key present when the new blob is published. A changed page whose first line is `+++`, or whose front matter contains a `url:` key, makes the job exit 1. The job names that path and does not assign it a key. Absent means HeadObject's stderr contains `(404)` and `Not Found`, and does not contain `(403)`. Exit 0 on an absent key fails the job. The T018 key `posts/spec-002-remove/index.html` is the absent-mode example. When the diff has no published page, the present set is exactly `index.html` and the summary says that no page source changed. **Acceptance**: the FR-002 block in Verification exits 0, including the release-merge commands and the oracle rows.

- **FR-003**: The same job checks the public URL with curl. `SITE_URL` has no trailing slash, as spec 002 requires. `curl -sS -o /dev/null -w '%{http_code}' "${SITE_URL}/"` equals `200`. `curl -sI -o /dev/null -w '%{http_code}' "http://${SITE_URL#https://}/"` equals `301` (no `-L`, so the first status is the redirect). On `staging`, `curl -fsSI "${SITE_URL}/"` has a header line matching `^x-robots-tag: noindex` (comparison is case-insensitive). On `production`, that response has no header line matching `^x-robots-tag:`. Any other environment name fails the job. **Acceptance**: the FR-003 block in Verification exits 0.

- **FR-004**: The job writes every check to the job summary and posts the same rows as a comment on the pull request whose merge triggered the deploy. The pull request list is `GET /repos/JLaborda/web-portfolio/commits/${GITHUB_SHA}/pulls`. The job comments on each returned number. An empty list fails the job after the summary is written. The comment and the summary include the run URL (`${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}`), the environment name (`staging` or `production`), the full commit SHA, and each check with its expected value and its actual value. They do not include the account id, the bucket name, or the distribution id. The guard reads the account id with `aws sts get-caller-identity --query Account --output text`. The bucket name is the existing `BUCKET_NAME` variable. The distribution id is the existing `DISTRIBUTION_ID` variable. Before any later command can print them, the job masks each value with `::add-mask::`. The guard then rejects the comment file and the summary file when either file contains that account id, that bucket name, or that distribution id as an exact string (`grep -F`). The `::error::` lines do not interpolate those three values. The guard does not use a twelve-digit pattern. A SHA or a run id that contains twelve digits is allowed. An `@` address and an `arn:aws` string still fail the guard. The comment step uses `GH_TOKEN` from `github.token`. The job's permissions are exactly `id-token: write`, `contents: read`, and `pull-requests: write`. The deploy job does not gain `pull-requests`. A failed check still posts the comment, then the job exits 1, unless the guard itself failed, in which case the job exits 1 without posting the text that contains a forbidden value. A failed comment API call exits 1 as well. **Acceptance**: the FR-004 block in Verification exits 0. The fixture in that block passes a body that contains a SHA and a twelve-digit run id, and it fails a body that contains the bucket value, the account id, or the distribution id.

- **FR-005**: A workflow `.github/workflows/branch-protection.yml` has one job named `branch-protection`. It runs on `schedule` with cron `0 9 * * 1` (Monday 09:00 UTC) and on `workflow_dispatch`. It has no `pull_request` trigger and no `push` trigger. It reads protection for `develop` and for `main` with `GET /repos/JLaborda/web-portfolio/branches/{branch}/protection`. For each branch the sorted `required_status_checks.contexts` equal `gitleaks`, `hugo`, `lychee`, and `terraform`, and `.enforce_admins.enabled` is true. The job writes both results to the job summary, then exits 1 if either branch mismatched or if the HTTP status was not 200. A 401, a 403, and a 404 are failed checks, not skips. The summary includes that HTTP status. The workflow file does not contain an HTTP method that writes protection (`PUT`, `PATCH`, `DELETE`, or `POST` against the protection URL). This job is not added to the required status checks. The credential is the repository secret `BRANCH_PROTECTION_READ_TOKEN` from the Clarifications session: a fine-grained personal access token with Administration: Read-only on JLaborda/web-portfolio only. Jorge created that secret on 2026-10-23. The job's `GITHUB_TOKEN` permissions are `contents: read` only. An empty secret prints `::error::BRANCH_PROTECTION_READ_TOKEN is unset` and exits 1. The workflow does not reference `github.token` or `secrets.GITHUB_TOKEN`. A GitHub App with Administration read was considered and is rejected. An expired or revoked token makes the weekly run fail, which is the signal to replace the secret. **Acceptance**: the FR-005 blocks in Verification exit 0.

- **FR-006**: Inspected on `develop` at `fe5f5329065e2fbfdb248f542bf6cc5ac2a1258f`. `HeadObject` is authorized by `s3:GetObject` on the object. A missing key returns `404 Not Found` when the caller also has `s3:ListBucket` on the bucket, and `403 Forbidden` when the caller does not. Both deploy roles already have both actions, scoped to that environment's bucket, with no wildcard action and no wildcard resource. In `infra/shared/iam.tf`, `aws_iam_role_policy.staging_deploy` (policy name `web-portfolio-staging-deploy`) has statement `ListStagingBucket` allowing `s3:ListBucket` on `arn:aws:s3:::${local.staging_bucket}`, and statement `WriteStagingObjects` allowing `s3:DeleteObject`, `s3:GetObject`, and `s3:PutObject` on `arn:aws:s3:::${local.staging_bucket}/*`. `aws_iam_role_policy.production_deploy` (policy name `web-portfolio-production-deploy`) has the same shape for `local.production_bucket` (`ListProductionBucket`, `WriteProductionObjects`). `local.staging_bucket` is `web-portfolio-staging-${local.account_id}` and `local.production_bucket` is `web-portfolio-production-${local.account_id}`. The account id is not written in this spec. In `infra/site/cdn.tf`, `aws_iam_role_policy.invalidate` (policy name `cloudfront-create-invalidation`) allows only `cloudfront:CreateInvalidation` on that stack's distribution ARN. It allows no S3 action. `infra/site/bucket.tf` allows `s3:GetObject` to `cloudfront.amazonaws.com` only, under the distribution source ARN. The T018 object was SSE-S3 (`AES256`), and the site bucket declares no KMS key, so HeadObject does not need `kms:Decrypt`. This feature adds no IAM action, no policy, and no rename. The implementation pull request does not change `infra/`. `terraform plan` is not an acceptance check for this feature, because there is no Terraform diff to show. Spec 002 FR-022 adds `cloudfront:GetInvalidation` on that same invalidate policy. That addition belongs to FR-022's implementation, which is in progress, and it is not an S3 gap. **Acceptance**: the FR-006 block in Verification exits 0. A diff under `infra/` fails it.

- **FR-007**: Spec 002 FR-022 is a merged requirement (pull request #35, merge `46aab5286a384493bc8271c735a4700dc772c301`). It requires branch-scoped concurrency `group: deploy-${{ github.ref }}` with `cancel-in-progress: false`, and it requires `aws cloudfront wait invalidation-completed` before `site_url` is written or printed. The `deploy.yml` edit that implements that wait is in progress. This pull request does not edit `deploy.yml`. The job `verify` uses `needs: deploy`, so once that wait is in the deploy job, verification starts only after the wait exits 0. The Web Developer does not open this feature's implementation pull request until that `deploy.yml` change is on `develop`. **Acceptance**: the FR-007 block in Verification exits 0 on this spec pull request. On the implementation pull request, `needs: deploy` is present and the wait command from FR-022 appears in the deploy job above `site_url`.

- **FR-008**: This feature does not automate a merge Jorge makes. The workflows do not contain `gh pr merge`. It does not change branch protection. It does not add an AWS resource, an IAM action, a custom domain, an ACM certificate, or a Route 53 record. It does not probe the SmartWealthAI repository and it does not probe health-stream-xai. A page of this site whose source is `content/projects/smartwealthai.md` remains an ordinary page of this site when that file changes, and FR-002 applies to it. The weekly workflow is not added to the required contexts `hugo`, `lychee`, `gitleaks`, and `terraform`. **Acceptance**: the FR-008 block in Verification exits 0.

### Key Entities

- **Verification report**: The environment name, the commit SHA, the run URL, and one row per check (name, expected, actual). Stored as the job summary and as the pull request comment.
- **Expected object**: An S3 key in the present set or the absent set, derived from the push range's page sources, plus `index.html` always present.
- **Branch-protection snapshot**: For `develop` and for `main`, the sorted required contexts and whether `enforce_admins` is enabled. Read-only.
- **Deploy role**: The existing role `web-portfolio-staging-deploy` or `web-portfolio-production-deploy`, assumed through the GitHub Environment. Not a new role.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: After a deploy to staging, and after a deploy to production, that deploy's own run records a pass or a fail for the live home page and for every expected artifact in the push range. A mismatch fails the run. Jorge does not run a separate object check for that deploy.
- **SC-002**: When a published page is removed, the same run records that the object is missing. A forbidden response fails the run. The removed page's text is not treated as a successful fetch.
- **SC-003**: The pull request that was merged shows the run link, the environment, the commit, and each check's expected and actual values. A reviewer can confirm that the note has no account identifier, storage-bucket name, or distribution identifier. A twelve-digit run id in the link does not, by itself, make the note fail.
- **SC-004**: A weekly run, and a run started by hand, records whether both protected branches still require the four existing gates and still apply them to administrators. Drift fails the run. An expired read token fails the run. The run does not change the protection settings.
- **SC-005**: A reviewer can run every command in Verification and compare it to the expected result named there.

## Verification

Commands marked "now" run on this spec pull request, from the repository root, on a clone that contains `2292272cdb129fa1eb50c493e6e0751528734f0b`. Commands marked "implementation" run on the implementation pull request, after the FR-022 `deploy.yml` change is on `develop`. `yq` in those commands is mikefarah yq 4.54.1, the pin `.github/workflows/deploy.yml` already installs. `ACCOUNT` is never printed.

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

- **FR-002** (now): release merge `2292272cdb129fa1eb50c493e6e0751528734f0b` has two parents. The empty `diff-tree` and the first-parent diff are the acceptance of the range.

  ```bash
  test -z "$(git diff-tree --no-commit-id --name-status -r 2292272cdb129fa1eb50c493e6e0751528734f0b)"
  git diff --name-status -M 2292272cdb129fa1eb50c493e6e0751528734f0b^1 2292272cdb129fa1eb50c493e6e0751528734f0b | grep -F 'content/about.md'
  git diff --name-status -M 2292272cdb129fa1eb50c493e6e0751528734f0b^1 2292272cdb129fa1eb50c493e6e0751528734f0b | grep -F 'content/posts/welcome.md'
  ```

  Expected: `diff-tree` prints nothing, so `test -z` exits 0. Both `grep -F` commands exit 0. `content/about.md` is added in that range and its key is `about/index.html` (present). `content/posts/welcome.md` is in the same range and is a draft, so it adds no key.

  **FR-002** (implementation): the job contains the range command and the head-object command, and it does not contain the empty merge form of `diff-tree`.

  ```bash
  grep -F 'github.event.before' .github/workflows/deploy.yml
  grep -F 'git fetch --no-tags origin' .github/workflows/deploy.yml
  grep -F 'git diff --name-status -M' .github/workflows/deploy.yml
  if grep -F 'git diff-tree --no-commit-id --name-status -r HEAD' .github/workflows/deploy.yml; then exit 1; fi
  grep -F 'aws s3api head-object' .github/workflows/deploy.yml
  grep -F '(404)' .github/workflows/deploy.yml
  grep -F 'Not Found' .github/workflows/deploy.yml
  grep -F '(403)' .github/workflows/deploy.yml
  grep -F 'url:' .github/workflows/deploy.yml
  ```

  Expected: each required `grep -F` exits 0. The `diff-tree` guard prints nothing. Present rows fail the run when HeadObject exits non-zero. The absent row passes only when stderr contains `(404)` and `Not Found` and does not contain `(403)`. The welcome row adds no key. A changed file that opens with `+++` or has a `url:` front-matter key fails the job.

  | Path | Status | Parent draft | New draft | Key | Set |
  | --- | --- | --- | --- | --- | --- |
  | `content/about.md` | M | no | no | `about/index.html` | present |
  | `content/posts/_index.md` | M | no | no | `posts/index.html` | present |
  | `content/projects/smartwealthai.md` | A | — | no | `projects/smartwealthai/index.html` | present |
  | `content/posts/welcome.md` | M | yes | yes | — | neither |
  | `content/posts/spec-002-remove.md` | D | no | — | `posts/spec-002-remove/index.html` | absent |
  | `content/now.md` | M | no | yes | `now/index.html` | absent |
  | `content/about.md` in `2292272cdb^1..2292272cdb` | A | — | no | `about/index.html` | present |
  | `content/posts/welcome.md` in that same range | A | — | yes | — | neither |

- **FR-003** (implementation):

  ```bash
  grep -F 'curl -sS -o /dev/null -w' .github/workflows/deploy.yml
  grep -F 'curl -sI -o /dev/null -w' .github/workflows/deploy.yml
  grep -F 'x-robots-tag: noindex' .github/workflows/deploy.yml
  grep -F 'x-robots-tag:' .github/workflows/deploy.yml
  ```

  Expected: each `grep -F` exits 0. Against a live deploy, the home page status is `200`, the HTTP status without `-L` is `301`, staging has the noindex header, and production has no `x-robots-tag` header. The live curl is the one in FR-003. It uses `SITE_URL` from the environment and does not hard-code a hostname.

- **FR-004** (now): the guard compares exact strings. Stand-in values stand for the account id, the bucket name, and the distribution id. A twelve-digit run id and a SHA that contains twelve digits are allowed. The same function is what the implementation runs after masking the real values.

  ```bash
  python3 - <<'PY'
  import sys
  account = "111122223333"  # FIXTURE-STAND-IN
  bucket = "web-portfolio-staging-EXAMPLE"
  dist = "E123EXAMPLE"
  allowed = "\n".join([
      "https://github.com/JLaborda/web-portfolio/actions/runs/123456789012",  # FIXTURE-STAND-IN
      "sha 012345678901abcdef012345678901abcdef01234567",
      "staging",
      "index.html expected exists actual exists",
  ])

  def guard(text):
      for label, value in (("account", account), ("bucket", bucket), ("distribution", dist)):
          if value in text:
              return label
      return None

  if guard(allowed) is not None:
      sys.exit("allowed body was rejected")
  if guard(allowed + "\n" + bucket) != "bucket":
      sys.exit("bucket value was accepted")
  if guard(allowed + "\n" + account) != "account":
      sys.exit("account id was accepted")
  if guard(allowed + "\n" + dist) != "distribution":
      sys.exit("distribution id was accepted")
  print("guard-ok")
  PY
  ```

  Expected: the script prints `guard-ok` and exits 0. The allowed body contains the fixture's twelve-digit run id and a SHA that contains twelve consecutive digits. The guard rejects only the exact stand-in values.

  **FR-004** (implementation):

  ```bash
  yq -e '.jobs.verify.permissions == {"contents": "read", "id-token": "write", "pull-requests": "write"}' .github/workflows/deploy.yml
  if yq -e '.jobs.deploy.permissions | has("pull-requests")' .github/workflows/deploy.yml >/dev/null; then exit 1; fi
  grep -F 'commits/${GITHUB_SHA}/pulls' .github/workflows/deploy.yml
  grep -F 'actions/runs/${GITHUB_RUN_ID}' .github/workflows/deploy.yml
  grep -F 'aws sts get-caller-identity --query Account --output text' .github/workflows/deploy.yml
  grep -F '::add-mask::' .github/workflows/deploy.yml
  grep -F 'grep -F' .github/workflows/deploy.yml
  if grep -F '[0-9]{12}' .github/workflows/deploy.yml; then exit 1; fi
  if grep -E 'web-portfolio-(staging|production)-[0-9]+' .github/workflows/deploy.yml; then exit 1; fi
  ```

  Expected: `yq` prints `true` and exits 0. The `pull-requests` guard does not take the `exit 1` branch. The identity, mask, and exact-match greps exit 0. The twelve-digit pattern is absent from the workflow, so that guard prints nothing. The workflow does not contain a literal bucket name. A reviewer runs the now fixture against the workflow's guard with the real masked values and expects the same pass and fail results. The `::error::` text does not include those values.

- **FR-005** (now): the workflow file is not part of this spec pull request. The credential decision is the Clarifications entry. The marker is gone.

  ```bash
  test ! -e .github/workflows/branch-protection.yml
  grep -F '0 9 * * 1' specs/005-deploy-verification/spec.md
  grep -F 'BRANCH_PROTECTION_READ_TOKEN' specs/005-deploy-verification/spec.md
  grep -F 'Administration: Read-only on JLaborda/web-portfolio only' specs/005-deploy-verification/spec.md
  grep -F '### Session 2026-10-23' specs/005-deploy-verification/spec.md
  python3 - <<'PY'
  import pathlib, sys
  text = pathlib.Path("specs/005-deploy-verification/spec.md").read_text()
  header = text.split("## Verification", 1)[0]
  if "Status: Approved by Jorge — PR #36" not in header:
      sys.exit("status line missing from the header")
  if "Status: Draft" in header:
      sys.exit("draft status remains")
  marker = "[" + "NEEDS CLARIFICATION:"
  if marker in text:
      sys.exit("clarification marker remains")
  print("status-ok")
  PY
  ```

  Expected: the workflow file is absent. Each `grep -F` exits 0. The script prints `status-ok` and exits 0. The header has one status line, `Status: Approved by Jorge — PR #36`, and no draft status. The clarification marker is not in the file.

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
  grep -F 'secrets.BRANCH_PROTECTION_READ_TOKEN' .github/workflows/branch-protection.yml
  grep -F 'BRANCH_PROTECTION_READ_TOKEN is unset' .github/workflows/branch-protection.yml
  if grep -E 'github\.token|secrets\.GITHUB_TOKEN' .github/workflows/branch-protection.yml; then exit 1; fi
  if grep -E -- '-X PUT|-X POST|-X PATCH|-X DELETE|method: PUT|method: POST|method: PATCH|method: DELETE|--method PUT|--method POST|--method PATCH|--method DELETE' .github/workflows/branch-protection.yml; then exit 1; fi
  ```

  Expected: the file exists. Each `yq -e` prints `true` and exits 0. The trigger guard, the token guard, and the write-method guard do not take the `exit 1` branch. Each context grep exits 0. The workflow file does not contain the token value. A non-200 response, including 404 when the classic protection endpoint is gone, fails the job after the summary records the status.

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

  Expected: the diff guard exits 0. The script prints `iam-ok` and exits 0. ListBucket is on the bucket ARN. GetObject is on the object ARN. The invalidate policy on this branch grants no S3 action and is still named `cloudfront-create-invalidation`. FR-022's later `cloudfront:GetInvalidation` addition is not part of this diff.

- **FR-007** (now):

  ```bash
  if git diff --name-only origin/develop...HEAD -- .github/workflows/deploy.yml | grep -q .; then exit 1; fi
  python3 - <<'PY'
  import pathlib, sys
  text = pathlib.Path("specs/005-deploy-verification/spec.md").read_text()
  body = text.split("## Verification", 1)[0]
  if "open pull request #35" in body or "depends on open" in body:
      sys.exit("stale open-PR dependency wording")
  for needle in (
      "46aab5286a384493bc8271c735a4700dc772c301",
      "aws cloudfront wait invalidation-completed",
      "needs: deploy",
      "FR-022",
  ):
      if text.count(needle) < 2:
          sys.exit("missing from the requirement text: %s" % needle)
  print("dependency-ok")
  PY
  ```

  Expected: `deploy.yml` is not in the diff. The script prints `dependency-ok` and exits 0. FR-022 is described as merged. The wait is still required before `verify` runs.

- **FR-008** (now): this pull request adds no workflow file.

  ```bash
  if git diff --name-only origin/develop...HEAD -- .github | grep -q .; then exit 1; fi
  if git diff --name-only origin/develop...HEAD -- docs | grep -q .; then exit 1; fi
  ```

  Expected: no path under `.github` or `docs` is in the diff, so both guards exit 0. The diff against `develop` is `specs/005-deploy-verification/spec.md` and `specs/005-deploy-verification/checklists/requirements.md`.

  **FR-008** (implementation):

  ```bash
  if grep -R -n 'gh pr merge' .github/workflows; then exit 1; fi
  ```

  Expected: the guard exits 0. A workflow that runs `gh pr merge` makes the guard exit 1. The branch-protection workflow still has no write method (FR-005).

- **Identifiers** (now): the patterns live in this script as escaped expressions, so the script source is not itself a literal account id, email, or hostname. The scan is this feature directory only.

  ```bash
  python3 - <<'PY'
  import pathlib, re, sys
  root = pathlib.Path("specs/005-deploy-verification")
  account = re.compile(r"(?<![0-9A-Fa-f])[0-9]{12}(?![0-9A-Fa-f])")
  email = re.compile(r"@[A-Za-z0-9.-]+\.[A-Za-z]{2,}")
  host = re.compile(r"cloudfront\.net")
  bad = []
  for path in root.rglob("*"):
      if not path.is_file():
          continue
      for i, line in enumerate(path.read_text().splitlines(), 1):
          if "FIXTURE-STAND-IN" in line:
              continue
          if account.search(line) or email.search(line) or host.search(line):
              bad.append("%s:%s" % (path, i))
  if bad:
      sys.exit("\n".join(bad))
  print("identifiers-ok")
  PY
  ```

  Expected: the script prints `identifiers-ok` and exits 0. Lines marked `FIXTURE-STAND-IN` are the FR-004 stand-in account id and the twelve-digit run id. Every other line is scanned. The spec names each bucket as a Terraform interpolation. It does not name a literal bucket, a distribution hostname, or an email address.


## Dependency

Spec 002 FR-022 is a merged requirement. Pull request #35 merged it as `46aab5286a384493bc8271c735a4700dc772c301`. FR-022 requires concurrency `group: deploy-${{ github.ref }}` with `cancel-in-progress: false`, and `aws cloudfront wait invalidation-completed` before `site_url` is written or printed. The `deploy.yml` change and the `cloudfront:GetInvalidation` addition are the implementation of FR-022. That implementation is in progress. This feature does not add `cloudfront:GetInvalidation` and does not edit `deploy.yml`.

The job `verify` uses `needs: deploy`. After the FR-022 implementation is on `develop`, the deploy job does not succeed until the invalidation wait exits 0, and `verify` starts only then. The Web Developer does not open this feature's implementation pull request before that `deploy.yml` change is on `develop`.

## Out of Scope

- Automating any merge Jorge does, including `gh pr merge` and auto-merge.
- Changing branch protection, including adding this feature's weekly job to the required status checks.
- New AWS resources. No new role, no new bucket, no new distribution, and no new IAM statement. FR-006 records that the statements HeadObject needs are already present.
- A custom domain, an ACM certificate, and Route 53.
- Checks that deploy or probe the SmartWealthAI repository, or health-stream-xai.
- The Now page and its automation. Those are reserved as specs 003 and 004.
- Applying Terraform from GitHub Actions.
- Long-lived AWS keys.
- A `url:` front-matter key and TOML front matter opened by `+++`. FR-002 fails the run when a changed page uses either form, and it does not invent a key.

## Assumptions

- The weekly minute is Monday 09:00 UTC (`0 9 * * 1`). GitHub schedules are UTC.
- Page sources are single Markdown files under `content/`, which is this site's layout. Hugo writes pretty URLs, so the object key ends in `index.html`. `uglyURLs` is unset. Front matter is YAML between `---` lines. This site does not set a `url` key and does not use TOML `+++` front matter.
- `SITE_URL`, `BUCKET_NAME`, `DISTRIBUTION_ID`, and `AWS_ROLE_ARN` are the GitHub Environment variables spec 002 already required. This feature reads them. It does not create them and it does not commit their values. The account id comes from `aws sts get-caller-identity` at run time and is masked.
- The comment is posted with the job's `GITHUB_TOKEN`. Finding the pull request from the commit SHA uses the commits API, which `pull-requests: write` is allowed to call.
- A squash merge's commit on `develop` is one commit, so `github.event.before` is that commit's parent. A release to `main` is a merge commit, so `github.event.before` is the first parent. GitHub associates `GITHUB_SHA` with the pull request that produced the push.
- Europe/Madrid on 22 and 23 October 2026 is CEST (UTC+2). Daylight-saving time in Spain ends on 25 October 2026. The 08:45 check is 06:45 UTC.
- A GitHub App with Administration read was the alternative credential and is rejected. The credential is the fine-grained PAT in the Clarifications session. Jorge created the repository secret on 2026-10-23. An expired token fails the weekly job.
