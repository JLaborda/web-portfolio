# Feature Specification: Minimal Hugo Site

**Feature Branch**: `001-minimal-hugo-site`

**Created**: 2026-10-20

Status: Approved by Jorge — PR #6

**Input**: User description: "Minimal Hugo site with the PaperMod theme. Portfolio and blog for ML Engineering and MLOps recruiters in fintech. Sections: Projects (SmartWealthAI placeholder), Now, About, and Posts (welcome post as a draft). Menu with those four links. PaperMod search, RSS, and table of contents enabled. Site language English. Social links: GitHub https://github.com/JLaborda and LinkedIn https://www.linkedin.com/in/jorge-daniel-laborda-sicilia. No email in this feature. CI on pull requests to develop: hugo build with --baseURL /, lychee on public/ with --root-dir, gitleaks with a synthetic secret that is not AKIAIOSFODNN7EXAMPLE. Pinned Hugo extended and PaperMod as a git submodule on a tag. Out of scope: AWS deployment, Terraform, domain, DNS, email, analytics, and real project content."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Recruiter opens the portfolio (Priority: P1)

A recruiter or hiring manager in ML Engineering or MLOps fintech opens the site and can see who Jorge is, what he has built, what he is doing now, and how to reach his GitHub and LinkedIn profiles. The only project listed is a clearly marked SmartWealthAI placeholder, not a finished case study.

**Why this priority**: Without a readable home page and the four sections, the site does not serve its audience.

**Independent Test**: Build the published site and open the home page. The four menu links, the author's name, the placeholder headline, and the two social links are visible. The SmartWealthAI entry is visibly a placeholder and links to its public repository.

**Acceptance Scenarios**:

1. **Given** the published site, **When** a visitor opens the home page, **Then** they see the name `Jorge D. Laborda Sicilia`, the headline `Placeholder headline`, a link to https://github.com/JLaborda, and a link to https://www.linkedin.com/in/jorge-daniel-laborda-sicilia, and they do not see an email address.
2. **Given** the published site, **When** a visitor uses the menu, **Then** they can open Projects, Now, About, and Posts, and the menu does not offer Search.
3. **Given** the published Projects page, **When** a visitor opens SmartWealthAI, **Then** the page is marked as a placeholder and links to https://github.com/JLaborda/SmartWealthAI.

---

### User Story 2 - Recruiter reads what is current (Priority: P2)

A recruiter opens Now and About to see what Jorge is learning and doing, and a short statement about him. The copy in this feature is placeholder text, not the final wording.

**Why this priority**: Recruiters need a current picture, but final prose is not part of this feature.

**Independent Test**: Open the published Now and About pages. Each page renders in English and is identifiable as placeholder copy.

**Acceptance Scenarios**:

1. **Given** the published site, **When** a visitor opens Now, **Then** the page is in English and contains the word `placeholder`.
2. **Given** the published site, **When** a visitor opens About, **Then** the page is in English and contains the word `placeholder`.

---

### User Story 3 - Recruiter uses search, the feed, and posts (Priority: P3)

A recruiter opens search from a button on the home page, not from the menu. The site advertises its feed in the page head, not as a menu item and not as a social icon. The visitor can switch between light and dark. The welcome post exists only as a draft titled `Welcome` at slug `welcome`, so it is absent from the published site, the feed, and search. When that draft is previewed, the post shows a table of contents and a reading time of `1 min`.

**Why this priority**: Search, the feed, and post tools are part of the reading experience, and an unpublished draft must not look like a live post.

**Independent Test**: On the published build, the home page links to `/search/`, the head links to the feed, and `/posts/welcome/` does not exist. A draft preview of the welcome post shows a table of contents and `1 min`.

**Acceptance Scenarios**:

1. **Given** the published home page, **When** a visitor activates the Search button, **Then** they arrive at `/search/`, and that button is not one of the four menu labels.
2. **Given** the published home page, **When** a feed reader follows the head's alternate link, **Then** it loads `/index.xml`, which does not contain the welcome post.
3. **Given** a draft preview, **When** a visitor opens `/posts/welcome/`, **Then** the post title is `Welcome`, a table of contents lists `First section` and `Second section`, and the post meta shows `1 min`. The same path is absent from the published site.

---

### Edge Cases

- The welcome post is a draft. A published build does not list it, link it from Posts, include it in search, or include it in the feed.
- A broken link to another page on the site fails the pull-request check. A broken link to an external site does not fail the job; the workflow emits a `::warning::` annotation and the job stays successful.
- LinkedIn answers many automated clients with HTTP 999. That URL is excluded from lychee so the warning channel stays usable for other external failures.
- Cloning the repository without the theme submodule does not produce a successful strict build.
- The home page and every published section render in English. No second language is offered.
- No published page shows an email address or a mailto link.
- Placeholder pages stay visibly marked as placeholders. This feature does not add final project write-ups.
- A secret that is committed and then deleted in a later commit on the same branch still fails gitleaks, because the pull-request scan covers the commit range. The failure proof uses a throwaway branch that is never merged.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The site MUST be a portfolio and blog whose audience is ML Engineering and MLOps recruiters and hiring managers in fintech.
- **FR-002**: The site language MUST be English on every published page, including navigation labels. The `html` element in `public/index.html` MUST have its `lang` attribute equal to `en`.
- **FR-003**: The home page MUST show the exact name `Jorge D. Laborda Sicilia`, the exact headline `Placeholder headline`, and only these social links: GitHub at https://github.com/JLaborda and LinkedIn at https://www.linkedin.com/in/jorge-daniel-laborda-sicilia. It MUST NOT show an email address. The headline is placeholder copy, not final wording.
- **FR-004**: The main menu (`ul#menu`) MUST contain exactly four links, labeled Projects, Now, About, and Posts, with destinations `/projects/`, `/now/`, `/about/`, and `/posts/`. It MUST NOT contain a Search label or a link to `/search/`.
- **FR-005**: Projects MUST list one entry, SmartWealthAI. That entry MUST be clearly marked as a placeholder and MUST link to https://github.com/JLaborda/SmartWealthAI. It is published at `/projects/smartwealthai/`.
- **FR-006**: Now MUST be published at `/now/`. Its copy MUST contain the word `placeholder` and MUST describe, as placeholder text, what Jorge is learning and doing now.
- **FR-007**: About MUST be published at `/about/`. Its copy MUST contain the word `placeholder`.
- **FR-008**: Posts MUST be published at `/posts/` with no published posts. The only post MUST be a draft whose title is exactly `Welcome`, whose slug is exactly `welcome`, and whose source is `content/posts/welcome.md` with `draft: true`. Its body MUST be shorter than 200 words and MUST contain exactly two level-2 headings, `First section` and `Second section`. The published build MUST NOT contain `public/posts/welcome/index.html`.
- **FR-009**: Search MUST be reachable from the home page by a PaperMod profile button, outside `ul#menu`, whose `class` attribute equals `button` and whose `href` attribute equals `/search/`. The published search page MUST exist at `public/search/index.html`, and `public/index.json` MUST exist. The draft welcome post MUST NOT appear in that JSON (no entry whose `title` is `Welcome` or whose `permalink` contains `/posts/welcome`).
- **FR-010**: The feed MUST be `public/index.xml`. The home page (`public/index.html`) MUST advertise it with a `link` element in the document head whose `rel` attribute is `alternate`, whose `type` attribute is `application/rss+xml`, and whose `href` attribute is `/index.xml`. Other published HTML pages are not required to repeat that site-feed link. The feed MUST NOT be a menu item and MUST NOT be a social icon. `public/index.xml` MUST NOT contain `<title>Welcome</title>` or `/posts/welcome/`.
- **FR-011**: Visitors MUST be able to switch between a light and a dark appearance. `public/index.html` MUST contain an element whose `id` attribute equals `theme-toggle`.
- **FR-012**: The draft preview of `/posts/welcome/` MUST show a table of contents and a reading time. That page MUST contain a `div` whose `class` attribute equals `toc`, the text `Table of Contents`, `href` attributes equal to `#first-section` and `#second-section`, and, inside a `div` whose `class` attribute equals `post-meta`, the exact text `1 min` (PaperMod's English `read_time` string for a post under 200 words). The verification build writes that page to `/tmp/public-drafts/posts/welcome/index.html` and MUST leave `public/posts/welcome/index.html` absent.
- **FR-013**: The site MUST be built with Hugo extended. The version MUST be a single pinned extended release, recorded in one workflow variable named `HUGO_VERSION` and repeated in the README. The PaperMod theme MUST be a git submodule at `themes/PaperMod` pinned to a release tag, not to a branch. The theme files MUST NOT be edited. This feature MUST NOT add project CSS or JavaScript.
- **FR-014**: Site configuration MUST live in `hugo.yaml`, not in `config.toml`. It MUST set the title, a provisional base URL, English as the default language, the author `Jorge D. Laborda Sicilia`, and the two social links. It MUST NOT set an email.
- **FR-015**: The README MUST state what the site is, the pinned Hugo extended version, `git clone --recurse-submodules`, and `hugo server -D`.
- **FR-016**: Pull requests to `develop` and pull requests to `main` MUST run a job named `hugo` that checks out submodules, installs the pinned Hugo extended version, and runs `hugo --gc --minify --panicOnWarning --baseURL /`. The job MUST fail when the build fails and MUST fail when Hugo emits only a warning. The warning proof is a throwaway branch, never merged, that adds `layouts/shortcodes/warn-test.html` containing `{{ warnf "spec-001 warning probe" }}` and calls `{{< warn-test >}}` from a published page. On that branch, `hugo --gc --minify --baseURL /` exits 0 and `hugo --gc --minify --panicOnWarning --baseURL /` exits non-zero.
- **FR-017**: Pull requests to `develop` and pull requests to `main` MUST run a job named `lychee`. The internal check MUST be `lychee --offline --root-dir public public` and MUST exit non-zero when a published page contains `[x](/does-not-exist/)`. External URLs MUST be checked in a separate step with `continue-on-error: true`, excluding `https://www.linkedin.com/in/jorge-daniel-laborda-sicilia` (LinkedIn answers automated clients with HTTP 999). For any other broken external URL the step log MUST contain that URL and the workflow MUST emit a GitHub annotation `::warning::<url>`. That external step MUST NOT fail the job: the job conclusion stays `success`.
- **FR-018**: Pull requests to `develop` and pull requests to `main` MUST run a job named `gitleaks`. The job's checkout MUST set `fetch-depth: 0`. The job MUST run `gitleaks detect --redact --log-opts="${{ github.event.pull_request.base.sha }}..${{ github.event.pull_request.head.sha }}"`, scanning commits reachable from the pull-request head and not from the base. The job MUST exit 0 on this feature. A secret added in one commit and removed in a later commit on the same branch MUST still fail this scan. The failure proof MUST use a throwaway local branch that is never pushed and never merged, so the synthetic value never reaches `develop`. The value MUST be generated at test time, MUST NOT be `AKIAIOSFODNN7EXAMPLE`, and MUST NOT be written into this specification.
- **FR-019**: Generated build output MUST NOT be committed. `public/`, `resources/_gen/`, and `.hugo_build.lock` MUST be ignored by git.
- **FR-020**: Final project write-ups, the final About and Now wording, an email address, analytics, comments, a contact form, more than one language, AWS deployment, Terraform, a domain, and DNS MUST NOT be part of this feature.
- **FR-021**: Once the workflow file exists on `develop`, `develop` and `main` MUST have branch protection whose required status checks include the job names `hugo`, `lychee`, and `gitleaks`. Applying that protection is a repository-admin action. Only Jorge can apply it. A contributor who is not an admin MUST NOT be expected to turn it on.

### Key Entities

- **Home page**: The name `Jorge D. Laborda Sicilia`, the headline `Placeholder headline`, the two social links, and a Search button to `/search/`.
- **Project entry**: Title SmartWealthAI, a placeholder notice, and the link https://github.com/JLaborda/SmartWealthAI.
- **Now page**: Placeholder copy for current learning and work, published at `/now/`.
- **About page**: Placeholder copy, published at `/about/`.
- **Welcome post**: Draft title `Welcome`, slug `welcome`, two sections named `First section` and `Second section`. It is not part of the published site.
- **Menu**: The four labels Projects, Now, About, and Posts inside `ul#menu`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A visitor can open the home page and reach Projects, Now, About, and Posts from the menu, and can reach search from the home-page Search button.
- **SC-002**: On the published site, the visitor sees exactly two social destinations (GitHub and LinkedIn) and zero email addresses.
- **SC-003**: On the published site, the visitor sees exactly one project, and that project is visibly a placeholder.
- **SC-004**: On the published site, `/posts/welcome/` is absent. The draft preview shows the title `Welcome`, two table-of-contents entries, and `1 min`.
- **SC-005**: A reviewer can run every command in Verification and compare it to the expected result named there. No value is left for the reviewer to choose.

## Verification

Run these from the repository root after `git clone --recurse-submodules`. The published build is:

```bash
hugo --gc --minify --panicOnWarning --baseURL /
```

Expected: exit code 0, and `test -f public/index.html` succeeds.

Attribute checks use one extended-regular-expression form throughout. It matches the quoted attributes named in the requirements (`lang="en"`) and the unquoted attributes Hugo writes with `--minify` (`lang=en`). There is no second, unminified build. Element extracts use the element's own tags, not a line range, because `--minify` can place the head and the body on the same line.

The draft build writes to `/tmp/public-drafts` and does not modify `public/`.

- **FR-002**: `grep -E '<html[^>]* lang="?en"?' public/index.html`. Expected: exit 0.
- **FR-003**:

  ```bash
  grep -F 'Jorge D. Laborda Sicilia' public/index.html
  grep -F 'Placeholder headline' public/index.html
  grep -F 'https://github.com/JLaborda' public/index.html
  grep -F 'https://www.linkedin.com/in/jorge-daniel-laborda-sicilia' public/index.html
  if grep -R -F 'mailto:' public --include='*.html'; then exit 1; fi
  ```

  Expected: the four `grep -F` commands exit 0, and the `mailto:` guard exits 0. The guard searches every published HTML file.
- **FR-004**:

  ```bash
  menu=$(python3 -c '
  import re, pathlib, sys
  html = pathlib.Path("public/index.html").read_text()
  m = re.search(r"<ul id=\"?menu\"?>.*?</ul>", html, re.S)
  if not m:
      sys.exit(1)
  sys.stdout.write(m.group(0))
  ')
  test "$(printf '%s\n' "$menu" | grep -oE 'href="?[^"[:space:]]+"?' | wc -l | tr -d ' ')" = 4
  printf '%s\n' "$menu" | grep -E 'href="?/projects/"?([[:space:]>]|$)'
  printf '%s\n' "$menu" | grep -E 'href="?/now/"?([[:space:]>]|$)'
  printf '%s\n' "$menu" | grep -E 'href="?/about/"?([[:space:]>]|$)'
  printf '%s\n' "$menu" | grep -E 'href="?/posts/"?([[:space:]>]|$)'
  printf '%s\n' "$menu" | grep -F 'Projects'
  printf '%s\n' "$menu" | grep -F 'Now'
  printf '%s\n' "$menu" | grep -F 'About'
  printf '%s\n' "$menu" | grep -F 'Posts'
  if printf '%s\n' "$menu" | grep -F '/search/'; then exit 1; fi
  ```

  Expected: exit 0. The count equals 4. Each label and path grep exits 0. The `/search/` guard does not find a match.
- **FR-005**:

  ```bash
  test -f public/projects/index.html
  test -f public/projects/smartwealthai/index.html
  grep -F 'placeholder' public/projects/smartwealthai/index.html
  grep -F 'https://github.com/JLaborda/SmartWealthAI' public/projects/smartwealthai/index.html
  ```

  Expected: all four commands exit 0.
- **FR-006, FR-007, FR-008**:

  ```bash
  test -f public/now/index.html
  test -f public/about/index.html
  test -f public/posts/index.html
  grep -F 'placeholder' public/now/index.html
  grep -F 'placeholder' public/about/index.html
  test ! -e public/posts/welcome/index.html
  rm -rf /tmp/public-drafts
  hugo --gc --minify --panicOnWarning --baseURL / -D --destination /tmp/public-drafts
  test -f /tmp/public-drafts/posts/welcome/index.html
  test ! -e public/posts/welcome/index.html
  ```

  Expected: every command exits 0. `public/posts/welcome/index.html` is absent before the draft build and still absent after it.
- **FR-009**:

  ```bash
  test -f public/search/index.html
  test -f public/index.json
  grep -E 'class="?button"? href="?/search/"?' public/index.html
  jq -e '[.[] | select(.title == "Welcome" or ((.permalink // "") | contains("/posts/welcome")))] | length == 0' public/index.json
  ```

  Expected: all commands exit 0. `jq` prints `true`.
- **FR-010**:

  ```bash
  test -f public/index.xml
  grep -E '<link rel="?alternate"? type="?application/rss\+xml"? href="?/index.xml"?' public/index.html
  if grep -F '<title>Welcome</title>' public/index.xml; then exit 1; fi
  if grep -F '/posts/welcome/' public/index.xml; then exit 1; fi
  menu=$(python3 -c '
  import re, pathlib, sys
  html = pathlib.Path("public/index.html").read_text()
  m = re.search(r"<ul id=\"?menu\"?>.*?</ul>", html, re.S)
  if not m:
      sys.exit(1)
  sys.stdout.write(m.group(0))
  ')
  if printf '%s\n' "$menu" | grep -F 'index.xml'; then exit 1; fi
  icons=$(python3 -c '
  import re, pathlib, sys
  html = pathlib.Path("public/index.html").read_text()
  m = re.search(r"<div class=\"?social-icons\"?[^>]*>.*?</div>", html, re.S)
  if not m:
      sys.exit(1)
  sys.stdout.write(m.group(0))
  ')
  if printf '%s\n' "$icons" | grep -F 'index.xml'; then exit 1; fi
  ```

  Expected: exit 0. The alternate-link grep matches the home page. The guards find no welcome title, no welcome path, and no feed link inside the menu element or the social-icons element.
- **FR-011**: `grep -E 'id="?theme-toggle"?' public/index.html`. Expected: exit 0.
- **FR-012**: After the draft build from FR-008. The file under test is `/tmp/public-drafts/posts/welcome/index.html`.

  ```bash
  draft=/tmp/public-drafts/posts/welcome/index.html
  grep -E '<div class="?toc"?>' "$draft"
  grep -F 'Table of Contents' "$draft"
  grep -E 'href="?#first-section"?' "$draft"
  grep -E 'href="?#second-section"?' "$draft"
  python3 -c '
  import re, pathlib, sys
  html = pathlib.Path("/tmp/public-drafts/posts/welcome/index.html").read_text()
  m = re.search(r"<div class=\"?post-meta\"?[^>]*>.*?</div>", html, re.S)
  if not m:
      sys.exit(1)
  text = m.group(0)
  if "1 min" not in text:
      sys.exit(1)
  print(text)
  '
  ```

  Expected: all five commands exit 0. The last command prints the post-meta element, and that element contains `1 min`.
- **FR-013**:

  ```bash
  git -C themes/PaperMod describe --tags --exact-match HEAD
  git ls-tree HEAD themes/PaperMod | grep -E '^[0-9]+ commit '
  test "$(grep -R -E '^[[:space:]]*HUGO_VERSION:' .github/workflows | wc -l | tr -d ' ')" = 1
  version=$(grep -R -E '^[[:space:]]*HUGO_VERSION:' .github/workflows | head -1 | sed -E 's/.*HUGO_VERSION:[[:space:]]*"?([^"[:space:]]+)"?.*/\1/')
  grep -F "$version" README.md
  ```

  Expected: `describe` prints one tag and exits 0. `ls-tree` prints one `commit` gitlink. The workflow count equals 1. `HUGO_VERSION` is matched with leading whitespace so an indented `env:` entry counts. The README grep exits 0.
- **FR-014**:

  ```bash
  test -f hugo.yaml
  test ! -e config.toml
  grep -E '^language: *en$|^defaultContentLanguage: *en$' hugo.yaml
  grep -F 'Jorge D. Laborda Sicilia' hugo.yaml
  if grep -E -i 'mailto:|e-?mail:' hugo.yaml; then exit 1; fi
  ```

  Expected: exit 0.
- **FR-015**:

  ```bash
  version=$(grep -R -E '^[[:space:]]*HUGO_VERSION:' .github/workflows | head -1 | sed -E 's/.*HUGO_VERSION:[[:space:]]*"?([^"[:space:]]+)"?.*/\1/')
  grep -F "$version" README.md
  grep -F 'git clone --recurse-submodules' README.md
  grep -F 'hugo server -D' README.md
  ```

  Expected: all three greps exit 0.
- **FR-016**: `.github/workflows/ci.yml` contains the job name `hugo`, `actions/checkout` with `submodules: true` (or `recursive`), and the command `hugo --gc --minify --panicOnWarning --baseURL /`. `on.pull_request.branches` lists the exact names `develop` and `main`, so the same jobs report a status on a release pull request. A `main` entry that exists only under `push` does not satisfy this check. A name that only shares a prefix, such as `develop-old` or `main-x`, does not satisfy it either.

  ```bash
  grep -E '^[[:space:]]+hugo:' .github/workflows/ci.yml
  grep -E 'submodules:[[:space:]]*(true|recursive)' .github/workflows/ci.yml
  grep -F 'hugo --gc --minify --panicOnWarning --baseURL /' .github/workflows/ci.yml
  yq -e '[.on.pull_request.branches[] | select(. == "develop" or . == "main")] | unique | length == 2' .github/workflows/ci.yml
  ```

  Expected: each grep exits 0. `yq` prints `true` and exits 0.

  Warning proof, on a branch that is deleted afterward and not pushed:

  ```bash
  git switch -c spec-001-warnf
  mkdir -p layouts/shortcodes
  printf '%s\n' '{{ warnf "spec-001 warning probe" }}' > layouts/shortcodes/warn-test.html
  printf '\n{{< warn-test >}}\n' >> content/about.md
  git add layouts/shortcodes/warn-test.html content/about.md
  git commit -m "test: warning probe"
  set +e
  hugo --gc --minify --baseURL / --destination /tmp/public-warn
  first=$?
  hugo --gc --minify --panicOnWarning --baseURL / --destination /tmp/public-warn
  second=$?
  set -e
  git switch -
  git branch -D spec-001-warnf
  test "$first" -eq 0
  test "$second" -ne 0
  ```

  Expected: `first` is 0 and `second` is not 0. Both builds use `/tmp/public-warn`, so `public/` stays the published tree. The branch is deleted and is not pushed.
- **FR-017**: `.github/workflows/ci.yml` job `lychee` runs `lychee --offline --root-dir public public` and a second lychee invocation with `--exclude https://www.linkedin.com/in/jorge-daniel-laborda-sicilia` and `continue-on-error: true` that prints `::warning::` plus the URL for each external failure.

  ```bash
  grep -F 'lychee --offline --root-dir public public' .github/workflows/ci.yml
  grep -F 'continue-on-error: true' .github/workflows/ci.yml
  grep -F 'https://www.linkedin.com/in/jorge-daniel-laborda-sicilia' .github/workflows/ci.yml
  grep -F '::warning::' .github/workflows/ci.yml
  lychee --offline --root-dir public public
  ```

  Expected: the four greps exit 0 and the lychee command exits 0.

  Internal proof, on a branch that is deleted afterward and not pushed. The build uses a separate destination so `public/` is not replaced:

  ```bash
  git switch -c spec-001-lychee
  printf '\n[x](/does-not-exist/)\n' >> content/about.md
  git add content/about.md
  git commit -m "test: broken internal link"
  rm -rf /tmp/public-lychee
  hugo --gc --minify --panicOnWarning --baseURL / --destination /tmp/public-lychee
  set +e
  lychee --offline --root-dir /tmp/public-lychee /tmp/public-lychee
  lychee_status=$?
  set -e
  git switch -
  git branch -D spec-001-lychee
  test "$lychee_status" -ne 0
  ```

  Expected: `lychee_status` is not 0. External proof, on a branch that is not merged: add `[x](https://example.invalid/spec-001-missing)` to `content/about.md`. Expected: the job conclusion is `success`, the step log contains `https://example.invalid/spec-001-missing`, and the log contains the line `::warning::https://example.invalid/spec-001-missing`.
- **FR-018**: The gitleaks job checks out with `fetch-depth: 0` and runs `gitleaks detect --redact --log-opts="${{ github.event.pull_request.base.sha }}..${{ github.event.pull_request.head.sha }}"`. That range is the commits on the pull request and not on the base, both for a pull request into `develop` and for a release pull request into `main`. `fetch-depth: 0` makes both SHAs available. The local failure proof, with no push, still uses `origin/develop..HEAD` on a throwaway branch:

  ```bash
  grep -F 'fetch-depth: 0' .github/workflows/ci.yml
  grep -F 'gitleaks detect --redact --log-opts="${{ github.event.pull_request.base.sha }}..${{ github.event.pull_request.head.sha }}"' .github/workflows/ci.yml
  git switch -c spec-001-gitleaks
  python3 -c 'import random,string; alphabet=string.ascii_uppercase+"234567"; key="AKIA"+"".join(random.choice(alphabet) for _ in range(16));
  assert key != "AKIAIOSFODNN7EXAMPLE";
  open("leak-test.txt","w").write("aws_access_key_id = %s\n"%key)'
  git add leak-test.txt
  git commit -m "test: synthetic gitleaks fixture"
  status=0
  gitleaks detect --redact --no-banner --log-opts="origin/develop..HEAD" --report-format json --report-path /tmp/gitleaks-report.json || status=$?
  jq -r '.[0].RuleID' /tmp/gitleaks-report.json
  git switch -
  git branch -D spec-001-gitleaks
  test "$status" -ne 0
  test "$(jq -r '.[0].RuleID' /tmp/gitleaks-report.json)" = "aws-access-token"
  test ! -e leak-test.txt
  ```

  Expected: `status` is not 0 and the rule id is `aws-access-token`. The alphabet is `A-Z` and `234567`, which is what that rule matches after `AKIA` (`[A-Z2-7]{16}`). The value is not `AKIAIOSFODNN7EXAMPLE` and is not written into this specification. `leak-test.txt` is not left on `develop` or on the feature branch.
- **FR-019**:

  ```bash
  grep -F 'public/' .gitignore
  grep -F 'resources/_gen/' .gitignore
  grep -F '.hugo_build.lock' .gitignore
  git status --short | grep -F 'public/' && exit 1 || true
  ```

  Expected: the three greps exit 0. `git status --short` does not list `public/`.
- **FR-020**: `git diff --stat origin/develop...HEAD` does not list Terraform files, an AWS template, an analytics snippet, a contact form, a comments partial, a second language, or an email address. Expected: each spec pull request lists only `specs/001-minimal-hugo-site/spec.md`. The implementation pull requests for this feature are checked the same way against those forbidden additions.
- **FR-021**: After the workflow is on `develop`, and after Jorge has saved branch protection:

  ```bash
  for branch in develop main; do
    gh api "repos/JLaborda/web-portfolio/branches/${branch}/protection" \
      --jq '[.required_status_checks.contexts[], .required_status_checks.checks[].context] | unique | sort'
  done
  ```

  Expected: each command exits 0 and prints `["gitleaks","hugo","lychee"]`. An HTTP 404 means protection is missing. Only Jorge, as repository admin, can create or edit that protection; the check failing before he does so is expected and does not fall to another contributor.

## Out of Scope

- AWS deployment, Terraform, a domain, DNS, and HTTPS. Those belong to feature 002.
- An email address or mailto link. That is a later, separate change.
- Analytics, comments, and a contact form.
- More than one language.
- Final project write-ups and final About, Now, headline, and welcome-post wording. Jorge writes and approves that copy later. This feature uses the fixed placeholder strings above so the checks can run.

## Assumptions

- The home page uses PaperMod profile mode: `title` is `Jorge D. Laborda Sicilia`, `subtitle` is `Placeholder headline`, and `buttons` contains one entry named Search with url `/search/`. Social icons are only GitHub and LinkedIn.
- Now is published at `/now/` from either `content/now.md` or `content/now/`. About is `/about/`. Projects are `/projects/` and `/projects/smartwealthai/`.
- Menu labels inside `ul#menu` are Projects, Now, About, and Posts. Search is the home button, not a fifth menu label. The feed is head autodiscovery only.
- Light/dark switching and reading time stay in this feature because they were part of the source draft and no decision removed them.
- The exact Hugo extended release and the exact PaperMod tag are chosen in the plan. This specification requires only that each is a single pinned release, not a floating branch. PaperMod v8 reading-time text for English is `1 min` or `N min`, and the table-of-contents wrapper is `<div class="toc">`.
- The status line is `Status: Approved by Jorge — PR #6`. A later change to the scope of this specification still requires its own spec pull request. That pull request replaces the status line with `Status: Approved by Jorge — PR #N` for that pull request before the new scope is implemented.
- No product question is left open. Language, social links, the absence of email, the author name, the placeholder headline, and the welcome post title and slug are fixed above.

## Clarifications

### Session 2026-10-20

- No critical ambiguities found; no questions asked.
