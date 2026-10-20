# Feature Specification: Minimal Hugo Site

**Feature Branch**: `001-minimal-hugo-site`

**Created**: 2026-10-20

Status: Pending approval

**Input**: User description: "Minimal Hugo site with the PaperMod theme. Portfolio and blog for ML Engineering and MLOps recruiters in fintech. Sections: Projects (SmartWealthAI placeholder), Now, About, and Posts (welcome post as a draft). Menu with those four links. PaperMod search, RSS, and table of contents enabled. Site language English. Social links: GitHub https://github.com/JLaborda and LinkedIn https://www.linkedin.com/in/jorge-daniel-laborda-sicilia. No email in this feature. CI on pull requests to develop: hugo build with --baseURL /, lychee on public/ with --root-dir, gitleaks with a synthetic secret that is not AKIAIOSFODNN7EXAMPLE. Pinned Hugo extended and PaperMod as a git submodule on a tag. Out of scope: AWS deployment, Terraform, domain, DNS, email, analytics, and real project content."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Recruiter opens the portfolio (Priority: P1)

A recruiter or hiring manager in ML Engineering or MLOps fintech opens the site and can see who Jorge is, what he has built, what he is doing now, and how to reach his GitHub and LinkedIn profiles. The only project listed is a clearly marked SmartWealthAI placeholder, not a finished case study.

**Why this priority**: Without a readable home page and the four sections, the site does not serve its audience.

**Independent Test**: Build the published site and open the home page. The four section links, the author's name, one headline line, and the two social links are visible. The SmartWealthAI entry is visibly a placeholder and links to its public repository.

**Acceptance Scenarios**:

1. **Given** the published site, **When** a visitor opens the home page, **Then** they see Jorge's name, one headline line, a link to https://github.com/JLaborda, and a link to https://www.linkedin.com/in/jorge-daniel-laborda-sicilia, and they do not see an email address.
2. **Given** the published site, **When** a visitor uses the menu, **Then** they can open Projects, Now, About, and Posts.
3. **Given** the published Projects page, **When** a visitor opens SmartWealthAI, **Then** the page is marked as a placeholder and links to https://github.com/JLaborda/SmartWealthAI.

---

### User Story 2 - Recruiter reads what is current (Priority: P2)

A recruiter opens Now and About to see what Jorge is learning and doing, and a short statement about him. The copy in this feature is placeholder text, not the final wording.

**Why this priority**: Recruiters need a current picture, but final prose is not part of this feature.

**Independent Test**: Open the published Now and About pages. Each page renders in English and is identifiable as placeholder copy.

**Acceptance Scenarios**:

1. **Given** the published site, **When** a visitor opens Now, **Then** the page is in English and states that the wording is a placeholder for what Jorge is learning and doing.
2. **Given** the published site, **When** a visitor opens About, **Then** the page is in English and states that the wording is a placeholder.

---

### User Story 3 - Recruiter uses search, the feed, and posts (Priority: P3)

A recruiter can search the published pages, follow the site feed, and switch between light and dark. The welcome post exists only as a draft, so it is absent from the published site, the feed, and search. When that draft is previewed, the post shows a table of contents and a reading time.

**Why this priority**: Search, the feed, and post tools are part of the reading experience, and an unpublished draft must not look like a live post.

**Independent Test**: On the published build, search and the feed exist, and the welcome post does not. A draft preview of the welcome post shows a table of contents and a reading time.

**Acceptance Scenarios**:

1. **Given** the published site, **When** a visitor opens search, **Then** search is available and does not list the welcome post.
2. **Given** the published site, **When** a visitor opens the feed, **Then** a feed is available and does not include the welcome post.
3. **Given** a draft preview, **When** a visitor opens the welcome post, **Then** the post shows a table of contents and a reading time, and it is still absent from the published site.

---

### Edge Cases

- The welcome post is a draft. A published build does not list it, link it from Posts, include it in search, or include it in the feed.
- A broken link to another page on the site fails the pull-request check. A broken link to an external site does not fail that check; it is reported as a warning.
- Cloning the repository without the theme submodule does not produce a successful strict build.
- The home page and every published section render in English. No second language is offered.
- No published page shows an email address or a mailto link.
- Placeholder pages stay visibly marked as placeholders. This feature does not add final project write-ups.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The site MUST be a portfolio and blog whose audience is ML Engineering and MLOps recruiters and hiring managers in fintech.
- **FR-002**: The site language MUST be English on every published page, including navigation labels.
- **FR-003**: The home page MUST show Jorge's name, one headline line, and only these social links: GitHub at https://github.com/JLaborda and LinkedIn at https://www.linkedin.com/in/jorge-daniel-laborda-sicilia. It MUST NOT show an email address. The headline line MUST be placeholder copy.
- **FR-004**: The main menu MUST contain exactly four links, labeled Projects, Now, About, and Posts, pointing at those sections.
- **FR-005**: Projects MUST list one entry, SmartWealthAI. That entry MUST be clearly marked as a placeholder and MUST link to https://github.com/JLaborda/SmartWealthAI.
- **FR-006**: Now MUST be a published page whose copy is a placeholder for what Jorge is learning and doing now.
- **FR-007**: About MUST be a published page whose copy is a placeholder.
- **FR-008**: Posts MUST be a published section with no published posts. It MUST contain one welcome post marked as a draft. That draft MUST NOT appear in the published site, the feed, or search.
- **FR-009**: Visitors MUST be able to search published pages. The search index MUST NOT include the draft welcome post.
- **FR-010**: The site MUST offer a feed of published pages and posts. The feed MUST NOT include the draft welcome post.
- **FR-011**: Visitors MUST be able to switch between a light and a dark appearance.
- **FR-012**: When the welcome post is previewed as a draft, it MUST show a table of contents and a reading time. The placeholder post MUST contain at least two headings so the table of contents is visible.
- **FR-013**: The site MUST be built with Hugo extended. The version MUST be a single pinned extended release, recorded in one workflow variable and repeated in the README. The PaperMod theme MUST be a git submodule at `themes/PaperMod` pinned to a release tag, not to a branch. The theme files MUST NOT be edited. This feature MUST NOT add project CSS or JavaScript.
- **FR-014**: Site configuration MUST live in `hugo.yaml`, not in `config.toml`. It MUST set the title, a provisional base URL, English as the default language, the author, and the two social links. It MUST NOT set an email.
- **FR-015**: The README MUST state what the site is, the pinned Hugo extended version, how to clone the repository with submodules, and how to preview locally including drafts.
- **FR-016**: Pull requests to `develop` MUST run a continuous-integration build that checks out submodules, installs the pinned Hugo extended version, and runs `hugo --gc --minify --panicOnWarning --baseURL /`. A template warning or a failed build MUST fail the check.
- **FR-017**: That same pull-request check MUST run lychee against `public/` with `--root-dir` set so root-relative links are resolved inside `public/`. A broken internal link MUST fail the check. A broken external link MUST NOT fail the check and MUST be reported only as a warning.
- **FR-018**: That same pull-request check MUST run gitleaks and MUST pass on the repository as specified. A test change that adds a synthetic secret the active gitleaks ruleset reports MUST fail the check. That synthetic secret MUST NOT be `AKIAIOSFODNN7EXAMPLE`, because the default rules allowlist it. The specification MUST NOT contain a live secret value.
- **FR-019**: Generated build output MUST NOT be committed. `public/`, `resources/_gen/`, and `.hugo_build.lock` MUST be ignored by git.
- **FR-020**: Final project write-ups, the final About and Now wording, an email address, analytics, comments, a contact form, more than one language, AWS deployment, Terraform, a domain, and DNS MUST NOT be part of this feature.

### Key Entities

- **Home page**: The author's name, one placeholder headline, and the two social links.
- **Project entry**: A title, a placeholder notice, and one outbound repository link. The only entry is SmartWealthAI.
- **Now page**: Placeholder copy for current learning and work.
- **About page**: Placeholder copy about Jorge.
- **Welcome post**: A draft post with at least two headings. It is not part of the published site.
- **Menu**: The four labels Projects, Now, About, and Posts.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A visitor can open the home page and reach Projects, Now, About, and Posts from the menu without using a search engine or an external index.
- **SC-002**: On the published site, the visitor sees exactly two social destinations (GitHub and LinkedIn) and zero email addresses.
- **SC-003**: On the published site, the visitor sees exactly one project, and that project is visibly a placeholder.
- **SC-004**: On the published site, the welcome post is absent from Posts, from search, and from the feed. It is visible only in a draft preview.
- **SC-005**: A reviewer can confirm every acceptance criterion in Verification with the command or file check named there, with no extra manual judgment beyond comparing the command result to the expected result.

## Verification

Each row is the acceptance check for this feature. Commands assume the repository root after `git clone --recurse-submodules`, unless the row says otherwise. The published build is:

```bash
hugo --gc --minify --panicOnWarning --baseURL /
```

That command MUST exit 0 and MUST create `public/index.html`.

- **FR-002, FR-004**: `public/index.html` contains `lang="en"`. The main menu contains the labels Projects, Now, About, and Posts and the paths `/projects/`, `/now/`, `/about/`, and `/posts/`, and it does not contain a fifth section label.
- **FR-003**: `public/index.html` contains `https://github.com/JLaborda` and `https://www.linkedin.com/in/jorge-daniel-laborda-sicilia`, and it does not contain `mailto:`.
- **FR-005**: These files exist: `public/projects/index.html` and `public/projects/smartwealthai/index.html`. The project page contains the word `placeholder` and `https://github.com/JLaborda/SmartWealthAI`.
- **FR-006, FR-007, FR-008**: These files exist: `public/now/index.html`, `public/about/index.html`, and `public/posts/index.html`. `public/now/index.html` and `public/about/index.html` each contain the word `placeholder`. A search of `public/` for the welcome post's slug returns no file. Repeating the build with drafts enabled (`hugo --gc --minify --panicOnWarning --baseURL / -D`) creates the welcome post under `public/` and the published command above does not.
- **FR-009, FR-010**: `public/index.json` and `public/index.xml` exist, and a search page exists at `public/search/index.html`. The draft welcome title is absent from `public/index.json` and from `public/index.xml`.
- **FR-011**: `public/index.html` contains `id="theme-toggle"`.
- **FR-012**: The draft build (`-D`) of the welcome post contains `class="toc"` and the substring `min`.
- **FR-013**: `git -C themes/PaperMod describe --tags --exact-match HEAD` prints a tag and exits 0. `git ls-tree HEAD themes/PaperMod` records a gitlink, not an ordinary tree of theme files. No commit in this feature changes files under `themes/PaperMod` except that gitlink. The workflow file contains one Hugo extended version variable, and the README states that same version.
- **FR-014**: `hugo.yaml` exists and `config.toml` does not. `hugo.yaml` sets the language to English and does not contain an email address.
- **FR-015**: The README names the site, the pinned Hugo extended version, `git clone --recurse-submodules`, and `hugo server -D`.
- **FR-016**: On a pull request to `develop`, the workflow checks out submodules, installs that pinned Hugo extended version, and runs `hugo --gc --minify --panicOnWarning --baseURL /`. Replacing a published page's body with an unknown shortcode on a test branch MUST make that check exit non-zero.
- **FR-017**: The workflow runs lychee on `public/` with `--root-dir` pointing at `public/`. Adding `[x](/does-not-exist/)` to a published page on a test branch MUST make the lychee step exit non-zero. A broken external URL on a test branch MUST leave the step successful and MUST appear only as a warning.
- **FR-018**: The workflow runs gitleaks and the step exits 0 on this feature. Adding a synthetic value that the pinned gitleaks ruleset reports, other than `AKIAIOSFODNN7EXAMPLE`, MUST make the step exit non-zero. Removing that value MUST make the step exit 0 again.
- **FR-019**: `.gitignore` contains `public/`, `resources/_gen/`, and `.hugo_build.lock`. `git status` after the published build does not list files under `public/`.
- **FR-020**: The diff for this feature does not add Terraform, AWS deployment, analytics, a contact form, comments, a second language, or an email address.

## Out of Scope

- AWS deployment, Terraform, a domain, DNS, and HTTPS. Those belong to feature 002.
- An email address or mailto link. That is a later, separate change.
- Analytics, comments, and a contact form.
- More than one language.
- Final project write-ups and final About, Now, headline, and welcome-post wording. Jorge writes and approves that copy later. This feature uses placeholders only.

## Assumptions

- The home page uses PaperMod's profile or home-info presentation: name, one headline line, and the social links. Final headline wording is a placeholder.
- Now is published at `/now/`. The source file may be `content/now.md` or a `content/now/` page, as long as the published path is `/now/`.
- About is published at `/about/`. Projects are published at `/projects/` and `/projects/smartwealthai/`. Posts are published at `/posts/`.
- Menu labels are Projects, Now, About, and Posts. Posts is the blog section.
- Light/dark switching and reading time stay in this feature because they were part of the source draft and no decision removed them. Search, RSS, and the table of contents were confirmed again for this feature.
- The exact Hugo extended release and the exact PaperMod tag are chosen in the plan. This specification requires only that each is a single pinned release, not a floating branch.
- `Status: Pending approval` stays until Jorge merges this pull request. After that merge, the Tech Lead replaces it with `Status: Approved by Jorge — PR #N` for this pull request's number. This pull request does not invent that number.
- No product question is left open. Language, social links, and the absence of email are decided.
