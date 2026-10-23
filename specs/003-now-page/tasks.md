# Tasks: Now Page

Status: Approved by Jorge — PR #N

**Input**: Design documents from `/specs/003-now-page/`

**Prerequisites**: plan.md, spec.md, checklists/requirements.md

**Tests**: No test framework. Each implementation pull request runs the Verification blocks named for it in `spec.md`.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: User story label.
- Every description names a file path.

On every implementation branch, before Spec Kit scripts, export `SPECIFY_FEATURE_DIRECTORY=specs/003-now-page`.

## Implementation pull requests

One task per pull request, merged one at a time into `develop`. Each pull request lists its task id in the description and marks it `[X]` here. One cloud agent per implementation pull request, reused for its fixes. `needs-human` follows constitution I (region, DNS, real AWS cost, IAM or secrets, branch protection); none of these tasks need it. The converge pull request title is exactly `chore(003): converge`; Reviewer QA reviews it; Jorge merges it.

| Branch | Task | Requirements | needs-human | Depends on | Verification |
|--------|------|--------------|-------------|------------|--------------|
| `003-now-page-t01` | T001 | FR-002, FR-004, FR-007 | No: layouts only; no IAM, secret, region, DNS, cost, or protection change | This `docs:` pull request merged | AC3 fixture commands in the pull request body; AC2 heading checks against a temporary structured `content/now.md` if needed for the build, or layout-only proof with a minimal front-matter fixture documented in the body; `hugo --gc --minify --panicOnWarning --baseURL /` |
| `003-now-page-t02` | T002 | FR-001, FR-002, FR-003, FR-005 (date present), FR-006 (lychee links), FR-007, AC6 | No: content only | T001 merged | AC1 menu block; AC2 field block; AC6 note; `lychee --offline --root-dir public public`; staging `/now/` 200 after merge (URL recorded in converge) |
| `003-now-page-t03` | T003 | FR-005, FR-006, AC4, AC5 | No: assets and one partial; no IAM, secret, region, DNS, cost, or protection change | T002 merged | AC4 and AC5 blocks; manual green/amber note in the pull request body |
| `003-now-page-t04` | T004 | Converge, SC-001–SC-004, AC1–AC6 | No (Jorge merges converge anyway) | T003 merged; staging AC1 evidence available | `converge.md` with verdict `Converged` |

## Phase 1: User Stories 1 and 3 — layout and required fields (P1, P3)

- [ ] T001 [US1][US3] Add the Now layout under `layouts/` (for example `layouts/_default/now.html`) so a page with `layout: now` renders headings `Current goal`, `Building`, `Learning`, `Reading`, `Last updated`, and optionally `Current challenge`. Fail the build with `errorf` when `current_goal`, `building`, `learning`, `reading`, or `last_updated` is missing or empty, and when `last_updated` is not `YYYY-MM-DD`; the error text must include the human field name. Do not render a Current challenge heading when `current_challenge` is absent or blank. Do not edit `themes/PaperMod`, `infra/`, or workflows. The pull request body pastes AC3 fixture runs (each required field removed → non-zero exit and field name; challenge omitted → exit 0).

## Phase 2: User Story 1 — structured content (P1)

- [ ] T002 [US1][US3] Replace `content/now.md` with structured English front matter for all required fields and a real Last updated ISO date. Building and Learning are short lists; include at least one link in each list so lychee sees external URLs. Omit Current challenge, or set it, but if set it must be non-placeholder English. Keep `title: Now` and `layout: now`. Do not change `hugo.yaml` menu entries except to restore Now → `/now/` if a rebase dropped it. Do not edit layouts or assets except if T001 left a temporary fixture file that this task removes. After merge, confirm staging `/now/` returns 200 and record that run or URL for T004. The pull request body pastes AC1 (build + menu), AC2, and AC6 evidence.

## Phase 3: User Story 2 — staleness indicator (P2)

- [ ] T003 [US2] Add `assets/js/now-staleness.js` and, if needed, `assets/css/extended/now-staleness.css`. Wire the script only on `/now/` via `layouts/partials/extend_footer.html` (project override). The script reads a `data-last-updated` ISO date, applies green when under 30 local days and amber when 30 or older, and performs no network requests. With JS disabled, the ISO date remains visible. Do not edit `themes/PaperMod` or `content/now.md` except for a class/hook required by the layout. The pull request body pastes AC4 and AC5 commands and states the manual green/amber check.

## Phase 4: Convergence

- [ ] T004 Run `/speckit-converge` and add `specs/003-now-page/converge.md` with: the staging `/now/` 200 evidence from T002; the AC1–AC6 verification results on the converge SHA; the date, the SHA, and the verdict `Converged`; `Status: Approved by Jorge — PR #N`. Title the pull request exactly `chore(003): converge`. Do not edit `spec.md` or `plan.md`. No account id, bucket name, distribution id, hostname, or email in the file. Reviewer QA reviews; Jorge merges.

## Dependencies

- T001 needs this `docs:` pull request merged (and constitution 3.0.0 in force).
- T002 needs T001.
- T003 needs T002 (needs a real `last_updated` on the page).
- T004 needs T003 and staging AC1 evidence.

## Notes

- Mark an id `[X]` only in the pull request that closes it. A pull request may add or update its own task line here (constitution principle V).
- Do not edit `spec.md` or `plan.md` in an implementation pull request.
- Feature 004 (automation) is out of scope; do not open it from these tasks.
