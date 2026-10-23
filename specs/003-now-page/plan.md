# Implementation Plan: Now Page

**Branch**: `003-now-page` | **Date**: 2026-10-23 | **Spec**: [spec.md](./spec.md)

Status: Approved by Jorge — PR #56

**Input**: Feature specification from `/specs/003-now-page/spec.md`

## Summary

Replace the feature 001 placeholder at `content/now.md` with a structured Now page that a hiring manager can read in under 30 seconds. One Markdown file holds Current goal, Building, Learning, Reading, optional Current challenge, and Last updated. A project layout under `layouts/` renders those fields and fails the Hugo build with `errorf` when a required field is missing. A small first-party script under `assets/js/` paints green or amber from Last updated (30-day threshold). The existing main-menu Now → `/now/` entry in `hugo.yaml` stays. No `infra/`, workflow, IAM, or theme-submodule edit.

## Technical Context

**Language/Version**: Hugo extended, version pinned as `HUGO_VERSION` in `.github/workflows/ci.yml` (feature 001). Templates use Hugo's Go template language. Staleness script is plain browser JavaScript (no build step, no npm).

**Primary Dependencies**: PaperMod theme submodule at `themes/PaperMod` tag `v8.0` (unchanged). Project overrides only under `layouts/` and `assets/` (constitution II).

**Storage**: None beyond git. The Now page is static HTML after `hugo`.

**Testing**: Verification blocks in [spec.md](./spec.md). No test framework. Fixture builds prove AC3.

**Target Platform**: Static site on the existing staging and production CloudFront distributions (feature 002). This feature does not change hosting.

**Project Type**: Hugo content + small layout/asset overrides at the repository root.

**Performance Goals**: `/now/` is a single short page. The staleness script is a few dozen lines and runs once on load.

**Constraints**: English only. No third-party scripts. No email, account id, bucket name, distribution id, or CloudFront hostname in content or docs. Routine updates touch only `content/now.md`.

**Scale/Scope**: One content file, one layout (or layout + partial), one JS file, optional small CSS under `assets/css/extended/`, keep existing menu entry.

## Constitution Check

| Principle | Gate | Result |
|-----------|------|--------|
| I. Spec-driven, PO approval | Spec, checklist, plan, and tasks ship in one `docs:` pull request; Jorge merges; Reviewer QA does not review docs. Constitution amendment 3.0.0 is in the same pull request. | Pass |
| II. Fixed stack | PaperMod submodule untouched. Project JS/CSS only under `layouts/` or `assets/`. | Pass |
| III. AWS hosting | No `infra/` or IAM change. | Pass |
| IV. Verifiable CI | Existing hugo, lychee, gitleaks, terraform gates. AC3 is a Hugo failure. AC5 is lychee offline. | Pass |
| V. Scoped PRs | Three intermediate branches plus `chore(003): converge`. | Pass |
| VI. Explainable and cheap | Static page + local script; no new AWS cost. | Pass |
| VII. English | All copy and docs English. | Pass |

## Project Structure

```text
specs/003-now-page/
├── spec.md
├── checklists/requirements.md
├── plan.md
├── tasks.md
└── converge.md                 # written by converge PR
content/
└── now.md                      # single editable source (t02)
layouts/
├── _default/
│   └── now.html                # or equivalent layout name (t01)
└── partials/
    └── extend_footer.html      # load script only on /now/ (t03)
assets/
├── js/
│   └── now-staleness.js        # t03
└── css/extended/
    └── now-staleness.css       # t03, green/amber only
hugo.yaml                       # menu Now entry already present; keep
```

Exact layout filename may be `layouts/_default/now.html` with `layout: now` in front matter, or a partial invoked from a thin single override. The implementation chooses one path and records it in the pull request body; it must not edit `themes/PaperMod`.

## Design

### Content model (`content/now.md`)

Front matter (YAML) carries the fields. Proposed keys (English labels are fixed in the layout, not in the keys):

| Field | Front matter key | Required | Shape |
|-------|------------------|----------|-------|
| Current goal | `current_goal` | yes | string |
| Building | `building` | yes | list of `{ text, url? }` |
| Learning | `learning` | yes | list of `{ text, url? }` |
| Reading | `reading` | yes | string |
| Current challenge | `current_challenge` | no | string; omit or blank → no section |
| Last updated | `last_updated` | yes | `YYYY-MM-DD` |
| Layout | `layout` | yes | `now` (so Hugo picks the project layout) |
| Title | `title` | yes | `Now` |

Body Markdown after front matter MAY be empty; the layout renders from params. Building/Learning `url` values are ordinary `https://` links that lychee will see in `public/now/index.html`.

### Layout validation (AC3)

In the Now layout, for each required field, if the value is missing or (for lists) empty, call `errorf` with a message that includes the human field name (`Current goal`, `Building`, `Learning`, `Reading`, `Last updated`). Validate `last_updated` against a `YYYY-MM-DD` pattern before render. Current challenge: `with` / non-empty check; skip the heading when absent.

### Staleness script (AC4, AC5)

1. Layout emits Last updated in a element that carries `data-last-updated="YYYY-MM-DD"` (and visible ISO text).
2. `assets/js/now-staleness.js` reads that attribute, computes whole local days between that date and today, sets a class `now-staleness--fresh` (< 30) or `now-staleness--stale` (>= 30) on a dedicated element. It does not fetch anything.
3. `layouts/partials/extend_footer.html` (project override of PaperMod's empty stub) includes the fingerprinted asset only when `.RelPermalink` is `/now/`.
4. Optional `assets/css/extended/now-staleness.css` defines the two colours. PaperMod already concatenates `assets/css/extended/*.css` into the site stylesheet; keep rules specific so other pages are unaffected.
5. Without JS, the ISO date remains; the colour element stays unstyled or hidden via a `now-staleness` hook that JS reveals—do not hide the date itself inside a JS-only node.

### Menu (AC1)

`hugo.yaml` already has:

```yaml
menu:
  main:
    - name: Now
      url: /now/
      weight: 2
```

Implementation tasks MUST NOT remove it. No menu redesign.

### Delivery order

1. This `docs:` pull request (spec, plan, tasks, checklist) plus constitution 3.0.0, merged by Jorge.
2. `003-now-page-t01` — layout + required-field `errorf` validation.
3. `003-now-page-t02` — replace `content/now.md` with structured English fields (real activity copy, not the word `placeholder` as the page body).
4. `003-now-page-t03` — JS, CSS, footer hook; prove green/amber and no third-party script.
5. After staging shows `/now/` 200, `chore(003): converge` writes `converge.md`, Reviewer QA signs off, Jorge merges.

## Complexity Tracking

No constitution violations require justification.
