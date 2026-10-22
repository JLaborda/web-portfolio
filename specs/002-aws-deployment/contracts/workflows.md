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
| Conditional `if` | `steps.paths.outputs.infra == 'true'` on every step that runs Terraform, tflint, or the plan script. No second `if`. No `continue-on-error`. |
| Assume | Inside the plan script, only when `AWS_PLAN_ROLE_ARN` is non-empty. The script requests the GitHub OIDC token with audience `sts.amazonaws.com` from `ACTIONS_ID_TOKEN_REQUEST_URL` and `ACTIONS_ID_TOKEN_REQUEST_TOKEN`, writes the JWT to a file, and exports `AWS_ROLE_ARN` and `AWS_WEB_IDENTITY_TOKEN_FILE`, or calls `aws sts assume-role-with-web-identity`. No `configure-aws-credentials` step. |
| Plan | `(cd "$d" && terraform plan -lock=false -input=false -no-color)` for shared, then the same command with `-var environment=staging` and `-var environment=production`. |
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
| Output | Job output `site_url` equals `SITE_URL`. The log prints `echo "site_url=${SITE_URL}"` from the shell variable. The file does not contain `site_url=${{ vars.SITE_URL }}`. |

A non-zero Hugo exit skips sync and invalidation.
