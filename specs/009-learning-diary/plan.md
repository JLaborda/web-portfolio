# Implementation Plan: Learning Diary Posts

**Branch**: `009-learning-diary` | **Date**: 2026-11-10 | **Spec**: [spec.md](./spec.md)

**Status**: Draft — short path

**Input**: Feature specification from `/specs/009-learning-diary/spec.md`

**Path**: short (small change)

## Summary

Keep Posts in the main menu and turn it into a weekly English learning diary. Delete or leave unpublished the draft `welcome` placeholder. Publish at least one real first diary entry about what Jorge is doing/learning. Document a light convention for ongoing weekly posts. No PaperMod redesign, no new layouts, no post automation, no `infra/` or workflow edits.

Phase 0/1 design is folded into this plan (content-feature pattern as specs 003/007). No new ADR.

## Technical Context

**Language/Version**: Hugo extended (`HUGO_VERSION` in `.github/workflows/ci.yml`).

**Primary Dependencies**: PaperMod post templates (unchanged). Existing Posts section from feature 001.

**Storage**: Git Markdown under `content/posts/`.

**Testing**: Verification block in [spec.md](./spec.md). Hugo + lychee offline + greps (no welcome stub published; ≥1 post page).

**Target Platform**: Existing staging/production CloudFront. No hosting change.

**Project Type**: Hugo content at repository root.

**Performance Goals**: Static post pages; PaperMod reading time/TOC already configured site-wide.

**Constraints**: English only. No inventing false claims about Jorge’s work. No theme submodule edits. Weekly cadence is a convention, not an automated scheduler in this feature.

**Scale/Scope**: Remove one draft; add ≥1 real post; short convention note in `tasks.md` / this plan. Independent of feature 008.

## Constitution Check

| Principle | Gate | Result |
|-----------|------|--------|
| I. Spec-driven, PO approval | Short path. Docs PR includes `Path: short (small change)`. Jorge merges docs and converge. First-post substance PR may use `needs-human` for Jorge’s approval. | Pass |
| II. Fixed stack | PaperMod untouched; default post layout. | Pass |
| III. AWS hosting | No infra/IAM/DNS. | Pass |
| IV. Verifiable CI | Existing gates + spec Verification. | Pass |
| V. Scoped PRs | `009-learning-diary-tXX` then `chore(009): converge`. | Pass |
| VI. Explainable and cheap | Content-only. | Pass |
| VII. English | Posts and docs English. | Pass |

Re-check after design: Pass.

## Project Structure

```text
specs/009-learning-diary/
├── spec.md
├── checklists/requirements.md
├── plan.md
└── tasks.md
content/posts/
├── _index.md              # keep section index
├── welcome.md             # delete or ensure draft never publishes
└── <first-diary-slug>.md  # new real English entry
```

**Structure Decision**: Content only under `content/posts/`. Do not change `hugo.yaml` menu (Posts already present). Do not edit `themes/PaperMod`.

## Design

### Welcome placeholder

- Prefer **delete** `content/posts/welcome.md` so it cannot be published by mistake.
- Acceptable alternative: keep `draft: true` forever—but deletion is cleaner for AC-W1.

### First diary post

- New file e.g. `content/posts/YYYY-MM-DD-short-slug.md` or PaperMod-friendly slug.
- Required front matter at minimum: `title`, `date`, and not `draft: true` (or `draft: false`).
- Body: English prose about current building/learning (may mention SmartWealthAI, fintech-sec-rag-agent, cert study, portfolio work).
- Agent MAY draft; Jorge approves (`needs-human` on that PR).
- Must not reuse welcome stub wording.

### Light convention (ongoing)

Document in tasks/plan for future posts:

1. Language: English.
2. Intent: what Jorge is doing or learning that week (learning diary), not marketing landing copy.
3. Cadence target: weekly; catch-up posts allowed; no CI enforcer in this feature.
4. Front matter: `title`, `date` (ISO or Hugo date); use `draft: true` until ready.
5. One Markdown file per entry under `content/posts/`.

### Independence from 008

- Builds and merges without About/SmartWealthAI copy being finished.
- May name the same projects; must not edit `content/about.md`, `content/projects/smartwealthai.md`, or `content/now.md` in this feature.

## Out of Scope (plan)

- Hiring placeholder fill (008)
- Second case study (010), email (011), visual (012)
- `/log` TIL product, cross-repo automation, non-English posts
- Changing Search button or menu order

## Implementation notes

- Export `SPECIFY_FEATURE_DIRECTORY=specs/009-learning-diary` on implementation branches.
- Converge title exactly `chore(009): converge`.
