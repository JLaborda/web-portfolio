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

One task (or cohesive pair) per pull request, merged one at a time into `develop`. Each lists its task ids and marks them `[X]` here. Infra tasks start only after issue #46 T011 is merged **and** Pasos de Jorge (a)–(c) are done (delegation visible). `needs-human` applies to DNS/ACM/cost changes; Jorge merges those. Converge title is exactly `chore(006): converge`.

| Branch | Task | Requirements | needs-human | Depends on | Verification |
|--------|------|--------------|-------------|------------|--------------|
| `006-custom-domain-t01` | T001 | FR-001–FR-005, FR-008, FR-009 | Yes: DNS, ACM, custom domain, AWS cost | This `docs:` PR merged; #46 T011 merged; Pasos de Jorge (a)–(c) done (`dig NS` shows `awsdns`) | PR body shows `dig NS jlaborda.com` → `awsdns`; `terraform plan` for production shows apex/www aliases, ACM, validation + alias records, function; no zone create/register; no MX/email TXT resources; staging plan has no aliases |
| `006-custom-domain-t02` | T002 | FR-006, FR-007 | No: workflow-only after secrets exist; SITE_URL update is Jorge | T001 merged and Jorge applied (Pasos de Jorge apply + SITE_URL) | Production verify greps/curl blocks for apex 200 and www 301; staging verify unchanged |
| `006-custom-domain-t03` | T003 | Converge, AC1–AC6, SC-001–SC-006 | No (Jorge merges converge anyway) | T002 merged; Jorge's release to `main` | `converge.md` with live evidence and `Converged` |

## Phase 1: Production DNS, ACM, aliases, redirect function (P1)

- [ ] T001 [US1][US2][US3] In `infra/site/`, production only: add `data "aws_route53_zone"` for the existing hand-created public zone `jlaborda.com` (lookup by name); request one ACM certificate in `us-east-1` for `jlaborda.com` and `www.jlaborda.com` with Route 53 DNS validation; set production distribution aliases and viewer certificate to that ACM ARN; extend the production viewer-request CloudFront Function so `www.jlaborda.com` returns HTTP 301 to `https://jlaborda.com` + path while keeping the Hugo directory rewrite for the canonical host; create Route 53 alias A and AAAA for apex and www to the production distribution. Do not register domains, do not create hosted zones, do not manage MX or email TXT, do not change staging aliases or certificate, do not reference `jorgelaborda.com`. Do not edit workflows in this pull request. Before expecting ACM Issued, verify delegation with `dig NS jlaborda.com` (must show Route 53 `awsdns` servers) and paste that output (no zone id) in the pull request body. Carries `needs-human`. Jorge runs plan/apply (certificate validation may take minutes once NS have propagated). The pull request body pastes plan summaries (no account id, bucket name, distribution id, hosted zone id, hostname, or email).

## Phase 2: SITE_URL and verify (P1, P2)

- [ ] T002 [US1][US2] After Jorge sets production `SITE_URL` to `https://jlaborda.com`, update `.github/workflows/deploy.yml` job `verify` so production checks the apex HTTP 200 and `www.jlaborda.com` HTTP 301 with path preserved (FR-007). Leave staging verify on staging `SITE_URL`. Do not edit `infra/`. The pull request body pastes the new check snippets and a dry explanation of environment branching.

## Phase 3: Convergence

- [ ] T003 After Jorge releases `develop` to `main`, run `/speckit-converge` and write `specs/006-custom-domain/converge.md` with AC1–AC6 evidence (apex 200, www redirect, sitemap/canonical sample, default hostname still 200, clean plan, MX/email TXT still present), the date, the SHA, and `Converged`; `Status: Approved by Jorge — PR #N`. Title exactly `chore(006): converge`. No secrets, account ids, zone ids, distribution ids, or CloudFront hostnames; the public product name `jlaborda.com` is allowed. Jorge merges after QA sign-off.

## Dependencies

- T001 needs this `docs:` pull request merged, #46 T011 merged on `develop`, and Pasos de Jorge (a)–(c) complete with visible NS delegation.
- T002 needs T001 applied and production `SITE_URL` updated.
- T003 needs T002 merged and the release to `main`.

## Pasos de Jorge

Only Jorge does these. Agents do not operate the OVH or AWS consoles for him.

### Done-by-Jorge prerequisites (before the first code PR / T001)

These must be finished before `006-custom-domain-t01` opens:

- [x] **(a) Note OVH MX/TXT** — From the OVH control panel for `jlaborda.com`, record the MX and SPF/TXT (and any other mail TXT) values for the free Zimbra Starter mailbox. Changing name servers does not void the mailbox while the domain stays registered at OVH.
- [x] **(b) Create public hosted zone and recreate MX/TXT** — In the AWS console, create the public Route 53 hosted zone for `jlaborda.com` by hand (not Terraform). Recreate the OVH MX and SPF/TXT records in that zone. Do not commit zone ids or account ids to git.
- [x] **(c) Set Route 53 NS at OVH** — In the OVH control panel, replace OVH's name servers with the four NS names from the Route 53 hosted zone. Wait for propagation (up to 48 hours) until `dig NS jlaborda.com` returns `awsdns` servers.

### After T001 is ready

1. Confirm `dig NS jlaborda.com` still shows Route 53 `awsdns` servers.
2. Run `terraform plan` / `terraform apply` for the production site stack (ACM DNS validation may take minutes). Confirm the certificate is Issued. Confirm MX and email TXT records Jorge placed by hand are still present (FR-009 / AC6).
3. Update the production GitHub Environment variable `SITE_URL` to `https://jlaborda.com` (no trailing slash). Confirm production environment secrets (`AWS_ROLE_ARN`, `BUCKET_NAME`, `DISTRIBUTION_ID`) remain as after #46/#73 — do not put those values into git.
4. After T002 is on `develop`, merge `develop` into `main` as a **merge commit** (release) so production deploys with the new baseURL and verify checks.

## Notes

- Mark an id `[X]` only in the pull request that closes it.
- Do not edit `spec.md` or `plan.md` in an implementation pull request.
- Email mailbox setup, `jorgelaborda.com`, staging subdomain, other TLDs, and HSTS preload stay out of scope.
- Never write AWS account ids, hosted zone ids, distribution ids, bucket names, or CloudFront hostnames into the repository.
