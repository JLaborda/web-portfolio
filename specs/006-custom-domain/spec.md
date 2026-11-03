# Feature Specification: Custom Domain jlaborda.com

**Feature Branch**: `006-custom-domain`

**Created**: 2026-11-03

Status: Approved by Jorge — PR #N

**Input**: User description: "Serve the production Hugo portfolio on https://jlaborda.com. Jorge registers jlaborda.com and jorgelaborda.com by hand in Route 53 (privacy protection, auto-renew). Hosted zones already exist after registration; Terraform reads them with data sources and does not register domains or create zones. Canonical host is the apex. www.jlaborda.com, jorgelaborda.com, and www.jorgelaborda.com return HTTP 301 to https://jlaborda.com keeping the path, via a CloudFront Function on the production distribution (all four aliases). One ACM certificate in us-east-1, DNS-validated in Terraform. Route 53 alias A/AAAA to the production distribution. Production Hugo baseURL and SITE_URL become https://jlaborda.com. Spec 005 verify checks the custom domain and one redirect. Staging stays on its default CloudFront hostname. Out of scope: email/MX, staging subdomain, other TLDs, HSTS preload."

## Clarifications

### Session 2026-11-03

- Q: Which host is canonical? → A: The apex `https://jlaborda.com`.
- Q: How do the other three names behave? → A: `www.jlaborda.com`, `jorgelaborda.com`, and `www.jorgelaborda.com` each return HTTP 301 to `https://jlaborda.com` with the request path preserved.
- Q: How is the redirect implemented? → A: A CloudFront Function on viewer-request on the single production distribution, which carries all four aliases. No second distribution and no S3 redirect bucket unless a blocker appears in the plan.
- Q: Who registers the domains and who owns the hosted zones in Terraform? → A: Jorge registers both domains by hand in the Route 53 console (privacy protection, auto-renew). Registration creates the hosted zones. Terraform MUST NOT register domains or create hosted zones; it reads the zones with data sources.
- Q: Where is the ACM certificate? → A: One certificate in `us-east-1`, DNS-validated through Route 53 records managed in Terraform, covering the four names.
- Q: What happens to staging? → A: Staging stays on its default CloudFront hostname. No custom domain for staging.
- Q: What is out of scope? → A: Email/MX, a staging subdomain, other TLDs, and HSTS preload.
- Q: When may infrastructure tasks start? → A: Only after issue #46's T011 (deploy identifiers as secrets) is merged, because this feature edits the same Terraform and `deploy.yml` surfaces.

## Context

Spec 002 deliberately left custom domain, ACM, and Route 53 out of scope. Production and staging are served only on CloudFront default hostnames. Jorge is already sending his CV out, so a memorable production URL that matches his GitHub username is high priority.

This feature overrides that deferral for production only. Staging remains unlisted on its default hostname. The decision record is [ADR 002](../../docs/adr/002-custom-domain.md).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Visitor opens the portfolio on jlaborda.com (Priority: P1)

A hiring manager or recruiter opens `https://jlaborda.com` and receives the production site over HTTPS with a valid certificate.

**Why this priority**: Without a working apex, the domain registration is wasted.

**Independent Test**: After apply and deploy, `curl` to `https://jlaborda.com/` returns HTTP 200. The TLS certificate is valid for that name.

**Acceptance Scenarios**:

1. **Given** the production distribution has the custom certificate and aliases, **When** a visitor opens `https://jlaborda.com/`, **Then** the response is HTTP 200 and the certificate covers that name.
2. **Given** that deploy finished, **When** a visitor opens a published path such as `/now/`, **Then** that path also returns 200 on the apex.

---

### User Story 2 - Alternate names redirect to the apex (Priority: P1)

A visitor who types `www.jlaborda.com`, `jorgelaborda.com`, or `www.jorgelaborda.com` (with or without a path) is redirected once to the same path on `https://jlaborda.com`.

**Why this priority**: Both registered names and the www forms must not serve a second origin.

**Independent Test**: For each of the three hosts, a request to `/now/` returns HTTP 301 with `Location` pointing at `https://jlaborda.com/now/`.

**Acceptance Scenarios**:

1. **Given** the production function is live, **When** a client requests `https://www.jlaborda.com/now/`, **Then** the response is 301 to `https://jlaborda.com/now/`.
2. **Given** the same setup, **When** a client requests `https://jorgelaborda.com/` or `https://www.jorgelaborda.com/projects/`, **Then** each returns 301 to the matching path on `https://jlaborda.com`.

---

### User Story 3 - Jorge finishes registration and apply (Priority: P2)

Jorge registers both domains, waits until they are active, applies Terraform (certificate validation may take minutes), updates the production `SITE_URL` variable, and releases `develop` to `main`.

**Why this priority**: DNS registration and ACM validation are Jorge-only steps with real cost.

**Independent Test**: After his steps, `terraform plan` is clean and production `SITE_URL` is `https://jlaborda.com` with no trailing slash.

**Acceptance Scenarios**:

1. **Given** both domains are Active in Route 53, **When** Jorge applies the infra pull request, **Then** the ACM certificate reaches Issued and the alias records point at the production distribution.
2. **Given** that apply, **When** he sets production `SITE_URL` and the release deploys, **Then** Hugo's production `baseURL` and sitemap/canonical links use `https://jlaborda.com`.

### Edge Cases

- A request that already uses the canonical host must not redirect in a loop; the function only redirects when the Host is one of the three non-canonical names.
- HTTP (port 80) to any alias still follows CloudFront's existing viewer protocol redirect to HTTPS before or with the host redirect; the acceptance checks use HTTPS.
- The old production CloudFront default hostname continues to serve the same origin (200). It is not required to redirect to the custom domain in this feature.
- Staging must not gain aliases, a custom certificate, or Route 53 records from this feature.
- Terraform must fail plan/apply in a clear way if a hosted zone data source cannot find the registered domain (zones not yet active).
- Path preservation includes the URI path; query strings SHOULD be preserved when CloudFront Function APIs allow it without a second product decision.
- Spec 005 verify on production must check the apex and one redirect after this feature lands; staging verify stays on the staging `SITE_URL`.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Jorge registers `jlaborda.com` and `jorgelaborda.com` by hand in the Route 53 console with privacy protection and auto-renew. Terraform MUST NOT call domain-registration APIs and MUST NOT create hosted zones. Terraform reads the existing public hosted zones with data sources. **Acceptance**: the infra tree has no `aws_route53domains_*` register resource and no `aws_route53_zone` resource for these names; zone lookups use `data` sources.

- **FR-002**: Production CloudFront carries aliases for `jlaborda.com`, `www.jlaborda.com`, `jorgelaborda.com`, and `www.jorgelaborda.com`. Viewer certificate is the ACM certificate from FR-003 (SNI). Staging keeps `cloudfront_default_certificate` and no aliases. **Acceptance**: production plan shows the four aliases; staging plan does not.

- **FR-003**: One ACM certificate in `us-east-1` covers the four names. Validation records are created in the Route 53 zones via Terraform. **Acceptance**: after apply the certificate status is Issued; validation records exist in the zones.

- **FR-004**: Route 53 alias A and AAAA records for the four names point at the production CloudFront distribution. **Acceptance**: DNS for each name resolves to the distribution; HTTPS works as in the acceptance criteria.

- **FR-005**: A CloudFront Function on viewer-request on the production distribution returns HTTP 301 to `https://jlaborda.com` + path when Host is one of the three non-canonical names. The existing directory-to-`index.html` rewrite behaviour for the canonical host MUST remain. Implementation MAY extend the existing production rewrite function rather than attach a second viewer-request function (CloudFront allows only one function association per event type). No second distribution and no S3 website redirect bucket. **Acceptance**: the three redirect checks in Verification exit 0.

- **FR-006**: Production Hugo `baseURL` (deploy job `--baseURL "${SITE_URL}/"`) and the production GitHub Environment variable `SITE_URL` are `https://jlaborda.com` with no trailing slash. Sitemap and canonical links in the published HTML use that origin. Staging `SITE_URL` is unchanged. **Acceptance**: greps on a production build and the live apex show `https://jlaborda.com`; staging still uses its CloudFront hostname variable.

- **FR-007**: Spec 005's production verify job checks the custom apex (HTTP 200) and one redirect from a non-canonical host (HTTP 301 with preserved path). Staging verify is unchanged. **Acceptance**: the FR-007 Verification block exits 0 after the verify workflow edit.

- **FR-008**: After Jorge's apply, `terraform plan` for production site state is clean (no pending changes required for this feature). The old production CloudFront default hostname still serves HTTP 200 for `/`. **Acceptance**: plan exit 0 / no changes; curl of the default hostname returns 200.

- **FR-009**: This feature does not add email/MX, a staging subdomain, other TLDs, or HSTS preload. Infra tasks MUST NOT open until issue #46 T011 is merged on `develop`. Every pull request that creates or changes AWS DNS, ACM, or cost-bearing resources carries `needs-human`. **Acceptance**: task table and Jorge's steps record that order; out-of-scope greps find no MX or HSTS preload additions.

### Key Entities

- **Canonical host**: `jlaborda.com` served as `https://jlaborda.com`.
- **Redirect hosts**: `www.jlaborda.com`, `jorgelaborda.com`, `www.jorgelaborda.com`.
- **Hosted zones**: Existing Route 53 public zones for the two registered domains; read-only in Terraform.
- **ACM certificate**: Single `us-east-1` certificate for the four names.
- **Production distribution**: Existing `infra/site` production stack, extended with aliases, custom certificate, and redirect logic.

## Success Criteria *(mandatory)*

- **SC-001**: `https://jlaborda.com/` returns HTTPS 200 with a valid certificate within one minute of a successful production deploy after this feature.
- **SC-002**: Each of the three non-canonical hosts returns 301 to the matching path on `https://jlaborda.com`.
- **SC-003**: Published sitemap and canonical links use `https://jlaborda.com`.
- **SC-004**: The previous production CloudFront default hostname still returns 200 for `/`.
- **SC-005**: `terraform plan` for the production site stack is clean after apply.

## Acceptance Criteria (verifiable)

| ID | Criterion |
|----|-----------|
| AC1 | HTTPS 200 on the apex with a valid certificate. |
| AC2 | 301 with the path preserved for the three other hosts. |
| AC3 | Sitemap and canonical links use `https://jlaborda.com`. |
| AC4 | The old `*.cloudfront.net` production URL still serves. |
| AC5 | `terraform plan` is clean after apply. |

## Assumptions

- Jorge completes domain registration and waits until both domains are Active before the first infra apply that needs the zones.
- Annual domain cost is about 15 USD per `.com`; hosted-zone cost is about 0.50 USD per month per zone (two zones). Budget alert remains the existing 1 USD monthly AWS Budgets rule; domain fees may appear on the Route 53 invoice separately.
- Issue #46 (environment secrets) is merged before infra tasks that edit `deploy.yml` / shared deploy surfaces.
- Constitution III already requires ACM in `us-east-1` and `needs-human` for DNS/custom domain work.

## Out of Scope

- Email, MX, or mailbox setup.
- A staging custom subdomain.
- Other TLDs or additional brand domains.
- HSTS preload submission.
- Redirecting the CloudFront default hostname to the custom domain.

## Verification

Commands use environment values; they must not print or commit account ids, bucket names, distribution ids, or emails. Placeholders below are names only.

### AC1

```bash
set -euo pipefail
code=$(curl -sS -o /dev/null -w '%{http_code}' https://jlaborda.com/)
test "$code" = "200"
echo | openssl s_client -servername jlaborda.com -connect jlaborda.com:443 2>/dev/null | openssl x509 -noout -subject | grep -F 'jlaborda.com'
```

### AC2

```bash
set -euo pipefail
for host in www.jlaborda.com jorgelaborda.com www.jorgelaborda.com; do
  loc=$(curl -sSI "https://${host}/now/" | tr -d '\r' | awk 'tolower($1)=="location:"{print $2; exit}')
  test "$loc" = "https://jlaborda.com/now/"
  code=$(curl -sSI "https://${host}/now/" | tr -d '\r' | awk 'toupper($1) ~ /^HTTP/{print $2; exit}')
  test "$code" = "301"
done
```

### AC3

```bash
set -euo pipefail
# After a production build with SITE_URL=https://jlaborda.com:
grep -R -F 'https://jlaborda.com' public/sitemap.xml public/**/index.html | head
grep -R -F 'rel="canonical"' public | head
```

### AC4 / AC5

```bash
set -euo pipefail
# AC4: SITE_URL_DEFAULT is the production CloudFront domain name from Terraform output (not committed).
code=$(curl -sS -o /dev/null -w '%{http_code}' "${SITE_URL_DEFAULT}/")
test "$code" = "200"
# AC5: Jorge's local plan after apply exits 0 with no changes for production site state.
```
