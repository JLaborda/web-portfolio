# Data Model: AWS Deployment

Entities from [spec.md](./spec.md). Field constraints are the ones the spec states.

## Environment

Two values only: `staging`, `production`.

| Field | Constraint |
|-------|------------|
| Branch | `staging` deploys from `develop`. `production` deploys from `main`. A pull request deploys neither. |
| Bucket | `web-portfolio-staging-<account-id>` or `web-portfolio-production-<account-id>`. Region `eu-west-1`. Not a website endpoint. |
| Block Public Access | All four flags true: `BlockPublicAcls`, `IgnorePublicAcls`, `BlockPublicPolicy`, `RestrictPublicBuckets`. |
| Distribution | Own distribution. `PriceClass_100`. `DefaultRootObject` `index.html`. `ViewerProtocolPolicy` `redirect-to-https`. `OriginAccessControlId` non-empty. |
| Hostname | `*.cloudfront.net` only. No custom domain. |
| Deploy role | `web-portfolio-staging-deploy` or `web-portfolio-production-deploy`. |
| GitHub Environment | `staging` (branch policy `develop` only) or `production` (branch policy `main` only). `wait_timer` 0. No required reviewers. |

A staging apply does not read production state. `infra/site` outputs `distribution_id`, `distribution_arn`, `bucket_name`, and `domain_name` for the environment it was applied to. Bootstrap copies those into the GitHub Environment variables.

## State bucket

| Field | Constraint |
|-------|------------|
| Name | `web-portfolio-tfstate-<account-id>` |
| Account id | 12 digits from `aws sts get-caller-identity --query Account --output text` |
| Region | `eu-west-1`, with `LocationConstraint` set at create time |
| Versioning | Enabled |
| Encryption | SSE-S3 `AES256`, `BucketKeyEnabled` true |
| Block Public Access | All four flags true |
| Created by | AWS CLI during bootstrap. The Terraform that stores state here does not create this bucket. |
| Keys | `shared/terraform.tfstate`, `staging/terraform.tfstate`, `production/terraform.tfstate` |
| Lock | `use_lockfile = true`. Lock object is `<key>.tflock`. Plan does not write it (`-lock=false`). |

## Budget

One account-level budget. Not one per environment.

| Field | Constraint |
|-------|------------|
| Name | `web-portfolio-monthly` |
| Limit | Amount `1`, unit `USD`, time unit `MONTHLY` |
| Notification | Type `ACTUAL`, comparison `GREATER_THAN`, threshold `100`, threshold type `PERCENTAGE` |
| Subscriber | Email equal to `TF_VAR_budget_alert_email`. Not committed. |
| Committed example | `infra/shared/terraform.tfvars.example` sets `budget_alert_email` to `replace-me@example.com` and is the only committed assignment. |

## IAM roles

No IAM user. No access key.

The OIDC provider is `https://token.actions.githubusercontent.com`, audience `sts.amazonaws.com`. Trust policies use prefix `repo:JLaborda@15078416/web-portfolio@1427090788`.

| Role | Subject | Ref | Allowed | Forbidden |
|------|---------|-----|---------|-----------|
| `web-portfolio-plan` | `:pull_request` | none | Read state. Read APIs required to plan this configuration. | `s3:PutObject`, `s3:DeleteObject`, `cloudfront:CreateInvalidation`, `cloudfront:UpdateDistribution`, `iam:CreateRole`, `iam:PutRolePolicy`, `budgets:ModifyBudget` |
| `web-portfolio-staging-deploy` | `:environment:staging` | `refs/heads/develop` | `s3:ListBucket`, `s3:GetObject`, `s3:PutObject`, `s3:DeleteObject` on the staging site bucket only. `cloudfront:CreateInvalidation` on the staging distribution only. | IAM, budgets, the state bucket, distribution configuration, and the production bucket. |
| `web-portfolio-production-deploy` | `:environment:production` | `refs/heads/main` | The same actions on the production bucket and distribution only. | IAM, budgets, the state bucket, distribution configuration, and the staging bucket. |

A deploy role cannot apply Terraform.

## Deploy variables

GitHub Actions variables, not secrets. One set per environment. Jorge sets them after apply. `SITE_URL` has no trailing slash.

| Name | Example shape |
|------|----------------|
| `AWS_ROLE_ARN` | ARN of that environment's deploy role |
| `SITE_URL` | `https://<id>.cloudfront.net` |
| `BUCKET_NAME` | `web-portfolio-<environment>-<account-id>` |
| `DISTRIBUTION_ID` | CloudFront distribution id |

## Plan variable

| Name | Scope | Empty behavior |
|------|--------|----------------|
| `AWS_PLAN_ROLE_ARN` | Repository variable. Not an environment variable and not a secret. Set without `--env`. | Empty skips plan only when `git ls-tree -d` of the base SHA for `infra` prints nothing. Empty fails the job when that tree exists. Non-empty runs plan. Whitespace is stripped before the test. |

## URL rewrite

Viewer-request function, evaluated in order:

| Request URI | Object key |
|-------------|------------|
| `/` | `index.html` |
| Ends with `/` | Append `index.html` |
| Last segment contains no `.` | Append `/index.html` |
| Last segment contains `.` | Unchanged, so `/index.xml` and `/index.json` stay |

## Cache-Control

| Object | Header |
|--------|--------|
| `*.html`, `*.xml`, `*.json`, `robots.txt` | `public, max-age=0, must-revalidate` |
| Key matches `\.[0-9a-f]{8,}\.` and is not one of the four names above | `public, max-age=31536000, immutable` |
| Every other object | `public, max-age=3600` |

The one-hour value is the only sync that passes `--delete`. A name that is both HTML and hashed uses the short header.

## Robots

| Environment | `robots.txt` | `X-Robots-Tag` |
|-------------|--------------|----------------|
| staging | `User-agent: *` and `Disallow: /` | `noindex` |
| production | `User-agent: *` and `Allow: /` | header not sent |

Neither site requires authentication.
