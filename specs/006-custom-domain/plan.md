# Implementation Plan: Custom Domain jlaborda.com

**Branch**: `006-custom-domain` | **Date**: 2026-11-03 | **Spec**: [spec.md](./spec.md)

Status: Approved by Jorge — PR #N

**Input**: Feature specification from `/specs/006-custom-domain/spec.md`

## Summary

Attach `jlaborda.com` (and the three alternate names) to the existing production CloudFront distribution. Jorge registers both domains in Route 53 by hand; Terraform only reads hosted zones, requests one ACM certificate in `us-east-1`, writes DNS validation and alias records, and extends the production viewer-request CloudFront Function so non-canonical hosts 301 to `https://jlaborda.com` while keeping the Hugo directory rewrite. Production `SITE_URL` / Hugo `baseURL` become `https://jlaborda.com`. Spec 005 verify gains apex and redirect checks. Staging unchanged. Decision record: [ADR 002](../../docs/adr/002-custom-domain.md).

## Technical Context

**Language/Version**: Terraform (existing pins in `infra/site`). CloudFront Functions runtime `cloudfront-js-2.0` (already used by `aws_cloudfront_function.rewrite`). Hugo deploy already uses `--baseURL "${SITE_URL}/"`.

**Primary Dependencies**: AWS ACM (`us-east-1`), Route 53 (data sources + records), CloudFront (existing distribution). No new GitHub Actions authenticator.

**Storage**: None beyond existing S3 origin.

**Testing**: Verification in [spec.md](./spec.md). Live curls after apply and release. `terraform plan` clean for production.

**Target Platform**: Production `infra/site` stack only for aliases/certificate/function/DNS. Staging stack unchanged.

**Project Type**: Infrastructure + small workflow verify extension + production environment variable update (Jorge).

**Performance Goals**: One viewer-request function; redirect before origin fetch.

**Constraints**: English only. No account id, bucket name, distribution id, CloudFront hostname, or email in the repository. `needs-human` on infra and any DNS/cost PR. Infra tasks start only after #46 T011 is on `develop`.

**Scale/Scope**: Two hosted zones (existing), one certificate, four aliases, one function update, Route 53 alias records, verify job tweaks, production `SITE_URL` update.

## Constitution Check

| Principle | Gate | Result |
|-----------|------|--------|
| I. Spec-driven | One `docs:` PR with spec, plan, tasks, checklist, ADR; Jorge merges; `needs-human`. | Pass |
| II. Fixed stack | No theme edit. | Pass |
| III. AWS hosting | ACM in `us-east-1`; Terraform; OIDC unchanged; custom domain with Jorge approval + `needs-human`. | Pass (constitution 3.1.0 clarifies deferred DNS may land in a later feature) |
| IV. Verifiable CI | Existing gates; live AC curls after release. | Pass |
| V. Scoped PRs | Small task PRs; converge `chore(006): converge`. | Pass |
| VI. Cheap | ~15 USD/year per domain + ~0.50 USD/month per zone; no second distribution. | Pass |
| VII. English | All docs English. | Pass |

## Project Structure

```text
specs/006-custom-domain/
├── spec.md
├── checklists/requirements.md
├── plan.md
├── tasks.md
└── converge.md                 # converge PR
docs/adr/
└── 002-custom-domain.md
infra/site/
├── cdn.tf                      # aliases, cert association, function (production)
├── dns.tf                      # new: data zones, ACM, validation, aliases (production only)
└── variables.tf                # optional domain toggles / names
.github/workflows/
└── deploy.yml                  # verify: apex + one redirect (production)
```

## Design

### Domains and zones

- Jorge registers `jlaborda.com` and `jorgelaborda.com` in Route 53 (console). Zones appear when Active.
- Terraform: `data "aws_route53_zone" "jlaborda"` and `data "aws_route53_zone" "jorgelaborda"` (public). No `aws_route53_zone` resource. No `aws_route53domains_registered_domain` create/register in this feature.

### ACM

- Provider alias or separate `aws` provider with `region = "us-east-1"` for `aws_acm_certificate` covering:
  - `jlaborda.com`
  - `www.jlaborda.com`
  - `jorgelaborda.com`
  - `www.jorgelaborda.com`
- `aws_route53_record` validation + `aws_acm_certificate_validation`.
- Production distribution `viewer_certificate` uses that ACM ARN, `ssl_support_method = "sni-only"`, modern TLS policy already in use or `TLSv1.2_2021`.

### CloudFront

- Production only: `aliases = [...]` the four names.
- Staging: unchanged (`cloudfront_default_certificate = true`, no aliases).
- Function: CloudFront allows one viewer-request association. Extend `aws_cloudfront_function.rewrite` for production (or a production-only function resource) so that:
  1. If `Host` is a redirect host → return 301 with `Location: https://jlaborda.com` + URI path.
  2. Else keep today's directory → `index.html` rewrite.
- No second distribution. No S3 website redirect bucket (blocker would be documented; none identified: combining host redirect with URI rewrite in one function is supported).

### Route 53 aliases

- Alias A and AAAA for each of the four names to the production distribution domain name / hosted zone id (CloudFront).

### Deploy / Hugo / verify

- Jorge sets production Environment variable `SITE_URL` to `https://jlaborda.com` (after certificate is usable).
- Deploy already builds with `--baseURL "${SITE_URL}/"`.
- Spec 005 verify on production: curl apex expect 200; curl one redirect host expect 301 to apex path. Staging verify unchanged.
- Depends on #46 T011 so secrets/vars wiring is settled before more `deploy.yml` edits.

### Cost (expected)

| Item | Rough cost |
|------|------------|
| Each `.com` registration | ~15 USD / year |
| Each public hosted zone | ~0.50 USD / month |
| ACM (public, DNS-validated) | 0 USD |
| Extra CloudFront (aliases on existing distribution) | negligible vs current |

## Delivery order

1. This `docs:` PR (needs-human) merged by Jorge.
2. #46 T011 merged (secrets).
3. Jorge registers domains; waits until Active (Jorge's steps).
4. Infra PR(s): DNS data sources, ACM, aliases, function, records (`needs-human`); Jorge applies.
5. Jorge sets production `SITE_URL`.
6. Verify workflow PR (apex + redirect checks).
7. Merge to `develop`, then Jorge releases `develop` → `main` (merge commit).
8. `chore(006): converge`.

## Complexity Tracking

Combining host redirect with the existing URI rewrite in one viewer-request function is required by CloudFront's single-association rule. Documented above; not a constitution violation.
