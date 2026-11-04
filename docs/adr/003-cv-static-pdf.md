# ADR 003: Serve the CV as a static PDF in the repository

**Status**: Accepted — PR #74 (Jorge's merge of that pull request accepts it)

**Date**: 2026-11-04

**Feature**: [specs/007-projects-about](../../specs/007-projects-about/spec.md)

## Context

The About page and main menu need a downloadable CV. Options were: generate a PDF in CI from Markdown or Word; host the file only in object storage outside the Hugo publish; or commit the current PDF under `static/` and let Hugo copy it into `public/` like any other asset.

Jorge already maintains a CV PDF and will upload the current file himself. The portfolio must stay English-only, cheap, and free of new AWS identities or CI PDF toolchains. Spec 007 forbids generating PDFs.

## Decision

Store the CV at `static/cv/jorge-laborda-cv.pdf`. Hugo publishes it at `/cv/jorge-laborda-cv.pdf`. About and the PaperMod main menu link that path as a download. Jorge replaces the file in git when the CV changes. No workflow generates or converts a PDF. No separate S3 object or signed URL is introduced for the CV.

## Consequences

- The PDF is versioned with the site; lychee offline and a simple `test -f` can prove the link in CI once the file is present.
- Binary diffs appear when Jorge updates the CV; that is acceptable for a single small PDF.
- Agents must not invent or regenerate the file; upload is a Jorge-only step (see tasks.md «Pasos de Jorge»).
- Email contact remains out of scope until after custom domain (spec 006); this decision does not add contact mechanisms beyond the PDF and LinkedIn/GitHub links.

## Alternatives

- Generate PDF in CI from Markdown. Rejected. Jorge already has a PDF; generation adds toolchain weight and diverges from his maintained document.
- Host only in S3 outside the Hugo tree. Rejected. Extra URL and IAM surface for no benefit; the deploy already publishes `public/`.
- Link to an external Drive/Dropbox URL. Rejected. Breaks offline lychee guarantees and couples the menu to a third-party host.
