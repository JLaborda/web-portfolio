# Implementation Plan: Hiring Content Wave

**Branch**: `008-hiring-content` | **Date**: 2026-11-10 | **Spec**: [spec.md](./spec.md)

**Status**: Draft — short path

**Input**: Feature specification from `/specs/008-hiring-content/spec.md`

**Path**: short (small change)

## Summary

Complete the hiring surface left as placeholders by feature 007: real home profile headline (Jorge-supplied), real About prose (Jorge-supplied), complete SmartWealthAI case study (agent draft from SmartWealthAI materials, Jorge approves; honest results; keep existing architecture PNG), and `/now/` Building aligned to SmartWealthAI + fintech-sec-rag-agent (drop health-stream-xai). No new layouts, no PaperMod restyle, no email, no second case study page, no `infra/` or workflow edits.

Phase 0/1 design is folded into this plan (same pattern as specs 003/007 for content features). No new ADR.

## Technical Context

**Language/Version**: Hugo extended, version pinned as `HUGO_VERSION` in `.github/workflows/ci.yml`.

**Primary Dependencies**: PaperMod `themes/PaperMod` tag `v8.0` (unchanged). Existing `layouts/_default/project.html` and `layouts/_default/now.html` from features 003/007.

**Storage**: Git only. Content under `content/`; existing diagram at `static/images/projects/smartwealthai-credit-architecture.png`; CV already at `static/cv/jorge-laborda-cv.pdf`.

**Testing**: Verification block in [spec.md](./spec.md). No new test framework. Hugo `--panicOnWarning`, lychee offline, grep guards for `PLACEHOLDER` / `Placeholder headline` / Building alignment.

**Target Platform**: Existing staging/production CloudFront (feature 002/006). No hosting change.

**Project Type**: Hugo content + `hugo.yaml` param edit at repository root.

**Performance Goals**: Static pages only; no client-side generation beyond existing Now staleness script.

**Constraints**: English only. No invented biography, positioning claim, or metrics. No `mailto:` / email. No Mermaid. No theme submodule edits. No account ids or infra identifiers in content.

**Scale/Scope**: Four surfaces — home subtitle, About, one case study file, Now front matter. One feature docs PR; small implementation PRs; converge.

## Constitution Check

| Principle | Gate | Result |
|-----------|------|--------|
| I. Spec-driven, PO approval | Short path: specify → plan → tasks → implement → converge. Docs PR must include exact line `Path: short (small change)`. Jorge merges docs and converge. Content PRs that publish Jorge’s voice / case study approval carry `needs-human` when his personal verification is required. | Pass |
| II. Fixed stack | PaperMod untouched; no new theme; reuse project/now layouts. | Pass |
| III. AWS hosting | No `infra/`, IAM, DNS, or domain change. | Pass |
| IV. Verifiable CI | Existing hugo / lychee / gitleaks / terraform gates; spec Verification greps. | Pass |
| V. Scoped PRs | Intermediate `008-hiring-content-tXX` then `chore(008): converge`. | Pass |
| VI. Explainable and cheap | Content-only; no new AWS cost. | Pass |
| VII. English | All public copy and feature docs English. | Pass |

Re-check after design: still Pass. No Complexity Tracking table needed.

## Project Structure

```text
specs/008-hiring-content/
├── spec.md
├── checklists/requirements.md
├── plan.md                 # this file
└── tasks.md
content/
├── about.md                # Jorge prose replaces PLACEHOLDER
├── now.md                  # Building list sync
└── projects/
    └── smartwealthai.md    # complete case study; no PLACEHOLDER
hugo.yaml                   # params.profileMode.subtitle only (headline)
static/images/projects/
└── smartwealthai-credit-architecture.png   # keep unless Jorge replaces
```

**Structure Decision**: Content and config only. Do not add layouts, assets CSS, workflows, or `infra/`.

## Design

### Home headline

- Edit `params.profileMode.subtitle` in `hugo.yaml` from `Placeholder headline` to Jorge’s exact English positioning string.
- Agents MUST NOT invent the string. Wire only after Pasos de Jorge delivers it (or Jorge commits it himself).

### About

- Replace all `PLACEHOLDER` sections in `content/about.md` with Jorge’s bio, stack, certifications.
- Keep LinkedIn / GitHub / CV download; no email.
- Agents MUST NOT invent biography; format/links only once text exists.

### SmartWealthAI

- Keep FR-002 schema and existing `architecture_image` path unless Jorge supplies a new image.
- Replace every placeholder field and body with real English copy drafted from https://github.com/JLaborda/SmartWealthAI (README/specs) then edited/approved by Jorge.
- `results`: honest qualitative / demo-bounded claims only.
- Optional `demo_url` only if a public demo exists; otherwise omit.

### Now Building

| Keep / add | Link target |
|------------|-------------|
| SmartWealthAI | `https://github.com/JLaborda/SmartWealthAI` (or on-site `/projects/smartwealthai/` if preferred once live—GitHub is fine and matches current Now style) |
| fintech-sec-rag-agent | `https://github.com/JLaborda/fintech-sec-rag-agent` |
| This portfolio (optional) | `https://github.com/JLaborda/web-portfolio` |

Remove `health-stream-xai` from Building. Update `last_updated` when Building changes. Do not create `/projects/fintech-sec-rag-agent/`.

### Authorship

| Surface | Draft | Approve |
|---------|-------|---------|
| Home headline | Jorge | Jorge |
| About | Jorge | Jorge |
| SmartWealthAI | Agent | Jorge (`needs-human` on that PR) |
| Now Building | Agent | Reviewer QA (unless Jorge wants `needs-human`) |

## Out of Scope (plan)

- fintech-sec-rag-agent case study page (010)
- Public email (011)
- Visual elegance (012)
- CI leftovers (#91, #46, #70, #84, #76)
- Posts diary (009)

## Implementation notes

- Export `SPECIFY_FEATURE_DIRECTORY=specs/008-hiring-content` on implementation branches.
- One task id per implementation PR into `develop`; mark `[X]` in `tasks.md` in that PR.
- Converge title exactly `chore(008): converge`.
