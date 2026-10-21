# Implementation Plan: AWS Deployment

**Branch**: `002-aws-deployment` | **Date**: 2026-10-21 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/002-aws-deployment/spec.md`

## Summary

Publish the Hugo site to AWS. Staging deploys on every push to `develop`. Production deploys on every push to `main`. Each environment is a private S3 bucket and a CloudFront distribution in `eu-west-1`, served on that distribution's `*.cloudfront.net` hostname. Jorge applies Terraform locally with SSO. GitHub Actions never runs `terraform apply`.

`/speckit-clarify` on this plan step found no new questions. The spec merged in pull request #11 (`5ceda20`) already records Jorge's decisions. This plan resolves the notes QA carried forward from that pull request: how deploy reads `HUGO_VERSION`, how `infra/site` is planned per environment, the IAM simulation checks, the region and DNS record below, workflow permissions, the paths-filter `if`, and the order of the task pull requests.

## Region and DNS

Jorge approved both on 2026-10-21, in the spec that pull request #11 merged:

- **Region**: `eu-west-1`. The state bucket, both site buckets, and both distributions are created there. This feature does not use a second region.
- **DNS**: no custom DNS. Each environment's public URL is the CloudFront default hostname (`*.cloudfront.net`). This feature creates no ACM certificate and no Route 53 record. A later feature that adds a custom domain requests its ACM certificate in `us-east-1`.

## Technical Context

**Language/Version**: Terraform 1.16.6. AWS provider `hashicorp/aws` 6.69.1. tflint 0.64.0 with AWS ruleset 0.49.0. Hugo extended is the single `HUGO_VERSION` already in `.github/workflows/ci.yml` (0.145.0). This feature does not add a second `HUGO_VERSION:` key.

**Primary Dependencies**: `actions/checkout` `3d3c42e5aac5ba805825da76410c181273ba90b1` (v7.0.1). `aws-actions/configure-aws-credentials` `e1253824e5c10ff9df46874f81ed3ec929e19cfd` (v6.3.0) on the deploy job only. mikefarah `yq` 4.54.1 in the deploy job, used only to read `.env.HUGO_VERSION` from `ci.yml`.

**Storage**: Remote Terraform state in one S3 bucket, three keys, `use_lockfile = true`. Site files in two private buckets. No DynamoDB table.

**Testing**: The Verification commands in [spec.md](./spec.md). No separate test framework. `tasks.md` adds `aws iam simulate-principal-policy` for FR-011, one action and one resource ARN per call.

**Target Platform**: GitHub Actions `ubuntu-latest` for plan and deploy. Jorge's machine, with his existing SSO profile, for bootstrap and `terraform apply`.

**Project Type**: Static site plus Terraform. The Hugo tree from feature 001 stays at the repository root.

**Performance Goals**: SC-001: the site answers over HTTPS within one minute of a successful deploy. No other latency target.

**Constraints**: English only. No IAM users. No long-lived access keys. No committed email. Budget 1 USD per month, email only when actual spend is greater than 1 USD. Actions never runs `terraform apply`. Expected monthly cost stays inside 0–1 USD.

**Scale/Scope**: Two environments, one shared stack, one budget, two workflows (`terraform.yml`, `deploy.yml`).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Gate | Result |
|-----------|------|--------|
| I. Spec-driven, PO approval | `spec.md` is on `develop` as `Status: Approved by Jorge — PR #11` (merge `5ceda20`). This pull request is the plan step. It does not edit `spec.md` or `checklists/requirements.md`. Custom checklist items stay unchecked for QA. | Pass |
| II. Fixed stack | Hugo stays the feature 001 pin. This plan does not edit `themes/PaperMod`, `layouts/`, or `assets/`. | Pass |
| III. AWS hosting | Private buckets, Block Public Access, CloudFront OAC, Terraform remote state, GitHub OIDC, no long-lived keys. The plan role is `web-portfolio-plan` (`pull_request` only). Each environment has its own deploy role, restricted by its GitHub Environment and branch ref. Those two deploy roles are the constitution's apply/deploy side, split so staging cannot write production. No ACM certificate is created. Region `eu-west-1` and no custom DNS are recorded above with Jorge's approval. | Pass |
| IV. Verifiable CI | `terraform.yml` runs on every pull request to `develop` and `main`, with no workflow-level `paths:` filter. On a Terraform change it runs fmt, validate, tflint, and plan with `-no-color`. `develop` and `main` gain required check `terraform` before the first `infra/` pull request merges, beside `hugo`, `lychee`, and `gitleaks`. `enforce_admins` is true. | Pass |
| V. Scoped PRs | Four implementation branches, `002-aws-deployment-t01` through `t04`, listed in [tasks.md](./tasks.md). `t01` lands `terraform.yml` with no `infra/` tree. `t02` is the first `infra/` pull request. `t04` commits `converge.md`. | Pass |
| VI. Explainable and cheap | Services are S3, CloudFront (`PriceClass_100`), IAM OIDC, and one AWS Budget. No WAF, no analytics, no second region. Expected monthly cost is **0–1 USD**. The budget emails only above 1 USD. | Pass |
| VII. English | Plan, research, data model, contracts, quickstart, tasks, and the checklist are English. | Pass |

No gate fails. Complexity tracking is empty.

## Project Structure

### Documentation (this feature)

```text
specs/002-aws-deployment/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── hosting.md
│   ├── iam.md
│   └── workflows.md
├── checklists/
│   ├── requirements.md      # already on develop; this pull request does not edit it
│   └── review.md            # /speckit-checklist; items stay unchecked
├── tasks.md
└── converge.md              # written by t04, not by this plan
```

### Source Code (repository root)

```text
.github/workflows/
├── ci.yml                   # feature 001; this feature only reads env.HUGO_VERSION
├── terraform.yml            # t01
└── deploy.yml               # t03
.gitignore                   # t01 adds the Terraform ignore lines
infra/
├── shared/                  # t02: OIDC, three roles, one budget
│   ├── terraform.tfvars.example
│   └── .tflint.hcl
└── site/                    # t02: bucket, OAC, distribution, function, headers policy
    └── .tflint.hcl
```

**Structure Decision**: Hugo stays at the repository root. Terraform lives under `infra/` and is applied from Jorge's machine. `t01` does not create `infra/`.

## Design

### State

One bucket, `web-portfolio-tfstate-<account-id>`, created by the AWS CLI during bootstrap, not by the Terraform that stores state in it. Versioning, SSE-S3 AES256, BucketKeyEnabled, all four Block Public Access flags, region `eu-west-1`. Backend `use_lockfile = true`. Keys:

| Stack | Key | Who applies |
|-------|-----|-------------|
| `infra/shared` | `shared/terraform.tfstate` | Jorge, once |
| `infra/site` staging | `staging/terraform.tfstate` | Jorge, with `-var environment=staging` |
| `infra/site` production | `production/terraform.tfstate` | Jorge, with `-var environment=production` |

A staging apply does not read production state. Plan and the real `init` pass `-lock=false`, so the plan role never writes the lock object. Validate uses `init -backend=false`.

### Plan command

Validate keeps the spec's `-chdir` form, because FR-006 runs `terraform -chdir=infra/shared validate` and `terraform -chdir=infra/site validate` on the workstation.

Plan in CI does not use `-chdir`. Inside the single `terraform` job, after the role is assumed, the script runs this command once for shared and once per site environment:

```bash
(cd "$d" && terraform plan -lock=false -input=false -no-color)
```

The site rows append `-var "environment=${environment}"`. `init` is a separate line before that command, with `-input=false -lock=false -reconfigure -backend-config="key=${key}"`. The workflow file contains the `(cd "$d" && …)` string. It does not contain `No changes. Your infrastructure` or `Plan: N to add,`.

This is a matrix of three rows inside one job. It is not a GitHub Actions `strategy.matrix`. A strategy matrix would rename the job and break the spec's single job name `terraform`.

| Directory | Backend key | Extra plan argument |
|-----------|-------------|---------------------|
| `infra/shared` | `shared/terraform.tfstate` | none |
| `infra/site` | `staging/terraform.tfstate` | `-var environment=staging` |
| `infra/site` | `production/terraform.tfstate` | `-var environment=production` |

Three summaries still satisfy FR-021, which requires a count of at least 2. `-no-color` is on every plan. FR-021 still strips ANSI with `sed -E 's/\x1b\[[0-9;]*m//g'` before the grep.

The plan step's only `if` is `steps.paths.outputs.infra == 'true'`. The script assumes `web-portfolio-plan` itself when the variable is set. There is no second `if` on `AWS_PLAN_ROLE_ARN`, because the spec's `yq` check requires every conditional step to use that one expression. The job sets no GitHub Environment, so the OIDC subject stays `:pull_request`.

### Deploy reads Hugo

`deploy.yml` has no line matching `^[[:space:]]*HUGO_VERSION:`. The job installs mikefarah `yq` 4.54.1 and runs:

```bash
hugo_version=$(yq '.env.HUGO_VERSION' .github/workflows/ci.yml)
test -n "$hugo_version"
echo "HUGO_VERSION=${hugo_version}" >> "$GITHUB_ENV"
```

The install URL then uses `hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz`. The repository-wide count of YAML keys `HUGO_VERSION:` stays 1, the key in `ci.yml`.

### Workflow permissions and order

Both new workflows set:

```yaml
permissions:
  id-token: write
  contents: read
```

`t01` merges `.github/workflows/terraform.yml` and the `.gitignore` lines. It does not add `infra/`. The job reports success because the paths filter sets `infra=false`. After that job has completed at least once on `develop`, and before `t02` merges, Jorge runs the spec's `gh api -X PUT` protection command.

`t02` is the pull request that first adds `infra/`. Jorge runs Bootstrap from that head, sets `AWS_PLAN_ROLE_ARN` last, re-runs `terraform`, and merges only when FR-021 passes. He does not merge a skipped plan and does not bypass. The later pull request into `main` is not a second bootstrap.

### IAM simulation

After Bootstrap creates the three roles, `t02` runs `aws iam simulate-principal-policy` once per action, with exactly one `--resource-arns` value. The commands are in [tasks.md](./tasks.md). A decision of `allowed` on a forbidden action fails the task. Passing more than one resource ARN in one call is not the proof: the API returns the most restrictive decision across those ARNs.

## Complexity Tracking

No constitution violations require justification.

## Post-design Constitution Check

Phase 1 adds no service outside principle III, no second Hugo pin, no theme edit, and no implementation pull request. The gates above still pass. Region and DNS remain the values Jorge approved on 2026-10-21.
