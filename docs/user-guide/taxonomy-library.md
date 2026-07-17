# Taxonomy Library

The Taxonomy workspace provides the current scientific classification used by Aperture. Version 1 focuses on stable browsing and assignment of taxa to observations. Major knowledge-center features such as comparison, maps, taxon timelines, and the Natuurgids.org Design System remain reserved for Version 2.

## Expected information

A taxon record should provide its scientific name, rank, accepted parent hierarchy, available common names, authority or source identifiers when supplied, and synonym relationships supported by the installed taxonomy package. Observation counts and AI suggestions are library data and do not replace the authoritative taxonomy record.

## Data quality

Missing names or hierarchy should be corrected in the source taxonomy package rather than edited directly in `library.sqlite3`. Use the Health Center and diagnostic logs to identify package or indexing problems. Back up the library before importing or replacing taxonomy resources.

## Version 2 scope

Version 2 will expand this area into Taxonomy & Knowledge with ecology, identification traits, conservation, media, similar species, analytics, completeness scoring, and validated taxonomy maintenance workflows.
