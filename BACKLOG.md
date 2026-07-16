# Aperture and NatureAI_Next Backlog

## Purpose

This document records accepted work outside the Version 1 feature freeze. A backlog item does not enter implementation automatically. It must be assigned to a release, reviewed for data migration, accessibility, licensing, performance, and rollback impact, and approved before development.

The full directional plan is available in [ROADMAP.md](ROADMAP.md) and in **Help → Roadmap & Future Releases**.

## Version 2 — accepted priorities

### Taxonomy & Knowledge Center

Expanded taxonomy overview, hierarchy, synonyms, common names, revision history, identification guidance, ecology, distribution, conservation, reference media, observation analytics, AI information, Taxon Health, and taxonomy-maintenance tools.

### Content hashes and exact duplicates

Store SHA-256 during import, index it in SQLite, backfill existing libraries through Maintenance Center, detect exact duplicates, and support integrity verification. Perceptual duplicates remain later work.

### Import provenance and import sessions

Preserve original filename, original path, parent folder, source drive letter, source volume/disk/card name, volume identity where available, import session, timestamp, managed filename, and managed location.

### Dynamic AI orchestration

Keep BioCLIP while adding task-specific engines dynamically for classification, behavior, habitat, segmentation, quality assessment, OCR, and similarity as needed.

### Maintenance and migration

Cross-version database/library validation, migration reports, hash-index builder, backup verification, and an external Backup & Recovery utility capable of validating and upgrading restored libraries.

### AI workflow continuity

Offer a reminder for unfinished AI activities after confirming any required online capability.

### Deployment tooling

Develop the universal installer/update-release builder as a separate reusable project.

## Version 3 — accepted direction

Advanced analysis, multiple AI engines and ensembles, richer reports, collaboration, synchronization, shared taxonomy workflows, plugin growth, and perceptual duplicate review. Study suitable concepts from mature open-source digital asset managers such as digiKam while respecting licensing and maintaining an independent Aperture architecture.

## Version 4 — accepted direction

Offline maps, observation calendar, biological moments, monitoring projects, revisit suggestions, photo-completeness guidance, field packages, route support, and time-lapse planning/indication.

## Version 5 — accepted direction

Semantic and natural-language search, including visual/behavior queries such as “flying bird,” explainable results, similarity discovery, and dynamic use of the AI engines required for each query.

## Unassigned backlog

- broader Natuurgids visual design system and color coding after contrast/accessibility review;
- advanced export profiles;
- mobile/field companion options;
- additional metadata templates;
- expanded thumbnail failure diagnostics and decoder reporting;
- regional scientific data-exchange integrations.
