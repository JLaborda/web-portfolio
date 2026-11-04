# Feature Specification: Project Case Studies and About Page

**Feature Branch**: `007-projects-about`

**Created**: 2026-11-04

Status: Approved by Jorge — PR #N

**Input**: User description: "Replace the Projects and About placeholders with a reusable Hugo case-study section and a real About page. Only SmartWealthAI in this feature. Structured front matter with required fields that fail the Hugo build when missing (same pattern as /now). About: short bio, stack, certifications (AWS MLA-C02 in progress), LinkedIn and GitHub only; no email yet. Jorge uploads a CV PDF to static/cv/; About and the menu link it as a download. Jorge writes all prose. Templates ship with marked placeholders. Menu keeps Projects and About next to Now and adds a CV download link. Out of scope: other projects, email, chatbot, /log, library."

## Clarifications

### Session 2026-11-04

- Q: Which case studies ship in this feature? → A: Only SmartWealthAI (`https://github.com/JLaborda/SmartWealthAI`). A future project is a new Markdown file under `content/projects/`.
- Q: Who writes the prose and supplies the diagram and CV? → A: Jorge writes the About bio and the SmartWealthAI case study, provides or approves the architecture diagram, uploads the CV PDF, and confirms the LinkedIn URL. Implementation ships templates with clearly marked placeholder structure.
- Q: Is email on About in scope? → A: No. Email contact waits until after custom domain (spec 006) can provide an address. Recorded as future work.
- Q: How is the CV published? → A: Jorge uploads the current PDF into the repository under `static/cv/`. The site links it from About and from the main menu as a download. No PDF generation. See [ADR 003](../../docs/adr/003-cv-static-pdf.md).
- Q: What happens if a required project front-matter field is missing? → A: The Hugo build fails with `errorf` naming the field and the content path, same pattern as spec 003 `/now`.

## Context

Feature 001 shipped placeholder Projects (`/projects/`, `/projects/smartwealthai/`) and About (`/about/`) pages and a four-item menu (Projects, Now, About, Posts). Recruiters still see “placeholder” copy. Spec 003 made `/now/` structured and validated. This feature does the same for project case studies and About, and adds a downloadable CV without generating PDFs in CI.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Hiring manager reads a case study (Priority: P1)

A hiring manager opens Projects, picks SmartWealthAI, and understands the problem, architecture, key ML/MLOps decisions, results, stack, and links to the repository (and demo if present).

**Why this priority**: Case studies are the portfolio’s proof of depth.

**Independent Test**: Build the site. `/projects/` lists SmartWealthAI. `/projects/smartwealthai/` renders every required section. A fixture that drops a required field fails `hugo --panicOnWarning` with that field’s name.

**Acceptance Scenarios**:

1. **Given** the published site, **When** a visitor opens `/projects/`, **Then** they see a list that includes SmartWealthAI and can open `/projects/smartwealthai/`.
2. **Given** that case study page, **When** they read it, **Then** they see title, summary, problem, architecture image, key decisions, results/metrics, stack, and repo (and optional demo) links.
3. **Given** a project Markdown file missing a required field, **When** Hugo builds with `--panicOnWarning`, **Then** the build fails and the error names the field and path.

---

### User Story 2 - Hiring manager reads About and downloads the CV (Priority: P1)

A hiring manager opens About, reads bio, stack, and certifications, follows LinkedIn and GitHub, and downloads the CV PDF from About or the menu.

**Why this priority**: About plus CV is the standard recruiter path next to case studies.

**Independent Test**: `/about/` is English (`lang="en"`), shows the required sections, links LinkedIn and GitHub only (no mailto), and links the CV file under `static/cv/`. The main menu includes Projects, Now, About, Posts, and a CV download entry. Lychee’s offline check resolves the CV link.

**Acceptance Scenarios**:

1. **Given** the published site, **When** a visitor opens `/about/`, **Then** they see short bio, stack, certifications (including AWS MLA-C02 in progress), LinkedIn, GitHub, and a CV download link.
2. **Given** the main menu, **When** they activate the CV item, **Then** they receive the PDF from `static/cv/`.
3. **Given** About, **When** they search the HTML, **Then** there is no `mailto:` and no email address.

---

### User Story 3 - Jorge updates content without editing templates (Priority: P2)

Jorge updates About or SmartWealthAI by editing Markdown (and replacing the PDF or diagram file when needed). Adding another project later is one new Markdown file with the same schema.

**Why this priority**: Templates must stay stable so content can iterate.

**Independent Test**: Changing only `content/about.md` or `content/projects/smartwealthai.md` (plus optional assets) changes the published pages without layout edits.

**Acceptance Scenarios**:

1. **Given** placeholder structure on a branch, **When** Jorge replaces placeholders with his prose and diagram, **Then** the pages render that content after merge and deploy.
2. **Given** the schema, **When** a future project file is added under `content/projects/`, **Then** it appears on `/projects/` without a new layout (out of scope to author here; schema must allow it).

### Edge Cases

- Optional demo URL absent: no empty “Demo” heading.
- Architecture image path missing or file absent: build fails naming the field (required).
- CV PDF missing from `static/cv/` while links point at it: lychee or a documented existence check fails the PR that claims the CV is live.
- Menu must keep Projects, Now, About, Posts; CV is an additional download entry (not Search).
- Other projects (health-stream-xai, fintech-sec-rag-agent) are not authored in this feature.
- Email remains future work after spec 006.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `/projects/` is a list of project case studies. This feature publishes exactly one: SmartWealthAI at `/projects/smartwealthai/`, sourced from `content/projects/smartwealthai.md`. Adding another project MUST require only a new Markdown file under `content/projects/` that uses the same layout/schema. **Acceptance**: AC1 — list and detail pages exist; Verification greps pass.

- **FR-002**: Each project page uses a front-matter schema with at least: `title`, `summary`, `problem`, `architecture_image` (path to a static image; no Mermaid), `decisions` (key ML/MLOps decisions), `results`, `stack`, `repo_url`. Optional: `demo_url`. The layout renders those sections with fixed English headings. **Acceptance**: AC2 — headings present when fields are set.

- **FR-003**: Missing or blank required project fields fail the Hugo build with `errorf` naming the human field and the content path (spec 003 pattern; page `.Params` only, not site `.Param`). **Acceptance**: AC3 — fixtures fail with field names.

- **FR-004**: `/about/` presents short bio, stack, certifications (must mention AWS MLA-C02 in progress once Jorge’s copy lands; placeholders mark the slot until then), and contact links to LinkedIn and GitHub only. No email and no `mailto:`. **Acceptance**: AC4 — sections and link guards.

- **FR-005**: Jorge’s CV PDF lives at `static/cv/jorge-laborda-cv.pdf` (exact filename fixed in plan). About and the main menu link that path as a download. The feature does not generate PDFs. **Acceptance**: AC5 — file exists when content is complete; lychee offline resolves the link; menu and About both reference it.

- **FR-006**: Main menu (`ul#menu`) includes Projects → `/projects/`, Now → `/now/`, About → `/about/`, Posts → `/posts/`, and a CV download entry pointing at the CV path. Search stays off the menu. **Acceptance**: AC6 — menu Verification.

- **FR-007**: Every published page keeps `lang="en"`. English only. **Acceptance**: `lang` check on `/projects/`, `/projects/smartwealthai/`, `/about/`.

- **FR-008**: Implementation pull requests MAY ship template/layout work with clearly marked placeholder prose structure so Hugo builds pass. Jorge’s final prose, diagram, and PDF are his steps (see tasks.md). Email, other case studies, chatbot, `/log`, and library are out of scope. **Acceptance**: out-of-scope guards; Jorge’s steps listed.

### Key Entities

- **Project case study**: One Markdown file under `content/projects/` with the FR-002 schema.
- **About page**: `content/about.md` with bio, stack, certifications, LinkedIn, GitHub, CV link.
- **CV asset**: Static PDF under `static/cv/jorge-laborda-cv.pdf`.

## Success Criteria *(mandatory)*

- **SC-001**: A hiring manager reaches SmartWealthAI from Projects and can summarize problem, approach, and results in under two minutes once Jorge’s copy is live.
- **SC-002**: A hiring manager downloads the CV from About or the menu without creating an account.
- **SC-003**: A missing required project field fails CI’s Hugo job with a named field.
- **SC-004**: Adding a future project is one new Markdown file using the same layout.

## Acceptance Criteria (verifiable)

| ID | Criterion |
|----|-----------|
| AC1 | `/projects/` and `/projects/smartwealthai/` return built HTML; Projects menu link works. |
| AC2 | Case study renders the required sections when front matter is complete. |
| AC3 | Missing required front-matter field → Hugo build fails naming the field. |
| AC4 | `/about/` has bio, stack, certifications slots, LinkedIn, GitHub; no mailto/email. |
| AC5 | CV PDF is linked from About and menu; lychee offline passes including that link when the file is present. |
| AC6 | Menu has Projects, Now, About, Posts, and CV download; `lang="en"` on the new pages. |

## Assumptions

- Feature 001 already registered Projects and About in `hugo.yaml`; this feature keeps them and adds the CV menu item.
- LinkedIn URL remains `https://www.linkedin.com/in/jorge-daniel-laborda-sicilia` unless Jorge supplies a replacement in his steps.
- Spec 006 (custom domain / future email) is not a blocker for this feature’s merge.

## Out of Scope

- Case studies for health-stream-xai, fintech-sec-rag-agent, or any project other than SmartWealthAI.
- Email contact or `mailto:` links.
- Chatbot, `/log` (TIL), library.
- PDF generation or Word-to-PDF pipelines.
- Changing staging/production AWS resources.

## Verification

```bash
set -euo pipefail
hugo --gc --minify --panicOnWarning --baseURL /
test -f public/projects/index.html
test -f public/projects/smartwealthai/index.html
test -f public/about/index.html
# lang=en
for f in public/projects/index.html public/projects/smartwealthai/index.html public/about/index.html; do
  grep -E 'lang="?en"?' "$f"
done
# menu
menu=$(sed -n '/<ul id="menu"/,/<\/ul>/p' public/index.html)
printf '%s\n' "$menu" | grep -F 'Projects'
printf '%s\n' "$menu" | grep -F 'About'
printf '%s\n' "$menu" | grep -E 'href="?/projects/"?'
printf '%s\n' "$menu" | grep -E 'href="?/about/"?'
printf '%s\n' "$menu" | grep -E 'cv/jorge-laborda-cv\.pdf'
# about: no mailto
if grep -Ei 'mailto:|@[a-z0-9.-]+\.[a-z]{2,}' public/about/index.html; then exit 1; fi
# CV file present once Jorge has uploaded it (content-complete gate)
test -f static/cv/jorge-laborda-cv.pdf
lychee --offline --root-dir public public
```

Required-field fixtures (implementation PR body): drop each required project key → non-zero Hugo exit and field name in the error.
