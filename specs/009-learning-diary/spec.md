# Feature Specification: Learning Diary Posts

**Feature Branch**: `009-learning-diary`

**Created**: 2026-11-10

**Status**: Draft

**Input**: User description: "Keep Posts in the main menu. Turn Posts into a weekly English learning diary about what Jorge is doing and learning (current work), not a placeholder blog. Remove or never publish the existing draft welcome post. Ship one real first diary entry in this feature wave. Establish a light convention for ongoing weekly posts so future entries stay consistent. English only. No visual redesign. Out of scope: automating posts from other repos, /log TIL product, non-English posts, hiring case study content (feature 008), second project case study (010), email, CI chores."

## Context

Feature 001 left Posts in the menu with a draft `welcome` post that never publishes. The public `/posts/` list is empty, which reads as an abandoned blog. The 2026-11-10 `/grill-me` session decided Posts stay and become a weekly learning diary in English, starting with a real first post in this wave, in parallel with hiring content feature 008.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Hiring manager reads a real diary entry (Priority: P1)

A hiring manager opens Posts, sees at least one published English entry about what Jorge is currently doing or learning, and can open that post. They never see the old placeholder welcome draft as a published post.

**Why this priority**: An empty or placeholder Posts section weakens the “active builder” signal Next to Now.

**Independent Test**: Build the site. `/posts/` lists at least one non-draft post. That post’s page has real English body content. The former `welcome` draft is deleted or remains draft and does not appear in the list.

**Acceptance Scenarios**:

1. **Given** the published site, **When** a visitor opens `/posts/`, **Then** they see at least one published post with a clear title and date.
2. **Given** that list, **When** they open the first diary entry, **Then** they read English prose about current work or learning (not lorem/placeholder “First section” stub text).
3. **Given** `/posts/`, **When** looking for a welcome placeholder post, **Then** no published welcome/placeholder entry appears.

---

### User Story 2 - Jorge keeps a weekly cadence without redesigning the theme (Priority: P2)

Jorge (or an agent drafting for his approval) can add a new weekly diary post by creating a normal post Markdown file following a light convention (language, intent, and front-matter expectations documented in the feature). PaperMod post layout stays; no new visual system.

**Why this priority**: Cadence only works if the cost of each entry is low and conventions are clear.

**Independent Test**: Feature docs state the convention (English; learning/doing diary; required front matter fields the project already uses for posts). Adding one additional Markdown post file publishes another entry without layout changes.

**Acceptance Scenarios**:

1. **Given** the convention recorded in this feature’s docs/tasks, **When** Jorge adds a new post file that follows it, **Then** `/posts/` lists the new entry after build/deploy.
2. **Given** this feature, **When** complete, **Then** no PaperMod visual redesign ships as part of it.
3. **Given** Posts, **When** the main menu is checked, **Then** Posts remains a menu item pointing at `/posts/`.

---

### User Story 3 - Recruiter trusts Now and Posts as the same active story (Priority: P3)

A recruiter who reads `/now/` and then Posts finds the diary consistent with “what I’m doing/learning now,” not an unrelated blog brand. The first entry may reference current projects or learning items without requiring the full case study pages from other features.

**Why this priority**: Consistency across Now and Posts reinforces the hiring narrative.

**Independent Test**: First published diary entry topic is framed as current work/learning; it does not depend on feature 008 or 010 being merged to build, though content may mention those projects.

**Acceptance Scenarios**:

1. **Given** the first diary post, **When** a recruiter skims it, **Then** the subject is current building or learning, not a generic site-welcome stub.
2. **Given** feature 008 is not merged, **When** this feature’s posts build, **Then** the site still builds and `/posts/` works independently.

### Edge Cases

- Draft posts MUST NOT appear in the public list (existing Hugo draft behavior).
- If Jorge delays the first real post body, the feature MUST NOT republish the old welcome placeholder as a substitute.
- Empty `/posts/` after removing welcome without adding a real post fails this feature’s acceptance—at least one real published entry is required.
- Search may index posts once content exists; this feature does not require changing the home Search button.
- Non-weekly catch-up posts are allowed; the convention is weekly as the target cadence, not a hard automated enforcer in v1.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The site MUST keep a Posts item in the main menu linking to `/posts/`. **Acceptance**: AC-M1.

- **FR-002**: The draft welcome placeholder post MUST be removed or kept non-published so it never appears in the public Posts list. **Acceptance**: AC-W1.

- **FR-003**: This feature MUST publish at least one real English learning-diary post about Jorge’s current work or learning. Placeholder stub sections MUST NOT ship as that first entry. **Acceptance**: AC-P1.

- **FR-004**: Diary posts MUST be English. The feature MUST document a light ongoing convention: weekly target cadence; topic = what Jorge is doing/learning; standard post front matter the site already expects (title, date, draft flag as needed). **Acceptance**: AC-C1.

- **FR-005**: An agent MAY draft the first post for Jorge’s edit/approval; Jorge’s approval (merge or explicit sign-off) is required before treating the entry as final. **Acceptance**: AC-OWN1.

- **FR-006**: This feature MUST NOT redesign PaperMod visuals, MUST NOT add email contact, MUST NOT author project case studies, and MUST NOT automate post creation from other repositories. **Acceptance**: out-of-scope guards.

### Key Entities

- **Learning diary post**: A published Posts entry in English about current work or learning, with title and date.
- **Welcome draft**: Legacy placeholder post to delete or leave unpublished.
- **Diary convention**: Short written rules for future weekly entries (language, intent, cadence, front matter).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A visitor opening `/posts/` sees at least one published diary entry within one click from the main menu.
- **SC-002**: A recruiter can tell within 30 seconds that Posts is an active learning diary, not an empty or placeholder blog.
- **SC-003**: Adding a second weekly entry requires only a new post content file following the documented convention—no theme work.
- **SC-004**: Zero published posts remain whose body is the old welcome placeholder stub.

## Acceptance Criteria (verifiable)

| ID | Criterion |
|----|-----------|
| AC-M1 | Main menu includes Posts → `/posts/`. |
| AC-W1 | Welcome placeholder is not in the published Posts list (deleted or draft-only). |
| AC-P1 | At least one published English diary post with real current-work/learning content exists under `/posts/`. |
| AC-C1 | Feature docs/tasks state the light weekly English diary convention. |
| AC-OWN1 | First-post authorship notes Jorge approval before final merge. |

## Assumptions

- Existing Posts section and PaperMod post templates from feature 001 remain sufficient.
- Feature 008 may run in parallel; this feature does not depend on About/SmartWealthAI copy being finished.
- Jorge will approve the first post’s substance; agents do not invent false claims about his work.
- No scheduler or GitHub Action is required to enforce weekly cadence in this feature.

## Out of Scope

- Hiring content placeholders (home/About/SmartWealthAI)—feature 008.
- fintech-sec-rag-agent case study—feature 010.
- Public email—feature 011.
- Visual elegance—feature 012.
- `/log` TIL product, cross-repo post automation, non-English posts.
- CI/deploy leftover issues.

## Verification

```bash
set -euo pipefail
hugo --gc --minify --panicOnWarning --baseURL /
test -f public/posts/index.html
# at least one published post page exists beyond the section index
post_count=$(find public/posts -mindepth 2 -name index.html | wc -l)
test "$post_count" -ge 1
# welcome stub must not be a published post
! test -f public/posts/welcome/index.html
# menu
menu=$(sed -n '/<ul id="menu"/,/<\/ul>/p' public/index.html)
printf '%s\n' "$menu" | grep -F 'Posts'
printf '%s\n' "$menu" | grep -E 'href="?/posts/"?'
# no obvious placeholder stub markers in published post bodies
! grep -RFi 'This section is placeholder text' public/posts --include='*.html'
grep -E 'lang="?en"?' public/posts/index.html
lychee --offline --root-dir public public
```
