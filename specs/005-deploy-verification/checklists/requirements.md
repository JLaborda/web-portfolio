# Specification Quality Checklist: Automated Post-deploy Verification

**Purpose**: Validate specification completeness and quality before proceeding to planning
**Created**: 2026-10-23
**Feature**: [spec.md](../spec.md)

## Content Quality

- [ ] No implementation details (languages, frameworks, APIs). Waiver: constitution III and IV require GitHub OIDC, least privilege, and a CI check that fails the run. The product owner asked for the commands that test each requirement, including `aws s3api head-object`, curl, and the branch-protection read. FR-001 through FR-008 name those checks.
- [x] Focused on user value and business needs
- [ ] Written for non-technical stakeholders. Waiver: the User Stories are written for Jorge, who today runs the checks by hand. The Verification section is the reviewer's check required by the constitution, and it names the commands.
- [x] All mandatory sections completed

## Requirement Completeness

- [ ] No [NEEDS CLARIFICATION] markers remain. Waiver: FR-005 keeps one marker for the branch-protection read credential. Option A is a fine-grained PAT with Administration read-only on this repository only, stored as `BRANCH_PROTECTION_READ_TOKEN` and created by Jorge. Option B is a GitHub App with Administration read. The spec recommends A. `/speckit-clarify` records Jorge's choice. No second marker was added.
- [x] Requirements are testable and unambiguous
- [x] Success criteria are measurable
- [x] Success criteria are technology-agnostic (no implementation details)
- [x] All acceptance scenarios are defined
- [x] Edge cases are identified
- [x] Scope is clearly bounded
- [x] Dependencies and assumptions identified

## Feature Readiness

- [x] All functional requirements have clear acceptance criteria
- [x] User scenarios cover primary flows
- [x] Feature meets measurable outcomes defined in Success Criteria
- [ ] No implementation details leak into specification. Waiver: same reason as the first item. The open credential marker does not add a second implementation beyond the two options Jorge was asked to choose.

## Notes

- Items marked incomplete require spec updates before `/speckit-clarify` or `/speckit-plan`
- The waived items stay unchecked. The reason is on the same line. The Reviewer accepts or rejects those waivers.
- `/speckit-specify` and `/speckit-clarify` maintain this file. It is not a `/speckit-checklist` artifact.
- The credential waiver stays until `/speckit-clarify` replaces the marker. The other two waivers match feature 001 and feature 002: the constitution requires the commands to be written in the specification.
- `docs/adr/001-post-deploy-verification.md` is Proposed. Constitution I rule 1 says a spec pull request contains `spec.md` and this checklist only. The ADR is in the same pull request because the request that commissioned this spec asked for it. The Reviewer can reject that extra file.
