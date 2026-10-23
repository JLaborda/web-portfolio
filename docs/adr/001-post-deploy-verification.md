# ADR 001: Post-deploy verification in CI with the existing OIDC role and a read-only admin token for branch protection

**Status**: Proposed

**Date**: 2026-10-23

## Context

Jorge verifies each deploy by hand. The deploy workflow assumes an existing OIDC role and publishes the site, and no later job checks the objects or the public URL. Agents that work in this repository have no long-lived AWS keys. Constitution III forbids those keys.

A read of branch protection with the credential available to this repository's automation returns HTTP 403. On 2026-10-23, `GET /repos/JLaborda/web-portfolio/branches/develop/protection` returned 403 with the message `Resource not accessible by integration`. The four required status checks and `enforce_admins` can be read only with a credential GitHub treats as an administrator. `GITHUB_TOKEN` is not that credential.

The deploy roles in `infra/shared` already allow `s3:GetObject` on each environment's objects and `s3:ListBucket` on each environment's bucket. Those two actions are what `aws s3api head-object` needs, including a `404 Not Found` for a missing key. This decision does not add an IAM action.

## Decision

After each deploy to staging (`develop`) and production (`main`), a job in `.github/workflows/deploy.yml` assumes that environment's existing deploy role through GitHub OIDC and checks the published artifacts and the public URL. The job writes a summary and comments on the pull request whose merge produced the commit. The comment token is `GITHUB_TOKEN` with `pull-requests: write` on that job only.

A second workflow reads branch protection for `develop` and `main` on a weekly schedule and on `workflow_dispatch`. It writes the result to the job summary. It does not change protection. The credential for that read is open: the recommended choice is a fine-grained personal access token with Administration read-only on this repository only, stored as a repository secret that Jorge creates. A GitHub App with Administration read is the other option. Spec 005 records both and does not pretend the choice is made.

The check runs only after spec 002 FR-022 has taught the deploy job to wait for the CloudFront invalidation. That requirement is open pull request #35.

## Consequences

- A mismatch fails the deploy run. Jorge is no longer the person who runs `head-object` after a normal deploy.
- Jorge still creates the branch-protection read secret. That step is `needs-human`. He does not create an AWS access key for this feature.
- The implementation pull request does not edit `infra/`. It does not rename `web-portfolio-staging-deploy`, `web-portfolio-production-deploy`, or `cloudfront-create-invalidation`.
- The weekly job is not added to the required status checks. Adding it would change branch protection, which this decision does not do.
- A leaked option-A token can read administration metadata for this repository only. It cannot deploy, and a read-only Administration permission cannot change protection.
- Until FR-022 is implemented, a check that ran at the end of today's deploy job would race the invalidation. The implementation waits for that requirement.

## Alternatives

- A new read-only IAM role for object checks. Rejected. The existing deploy role already has the two S3 actions, on that environment's bucket only, and a new role would be a new AWS identity.
- Long-lived AWS keys in GitHub secrets. Rejected. Constitution III forbids them.
- Using `GITHUB_TOKEN` to read branch protection. Rejected. The API returns 403 for that token.
- A GitHub App (option B). Acceptable, and heavier than a single read-only token. Left open for Jorge.
