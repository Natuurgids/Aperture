# Changelog

## 2.0.0 RC2.2

- Replaced single-path Geofabrik tile rendering with a bounded multi-process NatureAI Nest render pool.
- Kept MBTiles database publication serialized while CPU-heavy tile generation runs across cores.
- Added adaptive memory-assisted resource workspaces with disk fallback.
- Added durable map checkpoints every 32 tiles.
- Preserved all resumable Activity Center work during history cleanup and added Open Tasks visibility.
- Made durable job worker sizing adaptive to logical processor count.

## 2.0.0 RC2.1 - Resource inventory and diagnostics

- Added inventory-first offline-map acquisition: verified current packages are reused without downloading or rendering again.
- Added developer performance diagnostics for process CPU, memory, threads, disk I/O, and Activity Center state when available.
- Refined shared Resource Manager delta planning and preserved the no-legacy-migration policy for pre-Version-5 playground builds.
- Kept seamless global “Show all offline maps” rendering in the later map-engine backlog.

## 2.0.0 RC2 - Resource reliability and responsiveness

- Added staged taxonomy import with family, genus, and species checkpoints and atomic publication.
- Reused stable taxon identities during updates, preventing duplicate `taxa.public_id` failures.
- Added shared GBIF region and species caches so added countries reuse existing downloads.
- Added the Resource Manager acquisition-planning foundation for delta/full resource decisions.
- Throttled Activity Center persistence and UI refresh to one update per second.
- Added logical user-facing failure messages, technical details, recommended actions, and safe activity cleanup.
- Added a required verified shutdown backup after successful taxonomy publication.
- Deferred seamless “Show all installed maps” rendering to the map-engine backlog.

# Aperture 2.0.0 RC1 — Release Candidate Freeze

- Frozen Release 2 functionality after successful end-to-end offline map field validation.
- Synchronized release identity, documentation, Help content, roadmap, backlog, and known limitations.
- Confirmed Species Dashboard search and higher-detail map generation as Release 3 backlog work.
- No new production functionality added after the R8 map integration build.

---

# Aperture 2.0.0.dev6968 — Shared Map Catalog and MBTiles Validation

- Map viewer now accepts all enabled installed MBTiles packages from the same catalog used by Offline Maps.
- Existing Geofabrik-generated packages registered with the legacy provider key remain discoverable without rerendering.
- New Geofabrik conversions register as `openstreetmap.mbtiles` while retaining source attribution.
- MBTiles installation now requires at least one tile plus valid bounds, zoom, and format metadata.
- Verification reports tile count and supported zoom range.

- Added an installed-area selector to the Maps workspace.
- Added **Zoom to Area** using the geographic bounds stored with each enabled MBTiles package.
- The Maps workspace now discovers newly installed packages when opened or refreshed.
- When the current view is not covered, Aperture automatically centers on the first enabled installed area.
- Existing pan, zoom, temporal overlays, observations, and offline-only tile reading remain unchanged.

# 2.0.0.dev6966

- Added VISION.md and PHILOSOPHY.md as authoritative project documents.
- Refreshed Help and About navigation while retaining complete development documentation.
- Clarified Aperture/NatureAI Next ownership and integration boundaries.

# Aperture Changelog

## 2.0.0.dev69652 — M6.9.6 R5.2 malformed geometry tolerance

- Isolated Geofabrik shape reads per record so invalid polygon records no longer fail an entire map job.
- Added defensive validation for empty points, invalid bounds, malformed parts, and non-finite coordinates.


## 2.0.0.dev69651 — M6.9.6 R5.1 Windows map cleanup reliability

- Explicitly closes every pyshp reader before temporary Geofabrik source files are removed.
- Reuses open layer readers during rendering instead of reopening DBF/SHP files for every tile.
- Added bounded Windows cleanup retries and defers stubborn temporary folders to Maintenance Center cleanup without invalidating a completed map.

- Moved Geofabrik region acquisition and raster MBTiles generation off the Qt UI thread into Activity Center operations.
- Added one-second throttled progress with transfer speed and rendered-tile counts.
- Added cancellation and retry payloads for individual regional map activities.

- Added `pyshp` to the installer core requirements used by all installation profiles.
- Changed Geofabrik conversion support to load `pyshp` only when a map conversion is started.
- Maintenance Center, Settings, health checks, and installed-map management now open even when optional conversion support is missing.
- Missing conversion support is reported as a repairable map-download error rather than a Maintenance Center bootstrap failure.


## 2.0.0.dev6963 — M6.9.6 R3

- Fixed Offline Maps installed-package refresh against the supported catalog API.
- Added Resources navigation entries for Offline Maps and Taxonomy Resources.
- Added cached map-catalog offline display and improved certification lock handling.
- Preserved separate, capability-specific acquisition workflows.

# M6.9.6 — Regional Taxonomy and Map Selection

- Connected Regional Knowledge GBIF package installation to the shared Taxonomy Reference database used by the Knowledge Center.
- Preserved the existing BioCLIP regional workflow and ranking behavior.
- Reworked Offline Map setup around continent/country filters and checkable regional packages.
- Moved map catalog source configuration under an Advanced section.

# Aperture 2.0.0.dev694 — M6.9.4 Settings and Maintenance Library Resolution

## 2.0.0.dev694 — M6.9.4 R1

- Fixed standalone Maintenance Center library discovery by using the same launcher configuration as Aperture.
- Added BOM-safe launcher configuration loading and a graphical library-selection fallback.
- Added Tools menu entries for Maintenance Center, Settings, and Help.
- Added a Settings landing workspace in the navigation pane.
- Added user-facing library selection that is remembered across launches.
- No schema or library-format changes.

---

# Aperture 2.0.0.dev693 — M6.9.3 Map Package Guidance and Bundle Import

- Added pre-download storage estimates and large-package guidance recommending regional increments.
- Added verified `.apkg` offline map bundle import for complete prepared map collections.
- Documented map catalog deployment, field preparation, bundle distribution, updates, and removal in user, operations, and developer manuals.
- Preserved the existing map renderer, core spatial data, and BioCLIP behavior.

## 2.0.0.dev693 — M6.9.3 Map Package Guidance and Bundle Import R1

- Synchronized runtime, packaging, installer-facing, release-note, and embedded Help version identity.
- Distinguished the Version 2 development package from the frozen Aperture 1.0.0 Foundation Release.
- Added release-manifest metadata and regenerated all file hashes after synchronization.

# Aperture 2.0 M6.9.1 — Platform Certification Build

- Added read-only Version 2 platform certification to the existing Maintenance Center.
- Certified core-library health, asset-enrichment integrity, optional maps/taxonomy state, Knowledge Engine capability registration, and maintenance boundaries.
- Preserved lazy optional-subsystem activation during certification.
- Added ADR-028 and focused regression coverage for certification failure isolation.

# Aperture 2.0 M5.2 — BioCLIP Asset-Enrichment Integration

- Connected local BioCLIP suggestion generation to immutable per-photo asset analyses.
- Linked review suggestions to the exact analysis execution while preserving historical unlinked suggestions.
- Stored ranked BioCLIP outputs as normalized analysis taxon candidates.
- Recorded succeeded and failed per-photo analysis outcomes without changing the validated review-authority workflow.
- Added ADR-016 and regression coverage for analysis/suggestion traceability.

# Aperture 1.0.0 — Foundation Release

- Promoted package version from `1.0.0rc1` to `1.0.0`.
- Added `VERSION2_DEVELOPMENT_CHARTER.md` to the source package and offline Help.
- Synchronized final release notes, project handover, validation title and start-here guidance.
- Preserved the validated runtime, database schema and library format without functional changes.

# Aperture 1.0.0 RC1 — Documentation Freeze

- Synchronized source documentation and packaged offline Help.
- Added Roadmap & Future Releases to Help.
- Added Version 1 project handover.
- Consolidated accepted Version 2–5 roadmap and backlog decisions.
- No runtime, schema, library-format, or AI-processing change.


## RC1 launcher and import-view correction

- Replaced the fragile WScript/PowerShell normal launcher with a direct `pythonw.exe` `.pyw` launcher.
- Added an explicit Library View selector with **All Library** and **Latest import** options.
- Import completion still shows the exact imported items, while users can return to the complete catalog without resetting filters manually.
## 1.0.0 RC1 stabilization polish

- Added structured first-paint startup timing diagnostics.
- Deferred Maintenance Center backup-history loading until after its window is shown.
- Added visible maintenance progress and disabled actions while history loads.
- Completed startup-performance and Taxonomy Library documentation.
- No database migration or workflow changes.

- Fixed clean-install ordering so a new `Aperture-Library` is initialized before launchers validate and register it.
# Changelog
- Fixed `Install Aperture.cmd` interactive launch when no installer arguments are supplied.

## 1.0.0 RC1

- Added BOM-tolerant and legacy-compatible library manifest reading.
- Added atomic manifest normalization with preservation of the original file.
- Added clear validation for malformed, incomplete, and unsupported manifests.
- Added regression coverage for all legacy fields encountered during field recovery.
- No database migration.

## 0.19.1

- Added operational-location diagnostics to Maintenance Center.
- Completed Viewer and Library Inspector shortcut documentation.
- Added release contracts for path diagnostics and shortcut completeness.
- No database migration.

## 0.19.0

- Added the visible Aperture Maintenance Center.
- Added updater progress and failure UI.
- Added a dedicated Maintenance Center launcher and installer shortcut.
- Preserved the legacy backup/recovery launcher as a compatibility alias.
- Added Maintenance Center documentation to packaged Help.

# Changelog

## 0.19.0

- Added a verified native-updater readiness handshake before Aperture closes.
- Made backup and no-backup update choices share the same handoff path.
- Added updater waiting for library-lock release before installation and relaunch.
- Added safe dead-process lock recovery as a reusable lifecycle operation.
- Added regression coverage for helper startup, failure acknowledgement, and lock-aware installation.

## 0.18.1

- Fixed friendly single-instance handling and stale Windows library-lock recovery.
- Added restore-without-backup and reliable lock-aware restore handoff.
- Removed synchronous database integrity scanning from the startup critical path.
- Updated launcher branding and lifecycle diagnostics.

- Added the Windows installer build guide and `scripts/build_aperture_windows_installer.ps1` to the source release and in-application Help.
## 0.18.0

- Consolidated Version 1 reliability and usability work.
- Added managed verified-backup history with restore, verify, and delete actions.
- Added persistent update history and post-install staging cleanup.
- Updated documentation and release QA contracts.

## 0.17.11 — Reliable Update Handoff

- Fixed the backup-to-update handoff so the updater starts before Aperture exits.
- Added Back Up and Install, Install Without Backup, and Cancel choices.
- Added updater startup verification and background-work safety checks.
- Added regression tests for handoff ordering and helper readiness.


## 0.17.10

- Added the standalone Aperture Backup & Recovery application and Windows shortcuts.
- Replaced user-facing restore scripts with automatic close, restore, rollback, and relaunch.
- Moved About Aperture to a separate top-level menu item.
- Fixed deployment preflight to use Conda Python instead of the Windows Store Python alias.

# 0.17.9 — Native Update & Recovery

- Replaces user-facing PowerShell update and restore steps with automatic background helpers.
- Adds restart-and-install and restart-and-restore workflows.
- Verifies staged packages and backups again after Aperture exits.
- Relaunches the same library after successful completion.
- Keeps PowerShell scripts only for developer and emergency support.

# 0.17.9 — Native Update & Recovery

- Replaces user-facing PowerShell update and restore steps with automatic background helpers.
- Adds restart-and-install and restart-and-restore workflows.
- Verifies staged packages and backups again after Aperture exits.
- Relaunches the same library after successful completion.
- Keeps PowerShell scripts only for developer and emergency support.

# Changelog

## 0.17.8 — Help System & Discoverability

- Added an integrated searchable offline Help browser.
- Added complete Help-menu access to bundled guides and release notes.
- Added context-sensitive F1 help.
- Documented and surfaced AI Review J/K, A, R, D, O, Ctrl+Z, and Shift+Enter shortcuts.
- Added in-workspace shortcut hints and documentation contract tests.
- No database migration.


## 0.17.6 — Installer and Deployment Hardening

- Added release-tree deployment preflight before installer mutations.
- Added structured preflight evidence and an installer diagnostics bundle.
- Added deployment, upgrade, repair, and uninstall guidance.
- Preserved Aperture branding and NatureAI_Next internals.


### Added

- Aperture Health Center with database, manifest, storage, backup, update-source, temporary-file, cache, and index checks.
- Full SQLite integrity-check action and clear healthy/warning/error summaries.
- Conservative **Repair Safe Items** action for missing standard directories and stale temporary files.
- Direct Health Center access to Backup, Restore, and Offline Updates.
- Version 1 release-readiness QA and Health Center documentation.
- Service and release-contract tests for health assessment and repair behavior.

### Compatibility

- No database migration or resource-format change.
- Internal NatureAI_Next identifiers remain unchanged; Aperture remains the user-facing brand.
- Version 2 design-system, maps, comparison, and major navigation work remains deferred.

## 0.17.4 - 2026-07-14

### Added

- Backup & Recovery Center with Restore Library, Verify Backup, and Manage Backups actions.
- Verified restore staging with mandatory emergency pre-restore backup.
- Rollback-capable PowerShell recovery utility and synchronized recovery documentation.
- Recovery verification, tamper rejection, staging, and release contract tests.

# Changelog

## 0.17.2 - Backup Button & Verified Snapshots

- Added Back Up Library to the toolbar, File menu, and Settings menu with Ctrl+Shift+B.
- Added verified, non-overwriting SQLite snapshots and SHA-256 JSON manifests.
- Added user-visible completion and failure reporting.
- Expanded backup and recovery documentation and automated release guards.
- Kept the release schema-neutral and preserved all NatureAI_Next formats and identifiers.

## 0.17.1 - Documentation & Release Hardening

- Added a packaged documentation center covering installation, quick start, core workflows, local AI resources, import/export, backup/recovery, troubleshooting, development, and release procedure.
- Added documentation contract coverage so required guides and branding boundaries remain release-gated.
- Clarified that Aperture is user-facing branding while NatureAI_Next package names, commands, libraries, databases, and resource formats remain unchanged.
- Kept the release schema-neutral and excluded Version 2 visual redesign, maps, and observation comparison work.

# 0.16.2

- Added a unified Species Dashboard with observation totals, timeline, evidence gallery, conservation, migration, habitats, source attribution, and a 12-month seasonal-presence display.
- Added “Why this suggestion?” to AI Review using visual rank/score, regional evidence, capture-month seasonality, ecological context, and personal history.
- NatureAI explicitly reports when feature-level visual explanations are unavailable instead of inventing traits.
- Ecological context remains informational and does not modify BioCLIP confidence or human confirmation.

## 0.16.1

- Added local conservation, seasonality, migration, and habitat context.
- Added migration 015 and ecological-context CSV import.
- Added ecological evidence to AI Review without altering visual confidence.

## 0.15.4 - Life Lists & Observation Statistics

- Added a Life Lists & Statistics workspace derived directly from human-confirmed observations.
- Shows totals for confirmed species, observations, evidence photographs, countries, and first observations in the current year.
- Groups the personal life list by installed taxonomy major group or kingdom.
- Shows the most frequently confirmed species.
- Statistics refresh immediately and require no migration or duplicated counter tables.

## 0.15.3.post1 - Observation Timeline Patch

- Fixed missing or non-refreshing entries in Observation History.
- Explicitly refreshes the timeline after species selection.
- Shows a visible entry count and a guaranteed usable timeline height.
- Selects the newest observation automatically and loads its evidence gallery immediately.
- Binds gallery selection to the timeline entry object rather than a fragile row index.
- Shows a clear empty state when no confirmed timeline entries exist.

## 0.15.3 - Observation Workspace and Species Dashboard

- Added a user-facing Observation History workspace.
- Added a species dashboard with confirmed-observation count, evidence-photo count, first/last dates, rank, and countries.
- Added a chronological observation timeline.
- Added a thumbnail evidence gallery for every photograph linked to an observation.
- Double-clicking evidence opens the existing Viewer.
- Added AI Review → Observation History navigation for the selected taxon.
- Added Accept & Next with Shift+Enter.
- Acceptance feedback now summarizes personal observation and photograph totals.
- Preserved stable observation identities, immutable originals, and the accepted Qt window lifecycle.

## 0.15.2 - Single-Photograph Taxonomy Resolution

- Added a Current photograph only review mode.
- Added atomic Accept & Reject Rest for one photograph.
- Added Reject Other Options after a normal acceptance.
- Kept accepted taxonomy, rejected alternatives, observation creation, audit events, and outbox events transactionally consistent.
- Preserved existing AI scores, provenance, and immutable originals.

## 0.15.1 - Observation Review Images and History

- Added a large cached photograph preview directly in AI Review.
- Added filename and capture-time context to prevent guesswork in large review queues.
- Added first/last observation dates and evidence-photo totals to personal observation context.
- Added first-observation confirmation feedback after acceptance.
- Preserved immutable originals and the accepted Qt window lifecycle.

## 0.15.0 - Observation Intelligence Phase 1

- Added stable multi-photo observation evidence links.
- Added personal observation-history queries and AI Review context.
- Added migration 014 and internal observation inspection.
- Preserved immutable originals and existing confirmation/reversal auditing.

## 0.14.6 - AI Workspace Consolidation

- Added Settings workspaces for AI Resources, Regional Knowledge, Health Check, and Preferences.
- Converted AI Resources into an in-window dashboard with BioCLIP, prompt, regional profile, quick setup, Activity Center, and advanced controls.
- Converted Regional Knowledge and Health Check into in-window pages.
- Routed the AI Review resource action and menu commands to the shared Settings pages.
- Kept compatibility menu shortcuts without duplicating implementation.

## 0.14.1 — Automatic Regional Knowledge Acquisition


## 0.14.3 - Activity Responsiveness Fix

- Removed the modal confirmation window shown after starting regional installation.
- Routed Activity Center progress, completion, and failure updates through queued Qt QObject slots on the main thread.
- Prevented worker-thread callbacks from mutating UI-facing activity state.
- Preserved the accepted regional acquisition, Activity Center, and Health Check workflows.

- Adds explicit one-click acquisition from the saved continent/country profile.
- Retrieves GBIF occurrence facets and Backbone Taxonomy records only after user confirmation.
- Builds, signs, verifies, installs, and activates the regional taxonomy package in the known NatureAI workspace.
- Generates and activates a BioCLIP prompt set and builds taxonomy embeddings when a compatible model is active.
- Reuses or creates the local signing identity automatically; no package or trusted-key browsing is required.
- Keeps photographs local and immutable.


## 0.13.8 — Release Packaging Integrity

- Corrected the Windows release archive so repository files are at the ZIP root instead of under an extra `src\` directory.
- Added a release-layout validation requirement for `pyproject.toml`, `scripts\install_windows.ps1`, and `src\natureai_next` at archive root.
- Preserves the BioCLIP runtime fix (`runtime: torch`) and rebuilds the existing local model package from the already-downloaded checkpoint.

## 0.13.2 - Local BioCLIP Generation

- Adds user-controlled **Generate selected** inference from the AI Review workspace.
- Uses the current Library selection and never scans or submits photographs without an explicit user action.
- Requires an active signed local model package, compatible active prompt set, and taxonomy text embeddings.
- Runs BioCLIP/OpenCLIP inference locally on the configured CUDA or CPU execution provider.
- Persists one auditable inference run plus ranked immutable suggestions with full model, prompt, preprocessing, provider, device, precision, and application provenance.
- Adds progress reporting, cancellation, per-asset failure isolation, and automatic review-queue refresh.
- Prevents application shutdown while generation is active, avoiding Qt worker teardown hazards.
- Does not download models, taxonomy, or prompt sets automatically and introduces no cloud inference.
- Existing libraries require no migration.

## [0.13.1] — QApplication Startup Fix

### Fixed
- Deferred AI Review QWidget construction until after QApplication creation.
- Added composition-order regression coverage.

## [0.13.0] — BioCLIP Review

### Added
- Production desktop composition for the existing AI Review subsystem.
- Active model, prompt-set, inference-run, and queue-status overview.
- Confidence filtering, review-state paging, provenance inspection, and keyboard review actions.
- Explicit empty states when no active local model or generated suggestions exist.

## 0.12.9 - Docked Core Panes

- Navigation is permanently docked on the left and Inspector on the right.
- Core panes can still be closed and reopened from the View menu, but cannot float as separate windows.
- Arbitrary Qt dock state is no longer persisted, preventing detached panes from returning after restart, upgrade, or display changes.
- Preserves the Windows-accepted 0.12.8 application lifecycle.

## 0.12.8 - Collection Reload Fix

- Fixed collection view reload/reset crash caused by passing QComboBox userData twice.
- Preserves the stable 0.12.7 Qt lifecycle rollback.

# Changelog

## 0.14.4 - Durable Background Tasks

- Blocks ordinary shutdown while background work is active.
- Adds explicit Keep running and Cancel tasks and exit choices.
- Persists Activity Center state and marks unfinished work as interrupted after restart.
- Adds Cancel and Resume / Retry controls.
- Adds safe regional acquisition checkpoints and cached GBIF taxonomy details.
- Reuses partial progress after network interruption, cancellation, or power loss.
- Keeps existing active resources until newly built resources reach verified installation.

## [0.12.7] — Stable Qt Lifecycle Rollback

- Restored the last Windows-confirmed crash-free Qt lifecycle from 0.12.2.
- Removed post-0.12.2 dock normalization and custom teardown changes.
- Retained Navigation/Inspector restore actions and collection assignment improvements.

## [0.12.7] — Navigation & Collection Workflow

### Fixed
- Restorable Navigation and Inspector docks through the View menu.
- Reset workspace layout action.
- Collections navigation now opens the live collection controls.
- Explicit manual-collection chooser for assigning selected photographs.


All notable NatureAI Next changes are recorded here. The project follows semantic versioning during pre-1.0 development.

## [0.12.1] — Smart Collections & Lock Recovery

### Added
- Safe stale-lock ownership detection and automatic same-host dead-process recovery.
- Smart collections backed by persisted structured queries.
- Collection rename, description editing, deletion, and manual member removal.

## [0.12.0] — Collections & Saved Searches

### Added
- Reusable saved searches backed by the versioned structured-query model.
- Manual collections with multi-selection membership and duplicate suppression.
- Live paged Library views for saved searches and collections.
- Asynchronous collection and saved-view persistence in the desktop workspace.

## [0.11.7] — Capture Date Filter Fix

### Fixed
- Capture-date From/To filters now match both authoritative UTC timestamps and EXIF local capture-date text.
- Date boundaries are inclusive and timezone is not fabricated when EXIF contains no zone.

## [0.11.6] — Structured Filters

### Added
- Asynchronous Library filters for rating, color, pick state, capture dates, dimensions, exact tags, and confirmed taxonomy names.
- Combined Quick Search and structured-filter query execution.
- Validated parameterized taxonomy-name matching across scientific, vernacular, and user-defined names.

## [0.11.5] — Quick Search

### Added
- Asynchronous Library quick search over filename, title, caption, notes, and tags.
- Debounced input, result counts, clear-to-library behavior, and keyset pagination.
- Stale search-result rejection and parameterized FTS/filename matching.

## [0.11.4] — Metadata

### Added
- Editable catalog title, caption, notes, rating, color label, pick state, and user tags.
- Dirty-state Save/Discard workflow with keyboard shortcuts.
- Atomic metadata and user-tag persistence with optimistic revision conflict handling.
- Architecture decision records for immutable originals and BioCLIP evidence separation.

## [0.11.3] — The Viewer

### Added
- Asynchronous full-image viewer.
- Wheel zoom, drag pan, Fit, 100%, double-click zoom toggle, and keyboard navigation.
- Stale preview-result rejection.
- Asynchronous Library inspector preview loading.

## [0.11.2] — Windows Productization

### Added
- Windows Installed Apps registration, repair, uninstall, and Start Menu integration.

## [0.11.1] — Windows Integration

### Added
- Machine-local launchers, shortcuts, default-library selection, and first-launch library picker.

## [0.11.0] — Persistent Thumbnails

### Added
- Persistent thumbnail and preview caches, placeholders, failure state, and retry.

## 0.13.3
- Added a local AI resources manager for signed model, prompt, and taxonomy packages.
- Added user-triggered taxonomy text embedding generation.
- Release the library lock from Qt `aboutToQuit`; library close is idempotent.

## 0.13.4
- Added `natureai-next-resources`, a reproducible offline AI resource packaging CLI.
- Added local Ed25519 signing-key generation and trusted-key export.
- Added signed model-package and taxonomy-package builders and validators.
- Added prompt-manifest validation and starter resource templates.

## 0.13.5

### Added
- Installer-managed current-user PATH entries for the NatureAI Conda environment and its Scripts directory.
- `natureai-next-resources workspace-init` for a reproducible local AI resource workspace with absolute model, taxonomy, prompt, signing, and package paths.
- Installation verification and smoke coverage for the resource CLI.

### Changed
- The uninstaller removes only the NatureAI environment PATH entries that the installer manages.

## 0.13.6

### Added
- Guided BioCLIP Quick Setup wizard for download/import, local signing, package installation, taxonomy CSV conversion, prompt generation, and embedding generation.
- Example taxonomy CSV template.

### Changed
- Manual resource-manifest editing is no longer required for the supported quick-setup workflow.

## 0.13.7

### Fixed
- Corrected BioCLIP Quick Setup and workspace manifests from unsupported `openclip` runtime to schema-compatible `torch`.
- Added early validation for unsupported model runtimes.

## 0.14.0
- Added per-library Regional Knowledge Profiles.
- Added continent/country/language setup and global fallback.
- Added regional occurrence evidence to AI Review.
- Added migration 013 and regional profile regression coverage.

## 0.14.2 - Activity Center and Regional Setup Polish
- Enlarged the Regional Knowledge setup dialog and added an explicit multi-minute first-install notice.
- Standardized the dialog actions as Cancel, Save, and Save & Install.
- Added View -> Activity Center for running, completed, and failed background work.
- Added a clickable status-bar activity indicator.
- Added Tools -> Health Check as a separate installation-status surface.
- Regional acquisition now continues after the setup dialog closes and reports live progress in Activity Center.

## 0.16.1
- Added ecological CSV import preview with matched and unmatched row counts.
- Added normalized scientific-name matching for authorship suffixes and hybrid x/× notation.
- Added accepted-name suggestions and unmatched-row CSV reports.


## 0.16.3
- Made the Species Dashboard interactive with country and collection filters.
- Added a personal-observation versus expected-season monthly summary.
- Added related observed taxa from the installed taxonomy.
- Kept map and observation-comparison work deferred to Version 2.

## 0.17.0

- Branded the user-facing desktop application as Aperture, powered by NatureAI_Next.
- Added editable Branding & Project settings backed by `branding.toml`.
- Added About Aperture and copyable Diagnostics workspaces.
- Replaced flat navigation with grouped expandable tree navigation.
- Applied the supplied Aperture icon to the Qt application and Windows integration.
- Renamed user-facing Windows shortcuts and Installed Apps display name while retaining all technical NatureAI_Next identifiers.
- Deferred house-style color coding to Version 2 using the approved Yourethos guide URL.

## 0.17.3 - 2026-07-14

- Added the offline trusted-folder Update Manager.
- Added Settings and Help menu update commands.
- Added update index compatibility and SHA-256 verification.
- Added automatic verified pre-update database backup and safe staging.
- Added a rollback-capable PowerShell staged installer.
- Added update service, UI contract, documentation, and corruption tests.

## 0.17.7 — Accessibility and UI polish

- Added keyboard-shortcut reference (`Ctrl+/`).
- Added conservative automatic accessible names and keyboard focus defaults.
- Improved explicit accessible names in the Health Center.
- Added accessibility and keyboard documentation and release contract tests.
- No database migration.

### RC1 packaging correction

- Corrected `Uninstall Aperture.cmd` PowerShell switch handling for package-only, environment-removal, and full-reset choices.

## 1.0.0 RC1 installer framework refresh

- Added guided storage-drive selection and automatic `Aperture-Library` creation.
- Added existing-library detection and reuse.
- Added unattended CMD installation parameters and an installation summary.
- Updated installation, quick-start, README, and packaged Help documentation.


## RC1 installer corrections

- Fixed Torch-build parameter forwarding and complete fixed-drive enumeration in the interactive installer.

## RC1 polish update

- automatic verified Miniconda bootstrap when Conda is absent;
- no separate system Python prerequisite;
- complete Maintenance Center shortcut cleanup during uninstall;
- startup milestone timing in structured logs;
- clearer Maintenance Center status and safety wording;
- synchronized installation and troubleshooting documentation.
- Fixed automatic Miniconda bootstrap failing with HTTP 404 when the optional `.sha256` sidecar was unavailable; verification now uses the official repository index.



### Conda channel isolation

The installer creates and maintains the Aperture environment with `--override-channels` and the `conda-forge` channel only. This avoids interactive Anaconda default-channel Terms of Service prompts during unattended installation.

- The Windows uninstaller now removes the `natureai-next` environment without initializing Conda channels, avoiding Anaconda Terms-of-Service prompts.
- Uninstall cleanup continues to remove the Aperture Maintenance Center desktop shortcut.

## RC1 Stabilization Sprint 2
- Corrected first-paint startup timing wiring so diagnostic records are actually written.
- Added process-exit fallback cleanup for held library locks.
- Added the latest startup timing and direct log access to Maintenance Center.

## 1.0.0 RC1 — Visible restore handoff correction

- Kept Maintenance Center visible during restore and added explicit stage progress.
- Created and verified emergency backups before closing Aperture.
- Added persistent restore history, foreign-key validation, failure reporting, and automatic relaunch.

- Fixed Windows Maintenance Center launcher resolution by using the active environment Scripts directory. Added pre-GUI bootstrap diagnostics in `%LOCALAPPDATA%\Aperture\Logs\maintenance-bootstrap.jsonl`.

## RC1 Maintenance window readiness fix

- Launch the Maintenance Center directly through the installed Python GUI runtime rather than relying on a generated console-script executable.
- Write `maintenance-launch.jsonl` before process creation so failed handoffs always leave evidence.
- Require a first-visible-window ready file before Aperture reports the Maintenance Center as opened.
- Keep Aperture open when the companion exits early or does not show within the readiness timeout.

### RC1 restore-button Windows handle fix
- Replaced the open `mkstemp` readiness placeholder with a unique non-created path.
- Prevents Windows file-handle deletion failures that made restore buttons appear unresponsive.
- Cleans stale `maintenance-ready-*.json*` handshake markers safely.

## RC1 restore handle release fix

- Explicitly closes SQLite cursors and connections before replacing a restored database on Windows.
- Adds bounded retry handling for short-lived antivirus or indexing locks.
- Records `validated-and-closed` and `replace-retry` stages in restore history.
- Keeps the previous database protected by rollback on failure.

## 1.0.0 RC1 — Final runtime freeze
- Normal Aperture shortcuts now use a detached, windowless `pythonw.exe` launch through Windows Script Host; only the Debug shortcut owns a console.
- Completed imports now open an exact “Latest import” view using the imported asset IDs, independent of the first catalog page, filters, or collections.
- Added `%LOCALAPPDATA%\Aperture\Logs\import-sync.jsonl` to record database/model synchronization after each import.

- Fixed the standard launcher reading the wrong configuration directory.
- Increased Library page size to 500 for deterministic RC1 catalog display.
- Added bounded thumbnail worker queue and corrected zero-import view behavior.

## 2.0.0 Development

### Observation context and geospatial provenance
- Added migration `v017_observation_context` for explicit observation time and location overrides.
- Added EXIF GPS normalization and capture-location linkage during import.
- Preserved asset-derived observation time and location as backward-compatible fallbacks.
- Added service support for user, import, plugin, and asset-metadata observation context sources.

## 2.0.0 development - M3 spatial and longitudinal foundation

- Added migration `v018_spatial_longitudinal`.
- Added monitoring projects, monitoring sites, observation series, and typed relationships between observations.
- Added map-ready spatial regions with validated bounding coordinates and JSON geometry payloads.
- Added map bookmarks for future offline-map views and saved geographic filters.
- Added additive links from observations to projects, sites, and longitudinal series.
- Added bounding-box repository queries for observations, assets, and monitoring sites.
- Preserved explicit observation location precedence with fallback to evidence-asset capture locations.

## 2.0.0 development - M3.2 optional subsystem database runtime

- Added a composition-root subsystem registry with stable dotted subsystem identifiers.
- Added lazy, idempotent database activation with independent migration histories.
- Added isolated subsystem health states that do not block core-library startup.
- Added the first `maps.offline` database and migration for offline map and geocoding package catalogs.
- Added map-package coverage lookup without opening or modifying the core library database.
- Added application-managed paths for subsystem databases and offline map package files.

## 2.0.0 development - M3.3 offline map package lifecycle

- Added a renderer-independent offline map provider contract.
- Added built-in validation providers for MBTiles and generic file-backed packages.
- Added independent package enable/disable lifecycle without changing subsystem availability.
- Added streaming SHA-256 package verification with separate declared and observed checksums.
- Added package verification metadata, file-size capture, status messages, and provider metadata.
- Added map package catalog migration version 2 and regression coverage for valid, missing, disabled, and re-enabled packages.

## Version 2 development — M3.5 Offline Map Workspace

- Added a lazily composed Map workspace to the Qt desktop shell.
- Added local OpenStreetMap-compatible MBTiles rendering with a lightweight 3×3 raster viewport.
- Added deterministic pan and zoom controls, observation and monitoring-site markers, map-bounds retrieval, and persistent attribution.
- Kept all tile access local; the workspace does not contact public OpenStreetMap tile servers.
- Isolated optional map failures from the core Aperture Library and remaining desktop workspaces.

### Aperture 2.0 M3.6 — Temporal Map and Movement Foundation

- Added schema v019 for temporal series semantics and verified movement segments.
- Added snapshot, cumulative, and trail-ready temporal queries.
- Added subject identity, tracking method, confidence, and connection policy.
- Added scientific distinction between observed distribution and confirmed movement.

## Version 2 M3.7 — Map Timelapse UI

- Added offline temporal playback controls to the Qt Map workspace.
- Added snapshot, cumulative, and trail display modes.
- Added day, week, month, season, and year playback steps.
- Added play/pause controls, editable time windows, series selection, and qualified trail rendering.
- Confirmed and unverified movement segments render distinctly; offline map attribution remains visible.

## Version 2 M4.1 — Taxonomy Reference Foundation

- Added the lazily activated `taxonomy.reference` subsystem database.
- Added independently migrated, versioned taxonomy datasets.
- Added sourced multilingual names, knowledge facts, distribution records, and external links.
- Added search and Knowledge Center profile projections without requiring the map subsystem or modifying Version 1 taxonomy records.

### Aperture 2.0 M4.2 — Knowledge Center synthesis foundation

- Added Knowledge Center application projections that combine shared taxonomy profiles with local observation histories at read time.
- Added search cards with preferred names, local observation/evidence counts, date range, and countries.
- Added resilient taxon pages for reference-only taxa and documented the no-cross-database-join rule in ADR-009.

### Version 2 M4.3 — Knowledge Center workspace and taxon linking

- Added a lazy Qt Knowledge Center workspace with scientific/common-name search and synthesized taxon pages.
- Added stable per-library local-to-reference taxon links in taxonomy subsystem migration v002.
- Added two-way navigation between Observation History and Knowledge Center pages.
- Preserved read-time synthesis and cross-database public-ID boundaries.

### Version 2 M4.4 — Authoritative taxonomy import

- Connected the signed taxonomy-package pipeline to the shared `taxonomy.reference` subsystem.
- Added atomic import of accepted Latin names, authorship, synonyms, multilingual common names, and regional occurrence records.
- Added dataset licence URL, redistribution permission, source URL, and package schema provenance.
- Added stable BioCLIP/model label mappings to authoritative reference taxa.
- Added licence enforcement preventing installation of packages not permitted for redistribution.

### Version 2 M4.5 — Taxonomy preferences and package lifecycle

- Added taxonomy subsystem migration v004.
- Added language and region preferences for common-name resolution.
- Added non-destructive taxonomy dataset enable/disable lifecycle and package inventory.
- Added Knowledge Center controls for preferred common-name language and region.

### Version 2 M5.1 — Asset analysis enrichment foundation

- Added core migration v020 for immutable, versioned asset analyses.
- Added normalized analysis taxon candidates, tags, and observation-promotion provenance.
- Added an application service and repository for asset-linked enrichment.
- Preserved the existing AI suggestion/review workflow with an optional parent-analysis link.
- Added ADR-015 and database/build rules for future AI and non-AI analysis engines.

## Aperture 2.0 M5.3 — Asset Removal and Enrichment Cleanup

- Added dependency previews for permanent asset deletion.
- Added full removal of asset-linked analyses, candidates, tags, suggestions, embeddings, derivatives, metadata, and file instances through database cascades.
- Added explicit observation policies for assets supporting authoritative knowledge.
- Added cancellation requests for active asset-specific jobs.
- Preserved reversible Trash behavior and legacy recoverable purge behavior.
- Added durable purge audit records that survive physical asset deletion.

## Aperture 2.0 M5.4 — Desktop Asset Removal Workflow

- Added bulk **Move to Trash** and **Permanently delete** actions to the Library workspace.
- Added dependency summaries covering managed files, derivatives, AI analyses, suggestions, observations, promotions, and active jobs.
- Added explicit user choices for retaining or deleting observations when evidence photographs are removed.
- Kept permanent deletion behind the reversible Trash boundary and moved destructive cleanup off the Qt UI thread.
- Wired the validated M5.3 removal service into production desktop composition.

### Version 2 M5.5 — Knowledge Engine Core

- Added the lazy capability registry and explicit capability dependencies.
- Added the Knowledge Engine cross-domain orchestration boundary.
- Added taxon evidence dossiers, spatial observation queries, and asset-enrichment dossiers.
- Added read-only asset analysis candidate projections.

### Version 2 M5.6 — Knowledge Engine Workspace Integration

- Routed Knowledge Center evidence summaries through `KnowledgeEngine` taxon dossiers.
- Added support for distinct shared-reference and local-library taxon identities during synthesis.
- Routed offline-map observation overlays through `KnowledgeEngine` spatial projections.
- Preserved map package/tile ownership in the offline map application service and lazy optional-database activation.
- Added regression coverage for workspace-level Knowledge Engine boundaries.

### Version 2 M5.7 — Knowledge Engine observation and AI integration

- Routed Observation History species, history, and related-taxon projections through the Knowledge Engine.
- Routed AI Review personal observation context through the Knowledge Engine.
- Added per-photo enrichment-history summaries to AI Review.
- Preserved existing review, promotion, observation, and lazy subsystem behavior.

### Version 2 M6.0 — Workflow, Event, and Retention Foundation

- Added versioned workflow definitions over the existing durable job engine.
- Added stable step dependencies, workflow run idempotency, and optional-step declarations.
- Added typed in-process domain-event dispatch with subscriber failure isolation.
- Added bounded cleanup for terminal job history, dispatched outbox events, and stale temporary files.
- Added dry-run cleanup reporting and per-job-type minimum-history preservation.
- Recorded ADR-021, ADR-022, and ADR-023.

### Version 2 M6.1 — Lean Embedded Runtime Constraints

- Recorded ADR-024 limiting Aperture Version 2 runtime infrastructure to the existing embedded desktop stack.
- Added an explicit embedded execution mode to workflow steps.
- Restricted workflow resource classes to local I/O, CPU, and GPU execution.
- Persisted the embedded execution mode in durable job payloads for auditability.
- Added regression coverage preventing accidental introduction of remote or service-backed workflow execution.

### Version 2 M6.2 — Lean cleanup visibility

- Added non-destructive cleanup previews with job, event, file, and byte estimates.
- Added conservative orphan detection limited to Aperture-owned temporary roots.
- Added empty temporary-directory pruning after successful file cleanup.
- Added Maintenance Center controls for previewing and running bounded cleanup.
- Added reclaimed-space reporting without introducing background services or new runtime technologies.

### Version 2 M6.3 — Existing Maintenance Center integration

- Extended the established library health service with background-work, optional-subsystem, capability-registry, and asset-analysis consistency checks.
- Added recent durable-job visibility to the existing Maintenance Center.
- Added Pause, Continue, and Stop controls using the existing SQLite job state machine.
- Preserved the existing backup, restore, health, recovery, and cleanup ownership; no parallel monitor, controller, daemon, or runtime service was introduced.
- Added ADR-026 defining the Maintenance Center as the sole operational surface for Version 2 health and work control.

### Version 2 M6.4 — Maintenance storage and package inventory
- Added read-only storage visibility to the existing Maintenance Center.
- Added installed offline-map and taxonomy package inventory without lazy-subsystem activation.
- Distinguished authoritative library storage from derived or managed data.