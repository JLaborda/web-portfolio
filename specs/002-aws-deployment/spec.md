# Feature Specification: AWS Deployment

**Feature Branch**: `002-aws-deployment`

**Created**: 2026-10-21

Status: Approved by Jorge — PR #23

Workflow: this feature will be the first run under the start/close approval rule (Jorge approves and merges the spec and the converge; Reviewer QA validates intermediate PRs, which merge automatically on QA approval). The rule takes effect only when constitution amendment v1.2.0 is merged; until then constitution v1.1.0 applies unchanged.

**Input**: User description: "Continuous deployment of the Hugo site to AWS. Staging on develop, production on main. Private S3 and CloudFront with Origin Access Control in eu-west-1. No custom domain. Terraform remote state. GitHub OIDC, no long-lived keys. Jorge bootstraps with SSO. Budget about 1 USD. Deploy syncs public/ and invalidates CloudFront."

## Clarifications

### Session 2026-10-21

- Q: Where is the site served, and is a custom domain part of this feature? → A: Each environment is served only on its CloudFront default hostname (`*.cloudfront.net`). A custom domain, an ACM certificate, and Route 53 are out of scope.
- Q: Which branch deploys which environment? → A: A push to `develop` deploys staging. A push to `main` deploys production. A pull request does not deploy.
- Q: Is staging authenticated, or only unlisted? → A: Unlisted and not authenticated. Staging publishes `robots.txt` with `Disallow: /` and sends the response header `X-Robots-Tag: noindex`. Production does neither.
- Q: Who applies infrastructure changes? → A: Jorge applies Terraform locally with his existing SSO session. GitHub Actions never runs `terraform apply`. Actions may run `terraform plan` with a read-only role. Apply credentials are not given to Actions, because those credentials could destroy a bucket or a distribution.
- Q: Where does the budget alert email live? → A: Outside git. Jorge passes it as `TF_VAR_budget_alert_email` or in an uncommitted tfvars file. The committed example value is `replace-me@example.com`.
- Q: Once `.github/workflows/terraform.yml` exists, which status checks must branch protection require on `develop` and `main`? → A: The job `terraform`, which runs `terraform fmt -check`, `validate`, `tflint`, and `plan`, together with feature 001's `hugo`, `lychee`, and `gitleaks`.
- Q: How does that required check report on a pull request that does not change `infra/**`? → A: The workflow runs on every pull request. A paths-filter step skips the Terraform steps and the job reports success when `infra/**` did not change. There is no workflow-level `paths:` filter.
- Q: In what order is the first pull request that adds `infra/` merged, so a red plan before bootstrap does not force a bypass? → A: A skipped plan is not a merge. The order is the later answer in this session.
- Q: When the plan-role ARN repository variable is not set, what does the `terraform` job do with plan? → A: An empty variable does not by itself skip plan. The condition is the later answer in this session.
- Q: Does the budget email fire when monthly spend reaches 1 USD, or only when spend is greater than 1 USD? → A: Only when actual spend is greater than 1 USD (`GREATER_THAN`).
- Q: Which command proves that tfvars files are ignored and that the example and the lock file are not? → A: `git check-ignore -q --no-index` on `x.tfvars` (ignored), `x.tfvars.example` (not ignored), and `.terraform.lock.hcl` (not ignored).
- Q: When may the `terraform` job skip plan with a notice? → A: Only when `git ls-tree -d` of the pull request base SHA for `infra` prints nothing and `AWS_PLAN_ROLE_ARN` is empty or whitespace. That is the first pull request that introduces `infra/`. The step prints `::notice::AWS_PLAN_ROLE_ARN is unset; terraform plan skipped until bootstrap` and exits 0. If the variable is non-empty, that same pull request runs plan.
- Q: What if `infra/` already exists on the base and `AWS_PLAN_ROLE_ARN` is empty? → A: The step prints `::error::AWS_PLAN_ROLE_ARN is unset and infra/ already exists on the base` and exits 1. Clearing the variable later fails the job. It does not skip plan.
- Q: In what order does Jorge merge the first pull request that adds `infra/`? → A: He runs Bootstrap from that head, sets `AWS_PLAN_ROLE_ARN`, re-runs `terraform`, and merges only when the latest run executed plan and is green. A skipped-plan run is not merged. There is no admin bypass.
- Q: Which command turns on the required status checks? → A: `gh api -X PUT repos/JLaborda/web-portfolio/branches/{develop,main}/protection` with contexts `gitleaks`, `hugo`, `lychee`, and `terraform`, `enforce_admins` true, and reviews and push restrictions null. Jorge runs it after the `terraform` job has reported, and before that first `infra/` pull request merges.
- Q: How does Verification prove that plan ran, without matching text the runner echoes from the script? → A: On the latest attempt, the log contains at least two Terraform summary lines, `No changes. Your infrastructure matches the configuration.` or `Plan: N to add,`. Those lines are not in the workflow file. One line is `infra/shared` and one is `infra/site`. `-no-color` and the ANSI strip are the later answers in this session.
- Q: How does Verification prove the skip notice and the error did not fire? → A: `gh api repos/JLaborda/web-portfolio/check-runs/$JOB_ID/annotations` has no message containing `terraform plan skipped` and no annotation whose level is `failure`. `$JOB_ID` is the `terraform` job of that attempt. `gh run view` is called with `--attempt` set to the run's latest attempt.
- Q: Which pull request does the first-infra merge order govern? → A: The pull request into `develop` whose base commit has no `infra/` tree. The later pull request into `main` is not a second bootstrap.
- Q: Can a direct push to `develop` or `main` deploy after protection is on? → A: No. `enforce_admins` is true, so the push is rejected even for Jorge. A deploy follows a merge. The protection read also checks `.enforce_admins.enabled` is true.
- Q: How does the plan summary stay matchable when Terraform 1.16.6 colors `Plan:` and `No changes.` even when stdout is not a terminal? → A: FR-017 runs `terraform plan -lock=false -input=false -no-color` in CI. FR-021 still strips ANSI before the grep with `sed -E 's/\x1b\[[0-9;]*m//g'`.
- Q: How does Verification stop the workflow file from containing the summary strings the log grep looks for? → A: FR-017 Verification exits 1 when `.github/workflows/terraform.yml` matches `No changes. Your infrastructure` or `Plan: N to add,`.
- Q: What if the plan prints only `Changes to Outputs:` and neither summary line? → A: Jorge re-applies Terraform locally from that head and re-runs the job. He does not bypass the check.
- Q: How does `terraform init` name the state bucket when the S3 backend block cannot use variables? → A: Partial backend configuration. The `backend "s3"` block in `infra/shared` and `infra/site` sets only `region = "eu-west-1"` and `use_lockfile = true`. It omits `bucket` and `key`. Every init that uses the backend passes `-backend-config="bucket=${STATE_BUCKET}"` and `-backend-config="key=..."`. `STATE_BUCKET` is `web-portfolio-tfstate-${ACCOUNT}`. The account id is never committed. In CI the account id is taken from the plan role ARN.
- Q: How does Verification check that the backend block omits `bucket` and `key` when site resources also use `bucket =`? → A: For `infra/shared` and for `infra/site`, Verification extracts the `backend "s3"` block from that header through its closing brace. The block contains `region = "eu-west-1"` and `use_lockfile = true`, and it contains no `bucket` argument and no `key` argument. A `bucket =` argument on an S3 resource is outside that block and does not fail the check.
- Q: How does the CI plan step name the state bucket on each backend init? → A: It sets `account` from `AWS_PLAN_ROLE_ARN` with `cut -d: -f5` and passes `-backend-config="bucket=web-portfolio-tfstate-${account}"` on each backend `terraform init`. That name is the same bucket as `STATE_BUCKET`.
- Q: Which pull requests does Jorge approve on this feature? → A: This feature will be the first run under the start/close approval rule. Jorge approves and merges the spec and the converge. Reviewer QA validates each intermediate pull request against the spec's verifiable acceptance criteria, and those pull requests merge automatically on QA approval. The rule takes effect only when constitution amendment v1.2.0 is merged. Until then constitution v1.1.0 applies unchanged.
- Q: Where is the deploy role's `cloudfront:CreateInvalidation` permission declared, given the distribution only exists after `infra/site` is applied? → A: `infra/site` declares one inline `aws_iam_role_policy` that grants `cloudfront:CreateInvalidation` only on that stack's own distribution ARN and attaches it to the deploy role looked up by name with `data "aws_iam_role"` `web-portfolio-${var.environment}-deploy`. No `terraform_remote_state`. The deploy roles, their trust policies, and their S3 permissions stay in `infra/shared`. Bootstrap order is unchanged.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Visitor opens the published site (Priority: P1)

A recruiter opens the portfolio over HTTPS. Staging and production are separate sites. Each site is the Hugo build of the commit that was pushed to its branch.

**Why this priority**: Without a reachable site, the portfolio feature has no public URL.

**Independent Test**: After Jorge has applied the infrastructure, a push to `develop` publishes staging and a push to `main` publishes production. `curl` against each CloudFront hostname returns the built home page over HTTPS.

**Acceptance Scenarios**:

1. **Given** a successful push to `develop`, **When** a visitor opens the staging URL, **Then** the home page is served over HTTPS from a `*.cloudfront.net` hostname and the page is the Hugo build of that commit.
2. **Given** a successful push to `main`, **When** a visitor opens the production URL, **Then** the same is true of the production hostname, and that hostname is not the staging hostname.
3. **Given** a pull request, **When** the pull request workflows finish, **Then** neither site is updated by that pull request.

---

### User Story 2 - Staging stays out of search indexes (Priority: P2)

Staging is a public URL that Jorge can share, and it is not a login wall. Crawlers are told not to index it. Production is indexable.

**Why this priority**: An unlisted staging site that sends no crawler directive will be indexed as if it were the portfolio.

**Independent Test**: Response headers and `robots.txt` differ between the two hostnames.

**Acceptance Scenarios**:

1. **Given** the staging site, **When** a client fetches `/robots.txt` and the home page headers, **Then** the file contains `Disallow: /` and the headers contain `X-Robots-Tag: noindex`.
2. **Given** the production site, **When** a client fetches the same two resources, **Then** the file does not contain `Disallow: /` and the headers do not contain `X-Robots-Tag`.
3. **Given** either site, **When** a visitor opens it, **Then** no login is required.

---

### User Story 3 - Jorge can see cost and deploy again safely (Priority: P3)

Jorge is emailed when actual AWS spend for the month is greater than 1 USD. The address is not stored in the repository. A later content push updates the site, including removing pages that were deleted in git, and prints the site URL in the Actions job.

**Why this priority**: The constitution caps this site at about 1 USD per month, and a deploy that only adds files would leave deleted pages online.

**Independent Test**: The budget API shows a 1 USD monthly budget with an email subscriber equal to Jorge's uncommitted value, and a content change followed by a push changes the live site.

**Acceptance Scenarios**:

1. **Given** the budget exists, **When** actual monthly spend is greater than 1 USD, **Then** AWS emails the address Jorge supplied, and that address is not in git.
2. **Given** a published page, **When** that page is removed from the Hugo build and the branch is pushed, **Then** the next deploy removes it from the bucket and the URL no longer returns the old page.
3. **Given** a deploy job, **When** it succeeds, **Then** the job output includes the site URL.

### Edge Cases

- A Hugo build that exits non-zero does not sync and does not invalidate. The previous live site stays as it was.
- After branch protection is on, a direct push to `develop` or `main` is rejected, including a push by Jorge, because `enforce_admins` is true. A deploy follows a merge onto that branch. Feature 001 requires `hugo`, `lychee`, and `gitleaks`. Once `.github/workflows/terraform.yml` is on `develop`, both branches also require the job `terraform`. This feature does not re-run the feature 001 jobs.
- `terraform plan` in Actions uses `-lock=false -no-color`. It does not write the S3 lock file. `-no-color` keeps the summary lines free of ANSI codes. A plan that races an apply Jorge is running locally can be stale; it still must not change infrastructure.
- A pull request that does not change `infra/**` still runs `.github/workflows/terraform.yml`. The paths-filter step skips the Terraform steps and the `terraform` job reports success. The workflow has no `paths:` filter, so the required check does not stay pending.
- The plan step prints `::notice::AWS_PLAN_ROLE_ARN is unset; terraform plan skipped until bootstrap` and exits 0 only when the base commit has no `infra/` tree and `AWS_PLAN_ROLE_ARN` is empty or whitespace. Fmt, validate, and tflint still gate that run. That green skip is not a merge. If the base commit already has an `infra/` tree and the variable is empty, the step prints `::error::AWS_PLAN_ROLE_ARN is unset and infra/ already exists on the base` and exits 1. A non-empty variable runs plan. A failing plan blocks the merge. Jorge does not bypass it.
- The CloudFront hostname does not exist until the first apply. The deploy job fails when `SITE_URL`, `BUCKET_NAME`, `DISTRIBUTION_ID`, or `AWS_ROLE_ARN` is empty.
- Pretty URLs such as `/about/` must resolve to the `index.html` object. The S3 REST origin does not add index documents by itself.
- HTTP requests are redirected to HTTPS. The bucket website endpoint is not used and is not public.
- This feature creates no ACM certificate. A later feature that adds a custom domain must request that certificate in `us-east-1`, as the constitution requires. This feature does not choose a DNS name.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Two environments exist, `staging` and `production`. A push to `develop` deploys staging. A push to `main` deploys production. No workflow in this feature deploys on `pull_request`. The deploy publishes the Hugo build of the commit that was pushed.
- **FR-002**: Each environment has its own S3 bucket in `eu-west-1` and its own CloudFront distribution. The bucket has Block Public Access enabled for all four settings (`BlockPublicAcls`, `IgnorePublicAcls`, `BlockPublicPolicy`, `RestrictPublicBuckets`), is not a website endpoint, and is readable by that distribution only, through Origin Access Control. The distribution uses price class `PriceClass_100`, default root object `index.html`, and viewer protocol policy `redirect-to-https`.
- **FR-003**: The public URL of each environment is the distribution's default hostname, matching `*.cloudfront.net`. This feature does not create a custom domain, an ACM certificate, or a Route 53 record.
- **FR-004**: A CloudFront Function on the viewer-request event rewrites directory URLs to Hugo's `index.html` objects. `/` serves `index.html`. A URI that ends in `/` appends `index.html`. A URI whose last segment contains no `.` appends `/index.html`. A URI whose last segment contains a `.` is unchanged. `/index.xml` and `/index.json` stay unchanged.
- **FR-005**: After the Hugo build, the staging deploy overwrites `public/robots.txt` with `User-agent: *` and `Disallow: /`. The production deploy overwrites it with `User-agent: *` and `Allow: /`. The staging distribution adds the response header `X-Robots-Tag: noindex`. The production distribution does not send `X-Robots-Tag`. Neither site requires authentication.
- **FR-006**: Infrastructure is Terraform. The Terraform version is exactly `1.16.6`. The AWS provider is exactly `6.69.1` (`hashicorp/aws`). `.terraform.lock.hcl` is committed. Remote state is an S3 bucket in `eu-west-1` with versioning, SSE-S3 (`AES256`), and Block Public Access. The backend sets `use_lockfile = true`. State keys are `shared/terraform.tfstate`, `staging/terraform.tfstate`, and `production/terraform.tfstate`. A staging apply does not read production state.
- **FR-007**: The state bucket name is `web-portfolio-tfstate-<account-id>`. The site bucket names are `web-portfolio-staging-<account-id>` and `web-portfolio-production-<account-id>`. `<account-id>` is the 12-digit account from `aws sts get-caller-identity`. Jorge creates the state bucket with the AWS CLI during bootstrap. Terraform does not create the bucket it stores state in.
- **FR-008**: Layout is `infra/shared` (OIDC provider, IAM roles, budget) and `infra/site` (bucket, Origin Access Control, distribution, function, the staging response-headers policy, and one inline `aws_iam_role_policy`). That inline policy is the single IAM object owned by `infra/site`. It grants `cloudfront:CreateInvalidation` only on that stack's own distribution ARN and attaches to the deploy role looked up by name with `data "aws_iam_role"` `web-portfolio-${var.environment}-deploy`. There is no `terraform_remote_state`. The deploy roles, their trust policies, and their S3 permissions stay in `infra/shared`. `infra/site` takes a variable `environment` whose only values are `staging` and `production`. Jorge applies `infra/site` twice, once per state key. Bootstrap order is unchanged.
- **FR-009**: Jorge applies Terraform. GitHub Actions does not run `terraform apply`. `.github/workflows/deploy.yml` and `.github/workflows/terraform.yml` do not contain the string `terraform apply`.
- **FR-010**: No IAM user is created. No long-lived access key is created or committed. Actions authenticates with GitHub's OIDC provider `https://token.actions.githubusercontent.com` and audience `sts.amazonaws.com`. On 2026-10-21, `GET /repos/JLaborda/web-portfolio/actions/oidc/customization/sub` reported `use_immutable_subject: true` and prefix `repo:JLaborda@15078416/web-portfolio@1427090788`. Trust policies use that prefix.
- **FR-011**: Three roles exist. `web-portfolio-plan` trusts only `sub` `repo:JLaborda@15078416/web-portfolio@1427090788:pull_request`. It can read the state objects and call the read APIs Terraform needs to plan this configuration. It can also call `iam:GetRole` and `iam:GetRolePolicy`, which plan needs for the `data "aws_iam_role"` and the inline policy. It still cannot `iam:PutRolePolicy`. It cannot `s3:PutObject`, `s3:DeleteObject`, `cloudfront:CreateInvalidation`, `cloudfront:UpdateDistribution`, `iam:CreateRole`, `iam:PutRolePolicy`, or `budgets:ModifyBudget`. `web-portfolio-staging-deploy` trusts `sub` `repo:JLaborda@15078416/web-portfolio@1427090788:environment:staging` and `ref` `refs/heads/develop`. `web-portfolio-production-deploy` trusts `sub` `repo:JLaborda@15078416/web-portfolio@1427090788:environment:production` and `ref` `refs/heads/main`. Each deploy role can `s3:ListBucket`, `s3:GetObject`, `s3:PutObject`, and `s3:DeleteObject` only on its own site bucket, and `cloudfront:CreateInvalidation` only on its own distribution. A deploy role cannot change IAM, budgets, the state bucket, or distribution configuration.
- **FR-012**: One AWS Budget named `web-portfolio-monthly` has limit amount `1`, unit `USD`, and time unit `MONTHLY`. One notification has type `ACTUAL`, comparison `GREATER_THAN`, threshold `100`, and threshold type `PERCENTAGE`. The subscriber is an email address equal to `TF_VAR_budget_alert_email`. That value is not committed. `infra/shared/terraform.tfvars.example` sets `budget_alert_email` to `replace-me@example.com` and is the only committed assignment of that variable.
- **FR-013**: `.gitignore` ignores `.terraform/`, `*.tfstate`, `*.tfstate.*`, and `*.tfvars`, and does not ignore `*.tfvars.example` or `.terraform.lock.hcl`.
- **FR-014**: The deploy workflow is `.github/workflows/deploy.yml`. It runs on `push` to `develop` and `main` and has no `pull_request` trigger. The job `deploy` uses GitHub Environment `staging` for `develop` and `production` for `main`. Those environments have custom branch policies (`develop` only, and `main` only), `wait_timer` 0, and no required reviewers. The job assumes `vars.AWS_ROLE_ARN` through `aws-actions/configure-aws-credentials` at commit `e1253824e5c10ff9df46874f81ed3ec929e19cfd` (v6.3.0), in region `eu-west-1`. Checkout is `actions/checkout` at `3d3c42e5aac5ba805825da76410c181273ba90b1` with submodules recursive.
- **FR-015**: The deploy job installs Hugo extended from `hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz`, where `HUGO_VERSION` is the single existing workflow variable owned by feature 001. This feature does not add a second `HUGO_VERSION:` key. The build command is `hugo --gc --minify --panicOnWarning --baseURL "${SITE_URL}/"`. `SITE_URL` has no trailing slash. The job then writes `robots.txt` as FR-005 requires, syncs `public/` with `--delete`, sets cache headers as FR-016 requires, and runs `aws cloudfront create-invalidation --distribution-id "$DISTRIBUTION_ID" --paths "/*"`. The job output `site_url` is `SITE_URL`.
- **FR-016**: Cache-Control is `public, max-age=0, must-revalidate` for `*.html`, `*.xml`, `*.json`, and `robots.txt`. It is `public, max-age=31536000, immutable` when the object key matches `\.[0-9a-f]{8,}\.` and is not one of those four names. Every other object is `public, max-age=3600`. The first sync may set the one-hour default and is the only sync that passes `--delete`. Later copies overwrite Cache-Control for the short and long groups and do not pass `--delete`.
- **FR-017**: `.github/workflows/terraform.yml` runs on every `pull_request` whose base is `develop` or `main`. It has no `paths` filter. It has one job named `terraform`. That job checks out with `actions/checkout` at `3d3c42e5aac5ba805825da76410c181273ba90b1` and `fetch-depth: 0`. A step with id `paths` sets output `infra` to `true` when `git diff --name-only` between `github.event.pull_request.base.sha` and `github.event.pull_request.head.sha` lists a path under `infra/`, and to `false` otherwise. Every step that runs `terraform`, `tflint`, or assumes `web-portfolio-plan` uses `if: steps.paths.outputs.infra == 'true'` and has no `continue-on-error`. Those steps run `terraform fmt -check -recursive`, `terraform -chdir=infra/shared validate`, `terraform -chdir=infra/site validate`, and `tflint` `0.64.0` with the AWS ruleset `0.49.0` in `infra/shared` and in `infra/site`. Those commands use no AWS credentials. The plan step uses that same `if`. It reads repository variable `AWS_PLAN_ROLE_ARN` from `${{ vars.AWS_PLAN_ROLE_ARN }}` and removes whitespace. GitHub supplies an empty string when the variable does not exist. It runs `git ls-tree -d "${{ github.event.pull_request.base.sha }}" infra`. Empty output means the base commit has no `infra/` tree. The step skips `terraform plan`, prints `::notice::AWS_PLAN_ROLE_ARN is unset; terraform plan skipped until bootstrap`, and exits 0 only when that output is empty and the variable is empty. That is the first pull request that introduces `infra/`. If the variable is non-empty, the step assumes `web-portfolio-plan` in that same script and runs `terraform plan -lock=false -input=false -no-color` in `infra/shared` and in `infra/site`, including on that first pull request. Before each of those plans, that same script sets `account` from `AWS_PLAN_ROLE_ARN` with `cut -d: -f5` and passes `-backend-config="bucket=web-portfolio-tfstate-${account}"` on each backend `terraform init`. The workflow file does not contain `No changes. Your infrastructure` or `Plan: N to add,`. If the base commit has an `infra/` tree and the variable is empty, the step prints `::error::AWS_PLAN_ROLE_ARN is unset and infra/ already exists on the base` and exits 1. A non-zero plan exit also fails the job. When `infra` is `false`, the Terraform steps are skipped and the job conclusion is `success`. When the notice skip applies, fmt, validate, and tflint still gate the job, and the job is `success` only if those commands passed. The job does not apply. A green skip is not a merge. FR-021 is.
- **FR-018**: Feature 001's jobs `hugo`, `lychee`, and `gitleaks` stay required status checks. This feature does not redefine them. Once `.github/workflows/terraform.yml` is on `develop`, the job `terraform` is required as well, as FR-020 states. A deploy happens after a push to `develop` or `main`, which is how a merge that passed the required checks becomes the deployed commit.
- **FR-019**: Bootstrap is the manual procedure in the Bootstrap section. Jorge runs it from the head of the pull request into `develop` that first adds `infra/`, with his SSO session, before that pull request merges and before the first deploy. Its last step sets the repository variable `AWS_PLAN_ROLE_ARN`. He then re-runs the `terraform` job on that same head. The later pull request into `main` does not run Bootstrap again.
- **FR-020**: Once `.github/workflows/terraform.yml` is on `develop` and the job `terraform` has completed at least once, Jorge runs the `gh api -X PUT` command in Bootstrap on `develop` and on `main`. The required contexts are `gitleaks`, `hugo`, `lychee`, and `terraform`. `enforce_admins` is true, so an administrator cannot bypass those checks. `required_pull_request_reviews` and `restrictions` are null. `strict` is false. The first `infra/` pull request is not merged until this protection is in place and FR-021 is satisfied. A red `terraform` check blocks the merge.
- **FR-021**: The pull request into `develop` whose base commit has no `infra/` tree is merged only in this order. Jorge runs Bootstrap from that pull request's head. Bootstrap sets `AWS_PLAN_ROLE_ARN`. He re-runs the `terraform` job on that same head. He merges only when the latest attempt of that run has conclusion `success`, the log, after `sed -E 's/\x1b\[[0-9;]*m//g'` removes ANSI color codes, contains at least two Terraform summary lines (`No changes. Your infrastructure matches the configuration.` or `Plan: N to add,`), and the `terraform` job's annotations contain neither `terraform plan skipped` nor a failure. He does not merge a run that skipped plan. He does not use an admin bypass. A plan that prints only `Changes to Outputs:` and neither summary line does not pass. Jorge re-applies Terraform locally from that head and re-runs the job. He does not bypass the check. This order does not apply to the pull request into `main`.

### Key Entities

- **Environment**: `staging` or `production`. Owns one bucket, one distribution, one deploy role, and one GitHub Environment.
- **State bucket**: One bucket, three state keys, S3 lock files beside those keys.
- **Budget**: One account-level monthly budget. Not per environment.
- **Deploy variables**: Per GitHub Environment: `AWS_ROLE_ARN`, `SITE_URL`, `BUCKET_NAME`, `DISTRIBUTION_ID`. They are variables, not secrets. Jorge sets them after apply.
- **Plan variable**: Repository variable `AWS_PLAN_ROLE_ARN`. Not an environment variable and not a secret. Empty until bootstrap's last step. Empty skips plan only when the base commit has no `infra/` tree. Empty fails the job when that tree already exists. Non-empty runs plan.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A visitor can open the staging site and the production site over HTTPS within one minute of a successful deploy, and the two hostnames are different.
- **SC-002**: A page removed from the build is absent from that environment after the next successful deploy of its branch.
- **SC-003**: Staging asks crawlers not to index it. Production does not. Neither site asks the visitor to log in.
- **SC-004**: The monthly hosting budget is 1 USD. Jorge receives an email when actual spend is greater than that amount. The address is not in the repository.
- **SC-005**: A reviewer can run every command in Verification and compare it to the expected result named there.

## Bootstrap

Jorge runs this on his machine after `aws sso login` with the SSO profile he already uses. `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are unset. Replace nothing except the profile name he already has.

```bash
export AWS_PROFILE=<jorge-sso-profile>
export AWS_REGION=eu-west-1
ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
STATE_BUCKET="web-portfolio-tfstate-${ACCOUNT}"
aws s3api create-bucket --bucket "$STATE_BUCKET" --region eu-west-1 \
  --create-bucket-configuration LocationConstraint=eu-west-1
aws s3api put-bucket-versioning --bucket "$STATE_BUCKET" \
  --versioning-configuration Status=Enabled
aws s3api put-public-access-block --bucket "$STATE_BUCKET" \
  --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
aws s3api put-bucket-encryption --bucket "$STATE_BUCKET" \
  --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"},"BucketKeyEnabled":true}]}'
```

He then applies Terraform 1.16.6 from a checkout of the head of the open pull request that contains `infra/`. He does this before that pull request merges. The email is only in the environment, not in a committed file.

```bash
export TF_VAR_budget_alert_email=<address-known-to-jorge>
terraform -chdir=infra/shared init -input=false -backend-config="bucket=${STATE_BUCKET}" -backend-config="key=shared/terraform.tfstate"
terraform -chdir=infra/shared apply -input=false
terraform -chdir=infra/site init -input=false -backend-config="bucket=${STATE_BUCKET}" -backend-config="key=staging/terraform.tfstate" -reconfigure
terraform -chdir=infra/site apply -input=false -var environment=staging
terraform -chdir=infra/site init -input=false -backend-config="bucket=${STATE_BUCKET}" -backend-config="key=production/terraform.tfstate" -reconfigure
terraform -chdir=infra/site apply -input=false -var environment=production
```

The `backend "s3"` block in `infra/shared` and in `infra/site` omits `bucket` and `key`. It sets `region = "eu-west-1"` and `use_lockfile = true`. Both `bucket` and `key` are passed with `-backend-config` at init, as above. `bucket` is `${STATE_BUCKET}` and is not a literal in the backend block. The account id is never committed.

He then creates the GitHub Environments and the branch policies. The environment update sets no reviewers.

```bash
for pair in staging:develop production:main; do
  env=${pair%%:*}
  branch=${pair##*:}
  gh api --method PUT "repos/JLaborda/web-portfolio/environments/${env}" --input - <<EOF
{"wait_timer":0,"deployment_branch_policy":{"protected_branches":false,"custom_branch_policies":true}}
EOF
  gh api --method POST "repos/JLaborda/web-portfolio/environments/${env}/deployment-branch-policies" --input - <<EOF
{"name":"${branch}","type":"branch"}
EOF
done
```

He copies Terraform outputs into environment variables. `SITE_URL` is `https://` plus the distribution domain, with no path and no trailing slash.

```bash
gh variable set AWS_ROLE_ARN --env staging --body "<staging deploy role arn>"
gh variable set SITE_URL --env staging --body "https://<staging-id>.cloudfront.net"
gh variable set BUCKET_NAME --env staging --body "web-portfolio-staging-${ACCOUNT}"
gh variable set DISTRIBUTION_ID --env staging --body "<staging distribution id>"
gh variable set AWS_ROLE_ARN --env production --body "<production deploy role arn>"
gh variable set SITE_URL --env production --body "https://<production-id>.cloudfront.net"
gh variable set BUCKET_NAME --env production --body "web-portfolio-production-${ACCOUNT}"
gh variable set DISTRIBUTION_ID --env production --body "<production distribution id>"
gh variable set AWS_PLAN_ROLE_ARN --body "<web-portfolio-plan role arn>"
```

The last command sets a repository variable. It does not pass `--env`. It is the last bootstrap step. Jorge runs Bootstrap from the head of the open pull request that first adds `infra/`, then re-runs `terraform` on that head. He merges only the run that executed plan, as FR-021 requires.

After the `terraform` job has reported at least once, and before that pull request merges, he turns on branch protection. `strict` is false. `enforce_admins` is true. Reviews and push restrictions are off.

```bash
for branch in develop main; do
  gh api -X PUT "repos/JLaborda/web-portfolio/branches/${branch}/protection" --input - <<EOF
{
  "required_status_checks": {
    "strict": false,
    "contexts": ["gitleaks", "hugo", "lychee", "terraform"]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": null,
  "restrictions": null
}
EOF
done
```

## Verification

Commands that read AWS use Jorge's SSO profile or the read-only plan role. They do not use static keys. `ACCOUNT` is the same 12-digit account as in Bootstrap.

- **FR-001, FR-014, FR-015, FR-018**:

  ```bash
  yq -e '[.on.push.branches[] | select(. == "develop" or . == "main")] | unique | length == 2' .github/workflows/deploy.yml
  if yq -e '.on | has("pull_request")' .github/workflows/deploy.yml >/dev/null; then exit 1; fi
  test "$(grep -R -E '^[[:space:]]*HUGO_VERSION:' .github/workflows | wc -l | tr -d ' ')" = 1
  grep -F 'hugo --gc --minify --panicOnWarning --baseURL' .github/workflows/deploy.yml
  grep -F 'hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz' .github/workflows/deploy.yml
  grep -F 'aws s3 sync' .github/workflows/deploy.yml
  grep -F 'aws cloudfront create-invalidation' .github/workflows/deploy.yml
  grep -F 'e1253824e5c10ff9df46874f81ed3ec929e19cfd' .github/workflows/deploy.yml
  grep -F '3d3c42e5aac5ba805825da76410c181273ba90b1' .github/workflows/deploy.yml
  if grep -F 'terraform apply' .github/workflows/deploy.yml .github/workflows/terraform.yml; then exit 1; fi
  ```

  Expected: `yq` prints `true` and exits 0. The `has("pull_request")` command does not take the `exit 1` branch. The version count is 1. Each `grep -F` exits 0. The `terraform apply` guard exits 0.

- **FR-002, FR-003, FR-004**: After both distributions exist. Repeat with the production distribution id and its `SITE_URL`.

  ```bash
  aws s3api get-public-access-block --bucket "$BUCKET_NAME" \
    | jq -e '.PublicAccessBlockConfiguration | [.BlockPublicAcls,.IgnorePublicAcls,.BlockPublicPolicy,.RestrictPublicBuckets] == [true,true,true,true]'
  aws cloudfront get-distribution --id "$DISTRIBUTION_ID" | jq -e '
    .Distribution
    | (.DomainName | test("^[a-z0-9]+\\.cloudfront\\.net$"))
    and .DistributionConfig.PriceClass == "PriceClass_100"
    and .DistributionConfig.DefaultRootObject == "index.html"
    and .DistributionConfig.DefaultCacheBehavior.ViewerProtocolPolicy == "redirect-to-https"
    and (.DistributionConfig.Origins.Items[0].OriginAccessControlId | length > 0)
    and ([.DistributionConfig.DefaultCacheBehavior.FunctionAssociations.Items[].EventType] | index("viewer-request") != null)
  '
  code=$(curl -sI -o /dev/null -w '%{http_code}' "http://${SITE_URL#https://}/")
  test "$code" = 301
  while IFS= read -r f; do
    rel=${f#public/}
    rel=${rel%index.html}
    curl -fsS -o /dev/null "${SITE_URL}/${rel}"
  done < <(find public -name index.html)
  ```

  Expected: both `jq -e` commands print `true` and exit 0. The HTTP status is 301. Every `curl` of a built directory URL exits 0. `public/` is the Hugo output of the deployed commit, built with `--baseURL "${SITE_URL}/"`.

- **FR-005**:

  ```bash
  curl -fsS "${SITE_URL}/robots.txt" | tee /tmp/robots.txt | grep -F 'Disallow: /'
  curl -fsSI "${SITE_URL}/" | grep -i '^x-robots-tag: noindex'
  ```

  Expected on staging: both commands exit 0. Expected on production: both commands exit non-zero, and `/tmp/robots.txt` from production contains `Allow: /`.

- **FR-006, FR-008, FR-009**:

  ```bash
  terraform version | head -1 | grep -F 'v1.16.6'
  grep -F 'version = "6.69.1"' infra/shared/*.tf infra/site/*.tf
  grep -F 'use_lockfile = true' infra/shared/*.tf infra/site/*.tf
  for dir in infra/shared infra/site; do
    block=$(awk '
      /backend[[:space:]]+"s3"[[:space:]]*\{/ {capture=1}
      capture {print}
      capture && /\}/ {capture=0}
    ' "$dir"/*.tf)
    test -n "$block"
    printf '%s\n' "$block" | grep -E 'region[[:space:]]*=[[:space:]]*"eu-west-1"'
    printf '%s\n' "$block" | grep -E 'use_lockfile[[:space:]]*=[[:space:]]*true'
    if printf '%s\n' "$block" | grep -E '^[[:space:]]*(bucket|key)[[:space:]]*='; then
      exit 1
    fi
  done
  test "$(grep -R -o -F 'resource "aws_iam_role_policy"' infra/site/*.tf | wc -l | tr -d ' ')" = 1 || exit 1
  if grep -R -n -E 'resource "aws_iam_role"' infra/site/*.tf | grep -v -F 'resource "aws_iam_role_policy"'; then exit 1; fi
  grep -R -F 'data "aws_iam_role"' infra/site/*.tf || exit 1
  grep -R -F 'web-portfolio-${var.environment}-deploy' infra/site/*.tf || exit 1
  grep -R -F 'cloudfront:CreateInvalidation' infra/site/*.tf || exit 1
  if grep -R -n -F 'terraform_remote_state' infra/site/*.tf infra/shared/*.tf; then exit 1; fi
  terraform fmt -check -recursive
  terraform -chdir=infra/shared init -backend=false -input=false
  terraform -chdir=infra/shared validate
  terraform -chdir=infra/site init -backend=false -input=false
  terraform -chdir=infra/site validate
  ```

  Expected: every command exits 0. `terraform version` prints a line containing `v1.16.6`. For `infra/shared` and for `infra/site`, the loop prints one line containing `region = "eu-west-1"` and one line containing `use_lockfile = true`. The `bucket`/`key` guard prints nothing. A `bucket =` argument on `aws_s3_bucket`, `aws_s3_bucket_public_access_block`, or `aws_s3_bucket_policy` is outside the extracted block and does not fail the guard. A `bucket =` or `key =` argument inside `backend "s3"` makes the guard exit 1. The `aws_iam_role_policy` count test prints nothing and exits 0, so `infra/site` contains that resource exactly once. The `aws_iam_role` guard prints nothing, so `infra/site` declares no `aws_iam_role` resource. The three `grep -R -F` commands print the matching lines. The `terraform_remote_state` guard prints nothing.

- **FR-007, FR-010, FR-011**:

  ```bash
  aws sts get-caller-identity --query Account --output text
  aws iam list-users --query 'length(Users)' --output text
  aws iam get-role --role-name web-portfolio-plan \
    | jq -e '.Role.AssumeRolePolicyDocument.Statement[0].Condition.StringEquals["token.actions.githubusercontent.com:sub"] == "repo:JLaborda@15078416/web-portfolio@1427090788:pull_request"'
  aws iam get-role --role-name web-portfolio-staging-deploy \
    | jq -e '.Role.AssumeRolePolicyDocument.Statement[0].Condition.StringEquals["token.actions.githubusercontent.com:sub"] == "repo:JLaborda@15078416/web-portfolio@1427090788:environment:staging" and .Role.AssumeRolePolicyDocument.Statement[0].Condition.StringEquals["token.actions.githubusercontent.com:ref"] == "refs/heads/develop"'
  aws iam get-role --role-name web-portfolio-production-deploy \
    | jq -e '.Role.AssumeRolePolicyDocument.Statement[0].Condition.StringEquals["token.actions.githubusercontent.com:sub"] == "repo:JLaborda@15078416/web-portfolio@1427090788:environment:production" and .Role.AssumeRolePolicyDocument.Statement[0].Condition.StringEquals["token.actions.githubusercontent.com:ref"] == "refs/heads/main"'
  if git grep -n -I -e 'AWS_ACCESS_KEY_ID' -e 'AWS_SECRET_ACCESS_KEY' -- .github infra; then exit 1; fi
  grep -R -E 'iam:GetRole"' infra/shared/*.tf || exit 1
  grep -R -F 'iam:GetRolePolicy' infra/shared/*.tf || exit 1
  if grep -R -n -F 'iam:PutRolePolicy' infra/shared/*.tf; then exit 1; fi
  ```

  Expected: `list-users` prints `0`. Each `jq -e` prints `true` and exits 0. The key-name guard exits 0. `grep -R -E 'iam:GetRole"'` and `grep -R -F 'iam:GetRolePolicy'` each print a matching line and exit 0. The `iam:PutRolePolicy` guard prints nothing, so the plan-role policy in `infra/shared` does not contain that action.

- **FR-012, FR-013**:

  ```bash
  aws budgets describe-budget --account-id "$ACCOUNT" --budget-name web-portfolio-monthly \
    | jq -e '.Budget | (.BudgetLimit.Amount | tonumber) == 1 and .BudgetLimit.Unit == "USD" and .TimeUnit == "MONTHLY"'
  NOTIF=$(aws budgets describe-notifications-for-budget --account-id "$ACCOUNT" --budget-name web-portfolio-monthly --query 'Notifications[0]' --output json)
  printf '%s\n' "$NOTIF" | jq -e '.NotificationType == "ACTUAL" and .ComparisonOperator == "GREATER_THAN" and (.Threshold | tonumber == 100) and .ThresholdType == "PERCENTAGE"'
  aws budgets describe-subscribers-for-notification --account-id "$ACCOUNT" --budget-name web-portfolio-monthly --notification "$NOTIF" \
    | jq -e --arg email "$TF_VAR_budget_alert_email" '[.Subscribers[] | select(.SubscriptionType == "EMAIL" and .Address == $email)] | length == 1'
  if git grep -n -I -E 'budget_alert_email[[:space:]]*=[[:space:]]*"[^"]+"' | grep -v 'replace-me@example.com'; then exit 1; fi
  test -f infra/shared/terraform.tfvars.example
  test ! -e infra/shared/terraform.tfvars
  git check-ignore -q --no-index .terraform/x
  git check-ignore -q --no-index x.tfstate
  git check-ignore -q --no-index x.tfstate.backup
  git check-ignore -q --no-index x.tfvars
  if git check-ignore -q --no-index x.tfvars.example; then exit 1; fi
  if git check-ignore -q --no-index .terraform.lock.hcl; then exit 1; fi
  ```

  Expected: each `jq -e` prints `true` and exits 0. The email guard exits 0. `terraform.tfvars` is not in the tree. `git check-ignore -q --no-index` exits 0 for `.terraform/x`, `x.tfstate`, `x.tfstate.backup`, and `x.tfvars`. It exits non-zero for `x.tfvars.example` and `.terraform.lock.hcl`, so those two `if` commands do not take the `exit 1` branch. `--no-index` tests the ignore rule itself, including when `.terraform.lock.hcl` is tracked. `git check-ignore -v` is not the proof: with `-v`, the negation `!*.tfvars.example` still exits 0.

- **FR-014**:

  ```bash
  gh api repos/JLaborda/web-portfolio/environments/staging/deployment-branch-policies --jq '[.branch_policies[].name] | sort == ["develop"]'
  gh api repos/JLaborda/web-portfolio/environments/production/deployment-branch-policies --jq '[.branch_policies[].name] | sort == ["main"]'
  gh api repos/JLaborda/web-portfolio/environments/staging --jq '(.deployment_branch_policy.custom_branch_policies == true) and (([.protection_rules[].type] | index("required_reviewers")) == null)'
  gh api repos/JLaborda/web-portfolio/environments/production --jq '(.deployment_branch_policy.custom_branch_policies == true) and (([.protection_rules[].type] | index("required_reviewers")) == null)'
  ```

  Expected: each command prints `true` and exits 0.

- **FR-016**: After a deploy, for the staging bucket and again for the production bucket.

  ```bash
  aws s3api head-object --bucket "$BUCKET_NAME" --key index.html --query CacheControl --output text
  ```

  Expected: the printed value is `public, max-age=0, must-revalidate`. An object whose key matches `\.[0-9a-f]{8,}\.` and is not html, xml, json, or `robots.txt` prints `public, max-age=31536000, immutable`. Any other object prints `public, max-age=3600`.

- **FR-017**:

  ```bash
  yq -e '[.on.pull_request.branches[] | select(. == "develop" or . == "main")] | unique | length == 2' .github/workflows/terraform.yml
  yq -e '.on.pull_request | has("paths") | not' .github/workflows/terraform.yml
  yq -e '.jobs | has("terraform")' .github/workflows/terraform.yml
  yq -o=json '.jobs.terraform.steps' .github/workflows/terraform.yml | jq -e --arg expected "steps.paths.outputs.infra == 'true'" '[.[] | select(.if != null) | .if] | unique == [$expected]'
  grep -F '3d3c42e5aac5ba805825da76410c181273ba90b1' .github/workflows/terraform.yml
  grep -F 'fetch-depth: 0' .github/workflows/terraform.yml
  grep -F 'id: paths' .github/workflows/terraform.yml
  grep -F 'git diff --name-only' .github/workflows/terraform.yml
  grep -F 'infra=true' .github/workflows/terraform.yml
  grep -F 'infra=false' .github/workflows/terraform.yml
  grep -F 'terraform fmt -check -recursive' .github/workflows/terraform.yml
  grep -F 'terraform plan -lock=false -input=false' .github/workflows/terraform.yml
  grep -F -- '-no-color' .github/workflows/terraform.yml
  if grep -E 'No changes\. Your infrastructure|Plan: [0-9]+ to add,' .github/workflows/terraform.yml; then exit 1; fi
  grep -F 'vars.AWS_PLAN_ROLE_ARN' .github/workflows/terraform.yml
  grep -F '::notice::AWS_PLAN_ROLE_ARN is unset; terraform plan skipped until bootstrap' .github/workflows/terraform.yml
  grep -F 'git ls-tree -d "${{ github.event.pull_request.base.sha }}" infra' .github/workflows/terraform.yml
  grep -F '::error::AWS_PLAN_ROLE_ARN is unset and infra/ already exists on the base' .github/workflows/terraform.yml
  grep -F 'cut -d: -f5' .github/workflows/terraform.yml
  grep -F 'backend-config="bucket=web-portfolio-tfstate-${account}"' .github/workflows/terraform.yml
  tflint --version | grep -F '0.64.0'
  ```

  Expected: every `yq -e` command prints `true` and exits 0. `.on.pull_request | has("paths") | not` prints `true`, so the pull request event has no `paths` filter. The `yq -o=json` pipeline prints `true` and exits 0. `yq --arg` is not used. Every step that sets `if` uses `steps.paths.outputs.infra == 'true'`. Every `grep -F` exits 0, including `grep -F -- '-no-color'`. The summary-string guard exits 0: `.github/workflows/terraform.yml` contains neither `No changes. Your infrastructure` nor `Plan: N to add,`. `grep -F 'cut -d: -f5'` prints that text. `grep -F 'backend-config="bucket=web-portfolio-tfstate-${account}"'` prints that text, once for each backend init. The plan step sets `account` from `AWS_PLAN_ROLE_ARN` with `cut -d: -f5` and passes `-backend-config="bucket=web-portfolio-tfstate-${account}"` on each backend `terraform init`. `tflint --version` contains `0.64.0`. The notice is only the branch where the base has no `infra/` tree and the variable is empty. The error is the branch where the base has `infra/` and the variable is empty. The plan command is `terraform plan -lock=false -input=false -no-color`.

- **FR-019**: Before bootstrap's last command, and again after it:

  ```bash
  gh variable list --json name --jq '[.[] | select(.name == "AWS_PLAN_ROLE_ARN")] | length == 1'
  ```

  Expected before that command: prints `false`. Expected after it: prints `true`. The value is the plan role ARN and is not committed.

- **FR-020**: After `.github/workflows/terraform.yml` is on `develop`, and after Jorge has saved branch protection:

  ```bash
  for branch in develop main; do
    gh api "repos/JLaborda/web-portfolio/branches/${branch}/protection" \
      --jq '[.required_status_checks.contexts[], .required_status_checks.checks[].context] | unique | sort'
    gh api "repos/JLaborda/web-portfolio/branches/${branch}/protection" \
      --jq '.enforce_admins.enabled'
  done
  ```

  Expected: each contexts command exits 0 and prints `["gitleaks","hugo","lychee","terraform"]`. Each `enforce_admins` command prints `true`. An HTTP 404 means protection is missing. A list that drops `hugo`, `lychee`, or `gitleaks` does not pass. Only Jorge, as repository admin, runs the Bootstrap `gh api -X PUT` command that creates this protection. `enforce_admins` true means he cannot bypass a red check. The check failing before he saves protection is expected, and it is not a reason to merge the first `infra/` pull request early.

- **FR-021**: On the pull request into `develop` that first adds `infra/`, after the re-run. `HEAD_SHA` is that pull request's head. The base ref is `develop`.

  ```bash
  ROW=$(gh run list --commit "$HEAD_SHA" --workflow terraform.yml --json databaseId,conclusion,createdAt,attempt \
    --jq 'sort_by(.createdAt) | reverse | .[0] | select(.conclusion == "success")')
  RUN=$(printf '%s\n' "$ROW" | jq -r '.databaseId')
  ATTEMPT=$(printf '%s\n' "$ROW" | jq -r '.attempt')
  test -n "$RUN"
  test -n "$ATTEMPT"
  gh run view "$RUN" --attempt "$ATTEMPT" --log > /tmp/terraform-run.log
  test "$(sed -E 's/\x1b\[[0-9;]*m//g' /tmp/terraform-run.log | grep -E -c 'No changes\. Your infrastructure matches the configuration\.|Plan: [0-9]+ to add,' || true)" -ge 2
  JOB_ID=$(gh run view "$RUN" --attempt "$ATTEMPT" --json jobs --jq '.jobs[] | select(.name == "terraform") | .databaseId')
  test -n "$JOB_ID"
  gh api "repos/JLaborda/web-portfolio/check-runs/${JOB_ID}/annotations" \
    --jq '[.[] | select((.message | contains("terraform plan skipped")) or .annotation_level == "failure")] | length == 0'
  ```

  Expected: `RUN` and `ATTEMPT` are non-empty. `--attempt` is the latest attempt of that run, which is what a re-run updates. The summary count is at least 2, one for `infra/shared` and one for `infra/site`, after `sed -E 's/\x1b\[[0-9;]*m//g'` strips ANSI color codes. `-no-color` on the plan command keeps those lines plain. The strip still matches if a code remains. Those lines are Terraform's own plan text. They are not in `.github/workflows/terraform.yml`, and the echoed `run:` script does not contain them. A log that prints only `Changes to Outputs:` counts below 2. Jorge re-applies Terraform locally from that head and re-runs the job. He does not bypass the check. The annotations command prints `true`: no annotation message contains `terraform plan skipped`, and none has level `failure`. A skipped plan does not pass, and it is not merged.

## Out of Scope

- Custom domain, ACM, and Route 53. A later feature owns those. Any ACM certificate that feature adds is requested in `us-east-1`.
- The `hugo`, `lychee`, and `gitleaks` jobs. Feature 001 owns them.
- Analytics, WAF, more than one region, and a preview distribution per pull request.
- IAM users, long-lived access keys, and committing an email address.
- Applying Terraform from GitHub Actions.

## Assumptions

- Feature 001 has merged far enough that `HUGO_VERSION` exists in `.github/workflows/ci.yml` and the Hugo site builds with `hugo --gc --minify --panicOnWarning`. This feature reads that variable and does not declare another.
- Jorge's AWS account is the one he already signs into with SSO. The account id is whatever `aws sts get-caller-identity` prints. Bucket names include that id because S3 names are global.
- The repository is public, so GitHub Environment branch policies are available. Confirmed for `JLaborda/web-portfolio` on 2026-10-21.
- `PriceClass_100` is the cheapest CloudFront price class that includes Europe, which is where `eu-west-1` visitors are served.
- S3 lock files (`use_lockfile`) replace a DynamoDB lock table. Terraform 1.16.6 supports that argument. The plan role does not write lock files because it passes `-lock=false`.
- One shared budget of 1 USD covers both environments. That is the constitution's monthly cap, not a per-environment cap.
- The deploy role is the constitution's apply/deploy role. It publishes files and creates invalidations. It is not allowed to apply Terraform. The plan role is the constitution's read-only plan role.
