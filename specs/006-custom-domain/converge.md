# Convergence: Custom Domain jlaborda.com

Feature: `specs/006-custom-domain`

Command: `/speckit-converge`

Status: Approved by Jorge — PR #71

Assessed commit: `9e95024ad83ee8d5c74f39032d87b37c4c745b1c` (main after release #92)

Date: 2026-11-10 (Europe/Madrid)

This file is the T003 record. `/speckit-converge` did not modify `spec.md` or `plan.md`, and it did not append a Convergence phase to `tasks.md`. `.specify/extensions.yml` is not present, so no before-converge or after-converge hooks ran. Account ids, bucket names, distribution ids, hosted zone ids, CloudFront hostnames, emails, and ARNs are omitted or written as `<redacted>`. The public product names `jlaborda.com` and `www.jlaborda.com` are allowed.

## Prerequisite check

```text
SPECIFY_FEATURE_DIRECTORY=specs/006-custom-domain
.specify/scripts/bash/check-prerequisites.sh --json --require-spec --require-tasks --include-tasks
```

```json
{"FEATURE_DIR":"/agent/repos/web-portfolio/specs/006-custom-domain","AVAILABLE_DOCS":["tasks.md"]}
```

`spec.md`, `plan.md`, and `tasks.md` are present.

## Release evidence

| Field | Value |
|-------|-------|
| Release PR | #92 (`develop` → `main`, merge commit) |
| Main SHA | `9e95024ad83ee8d5c74f39032d87b37c4c745b1c` |
| Production deploy | https://github.com/JLaborda/web-portfolio/actions/runs/42835571403 |
| Deploy conclusion | `success` |
| Verify comment on #92 | `production SITE_URL`, `apex home`, and `www redirect` all `pass` |

## AC1–AC6 live evidence (gathered 2026-11-10)

### AC1 — apex HTTPS 200 + certificate

```bash
curl -sS --retry 5 --retry-delay 5 --retry-all-errors --connect-timeout 20 \
  -o /dev/null -w '%{http_code}' 'https://jlaborda.com/'
```

Printed `200`.

```bash
echo | openssl s_client -servername jlaborda.com -connect jlaborda.com:443 2>/dev/null \
  | openssl x509 -noout -subject
```

Printed `subject=CN = jlaborda.com`.

### AC2 — www → apex 301 with path preserved

```bash
curl -sSI --retry 5 --retry-delay 5 --retry-all-errors --connect-timeout 20 \
  'https://www.jlaborda.com/now/'
```

Status `301`. `Location: https://jlaborda.com/now/`.

### AC3 — sitemap and canonical use `https://jlaborda.com`

Live `https://jlaborda.com/sitemap.xml` includes:

```xml
<loc>https://jlaborda.com/</loc>
```

(and further `<loc>https://jlaborda.com/…</loc>` entries for site sections).

Live `https://jlaborda.com/` HTML includes:

```html
<link rel=canonical href=https://jlaborda.com/>
```

### AC4 — default CloudFront hostname still serves

`curl` of the production default CloudFront hostname `/` (hostname not written here) returned HTTP `200`.

### AC5 — clean production plan

Terraform CI does not run on push to `main`; the latest green plan that covered production after T001 apply is the terraform job on release PR #92:

| Field | Value |
|-------|-------|
| Run | https://github.com/JLaborda/web-portfolio/actions/runs/42830704689 |
| Head SHA | `6a07d53967f0a9fa955d4f8815af9e043b54eca3` |
| Conclusion | `success` |

Plan summaries in that run (shared, staging, production):

```text
No changes. Your infrastructure matches the configuration.
No changes. Your infrastructure matches the configuration.
No changes. Your infrastructure matches the configuration.
```

### AC6 — MX and email TXT still present

DNS-over-HTTPS (`https://dns.google/resolve`) on 2026-11-10, counts only (no record values, no emails):

| Query | Status | Answer count | Notes |
|-------|--------|--------------|-------|
| `MX` `jlaborda.com` | 0 (NOERROR) | 2 | MX present |
| `TXT` `jlaborda.com` | 0 (NOERROR) | 1 | includes 1 SPF (`v=spf1…`) TXT |

Infra has no Terraform resources that create, update, or destroy MX or email TXT for this zone (`data "aws_route53_zone"` plus ACM validation CNAMEs and apex/www alias A/AAAA only).

## SC-001–SC-006

| ID | Result | Evidence |
|----|--------|----------|
| SC-001 | Pass | AC1; production deploy `42835571403` verify `apex home` / `home` 200 |
| SC-002 | Pass | AC2; verify `www redirect` pass on #92 |
| SC-003 | Pass | AC3 sitemap + canonical samples |
| SC-004 | Pass | AC4 default CloudFront hostname HTTP 200 |
| SC-005 | Pass | AC5 three `No changes` lines on run `42830704689` |
| SC-006 | Pass | AC6 MX count 2, SPF TXT count 1 via DoH |

## What was checked (code)

- **FR-001**: `data "aws_route53_zone" "jlaborda"` by name; no `aws_route53_zone` resource; no domain registration resources.
- **FR-002**: Production aliases `jlaborda.com` + `www.jlaborda.com`; ACM viewer cert (SNI, TLSv1.2_2021); staging keeps default cert and empty aliases.
- **FR-003**: `aws_acm_certificate.jlaborda` via `aws.us_east_1`; Route 53 validation records + `aws_acm_certificate_validation.jlaborda`.
- **FR-004**: Route 53 alias A/AAAA for apex and www.
- **FR-005**: Production viewer-request function redirects `www.jlaborda.com` with 301 and keeps Hugo directory rewrite.
- **FR-006**: Production `SITE_URL` is `https://jlaborda.com` (verify assert + live HTML/sitemap).
- **FR-007**: Production verify checks apex 200 and www 301 with path; staging still uses staging `SITE_URL` only for those existing checks.
- **FR-008**: Clean production plan evidence above; default hostname still 200.
- **FR-009**: No MX/email TXT resources in Terraform; live MX/SPF still present.
- **Constitution III**: ACM in `us-east-1`; DNS/custom-domain path carried `needs-human` on T001.

## Convergence Findings

No actionable findings. `/speckit-converge` did not append a phase to `tasks.md`.

| ID | Gap Type | Severity | Source | Evidence | Remaining Work |
|----|----------|----------|--------|----------|----------------|
| — | — | — | — | Implementation matches the spec, plan, and tasks | — |

**Summary metrics:**

- Requirements checked: 9 (FR-001 through FR-009)
- Success criteria checked: 6 (SC-001 through SC-006)
- Acceptance criteria checked: 6 (AC1 through AC6)
- Plan decisions checked: hand-created zone data source, us-east-1 ACM, production-only aliases, combined www redirect + Hugo rewrite, no MX/TXT in Terraform, staging unchanged, verify extension
- Constitution principles checked: III (hosting/ACM/DNS) in scope; no MUST violations found
- Tasks checked: T001 through T003
- Findings by gap type: missing 0, partial 0, contradicts 0, unrequested 0
- Findings by severity: CRITICAL 0, HIGH 0, MEDIUM 0, LOW 0

Outcome: **Converged**.

## Checks

```text
actionlint .github/workflows/*.yml   # exit 0
hugo --gc --minify --panicOnWarning --baseURL /   # exit 0, 17 pages
```

**"✅ Converged — the implementation satisfies the spec, plan, and tasks."**
