# Data Model: Minimal Hugo Site

Hugo pages are the records. There is no database. Field text below is exact where the specification fixes it.

## Home page

- **Path**: `public/index.html` (from the site index in profile mode).
- **Fields**:
  - `title`: `Jorge D. Laborda Sicilia`
  - `subtitle`: `Placeholder headline`
  - `lang`: `en` on the `html` element
  - Social links, exactly two: `https://github.com/JLaborda`, `https://www.linkedin.com/in/jorge-daniel-laborda-sicilia`
  - Search button: `class` equals `button` and `href` equals `/search/`, outside `ul#menu`
  - Feed link in the document head: `rel` `alternate`, `type` `application/rss+xml`, `href` `/index.xml`
  - Theme control: an element whose `id` is `theme-toggle`
- **Validation**: No `mailto:` on this page or on any other published HTML page. The menu element contains exactly four links.
- **Relationships**: Menu targets the four section pages. The Search button targets the search page. The feed link targets the site feed.

## Menu

- **Container**: `ul` whose `id` is `menu`, on the home page.
- **Entries**, exactly these four. FR-004 does not constrain order. This plan fixes the order below so the menu is one list:
  - Projects → `/projects/`
  - Now → `/now/`
  - About → `/about/`
  - Posts → `/posts/`
- **Validation**: No `/search/` and no `index.xml` inside the element.

## Project entry

- **Path**: `/projects/smartwealthai/` from `content/projects/smartwealthai.md`. The section index is `/projects/`.
- **Fields**:
  - Title: SmartWealthAI
  - Body contains the word `placeholder`
  - Link: `https://github.com/JLaborda/SmartWealthAI`
- **State**: Published. It is the only project.

## Now page

- **Path**: `/now/` from `content/now.md`.
- **Fields**: English body containing the word `placeholder`, describing current learning and work as placeholder copy.
- **State**: Published.

## About page

- **Path**: `/about/` from `content/about.md`.
- **Fields**: English body containing the word `placeholder`.
- **State**: Published.

## Welcome post

- **Source**: `content/posts/welcome.md`
- **Fields**:
  - `title`: `Welcome`
  - `slug`: `welcome`
  - `draft`: `true`
  - `date`: `2026-10-20`
  - Exactly two level-2 headings: `First section`, `Second section`
  - Fewer than 200 words
  - `ShowToc`: true
- **State transition**: Draft only. The published build does not emit `public/posts/welcome/index.html`, does not list the post, and does not put it in search or in `public/index.xml`. A draft build with `-D --destination /tmp/public-drafts` emits `/tmp/public-drafts/posts/welcome/index.html` with a table of contents and the text `1 min` inside the post-meta element.
- **Relationships**: Belongs to the Posts section. Excluded from the published section index, `public/index.json`, and `public/index.xml`.

## Search index

- **Paths**: `public/search/index.html`, `public/index.json`.
- **Fields**: JSON array of objects with `title`, `content`, `permalink`, and `summary`.
- **Validation**: No object whose `title` is `Welcome` or whose `permalink` contains `/posts/welcome`.

## Site feed

- **Path**: `public/index.xml`.
- **Validation**: No `<title>Welcome</title>` and no `/posts/welcome/`. Not linked from the menu or from the social-icons element. Advertised from the home page head only.

## Site configuration

- **File**: `hugo.yaml` only. `config.toml` is absent.
- **Fields**: title `Jorge D. Laborda Sicilia`, provisional `baseURL` `https://example.org/`, `defaultContentLanguage: en`, author `Jorge D. Laborda Sicilia`, the two social links, profile mode, the four-item menu, home outputs HTML, RSS, and JSON.
- **Validation**: No email and no `mailto:`.
