# Implementation Plan: Project Case Studies and About Page

**Branch**: `007-projects-about` | **Date**: 2026-11-04 | **Spec**: [spec.md](./spec.md)

Status: Approved by Jorge — PR #74

**Input**: Feature specification from `/specs/007-projects-about/spec.md`

## Summary

Replace the feature 001 Projects and About placeholders with a reusable Hugo case-study section and a real About page. This feature publishes exactly one case study, SmartWealthAI, under `/projects/smartwealthai/`. A project layout under `layouts/` renders a fixed English front-matter schema and fails the Hugo build with `errorf` when a required field is missing (same pattern as spec 003 `/now`). About at `/about/` shows short bio, stack, certifications (AWS MLA-C02 in progress), LinkedIn and GitHub only, and a CV download. Jorge uploads the CV PDF himself to `static/cv/jorge-laborda-cv.pdf`; the site links it from About and from the main menu. No PDF generation. Jorge writes all prose; implementation ships templates and clearly marked placeholder structure. Menu keeps Projects, Now, About, Posts and adds a CV download entry. No `infra/`, workflow, IAM, or theme-submodule edit. The CV serving decision is [ADR 003](../../docs/adr/003-cv-static-pdf.md).

## Technical Context

**Language/Version**: Hugo extended, version pinned as `HUGO_VERSION` in `.github/workflows/ci.yml` (feature 001). Templates use Hugo's Go template language.

**Primary Dependencies**: PaperMod theme submodule at `themes/PaperMod` tag `v8.0` (unchanged). Project overrides only under `layouts/` (and optional small CSS under `assets/css/extended/` if needed for section spacing). Constitution II.

**Storage**: None beyond git. Case studies, About, and the CV PDF are static after `hugo`. The PDF is a binary asset under `static/cv/`.

**Testing**: Verification blocks in [spec.md](./spec.md). No test framework. Fixture builds prove AC3 (required project fields). Lychee offline proves CV and external links when the PDF is present.

**Target Platform**: Static site on the existing staging and production CloudFront distributions (feature 002). This feature does not change hosting.

**Project Type**: Hugo content + layout overrides at the repository root.

**Performance Goals**: One list page, one case study, one About page, one PDF. No client-side generation.

**Constraints**: English only. No Mermaid (architecture is a static image). No email or `mailto:`. No third-party scripts. No account id, bucket name, distribution id, or CloudFront hostname in content or docs. Routine content updates touch only Markdown under `content/` (and optional image/PDF replacements under `static/`).

**Scale/Scope**: One project layout (or layout + partial), About content (Markdown and/or thin layout), one case-study Markdown file, `_index.md` for the list, menu CV entry, one PDF path. Future projects are additional Markdown files only.

## Constitution Check

| Principle | Gate | Result |
|-----------|------|--------|
| I. Spec-driven, PO approval | Spec, checklist, plan, tasks, and ADR ship in one `docs:` pull request; Jorge merges; Reviewer QA does not review docs. Label `needs-human` because Jorge owns the prose, diagram, CV upload, LinkedIn URL, and release. | Pass |
| II. Fixed stack | PaperMod submodule untouched. Project layouts only under `layouts/`. | Pass |
| III. AWS hosting | No `infra/` or IAM change. CV is a static file, not an S3-only object outside the site publish. | Pass |
| IV. Verifiable CI | Existing hugo, lychee, gitleaks, terraform gates. AC3 is a Hugo failure. AC5 includes lychee offline once the PDF is present. | Pass |
| V. Scoped PRs | Intermediate implementation branches plus `chore(007): converge`. | Pass |
| VI. Explainable and cheap | Static pages + one PDF in the repo; no new AWS cost. | Pass |
| VII. English | All copy and docs English. | Pass |

## Project Structure

```text
specs/007-projects-about/
├── spec.md
├── checklists/requirements.md
├── plan.md
├── tasks.md
└── converge.md                 # written by converge PR
docs/adr/
└── 003-cv-static-pdf.md
content/
├── about.md                    # About source (placeholders → Jorge's prose)
└── projects/
    ├── _index.md               # list page
    └── smartwealthai.md        # only case study in this feature
layouts/
├── _default/
│   └── project.html            # or equivalent; layout: project (t01)
└── partials/                   # optional shared project sections
static/
├── cv/
│   └── jorge-laborda-cv.pdf    # Jorge uploads (Pasos de Jorge)
└── images/projects/            # architecture diagram asset(s)
hugo.yaml                       # keep Projects/Now/About/Posts; add CV download
```

Exact layout filename may be `layouts/_default/project.html` with `layout: project` in front matter, or a section layout under `layouts/projects/`. The implementation chooses one path and records it in the pull request body; it must not edit `themes/PaperMod`.

## Design

### Project content model (`content/projects/*.md`)

Front matter (YAML) carries the fields. English section headings are fixed in the layout, not in the keys:

| Field | Front matter key | Required | Shape |
|-------|------------------|----------|-------|
| Title | `title` | yes | string |
| Summary | `summary` | yes | string |
| Problem | `problem` | yes | string (or short Markdown string) |
| Architecture image | `architecture_image` | yes | site-relative path to a static image (no Mermaid) |
| Key decisions | `decisions` | yes | list of strings, or list of `{ text }` maps |
| Results / metrics | `results` | yes | string or list |
| Stack | `stack` | yes | list of strings |
| Repository URL | `repo_url` | yes | `https://` URL |
| Demo URL | `demo_url` | no | `https://` URL; omit or blank → no Demo heading |
| Layout | `layout` | yes | `project` (so Hugo picks the project layout) |

Body Markdown after front matter MAY hold optional free-form notes; the required sections render from params. This feature authors only `smartwealthai.md`. Adding a future project is a new file with the same keys.

### Layout validation (AC3)

In the project layout, for each required field, if the value is missing or (for lists) empty, call `errorf` with a message that includes the human field name (`Summary`, `Problem`, `Architecture image`, `Key decisions`, `Results`, `Stack`, `Repository URL`) and the content path (`.File.Path`). Read every field with `index .Params "<key>"` (page `.Params` only, not site `.Param`), same rule as spec 003 FR-003/FR-004 follow-ups. For `architecture_image`, also fail when the path is blank; the image file under `static/` (or `assets/` if the implementation fingerprints it) must exist by the time the case study is content-complete. Optional `demo_url`: skip the Demo heading when absent or blank after trim.

### About page (AC4)

`content/about.md` holds short bio, stack, certifications (slot for AWS MLA-C02 in progress), LinkedIn, GitHub, and a link to `/cv/jorge-laborda-cv.pdf`. No `mailto:` and no email address. Implementation may use plain Markdown with marked placeholders, or a thin layout if validation of contact links is useful; either way, placeholders must be clearly marked so Jorge can replace them without editing templates. Default LinkedIn URL remains `https://www.linkedin.com/in/jorge-daniel-laborda-sicilia` until Jorge confirms or replaces it. GitHub remains `https://github.com/JLaborda`.

### CV asset (AC5, ADR 003)

- Canonical path: `static/cv/jorge-laborda-cv.pdf` → published URL `/cv/jorge-laborda-cv.pdf`.
- About and the main menu link that URL as a download (`download` attribute optional; destination must be the PDF). Those links land in the same implementation pull request as the PDF (tasks.md T003) so lychee offline stays green; do not add a lychee exclusion.
- No CI job generates a PDF. Jorge provides the file via a pull request (Pasos de Jorge); the Web Developer’s T003 commits it with the links if needed.
- `static/cv/` must contain only that PDF once T003 is done. Do not ship a README or other non-PDF under `static/cv/` (Hugo would publish it at `/cv/…`). Put agent/Jorge guidance in `specs/007-projects-about/tasks.md` or this plan instead.
- Until the PDF is in the tree, a PR that claims the CV is live must fail `test -f static/cv/jorge-laborda-cv.pdf` or lychee offline. T002 (About placeholders) omits CV hrefs for that reason.

### Menu (AC6)

`hugo.yaml` already has Projects, Now, About, Posts. Implementation MUST keep those four and add a CV download entry, for example:

```yaml
    - name: CV
      url: /cv/jorge-laborda-cv.pdf
      weight: 5
```

Weight may sit after Posts or next to About; the Verification greps for the PDF href and for Projects/About. Search stays off the main menu (profile button only).

### Delivery order

1. Docs pull request #74 (spec, plan, tasks, checklist, ADR 003), merged by Jorge (`needs-human`). *(done)*
2. `007-projects-about-t01` — project layout + required-field `errorf` + list page wiring + placeholder `smartwealthai.md` schema that builds. *(done)*
3. `007-projects-about-t02` — About placeholder structure only; no CV menu entry and no About PDF link (keeps lychee green). *(done, PR #77)*
4. Jorge completes «Pasos de Jorge» prose/diagram/LinkedIn as ready, and uploads or delivers `static/cv/jorge-laborda-cv.pdf` via a pull request (exact filename; never generated).
5. `007-projects-about-t03` — Web Developer: PDF in `static/cv/` (Jorge’s file), About + menu CV links in the same PR, delete `static/cv/README.md`, no lychee exclusion (FR-005, AC5, AC6 CV item).
6. After staging shows `/projects/`, `/projects/smartwealthai/`, `/about/` 200 and AC5 passes, `chore(007): converge` (T004) writes `converge.md`, Reviewer QA signs off, Jorge merges.
7. Jorge releases `develop` → `main` with a merge commit when he chooses.

## Complexity Tracking

No constitution violations require justification.
