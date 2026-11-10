# Feature Specification: Custom Domain jlaborda.com

**Feature Branch**: `006-custom-domain`

**Created**: 2026-11-03

Status: Approved by Jorge — PR #71

**Input**: User description: "Serve the production Hugo portfolio on https://jlaborda.com. Jorge bought jlaborda.com at OVHcloud (external registrar) on 9 Nov 2026. Route 53 domain registration is not used. Jorge creates the public Route 53 hosted zone by hand; Terraform only reads it and adds ACM DNS validation plus apex/www aliases to the production CloudFront distribution. Canonical host is the apex. www.jlaborda.com returns HTTP 301 to https://jlaborda.com keeping the path, via a CloudFront Function. One ACM certificate in us-east-1, DNS-validated in Terraform. Production Hugo baseURL and SITE_URL become https://jlaborda.com. Spec 005 verify checks the custom domain and the www redirect. Staging stays on its default CloudFront hostname. jorgelaborda.com was not bought and is out of scope. Email mailbox setup is out of scope; Terraform must never manage or delete MX or email TXT records that Jorge places by hand for OVH Zimbra."

## Clarifications

### Session 2026-11-03

- Q: Which host is canonical? → A: The apex `https://jlaborda.com`.
- Q: How is the www name handled? → A: `www.jlaborda.com` returns HTTP 301 to `https://jlaborda.com` with the request path preserved (CloudFront Function on viewer-request).
- Q: Where is the ACM certificate? → A: One certificate in `us-east-1`, DNS-validated through Route 53 records managed in Terraform, covering the apex and `www`.
- Q: What happens to staging? → A: Staging stays on its default CloudFront hostname. No custom domain for staging.
- Q: When may infrastructure tasks start? → A: Only after issue #46's T011 (deploy identifiers as secrets) is merged, because this feature edits the same Terraform and `deploy.yml` surfaces.

### Session 2026-11-09

- Q: Where was the domain registered? → A: Jorge bought `jlaborda.com` at an external registrar, **OVHcloud**, on 9 Nov 2026 (1 year, renews Nov 2027). Route 53 domain registration is **not** used. Registration and renewal are manual and outside Terraform.
- Q: Was `jorgelaborda.com` bought? → A: **No.** It is out of scope for this feature. Any redirect or alias for `jorgelaborda.com` / `www.jorgelaborda.com` is future work.
- Q: Who creates the Route 53 hosted zone? → A: Jorge creates the public hosted zone for `jlaborda.com` **by hand** in the AWS console. Terraform MUST NOT create the zone; it reads it with `data "aws_route53_zone"` by name and adds records only (ACM DNS validation, apex and www alias A/AAAA to the production CloudFront distribution).
- Q: How does DNS delegation work? → A: Jorge replaces OVH's name servers with the four Route 53 NS of the hosted zone in the OVH control panel. Propagation can take up to 48 hours. The first code task MUST verify delegation (for example `dig NS jlaborda.com` returns `awsdns` name servers) before ACM validation is expected to pass.
- Q: What about email at OVH? → A: OVH includes a free Zimbra Starter mailbox that stays valid while the domain remains registered at OVH (changing name servers does not void it). Jorge copies OVH's MX and SPF/TXT records into the Route 53 hosted zone by hand. Terraform MUST NOT manage or delete MX or email TXT records. Email mailbox setup itself remains out of scope.

## Context

Spec 002 deliberately left custom domain, ACM, and Route 53 out of scope. Production and staging are served only on CloudFront default hostnames. Jorge bought `jlaborda.com` at OVHcloud so a memorable production URL that matches his GitHub username is available.

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

### User Story 2 - www redirects to the apex (Priority: P1)

A visitor who types `www.jlaborda.com` (with or without a path) is redirected once to the same path on `https://jlaborda.com`.

**Why this priority**: The www form must not serve a second origin.

**Independent Test**: A request to `https://www.jlaborda.com/now/` returns HTTP 301 with `Location` pointing at `https://jlaborda.com/now/`.

**Acceptance Scenarios**:

1. **Given** the production function is live, **When** a client requests `https://www.jlaborda.com/now/`, **Then** the response is 301 to `https://jlaborda.com/now/`.
2. **Given** the same setup, **When** a client requests `https://www.jlaborda.com/`, **Then** the response is 301 to `https://jlaborda.com/`.

---

### User Story 3 - Jorge finishes DNS hand-off and apply (Priority: P2)

Jorge has registered the domain at OVH, created the Route 53 hosted zone by hand, recreated MX/TXT for mail, and delegated NS at OVH. After delegation is visible, he applies Terraform (certificate validation may take minutes), updates the production `SITE_URL` variable, and releases `develop` to `main`.

**Why this priority**: DNS hand-off and ACM validation are Jorge-only steps with real cost and external registrar UI.

**Independent Test**: After his steps, `dig NS jlaborda.com` shows Route 53 `awsdns` servers, `terraform plan` is clean, and production `SITE_URL` is `https://jlaborda.com` with no trailing slash.

**Acceptance Scenarios**:

1. **Given** the hosted zone exists and NS are delegated, **When** Jorge applies the infra pull request, **Then** the ACM certificate reaches Issued and the apex/www alias records point at the production distribution.
2. **Given** that apply, **When** he sets production `SITE_URL` and the release deploys, **Then** Hugo's production `baseURL` and sitemap/canonical links use `https://jlaborda.com`.

### Edge Cases

- A request that already uses the canonical host must not redirect in a loop; the function only redirects when the Host is `www.jlaborda.com`.
- HTTP (port 80) to any alias still follows CloudFront's existing viewer protocol redirect to HTTPS before or with the host redirect; the acceptance checks use HTTPS.
- The old production CloudFront default hostname continues to serve the same origin (200). It is not required to redirect to the custom domain in this feature.
- Staging must not gain aliases, a custom certificate, or Route 53 records from this feature.
- Terraform must fail plan/apply in a clear way if the hosted zone data source cannot find `jlaborda.com` (zone not yet created).
- Path preservation includes the URI path; query strings SHOULD be preserved when CloudFront Function APIs allow it without a second product decision.
- Spec 005 verify on production must check the apex and the www redirect after this feature lands; staging verify stays on the staging `SITE_URL`.
- Terraform apply must leave Jorge's hand-managed MX and email TXT records untouched (never create, update, or destroy them).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Jorge registered `jlaborda.com` at OVHcloud (external registrar). Registration and renewal are manual and outside Terraform. Route 53 domain registration MUST NOT be used. Jorge creates the public Route 53 hosted zone for `jlaborda.com` by hand in the AWS console. Terraform MUST NOT register domains and MUST NOT create hosted zones. Terraform reads the existing public hosted zone with `data "aws_route53_zone"` by name. **Acceptance**: the infra tree has no `aws_route53domains_*` register resource and no `aws_route53_zone` resource for this name; zone lookup uses a `data` source.

- **FR-002**: Production CloudFront carries aliases for `jlaborda.com` and `www.jlaborda.com`. Viewer certificate is the ACM certificate from FR-003 (SNI). Staging keeps `cloudfront_default_certificate` and no aliases. **Acceptance**: production plan shows the two aliases; staging plan does not.

- **FR-003**: One ACM certificate in `us-east-1` covers `jlaborda.com` and `www.jlaborda.com`. Validation records are created in the Route 53 hosted zone via Terraform. The first implementation task MUST verify DNS delegation (`dig NS jlaborda.com` returns Route 53 `awsdns` name servers) before ACM validation is expected to succeed. **Acceptance**: after delegation and apply the certificate status is Issued; validation records exist in the zone.

- **FR-004**: Route 53 alias A and AAAA records for the apex and `www` point at the production CloudFront distribution. **Acceptance**: DNS for each name resolves to the distribution; HTTPS works as in the acceptance criteria.

- **FR-005**: A CloudFront Function on viewer-request on the production distribution returns HTTP 301 to `https://jlaborda.com` + path when Host is `www.jlaborda.com`. The existing directory-to-`index.html` rewrite behaviour for the canonical host MUST remain. Implementation MAY extend the existing production rewrite function rather than attach a second viewer-request function (CloudFront allows only one function association per event type). No second distribution and no S3 website redirect bucket. **Acceptance**: the www redirect check in Verification exits 0.

- **FR-006**: Production Hugo `baseURL` (deploy job `--baseURL "${SITE_URL}/"`) and the production GitHub Environment variable `SITE_URL` are `https://jlaborda.com` with no trailing slash. Sitemap and canonical links in the published HTML use that origin. Staging `SITE_URL` is unchanged. **Acceptance**: greps on a production build and the live apex show `https://jlaborda.com`; staging still uses its CloudFront hostname variable.

- **FR-007**: Spec 005's production verify job checks the custom apex (HTTP 200) and the www redirect (HTTP 301 with preserved path). Staging verify is unchanged. **Acceptance**: the FR-007 Verification block exits 0 after the verify workflow edit.

- **FR-008**: After Jorge's apply, `terraform plan` for production site state is clean (no pending changes required for this feature). The old production CloudFront default hostname still serves HTTP 200 for `/`. **Acceptance**: plan exit 0 / no changes; curl of the default hostname returns 200.

- **FR-009**: Terraform MUST NOT manage or delete MX records or email-related TXT records (including SPF) in the `jlaborda.com` hosted zone. Jorge places OVH Zimbra MX/SPF/TXT records by hand. Email mailbox setup is out of scope. **Acceptance**: infra has no resources that create/update/destroy MX or email TXT; apply evidence shows those records remain after apply (AC6).

- **FR-010**: This feature does not add a staging subdomain, other TLDs, `jorgelaborda.com`, or HSTS preload. Infra tasks MUST NOT open until issue #46 T011 is merged on `develop`. Every pull request that creates or changes AWS DNS, ACM, or cost-bearing resources carries `needs-human`. **Acceptance**: task table and Pasos de Jorge record that order; out-of-scope greps find no HSTS preload additions and no `jorgelaborda.com` aliases.

### Key Entities

- **Canonical host**: `jlaborda.com` served as `https://jlaborda.com`.
- **Redirect host**: `www.jlaborda.com`.
- **Registrar**: OVHcloud (external); not Route 53 Domains.
- **Hosted zone**: Public Route 53 zone for `jlaborda.com`, created by hand; read-only in Terraform (`data` source).
- **ACM certificate**: Single `us-east-1` certificate for apex and www.
- **Production distribution**: Existing `infra/site` production stack, extended with aliases, custom certificate, and redirect logic.
- **Email DNS (hand-managed)**: MX and SPF/TXT copied from OVH into Route 53 by Jorge; never owned by Terraform.

## Success Criteria *(mandatory)*

- **SC-001**: `https://jlaborda.com/` returns HTTPS 200 with a valid certificate within one minute of a successful production deploy after this feature.
- **SC-002**: `www.jlaborda.com` returns 301 to the matching path on `https://jlaborda.com`.
- **SC-003**: Published sitemap and canonical links use `https://jlaborda.com`.
- **SC-004**: The previous production CloudFront default hostname still returns 200 for `/`.
- **SC-005**: `terraform plan` for the production site stack is clean after apply.
- **SC-006**: After Terraform apply, Jorge's hand-managed MX and email TXT records for OVH Zimbra are still present unchanged.

## Acceptance Criteria (verifiable)

| ID | Criterion |
|----|-----------|
| AC1 | HTTPS 200 on the apex with a valid certificate. |
| AC2 | 301 with the path preserved for `www.jlaborda.com`. |
| AC3 | Sitemap and canonical links use `https://jlaborda.com`. |
| AC4 | The old `*.cloudfront.net` production URL still serves. |
| AC5 | `terraform plan` is clean after apply. |
| AC6 | Apply does not remove or alter MX or email TXT records Jorge placed by hand. |

## Assumptions

- Jorge completed OVH registration of `jlaborda.com` on 2026-11-09 (renews Nov 2027) and will complete hosted-zone creation, MX/TXT copy, and NS delegation (Pasos de Jorge a–c) before the first infra apply that needs the zone and ACM validation.
- Hosted-zone cost is about 0.50 USD per month for one zone. Domain renewal is billed by OVH, not AWS. Budget alert remains the existing 1 USD monthly AWS Budgets rule.
- Issue #46 (environment secrets) is merged before infra tasks that edit `deploy.yml` / shared deploy surfaces.
- Constitution III already requires ACM in `us-east-1` and `needs-human` for DNS/custom domain work.
- Repository docs never contain AWS account ids, hosted zone ids, distribution ids, bucket names, or CloudFront hostnames.

## Out of Scope

- Email mailbox setup (OVH Zimbra configuration beyond Jorge copying MX/SPF/TXT by hand into Route 53).
- Buying or redirecting `jorgelaborda.com` / `www.jorgelaborda.com` (future work if ever purchased).
- Route 53 domain registration or Terraform-managed domain registration/renewal.
- Terraform-managed hosted zone creation.
- A staging custom subdomain.
- Other TLDs or additional brand domains.
- HSTS preload submission.
- Redirecting the CloudFront default hostname to the custom domain.

## Verification

Commands use environment values; they must not print or commit account ids, bucket names, distribution ids, hosted zone ids, or emails. Placeholders below are names only.

### Delegation (before expecting ACM Issued)

```bash
set -euo pipefail
dig +short NS jlaborda.com | grep -F 'awsdns'
```

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
loc=$(curl -sSI 'https://www.jlaborda.com/now/' | tr -d '\r' | awk 'tolower($1)=="location:"{print $2; exit}')
test "$loc" = "https://jlaborda.com/now/"
code=$(curl -sSI 'https://www.jlaborda.com/now/' | tr -d '\r' | awk 'toupper($1) ~ /^HTTP/{print $2; exit}')
test "$code" = "301"
```

### AC3

```bash
set -euo pipefail
# After a production build with SITE_URL=https://jlaborda.com:
grep -R -F 'https://jlaborda.com' public/sitemap.xml public/**/index.html | head
grep -R -F 'rel="canonical"' public | head
```

### AC4 / AC5 / AC6

```bash
set -euo pipefail
# AC4: SITE_URL_DEFAULT is the production CloudFront domain name from Terraform output (not committed).
code=$(curl -sS -o /dev/null -w '%{http_code}' "${SITE_URL_DEFAULT}/")
test "$code" = "200"
# AC5: Jorge's local plan after apply exits 0 with no changes for production site state.
# AC6: before/after apply, dig MX and dig TXT for jlaborda.com still show Jorge's OVH mail records;
# terraform state lists no MX or email TXT resources for this zone.
```
