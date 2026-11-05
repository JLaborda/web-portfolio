# ADR 002: Production custom domain jlaborda.com (overrides spec 002 “no custom domain”)

**Status**: Accepted — PR #71 (Jorge's merge of that pull request accepts it)

**Date**: 2026-11-03

**Feature**: [specs/006-custom-domain](../../specs/006-custom-domain/spec.md)

## Context

Spec 002 FR-003 and its Clarifications session stated that each environment is served only on its CloudFront default hostname and that a custom domain, ACM certificate, and Route 53 were out of scope. That kept cost and DNS risk out of the first deploy.

Jorge now needs a memorable production URL that matches his GitHub username while he sends his CV. He will register `jlaborda.com` (primary) and `jorgelaborda.com` by hand in Route 53 with privacy protection and auto-renew. Registration creates the hosted zones.

Constitution III already requires any ACM certificate to live in `us-east-1` and requires `needs-human` for DNS or custom-domain changes. It does not forbid a later feature from owning DNS after the deployment feature deferred it.

## Decision

Production is served at the canonical apex `https://jlaborda.com`. The names `www.jlaborda.com`, `jorgelaborda.com`, and `www.jorgelaborda.com` are aliases on the **same** production CloudFront distribution and return HTTP 301 to `https://jlaborda.com` with the path preserved, implemented in a viewer-request CloudFront Function (combined with the existing Hugo directory rewrite because CloudFront allows only one function per event type).

One ACM certificate in `us-east-1` covers the four names and is DNS-validated through Route 53 records managed in Terraform. Terraform reads the existing hosted zones with data sources; it does not register domains or create zones. Route 53 alias A and AAAA records point at the production distribution.

Production Hugo `baseURL` and the production `SITE_URL` environment variable become `https://jlaborda.com`. Staging stays on its default CloudFront hostname. Spec 005 production verify checks the apex and one redirect.

This decision **overrides** spec 002's “no custom domain” deferral for production only. Spec 002 remains the source of truth for staging and for the rest of the hosting layout.

## Consequences

- Annual domain fees (~15 USD per `.com`) and hosted-zone fees (~0.50 USD per month per zone) appear on the AWS bill; the existing 1 USD monthly budget alert may fire for usage separate from registration invoices.
- Infra and DNS pull requests carry `needs-human`; Jorge applies Terraform and updates `SITE_URL`.
- The old production `*.cloudfront.net` hostname continues to serve; this ADR does not require redirecting it.
- Email/MX, staging subdomains, other TLDs, and HSTS preload remain out of scope.
- Implementation must wait until issue #46 (deploy identifiers as secrets) is merged so `deploy.yml` and related surfaces are not edited in parallel conflict.

## Alternatives

- Second CloudFront distribution or S3 website redirect bucket for the alternate names. Rejected unless a blocker appears; one distribution with a viewer-request function meets the requirement with less cost and state.
- Registering domains from Terraform. Rejected; Jorge registers in the console so renewals and privacy stay under his account actions, and zones already exist after registration.
- Custom domain on staging. Rejected for this feature; staging stays unlisted on the default hostname.
- Keeping only CloudFront default hostnames (spec 002). Rejected for production given CV outreach needs.
