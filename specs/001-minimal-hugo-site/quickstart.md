# Quickstart: Minimal Hugo Site

Validate a checkout of feature 001. This is the run guide. Implementation steps are in [tasks.md](./tasks.md). Page fields are in [data-model.md](./data-model.md) and [contracts/public-pages.md](./contracts/public-pages.md).

## Prerequisites

- Git, with submodule support
- Hugo extended **0.145.0**
- lychee **0.24.2**
- gitleaks **8.30.1**
- `jq`, `python3`, and `yq` (the jq-style YAML wrapper)

Confirm the binaries:

```bash
hugo version    # v0.145.0 ... +extended
lychee --version
gitleaks version
```

## Setup

```bash
git clone --recurse-submodules <repo-url>
cd web-portfolio
git -C themes/PaperMod describe --tags --exact-match HEAD   # v8.0
```

Local preview, including the draft welcome post:

```bash
hugo server -D
```

## Published build

```bash
hugo --gc --minify --panicOnWarning --baseURL /
test -f public/index.html
test ! -e public/posts/welcome/index.html
```

Expected: the hugo command exits 0.

## Draft preview

```bash
rm -rf /tmp/public-drafts
hugo --gc --minify --panicOnWarning --baseURL / -D --destination /tmp/public-drafts
test -f /tmp/public-drafts/posts/welcome/index.html
test ! -e public/posts/welcome/index.html
```

Expected: both `test` commands exit 0. The draft page contains a table of contents and the text `1 min`.

## Feed, search, and menu

Run the FR-004, FR-009, FR-010, and FR-012 command blocks in the specification's Verification section. Attribute patterns accept both quoted and minified unquoted HTML. The home page is the only page required to advertise `/index.xml`.

## CI workflow shape

From a checkout that contains `.github/workflows/ci.yml`:

```bash
yq -e '.on.pull_request.branches | contains(["develop"]) and contains(["main"])' .github/workflows/ci.yml
grep -F 'hugo --gc --minify --panicOnWarning --baseURL /' .github/workflows/ci.yml
grep -F 'lychee --offline --root-dir public public' .github/workflows/ci.yml
grep -F 'fetch-depth: 0' .github/workflows/ci.yml
grep -F 'gitleaks detect --redact --log-opts="${{ github.event.pull_request.base.sha }}..${{ github.event.pull_request.head.sha }}"' .github/workflows/ci.yml
```

Expected: `yq` prints `true`. Each grep exits 0.

## Internal links

```bash
lychee --offline --root-dir public public
```

Expected: exit 0 on the published tree. A throwaway change that adds `[x](/does-not-exist/)` to `content/about.md`, built to a separate destination, makes lychee exit non-zero.

## What this feature does not start

Do not apply Terraform, create an S3 bucket, or attach a domain. Those are feature 002.
