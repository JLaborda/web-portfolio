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

One task per pull request, merged one at a time into `develop`. Each pull request lists its task id in the description and marks it `[X]` here. One cloud agent per implementation pull request, reused for its fixes. `needs-human` follows constitution I (region, DNS, real AWS cost, IAM or secrets, branch protection); T001–T003 do not need it for those reasons. The docs PR and Jorge’s content/release steps do. The converge pull request title is exactly `chore(007): converge`; Reviewer QA reviews it; Jorge merges it.

| Branch | Task | Requirements | needs-human | Depends on | Verification |
|--------|------|--------------|-------------|------------|--------------|
| `007-projects-about-t01` | T001 | FR-001, FR-002, FR-003, FR-007, FR-008 | No: layouts + placeholder schema; no IAM, secret, region, DNS, cost, or protection change | Docs PR #74 merged | AC3 fixture commands in the pull request body; `hugo --gc --minify --panicOnWarning --baseURL /`; AC1 path existence for `/projects/` and `/projects/smartwealthai/` |
| `007-projects-about-t02` | T002 | FR-004, FR-007, FR-008 (AC5/CV links deferred) | No: About placeholders only; no IAM, secret, region, DNS, cost, or protection change | T001 merged | AC4 (sections/slots, no mailto); `lang="en"`; menu keeps Projects/Now/About/Posts; no CV href; `lychee --offline --root-dir public public` |
| `007-projects-about-t03` | T003 | FR-005, AC5, AC6 (CV menu item) | No: static PDF + menu/About links; PDF provided by Jorge, never generated | T002 merged; Jorge’s CV PDF available (Pasos de Jorge step 5) | `test -f static/cv/jorge-laborda-cv.pdf`; `test ! -f public/cv/README.md` after hugo; AC5 lychee offline (no lychee exclusion); AC6 menu grep includes CV href; About links the PDF |
| `007-projects-about-diagram` | T005 | FR-002 (architecture image) | Yes: Jorge reviews/approves the diagram | T001 merged; Jorge provides the PNG (Pasos de Jorge step 4) | Image served on `/projects/smartwealthai/`; `hugo` + `lychee --offline` |
| `007-projects-about-t04` | T004 | Converge, SC-001–SC-004, AC1–AC6 | No (Jorge merges converge anyway) | T003 merged; Jorge’s remaining Pasos de Jorge done enough for content-complete ACs; staging evidence available | `converge.md` with verdict `Converged` |

## Phase 1: User Stories 1 and 3 — project layout and required fields (P1, P2)

- [X] T001 [US1][US3] Add the project case-study layout under `layouts/` (for example `layouts/_default/project.html`) so a page with `layout: project` renders fixed English headings for Summary, Problem, Architecture, Key decisions, Results, Stack, and Repository (and Demo only when `demo_url` is non-blank). Fail the build with `errorf` when any required front-matter field from the plan is missing or empty; the error text must include the human field name and `.File.Path`. Read fields only from page `.Params` (`index .Params`), never site `.Param`. Keep or adjust `content/projects/_index.md` so `/projects/` lists case studies. Replace `content/projects/smartwealthai.md` with the full schema and clearly marked placeholder values (not invented final prose) so the build passes, `repo_url: https://github.com/JLaborda/SmartWealthAI`, and an architecture image path that points at a checked-in placeholder image under `static/` (or fail clearly until Jorge’s diagram lands—prefer a minimal placeholder image so CI builds). Do not edit `themes/PaperMod`, `infra/`, or workflows. Do not add health-stream-xai or fintech-sec-rag-agent case studies. The pull request body pastes AC3 fixture runs (each required field removed → non-zero exit and field name) and AC1 path checks.

## Phase 2: User Story 2 — About placeholders (P1)

- [X] T002 [US2] Replace `content/about.md` with a clearly marked placeholder structure for short bio, stack, certifications (including an AWS MLA-C02 in progress slot), LinkedIn, and GitHub. No email and no `mailto:`. Default LinkedIn to `https://www.linkedin.com/in/jorge-daniel-laborda-sicilia` and GitHub to `https://github.com/JLaborda` until Jorge confirms. In `hugo.yaml`, keep Projects → `/projects/`, Now → `/now/`, About → `/about/`, and Posts → `/posts/`. Do **not** add a CV menu entry and do **not** link `/cv/jorge-laborda-cv.pdf` from About (AC5 deferred to T003 so offline lychee stays green). Do not generate a PDF. Do not invent Jorge’s final bio. Do not edit `themes/PaperMod` or `infra/`. (PR #77 also added a temporary `static/cv/README.md`; that file must not remain published—T003 removes it.) The pull request body pastes AC4 evidence and states AC5 / CV menu-About PDF links are deferred to T003.

## Phase 3: User Story 2 — CV PDF and links (P1)

- [X] T003 [US2] After Jorge provides `jorge-laborda-cv.pdf` (Pasos de Jorge step 5), open one pull request that: (1) adds `static/cv/jorge-laborda-cv.pdf` (exact filename; Jorge’s file only—never generate or invent a PDF); (2) adds the About download link to `/cv/jorge-laborda-cv.pdf` in `content/about.md`; (3) adds the main-menu CV entry in `hugo.yaml` pointing at `/cv/jorge-laborda-cv.pdf` (keep Projects, Now, About, Posts); (4) deletes `static/cv/README.md` so Hugo does not publish `/cv/README.md`—move any remaining agent/Jorge guidance into `specs/007-projects-about/tasks.md` or `plan.md` (or `docs/`) if needed, and leave `static/cv/` with only the PDF (no non-PDF files under that tree). Do **not** add a lychee exclusion. Do not edit `themes/PaperMod` or `infra/`. Covers **FR-005**, **AC5**, and the **CV item of AC6**. The pull request body pastes: `hugo --gc --minify --panicOnWarning --baseURL /`; `test -f static/cv/jorge-laborda-cv.pdf`; `test ! -f public/cv/README.md`; AC5 `lychee --offline --root-dir public public`; AC6 menu block grepping the CV PDF href; About HTML contains the CV link.

## Phase 4: Architecture diagram (Pasos de Jorge step 4)

- [X] T005 Replace the SmartWealthAI architecture placeholder image with Jorge’s credit-module diagram at `static/images/projects/smartwealthai-credit-architecture.png`, point `architecture_image` in `content/projects/smartwealthai.md` at that path, and set a descriptive English `architecture_image_alt` (components and flow only; no performance metrics). Remove the old SVG placeholder. Do not edit other PLACEHOLDER prose. Do not edit `themes/PaperMod` or `infra/`. This pull request carries `needs-human` for Jorge’s review.

## Phase 5: Convergence

- [ ] T004 Run `/speckit-converge` and add `specs/007-projects-about/converge.md` with: staging 200 evidence for `/projects/`, `/projects/smartwealthai/`, `/about/`; AC1–AC6 verification results on the converge SHA including CV file presence, no `public/cv/README.md`, and lychee offline; the date, the SHA, and the verdict `Converged`; `Status: Approved by Jorge — PR #N` (N is the converge pull request). Title the pull request exactly `chore(007): converge`. Do not edit `spec.md` or `plan.md`. No account id, bucket name, distribution id, hostname, or email in the file. Reviewer QA reviews; Jorge merges.

## Pasos de Jorge

Only Jorge does these. Agents do not invent his prose, diagram, or PDF.

1. **Merge the feature `docs:` pull request** (`docs: spec 007 project case studies and about page`, PR #74) after he is satisfied with the plan. *(done)*
2. **Write the About page** — replace placeholders in `content/about.md` with his short bio, stack, and certifications (include AWS MLA-C02 in progress). Confirm or replace the LinkedIn URL; keep GitHub as `https://github.com/JLaborda`. Do not add email. (May land before or with T003; do not add the CV href until T003 if that would break lychee.)
3. **Write the SmartWealthAI case study** — replace placeholders in `content/projects/smartwealthai.md` with real summary, problem, key ML/MLOps decisions, results/metrics, and stack. Keep `repo_url` for `https://github.com/JLaborda/SmartWealthAI`. Add `demo_url` only if a public demo exists.
4. **Provide or approve the architecture diagram** — supply a static image (no Mermaid), place it where `architecture_image` points, and approve the published figure.
5. **Upload the CV PDF via a pull request** — add his current CV as `static/cv/jorge-laborda-cv.pdf` (exact filename), or otherwise deliver that binary for the Web Developer. No generation pipeline. Do not add About/menu CV links in a PDF-only PR if lychee would fail; the Web Developer’s **T003** lands the PDF (if not already merged), the About link, and the menu entry together so lychee stays green.
6. **Web Developer runs T003** — after step 5, the Web Developer (implementation agent) completes T003: PDF in `static/cv/`, About + menu CV links, remove `static/cv/README.md`. Jorge does not write that wiring himself unless he chooses to.
7. **Provide LinkedIn URL** — confirm the default or supply the correct profile URL for About (and site social icons if he wants them aligned).
8. **Merge the converge pull request** `chore(007): converge` after Reviewer QA sign-off.
9. **Release `develop` → `main`** with a **merge commit** when he chooses to publish production.

## CV directory guidance (moved out of `static/cv/`)

Hugo copies everything under `static/` into `public/` as-is. Do **not** keep a README or other non-PDF files under `static/cv/` (issue #79). The only published object under `/cv/` must be `jorge-laborda-cv.pdf`. Jorge provides that PDF; agents never generate it. About and the main menu gain the download links only in T003, in the same pull request as the PDF, with no lychee exclusion (issue #78).

## Dependencies

- T001 needs docs PR #74 merged.
- T002 needs T001.
- T003 needs T002 and Jorge’s CV PDF (Pasos de Jorge step 5).
- T004 needs T003, Jorge’s remaining content steps as needed for content-complete ACs, and staging evidence.

## Notes

- Mark an id `[X]` only in the pull request that closes it. A pull request may add or update its own task line here (constitution principle V).
- Do not edit `spec.md` or `plan.md` in an implementation pull request.
- Other project case studies, email contact, chatbot, `/log`, and library remain out of scope.
