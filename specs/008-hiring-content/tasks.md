# Tasks: Hiring Content Wave

**Status**: Draft — short path

**Input**: Design documents from `/specs/008-hiring-content/`

**Prerequisites**: plan.md, spec.md, checklists/requirements.md

**Tests**: No test framework. Each implementation PR runs the Verification checks named for it.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no incomplete dependencies)
- **[Story]**: User story label (US1–US4)
- Every description names a file path

On every implementation branch, before Spec Kit scripts, export `SPECIFY_FEATURE_DIRECTORY=specs/008-hiring-content`.

## Implementation pull requests

One task per pull request, merged one at a time into `develop` (Now and SmartWealthAI may be sequenced; headline/About wait on Jorge’s text). Converge title: exactly `chore(008): converge`.

| Branch | Task | Requirements | needs-human | Depends on | Verification |
|--------|------|--------------|-------------|------------|--------------|
| `008-hiring-content-t01` | T001 | FR-006, AC-N1 | No | Docs PR merged | Spec Verification Now greps; hugo + lychee offline |
| `008-hiring-content-t02` | T002 | FR-003, FR-004, FR-005, AC-P1, AC-P2 | Yes: Jorge approves case study copy | Docs PR merged; may parallel T001 | No `PLACEHOLDER` on SmartWealthAI; hugo; lychee; architecture image still loads |
| `008-hiring-content-t03` | T003 | FR-001, FR-002, FR-007, AC-H1, AC-A1, AC-M1 | Yes: Jorge’s headline + About voice | Pasos de Jorge 2–3 done; prefer after T001 | No `Placeholder headline`; no About `PLACEHOLDER`; no mailto; menu intact; hugo; lychee |
| `008-hiring-content-t04` | T004 | Converge SC-001–SC-004 | No (Jorge merges converge) | T001–T003 merged; content-complete | `converge.md` verdict `Converged` + full Verification block |

## Phase 1: User Story 3 — Now sync (P2)

- [X] T001 [US3] Update `content/now.md` Building to list SmartWealthAI and fintech-sec-rag-agent (portfolio optional); remove health-stream-xai; set `last_updated` to the edit date (ISO). Keep GitHub URLs for projects without on-site case studies. Do not add `content/projects/fintech-sec-rag-agent.md`. Do not edit `themes/PaperMod`, `infra/`, or workflows.

## Phase 2: User Story 1 — SmartWealthAI case study (P1) 🎯 MVP

- [ ] T002 [US1][US4] Replace all placeholder fields and body in `content/projects/smartwealthai.md` with a complete English case study (summary, problem, decisions, results, stack; keep `architecture_image` / alt pointing at `static/images/projects/smartwealthai-credit-architecture.png` unless Jorge supplies a replacement). Draft from SmartWealthAI public materials; honest results only; no invented metrics. Keep `repo_url: https://github.com/JLaborda/SmartWealthAI`. Omit `demo_url` unless a public demo exists. Open the PR with `needs-human` for Jorge’s approval. Do not edit layouts or PaperMod.

## Phase 3: User Stories 2 & 4 — headline + About (P1)

- [ ] T003 [US2][US4] After Jorge supplies text (Pasos de Jorge): set `params.profileMode.subtitle` in `hugo.yaml` to his exact headline; replace placeholders in `content/about.md` with his bio, stack, and certifications; keep LinkedIn, GitHub, CV link; no email/`mailto:`. Do not invent copy. Keep menu Projects/Now/About/Posts/CV. Label `needs-human` for Jorge’s voice check. Do not edit PaperMod or `infra/`.

## Phase 4: Convergence

- [ ] T004 Run `/speckit-converge` and add `specs/008-hiring-content/converge.md` with staging evidence, Verification results, date, SHA, verdict `Converged`. Title exactly `chore(008): converge`. Do not edit `spec.md` or `plan.md`. Reviewer QA reviews; Jorge merges.

## Pasos de Jorge

Only Jorge does these. Agents do not invent his headline or biography.

1. **Merge the feature `docs:` pull request** (#94) after he is satisfied with plan/tasks (`Path: short (small change)`).
2. **Write the home positioning headline** — one English line (role + domain). Deliver in chat/PR comment or commit for T003.
3. **Write About** — short bio, stack, certifications (MLA-C02 status accurate). No email.
4. **Review/edit SmartWealthAI draft** on the T002 PR; approve merge when honest and complete.
5. **Merge the converge pull request** `chore(008): converge` after Reviewer QA.
6. **Release `develop` → `main`** with a merge commit when he chooses production.

## Dependencies

- T001 and T002 may start in parallel after docs merge (different files).
- T003 needs Jorge’s headline + About text (Pasos 2–3).
- T004 needs T001–T003 merged and content-complete ACs.

## Parallel example

```text
# After docs merge:
Agent A: 008-hiring-content-t01 (now.md)
Agent B: 008-hiring-content-t02 (smartwealthai.md)  # needs-human
# After Jorge delivers headline + About:
Agent C: 008-hiring-content-t03 (hugo.yaml + about.md)  # needs-human
```

## Notes

- Mark an id `[X]` only in the PR that closes it.
- Do not edit `spec.md` or `plan.md` in implementation PRs.
- Feature 009 may run in parallel; do not change Posts content here.
