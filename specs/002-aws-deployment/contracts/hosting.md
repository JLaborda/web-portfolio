# Contract: Hosting

What a visitor and a crawler can observe. Details and commands stay in [spec.md](../spec.md) Verification and in [data-model.md](../data-model.md).

## Hostnames

Each environment has one hostname matching `^[a-z0-9]+\.cloudfront.net$`. The two hostnames differ. HTTP on port 80 returns 301. HTTPS serves the Hugo build of the commit pushed to that environment's branch.

## Directory URLs

`/` and every generated directory URL returns the matching `index.html`. `/index.xml` and `/index.json` are not rewritten to an HTML object.

## Staging versus production

| Check | Staging | Production |
|-------|---------|------------|
| `/robots.txt` | Contains `Disallow: /` | Contains `Allow: /` and does not contain `Disallow: /` |
| `X-Robots-Tag` on `/` | `noindex` | Header absent |
| Authentication | None | None |

## Cache

`index.html` is `public, max-age=0, must-revalidate`. A hashed asset that is not html, xml, json, or `robots.txt` is `public, max-age=31536000, immutable`. Any other object is `public, max-age=3600`.

## Removal

After a successful deploy, an object whose page was removed from the build is gone from that environment's bucket. A failed Hugo build does not sync and does not invalidate.
