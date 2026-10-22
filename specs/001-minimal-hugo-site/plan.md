# Implementation Plan: Minimal Hugo Site

**Branch**: `001-minimal-hugo-site` | **Date**: 2026-10-20 | **Spec**: [spec.md](./spec.md)

Status: Approved by Jorge — PR #8

**Input**: Feature specification from `/specs/001-minimal-hugo-site/spec.md`

## Summary

Publish a minimal English Hugo portfolio and blog for ML Engineering and MLOps recruiters in fintech. The site uses PaperMod profile mode, four menu sections (Projects, Now, About, Posts), a home-page Search button, a site feed advertised on the home page, and a draft welcome post that is absent from the published build.

This pull request is the feature 001 plan under constitution 1.1.0. The spec was approved under 1.0.0. From the plan onward the feature follows the full path. The only edit to `spec.md` is the Clarifications section for the 2026-10-20 clarify run, which found nothing material. `checklists/requirements.md` is added here and changes no requirement.

Hugo extended is pinned to **0.145.0**, not the latest stable 0.168.0, because 0.168.0 cannot build the latest PaperMod release tag. PaperMod is pinned to **v8.0**. Lychee **0.24.2** and gitleaks **8.30.1** are installed in CI and invoked as the literal commands in the specification. The measurements are in [research.md](./research.md).

## Technical Context

**Language/Version**: Hugo extended 0.145.0 (`HUGO_VERSION`), Go templates as shipped by PaperMod v8.0. Site content is Markdown.

**Primary Dependencies**: PaperMod v8.0 (`a2eb47bb4b805116dcd34c1605d39835121f8dbe`) as a git submodule at `themes/PaperMod`. CI installs lychee 0.24.2 and gitleaks 8.30.1 and runs their CLIs. Checkout is `actions/checkout` v7.0.1 (`3d3c42e5aac5ba805825da76410c181273ba90b1`).

**Storage**: Markdown and YAML in the git repository. Hugo writes `public/` at build time. That directory is not committed.

**Testing**: The Verification commands in the specification. No separate test framework. The branch check is the exact `yq` filter in FR-016.

**Target Platform**: Static HTML built on GitHub Actions (`ubuntu-latest`) and browsed as a local `hugo server` or as files under `public/`. AWS hosting is feature 002.

**Project Type**: Static website (Hugo).

**Performance Goals**: The published build is one `hugo --gc --minify --panicOnWarning --baseURL /` invocation. No runtime service level objective.

**Constraints**: English only. No email. No project CSS or JavaScript. Theme files are not edited. Theme overrides live only in `layouts/`. Monthly cost of this feature is 0 USD. The strict build must exit 0 on the pinned pair. Provisional `baseURL` in `hugo.yaml` is `https://example.org/`. CI still passes `--baseURL /`.

**Scale/Scope**: One home page, four sections, one placeholder project, one draft post, search, and one CI workflow.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Gate | Result |
|-----------|------|--------|
| I. Spec-driven, PO approval | `spec.md` is on `develop` as `Status: Approved by Jorge — PR #6`. This pull request is the plan step of the full path. It appends only the feature 001 Clarifications block and adds `checklists/requirements.md`. Custom `/speckit-checklist` items stay unchecked for QA's review. | Pass |
| II. Fixed stack | One Hugo extended version in `HUGO_VERSION` and the README. PaperMod is a submodule on tag `v8.0`, not a branch. The theme directory is not edited. The three partial overrides and the favicon files live in `layouts/` and `static/`. | Pass |
| III. AWS | No S3, CloudFront, Terraform, or OIDC in this feature. Region and DNS stay in feature 002. | Pass |
| IV. Verifiable CI | Jobs `hugo`, `lychee`, and `gitleaks` run on pull requests to `develop` and to `main`. Build uses `--baseURL /` and `--panicOnWarning`. The lychee job runs that same build first, because `public/` is not committed, then `lychee --offline --root-dir public public`. Gitleaks uses a synthetic key from `A-Z` and `234567`, never `AKIAIOSFODNN7EXAMPLE`. After `t03` merges, Jorge applies branch protection. `t04` records the `gh api` output in `converge.md` before the verdict `Converged`. | Pass |
| V. Scoped PRs | Four implementation branches, `001-minimal-hugo-site-t01` through `t04`. Each maps to the task ids in [tasks.md](./tasks.md). `t04` is the last pull request and commits `converge.md`. | Pass |
| VI. Explainable and cheap | Pinned static-site tools only. Expected monthly cost of feature 001 is **0 USD**. Overrides are a comma fix and two deleted `site.Social` branches. | Pass |
| VII. English | Plan, research, data model, contracts, quickstart, tasks, checklists, and the site are English. | Pass |

No gate fails. Complexity tracking is empty.

## Project Structure

### Documentation (this feature)

```text
specs/001-minimal-hugo-site/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── public-pages.md
├── checklists/
│   ├── requirements.md
│   └── review.md
├── tasks.md
└── converge.md          # written by the last implementation PR, not by this plan
```

### Source Code (repository root)

```text
.github/workflows/ci.yml
content/
├── about.md
├── now.md
├── search.md
├── posts/
│   ├── _index.md
│   └── welcome.md
└── projects/
    ├── _index.md
    └── smartwealthai.md
layouts/partials/templates/
├── opengraph.html
├── schema_json.html
└── twitter_cards.html
static/
├── apple-touch-icon.png
├── favicon-16x16.png
├── favicon-32x32.png
├── favicon.ico
└── safari-pinned-tab.svg
themes/PaperMod/          # submodule, tag v8.0, not edited
hugo.yaml
README.md
.gitignore
```

**Structure Decision**: A single Hugo site at the repository root. There is no `src/` tree and no application server. Feature 002 will add infrastructure beside this tree; this plan does not create it.

## Complexity Tracking

No constitution violations require justification.

## Post-design Constitution Check

Phase 1 does not add a service, a second language, a theme edit, or an implementation pull request. The gates above still pass. The layouts overrides are the constitution's allowed customization path, used only so the pinned tag builds under `--panicOnWarning`.
