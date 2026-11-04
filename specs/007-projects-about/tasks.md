# Tasks: Project Case Studies and About Page

Status: Approved by Jorge — PR #74

**Input**: Design documents from `/specs/007-projects-about/`

**Prerequisites**: plan.md, spec.md, checklists/requirements.md, [ADR 003](../../docs/adr/003-cv-static-pdf.md)

**Tests**: No test framework. Each implementation pull request runs the Verification blocks named for it in `spec.md`.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: User story label.
- Every description names a file path.

On every implementation branch, before Spec Kit scripts, export `SPECIFY_FEATURE_DIRECTORY=specs/007-projects-about`.

## Implementation pull requests

One task per pull request, merged one at a time into `develop`. Each pull request lists its task id in the description and marks it `[X]` here. One cloud agent per implementation pull request, reused for its fixes. `needs-human` follows constitution I (region, DNS, real AWS cost, IAM or secrets, branch protection); T001–T002 do not need it for those reasons. The docs PR and Jorge’s content/release steps do. The converge pull request title is exactly `chore(007): converge`; Reviewer QA reviews it; Jorge merges it.

| Branch | Task | Requirements | needs-human | Depends on | Verification |
|--------|------|--------------|-------------|------------|--------------|
| `007-projects-about-t01` | T001 | FR-001, FR-002, FR-003, FR-007, FR-008 | No: layouts + placeholder schema; no IAM, secret, region, DNS, cost, or protection change | This `docs:` pull request merged | AC3 fixture commands in the pull request body; `hugo --gc --minify --panicOnWarning --baseURL /`; AC1 path existence for `/projects/` and `/projects/smartwealthai/` |
| `007-projects-about-t02` | T002 | FR-004, FR-007, FR-008 (AC5/CV links deferred) | No: About placeholders; PDF binary and CV links are Jorge’s later PR | T001 merged | AC4 (sections/slots, no mailto); `lang="en"`; menu keeps Projects/Now/About/Posts; AC5 and CV hrefs deferred until the PR that adds the PDF |
| `007-projects-about-t03` | T003 | Converge, SC-001–SC-004, AC1–AC6 | No (Jorge merges converge anyway) | T002 merged; Jorge’s Pasos de Jorge done enough for AC5; staging evidence available | `converge.md` with verdict `Converged` |

## Phase 1: User Stories 1 and 3 — project layout and required fields (P1, P2)

- [X] T001 [US1][US3] Add the project case-study layout under `layouts/` (for example `layouts/_default/project.html`) so a page with `layout: project` renders fixed English headings for Summary, Problem, Architecture, Key decisions, Results, Stack, and Repository (and Demo only when `demo_url` is non-blank). Fail the build with `errorf` when any required front-matter field from the plan is missing or empty; the error text must include the human field name and `.File.Path`. Read fields only from page `.Params` (`index .Params`), never site `.Param`. Keep or adjust `content/projects/_index.md` so `/projects/` lists case studies. Replace `content/projects/smartwealthai.md` with the full schema and clearly marked placeholder values (not invented final prose) so the build passes, `repo_url: https://github.com/JLaborda/SmartWealthAI`, and an architecture image path that points at a checked-in placeholder image under `static/` (or fail clearly until Jorge’s diagram lands—prefer a minimal placeholder image so CI builds). Do not edit `themes/PaperMod`, `infra/`, or workflows. Do not add health-stream-xai or fintech-sec-rag-agent case studies. The pull request body pastes AC3 fixture runs (each required field removed → non-zero exit and field name) and AC1 path checks.

## Phase 2: User Story 2 — About placeholders and CV menu (P1)

- [X] T002 [US2] Replace `content/about.md` with a clearly marked placeholder structure for short bio, stack, certifications (including an AWS MLA-C02 in progress slot), LinkedIn, and GitHub. No email and no `mailto:`. Default LinkedIn to `https://www.linkedin.com/in/jorge-daniel-laborda-sicilia` and GitHub to `https://github.com/JLaborda` until Jorge confirms. In `hugo.yaml`, keep Projects → `/projects/`, Now → `/now/`, About → `/about/`, and Posts → `/posts/` (no CV menu entry in this task). Ensure `static/cv/` exists (for example a short README stating Jorge uploads `jorge-laborda-cv.pdf`); do not generate a PDF; do not link `/cv/jorge-laborda-cv.pdf` from About or the menu until the PDF lands. Do not invent Jorge’s final bio. Do not edit `themes/PaperMod` or `infra/`. The pull request body pastes AC4 evidence; AC5 and the CV menu/About PDF links are deferred to the pull request that adds the PDF after Jorge uploads it.

## Phase 3: Convergence

- [ ] T003 Run `/speckit-converge` and add `specs/007-projects-about/converge.md` with: staging 200 evidence for `/projects/`, `/projects/smartwealthai/`, `/about/`; AC1–AC6 verification results on the converge SHA including CV file presence and lychee offline; the date, the SHA, and the verdict `Converged`; `Status: Approved by Jorge — PR #N` (N is the converge pull request). Title the pull request exactly `chore(007): converge`. Do not edit `spec.md` or `plan.md`. No account id, bucket name, distribution id, hostname, or email in the file. Reviewer QA reviews; Jorge merges.

## Pasos de Jorge

Only Jorge does these. Agents do not invent his prose, diagram, or PDF.

1. **Merge this `docs:` pull request** (`docs: spec 007 project case studies and about page`) after he is satisfied with the plan.
2. **Write the About page** — replace placeholders in `content/about.md` with his short bio, stack, and certifications (include AWS MLA-C02 in progress). Confirm or replace the LinkedIn URL; keep GitHub as `https://github.com/JLaborda`. Do not add email.
3. **Write the SmartWealthAI case study** — replace placeholders in `content/projects/smartwealthai.md` with real summary, problem, key ML/MLOps decisions, results/metrics, and stack. Keep `repo_url` for `https://github.com/JLaborda/SmartWealthAI`. Add `demo_url` only if a public demo exists.
4. **Provide or approve the architecture diagram** — supply a static image (no Mermaid), place it where `architecture_image` points, and approve the published figure.
5. **Upload the CV PDF** — add his current CV as `static/cv/jorge-laborda-cv.pdf` (exact filename). No generation pipeline.
6. **Provide LinkedIn URL** — confirm the default or supply the correct profile URL for About (and site social icons if he wants them aligned).
7. **Merge the converge pull request** `chore(007): converge` after Reviewer QA sign-off.
8. **Release `develop` → `main`** with a **merge commit** when he chooses to publish production.

## Dependencies

- T001 needs this `docs:` pull request merged.
- T002 needs T001.
- Jorge’s Pasos de Jorge (prose, diagram, PDF, LinkedIn) should complete before T003 claims AC5 and content-complete ACs.
- T003 needs T002, Jorge’s content/PDF steps, and staging evidence.

## Notes

- Mark an id `[X]` only in the pull request that closes it. A pull request may add or update its own task line here (constitution principle V).
- Do not edit `spec.md` or `plan.md` in an implementation pull request.
- Other project case studies, email contact, chatbot, `/log`, and library remain out of scope.
