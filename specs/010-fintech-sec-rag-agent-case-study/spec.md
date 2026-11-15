# Feature Specification: Fintech SEC RAG Agent Case Study

**Feature Branch**: `010-fintech-sec-rag-agent-case-study`

**Created**: 2026-11-15

**Status**: Draft — Path: short (small change)

**Input**: User description: "Add an English case study page for fintech-sec-rag-agent to the portfolio, linked from Projects and Now, so recruiters see a second ML/MLOps fintech project next to SmartWealthAI. Use the existing project schema. Copy the architecture sketch from the source repo. Status must honestly say the pipeline is deployed on AWS and OpenSearch indexing is the current blocker; invent no metrics or results. Content PR carries needs-human. Supersedes the 008 note that forbade adding content/projects/fintech-sec-rag-agent.md. Spec Kit path: short."

## Context

Feature 008 completed SmartWealthAI and listed fintech-sec-rag-agent on `/now/` with a GitHub-only link, explicitly deferring an on-site case study. This feature adds that case study under Projects, copies the public architecture sketch into this repo, and retargets the Now Building link to the new page. It supersedes the 008 note “do not add `content/projects/fintech-sec-rag-agent.md`”.

The project layout from feature 007 requires front-matter fields `title`, `summary`, `problem`, `architecture_image`, `decisions`, `results`, `stack`, and `repo_url` (optional `demo_url`). Issue CA-1’s “current status” maps to the existing required `results` field: honest status prose under the published “Results” heading—no layout or schema change.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Hiring manager reads a second fintech case study (Priority: P1)

A hiring manager opens Projects, opens fintech-sec-rag-agent, and reads an English case study with summary, problem, architecture image, key decisions, honest current status (in Results), stack, and repository link—no demo link, no invented metrics.

**Why this priority**: Delivers the second ML/MLOps fintech proof next to SmartWealthAI.

**Independent Test**: After Hugo build, `public/projects/fintech-sec-rag-agent/index.html` exists; required headings render; `results` states AWS deployment and OpenSearch indexing as the blocker; `repo_url` is the GitHub repo; `demo_url` is absent; page is not draft.

**Acceptance Scenarios**:

1. **Given** the published site, **When** a visitor opens `/projects/fintech-sec-rag-agent/`, **Then** they see Summary, Problem, Architecture, Key decisions, Results, Stack, and Repository sections with non-empty content following the SmartWealthAI case-study schema.
2. **Given** that page, **When** they read Results, **Then** the text states that the pipeline is deployed on AWS and that OpenSearch indexing is the current blocker, and it claims no invented results or metrics.
3. **Given** that page’s front matter, **When** inspected, **Then** `repo_url` is `https://github.com/JLaborda/fintech-sec-rag-agent`, `demo_url` is omitted, and the page is not marked `draft: true`.

---

### User Story 2 - Architecture sketch is visible on the case study (Priority: P1)

A hiring manager sees the architecture sketch from the source repository on the case study page, with descriptive alt text.

**Why this priority**: Architecture is the visual proof for ML/MLOps recruiters; CA-3 requires the source sketch.

**Independent Test**: `static/images/projects/fintech-sec-rag-agent-sketch.png` exists; front matter `architecture_image` points at `/images/projects/fintech-sec-rag-agent-sketch.png`; `architecture_image_alt` is non-empty English; Hugo build resolves the image.

**Acceptance Scenarios**:

1. **Given** the portfolio repo, **When** the feature is content-complete, **Then** `static/images/projects/fintech-sec-rag-agent-sketch.png` is present (copied from `docs/images/fintech-sec-rag-agent-sketch.png` in https://github.com/JLaborda/fintech-sec-rag-agent).
2. **Given** `/projects/fintech-sec-rag-agent/`, **When** the Architecture section is rendered, **Then** the img `src` resolves to that static file and `alt` is a non-empty English description.

---

### User Story 3 - Now points at the on-site case study (Priority: P2)

A hiring manager opens `/now/` and follows fintech-sec-rag-agent to the portfolio case study instead of only to GitHub.

**Why this priority**: Aligns Now with Projects once the page exists (CA-5).

**Independent Test**: In `content/now.md`, the Building entry for fintech-sec-rag-agent uses a URL that targets `/projects/fintech-sec-rag-agent/` (site-relative or absolute path to that page), not solely the GitHub repository URL.

**Acceptance Scenarios**:

1. **Given** `/now/`, **When** a visitor activates the fintech-sec-rag-agent Building link, **Then** they reach the on-site case study `/projects/fintech-sec-rag-agent/`.
2. **Given** that Building entry, **When** compared to pre-feature Now, **Then** it no longer uses only `https://github.com/JLaborda/fintech-sec-rag-agent` as the destination.

---

### User Story 4 - Site builds and staging shows the page (Priority: P1)

After implementation, Hugo CI gates pass and the case study is reachable on staging once that build is deployed.

**Why this priority**: CA-6; no silent content that fails the build.

**Independent Test**: `hugo --gc --minify --panicOnWarning --baseURL /` exits 0 and emits `public/projects/fintech-sec-rag-agent/index.html`. Staging evidence is recorded at converge.

**Acceptance Scenarios**:

1. **Given** the feature branch head, **When** Hugo builds with panic-on-warning, **Then** the build succeeds and the case study HTML exists under `public/projects/fintech-sec-rag-agent/`.
2. **Given** staging after deploy from `develop`, **When** `/projects/fintech-sec-rag-agent/` is requested, **Then** it returns success (recorded in converge).

### Edge Cases

- Source sketch missing or rename in the upstream repo: copy fails; task MUST NOT invent a substitute diagram or use Mermaid.
- Temptation to invent latency/accuracy/cost metrics: forbidden; Results/status may only state deployment + OpenSearch indexing blocker and qualitative limits that exist in public source materials.
- `demo_url` accidentally set empty vs omitted: omit the key so the Demo heading does not appear (spec 007 behavior).
- Now still listing GitHub for SmartWealthAI: unchanged; only fintech-sec-rag-agent must retarget to the case study.
- Content authorship: agent may draft from the public fintech-sec-rag-agent README / `specs/001-10k-signal-demo`; the implementation PR that publishes the case study text MUST carry `needs-human` so Jorge approves the wording.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `content/projects/fintech-sec-rag-agent.md` MUST exist, MUST NOT be `draft: true`, and MUST use the SmartWealthAI / feature 007 project schema: `title`, `summary`, `problem`, `architecture_image`, `architecture_image_alt`, `decisions`, `results` (honest current status per FR-002), `stack`, `repo_url`. **Acceptance**: CA-1.

- **FR-002**: The `results` field (published as “Results”) MUST state that the pipeline is deployed on AWS and that OpenSearch indexing is the current blocker. It MUST NOT claim invented results, metrics, or screenshots of outputs that do not exist. **Acceptance**: CA-2.

- **FR-003**: The architecture sketch MUST be copied from `docs/images/fintech-sec-rag-agent-sketch.png` in https://github.com/JLaborda/fintech-sec-rag-agent into `static/images/projects/fintech-sec-rag-agent-sketch.png`. Front matter MUST set `architecture_image: /images/projects/fintech-sec-rag-agent-sketch.png` and a non-empty English `architecture_image_alt`. **Acceptance**: CA-3.

- **FR-004**: `repo_url` MUST be `https://github.com/JLaborda/fintech-sec-rag-agent`. `demo_url` MUST NOT be present. **Acceptance**: CA-4.

- **FR-005**: `content/now.md` Building entry for fintech-sec-rag-agent MUST link to the on-site case study (`/projects/fintech-sec-rag-agent/` or equivalent site path), not only to GitHub. `last_updated` MUST be set to the edit date (ISO). **Acceptance**: CA-5.

- **FR-006**: Hugo build with `--gc --minify --panicOnWarning` MUST succeed, and the page MUST render on staging after deploy. **Acceptance**: CA-6.

- **FR-007**: The content pull request that introduces or finalizes the case study prose MUST carry the GitHub label `needs-human` so Jorge approves the text before merge.

- **FR-008**: This feature supersedes the feature 008 instruction not to add `content/projects/fintech-sec-rag-agent.md`. That page is in scope here.

### Key Entities

- **fintech-sec-rag-agent case study**: New project page under `content/projects/`, same schema as SmartWealthAI.
- **Architecture sketch**: Static PNG under `static/images/projects/`, sourced from the public project repo.
- **Now Building entry**: Retargeted link for fintech-sec-rag-agent to the on-site case study.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A hiring manager can open `/projects/fintech-sec-rag-agent/` and summarize problem, approach, and current blocker in under two minutes.
- **SC-002**: `/now/` Building for fintech-sec-rag-agent lands on the on-site case study, not only GitHub.
- **SC-003**: Hugo CI gates pass; staging serves the new page (evidence in converge).

## Acceptance Criteria (verifiable)

| ID | Criterion |
|----|-----------|
| CA-1 | `content/projects/fintech-sec-rag-agent.md` exists, not draft, with summary, problem, architecture/decisions, current status (via `results`), and stack, following SmartWealthAI structure. |
| CA-2 | Status/`results` states pipeline deployed on AWS and OpenSearch indexing is the current blocker; no claimed invented results or metrics. |
| CA-3 | Architecture image is the source-repo sketch at `static/images/projects/fintech-sec-rag-agent-sketch.png` with alt text. |
| CA-4 | `repo_url` is `https://github.com/JLaborda/fintech-sec-rag-agent`; no `demo_url`. |
| CA-5 | Now page links to the new case study instead of only GitHub. |
| CA-6 | Hugo build passes and the page renders on staging. |

## Assumptions

- Feature 007 project layout and `_index.md` cascade (`layout: project`) remain unchanged.
- Feature 008 Now list already includes fintech-sec-rag-agent; this feature only retargets its URL (and updates `last_updated`).
- Public materials in fintech-sec-rag-agent are sufficient for an honest draft; Jorge approves final wording via `needs-human`.
- Production ship is the next `develop` → `main` release after this feature merges to `develop` (release itself is out of this feature’s implementation tasks).

## Out of Scope

- Changes to the fintech-sec-rag-agent repository itself.
- Fixing the OpenSearch indexing issue.
- Invented metrics, results, or screenshots of outputs that do not exist.
- Theme, layout, `infra/`, or CI workflow changes.
- Editing SmartWealthAI case study content.
- Visual redesign of PaperMod.

## Notes

- Content drafted from the public repo (README, `specs/001-10k-signal-demo`). The content PR carries `needs-human`: Jorge approves the text.
- Supersedes the 008 note “do not add `content/projects/fintech-sec-rag-agent.md`”.
- Spec Kit path: short.
- Ships to production in the next `develop` → `main` release.

## Verification

```bash
set -euo pipefail
test -f static/images/projects/fintech-sec-rag-agent-sketch.png
test -f content/projects/fintech-sec-rag-agent.md
! grep -Ei '^draft:[[:space:]]*true' content/projects/fintech-sec-rag-agent.md
grep -F 'repo_url: https://github.com/JLaborda/fintech-sec-rag-agent' content/projects/fintech-sec-rag-agent.md
! grep -E '^demo_url:' content/projects/fintech-sec-rag-agent.md
grep -F 'architecture_image: /images/projects/fintech-sec-rag-agent-sketch.png' content/projects/fintech-sec-rag-agent.md
grep -E '^architecture_image_alt:' content/projects/fintech-sec-rag-agent.md
grep -Fi 'OpenSearch' content/projects/fintech-sec-rag-agent.md
grep -Fi 'AWS' content/projects/fintech-sec-rag-agent.md
grep -F '/projects/fintech-sec-rag-agent/' content/now.md
hugo --gc --minify --panicOnWarning --baseURL /
test -f public/projects/fintech-sec-rag-agent/index.html
grep -E '<h2>Summary</h2>' public/projects/fintech-sec-rag-agent/index.html
grep -E '<h2>Problem</h2>' public/projects/fintech-sec-rag-agent/index.html
grep -E '<h2>Architecture</h2>' public/projects/fintech-sec-rag-agent/index.html
grep -E '<h2>Key decisions</h2>' public/projects/fintech-sec-rag-agent/index.html
grep -E '<h2>Results</h2>' public/projects/fintech-sec-rag-agent/index.html
grep -E '<h2>Stack</h2>' public/projects/fintech-sec-rag-agent/index.html
grep -F 'fintech-sec-rag-agent-sketch.png' public/projects/fintech-sec-rag-agent/index.html
grep -F 'https://github.com/JLaborda/fintech-sec-rag-agent' public/projects/fintech-sec-rag-agent/index.html
! grep -E '<h2>Demo</h2>' public/projects/fintech-sec-rag-agent/index.html
grep -F '/projects/fintech-sec-rag-agent/' public/now/index.html
lychee --offline --root-dir public public
```
