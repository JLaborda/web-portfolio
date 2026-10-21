# Research: AWS Deployment

Decisions for feature 002. The governing text is `spec.md` as merged to `develop` in pull request #11 (`5ceda20`). `/speckit-clarify` for this plan step asked no new questions.

## Region and DNS

- **Decision**: Region `eu-west-1`. DNS is the CloudFront default hostname only. No custom domain, no ACM certificate, no Route 53 record.
- **Rationale**: Jorge approved both on 2026-10-21. Constitution III requires the deployment plan to record them with his approval. The constitution does not itself fix the values. CloudFront still accepts a later certificate only from `us-east-1`; this feature creates none, so that rule is not exercised.
- **Alternatives considered**: A custom domain in this feature was rejected. An ACM certificate "just in case" was rejected because it would be a custom-domain resource the spec puts out of scope.

## Terraform, provider, lint, and state lock

- **Decision**: Terraform 1.16.6, AWS provider 6.69.1, tflint 0.64.0, AWS ruleset 0.49.0. S3 backend with `use_lockfile = true`. No DynamoDB lock table.
- **Rationale**: These are the pins in FR-006 and FR-017. Terraform 1.10 and later supports the S3 lock file. The object is `<key>.tflock`. Plan and real `init` pass `-lock=false`, so the read-only role needs no `s3:PutObject` on the lock.
- **Alternatives considered**: A DynamoDB lock table was rejected. It is a second service, and the plan role would need a write the constitution does not allow.

## Who applies

- **Decision**: Jorge applies with his existing SSO session. Both workflows omit the string `terraform apply`. CI plans with `web-portfolio-plan` only.
- **Rationale**: Apply credentials in Actions could destroy a bucket or a distribution. That was Jorge's decision on 2026-10-21.
- **Alternatives considered**: `terraform apply` from a protected environment was rejected for that reason.

## Three roles

- **Decision**: `web-portfolio-plan` trusts only `sub` `repo:JLaborda@15078416/web-portfolio@1427090788:pull_request`. `web-portfolio-staging-deploy` trusts `environment:staging` and `ref` `refs/heads/develop`. `web-portfolio-production-deploy` trusts `environment:production` and `ref` `refs/heads/main`. Audience `sts.amazonaws.com`. The prefix is the live immutable subject from `GET /repos/JLaborda/web-portfolio/actions/oidc/customization/sub` on 2026-10-21 (`use_immutable_subject: true`).
- **Rationale**: Constitution III requires a read-only plan role and a different apply/deploy role bound to a protected environment. Two environments need two deploy roles so staging cannot write the production bucket. "Two distinct roles" is plan versus deploy, not a cap of two role objects. The plan job does not set a GitHub Environment; a job that did would change `sub` to `:environment:NAME` and the plan trust would not match.
- **Alternatives considered**: One deploy role for both environments was rejected because least privilege would then allow each branch to write the other bucket. An IAM user with access keys was rejected.

## Plan invocation

- **Decision**: One job named `terraform`. Permissions `id-token: write` and `contents: read`. Every conditional step uses exactly `if: steps.paths.outputs.infra == 'true'`. The plan script assumes the role inline. It runs `(cd "$d" && terraform plan -lock=false -input=false -no-color)` for `infra/shared` and, with `-var environment=…` and `-backend-config key=…` on `init`, for staging and production. `-backend-config` is an `init` flag. Site inits also pass `-reconfigure`.
- **Rationale**: FR-017 fixes the `if` string so the `yq` uniqueness check holds. A GitHub Actions `strategy.matrix` would publish job names other than `terraform`, and FR-021 selects `.name == "terraform"`. Terraform 1.16.6 colors `Plan:` and `No changes.` when stdout is not a terminal; `-no-color` was confirmed on 2026-10-21, and the spec still strips ANSI before the grep. The `(cd "$d" && …)` form is the verification wording for plan. Validate stays on `-chdir` because FR-006's workstation commands use that form.
- **Alternatives considered**: `terraform -chdir="$d" plan` in CI was rejected for the plan step. `TF_CLI_ARGS_plan=-no-color` alone was rejected because the spec requires the flag on the plan command. A second `if` on the credentials action was rejected because it would fail the unique-`if` check.

## Hugo version in deploy

- **Decision**: The deploy job installs mikefarah `yq` 4.54.1 and writes `HUGO_VERSION` into `$GITHUB_ENV` from `yq '.env.HUGO_VERSION' .github/workflows/ci.yml`. `deploy.yml` contains no `HUGO_VERSION:` YAML key.
- **Rationale**: A workflow cannot read another workflow's `env` map. FR-015 forbids a second key. The spec's count is `grep -R -E '^[[:space:]]*HUGO_VERSION:' .github/workflows`, which stays 1 while the key lives only in `ci.yml`. `yq` 4.54.1 is the mikefarah build used to prove the spec's `yq -o=json | jq` check (`yq --arg` is not a mikefarah flag).
- **Alternatives considered**: Copying `HUGO_VERSION: "0.145.0"` into `deploy.yml` was rejected because the count would become 2. `yq --arg` was rejected because that flag does not exist on mikefarah yq.

## Budget email and cost

- **Decision**: One budget `web-portfolio-monthly`, 1 USD, monthly, notification `ACTUAL` `GREATER_THAN` 100 percent. The address is `TF_VAR_budget_alert_email` or an uncommitted tfvars file. The only committed assignment is `replace-me@example.com` in `infra/shared/terraform.tfvars.example`.
- **Rationale**: US3 and SC-004 say greater than 1 USD. `GREATER_THAN` does not fire when spend equals 1 USD. Expected hosting cost is inside 0–1 USD (`PriceClass_100`, no WAF). Principle VI needs no exception.
- **Alternatives considered**: A threshold of `GREATER_THAN_OR_EQUAL` was rejected because it would email at exactly 1 USD.

## Cache and pretty URLs

- **Decision**: One `aws s3 sync --delete` sets `public, max-age=3600`. Later `aws s3 cp` calls, without `--delete`, set `public, max-age=0, must-revalidate` on `*.html`, `*.xml`, `*.json`, and `robots.txt`, and `public, max-age=31536000, immutable` when the key matches `\.[0-9a-f]{8,}\.` and is not one of those names. HTML wins when a name matches both. A viewer-request CloudFront Function rewrites `/`, URIs ending in `/`, and extension-less last segments to `index.html`. Keys whose last segment contains `.` are unchanged.
- **Rationale**: OAC uses the S3 REST endpoint, which does not append index documents. A `--delete` sync that excluded HTML would delete those objects. FR-004 and FR-016 fix both.
- **Alternatives considered**: S3 website hosting was rejected because the bucket must not be public.

## First-infra merge order

- **Decision**: `terraform.yml` merges in `t01` with no `infra/` tree. Protection is turned on after that job has reported and before `t02` merges. `t02` contains both `infra/shared` and `infra/site`. Bootstrap, including the repository variable `AWS_PLAN_ROLE_ARN`, runs from the `t02` head. Merge waits for a green latest attempt whose stripped log has at least two Terraform summaries and whose annotations have no skip and no failure. An outputs-only plan (`Changes to Outputs:`) is fixed by applying again locally, not by a bypass.
- **Rationale**: FR-019, FR-020, and FR-021. If `terraform.yml` and `infra/` landed in one pull request, protection could not be on before that merge, and the required check would not yet exist on `develop`.
- **Alternatives considered**: Skipping plan whenever the variable is empty was rejected. It would let every later infra pull request pass without a plan.
