# Tasks: AWS Deployment

Status: Approved by Jorge — PR #25

**Input**: Design documents from `/specs/002-aws-deployment/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/hosting.md, contracts/iam.md, contracts/workflows.md, quickstart.md

**Tests**: The specification does not request a test framework. Each implementation pull request runs the verification named for its group. There are no separate test tasks.

**Organization**: Tasks are grouped by user story. Delivery is four pull requests, on the same pattern as feature 001's `t01` through `t04`.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: User story label. Setup, Foundational, and Polish tasks have none.
- Every description names a file path.

On every implementation branch, before Spec Kit scripts, export `SPECIFY_FEATURE_DIRECTORY=specs/002-aws-deployment`.

## Path conventions

Hugo site at the repository root. Terraform under `infra/`. Workflows under `.github/workflows/`. See [plan.md](./plan.md).

## Implementation pull requests

Four pull requests, merged one at a time into `develop`. Each pull request lists its task ids in the description and marks those same ids `[X]` in this file. The last pull request also commits `specs/002-aws-deployment/converge.md`.

`t01` contains no `infra/` tree. `terraform.yml` is on `develop`, and the job `terraform` has completed at least once, before `t02` is merged. `t02` is the pull request into `develop` that first adds `infra/`. Jorge runs Bootstrap from that head before the merge. Protection is on before that merge. The later pull request into `main` does not bootstrap again.

| Branch | Tasks | Requirements | Depends on | Verification command |
|--------|-------|--------------|------------|----------------------|
| `002-aws-deployment-t01` | T001–T002 | FR-009 (no `terraform apply` in the workflow), FR-013, FR-017, FR-018 (does not redefine hugo, lychee, or gitleaks) | This `tasks.md` merged | The FR-017 block in `spec.md`, except `grep -F 'cut -d: -f5'` and `grep -F 'backend-config="bucket=web-portfolio-tfstate-${account}"'`, which T003 adds in `t02`. Also `grep -F '(cd "$d" && terraform plan -lock=false -input=false -no-color)' .github/workflows/terraform.yml` exits 0. `yq -e '.jobs.terraform.permissions."id-token" == "write" and .jobs.terraform.permissions.contents == "read"' .github/workflows/terraform.yml` prints `true`. `test "$(yq '.jobs \| keys \| length' .github/workflows/terraform.yml)" = "1"`. `git check-ignore -q --no-index` from FR-013. `test ! -d infra`. `grep -F 'ACTIONS_ID_TOKEN_REQUEST_URL' .github/workflows/terraform.yml`, `grep -F 'ACTIONS_ID_TOKEN_REQUEST_TOKEN' .github/workflows/terraform.yml`, and `grep -F 'audience=sts.amazonaws.com' .github/workflows/terraform.yml` exit 0. `grep -E 'AWS_WEB_IDENTITY_TOKEN_FILE|assume-role-with-web-identity' .github/workflows/terraform.yml` exits 0. `if grep -F 'configure-aws-credentials' .github/workflows/terraform.yml; then exit 1; fi` and `if grep -F "vars.AWS_PLAN_ROLE_ARN != ''" .github/workflows/terraform.yml; then exit 1; fi` both exit 0. The pull request's `terraform` job is green with the paths filter skipping Terraform, because `infra/**` did not change. |
| `002-aws-deployment-t02` | T003–T010 | FR-002, FR-003, FR-004, FR-006, FR-007, FR-008, FR-009, FR-010, FR-011, FR-012, FR-017 (plan inits only), FR-019, FR-020, FR-021 | `t01` merged and the `terraform` job has reported on `develop`. Branch protection is on before this pull request merges (T009), not necessarily before it opens | Workstation blocks FR-006 through FR-013 and FR-019 in `spec.md`. `grep -F 'cut -d: -f5' .github/workflows/terraform.yml` and `grep -F 'backend-config="bucket=web-portfolio-tfstate-${account}"' .github/workflows/terraform.yml` exit 0. The three plan init steps in `.github/workflows/terraform.yml` — the shared init (`key=shared/terraform.tfstate`), the staging init (`key=staging/terraform.tfstate`), and the production init (`key=production/terraform.tfstate`) — pass that bucket flag and the key for that step. That plan-init change belongs to `t02`. This plan pull request does not edit `.github/workflows/terraform.yml`. The simulation script in T010. Then FR-021 on the re-run. Three plan summaries are expected (shared, staging, production) and the count is at least 2. A log that shows only `Changes to Outputs:` is not merged. Jorge re-applies locally and re-runs. No admin bypass. |
| `002-aws-deployment-t03` | T011–T015 | FR-001, FR-005, FR-014, FR-015, FR-016, FR-018 | `t02` merged and the deploy variables set | The FR-001, FR-014, and FR-015 block in `spec.md`, including `test "$(grep -R -E '^[[:space:]]*HUGO_VERSION:' .github/workflows \| wc -l \| tr -d ' ')" = 1`. `grep -F "yq '.env.HUGO_VERSION' .github/workflows/ci.yml" .github/workflows/deploy.yml` exits 0. `deploy.yml` has no `pull_request` trigger. Staging checks FR-002, FR-003, FR-004, FR-005, and FR-016 after the push to `develop`. Production uses the same commands after Jorge merges that release to `main`. SC-002, on the branch that just deployed: add `content/posts/spec-002-remove.md`, deploy, record that `posts/spec-002-remove/index.html` exists, delete that file, deploy again, then `if aws s3api head-object --bucket "$BUCKET_NAME" --key posts/spec-002-remove/index.html; then exit 1; fi` and `if curl -fsS "${SITE_URL}/posts/spec-002-remove/" | grep -F 'spec-002-remove'; then exit 1; fi`. Expected: `head-object` fails, so the key is gone, and `curl` does not return the old page. US3 scenario 3: `RUN` is the successful `deploy.yml` run for that commit, `gh run view "$RUN" --log` contains `site_url=${SITE_URL}`, and `grep -F "site_url=${SITE_URL}"` exits 0. `grep -F 'site_url=${SITE_URL}' .github/workflows/deploy.yml` exits 0, and `if grep -F 'site_url=${{ vars.SITE_URL }}' .github/workflows/deploy.yml; then exit 1; fi` exits 0. `SITE_URL` is `https://` plus the CloudFront hostname, with no trailing slash. `grep -F 'for name in SITE_URL BUCKET_NAME DISTRIBUTION_ID AWS_ROLE_ARN' .github/workflows/deploy.yml` and `grep -F '::error::%s is empty' .github/workflows/deploy.yml` exit 0. |
| `002-aws-deployment-t04` | T016 | FR-020, converge | `t03` merged, both hostnames serving, protection already on | `specs/002-aws-deployment/converge.md` contains the FR-020 `gh api` output `["gitleaks","hugo","lychee","terraform"]` and `true` for `.enforce_admins.enabled`, for `develop` and for `main`, then the date, the SHA it ran on, and the verdict `Converged`. The pull request description pastes that verdict. |

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Ignore Terraform local files, and land the required `terraform` check before any `infra/` tree exists.

**Pull request**: `002-aws-deployment-t01`

- [X] T001 In `.gitignore`, add `.terraform/`, `*.tfstate`, `*.tfstate.*`, `*.tfvars`, and the negation `!*.tfvars.example`. Do not ignore `.terraform.lock.hcl`
- [X] T002 Add `.github/workflows/terraform.yml` with `permissions` `id-token: write` and `contents: read`, one job named `terraform`, no workflow-level `paths:` filter, no GitHub Environment, and no `strategy.matrix`. Checkout is `actions/checkout` at `3d3c42e5aac5ba805825da76410c181273ba90b1` with `fetch-depth: 0` and `ref: ${{ github.event.pull_request.head.sha }}`. Before the diff, fetch `github.event.pull_request.base.sha` so both commits exist. A step id `paths` sets output `infra` from `git diff --name-only` between the base and head SHAs (`infra=true` or `infra=false`). The plan script assumes `web-portfolio-plan` inside that same script, and every step that runs Terraform, tflint, or that script uses `if: steps.paths.outputs.infra == 'true'` and no `continue-on-error`. There is no `aws-actions/configure-aws-credentials` step in this file and no second `if`. Fmt, validate, and tflint run `terraform fmt -check -recursive`, `terraform -chdir=infra/shared validate`, `terraform -chdir=infra/site validate`, and tflint 0.64.0 with AWS ruleset 0.49.0, without AWS credentials. The plan step uses that same `if`, reads `vars.AWS_PLAN_ROLE_ARN`, strips whitespace, and runs `git ls-tree -d "${{ github.event.pull_request.base.sha }}" infra`. It prints `::notice::AWS_PLAN_ROLE_ARN is unset; terraform plan skipped until bootstrap` and exits 0 only when that output is empty and the variable is empty. It prints `::error::AWS_PLAN_ROLE_ARN is unset and infra/ already exists on the base` and exits 1 when the tree exists and the variable is empty. When the variable is non-empty, that same script requests the GitHub OIDC token with audience `sts.amazonaws.com` from `ACTIONS_ID_TOKEN_REQUEST_URL` and `ACTIONS_ID_TOKEN_REQUEST_TOKEN`, writes the JWT to a file, and exports `AWS_ROLE_ARN` and `AWS_WEB_IDENTITY_TOKEN_FILE`, or calls `aws sts assume-role-with-web-identity`. It then runs the three-row loop in [plan.md](./plan.md), with the repository secret `TF_VAR_budget_alert_email` exported as `TF_VAR_budget_alert_email: ${{ secrets.TF_VAR_budget_alert_email }}`, the real address (not a dummy, not committed): `(cd "$d" && terraform plan -lock=false -input=false -no-color)` for `infra/shared` (init `-backend-config="key=shared/terraform.tfstate"`) and for `infra/site` twice (`-backend-config="key=staging/terraform.tfstate"` with `-var environment=staging`, and `key=production/terraform.tfstate` with `-var environment=production`), each init using `-input=false -lock=false -reconfigure`. The file contains neither `terraform apply` nor `No changes. Your infrastructure` nor `Plan: N to add,`. Do not create `infra/` in this pull request.

**Checkpoint**: `terraform.yml` is reviewable without an `infra/` tree. The required check can report before the first infrastructure pull request.

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Define both stacks and bootstrap them from the first `infra/` pull request.

**Critical**: No deploy pull request starts until `002-aws-deployment-t02` is merged. Jorge bootstraps from the `t02` head before that merge.

**Pull request**: `002-aws-deployment-t02`

- [X] T003 [P] Add `infra/shared` Terraform 1.16.6 and AWS provider `hashicorp/aws` `6.69.1`. The `backend "s3"` block contains only `region = "eu-west-1"` and `use_lockfile = true`. It has no `bucket` argument and no `key` argument. Init passes `-backend-config="bucket=web-portfolio-tfstate-${ACCOUNT}"` and `-backend-config="key=shared/terraform.tfstate"`. The account id is never committed. In this same `002-aws-deployment-t02` pull request, and in no other pull request, change the three plan init steps in `.github/workflows/terraform.yml`: the shared init (`key=shared/terraform.tfstate`), the staging init (`key=staging/terraform.tfstate`), and the production init (`key=production/terraform.tfstate`). Each of those inits passes `-backend-config="bucket=web-portfolio-tfstate-${account}"` and its key. Set `account` from `AWS_PLAN_ROLE_ARN` with `cut -d: -f5`. Do not commit the account id. This plan pull request does not edit `.github/workflows/terraform.yml`. That plan-init change belongs to `t02`
- [X] T004 [P] Add the GitHub OIDC provider and the three roles in `infra/shared`. The provider URL is `https://token.actions.githubusercontent.com` and the audience is `sts.amazonaws.com`. Read the thumbprint from GitHub's current OIDC certificate at implementation time; do not invent one. Trust uses prefix `repo:JLaborda@15078416/web-portfolio@1427090788`. `web-portfolio-plan` trusts only `sub` `repo:JLaborda@15078416/web-portfolio@1427090788:pull_request` and cannot `s3:PutObject`, `s3:DeleteObject`, `cloudfront:CreateInvalidation`, `cloudfront:UpdateDistribution`, `iam:CreateRole`, `iam:PutRolePolicy`, or `budgets:ModifyBudget`. `web-portfolio-staging-deploy` trusts `sub` `repo:JLaborda@15078416/web-portfolio@1427090788:environment:staging` and `ref` `refs/heads/develop`. `web-portfolio-production-deploy` trusts `sub` `repo:JLaborda@15078416/web-portfolio@1427090788:environment:production` and `ref` `refs/heads/main`. Each deploy role can `s3:ListBucket`, `s3:GetObject`, `s3:PutObject`, and `s3:DeleteObject` only on its own site bucket. The deploy role, its trust policy, and those S3 permissions stay in `infra/shared`. `infra/shared` does not use `inline_policy` blocks or `aws_iam_role_policies_exclusive` on the deploy roles, so the inline policy owned by `infra/site` is not reverted. `cloudfront:CreateInvalidation` is not granted from `infra/shared`; T007 attaches that action in `infra/site` to the role's own distribution ARN. `web-portfolio-plan` can `iam:GetRole` and `iam:GetRolePolicy` on the staging and production deploy roles. A deploy role cannot change IAM, budgets, the state bucket, or distribution configuration
- [X] T005 [P] Add budget `web-portfolio-monthly` in `infra/shared`: limit amount `1`, unit `USD`, time unit `MONTHLY`, one notification type `ACTUAL`, comparison `GREATER_THAN`, threshold `100`, threshold type `PERCENTAGE`, subscriber email `TF_VAR_budget_alert_email`. Do not commit the address and do not pass a dummy value
- [X] T006 [P] Add `infra/shared/terraform.tfvars.example` setting `budget_alert_email` to `replace-me@example.com`, and no other committed assignment of that variable
- [X] T007 [P] Add `infra/site` pinned to Terraform 1.16.6 and AWS provider `hashicorp/aws` `6.69.1`, with variable `environment` limited to `staging` and `production`. The `backend "s3"` block contains only `region = "eu-west-1"` and `use_lockfile = true`. It has no `bucket` argument and no `key` argument. Init passes `-backend-config="bucket=web-portfolio-tfstate-${ACCOUNT}"` and `-backend-config="key=${environment}/terraform.tfstate"`. The account id is not committed. Outputs are `distribution_id`, `distribution_arn`, `bucket_name`, and `domain_name`. Add one inline `aws_iam_role_policy` allowing `cloudfront:CreateInvalidation` on this environment's distribution ARN, attached to the deploy role from `data "aws_iam_role"` named `web-portfolio-${var.environment}-deploy`. Do not use remote state. Declare no `aws_iam_policy`, no `aws_iam_role_policy_attachment`, and no `aws_iam_role_policies_exclusive`. The deploy role, its trust policy, and its S3 permissions stay in `infra/shared`. For the selected environment create bucket `web-portfolio-<environment>-<account-id>` with all four Block Public Access flags, no website endpoint, an Origin Access Control, and a distribution `PriceClass_100`, default root object `index.html`, viewer protocol policy `redirect-to-https`. Add the viewer-request function: `/` serves `index.html`, a URI ending in `/` appends `index.html`, a last segment with no `.` appends `/index.html`, and a last segment containing `.` is unchanged. The staging distribution adds response header `X-Robots-Tag: noindex`. The production distribution does not send `X-Robots-Tag`
- [X] T008 Add `.tflint.hcl` in `infra/shared` and `infra/site` pinning AWS ruleset `0.49.0`, and commit `.terraform.lock.hcl` in each directory after `terraform providers lock` for `linux_amd64`. Do not commit `.terraform/` or a tfvars file
- [X] T009 From the `t02` head, before merge, Jorge runs the Bootstrap section of `spec.md` with his SSO profile: state bucket, then `terraform init` and `terraform apply` of `infra/shared` with `-backend-config="bucket=web-portfolio-tfstate-${ACCOUNT}"` and `-backend-config="key=shared/terraform.tfstate"`, then `infra/site` twice (`-backend-config="bucket=web-portfolio-tfstate-${ACCOUNT}"` and `-backend-config="key=staging/terraform.tfstate"` with `-var environment=staging`, then `-backend-config="bucket=web-portfolio-tfstate-${ACCOUNT}"` and `-backend-config="key=production/terraform.tfstate"` with `-var environment=production`). The account id is not committed. The budget email is only the repository secret `TF_VAR_budget_alert_email`. He creates the GitHub Environments and sets the deploy variables and, last, repository variable `AWS_PLAN_ROLE_ARN` with no `--env`. He sets the repository secret `TF_VAR_budget_alert_email` to that same address before the re-run. He re-runs `terraform` on that head. He turns on branch protection with the `gh api -X PUT` command in `spec.md` if the `t01` job has already reported and protection is not on yet. He merges only when FR-021 passes
- [X] T010 After T009, run the bash script in `specs/002-aws-deployment/tasks.md` (the block under this task) from a machine with permission to call `iam:SimulatePrincipalPolicy`. Paste the decisions in the `t02` pull request description. One action and one resource ARN per call. `allowed` on a `deny` row fails the task. `implicitDeny` or `explicitDeny` on an `allow` row fails the task

```bash
ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
PLAN_ARN=$(aws iam get-role --role-name web-portfolio-plan --query Role.Arn --output text)
STAGING_ARN=$(aws iam get-role --role-name web-portfolio-staging-deploy --query Role.Arn --output text)
PRODUCTION_ARN=$(aws iam get-role --role-name web-portfolio-production-deploy --query Role.Arn --output text)
terraform -chdir=infra/site init -input=false -lock=false -reconfigure -backend-config="bucket=web-portfolio-tfstate-${ACCOUNT}" -backend-config="key=staging/terraform.tfstate"
STAGING_DIST=$(terraform -chdir=infra/site output -raw distribution_arn)
terraform -chdir=infra/site init -input=false -lock=false -reconfigure -backend-config="bucket=web-portfolio-tfstate-${ACCOUNT}" -backend-config="key=production/terraform.tfstate"
PRODUCTION_DIST=$(terraform -chdir=infra/site output -raw distribution_arn)
sim() {
  local expect="$1" arn="$2" action="$3" resource="$4"
  decision=$(aws iam simulate-principal-policy \
    --policy-source-arn "$arn" \
    --action-names "$action" \
    --resource-arns "$resource" \
    --query 'EvaluationResults[0].EvalDecision' --output text)
  printf '%s %s %s -> %s (want %s)\n' "$arn" "$action" "$resource" "$decision" "$expect"
  if [ "$expect" = allow ]; then test "$decision" = allowed; else test "$decision" != allowed; fi
}
sim deny  "$PLAN_ARN"       s3:PutObject                  "arn:aws:s3:::web-portfolio-staging-${ACCOUNT}/*"
sim deny  "$PLAN_ARN"       s3:PutObject                  "arn:aws:s3:::web-portfolio-tfstate-${ACCOUNT}/*"
sim deny  "$PLAN_ARN"       s3:DeleteObject               "arn:aws:s3:::web-portfolio-staging-${ACCOUNT}/*"
sim deny  "$PLAN_ARN"       cloudfront:CreateInvalidation "arn:aws:cloudfront::${ACCOUNT}:distribution/*"
sim deny  "$PLAN_ARN"       cloudfront:UpdateDistribution "arn:aws:cloudfront::${ACCOUNT}:distribution/*"
sim deny  "$PLAN_ARN"       iam:CreateRole                "arn:aws:iam::${ACCOUNT}:role/*"
sim allow "$PLAN_ARN"       iam:GetRole                   "arn:aws:iam::${ACCOUNT}:role/web-portfolio-staging-deploy"
sim allow "$PLAN_ARN"       iam:GetRolePolicy             "arn:aws:iam::${ACCOUNT}:role/web-portfolio-staging-deploy"
sim allow "$PLAN_ARN"       iam:GetRole                   "arn:aws:iam::${ACCOUNT}:role/web-portfolio-production-deploy"
sim allow "$PLAN_ARN"       iam:GetRolePolicy             "arn:aws:iam::${ACCOUNT}:role/web-portfolio-production-deploy"
sim deny  "$PLAN_ARN"       iam:PutRolePolicy             "arn:aws:iam::${ACCOUNT}:role/web-portfolio-plan"
sim deny  "$PLAN_ARN"       iam:PutRolePolicy             "arn:aws:iam::${ACCOUNT}:role/web-portfolio-staging-deploy"
sim deny  "$PLAN_ARN"       iam:PutRolePolicy             "arn:aws:iam::${ACCOUNT}:role/web-portfolio-production-deploy"
sim deny  "$PLAN_ARN"       budgets:ModifyBudget          "arn:aws:budgets::${ACCOUNT}:budget/web-portfolio-monthly"
sim allow "$STAGING_ARN"    s3:PutObject                  "arn:aws:s3:::web-portfolio-staging-${ACCOUNT}/*"
sim allow "$STAGING_ARN"    s3:DeleteObject               "arn:aws:s3:::web-portfolio-staging-${ACCOUNT}/*"
sim allow "$STAGING_ARN"    s3:GetObject                  "arn:aws:s3:::web-portfolio-staging-${ACCOUNT}/*"
sim allow "$STAGING_ARN"    s3:ListBucket                 "arn:aws:s3:::web-portfolio-staging-${ACCOUNT}"
sim allow "$STAGING_ARN"    cloudfront:CreateInvalidation "$STAGING_DIST"
sim deny  "$STAGING_ARN"    s3:PutObject                  "arn:aws:s3:::web-portfolio-production-${ACCOUNT}/*"
sim deny  "$STAGING_ARN"    s3:PutObject                  "arn:aws:s3:::web-portfolio-tfstate-${ACCOUNT}/*"
sim deny  "$STAGING_ARN"    cloudfront:UpdateDistribution "$STAGING_DIST"
sim deny  "$STAGING_ARN"    cloudfront:CreateInvalidation "$PRODUCTION_DIST"
sim deny  "$STAGING_ARN"    iam:CreateRole                "arn:aws:iam::${ACCOUNT}:role/*"
sim deny  "$STAGING_ARN"    budgets:ModifyBudget          "arn:aws:budgets::${ACCOUNT}:budget/web-portfolio-monthly"
sim allow "$PRODUCTION_ARN" s3:PutObject                  "arn:aws:s3:::web-portfolio-production-${ACCOUNT}/*"
sim allow "$PRODUCTION_ARN" s3:DeleteObject               "arn:aws:s3:::web-portfolio-production-${ACCOUNT}/*"
sim allow "$PRODUCTION_ARN" cloudfront:CreateInvalidation "$PRODUCTION_DIST"
sim deny  "$PRODUCTION_ARN" s3:PutObject                  "arn:aws:s3:::web-portfolio-staging-${ACCOUNT}/*"
sim deny  "$PRODUCTION_ARN" cloudfront:UpdateDistribution "$PRODUCTION_DIST"
sim deny  "$PRODUCTION_ARN" iam:PutRolePolicy             "arn:aws:iam::${ACCOUNT}:role/web-portfolio-production-deploy"
```

`distribution_arn` is the output from T007. Do not pass two resource ARNs in one call.

**Checkpoint**: Both stacks are applied. The re-run planned all three rows. Protection requires `gitleaks`, `hugo`, `lychee`, and `terraform`.

## Phase 3: User Story 1 - Visitor opens the published site (Priority: P1)

**Goal**: A push to `develop` publishes staging and a push to `main` publishes production, each over HTTPS on its own `*.cloudfront.net` hostname.

**Independent Test**: After the variables from Bootstrap are set, the FR-002 and FR-003 checks in `spec.md` pass for both distributions, and a pull request does not deploy.

**Pull request**: `002-aws-deployment-t03`

- [X] T011 [US1] Add `.github/workflows/deploy.yml` on `push` to `develop` and `main` only, with no `pull_request` trigger, `permissions` `id-token: write` and `contents: read`, and job `deploy`. The job environment is `staging` for `develop` and `production` for `main`. Checkout is `actions/checkout` at `3d3c42e5aac5ba805825da76410c181273ba90b1` with submodules recursive. The job assumes `vars.AWS_ROLE_ARN` through `aws-actions/configure-aws-credentials` at `e1253824e5c10ff9df46874f81ed3ec929e19cfd` with audience `sts.amazonaws.com` in `eu-west-1`. The file does not contain `terraform apply`. The first `run` step in `.github/workflows/deploy.yml` is `for name in SITE_URL BUCKET_NAME DISTRIBUTION_ID AWS_ROLE_ARN; do eval "value=\${$name}"; if [ -z "$value" ]; then printf '::error::%s is empty\n' "$name"; exit 1; fi; done`. Expected when any of the four is empty: that step exits 1 and the job does not sync
- [X] T012 [US1] In `.github/workflows/deploy.yml`, install mikefarah `yq` 4.54.1 and set `HUGO_VERSION` from `yq '.env.HUGO_VERSION' .github/workflows/ci.yml` into `$GITHUB_ENV`. Do not add a `HUGO_VERSION:` key. Install `hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz` and build with `hugo --gc --minify --panicOnWarning --baseURL "${SITE_URL}/"`. A non-zero build does not sync and does not invalidate
- [X] T013 [US1] In `.github/workflows/deploy.yml`, sync `public/` to `vars.BUCKET_NAME`. The only `--delete` is the first sync, which sets `public, max-age=3600`. Run `aws cloudfront create-invalidation --distribution-id "$DISTRIBUTION_ID" --paths "/*"`. The T011 guard has already exited 1 if `SITE_URL`, `BUCKET_NAME`, `DISTRIBUTION_ID`, or `AWS_ROLE_ARN` is empty, so this step does not sync in that case. Set the job output `site_url` from the shell variable `SITE_URL` with `echo "site_url=${SITE_URL}" >> "$GITHUB_OUTPUT"`, and print the same shell expansion with `echo "site_url=${SITE_URL}"`. Do not write `site_url=${{ vars.SITE_URL }}`. The workflow file contains `site_url=${SITE_URL}` and does not contain `site_url=${{ vars.SITE_URL }}`. `SITE_URL` has no trailing slash

**Checkpoint**: Staging updates on the merge to `develop`. Production updates when that commit is merged to `main`.

## Phase 4: User Story 2 - Staging stays out of search indexes (Priority: P2)

**Goal**: Staging sends crawlers away. Production does not. Neither site asks for a login.

**Independent Test**: The FR-005 commands in `spec.md` pass on staging and fail the `Disallow` and `X-Robots-Tag` greps on production. The header difference is the distribution from T007.

**Pull request**: `002-aws-deployment-t03`

- [X] T014 [US2] In `.github/workflows/deploy.yml`, after the Hugo build and before sync, overwrite `public/robots.txt`. Staging writes `User-agent: *` and `Disallow: /`. Production writes `User-agent: *` and `Allow: /`

**Checkpoint**: Staging is unlisted. Production is indexable. The `X-Robots-Tag` behavior is the distribution from T007.

## Phase 5: User Story 3 - Jorge can see cost and deploy again safely (Priority: P3)

**Goal**: Spend above 1 USD emails Jorge, and a removed page disappears on the next deploy.

**Independent Test**: The FR-012 budget commands in `spec.md` pass after T009. After T015, FR-016's three Cache-Control values match. The `t03` row's `head-object` command fails for the removed page, `curl` does not return that page, and the deploy log contains `site_url=${SITE_URL}`.

**Pull request**: `002-aws-deployment-t03`

- [X] T015 [US3] In `.github/workflows/deploy.yml`, after the single `--delete` sync, copy without `--delete`: `public, max-age=0, must-revalidate` for `*.html`, `*.xml`, `*.json`, and `robots.txt`, and `public, max-age=31536000, immutable` when the key matches `\.[0-9a-f]{8,}\.` and is not one of those four names. A name that matches both uses the short header. `aws s3 cp` uses `--metadata-directive REPLACE`

**Checkpoint**: The budget from T005 is unchanged. Deploys remove objects that the build no longer contains.

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Record that the feature matches the spec after both sites and the required checks are in place.

**Pull request**: `002-aws-deployment-t04` (the last implementation pull request)

- [ ] T016 Run the FR-020 protection commands in `spec.md` and write `specs/002-aws-deployment/converge.md` with that output for `develop` and `main`, the date, the full SHA of the commit it ran on, and the verdict `Converged`. Paste the verdict in the pull request description

**Checkpoint**: QA can block the pull request if `converge.md` is missing or the verdict is not `Converged`.

## Dependencies & Execution Order

### Phase Dependencies

- Phase 1 (`t01`) starts after this plan pull request is merged.
- Phase 2 (`t02`) depends on `t01` on `develop` and on the `terraform` job having reported. It blocks deploy.
- Phases 3, 4, and 5 ship together as `t03` after `t02`.
- Phase 6 (`t04`) depends on `t03` and on both hostnames serving. Protection is already on from T009. `t04` records it.

### User Story Dependencies

- User Story 1 depends on the stacks and the variables from Phase 2.
- User Story 2 depends on the distributions from T007 and on the deploy workflow.
- User Story 3's budget exists after T005. Its cache and delete behavior depends on T013 and T015.

### Parallel Opportunities

- T003, T004, T005, T006, and T007 touch different Terraform files and can be written in parallel inside `t02`. T003 also edits the plan inits in `.github/workflows/terraform.yml`. No other task in `t02` edits that file.
- T008 waits until those Terraform files exist, because it writes the lock files.
- T011 through T015 all edit `.github/workflows/deploy.yml`, so they stay in one sequence inside `t03`.

## Parallel Example: Foundational

```bash
# Different files, same pull request 002-aws-deployment-t02:
# T003 infra/shared backend
# T004 infra/shared IAM
# T005 infra/shared budget
# T006 infra/shared/terraform.tfvars.example
# T007 infra/site
```

## Implementation Strategy

### MVP First

1. Merge `t01` (T001–T002). The `terraform` check reports without a plan.
2. Jorge confirms the job has completed on `develop`.
3. Merge is not yet allowed for `t02`. Open `t02` (T003–T010). Jorge bootstraps from that head, sets `AWS_PLAN_ROLE_ARN`, saves branch protection, re-runs `terraform`, and merges only a green plan.
4. Merge `t03` (T011–T015). Staging deploys from `develop`. Production deploys when Jorge merges that release to `main`.
5. Merge `t04` (T016). `converge.md` says `Converged`.

### Incremental Delivery

`t01` makes the required check able to report. `t02` makes the infrastructure real and is the only bootstrap. `t03` is the first visitor-visible deploy. `t04` does not add infrastructure.

## Notes

- [P] tasks use different files and do not depend on an unfinished task.
- Mark an id `[X]` only in the implementation pull request that closes it.
- Do not edit `spec.md` or `plan.md` in an implementation pull request.
- An outputs-only plan is re-applied locally. It is not a bypass.

## Phase 7: Convergence

- [ ] T017 In a later pull request `002-aws-deployment-t06`, write `specs/002-aws-deployment/converge.md`. FR-020 reuses Jorge's admin reading from 2026-10-22 at 13:24 Europe/Madrid (11:24 UTC), the same for `develop` and for `main`: `{"checks": ["hugo","lychee","gitleaks","terraform"], "enforce_admins": true}`, from `gh api repos/JLaborda/web-portfolio/branches/$b/protection --jq '{checks: .required_status_checks.contexts, enforce_admins: .enforce_admins.enabled}'`. US3/AC2, US3/AC3, and SC-002 use the T018 evidence plus the `site_url=` lines from staging deploy run `39765229871` (`site_url=https://d27iuevzdct8et.cloudfront.net`) and production deploy run `39768850371` (`site_url=https://d3kitcqjidoveq.cloudfront.net`)
- [ ] T018 Run the page-removal cycle on staging. One pull request adds `content/posts/spec-002-remove.md`, merges to `develop`, deploys staging, and records curl HTTP 200 for that page next to `aws s3api head-object --bucket "$BUCKET_NAME" --key posts/spec-002-remove/index.html` exit 0, and record that `posts/spec-002-remove/index.html` exists. A second pull request deletes `content/posts/spec-002-remove.md`, merges to `develop`, and deploys staging. Jorge runs `head-object` locally with his own credentials, as in T010. This task does not change `.github/workflows/deploy.yml`. Then `if aws s3api head-object --bucket "$BUCKET_NAME" --key posts/spec-002-remove/index.html; then exit 1; fi` and `if curl -fsS "${SITE_URL}/posts/spec-002-remove/" | grep -F 'spec-002-remove'; then exit 1; fi`. Expected: `head-object` fails, so the key is gone, and `curl` does not return the old page. The run ids and `site_url=` lines are recorded in each t05 pull request body. The staging deploy log line `delete: s3://.../spec-002-remove...` from `aws s3 sync --delete` is recorded in the deletion t05 pull request body, with the bucket name and any account id redacted
