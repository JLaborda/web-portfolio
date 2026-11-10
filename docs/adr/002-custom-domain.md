# ADR 002: Production custom domain jlaborda.com (overrides spec 002 “no custom domain”)

**Status**: Accepted — PR #71 (Jorge's merge of that pull request accepts it)

**Date**: 2026-11-03 (updated 2026-11-09)

**Feature**: [specs/006-custom-domain](../../specs/006-custom-domain/spec.md)

## Context

Spec 002 FR-003 and its Clarifications session stated that each environment is served only on its CloudFront default hostname and that a custom domain, ACM certificate, and Route 53 were out of scope. That kept cost and DNS risk out of the first deploy.

Jorge bought `jlaborda.com` at an external registrar (**OVHcloud**) on 9 Nov 2026 (1 year, renews Nov 2027) so production can use a memorable URL that matches his GitHub username. Route 53 domain registration is not used. `jorgelaborda.com` was not purchased and is out of scope.

Constitution III already requires any ACM certificate to live in `us-east-1` and requires `needs-human` for DNS or custom-domain changes. It does not forbid a later feature from owning DNS after the deployment feature deferred it.

## Decision

Production is served at the canonical apex `https://jlaborda.com`. The name `www.jlaborda.com` is an alias on the **same** production CloudFront distribution and returns HTTP 301 to `https://jlaborda.com` with the path preserved, implemented in a viewer-request CloudFront Function (combined with the existing Hugo directory rewrite because CloudFront allows only one function per event type).

Jorge creates the public Route 53 hosted zone for `jlaborda.com` **by hand** in the AWS console and delegates the domain at OVH by setting the zone's four name servers. Terraform reads that zone with `data "aws_route53_zone"` by name; it does not register the domain, renew it, or create the hosted zone. Terraform adds only ACM DNS validation records (certificate in `us-east-1` for apex and www) and Route 53 alias A/AAAA records for apex and www to the production distribution. Terraform must not manage or delete MX or email TXT records that Jorge copies from OVH Zimbra into the zone by hand.

Production Hugo `baseURL` and the production `SITE_URL` environment variable become `https://jlaborda.com`. Staging stays on its default CloudFront hostname. Spec 005 production verify checks the apex and the www redirect. The first implementation task verifies NS delegation (`dig NS` → `awsdns`) before ACM validation is expected to pass.

This decision **overrides** spec 002's “no custom domain” deferral for production only. Spec 002 remains the source of truth for staging and for the rest of the hosting layout.

## Consequences

- Domain renewal is billed by OVH; AWS bills ~0.50 USD/month for one hosted zone. The existing 1 USD monthly budget alert covers AWS usage, not OVH invoices.
- Infra and DNS pull requests carry `needs-human`; Jorge applies Terraform and updates `SITE_URL`.
- The old production `*.cloudfront.net` hostname continues to serve; this ADR does not require redirecting it.
- Email mailbox setup remains out of scope; mail DNS stays hand-managed so apply cannot break Zimbra.
- `jorgelaborda.com` redirects/aliases are future work if that name is ever purchased.
- Implementation must wait until issue #46 (deploy identifiers as secrets) is merged and Jorge's hosted-zone + NS delegation steps are done.
- Docs and code must never commit account ids, hosted zone ids, distribution ids, bucket names, or CloudFront hostnames.

## Alternatives

- Second CloudFront distribution or S3 website redirect bucket for www. Rejected unless a blocker appears; one distribution with a viewer-request function meets the requirement with less cost and state.
- Registering the domain in Route 53 Domains (or from Terraform). Rejected; Jorge already registered at OVHcloud and keeps renewal there.
- Terraform-managed `aws_route53_zone`. Rejected; Jorge creates the zone by hand so NS delegation and mail records stay under his console steps; Terraform only adds app records.
- Buying and redirecting `jorgelaborda.com` in this feature. Rejected; that name was not purchased.
- Managing MX/TXT in Terraform. Rejected; risk of destroying OVH Zimbra DNS on apply.
- Custom domain on staging. Rejected for this feature; staging stays unlisted on the default hostname.
- Keeping only CloudFront default hostnames (spec 002). Rejected for production given CV outreach needs.
