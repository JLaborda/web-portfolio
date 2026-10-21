# Quickstart: AWS Deployment

Validation guide for a reviewer. Commands and expected results are the Verification section of [spec.md](./spec.md). This file only says when to run which block. It is not the implementation.

## Before any task pull request

```bash
git merge-base --is-ancestor origin/develop HEAD
```

Expected: exit 0. The branch contains merge `5ceda20` and `.github/workflows/ci.yml`.

`/speckit-clarify` for this plan asked no new questions. Do not open a second clarification session unless a later review changes a requirement.

## After `t01` (workflow only)

`infra/` does not exist. Run the FR-017 block in the spec against `.github/workflows/terraform.yml`. Also:

```bash
grep -F '(cd "$d" && terraform plan -lock=false -input=false -no-color)' .github/workflows/terraform.yml
yq -e '.jobs.terraform.permissions."id-token" == "write" and .jobs.terraform.permissions.contents == "read"' .github/workflows/terraform.yml
test "$(yq '.jobs | keys | length' .github/workflows/terraform.yml)" = "1"
if grep -F 'terraform apply' .github/workflows/terraform.yml; then exit 1; fi
```

Expected: the spec's FR-017 checks pass, the `cd` grep exits 0, `yq -e` prints `true`, the key count is 1, and the apply guard exits 0. The pull request's Actions run shows job `terraform` green without a plan, because `infra/**` did not change.

Do not merge `t02` until that job has completed once on `develop` and Jorge has saved branch protection.

## After Bootstrap on the `t02` head

Run FR-006, FR-007, FR-008, FR-009, FR-010, FR-011, FR-012, FR-013, and FR-019 from the spec. Then run the `aws iam simulate-principal-policy` table in [tasks.md](./tasks.md). Then re-run `terraform` and run the FR-021 block. A log that shows only `Changes to Outputs:` is not a pass. Apply again locally and re-run. Do not bypass.

## After `t03` deploys

On staging first (the push to `develop`). Repeat on production after Jorge merges that release to `main`.

Run FR-001, FR-002, FR-003, FR-004, FR-005, FR-014, FR-015, FR-016, and FR-018 from the spec. `SITE_URL` has no trailing slash. The Hugo key count is still 1.

## After `t04`

`specs/002-aws-deployment/converge.md` contains the FR-020 protection output for `develop` and `main`, the date, the SHA it ran on, and the verdict `Converged`.
