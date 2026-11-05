# Tasks: Custom Domain jlaborda.com

Status: Approved by Jorge — PR #71

**Input**: Design documents from `/specs/006-custom-domain/`

**Prerequisites**: plan.md, spec.md, checklists/requirements.md, [ADR 002](../../docs/adr/002-custom-domain.md)

**Tests**: No test framework. Each implementation pull request runs the Verification named for it in `spec.md`.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: User story label.
- Every description names a file path.

On every implementation branch, before Spec Kit scripts, export `SPECIFY_FEATURE_DIRECTORY=specs/006-custom-domain`.

## Implementation pull requests

One task (or cohesive pair) per pull request, merged one at a time into `develop`. Each lists its task ids and marks them `[X]` here. Infra tasks start only after issue #46 T011 is merged. `needs-human` applies to DNS/ACM/cost changes; Jorge merges those. Converge title is exactly `chore(006): converge`.

| Branch | Task | Requirements | needs-human | Depends on | Verification |
|--------|------|--------------|-------------|------------|--------------|
| `006-custom-domain-t01` | T001 | FR-001, FR-002, FR-003, FR-004, FR-005, FR-008 | Yes: DNS, ACM, custom domain, AWS cost | This `docs:` PR merged; #46 T011 merged; Jorge's step 1 (domains Active) | `terraform plan` for production shows aliases, ACM, records, function; no zone create/register resources; staging plan has no aliases |
| `006-custom-domain-t02` | T002 | FR-006, FR-007 | No: workflow-only after secrets exist; SITE_URL update is Jorge | T001 merged and Jorge applied (steps 2–3) | Production verify greps/curl blocks for apex 200 and one 301; staging verify unchanged |
| `006-custom-domain-t03` | T003 | Converge, AC1–AC5, SC-001–SC-005 | No (Jorge merges converge anyway) | T002 merged; Jorge's step 4 (release to `main`) | `converge.md` with live evidence and `Converged` |

## Phase 1: Production DNS, ACM, aliases, redirect function (P1)

- [ ] T001 [US1][US2][US3] In `infra/site/`, production only: add data sources for the existing `jlaborda.com` and `jorgelaborda.com` public hosted zones; request one ACM certificate in `us-east-1` for the four names with Route 53 DNS validation; set production distribution aliases and viewer certificate to that ACM ARN; extend the production viewer-request CloudFront Function so non-canonical hosts return HTTP 301 to `https://jlaborda.com` + path while keeping the Hugo directory rewrite for the canonical host; create Route 53 alias A and AAAA records for the four names to the production distribution. Do not register domains, do not create hosted zones, do not change staging aliases or certificate. Do not edit workflows in this pull request. Carries `needs-human`. Jorge runs plan/apply (certificate validation may take minutes). The pull request body pastes plan summaries (no account id, bucket name, distribution id, hostname, or email).

## Phase 2: SITE_URL and verify (P1, P2)

- [ ] T002 [US1][US2] After Jorge sets production `SITE_URL` to `https://jlaborda.com`, update `.github/workflows/deploy.yml` job `verify` so production checks the apex HTTP 200 and one redirect host HTTP 301 with path preserved (FR-007). Leave staging verify on staging `SITE_URL`. Do not edit `infra/`. The pull request body pastes the new check snippets and a dry explanation of environment branching.

## Phase 3: Convergence

- [ ] T003 After Jorge releases `develop` to `main`, run `/speckit-converge` and write `specs/006-custom-domain/converge.md` with AC1–AC5 evidence (apex 200, three redirects or the one automated plus note, sitemap/canonical sample, default hostname still 200, clean plan), the date, the SHA, and `Converged`; `Status: Approved by Jorge — PR #N`. Title exactly `chore(006): converge`. No secrets or hostnames that are distribution ids; the custom domain names `jlaborda.com` / `jorgelaborda.com` are allowed as public product names. Jorge merges after QA sign-off.

## Dependencies

- T001 needs this `docs:` pull request merged, #46 T011 merged on `develop`, and Jorge's domains Active.
- T002 needs T001 applied and production `SITE_URL` updated.
- T003 needs T002 merged and the release to `main`.

## Jorge's steps

Order:

1. Register `jlaborda.com` and `jorgelaborda.com` in the Route 53 console (privacy protection, auto-renew) and wait until both domains are Active (hosted zones exist).
2. After T001 is ready, run `terraform plan` / `terraform apply` for the production site stack (ACM DNS validation may take minutes). Confirm the certificate is Issued.
3. Update the production GitHub Environment variable `SITE_URL` to `https://jlaborda.com` (no trailing slash). Do not put secrets or the old CloudFront hostname into git.
4. After T002 is on `develop`, merge `develop` into `main` as a merge commit (release) so production deploys with the new baseURL and verify checks.

## Notes

- Mark an id `[X]` only in the pull request that closes it.
- Do not edit `spec.md` or `plan.md` in an implementation pull request.
- Email/MX, staging subdomain, other TLDs, and HSTS preload stay out of scope.
