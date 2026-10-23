# ADR 001: Post-deploy verification in CI with the existing OIDC role and a read-only token for branch protection

**Status**: Accepted — PR #36 (Jorge's merge of that pull request accepts it)

**Date**: 2026-10-23

**Feature**: [specs/005-deploy-verification](../../specs/005-deploy-verification/spec.md)

## Context

Jorge verifies each deploy by hand. The deploy workflow assumes an existing OIDC role and publishes the site, and no later job checks the objects or the public URL. Agents that work in this repository have no long-lived AWS keys. Constitution III forbids those keys.

A read of branch protection with the credential available to this repository's automation returns HTTP 403. On 2026-10-23, `GET /repos/JLaborda/web-portfolio/branches/develop/protection` returned 403 with the message `Resource not accessible by integration`. The four required status checks and `enforce_admins` can be read only with a credential GitHub treats as an administrator. `GITHUB_TOKEN` is not that credential.

The deploy roles in `infra/shared` already allow `s3:GetObject` on each environment's objects and `s3:ListBucket` on each environment's bucket. Those two actions are what `aws s3api head-object` needs, including a `404 Not Found` for a missing key. This decision does not add an IAM action.

## Decision

After each deploy to staging (`develop`) and production (`main`), a job `verify` in `.github/workflows/deploy.yml` assumes that environment's existing deploy role through GitHub OIDC and checks the published artifacts for the push range (`$BEFORE..$GITHUB_SHA`) and the public URL. It writes a summary and comments on the pull request whose merge produced the commit. The comment token is `GITHUB_TOKEN` with `pull-requests: write` on that job only.

A second workflow, `.github/workflows/branch-protection.yml`, reads branch protection for `develop` and `main` weekly and on `workflow_dispatch`. It writes the result to the job summary and does not change protection. The credential is option A: a fine-grained personal access token with Administration: Read-only on this repository only, stored as the repository secret `BRANCH_PROTECTION_READ_TOKEN`. Jorge created that secret on 2026-10-23.

`verify` runs with `needs: deploy`. Spec 002 FR-022 (merged in PR #35) makes the deploy job wait for the CloudFront invalidation, so verification starts only after that wait. The implementation waits until that `deploy.yml` change is on `develop`.

## Consequences

- A mismatch fails the deploy run. Jorge is no longer the person who runs `head-object` after a normal deploy.
- The implementation pull request does not edit `infra/`. It does not rename `web-portfolio-staging-deploy`, `web-portfolio-production-deploy`, or `cloudfront-create-invalidation`.
- The weekly job is not added to the required status checks. Adding it would change branch protection, which this decision does not do.
- A leaked token can read administration metadata for this repository only. It cannot deploy, and a read-only Administration permission cannot change protection. When it expires, the weekly run fails, which is the signal to replace it.
- Scheduled and dispatched workflows run from the default branch, so the first live branch-protection read happens after the next release to `main`.

## Alternatives

- A new read-only IAM role for object checks. Rejected. The existing deploy role already has the two S3 actions, on that environment's bucket only, and a new role would be a new AWS identity.
- Long-lived AWS keys in GitHub secrets. Rejected. Constitution III forbids them.
- Using `GITHUB_TOKEN` to read branch protection. Rejected. The API returns 403 for that token.
- A GitHub App with Administration read (option B). Rejected for now: heavier to set up than one read-only token for a single repository.
