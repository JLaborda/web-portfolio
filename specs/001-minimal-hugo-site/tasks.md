# Tasks: Minimal Hugo Site

Status: Approved by Jorge — PR #8

**Input**: Design documents from `/specs/001-minimal-hugo-site/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/public-pages.md, quickstart.md

**Tests**: The specification does not request a test framework. Each implementation pull request runs the verification command named for its group. There are no separate test tasks.

**Organization**: Tasks are grouped by user story. Delivery is grouped into four pull requests so the team reviews a small number of changes. The commands are the ones in the specification Verification section.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: User story label. Setup, Foundational, and Polish tasks have none.
- Every description names a file path.

On every implementation branch, before Spec Kit scripts, export `SPECIFY_FEATURE_DIRECTORY=specs/001-minimal-hugo-site`.

## Path conventions

Hugo site at the repository root. See the source tree in [plan.md](./plan.md).

## Implementation pull requests

Four pull requests, merged one at a time into `develop`, from these branches. Each pull request lists its task ids in the description and marks those same ids `[X]` in this file. The last pull request also commits `specs/001-minimal-hugo-site/converge.md`.

Every row's verification also runs:

```bash
git diff --stat origin/develop...HEAD
```

Expected: the diff does not add Terraform, an AWS template, an analytics snippet, a contact form, a comments partial, a second language, or an email address.

| Branch | Tasks | Requirements | Depends on | Verification command |
|--------|-------|--------------|------------|----------------------|
| `001-minimal-hugo-site-t01` | T001–T008 | FR-001, FR-013 (submodule, theme untouched, no project CSS or JS), FR-014 (file, language, author, base URL, no email), FR-015 (README text and version string), FR-019, FR-020 | This `tasks.md` merged | `hugo --gc --minify --panicOnWarning --baseURL /` exits 0. `git -C themes/PaperMod describe --tags --exact-match HEAD` prints `v8.0`. `test ! -e config.toml`. `grep -E '^defaultContentLanguage: *en$' hugo.yaml` and `grep -F 'https://example.org/' hugo.yaml` exit 0. The email guard on `hugo.yaml` finds nothing. README contains the audience sentence, `0.145.0`, `git clone --recurse-submodules`, and `hugo server -D`. `.gitignore` contains `public/`, `resources/_gen/`, and `.hugo_build.lock`. The FR-013 `HUGO_VERSION` count and the FR-015 extraction from that variable are checked in `t03`, when `.github/workflows/ci.yml` exists. |
| `001-minimal-hugo-site-t02` | T009–T017 | FR-001, FR-002, FR-003, FR-004, FR-005, FR-006, FR-007, FR-008, FR-009, FR-010, FR-011, FR-012, FR-014 (social links in `hugo.yaml`), FR-020 | `t01` merged | The FR-002 through FR-012 blocks in the specification Verification section. The draft build uses `--destination /tmp/public-drafts`. The feed alternate link is required on `public/index.html` only. |
| `001-minimal-hugo-site-t03` | T018–T022 | FR-013 (`HUGO_VERSION`), FR-015 (README matches that variable), FR-016, FR-017, FR-018, FR-020 | `t02` merged | `yq -e '[.on.pull_request.branches[] \| select(. == "develop" or . == "main")] \| unique \| length == 2' .github/workflows/ci.yml` prints `true`. Grep the workflow for the hugo command, `lychee --offline --root-dir public public`, `fetch-depth: 0`, and `gitleaks detect --redact --log-opts="${{ github.event.pull_request.base.sha }}..${{ github.event.pull_request.head.sha }}"`. The lychee job runs the hugo command before lychee, because `public/` is gitignored, and its external step also passes `--root-dir public`. The Hugo tarball name is `hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz`. The FR-013 version count is 1 and README contains that value. The unpushed local proofs in the specification pass. A separate throwaway pull request, closed and not merged, shows the hugo job red on the warnf shortcode, lychee red on `/does-not-exist/`, and lychee green with `::warning::https://example.invalid/spec-001-missing`. The gitleaks failure proof stays local and is not pushed. |
| `001-minimal-hugo-site-t04` | T023–T024 | FR-021, FR-020, converge | `t03` merged, and Jorge has applied branch protection | `specs/001-minimal-hugo-site/converge.md` contains the `gh api` output `["gitleaks","hugo","lychee"]` for `develop` and for `main`, then the date, the SHA it ran on, and the verdict `Converged`. The pull request description pastes that verdict. |

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Pin the theme and record the site configuration that every later task builds on.

**Pull request**: `001-minimal-hugo-site-t01`

- [X] T001 Add the PaperMod git submodule at `themes/PaperMod` pinned to tag `v8.0` (`a2eb47bb4b805116dcd34c1605d39835121f8dbe`) and record that URL in `.gitmodules`
- [X] T002 Create `hugo.yaml` with `theme: PaperMod`, `baseURL: https://example.org/`, `defaultContentLanguage: en`, title `Jorge D. Laborda Sicilia`, author `Jorge D. Laborda Sicilia`, `disableThemeToggle: false`, `ShowBreadCrumbs: true`, no email field, and home outputs `HTML`, `RSS`, and `JSON`
- [X] T003 Add `public/`, `resources/_gen/`, and `.hugo_build.lock` to `.gitignore`
- [X] T004 Document in `README.md` that the site is a portfolio and blog for ML Engineering and MLOps recruiters and hiring managers in fintech, and document Hugo extended `0.145.0`, `git clone --recurse-submodules`, and `hugo server -D`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Make the pinned Hugo and PaperMod pair pass the strict build, and give lychee the icon files the theme links.

**Critical**: No user-story pull request starts until `001-minimal-hugo-site-t01` is merged.

**Pull request**: `001-minimal-hugo-site-t01`

- [X] T005 [P] Add `static/favicon.ico`, `static/favicon-16x16.png`, `static/favicon-32x32.png`, `static/apple-touch-icon.png`, and `static/safari-pinned-tab.svg` so PaperMod's default icon links resolve
- [X] T006 [P] Add `layouts/partials/templates/schema_json.html` copied from `themes/PaperMod/layouts/partials/templates/schema_json.html` at tag `v8.0`, changing only the BreadcrumbList commas to the `scratch` key `item` so `hugo --minify` accepts `/projects/smartwealthai/`
- [X] T007 [P] Add `layouts/partials/templates/opengraph.html` and `layouts/partials/templates/twitter_cards.html` copied from `themes/PaperMod/layouts/partials/templates/opengraph.html` and `twitter_cards.html` at tag `v8.0`, deleting only the `else` branches that call `site.Social.facebook_admin` and `site.Social.twitter`
- [X] T008 Run `hugo --gc --minify --panicOnWarning --baseURL /` from the repository root and require exit 0. Do not add a project stylesheet or script; theme overrides stay in `layouts/`

**Checkpoint**: The empty site builds strictly. Theme files under `themes/PaperMod` are unchanged.

---

## Phase 3: User Story 1 - Recruiter opens the portfolio (Priority: P1)

**Goal**: The home page shows Jorge's name, the placeholder headline, the two social links, and the four menu destinations. Projects lists the SmartWealthAI placeholder.

**Independent Test**: Build the published site. The home page shows `Jorge D. Laborda Sicilia`, `Placeholder headline`, GitHub, and LinkedIn, and no email. The menu opens Projects, Now, About, and Posts and does not offer Search. SmartWealthAI is marked as a placeholder and links to its repository.

**Pull request**: `001-minimal-hugo-site-t02`

### Implementation for User Story 1

- [ ] T009 [US1] Set `params.profileMode` in `hugo.yaml` to title `Jorge D. Laborda Sicilia`, subtitle `Placeholder headline`, and one button named Search with url `/search/`
- [ ] T010 [US1] Set `params.socialIcons` in `hugo.yaml` to GitHub `https://github.com/JLaborda` and LinkedIn `https://www.linkedin.com/in/jorge-daniel-laborda-sicilia` only
- [ ] T011 [US1] Set `menu.main` in `hugo.yaml` to exactly Projects `/projects/`, Now `/now/`, About `/about/`, and Posts `/posts/`, in that order
- [ ] T012 [P] [US1] Create `content/projects/_index.md` and `content/projects/smartwealthai.md` with the word `placeholder` and the link `https://github.com/JLaborda/SmartWealthAI`

**Checkpoint**: User Story 1's home, menu, and project entry match [contracts/public-pages.md](./contracts/public-pages.md). Now and About may still be empty routes until Phase 4.

---

## Phase 4: User Story 2 - Recruiter reads what is current (Priority: P2)

**Goal**: Now and About are published English placeholder pages.

**Independent Test**: Open `/now/` and `/about/` on the published build. Each page contains the word `placeholder`.

**Pull request**: `001-minimal-hugo-site-t02`

### Implementation for User Story 2

- [ ] T013 [P] [US2] Create `content/now.md` in English containing the word `placeholder` and placeholder text for what Jorge is learning and doing now
- [ ] T014 [P] [US2] Create `content/about.md` in English containing the word `placeholder`

**Checkpoint**: User Stories 1 and 2 both render from one published build.

---

## Phase 5: User Story 3 - Recruiter uses search, the feed, and posts (Priority: P3)

**Goal**: Search is a home-page button, the home page advertises `/index.xml`, light/dark switching is present, and the welcome post exists only as a draft that previews with a table of contents and `1 min`.

**Independent Test**: On the published build, `/search/` and `/index.json` exist, the welcome post is absent from `public/`, from the feed, and from the JSON index, and the home head links to `/index.xml`. The draft build at `/tmp/public-drafts/posts/welcome/index.html` shows the table of contents and `1 min`.

**Pull request**: `001-minimal-hugo-site-t02`

### Implementation for User Story 3

- [ ] T015 [P] [US3] Create `content/search.md` with `layout: search` so the published build writes `public/search/index.html` and `public/index.json`
- [ ] T016 [P] [US3] Create `content/posts/_index.md` and `content/posts/welcome.md` with `draft: true`, title `Welcome`, slug `welcome`, date `2026-10-20`, `ShowToc: true`, and exactly two level-2 headings, `First section` and `Second section`, in under 200 words
- [ ] T017 [US3] Set `ShowReadingTime: true`, `ShowToc: true`, and `UseHugoToc: true` in `hugo.yaml` so the draft preview shows a table of contents and the text `1 min`

**Checkpoint**: The FR-008 through FR-012 verification commands pass, including a draft destination that does not create `public/posts/welcome/index.html`.

---

## Phase 6: CI gates

**Purpose**: Run the strict build, lychee, and gitleaks on pull requests to `develop` and to `main`.

**Pull request**: `001-minimal-hugo-site-t03`

- [ ] T018 Create `.github/workflows/ci.yml` with `on.pull_request.branches` set to `develop` and `main`, and with `HUGO_VERSION` `0.145.0`, `LYCHEE_VERSION` `0.24.2`, and `GITLEAKS_VERSION` `8.30.1` indented under `env`
- [ ] T019 Add the `hugo` job to `.github/workflows/ci.yml` (job key `hugo:`) using `actions/checkout` at `3d3c42e5aac5ba805825da76410c181273ba90b1` (v7.0.1) with `submodules: recursive`, installing `hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz` from `HUGO_VERSION`, and running `hugo --gc --minify --panicOnWarning --baseURL /`
- [ ] T020 Add the `lychee` job to `.github/workflows/ci.yml` (job key `lychee:`) that checks out with that same commit and `submodules: recursive`, installs Hugo extended from `hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz`, and runs `hugo --gc --minify --panicOnWarning --baseURL /` so `public/` exists (`public/` is gitignored). Install lychee `0.24.2` from `lychee-x86_64-unknown-linux-gnu.tar.gz` on tag `lychee-v0.24.2` and run `lychee --offline --root-dir public public`. Add a second `run:` step with `continue-on-error: true` that runs `lychee --exclude https://www.linkedin.com/in/jorge-daniel-laborda-sicilia --root-dir public public` and prints `::warning::` plus each failing URL
- [ ] T021 Add the `gitleaks` job to `.github/workflows/ci.yml` (job key `gitleaks:`) that checks out `actions/checkout` at `3d3c42e5aac5ba805825da76410c181273ba90b1` with `fetch-depth: 0`, installs gitleaks `8.30.1` from `gitleaks_8.30.1_linux_x64.tar.gz`, and runs `gitleaks detect --redact --log-opts="${{ github.event.pull_request.base.sha }}..${{ github.event.pull_request.head.sha }}"`
- [ ] T022 Run the FR-016, FR-017, and FR-018 local proofs in the specification on branches `spec-001-warnf`, `spec-001-lychee`, and `spec-001-gitleaks`, then delete those branches without pushing them. Separately, open one throwaway pull request and close it without merging: its Actions runs show the hugo job red for the warnf shortcode, lychee red for `[x](/does-not-exist/)`, and lychee green with `::warning::https://example.invalid/spec-001-missing` in the log. Paste those Actions run links in the `t03` pull request description. The synthetic gitleaks secret stays only on the unpushed local branch

**Checkpoint**: The workflow-file checks in the `t03` row pass, and the throwaway pull request has shown the three job outcomes. The gitleaks failure proof is local only.

---

## Phase 7: Polish and converge

**Purpose**: Record branch protection and close the feature with a written converge result.

**Pull request**: `001-minimal-hugo-site-t04` (the last implementation pull request)

Jorge applies branch protection on `develop` and `main`, requiring `hugo`, `lychee`, and `gitleaks`, after `t03` is merged and before this pull request declares `Converged`.

- [ ] T023 Run the FR-021 `gh api` loop for `develop` and `main` and write both outputs, `["gitleaks","hugo","lychee"]`, into `specs/001-minimal-hugo-site/converge.md` before the verdict
- [ ] T024 Run `/speckit-converge` on the last implementation pull request and commit its full output, the date, the commit SHA it ran on, and the verdict `Converged` to `specs/001-minimal-hugo-site/converge.md`

---

## Dependencies and execution order

### Phase dependencies

- Phase 1 and Phase 2 ship together as `t01`. Phase 2 blocks every user story.
- Phases 3, 4, and 5 ship together as `t02` after `t01`. They are one cohesive content change.
- Phase 6 (`t03`) depends on `t02`, because lychee and the strict build need the published pages.
- Phase 7 (`t04`) depends on `t03` being merged and on Jorge applying branch protection. Converge cannot say `Converged` while FR-021 is unmet.

### User story dependencies

- User Story 1 (P1) starts after Phase 2. It does not require User Story 2 or 3.
- User Story 2 (P2) starts after Phase 2. It does not require the draft post.
- User Story 3 (P3) starts after Phase 2. The Search button is configured in User Story 1's `hugo.yaml` edits, which land in the same pull request.

### Parallel opportunities

- T005, T006, and T007 touch different files and can be written together.
- T013 and T014 can be written together.
- T015 and T016 can be written together.
- T009, T010, T011, and T017 all edit `hugo.yaml`, so they stay in one commit sequence inside `t02`.

## Parallel example: User Story 1

```bash
# T012 is a different file from the hugo.yaml edits in T009–T011:
# content/projects/_index.md
# content/projects/smartwealthai.md
```

## Parallel example: User Story 2

```bash
# Different files, same pull request 001-minimal-hugo-site-t02:
# content/now.md
# content/about.md
```

## Parallel example: User Story 3

```bash
# Different files, same pull request 001-minimal-hugo-site-t02:
# content/search.md
# content/posts/_index.md
# content/posts/welcome.md
```

## Implementation strategy

### MVP first

1. Merge `t01` (T001–T008). The strict build exits 0.
2. Merge `t02` (T009–T017). Stop and run the content verification commands. This is the recruiter-visible site.
3. Merge `t03` (T018–T022). CI gates match FR-016 through FR-018, including the throwaway Actions runs.
4. Jorge applies branch protection on `develop` and `main`. Then merge `t04` (T023–T024). `converge.md` records the protection output and then says `Converged`.

### Why four pull requests

The content tasks are small and cohesive, so User Stories 1 through 3 share one pull request. CI is separate because it is the constitution's gate and is easier to review alone. Converge stays on the last pull request, as the constitution requires. That is four implementation pull requests, inside the three-to-five range.

## Notes

- Do not edit files under `themes/PaperMod`.
- Do not commit `public/`, `.specify/feature.json`, or a generated gitleaks key.
- The synthetic key alphabet is `A-Z` plus `234567`. The expected rule id is `aws-access-token`.
- Mark task ids `[X]` only in the pull request that closes them.
- Do not mark items in `checklists/review.md`. QA records those marks in its review.
