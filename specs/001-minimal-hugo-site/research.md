# Research: Minimal Hugo Site

Decisions for feature 001. The Verification section added in pull request #4 is authoritative for how each requirement is checked, including while that pull request is unmerged. FR-010 and FR-016 through FR-018 are applied here in the amended form QA requested on that review: the site feed is checked on the home page, and CI runs for pull requests to `develop` and to `main`.

## Hugo extended pin

- **Decision**: Pin Hugo extended **0.145.0** in the single workflow variable `HUGO_VERSION` and repeat `0.145.0` in `README.md`. Install the release asset `hugo_extended_0.145.0_linux-amd64.tar.gz`.
- **Rationale**: The latest stable release today is **0.168.0** (published 2026-10-13, `e27a6760c5547237f87d353aebe0580feadb20f4`). It does not build PaperMod v8.0. A local build with `hugo --gc --minify --panicOnWarning --baseURL /` exited 1. Hugo reported that `.Language.LanguageDirection` was deprecated in v0.158.0 and that `partial "partials/templates/_funcs/get-page-images"` was not found. The same command without `--panicOnWarning` also exited 1. PaperMod v8.0 predates the template layout introduced in Hugo 0.146.0, and there is no newer PaperMod release tag that contains that migration. 0.145.0 is the newest extended release before 0.146.0. With the layouts overrides below, `hugo v0.145.0+extended --gc --minify --panicOnWarning --baseURL /` exited 0 (17 pages).
- **Alternatives considered**: Hugo 0.168.0 was rejected because the build fails. Staying on 0.128.2 was rejected because a newer extended release builds the same tag. Hugo 0.134.3 and 0.135.0 were measured as well: under `--panicOnWarning` they error on `site.Social.facebook_admin` inside the theme, so they are not a simpler pin.

## PaperMod pin

- **Decision**: Git submodule `themes/PaperMod` at tag **v8.0**, commit `a2eb47bb4b805116dcd34c1605d39835121f8dbe` (published 2024-11-03). `git -C themes/PaperMod describe --tags --exact-match HEAD` prints `v8.0`.
- **Rationale**: The GitHub releases API lists v8.0 as the newest release. The tags API's first entry is v8.0. The constitution forbids pinning a branch, so PaperMod `master` (which has the Hugo 0.146 template migration) is not eligible.
- **Alternatives considered**: PaperMod `master` at `87de3fb` would track current Hugo and is rejected because it is not a release tag.

## Layouts overrides required by the pin

- **Decision**: Do not edit files inside `themes/PaperMod`. Add three project partials under `layouts/partials/templates/`:
  - `schema_json.html` repairs the BreadcrumbList comma. Without it, Hugo's minifier aborts on `/projects/smartwealthai/` with `expected comma character`. With the repair, both JSON-LD scripts on that page parse, and `--minify --panicOnWarning` exits 0.
  - `opengraph.html` and `twitter_cards.html` read `site.Params.social` only. They do not evaluate `site.Social`. On 0.145.0 that call is a hard error (`logged 1 error(s)`), including when `--panicOnWarning` is omitted.
- **Rationale**: Principle II allows overrides in `layouts/` and forbids editing the theme. The overrides are the minimum that makes the pinned pair satisfy the strict build.
- **Alternatives considered**: Ignoring the minifier error, or setting `ignoreLogs`, would fail `--panicOnWarning` or hide a broken build. Copying the theme into the repository would violate the submodule rule.

## Favicons and lychee

- **Decision**: Commit the five files PaperMod links by default, under `static/`: `favicon.ico`, `favicon-16x16.png`, `favicon-32x32.png`, `apple-touch-icon.png`, `safari-pinned-tab.svg`. Empty files are enough for the offline link check.
- **Rationale**: `lychee 0.24.2 --offline --root-dir public public` on a build that has those files exits 0 (`208 Total`, `0 Errors`). The same theme without the files reports the five icons as broken internal links. That would fail FR-017 on a correct site.
- **Alternatives considered**: Excluding the icon paths in lychee would hide a real internal link. Generating branded art is out of scope; the files only need to exist.

## Lychee pin

- **Decision**: Tool **lychee 0.24.2** (release `lychee-v0.24.2`, published 2026-05-01). Action **lycheeverse/lychee-action v2.9.0**, commit `e7477775783ea5526144ba13e8db5eec57747ce8` (published 2026-07-09), input `lycheeVersion: v0.24.2`.
- **Rationale**: Both are the latest releases returned by the GitHub releases API. v2.9.0's default lychee version is v0.24.2. The workflow must still contain the literal command `lychee --offline --root-dir public public`, because that is the verification grep. The external step uses `continue-on-error: true`, excludes `https://www.linkedin.com/in/jorge-daniel-laborda-sicilia`, and prints `::warning::` plus the URL.
- **Alternatives considered**: A floating `lychee-action@v2` tag was rejected because the pin would move.

## Gitleaks pin

- **Decision**: Tool **gitleaks 8.30.1** (release `v8.30.1`, published 2026-03-21). Action **gitleaks/gitleaks-action v3.0.0**, commit `e0c47f4f8be36e29cdc102c57e68cb5cbf0e8d1e` (published 2026-05-30), with `GITLEAKS_VERSION` `8.30.1`. Checkout for this job uses `fetch-depth: 0`. The scan command is `gitleaks detect --redact --log-opts="${{ github.event.pull_request.base.sha }}..${{ github.event.pull_request.head.sha }}"`.
- **Rationale**: 8.30.1 and action v3.0.0 are the latest releases. v3 moves the action to the Node 24 runtime. The SHA range is the CI form of "commits on the pull request and not on the base". It works for a pull request into `develop` and for a `develop` → `main` release pull request. `fetch-depth: 0` makes both SHAs available. The local failure proof still uses `origin/develop..HEAD` on a throwaway branch. The generator alphabet is `string.ascii_uppercase + "234567"`. Twenty keys generated that way, scanned with gitleaks 8.30.1 `--no-git`, all exited 1 with rule id `aws-access-token`. `AKIA` followed by sixteen `0` characters exited 0. `AKIAIOSFODNN7EXAMPLE` exited 0. A git-range scan of one throwaway commit exited 1 with the same rule id, and the fixture file was not left on the base branch.
- **Alternatives considered**: `origin/develop..HEAD` as the only CI range was rejected. A default `pull_request` checkout does not have that ref, and the same string does not describe a release pull request whose base is `main`. `gitleaks-action` v2 was rejected because it is the Node 20 action.

## CI trigger

- **Decision**: `on.pull_request.branches` lists `develop` and `main`. The check is `yq -e '.on.pull_request.branches | contains(["develop"]) and contains(["main"])' .github/workflows/ci.yml`, which prints `true` and exits 0. A workflow that lists `main` only under `push` prints `false` and exits 1. This was measured with the system `yq` (jq filter over YAML).
- **Rationale**: FR-021 requires the `hugo`, `lychee`, and `gitleaks` contexts on `main` as well as `develop`. A release pull request never reports those contexts if the workflow does not run on pull requests to `main`. A line-oriented grep for `- main` matches a push branch list and is not the check.
- **Alternatives considered**: Running the jobs only on `develop` was rejected because required checks on `main` would wait forever.

## Feed scope

- **Decision**: The site feed `public/index.xml` is advertised on the home page only. Section pages may advertise their own section feeds. The verification grep for `rel=alternate`, `type=application/rss+xml`, and `href=/index.xml` runs against `public/index.html`.
- **Rationale**: User Story 3 scenario 2 already follows the head link from the home page. On a real PaperMod v8.0 build, `/about/`, `/now/`, and `/search/` have no RSS alternate link, and `/posts/` advertises `/posts/index.xml`. Requiring `/index.xml` on every HTML page would need a theme override and would change the check. That is not this feature's scope.
- **Alternatives considered**: A `layouts/` override that injects the home feed into every page was rejected. It is a behavior PaperMod does not ship, and the approved story does not ask for it.

## Draft build destination

- **Decision**: Published pages are built into `public/`. The draft preview is `hugo --gc --minify --panicOnWarning --baseURL / -D --destination /tmp/public-drafts`. After that command, `public/posts/welcome/index.html` is still absent and `/tmp/public-drafts/posts/welcome/index.html` exists.
- **Rationale**: `hugo -D` writes into the default destination and does not clean it, so a later search and feed check would see the draft. A separate destination was measured: the published tree stayed without the welcome page, and the draft page contained `div class=toc`, `Table of Contents`, `href=#first-section`, `href=#second-section`, and `1 min` inside `div class=post-meta`.
- **Alternatives considered**: Building drafts into `public/` and deleting the welcome file afterwards was rejected because a missed deletion fails FR-009.

## Checkout pin

- **Decision**: `actions/checkout` **v7.0.1**, commit `3d3c42e5aac5ba805825da76410c181273ba90b1` (published 2026-07-20). The `hugo` and `lychee` jobs set `submodules: recursive`. The `gitleaks` job sets `fetch-depth: 0`.
- **Rationale**: v7.0.1 is the latest checkout release. The submodule flag is required to build the theme. Full history is required for the SHA range.
- **Alternatives considered**: `actions/checkout@v4` was rejected as an unpinned older major.

## Cost

- **Decision**: Feature 001 adds no hosted service. Expected monthly cost is **0 USD**.
- **Rationale**: The deliverable is static files and a GitHub Actions workflow on the free tier for a public repository. AWS cost belongs to feature 002 and stays inside the constitution's about-1-USD budget there.
- **Alternatives considered**: None for this feature.
