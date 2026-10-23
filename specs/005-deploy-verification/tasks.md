# Tasks: Automated Post-deploy Verification

Status: Approved by Jorge — PR #36

**Input**: Design documents from `/specs/005-deploy-verification/`

**Prerequisites**: plan.md, spec.md, checklists/requirements.md, [ADR 001](../../docs/adr/001-post-deploy-verification.md)

**Tests**: No test framework. Each implementation pull request runs the Verification blocks named for it in `spec.md`.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: User story label.
- Every description names a file path.

On every implementation branch, before Spec Kit scripts, export `SPECIFY_FEATURE_DIRECTORY=specs/005-deploy-verification`.

## Implementation pull requests

One task per pull request, merged one at a time into `develop`. Each pull request lists its task id in the description and marks it `[X]` here. One cloud agent per pull request, reused for its fixes. `needs-human` follows constitution I (region, DNS, real AWS cost, IAM or secrets, branch protection); the Scrum Master Dev adds it before QA's verdict.

| Branch | Task | Requirements | needs-human | Depends on | Verification |
|--------|------|--------------|-------------|------------|--------------|
| `005-deploy-verification-t01` | T001 | FR-001, FR-002, FR-003, FR-004, FR-006, FR-007, FR-008 | No: no IAM, secret, region, DNS, cost, or protection change | PR #36 merged; spec 002 FR-022 `deploy.yml` change on `develop` | FR-001, FR-002, FR-003, FR-004 (implementation) blocks; FR-006 diff guard; FR-007 implementation check; FR-008 implementation guard; oracle dry run |
| `005-deploy-verification-t06` | T006 | FR-002 (rename same-key / differing-key) | No: workflow-only follow-up to T001; no IAM, secret, region, DNS, cost, or protection change | T001 merged; docs fix for issues #43 and #44 merged | FR-002 oracle dry run including the four rename rows; no key in both present and absent |
| `005-deploy-verification-t02` | T002 | FR-005, FR-008 | Yes: consumes secret `BRANCH_PROTECTION_READ_TOKEN` and reads branch protection | T001 merged | FR-005 (implementation) block; FR-008 guard |
| `005-deploy-verification-t03` | T003 | US1 scenario 1, SC-001 | No | T001 merged | Staging verify run after merge |
| `005-deploy-verification-t04` | T004 | US1 scenario 2, SC-002 | No | T003 merged and its staging run green | Staging verify run after merge |
| `005-deploy-verification-t05` | T005 | Converge, US1 scenario 3, US3, SC-003, SC-004 | No (Jorge merges converge anyway) | T004 merged; Jorge's release of `develop` to `main` | `converge.md` |

## Phase 1: User Stories 1 and 2 — the deploy checks itself and comments (P1, P2)

- [X] T001 [US1][US2] In `.github/workflows/deploy.yml`, add job `verify` as designed in [plan.md](./plan.md): `needs: deploy`, same environment expression, permissions `id-token: write`, `contents: read`, `pull-requests: write`, checkout `fetch-depth: 2`, existing OIDC deploy role, masking via `aws sts get-caller-identity`, `git fetch --no-tags origin "$BEFORE"`, `git diff --name-status -M "$BEFORE" "$GITHUB_SHA"`, parent blob read with `git show "$BEFORE:<path>"`, HeadObject present/absent rules, curl checks, report, exact-string guard, summary, and comment on each pull request from `commits/${GITHUB_SHA}/pulls`. Do not edit `infra/` or the `deploy` job's permissions. The pull request body pastes: every FR-001 to FR-004 implementation block with its exit status; the FR-006 `infra` diff guard; a local dry run of the key-derivation block against every oracle row in spec FR-002 (both tables, including the `2292272cdb^1..2292272cdb` range) with expected and actual sets; the FR-004 guard fixture run with a 40-character SHA. After merge, the first staging run must be green and must comment on this pull request; its run URL is recorded in T005
- [X] T006 [US1] In `.github/workflows/deploy.yml`, update the `verify` key-derivation block so a rename (`R` status) follows the FR-002 clarification from issue #44: when the old and new object keys are equal, treat the row as a modification of that one key (present if the new blob is published; absent if the new blob is a draft and the parent was published); when the keys differ, keep old absent / new present. A key must not appear in both sets. Do not edit `infra/`. The pull request body pastes a local dry run against the four rename oracle rows (same-slug keep, page-to-bundle keep, and the two differing-key rows) with expected and actual sets, and shows that the same-key cases no longer exit with `object key ... is both present and absent`

## Phase 2: User Story 3 — branch protection is read on a schedule (P3)

- [X] T002 [US3] Add `.github/workflows/branch-protection.yml` as designed in [plan.md](./plan.md): `schedule` `0 9 * * 1` and `workflow_dispatch` only, `permissions: contents: read`, job `branch-protection`, `GET` only with `secrets.BRANCH_PROTECTION_READ_TOKEN`, unset-secret error, no `github.token`, sorted contexts and `enforce_admins` compared for `develop` and `main`, HTTP status in the summary, exit 1 on mismatch or non-200. Do not add it to required checks. The pull request body pastes the FR-005 and FR-008 implementation blocks with exit statuses and states that the first live run happens after the release to `main` (T005)

## Phase 3: Live evidence on staging

- [X] T003 [US1] Add `content/posts/spec-005-probe.md` (non-draft, one line of body, title "Spec 005 probe"). After merge, the staging verify run lists `posts/spec-005-probe/index.html` as present and passes, and comments on this pull request. Record the run URL in T005
- [X] T004 [US1] Delete `content/posts/spec-005-probe.md`. After merge, the staging verify run lists `posts/spec-005-probe/index.html` as absent with `(404)` and `Not Found`, and passes. Record the run URL in T005. Jorge runs no `head-object` himself

## Phase 4: Convergence

- [X] T005 After Jorge releases `develop` to `main` (the release range adds and removes the probe, so it nets out), run `/speckit-converge` and write `specs/005-deploy-verification/converge.md` with: the staging run URLs from T001, T003, T004 and their pull request comments; the production verify run URL for the release merge, showing no `x-robots-tag` and every key in the `$BEFORE..$GITHUB_SHA` range; the first `workflow_dispatch` run URL of `branch-protection.yml` on `main` with both branches matching (this is the proof that `BRANCH_PROTECTION_READ_TOKEN` exists); the date, the SHA it ran on, and the verdict `Converged`; `Status: Approved by Jorge — PR #N`. No account id, bucket name, distribution id, hostname, or email in the file. Jorge merges this pull request

## Dependencies

- T001 needs PR #36 merged and spec 002 FR-022 (`deploy.yml` invalidation wait) on `develop` (spec FR-007).
- T006 needs T001 merged and the `docs:` pull request that fixes issues #43 and #44 merged. It only edits the `verify` key block in `deploy.yml`.
- T002 needs T001 merged (one feature PR at a time). T002 and T001 touch different files but merge sequentially. T006 may merge before or after T002; they touch different files.
- T003 needs T001; T004 needs T003; T005 needs T004 and the release to `main`.

## Notes

- Mark an id `[X]` only in the pull request that closes it. A pull request may add or update its own task line here (constitution 2.0.0, principle V).
- Do not edit `spec.md` or `plan.md` in an implementation pull request.
- If Jorge prefers fewer pull requests, T003 and T004 can be dropped and SC-002 accepted on the oracle dry run in T001 instead. That is a scope change and needs a `docs:` pull request first.

## Phase 5: Convergence

- [X] T007 After Jorge starts `workflow_dispatch` for `.github/workflows/branch-protection.yml` on `main`, record that run URL and the matching summary for `develop` and `main` in `specs/005-deploy-verification/converge.md`, set the verdict to `Converged`, and mark T005 `[X]` per SC-004 / US3 / T005 (missing). This agent cannot create the dispatch (HTTP 403 Resource not accessible by integration). Do not invent a run URL. Do not edit `spec.md` or `plan.md`.

## Phase 6: Follow-up — top-level url: only (FR-002)

- [X] T008 In `.github/workflows/deploy.yml`, change `parse_front_matter` so a `url:` front-matter key fails the verify job only when the line is unindented (`line.startswith("url:")`, no `strip`). Nested list keys such as Building/Learning `url:` under `content/now.md` must not fail the job. Do not change other verify behaviour. Staging run `39973168501` failed verify after #57 because indented `url:` lines were rejected. The pull request body pastes a local proof: current `content/now.md` passes; a copy with a top-level `url:` fails.
