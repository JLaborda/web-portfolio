# Implementation Plan: Fintech SEC RAG Agent Case Study

**Branch**: `010-fintech-sec-rag-agent-case-study` | **Date**: 2026-11-15 | **Spec**: [spec.md](./spec.md)

**Status**: Draft — short path

**Input**: Feature specification from `/specs/010-fintech-sec-rag-agent-case-study/spec.md`

**Path**: short (small change)

## Summary

Add a second hiring case study for fintech-sec-rag-agent using the existing project schema and layouts: copy the public architecture sketch into `static/images/projects/`, author `content/projects/fintech-sec-rag-agent.md` with honest AWS + OpenSearch-blocker status in `results` (no invented metrics, no `demo_url`), and retarget the Now Building link from GitHub-only to `/projects/fintech-sec-rag-agent/`. Content PR carries `needs-human`. No theme, layout, `infra/`, or CI changes.

Phase 0/1 design is folded into this plan (same pattern as specs 003/007/008 for content features). No new ADR.

## Technical Context

**Language/Version**: Hugo extended, version pinned as `HUGO_VERSION` in `.github/workflows/ci.yml`.

**Primary Dependencies**: PaperMod `themes/PaperMod` (unchanged). Existing `layouts/_default/project.html` and Now layout from features 003/007.

**Storage**: Git only. New PNG under `static/images/projects/`; new Markdown under `content/projects/`; edit `content/now.md`. Source sketch: `docs/images/fintech-sec-rag-agent-sketch.png` in https://github.com/JLaborda/fintech-sec-rag-agent.

**Testing**: Verification block in [spec.md](./spec.md). No new test framework. Strict TDD per constitution: each Builder task commits the failing check command(s) before the content/asset commit. Hugo `--panicOnWarning`, lychee offline, front-matter greps.

**Target Platform**: Existing staging/production CloudFront. No hosting change.

**Project Type**: Hugo content + static asset at repository root.

**Performance Goals**: Static page only.

**Constraints**: English only. No invented metrics/results. No Mermaid. No theme submodule edits. No `infra/` or workflow edits. No changes to the upstream fintech-sec-rag-agent repo. Do not fix OpenSearch indexing.

**Scale/Scope**: One PNG, one project Markdown file, one Now front-matter URL (and `last_updated`). Docs PR + small implementation PRs + converge.

## Constitution Check

| Principle | Gate | Result |
|-----------|------|--------|
| I. Spec-driven, software factory | Short path: specify → plan → tasks → implement → converge. Docs PR description MUST include exact line `Path: short (small change)`. Checklist files and analyze report are not required. Content PR carries `needs-human`. | Pass |
| II. Fixed stack | PaperMod untouched; reuse project/now layouts; no new theme CSS/JS. | Pass |
| III. AWS hosting | No `infra/`, IAM, OIDC, DNS, or domain change. | Pass |
| IV. Verifiable CI | Existing hugo / lychee / gitleaks gates; spec Verification greps. | Pass |
| V. Scoped PRs + strict TDD | Intermediate `010-fintech-sec-rag-agent-case-study-tXX`; failing-test commit before code commit; `chore(010): converge`. | Pass |
| VI. Explainable and cheap | Content-only; no new AWS cost or dependencies. | Pass |
| VII. English | All public copy and feature docs English. | Pass |

Re-check after design: still Pass. No Complexity Tracking table needed.

## Project Structure

```text
specs/010-fintech-sec-rag-agent-case-study/
├── spec.md
├── plan.md                 # this file
└── tasks.md
content/
├── now.md                  # Building URL retarget + last_updated
└── projects/
    ├── _index.md           # unchanged cascade
    ├── smartwealthai.md    # unchanged
    └── fintech-sec-rag-agent.md   # new case study
static/images/projects/
├── smartwealthai-credit-architecture.png
└── fintech-sec-rag-agent-sketch.png   # copied from source repo
layouts/_default/project.html         # unchanged
```

**Structure Decision**: Content and one static image only. Do not add layouts, assets CSS, workflows, or `infra/`.

## Design

### Case study page

- New file `content/projects/fintech-sec-rag-agent.md` with the same front-matter shape as `content/projects/smartwealthai.md`.
- Map issue “current status” onto required field `results` (heading “Results” in the layout). Prose MUST include: pipeline deployed on AWS; OpenSearch indexing is the current blocker; no fabricated metrics.
- Omit `demo_url`. Set `repo_url: https://github.com/JLaborda/fintech-sec-rag-agent`.
- Do not set `draft: true`.
- Optional body prose after front matter is allowed if it adds context without inventing metrics; keep primary facts in front-matter fields the layout renders.
- Draft from public README / `specs/001-10k-signal-demo` in the source repo; Jorge approves via `needs-human` on that PR.

### Architecture image

- Copy `docs/images/fintech-sec-rag-agent-sketch.png` from https://github.com/JLaborda/fintech-sec-rag-agent to `static/images/projects/fintech-sec-rag-agent-sketch.png` in this repo (Builder copies the binary; Planner does not).
- Front matter: `architecture_image: /images/projects/fintech-sec-rag-agent-sketch.png` and English `architecture_image_alt` describing components/flow only.

### Now page

- In `content/now.md`, change the Building item `text: fintech-sec-rag-agent` so `url` is `/projects/fintech-sec-rag-agent/` (or an equivalent site path that resolves to that page).
- Update `last_updated` to the ISO date of the edit.
- Leave SmartWealthAI and portfolio Building entries unchanged unless a link break forces a fix (out of intent).

### Authorship and merge

- Docs PR: Planner; short path; no product code.
- Image and/or Now PRs: Builder; Reviewer; Merge Triage when green.
- Case study prose PR: Builder; MUST label `needs-human`; Jorge merges after text approval.
- Converge: Builder runs `/speckit-converge`; records staging evidence for CA-6.

## Implementation order

1. Copy sketch into `static/images/projects/` (CA-3 asset).
2. Add case study Markdown (CA-1, CA-2, CA-4) with `needs-human`.
3. Retarget Now Building URL (CA-5).
4. Converge with full Verification + staging check (CA-6).

## Complexity Tracking

None.
