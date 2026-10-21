# Contract: Workflows

Two new workflow files. Feature 001's `.github/workflows/ci.yml` is read and not rewritten.

## `terraform.yml`

| Field | Value |
|-------|--------|
| On | `pull_request` to `develop` and `main`. No `paths` filter. |
| Job name | `terraform` only. Not a strategy matrix. |
| Permissions | `id-token: write`, `contents: read` |
| Environment | None |
| Checkout | `actions/checkout` at `3d3c42e5aac5ba805825da76410c181273ba90b1`, `fetch-depth: 0`, `ref` `github.event.pull_request.head.sha` |
| Paths step id | `paths`. Output `infra` is `true` or `false`. |
| Conditional `if` | `steps.paths.outputs.infra == 'true'` on fmt, validate, tflint, and the plan script. The assume step's `if` is `steps.paths.outputs.infra == 'true' && vars.AWS_PLAN_ROLE_ARN != ''`. No `continue-on-error`. |
| Assume | `aws-actions/configure-aws-credentials` at `e1253824e5c10ff9df46874f81ed3ec929e19cfd`, `role-to-assume` `${{ vars.AWS_PLAN_ROLE_ARN }}`, audience `sts.amazonaws.com`, region `eu-west-1`. |
| Plan | `(cd "$d" && terraform plan -lock=false -input=false -no-color)` for shared, then the same command with `-var environment=staging` and `-var environment=production`. Env `TF_VAR_budget_alert_email` is the repository secret of that name. |
| Forbidden text | The file contains neither `terraform apply` nor `No changes. Your infrastructure` nor `Plan: N to add,`. |

When `infra` is `false`, the Terraform steps are skipped and the job succeeds. The notice skip and the error exit are the spec's FR-017 branches.

## `deploy.yml`

| Field | Value |
|-------|--------|
| On | `push` to `develop` and `main`. No `pull_request` trigger. |
| Job name | `deploy` |
| Permissions | `id-token: write`, `contents: read` |
| Environment | `staging` when the ref is `develop`, `production` when the ref is `main` |
| Credentials | `aws-actions/configure-aws-credentials` at `e1253824e5c10ff9df46874f81ed3ec929e19cfd`, region `eu-west-1`, role `vars.AWS_ROLE_ARN` |
| Hugo | `yq '.env.HUGO_VERSION' .github/workflows/ci.yml` into `$GITHUB_ENV`. No `HUGO_VERSION:` key in this file. |
| Build | `hugo --gc --minify --panicOnWarning --baseURL "${SITE_URL}/"` |
| Publish | `aws s3 sync` with `--delete` once, then cache copies without `--delete`, then `aws cloudfront create-invalidation --paths "/*"` |
| Output | Job output `site_url` equals `SITE_URL` |

A non-zero Hugo exit skips sync and invalidation.
