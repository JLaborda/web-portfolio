# Feature Specification: Now Page

**Feature Branch**: `003-now-page`

**Created**: 2026-10-23

Status: Approved by Jorge — PR #56

**Input**: User description: "A hiring manager visiting the portfolio sees what Jorge is working on right now (proof of activity) in under 30 seconds. The /now page shows Current goal, Building, Learning, Reading, Current challenge (optional), and Last updated. Jorge updates it by editing a single Markdown file. Main menu keeps a Now link. Staleness colour is computed in the browser with a small local script (green if Last updated is under 30 days ago, amber if 30 days or older). English only. Out of scope: /log (TIL), automation from SmartWealthAI/health-stream-xai, other languages, any staleness alert beyond the colour."

Numbers 003 and 004 are reserved: 003 is this Now page; 004 is reserved for later Now/log automation and is not opened by this feature.

## Clarifications

### Session 2026-10-23

- Q: Which fields appear on `/now/`, and which are required? → A: Current goal, Building, Learning, Reading, Current challenge, and Last updated. All are required except Current challenge (optional). Building and Learning each accept a short list with links.
- Q: How does Jorge update `/now/`? → A: By editing a single Markdown file and merging. He does not edit templates, layouts, assets, or `hugo.yaml` for a routine update.
- Q: How is staleness shown? → A: A small local JavaScript file (no third-party scripts, no dependencies) paints green when Last updated is less than 30 days ago and amber when it is 30 days or older. With JavaScript disabled, only the ISO date shows and the page still works; there are no console errors.
- Q: Language and navigation? → A: English only. The main menu has a "Now" link to `/now/` (already present from feature 001; this feature keeps it).
- Q: What is out of scope? → A: The `/log` (TIL) page; all automation (PR injection from SmartWealthAI/health-stream-xai, TIL drafts, a staleness GitHub Action); other languages; any staleness alert other than the colour.

## Context

Feature 001 shipped a placeholder at `content/now.md` and a main-menu item labeled Now that points to `/now/`. That page still says it is a placeholder. A hiring manager cannot tell what Jorge is building or learning, or whether the page is current.

This feature replaces that placeholder with a structured Now page whose six fields are the product owner's list. The page is the proof of activity. Routine updates stay a one-file Markdown edit so Jorge does not touch templates.

Feature 004 (not opened here) may later automate updates and alerts. This feature only delivers the page, the local colour indicator, and the single-file edit path.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Hiring manager reads what is current (Priority: P1)

A hiring manager opens `/now/` and, within about 30 seconds, understands what Jorge is building and learning right now.

**Why this priority**: Without a clear current picture, the portfolio does not prove activity.

**Independent Test**: Build the site. Open `/now/`. The Current goal, Building, Learning, and Reading sections are visible with English content. Building and Learning show short lists that may include links. The page is reachable from the main menu label Now.

**Acceptance Scenarios**:

1. **Given** the published site on staging, **When** a visitor opens `/now/`, **Then** the response is HTTP 200 and the main menu contains a link labeled Now whose destination is `/now/`.
2. **Given** the published `/now/` page, **When** a visitor reads it, **Then** they see Current goal, Building, Learning, Reading, and Last updated, and they can name what Jorge is building and learning without opening another page.
3. **Given** Building or Learning entries that include URLs, **When** the visitor follows those links, **Then** the destinations are the URLs written in the Markdown file.

---

### User Story 2 - Hiring manager sees freshness (Priority: P2)

A hiring manager sees when `/now/` was last updated and, with JavaScript enabled, sees a green or amber indicator so they know if the page is current.

**Why this priority**: An undated Now page cannot be trusted as proof of activity.

**Independent Test**: Build the site with a Last updated date. With JavaScript enabled, a date under 30 days ago is green and a date 30 days ago or older is amber. With JavaScript disabled, only the ISO date is visible and the page still renders.

**Acceptance Scenarios**:

1. **Given** Last updated is set to an ISO date, **When** the page renders, **Then** that date is shown in ISO format (`YYYY-MM-DD`).
2. **Given** JavaScript is enabled and Last updated is less than 30 days before "today" in the browser, **When** the page loads, **Then** the staleness indicator is green.
3. **Given** JavaScript is enabled and Last updated is 30 days ago or older, **When** the page loads, **Then** the staleness indicator is amber.
4. **Given** JavaScript is disabled, **When** the page loads, **Then** only the ISO date shows, the page remains readable, and the browser console has no errors caused by this page's script.

---

### User Story 3 - Jorge updates one Markdown file (Priority: P3)

Jorge updates `/now/` by editing a single Markdown file and merging. He does not edit templates, layouts, assets, or site configuration for that update.

**Why this priority**: A Now page that requires template edits will go stale.

**Independent Test**: Change only the Now Markdown file's field values, rebuild, and confirm the published page shows the new values. No other path under `layouts/`, `assets/`, or `hugo.yaml` changes for that update.

**Acceptance Scenarios**:

1. **Given** a routine content update, **When** Jorge edits only the Now Markdown file and merges, **Then** `/now/` shows the new field values after deploy.
2. **Given** Current challenge is omitted from that file, **When** the site builds, **Then** the build succeeds and the published page does not render a Current challenge heading or empty section.
3. **Given** any required field is missing from that file, **When** Hugo builds with `--panicOnWarning`, **Then** the build fails and the error text names the missing field.

### Edge Cases

- Current challenge absent: no heading, no empty section, build succeeds.
- Current challenge present but blank after trim: treat as absent (do not render the section).
- Building or Learning is an empty list: that is a missing required field; the build fails and names the field.
- Building or Learning entries without a link: allowed; the entry still renders as text.
- Last updated is not a valid `YYYY-MM-DD` calendar date: the build fails and names Last updated.
- Last updated exactly 30 days before the browser's local "today": amber (threshold is `>= 30` days).
- The visitor has JavaScript disabled or the script fails to load: the ISO date remains visible; no third-party request is attempted.
- Feature 001's placeholder word `placeholder` must not remain as the only body of `/now/` after this feature ships.
- The main menu must keep exactly the four labels from feature 001 (Projects, Now, About, Posts). This feature does not add Search to the menu.
- Broken external links in Building or Learning do not fail the merge (lychee external step is warning-only per constitution IV). Internal links must pass the offline lychee check.
- No email address, AWS account id, bucket name, distribution id, or CloudFront hostname appears in the Now Markdown file, the layout, the script, or this specification.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The site MUST publish `/now/` at HTTP 200 on staging after this feature's content is on `develop` and deployed. The main menu (`ul#menu`) MUST contain a link whose visible label is `Now` and whose destination is `/now/`. Feature 001 already added that menu entry in `hugo.yaml`; this feature MUST keep it. **Acceptance**: AC1 — staging `/now/` returns 200; the menu check in Verification exits 0.

- **FR-002**: The Now page MUST render these sections with English headings exactly: `Current goal`, `Building`, `Learning`, `Reading`, `Current challenge`, and `Last updated`. Current challenge MUST be omitted from the HTML when the field is absent or blank. Building and Learning MUST render as short lists; each item MAY include a link whose `href` is the URL from the Markdown file. **Acceptance**: AC2 — Verification finds the five always-present headings and confirms Current challenge is absent when the field is omitted.

- **FR-003**: The Now page source MUST be a single Markdown file at `content/now.md`. A routine update MUST require editing only that file. Layouts, assets, and `hugo.yaml` MUST NOT need changes for a field-value update. **Acceptance**: AC6 — Verification shows that changing only `content/now.md` updates the published fields.

- **FR-004**: Hugo MUST fail the build when any required field is missing. Required fields are Current goal, Building, Learning, Reading, and Last updated. The error message MUST name the missing field (for example `Current goal`). Current challenge MUST NOT be required. **Acceptance**: AC3 — a fixture that drops each required field fails the build with that field's name; a fixture that only omits Current challenge builds successfully.

- **FR-005**: Last updated MUST be an ISO calendar date `YYYY-MM-DD` in the Markdown file and MUST appear in that same format on the page. With the local script enabled, the staleness indicator MUST be green when the date is less than 30 local days before today, and amber when it is 30 local days ago or older. With the script disabled, only the date shows and the page remains usable. **Acceptance**: AC4 — Verification checks the ISO date in HTML and the script's 30-day threshold; a no-JS reading still shows the date.

- **FR-006**: The staleness script MUST be a first-party file under `assets/` (or loaded only from this repository's published assets). It MUST NOT load any third-party script, stylesheet, or beacon. It MUST NOT add a runtime dependency. Lychee MUST pass its required internal check on the published tree that includes the Building and Learning links. **Acceptance**: AC5 — Verification finds no third-party script URL on `/now/`; `lychee --offline --root-dir public public` exits 0.

- **FR-007**: Site language remains English only. This feature MUST NOT add `i18n/` locales, a second `defaultContentLanguage`, or translated Now copy. **Acceptance**: Verification confirms `defaultContentLanguage: en` and English headings on `/now/`.

- **FR-008**: This feature MUST NOT add `/log`, TIL automation, PR injection from SmartWealthAI or health-stream-xai, a GitHub Action that warns on staleness, analytics, a contact form, or any change under `infra/` or to IAM, secrets, region, DNS, cost, or branch protection. **Acceptance**: the FR-008 guard in Verification exits 0.

### Key Entities

- **Now page**: The published page at `/now/`, sourced from `content/now.md`, showing the six fields.
- **Now fields**: Current goal (text), Building (list, optional links), Learning (list, optional links), Reading (text), Current challenge (optional text), Last updated (`YYYY-MM-DD`).
- **Staleness indicator**: Browser-side green/amber mark derived only from Last updated and the visitor's local date; absent when JavaScript is off.

## Success Criteria *(mandatory)*

- **SC-001**: A hiring manager reaches `/now/` from the main menu and, within about 30 seconds, can state Jorge's current goal and at least one Building and one Learning item.
- **SC-002**: A hiring manager can see the Last updated ISO date on every visit; with JavaScript on, they also see green or amber according to the 30-day rule.
- **SC-003**: Jorge updates `/now/` by editing only `content/now.md` and merging; no template edit is required for that update.
- **SC-004**: A missing required field fails CI's Hugo job with an error that names the field; omitting Current challenge does not.

## Acceptance Criteria (verifiable)

| ID | Criterion |
|----|-----------|
| AC1 | `/now/` returns 200 on staging and the main menu has a Now link to `/now/`. |
| AC2 | The six fields render; if Current challenge is absent its section is not rendered (no empty heading). |
| AC3 | If any required field is missing, the Hugo build fails with an error naming the missing field. |
| AC4 | Last updated shows the date in ISO format; with JS, green if under 30 days and amber if 30 days or older; with JS disabled only the date shows and there are no console errors from this page. |
| AC5 | The script is local (no third-party requests); lychee passes with the Building/Learning links. |
| AC6 | Updating `/now/` only requires editing one Markdown file (`content/now.md`). |

## Assumptions

- Feature 001's menu entry for Now remains on `develop` when implementation starts; tasks keep it rather than re-adding it from scratch.
- Staging deploy from `develop` remains the path that makes AC1's HTTP 200 check possible after the content pull request merges.
- PaperMod's `extend_footer.html` / `extend_head.html` project overrides under `layouts/partials/` are the supported place to attach the Now script without editing `themes/PaperMod`.
- Constitution II allows project JS and CSS only under `layouts/` or `assets/`.

## Out of Scope

- The `/log` (TIL) page (future feature).
- Automation: PR injection from SmartWealthAI or health-stream-xai, TIL drafts, a staleness GitHub Action (reserved for feature 004 or later).
- Other languages.
- Any staleness alert other than the green/amber colour.
- Changes to AWS infrastructure, IAM, secrets, region, DNS, cost, or branch protection.

## Verification

Commands run from the repository root unless noted. Do not print or commit an AWS account id, bucket name, distribution id, CloudFront hostname, or email.

### AC1 / FR-001 (menu and published path)

```bash
set -euo pipefail
hugo --gc --minify --panicOnWarning --baseURL /
test -f public/now/index.html
menu=$(sed -n '/<ul id="menu"/,/<\/ul>/p' public/index.html)
printf '%s\n' "$menu" | grep -F 'Now'
printf '%s\n' "$menu" | grep -E 'href="?/now/"?([[:space:]>]|$)'
grep -E '^[[:space:]]*- name: Now$' hugo.yaml
grep -E '^[[:space:]]*url: /now/$' hugo.yaml
```

Staging 200 (after the content task is on `develop` and deployed): `curl -sS -o /dev/null -w '%{http_code}' "${SITE_URL}/now/"` prints `200`. `SITE_URL` comes from the staging Environment variable; it is never written into this repository.

### AC2 / FR-002 (fields render; optional challenge omitted)

```bash
set -euo pipefail
hugo --gc --minify --panicOnWarning --baseURL /
page=public/now/index.html
for h in 'Current goal' 'Building' 'Learning' 'Reading' 'Last updated'; do
  grep -F "$h" "$page"
done
# When content/now.md has no current_challenge (or blank), the heading must be absent:
if grep -E 'current_challenge:[[:space:]]*[^[:space:]]' content/now.md; then
  grep -F 'Current challenge' "$page"
else
  if grep -F 'Current challenge' "$page"; then exit 1; fi
fi
```

### AC3 / FR-004 (required-field build failures)

```bash
set -euo pipefail
# Implementation provides a documented way to run these fixtures (copy or env).
# Each required field missing must make hugo exit non-zero and name the field.
# Omitting only Current challenge must make hugo exit 0.
```

The implementation pull request that adds validation pastes the exact fixture commands and their exit statuses in the pull request body.

### AC4 / FR-005 (ISO date and staleness script)

```bash
set -euo pipefail
hugo --gc --minify --panicOnWarning --baseURL /
grep -E '[0-9]{4}-[0-9]{2}-[0-9]{2}' public/now/index.html
# Script is present and first-party:
grep -F 'now-staleness' public/now/index.html
# Threshold of 30 days is in the local script source under assets/:
grep -E '30' assets/js/now-staleness.js
```

Manual: with JS on, a Last updated of today is green; a Last updated of 40 days ago is amber. With JS off, only the date shows.

### AC5 / FR-006 (local script; lychee)

```bash
set -euo pipefail
hugo --gc --minify --panicOnWarning --baseURL /
# No third-party script hosts on the Now page:
if grep -E 'src="https?://' public/now/index.html; then exit 1; fi
lychee --offline --root-dir public public
```

### AC6 / FR-003 (single-file update)

```bash
set -euo pipefail
# Documented in plan.md: a content-only commit touches only content/now.md.
# After rebuild, public/now/index.html contains the new Current goal string.
```

### FR-007 / FR-008 guards

```bash
set -euo pipefail
grep -E '^defaultContentLanguage: *en$' hugo.yaml
if git diff --name-only origin/develop...HEAD | grep -E '^(infra/|\.github/workflows/)'; then exit 1; fi
if grep -R -E 'health-stream-xai|SmartWealthAI.*inject|/log/' layouts assets content/now.md 2>/dev/null; then exit 1; fi
```
