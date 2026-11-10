# Feature Specification: Hiring Content Wave

**Feature Branch**: `008-hiring-content`

**Created**: 2026-11-10

**Status**: Draft — Path: short (small change)

**Input**: User description: "Replace remaining hiring-surface placeholders with real English content for ML Engineer / MLOps fintech recruiters. Wire a real home profile headline that Jorge supplies. Fill About with Jorge’s bio, stack, and certifications (no email yet). Replace all SmartWealthAI PLACEHOLDER prose with a complete case study (full existing project schema); agent drafts from the SmartWealthAI repo/README/specs, Jorge approves/edits before merge; keep the existing architecture diagram; results must be honest and may be qualitative—no invented metrics. Sync /now/ Building to SmartWealthAI + fintech-sec-rag-agent (portfolio repo optional) and remove health-stream-xai from Building. Stay on PaperMod; no visual redesign. Out of scope: fintech-sec-rag-agent case study page (feature 010), public email (011), visual elegance (012), CI/deploy chores, other projects as case studies."

## Context

Spec 007 shipped the project case-study schema, About structure, CV download, and SmartWealthAI with marked placeholders. Production still shows `Placeholder headline`, About `PLACEHOLDER` copy, and SmartWealthAI `PLACEHOLDER` fields. The 2026-11-10 `/grill-me` session agreed this wave fills that hiring content first and parks aesthetics. fintech-sec-rag-agent may appear on `/now/` as something Jorge is building (GitHub link) without a case study page in this feature.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Hiring manager reads a finished SmartWealthAI case study (Priority: P1)

A hiring manager opens Projects, opens SmartWealthAI, and reads a complete English case study: summary, problem, architecture image, key decisions, honest results, stack, and repository link—with no placeholder wording.

**Why this priority**: Case studies are the portfolio’s proof of depth; placeholders undermine trust.

**Independent Test**: Build the site. `/projects/smartwealthai/` HTML contains every required section with non-placeholder prose. Grep for `PLACEHOLDER` on that page returns no matches. The architecture image still renders.

**Acceptance Scenarios**:

1. **Given** the published site, **When** a visitor opens `/projects/smartwealthai/`, **Then** they see title, summary, problem, architecture image, decisions, results, stack, and repo link, and none of those values is empty or marked as placeholder.
2. **Given** that page’s HTML and the source Markdown, **When** searched for the token `PLACEHOLDER` (any case), **Then** there are no matches in the published SmartWealthAI content.
3. **Given** the results section, **When** a reviewer reads it, **Then** claims are qualitative and/or sourced honestly—no fabricated production metrics.

---

### User Story 2 - Hiring manager reads real About and a clear home position (Priority: P1)

A hiring manager lands on the home profile, sees Jorge’s name plus a real one-line positioning headline (role + domain), then opens About and reads a short bio, stack, and certifications with LinkedIn, GitHub, and CV—still no email.

**Why this priority**: Home and About are the first credibility check next to Projects.

**Independent Test**: Home subtitle is not `Placeholder headline`. `/about/` has no `PLACEHOLDER` tokens. Menu still offers Projects, Now, About, Posts, and CV. No `mailto:` on About.

**Acceptance Scenarios**:

1. **Given** the published home page, **When** a visitor views the profile block, **Then** they see a single English positioning headline supplied by Jorge, and they do not see the literal text `Placeholder headline`.
2. **Given** `/about/`, **When** a visitor reads it, **Then** they see short bio, stack, certifications (including AWS MLA-C02 in progress unless Jorge updates that status), LinkedIn, GitHub, and CV download, with no placeholder markers and no email/`mailto:`.
3. **Given** the main menu, **When** inspected, **Then** Projects, Now, About, Posts, and CV remain; Search stays off the menu.

---

### User Story 3 - Hiring manager sees Now aligned with what the portfolio is selling (Priority: P2)

A hiring manager opens `/now/` and sees Building list SmartWealthAI and fintech-sec-rag-agent (and optionally this portfolio), without health-stream-xai as a Building item, so Now does not advertise a different project set than Projects.

**Why this priority**: Mismatch between Now and Projects confuses recruiters about focus.

**Independent Test**: `/now/` Building links include SmartWealthAI and fintech-sec-rag-agent; health-stream-xai is absent from Building. Last updated remains a valid ISO date Jorge sets when he edits.

**Acceptance Scenarios**:

1. **Given** `/now/`, **When** a visitor reads Building, **Then** they see SmartWealthAI and fintech-sec-rag-agent with working links.
2. **Given** Building, **When** searched for health-stream-xai, **Then** it is not listed there.
3. **Given** this feature does not publish a fintech-sec-rag-agent case study, **When** Building links that project, **Then** the link may point at its public GitHub repository (not a missing on-site case study URL).

---

### User Story 4 - Jorge and an agent iterate content without template churn (Priority: P3)

Jorge supplies the home headline and About prose. An agent drafts SmartWealthAI copy from the public SmartWealthAI materials; Jorge edits and approves before the content is treated as final. Updates are Markdown (and assets already present), not layout redesigns.

**Why this priority**: Agreed authorship model from the grill; keeps PaperMod templates stable.

**Independent Test**: Changing only content/config files updates home subtitle, About, SmartWealthAI, and Now without new visual theme work.

**Acceptance Scenarios**:

1. **Given** Jorge’s approved headline string, **When** it is set on the site profile, **Then** home shows that exact positioning line.
2. **Given** an agent draft of SmartWealthAI, **When** Jorge has not approved it, **Then** it MUST NOT merge as final hiring copy (approval is Jorge’s merge or explicit sign-off on the content PR).
3. **Given** this feature, **When** complete, **Then** no PaperMod visual redesign (fonts, colors, hero composition, favicons art, footer branding) shipped as part of it.

### Edge Cases

- Jorge has not yet delivered headline or About prose: implementation MUST NOT invent the hiring claim or biography; tasks stay blocked on his text or use clearly temporary draft only on a non-production path Jorge accepts—default is wait for Jorge’s copy.
- SmartWealthAI architecture image path or file missing: existing required-field build failure from spec 007 still applies; this feature keeps the current diagram unless Jorge replaces it.
- Optional `demo_url` absent: no empty Demo heading (spec 007 behavior).
- fintech-sec-rag-agent case study page must not appear under `/projects/` in this feature.
- Email remains out of scope even though the custom domain is live.
- Weekly diary posts are feature 009, not this feature—Posts menu entry stays, content of Posts is unchanged here.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The home profile subtitle/headline MUST be a real English positioning line that Jorge supplies (role and domain for ML Engineering / MLOps fintech hiring). The literal string `Placeholder headline` MUST NOT appear on the published home page. **Acceptance**: AC-H1.

- **FR-002**: `/about/` MUST present Jorge-authored short bio, stack, and certifications in English, plus LinkedIn, GitHub, and CV download. It MUST NOT contain `PLACEHOLDER` markers, email addresses, or `mailto:` links. Certifications MUST still reflect AWS MLA-C02 status accurately per Jorge’s text. **Acceptance**: AC-A1.

- **FR-003**: `/projects/smartwealthai/` MUST publish a complete case study using the existing project schema (`title`, `summary`, `problem`, `architecture_image`, `decisions`, `results`, `stack`, `repo_url`; optional `demo_url`). All prior placeholder tokens and placeholder prose MUST be removed. **Acceptance**: AC-P1.

- **FR-004**: SmartWealthAI `results` MUST be honest (qualitative demo outcomes and limits allowed). Invented production metrics MUST NOT be published. **Acceptance**: AC-P2.

- **FR-005**: SmartWealthAI case study copy MAY be drafted by an agent from the SmartWealthAI repository materials; Jorge MUST approve or edit before that copy is merged as the live hiring case study. About prose and the home headline MUST be Jorge’s voice (agent may only wire formatting/links once he supplies text). **Acceptance**: AC-OWN1.

- **FR-006**: `/now/` Building MUST list SmartWealthAI and fintech-sec-rag-agent with links; MAY list this portfolio; MUST NOT list health-stream-xai. Linking fintech-sec-rag-agent to GitHub is sufficient because its on-site case study is out of scope. **Acceptance**: AC-N1.

- **FR-007**: Main menu MUST keep Projects, Now, About, Posts, and CV download; Search stays off the menu. Site language remains English (`lang="en"`). **Acceptance**: AC-M1.

- **FR-008**: This feature MUST NOT ship a visual redesign of PaperMod, MUST NOT add a fintech-sec-rag-agent (or other) new case study page, MUST NOT add public email, and MUST NOT treat CI/deploy leftover issues as in-scope work. **Acceptance**: out-of-scope guards in Verification / PR review.

### Key Entities

- **Home positioning headline**: Single English subtitle on the profile home, owned by Jorge.
- **About page**: Bio, stack, certifications, social links, CV—owned by Jorge.
- **SmartWealthAI case study**: Existing project entity under Projects; content completed in this feature.
- **Now Building list**: Current-work entries aligned with the hiring narrative for this wave.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A hiring manager can open home, About, and SmartWealthAI and find zero `PLACEHOLDER` / `Placeholder headline` strings in those published surfaces.
- **SC-002**: A hiring manager can summarize SmartWealthAI’s problem, approach, and results in under two minutes from the case study page alone.
- **SC-003**: A hiring manager comparing `/now/` Building with `/projects/` sees SmartWealthAI as a case study and does not see health-stream-xai listed under Building.
- **SC-004**: Time-to-credible first read (home headline + About skimming) is under 60 seconds for a recruiter familiar with ML/MLOps roles.

## Acceptance Criteria (verifiable)

| ID | Criterion |
|----|-----------|
| AC-H1 | Published home profile shows Jorge’s English positioning headline; `Placeholder headline` is absent. |
| AC-A1 | `/about/` has bio, stack, certifications, LinkedIn, GitHub, CV; no `PLACEHOLDER`, no email/`mailto:`. |
| AC-P1 | SmartWealthAI case study renders full schema content with no `PLACEHOLDER` tokens; architecture image present. |
| AC-P2 | Results section contains only honest qualitative and/or non-fabricated claims (reviewer check). |
| AC-OWN1 | Docs/tasks record Jorge as owner of headline + About; SmartWealthAI draft requires his approval before merge as final. |
| AC-N1 | `/now/` Building includes SmartWealthAI and fintech-sec-rag-agent; excludes health-stream-xai; no on-site fintech-sec-rag-agent case study from this feature. |
| AC-M1 | Menu keeps Projects, Now, About, Posts, CV; pages stay `lang="en"`. |

## Assumptions

- Spec 007’s project schema, layouts, CV path, and menu shape remain the baseline; this feature is content completion plus Now alignment and headline wiring.
- Jorge will provide the home headline and About prose before or during implementation; agents do not invent his biography or positioning claim.
- The existing SmartWealthAI architecture PNG remains acceptable unless Jorge supplies a replacement.
- Feature 009 (learning diary) may run in parallel and owns Posts content changes.
- Feature 010 will add the fintech-sec-rag-agent case study and its architecture diagram later.

## Out of Scope

- Case study page for fintech-sec-rag-agent, health-stream-xai, or any project other than completing SmartWealthAI.
- Public email / `mailto:` (feature 011 when mailbox is ready).
- Visual elegance / PaperMod restyle (feature 012).
- CI/deploy chores (#91, #46, #70, #84, #76) unless opened separately.
- Changing AWS infrastructure, domain DNS, or CV PDF generation.
- Automating Now updates from external repos.

## Verification

```bash
set -euo pipefail
hugo --gc --minify --panicOnWarning --baseURL /
test -f public/index.html
test -f public/about/index.html
test -f public/projects/smartwealthai/index.html
test -f public/now/index.html
# no placeholder tokens on hiring surfaces
! grep -Fi 'Placeholder headline' public/index.html
! grep -Fi 'PLACEHOLDER' public/about/index.html
! grep -Fi 'PLACEHOLDER' public/projects/smartwealthai/index.html
# about: no mailto / email
if grep -Ei 'mailto:|@[a-z0-9.-]+\.[a-z]{2,}' public/about/index.html; then exit 1; fi
# now building alignment (case-insensitive)
grep -Fi 'SmartWealthAI' public/now/index.html
grep -Fi 'fintech-sec-rag-agent' public/now/index.html
! grep -Fi 'health-stream-xai' public/now/index.html
# no second case study from this feature
! test -f public/projects/fintech-sec-rag-agent/index.html
# menu + lang
menu=$(sed -n '/<ul id="menu"/,/<\/ul>/p' public/index.html)
printf '%s\n' "$menu" | grep -F 'Projects'
printf '%s\n' "$menu" | grep -F 'Now'
printf '%s\n' "$menu" | grep -F 'About'
printf '%s\n' "$menu" | grep -F 'Posts'
printf '%s\n' "$menu" | grep -E 'cv/jorge-laborda-cv\.pdf'
grep -E 'lang="?en"?' public/index.html
grep -E 'lang="?en"?' public/about/index.html
lychee --offline --root-dir public public
```
