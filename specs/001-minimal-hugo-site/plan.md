# Implementation Plan: Minimal Hugo Site

**Branch**: `001-minimal-hugo-site-plan` | **Date**: 2026-10-20 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-minimal-hugo-site/spec.md`

Status: Approved by Jorge — PR #PLANPR

## Summary

Publish a minimal English Hugo portfolio and blog for ML Engineering and MLOps recruiters in fintech. The site uses PaperMod profile mode, four menu sections (Projects, Now, About, Posts), a home-page Search button, a site feed advertised on the home page, and a draft welcome post that is absent from the published build.

The authoritative acceptance text for this plan is the Verification section from pull request #4 plus the requirement amendments QA requested on that review (FR-010 scoped to the home page, and FR-016, FR-017, and FR-018 covering pull requests to `develop` and `main`, with gitleaks using `fetch-depth: 0` and the pull-request SHA range). Pull request #4 is not the spec of record: those amendments land on branch `001-minimal-hugo-site`. This plan follows that amended text even if the amendment pull request is still open.

Hugo extended is pinned to **0.145.0**, not the latest stable 0.168.0, because 0.168.0 cannot build the latest PaperMod release tag. PaperMod is pinned to **v8.0**, which is the latest release tag. Lychee **0.24.2** and gitleaks **8.30.1** are pinned together with their GitHub Actions. The incompatibility and the measured build are recorded in [research.md](./research.md).

## Technical Context

**Language/Version**: Hugo extended 0.145.0 (`HUGO_VERSION`), Go templates as shipped by PaperMod v8.0. Site content is Markdown.

**Primary Dependencies**: PaperMod v8.0 (`a2eb47bb4b805116dcd34c1605d39835121f8dbe`) as a git submodule at `themes/PaperMod`. CI tools: lychee 0.24.2 (`lycheeverse/lychee-action` v2.9.0, `e7477775783ea5526144ba13e8db5eec57747ce8`), gitleaks 8.30.1 (`gitleaks/gitleaks-action` v3.0.0, `e0c47f4f8be36e29cdc102c57e68cb5cbf0e8d1e`), `actions/checkout` v7.0.1 (`3d3c42e5aac5ba805825da76410c181273ba90b1`).

**Storage**: Markdown and YAML in the git repository. Hugo writes `public/` at build time. That directory is not committed.

**Testing**: The Verification commands in the specification. No separate test framework. `yq` (jq-style YAML filter) checks `on.pull_request.branches`.

**Target Platform**: Static HTML built on GitHub Actions (`ubuntu-latest`) and browsed as a local `hugo server` or as files under `public/`. AWS hosting is feature 002.

**Project Type**: Static website (Hugo).

**Performance Goals**: The published build is one `hugo --gc --minify --panicOnWarning --baseURL /` invocation. No runtime service level objective.

**Constraints**: English only. No email. No project CSS or JavaScript. Theme files are not edited. Theme overrides live only in `layouts/`. Monthly cost of this feature is 0 USD. The strict build must exit 0 on the pinned pair.

**Scale/Scope**: One home page, four sections, one placeholder project, one draft post, search, and one CI workflow.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Gate | Result |
|-----------|------|--------|
| I. Spec-driven, PO approval | `spec.md` is already on `develop` as `Status: Approved by Jorge — PR #3`. This pull request adds `plan.md` and `tasks.md` only after that merge. Implementation pull requests wait until this pull request is merged. | Pass |
| II. Fixed stack | One Hugo extended version in `HUGO_VERSION` and the README. PaperMod is a submodule on tag `v8.0`, not a branch. The theme directory is not edited. The three partial overrides and the favicon files live in `layouts/` and `static/`. | Pass |
| III. AWS | No S3, CloudFront, Terraform, or OIDC in this feature. Region and DNS stay in feature 002. | Pass |
| IV. Verifiable CI | Jobs `hugo`, `lychee`, and `gitleaks` run on pull requests to `develop` and to `main`. Build uses `--baseURL /` and `--panicOnWarning`. Lychee uses `--offline --root-dir public public`. Gitleaks uses a synthetic key from `A-Z` and `234567`, never `AKIAIOSFODNN7EXAMPLE`. Branch protection (FR-021) is Jorge's admin step after the workflow is on `develop`. | Pass |
| V. Scoped PRs | Four implementation branches, `001-minimal-hugo-site-t01` through `t04`. Each maps to the task ids in [tasks.md](./tasks.md). `t04` is the last pull request and commits `converge.md`. | Pass |
| VI. Explainable and cheap | Pinned static-site tools only. Expected monthly cost of feature 001 is **0 USD**. No opaque host. | Pass |
| VII. English | Plan, research, data model, contracts, quickstart, tasks, and the site are English. | Pass |

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
