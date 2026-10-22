# Research: Minimal Hugo Site

Decisions for feature 001. The governing text is `spec.md` on `develop` after pull request #6, plus the Clarifications section this plan pull request appends. Versions below were read from the GitHub releases API on 2026-10-20 and then built on a throwaway site that is not in this repository.

## Hugo extended pin

- **Decision**: Pin Hugo extended **0.145.0** in the single workflow variable `HUGO_VERSION` and repeat `0.145.0` in `README.md`. Install `hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz`.
- **Rationale**: The latest stable release on 2026-10-20 is **0.168.0** (published 2026-10-13, `e27a6760c5547237f87d353aebe0580feadb20f4`). Re-run the same day: `hugo v0.168.0+extended --gc --minify --panicOnWarning --baseURL /` on PaperMod v8.0 exited 1. Hugo reported that `.Language.LanguageDirection` was deprecated in v0.158.0 and that `partial "partials/templates/_funcs/get-page-images"` was not found. PaperMod v8.0 predates the template layout introduced in Hugo 0.146.0, and there is no newer PaperMod release tag. The releases API lists **0.145.0** (published 2025-02-26, `666444f0a52132f9fec9f71cf25b441cc6a4f355`) as the newest extended release before 0.146.0. With the layouts overrides below, `hugo v0.145.0+extended --gc --minify --panicOnWarning --baseURL /` exited 0 (17 pages).
- **Alternatives considered**: Hugo 0.168.0 was rejected because the build fails. Hugo 0.146.0 and later were rejected for the same template break. Staying on 0.128.2 was rejected because 0.145.0 is a newer extended release that builds the same tag.

## PaperMod pin

- **Decision**: Git submodule `themes/PaperMod` at tag **v8.0**, commit `a2eb47bb4b805116dcd34c1605d39835121f8dbe` (published 2024-11-03). `git -C themes/PaperMod describe --tags --exact-match HEAD` prints `v8.0`.
- **Rationale**: The GitHub releases API lists v8.0 as the newest release. The tags API's first entry is v8.0. The constitution forbids pinning a branch, so PaperMod `master` is not eligible.
- **Alternatives considered**: PaperMod `master` would track current Hugo and is rejected because it is not a release tag.

## Layouts overrides required by the pin

- **Decision**: Do not edit files inside `themes/PaperMod`. Copy three partials into `layouts/partials/templates/` and keep the diff to the v8.0 source minimal:
  - `themes/PaperMod/layouts/partials/templates/schema_json.html`: inside the breadcrumb range, replace the index comma with `{{- if $scratch.Get "item" }}, {{ end }}` and `{{- $ignore := $scratch.Set "item" true }}`. Before the self item, use the same `item` flag instead of `ge (len $bc_list) 2`.
  - `themes/PaperMod/layouts/partials/templates/opengraph.html`: delete only the `else` branch that calls `site.Social.facebook_admin`.
  - `themes/PaperMod/layouts/partials/templates/twitter_cards.html`: delete only the `else` branch that calls `site.Social.twitter`.
- **Rationale**: Without the comma repair, Hugo's minifier aborts on `/projects/smartwealthai/` with `expected comma character`. With it, both JSON-LD scripts on that page parse. On 0.145.0, `site.Social` is a hard error (`logged 1 error(s)`), including when `--panicOnWarning` is omitted. Principle II allows overrides in `layouts/` and forbids editing the theme.
- **Alternatives considered**: `ignoreLogs` would hide a broken build. Copying the theme into the repository would violate the submodule rule.

## Favicons and lychee

- **Decision**: Commit the five files PaperMod links by default, under `static/`: `favicon.ico`, `favicon-16x16.png`, `favicon-32x32.png`, `apple-touch-icon.png`, `safari-pinned-tab.svg`. Empty files are enough for the offline link check.
- **Rationale**: `lychee 0.24.2 --offline --root-dir public public` on the 0.145.0 build with those files exited 0 (`208 Total`, `0 Errors`).
- **Alternatives considered**: Excluding the icon paths would hide a real internal link.

## Lychee pin

- **Decision**: Install **lychee 0.24.2** from `https://github.com/lycheeverse/lychee/releases/download/lychee-v0.24.2/lychee-x86_64-unknown-linux-gnu.tar.gz` and run `lychee --offline --root-dir public public` in a `run:` step. The lychee job first checks out submodules and runs `hugo --gc --minify --panicOnWarning --baseURL /`, because `public/` is gitignored and is not present after checkout. The external step is a second `run:` with `continue-on-error: true` that runs `lychee --exclude https://www.linkedin.com/in/jorge-daniel-laborda-sicilia --root-dir public public` and prints `::warning::` plus the URL. Without `--root-dir`, lychee 0.24.2 reports `Cannot resolve root-relative link` for site-absolute paths and would warn on internal links.
- **Rationale**: 0.24.2 (published 2026-05-01) is the latest release that is not a prerelease. The same day's releases list also contains `nightly`, which is a prerelease and is not pinned. `lychee-action` passes flags through `args:` and does not put the literal command in the workflow, so the FR-017 grep would fail. The CLI step contains that literal command.
- **Alternatives considered**: `lycheeverse/lychee-action` was rejected because its `args:` input is not the string the specification greps. `nightly` was rejected because it is a prerelease.

## Gitleaks pin

- **Decision**: Install **gitleaks 8.30.1** from `https://github.com/gitleaks/gitleaks/releases/download/v8.30.1/gitleaks_8.30.1_linux_x64.tar.gz`. The job checks out with `fetch-depth: 0` and runs `gitleaks detect --redact --log-opts="${{ github.event.pull_request.base.sha }}..${{ github.event.pull_request.head.sha }}"`.
- **Rationale**: 8.30.1 (published 2026-03-21) is the latest release. `gitleaks-action` computes its own scan range and does not run a custom command, so the FR-018 grep would not be what executes. The SHA range covers a pull request into `develop` and a `develop` → `main` release pull request. The local failure proof still uses `origin/develop..HEAD` on a throwaway branch that is never pushed. The generator alphabet is `string.ascii_uppercase + "234567"`. That alphabet matches rule id `aws-access-token`. `AKIAIOSFODNN7EXAMPLE` does not.
- **Alternatives considered**: `gitleaks/gitleaks-action` was rejected because it does not run the literal command. `origin/develop..HEAD` as the only CI range was rejected because a release pull request's base is `main`.

## CI trigger

- **Decision**: `on.pull_request.branches` lists `develop` and `main`. The check is `yq -e '[.on.pull_request.branches[] | select(. == "develop" or . == "main")] | unique | length == 2' .github/workflows/ci.yml`.
- **Rationale**: On the throwaway workflow with those two branches, mikefarah `yq` v4.54.1 printed `true` and exited 0. A `main` entry that exists only under `push`, and the names `develop-old` and `main-x`, do not satisfy the filter.
- **Alternatives considered**: `contains(["develop"])` was rejected. On the jq-style `yq` it matches prefixes, and on mikefarah `yq` v4 it errors.

## Feed scope and draft destination

- **Decision**: `public/index.xml` is advertised on the home page only. The draft preview is `hugo --gc --minify --panicOnWarning --baseURL / -D --destination /tmp/public-drafts`.
- **Rationale**: On the 0.145.0 build, the home page matches the alternate-link pattern and `/about/`, `/now/`, and `/search/` do not advertise `/index.xml`. The draft build wrote `/tmp/public-drafts/posts/welcome/index.html` with `div class=toc`, `Table of Contents`, both section anchors, and `1 min` inside `div class=post-meta`, and left `public/posts/welcome/index.html` absent.
- **Alternatives considered**: Requiring `/index.xml` on every page would need a behavior PaperMod does not ship. Building drafts into `public/` makes the later feed and search checks see the draft.

## Provisional base URL

- **Decision**: `hugo.yaml` sets `baseURL: https://example.org/`. Every CI and verification build still passes `--baseURL /`.
- **Rationale**: FR-014 requires a provisional base URL. `example.org` is a documentation name, not this site's domain. Feature 002 replaces it when the domain is chosen.
- **Alternatives considered**: Omitting `baseURL` would fail FR-014. Using a real domain would decide DNS inside this feature.

## Checkout pin

- **Decision**: `actions/checkout` **v7.0.1**, commit `3d3c42e5aac5ba805825da76410c181273ba90b1` (published 2026-07-20). The `hugo` and `lychee` jobs set `submodules: recursive`. The `gitleaks` job sets `fetch-depth: 0`.
- **Rationale**: v7.0.1 is the latest checkout release. The submodule flag is required to build the theme. Full history is required for the SHA range.
- **Alternatives considered**: A floating major tag was rejected.

## Cost

- **Decision**: Feature 001 adds no hosted service. Expected monthly cost is **0 USD**.
- **Rationale**: The deliverable is static files and a GitHub Actions workflow. AWS cost belongs to feature 002.
- **Alternatives considered**: None for this feature.
