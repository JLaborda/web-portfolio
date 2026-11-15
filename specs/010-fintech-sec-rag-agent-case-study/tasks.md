# Tasks: Fintech SEC RAG Agent Case Study

**Status**: Draft — short path

**Input**: Design documents from `/specs/010-fintech-sec-rag-agent-case-study/`

**Prerequisites**: plan.md, spec.md

**Tests**: No new test framework. Strict TDD: for every task below, the Builder’s first commit on that branch MUST add or run the named failing check (exit non-zero before the implementation exists); the second commit MUST add the product change that makes the same check pass. Reviewer verifies that order in the PR history.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no incomplete dependencies)
- **[Story]**: User story label (US1–US4)
- Every description names file paths, CAs, and the exact failing-test command

On every implementation branch, before Spec Kit scripts, export `SPECIFY_FEATURE_DIRECTORY=specs/010-fintech-sec-rag-agent-case-study`.

## Implementation pull requests

One task per pull request, merged one at a time into `develop`. Converge title: exactly `chore(010): converge`.

| Branch | Task | Requirements | needs-human | Depends on | Verification |
|--------|------|--------------|-------------|------------|--------------|
| `010-fintech-sec-rag-agent-case-study-t01` | T001 | FR-003, CA-3 | No | Docs PR merged | Image path test |
| `010-fintech-sec-rag-agent-case-study-t02` | T002 | FR-001, FR-002, FR-004, FR-007, FR-008, CA-1, CA-2, CA-4 | Yes: Jorge approves case study text | T001 merged | Front-matter greps + hugo page |
| `010-fintech-sec-rag-agent-case-study-t03` | T003 | FR-005, CA-5 | No | T002 merged | Now URL grep + hugo |
| `010-fintech-sec-rag-agent-case-study-t04` | T004 | FR-006, CA-6, converge | Classified by Merge Triage | T001–T003 merged | Full Verification + staging evidence |

## Phase 1: User Story 2 — architecture sketch (P1)

- [X] T001 [US2] Copy the architecture sketch into this repo (CA-3).

  **Failing test (commit 1 — must fail before the image exists):**
  ```bash
  test -f static/images/projects/fintech-sec-rag-agent-sketch.png
  ```

  **Implementation (commit 2):** Copy `docs/images/fintech-sec-rag-agent-sketch.png` from https://github.com/JLaborda/fintech-sec-rag-agent to `static/images/projects/fintech-sec-rag-agent-sketch.png`. Do not invent a substitute image. Do not edit `content/`, layouts, PaperMod, `infra/`, or workflows.

  **Pass check:** re-run the same `test -f` command (exit 0).

## Phase 2: User Story 1 — case study page (P1) 🎯 MVP

- [X] T002 [US1][US4] Add `content/projects/fintech-sec-rag-agent.md` (CA-1, CA-2, CA-4). Label the PR `needs-human` (FR-007). Supersedes the 008 “do not add” note (FR-008).

  **Failing test (commit 1 — must fail before the page exists / is complete):**
  ```bash
  set -euo pipefail
  test -f content/projects/fintech-sec-rag-agent.md
  ! grep -Ei '^draft:[[:space:]]*true' content/projects/fintech-sec-rag-agent.md
  grep -F 'summary:' content/projects/fintech-sec-rag-agent.md
  grep -F 'problem:' content/projects/fintech-sec-rag-agent.md
  grep -F 'architecture_image: /images/projects/fintech-sec-rag-agent-sketch.png' content/projects/fintech-sec-rag-agent.md
  grep -E '^architecture_image_alt:' content/projects/fintech-sec-rag-agent.md
  grep -F 'decisions:' content/projects/fintech-sec-rag-agent.md
  grep -F 'results:' content/projects/fintech-sec-rag-agent.md
  grep -Fi 'OpenSearch' content/projects/fintech-sec-rag-agent.md
  grep -Fi 'AWS' content/projects/fintech-sec-rag-agent.md
  grep -F 'stack:' content/projects/fintech-sec-rag-agent.md
  grep -F 'repo_url: https://github.com/JLaborda/fintech-sec-rag-agent' content/projects/fintech-sec-rag-agent.md
  ! grep -E '^demo_url:' content/projects/fintech-sec-rag-agent.md
  hugo --gc --minify --panicOnWarning --baseURL /
  test -f public/projects/fintech-sec-rag-agent/index.html
  grep -E '<h2>Summary</h2>' public/projects/fintech-sec-rag-agent/index.html
  grep -E '<h2>Results</h2>' public/projects/fintech-sec-rag-agent/index.html
  ! grep -E '<h2>Demo</h2>' public/projects/fintech-sec-rag-agent/index.html
  ```

  **Implementation (commit 2):** Create `content/projects/fintech-sec-rag-agent.md` using the SmartWealthAI schema (`title`, `summary`, `problem`, `architecture_image`, `architecture_image_alt`, `decisions`, `results`, `stack`, `repo_url`). Put honest current status in `results`: pipeline deployed on AWS; OpenSearch indexing is the current blocker; invent no metrics or output screenshots. Draft from the public fintech-sec-rag-agent README / `specs/001-10k-signal-demo`. Omit `demo_url`. Do not set `draft: true`. Do not edit layouts, PaperMod, `infra/`, or workflows.

  **Pass check:** re-run the same command block (exit 0).

## Phase 3: User Story 3 — Now link (P2)

- [ ] T003 [US3] Retarget Now Building to the case study (CA-5).

  **Failing test (commit 1 — must fail while Now still points only at GitHub):**
  ```bash
  set -euo pipefail
  grep -F '/projects/fintech-sec-rag-agent/' content/now.md
  hugo --gc --minify --panicOnWarning --baseURL /
  grep -F '/projects/fintech-sec-rag-agent/' public/now/index.html
  ```

  **Implementation (commit 2):** In `content/now.md`, set the Building entry for `fintech-sec-rag-agent` `url` to `/projects/fintech-sec-rag-agent/` (not only `https://github.com/JLaborda/fintech-sec-rag-agent`). Set `last_updated` to the ISO date of the edit. Do not edit other Building items unless required for a broken link. Do not edit layouts, PaperMod, `infra/`, or workflows.

  **Pass check:** re-run the same command block (exit 0).

## Phase 4: Convergence (CA-6)

- [ ] T004 [US4] Run `/speckit-converge` and add `specs/010-fintech-sec-rag-agent-case-study/converge.md` with the full Verification block from `spec.md`, staging evidence that `/projects/fintech-sec-rag-agent/` renders (CA-6), date, SHA, and verdict `Converged`. Title exactly `chore(010): converge`. Do not edit `spec.md` or `plan.md`.

  **Failing test (commit 1 — must fail before `converge.md` exists with Converged):**
  ```bash
  set -euo pipefail
  test -f specs/010-fintech-sec-rag-agent-case-study/converge.md
  grep -F 'Converged' specs/010-fintech-sec-rag-agent-case-study/converge.md
  # Full feature Verification (CA-1..CA-6 local gates):
  test -f static/images/projects/fintech-sec-rag-agent-sketch.png
  test -f content/projects/fintech-sec-rag-agent.md
  ! grep -Ei '^draft:[[:space:]]*true' content/projects/fintech-sec-rag-agent.md
  grep -F 'repo_url: https://github.com/JLaborda/fintech-sec-rag-agent' content/projects/fintech-sec-rag-agent.md
  ! grep -E '^demo_url:' content/projects/fintech-sec-rag-agent.md
  grep -F '/projects/fintech-sec-rag-agent/' content/now.md
  hugo --gc --minify --panicOnWarning --baseURL /
  test -f public/projects/fintech-sec-rag-agent/index.html
  lychee --offline --root-dir public public
  ```

  **Implementation (commit 2):** Write `converge.md` with Verification results, staging URL/status evidence for the case study page, date, SHA, `Converged`, and the status line required by the constitution for who merges the converge PR. Mark T001–T004 done in `tasks.md` only as allowed by principle V.

  **Pass check:** re-run the same command block (exit 0). Staging evidence remains a documented manual check inside `converge.md` (CA-6).

## Dependencies

- T001 before T002 (page `architecture_image` must resolve to an existing static file for Hugo).
- T002 before T003 (Now must not point at a missing case study).
- T004 after T001–T003 merged and Verification green locally.

## Parallel example

```text
# After docs merge (sequential — image before page before Now):
Agent: 010-fintech-sec-rag-agent-case-study-t01
Agent: 010-fintech-sec-rag-agent-case-study-t02   # needs-human
Agent: 010-fintech-sec-rag-agent-case-study-t03
Agent: 010-fintech-sec-rag-agent-case-study-t04   # chore(010): converge
```

## Notes

- Mark an id `[X]` only in the PR that closes it.
- Do not edit `spec.md` or `plan.md` in implementation PRs.
- Do not change the fintech-sec-rag-agent upstream repo; do not “fix” OpenSearch indexing.
- Invent no metrics, results, or output screenshots.
