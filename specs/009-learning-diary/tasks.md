# Tasks: Learning Diary Posts

**Status**: Draft — short path

**Input**: Design documents from `/specs/009-learning-diary/`

**Prerequisites**: plan.md, spec.md, checklists/requirements.md

**Tests**: No test framework. Each implementation PR runs named Verification checks.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel
- **[Story]**: US1–US3
- Every description names a file path

Export `SPECIFY_FEATURE_DIRECTORY=specs/009-learning-diary` on implementation branches.

## Implementation pull requests

| Branch | Task | Requirements | needs-human | Depends on | Verification |
|--------|------|--------------|-------------|------------|--------------|
| `009-learning-diary-t01` | T001 | FR-002, AC-W1 | No | Docs PR merged | `welcome` not published; hugo; Posts menu present |
| `009-learning-diary-t02` | T002 | FR-001, FR-003, FR-004, FR-005, AC-M1, AC-P1, AC-C1, AC-OWN1 | Yes: Jorge approves first post | T001 merged (or same PR only if both land together—prefer separate) | ≥1 published post; no welcome stub text; convention noted; hugo; lychee |
| `009-learning-diary-t03` | T003 | Converge SC-001–SC-004 | No (Jorge merges) | T001–T002 | `converge.md` verdict `Converged` + full Verification |

## Phase 1: User Story 1 — remove welcome placeholder

- [ ] T001 [US1] Delete `content/posts/welcome.md` (preferred) or prove it remains `draft: true` and is absent from `public/posts/` after hugo. Do not publish placeholder stub content. Do not edit PaperMod, `infra/`, or unrelated content files (`about.md`, `now.md`, projects).

## Phase 2: User Stories 1–3 — first diary entry + convention 🎯 MVP

- [ ] T002 [US1][US2][US3] Add one real English learning-diary post under `content/posts/` (new Markdown file with `title`, `date`, not draft). Topic = current work/learning. Draft may come from an agent; open PR with `needs-human` for Jorge’s edit/approval. Ensure Posts remains in `hugo.yaml` menu (already present—do not remove). Record the light weekly convention in this `tasks.md` Notes (already below) or a short comment in the PR body pointing here (AC-C1). Do not change theme visuals.

## Phase 3: Convergence

- [ ] T003 Run `/speckit-converge` and add `specs/009-learning-diary/converge.md` with Verification evidence, date, SHA, verdict `Converged`. Title exactly `chore(009): converge`. Do not edit `spec.md` or `plan.md`.

## Pasos de Jorge

1. **Merge the feature `docs:` pull request** (#95) when satisfied (`Path: short (small change)`).
2. **Approve/edit the first diary post** on the T002 PR (substance must be true to his week).
3. **Merge** `chore(009): converge` after Reviewer QA.
4. **Release `develop` → `main`** when he wants production.
5. **Ongoing**: add weekly posts under `content/posts/` following the convention below.

## Diary convention (AC-C1)

1. English only.
2. Topic: what Jorge is doing or learning (weekly learning diary).
3. Cadence target: weekly; catch-up OK; no automation in this feature.
4. Front matter: `title`, `date`; `draft: true` until ready to publish.
5. One Markdown file per entry in `content/posts/`.

## Dependencies

- T002 should follow T001 so the list never shows only a deleted welcome with zero posts mid-flight for long; if combined, the single PR must both delete welcome and add the real post.
- T003 after T001–T002.
- Independent of 008 merge state.

## Parallel with 008

```text
# After both docs PRs merge:
Agent A: 008-hiring-content-t01 / t02
Agent B: 009-learning-diary-t01 then t02
# Avoid same-file conflicts (008 and 009 touch different paths)
```

## Notes

- Mark `[X]` only in the closing PR.
- Do not edit `spec.md` or `plan.md` in implementation PRs.
- Do not author SmartWealthAI/About/Now changes here.
