# Implementation Plan: Custom Domain jlaborda.com

**Branch**: `006-custom-domain` | **Date**: 2026-11-03 (updated 2026-11-09) | **Spec**: [spec.md](./spec.md)

Status: Approved by Jorge — PR #71

**Input**: Feature specification from `/specs/006-custom-domain/spec.md`

## Summary

Attach `jlaborda.com` (and `www.jlaborda.com`) to the existing production CloudFront distribution. Jorge bought the domain at **OVHcloud** (external registrar, 9 Nov 2026); Route 53 Domains is not used. He creates the public Route 53 hosted zone by hand and delegates OVH name servers to that zone. Terraform only reads the zone with `data "aws_route53_zone"`, requests one ACM certificate in `us-east-1`, writes DNS validation and apex/www alias records, and extends the production viewer-request CloudFront Function so `www` 301s to `https://jlaborda.com` while keeping the Hugo directory rewrite. Terraform never manages MX or email TXT. Production `SITE_URL` / Hugo `baseURL` become `https://jlaborda.com`. Spec 005 verify gains apex and www-redirect checks. Staging unchanged. `jorgelaborda.com` is out of scope. Decision record: [ADR 002](../../docs/adr/002-custom-domain.md).

## Technical Context

**Language/Version**: Terraform (existing pins in `infra/site`). CloudFront Functions runtime `cloudfront-js-2.0` (already used by `aws_cloudfront_function.rewrite`). Hugo deploy already uses `--baseURL "${SITE_URL}/"`.

**Primary Dependencies**: AWS ACM (`us-east-1`), Route 53 (data source + records Jorge did not place by hand), CloudFront (existing distribution). OVHcloud for registration/renewal and as the source of MX/SPF/TXT values Jorge copies. No new GitHub Actions authenticator.

**Storage**: None beyond existing S3 origin.

**Testing**: Verification in [spec.md](./spec.md), including `dig NS` before ACM. Live curls after apply and release. `terraform plan` clean for production.

**Target Platform**: Production `infra/site` stack only for aliases/certificate/function/DNS records. Staging stack unchanged.

**Project Type**: Infrastructure + small workflow verify extension + production environment variable update (Jorge).

**Performance Goals**: One viewer-request function; redirect before origin fetch.

**Constraints**: English only. No account id, bucket name, distribution id, hosted zone id, CloudFront hostname, or email address in the repository. `needs-human` on infra and any DNS/cost PR. Infra tasks start only after #46 T011 is on `develop`. Never destroy Jorge's hand-managed MX/TXT.

**Scale/Scope**: One hosted zone (hand-created), one certificate (apex + www), two aliases, one function update, Route 53 alias + ACM validation records, verify job tweaks, production `SITE_URL` update.

## Constitution Check

| Principle | Gate | Result |
|-----------|------|--------|
| I. Spec-driven | One `docs:` PR with spec, plan, tasks, checklist, ADR; Jorge merges; `needs-human`. | Pass |
| II. Fixed stack | No theme edit. | Pass |
| III. AWS hosting | ACM in `us-east-1`; Terraform; OIDC unchanged; custom domain with Jorge approval + `needs-human`. | Pass (constitution 3.1.0 clarifies deferred DNS may land in a later feature) |
| IV. Verifiable CI | Existing gates; live AC curls after release; delegation dig before ACM. | Pass |
| V. Scoped PRs | Small task PRs; converge `chore(006): converge`. | Pass |
| VI. Cheap | Domain renewal at OVH; ~0.50 USD/month for one hosted zone; no second distribution. | Pass |
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
├── dns.tf                      # new: data zone, ACM, validation, apex/www aliases (production only)
└── variables.tf                # optional domain toggles / names
.github/workflows/
└── deploy.yml                  # verify: apex + www redirect (production)
```

## Design

### Registrar and zone (outside Terraform)

- Domain: `jlaborda.com` at OVHcloud since 2026-11-09 (1 year, renews Nov 2027). Registration and renewal stay in OVH's UI.
- Jorge creates the public Route 53 hosted zone named `jlaborda.com` in the AWS console (hand).
- Jorge notes OVH MX and SPF/TXT, recreates them as records in that hosted zone, then sets the zone's four NS values in the OVH control panel.
- Propagation may take up to 48 hours.

### Terraform DNS surface

- `data "aws_route53_zone" "jlaborda"` looking up the public zone by name. No `aws_route53_zone` resource. No `aws_route53domains_*` registration.
- Terraform-owned records only: ACM DNS validation CNAMEs (or as required by ACM) and alias A/AAAA for apex and `www` to the production distribution.
- Explicit non-ownership: no MX, no email SPF/TXT, no other mail records. Apply must not delete them (do not use a pattern that replaces the whole zone or adopts unmanaged records).

### ACM

- Provider alias or separate `aws` provider with `region = "us-east-1"` for `aws_acm_certificate` covering:
  - `jlaborda.com`
  - `www.jlaborda.com`
- `aws_route53_record` validation + `aws_acm_certificate_validation`.
- First code task verifies `dig NS jlaborda.com` returns `awsdns` before treating validation failure as a code bug.
- Production distribution `viewer_certificate` uses that ACM ARN, `ssl_support_method = "sni-only"`, modern TLS policy already in use or `TLSv1.2_2021`.

### CloudFront

- Production only: `aliases = ["jlaborda.com", "www.jlaborda.com"]`.
- Staging: unchanged (`cloudfront_default_certificate = true`, no aliases).
- Function: CloudFront allows one viewer-request association. Extend `aws_cloudfront_function.rewrite` for production (or a production-only function resource) so that:
  1. If `Host` is `www.jlaborda.com` → return 301 with `Location: https://jlaborda.com` + URI path.
  2. Else keep today's directory → `index.html` rewrite.
- No second distribution. No S3 website redirect bucket.

### Deploy / Hugo / verify

- Jorge sets production Environment variable `SITE_URL` to `https://jlaborda.com` (after certificate is usable).
- Deploy already builds with `--baseURL "${SITE_URL}/"`.
- Spec 005 verify on production: curl apex expect 200; curl `www` expect 301 to apex path. Staging verify unchanged.
- Depends on #46 T011 so secrets/vars wiring is settled before more `deploy.yml` edits.

### Cost (expected)

| Item | Rough cost |
|------|------------|
| `jlaborda.com` at OVHcloud | Paid to OVH (1 year from 2026-11-09) |
| One public hosted zone | ~0.50 USD / month (AWS) |
| ACM (public, DNS-validated) | 0 USD |
| Extra CloudFront (aliases on existing distribution) | negligible vs current |

## Delivery order

1. This `docs:` PR (needs-human) merged by Jorge.
2. #46 T011 merged (secrets) — already on `develop` when infra starts.
3. Jorge completes Pasos de Jorge (a)–(c): note OVH MX/TXT; create hosted zone and recreate MX/TXT; set Route 53 NS at OVH; wait for delegation (`dig NS` shows `awsdns`).
4. Infra PR T001: data zone, ACM, aliases, function, records (`needs-human`); verify delegation in the PR body; Jorge applies.
5. Jorge sets production `SITE_URL` and any remaining GitHub secrets/vars steps already listed in Pasos de Jorge.
6. Verify workflow PR (apex + www redirect checks).
7. Merge to `develop`, then Jorge releases `develop` → `main` (merge commit).
8. `chore(006): converge`.

## Complexity Tracking

Combining host redirect with the existing URI rewrite in one viewer-request function is required by CloudFront's single-association rule. Documented above; not a constitution violation.
