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
| `005-deploy-verification-t09` | T009, T010 | FR-002, FR-004, FR-005 (issues #44, #45, #49, #61) | No: workflow-only; no IAM, secret, region, DNS, cost, or protection change | The 2026-11-02 follow-up `docs:` pull request merged | FR-002 oracle dry run including the new rows; front-matter fixtures; rendered table sample; FR-005 and FR-008 implementation blocks; stubbed curl/jq runs |
| `005-deploy-verification-t11` | T011 | FR-001, FR-004 (issue #46); spec 002 FR-014, FR-017 | Yes: secrets | This `docs:` pull request merged; Jorge has created the environment secrets and the plan-role repository secret | Workflow greps for `secrets.AWS_ROLE_ARN`, `secrets.BUCKET_NAME`, `secrets.DISTRIBUTION_ID`, and `secrets.AWS_PLAN_ROLE_ARN`; `SITE_URL` remains a variable; one deploy log after merge shows those names masked |

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
- T009 and T010 need the 2026-11-02 follow-up `docs:` pull request merged. They may share one pull request (different files).
- T011 needs this `docs:` pull request merged and Jorge's secrets created (see Jorge's steps). It may merge before or after T009/T010; they touch overlapping files in `deploy.yml`, so prefer T009 first if both are open.

## Notes

- Mark an id `[X]` only in the pull request that closes it. A pull request may add or update its own task line here (constitution 2.0.0, principle V).
- Do not edit `spec.md` or `plan.md` in an implementation pull request.
- If Jorge prefers fewer pull requests, T003 and T004 can be dropped and SC-002 accepted on the oracle dry run in T001 instead. That is a scope change and needs a `docs:` pull request first.

## Phase 5: Convergence

- [X] T007 After Jorge starts `workflow_dispatch` for `.github/workflows/branch-protection.yml` on `main`, record that run URL and the matching summary for `develop` and `main` in `specs/005-deploy-verification/converge.md`, set the verdict to `Converged`, and mark T005 `[X]` per SC-004 / US3 / T005 (missing). This agent cannot create the dispatch (HTTP 403 Resource not accessible by integration). Do not invent a run URL. Do not edit `spec.md` or `plan.md`.

## Phase 6: Follow-up — top-level url: only (FR-002)

- [X] T008 In `.github/workflows/deploy.yml`, change `parse_front_matter` so a `url:` front-matter key fails the verify job only when the line is unindented (`line.startswith("url:")`, no `strip`). Nested list keys such as Building/Learning `url:` under `content/now.md` must not fail the job. Do not change other verify behaviour. Staging run `39973168501` failed verify after #57 because indented `url:` lines were rejected. The pull request body pastes a local proof: current `content/now.md` passes; a copy with a top-level `url:` fails.

## Phase 7: Follow-up fixes (issues #44, #45, #49, #61)

- [X] T009 [US1][US2] In `.github/workflows/deploy.yml`, job `verify` only: (a) in the key-derivation block, when a key is in both sets, keep it only in the present set instead of exiting with `object key ... is both present and absent` (FR-002, issue #44); (b) in `parse_front_matter`, fail only on an unindented `url` key, quoted or not, with optional spaces before the colon (`^["']?url["']?\s*:`), and keep indented `url:` allowed (FR-002, issue #61); (c) in `start_report`, `record`, and `note_page_source`, write the report as a GitHub-flavored Markdown table as defined in the 2026-11-02 Clarifications, with a blank line before `no page source changed` (FR-004, issue #45). Keep the secret guard on the final text. Do not edit `infra/` or the `deploy` job. The pull request body pastes: a local dry run of the key block against every FR-002 oracle row including the new rows; `parse_front_matter` fixtures for `url:`, `"url":`, `'url':`, `url :` (fail) and the current `content/now.md` (pass); a rendered sample of the summary table.
- [X] T010 [US3] In `.github/workflows/branch-protection.yml`, record a curl transport error as status `000` (`|| status=000`), read contexts with `(.required_status_checks.contexts // []) | sort` and `enforce_admins` with `.enforce_admins.enabled // false`, so each case writes a `fail` row and the loop continues to the other branch (FR-005, issue #49). Do not change triggers, permissions, the secret, or the expected contexts. The pull request body pastes the FR-005 and FR-008 implementation blocks and a local run with a stubbed `curl` that fails and a stubbed body without `required_status_checks`, showing both branch rows and exit 1. The first live run is the Monday schedule or Jorge's `workflow_dispatch` on `main` after the next release.

## Phase 8: Follow-up — deploy identifiers as secrets (issue #46)

- [ ] T011 In `.github/workflows/deploy.yml`, for both jobs `deploy` and `verify`, read `AWS_ROLE_ARN`, `BUCKET_NAME`, and `DISTRIBUTION_ID` from `${{ secrets.* }}` (GitHub Environment secrets) instead of `${{ vars.* }}`. Keep `SITE_URL` as `${{ vars.SITE_URL }}` so the deploy job output `site_url` is not dropped. In `.github/workflows/terraform.yml`, read `AWS_PLAN_ROLE_ARN` from `${{ secrets.AWS_PLAN_ROLE_ARN }}` instead of `${{ vars.AWS_PLAN_ROLE_ARN }}`. Do not edit `infra/`. This pull request carries `needs-human`. The pull request body pastes greps showing `secrets.AWS_ROLE_ARN`, `secrets.BUCKET_NAME`, `secrets.DISTRIBUTION_ID`, and `secrets.AWS_PLAN_ROLE_ARN` in the workflows, and showing `SITE_URL` still comes from `vars`.

## Jorge's steps

Issue #46 requires Jorge to create secrets before the T011 code merge and to delete the old variables afterwards. Order:

1. Create the environment secrets in `staging` and in `production` for `AWS_ROLE_ARN`, `BUCKET_NAME`, and `DISTRIBUTION_ID`, and create the repository secret `AWS_PLAN_ROLE_ARN` for the plan role (same values the variables hold today). Do not commit those values.
2. Merge the T011 code pull request (after QA and with `needs-human` still on).
3. Delete the old environment variables `AWS_ROLE_ARN`, `BUCKET_NAME`, and `DISTRIBUTION_ID` from `staging` and `production`, and delete the old repository variable `AWS_PLAN_ROLE_ARN`. Leave `SITE_URL` as a variable.
4. Check one staging or production deploy log and confirm those secret names are masked in step headers and action inputs.
