# Architecture Decisions

This file records durable architectural decisions for NatureAI Next. New ideas that do not alter an approved architectural decision belong in `BACKLOG.md`.

## ADR-001 — Original photographs are immutable

**Status:** Accepted

NatureAI Next never rewrites an original photograph during normal catalog, metadata, taxonomy, or AI workflows. Human metadata, review decisions, and AI results are stored in the library catalog. Embedded-file metadata is written only by an explicit export operation to a new output.

**Consequences**

- Catalog editing is fast and reversible.
- Original evidence remains unchanged.
- Exports must make provenance and embedded-metadata behavior explicit.

## ADR-002 — Human metadata and AI evidence are separate

**Status:** Accepted

Human-confirmed catalog metadata is authoritative. BioCLIP and other AI providers create versioned suggestions and observations with model, preprocessing, prompt, provider, score, and inference provenance. AI output never silently overwrites human metadata.

**Consequences**

- Suggestions require explicit review actions.
- Re-running a newer model preserves historical evidence.
- Search may distinguish confirmed metadata from unreviewed AI suggestions.

## ADR-003 — Catalog metadata saves are optimistic and atomic

**Status:** Accepted

A single-asset edit submits the loaded asset revision together with title, caption, notes, rating, color label, pick state, and the complete user-tag set. SQLite applies the metadata and user-tag replacement in one transaction. A mismatched revision is rejected and the latest values are reloaded.

**Consequences**

- Concurrent edits cannot silently overwrite one another.
- Partial metadata/tag saves are not visible.
- Import- and plugin-sourced tag assignments are not removed by user-tag editing.
