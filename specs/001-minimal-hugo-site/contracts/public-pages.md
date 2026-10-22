# Contract: Published pages

The site exposes static URLs. Paths below are relative to the build `baseURL /` produced by `hugo --gc --minify --panicOnWarning --baseURL /`. The provisional value in `hugo.yaml` is `https://example.org/` and is overridden by that flag.

## Pages that must exist

| URL | Source | Required visible content |
|-----|--------|--------------------------|
| `/` | profile-mode home | Name `Jorge D. Laborda Sicilia`, headline `Placeholder headline`, both social URLs, Search button to `/search/`, four-item menu, feed autodiscovery to `/index.xml`, theme toggle |
| `/projects/` | `content/projects/_index.md` | Section index |
| `/projects/smartwealthai/` | `content/projects/smartwealthai.md` | Word `placeholder` and `https://github.com/JLaborda/SmartWealthAI` |
| `/now/` | `content/now.md` | Word `placeholder` |
| `/about/` | `content/about.md` | Word `placeholder` |
| `/posts/` | `content/posts/_index.md` | Section index with no published posts |
| `/search/` | `content/search.md` (`layout: search`) | Search page |
| `/index.xml` | Hugo RSS home output | Feed without the welcome post |
| `/index.json` | Hugo JSON home output | Search index without the welcome post |

## Pages that must not exist after the published build

| URL | Reason |
|-----|--------|
| `/posts/welcome/` | The only post is `draft: true` |

The draft contract is a second build: `hugo --gc --minify --panicOnWarning --baseURL / -D --destination /tmp/public-drafts`. That destination's `/posts/welcome/` page has title `Welcome`, a table of contents for `First section` and `Second section`, and the text `1 min` in the post meta.

## Head contract (home page)

The home document's `html` element has `lang` equal to `en`. Its head includes one alternate link with `type` `application/rss+xml` and `href` `/index.xml`. Other published HTML pages are not required to repeat that site-feed link.

## Social and menu contract

The social-icons element on the home page contains the GitHub URL and the LinkedIn URL and does not contain `index.xml` or `mailto:`. The menu element contains exactly four `href` values, in order: `/projects/`, `/now/`, `/about/`, `/posts/`.

## CI contract

`.github/workflows/ci.yml` exposes three job names, `hugo`, `lychee`, and `gitleaks`, on pull requests whose base branch is `develop` or `main`. The lychee job runs `lychee --offline --root-dir public public`. The gitleaks job checks out with `fetch-depth: 0` and runs `gitleaks detect --redact --log-opts="${{ github.event.pull_request.base.sha }}..${{ github.event.pull_request.head.sha }}"`. Version variables and install URLs are the ones in [research.md](../research.md).
