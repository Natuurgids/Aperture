# Aperture 1.0.0 RC1 — Documentation Synchronization

This final RC1 documentation build preserves the validated runtime and synchronizes source documentation, packaged offline Help, release notes, backlog, and the product roadmap.

## Documentation additions

- Added **Roadmap & Future Releases** to the Help menu and searchable offline Help.
- Added the Version 1 project handover document for the next development conversation.
- Documented the approved Version 2 Taxonomy & Knowledge Center, content hashing, exact duplicates, import provenance, source disk/card identity, and dynamic AI orchestration.
- Documented Version 3 advanced analysis and collaboration direction.
- Assigned offline maps, calendar, biological moments, revisit planning, photo-completeness suggestions, and time-lapse guidance to Version 4.
- Assigned semantic and natural-language discovery, including searches such as “flying bird,” to Version 5.
- Synchronized the source documentation and bundled offline Help.
- No runtime, database schema, library format, or AI-processing change is introduced.


## RC1 launcher and import-view correction

- Replaced the fragile WScript/PowerShell normal launcher with a direct `pythonw.exe` `.pyw` launcher.
- Added an explicit Library View selector with **All Library** and **Latest import** options.
- Import completion still shows the exact imported items, while users can return to the complete catalog without resetting filters manually.
# Aperture 1.0.0 RC1 — Stabilization Polish

This non-functional hardening increment adds startup timing diagnostics, defers Maintenance Center history loading until after first paint, improves maintenance progress feedback, and completes startup and taxonomy documentation. It does not change database schemas, library formats, AI processing, taxonomy data, or observation workflows.

- Fixed clean installation of a newly selected storage drive: the library is now created before launcher registration validates it.
# Aperture 1.0.0 RC1 — Library Compatibility & Recovery Hardening

Aperture 1.0.0 RC1 is a feature-frozen Version 1 release candidate focused on compatibility, recovery, and production readiness.

## RC1 installer wrapper correction

- `Install Aperture.cmd` now omits `-InstallerArguments` when no command-line options were supplied.
- Interactive installation no longer fails with “Missing an argument for parameter InstallerArguments”.
- Unattended command-line forwarding remains unchanged when one or more options are supplied.

## Library manifest compatibility

- Accepts UTF-8 `library.json` files with or without a byte-order mark (BOM).
- Normalizes recognized legacy fields:
  - `format` to `format_version`
  - `library_name` to `display_name`
  - `created_at_utc` to `created_at_us`
  - `database_file` to `database_filename`
- Removes legacy backup metadata fields `sha256` and `size_bytes` from the operational library manifest.
- Preserves the original file as `library.json.before-normalization` before rewriting.
- Writes the current canonical manifest atomically as UTF-8 without BOM.
- Reports all unsupported fields together instead of raising a raw dataclass `TypeError` one field at a time.
- Reports malformed JSON with a clear compatibility error.

## Compatibility

- No database migration is introduced by this release.
- Current schema version remains unchanged.
- Internal `NatureAI_Next` identifiers and resource formats remain unchanged.
- Version 2 UI features remain deferred.

## RC1 packaging correction

- Fixed the root `Uninstall Aperture.cmd` launcher so non-interactive uninstall choices pass PowerShell's `-Confirm:$false` switch through the command parser correctly.
- Full reset continues to preserve Aperture libraries, photographs, backups, and exports.

## Installer and deployment framework

- `Install Aperture.cmd` now asks users to choose a storage drive instead of typing a library path.
- Explains that the Aperture Library contains the SQLite database, metadata, thumbnails, backups, and managed photographs and grows over time.
- Recommends a writable fixed drive using existing-library presence and available free space.
- Creates `<drive>:\Aperture-Library` automatically.
- Detects and offers to reuse an existing valid Aperture Library.
- Shows an installation summary before making changes.
- Supports unattended `/silent`, `/drive`, `/profile`, `/torch`, `/library`, `/useexisting`, `/createnew`, `/repair`, and `/skippreflight` options.
- Initializes a new library with the canonical `natureai-next-admin library-create` service after installation.


## RC1 installer corrections

- Corrected explicit named-parameter forwarding to the Windows installer and now lists every ready fixed drive, marking drives that require elevated write permission.

## RC1 polish update

- automatic verified Miniconda bootstrap when Conda is absent;
- no separate system Python prerequisite;
- complete Maintenance Center shortcut cleanup during uninstall;
- startup milestone timing in structured logs;
- clearer Maintenance Center status and safety wording;
- synchronized installation and troubleshooting documentation.
- Fixed clean-install Miniconda bootstrap verification: the installer now reads the published SHA-256 from Anaconda's official repository index instead of requesting a non-existent `.sha256` sidecar.



### Conda channel isolation

The installer creates and maintains the Aperture environment with `--override-channels` and the `conda-forge` channel only. This avoids interactive Anaconda default-channel Terms of Service prompts during unattended installation.

- The Windows uninstaller now removes the `natureai-next` environment without initializing Conda channels, avoiding Anaconda Terms-of-Service prompts.
- Uninstall cleanup continues to remove the Aperture Maintenance Center desktop shortcut.

## Stabilization Sprint 2
This RC1 refresh corrects startup timing diagnostics, adds a safe process-exit fallback for library-lock release, and surfaces the latest first-window timing in Aperture Maintenance Center. No database migration or workflow change is introduced.

## RC1 visible restore handoff correction

- Aperture Maintenance Center remains visible throughout restore operations.
- **Back Up and Restore** creates and verifies the emergency database backup before Aperture is asked to close.
- Restore progress now reports backup creation, application shutdown, lock release, database replacement, validation, and relaunch.
- Restore validates both SQLite integrity and foreign-key consistency.
- Restore outcomes are recorded in `%LOCALAPPDATA%\Aperture\Logs\restore-history.jsonl`.
- No database migration or resource-format change is introduced.

- Fixed Windows Maintenance Center launcher resolution by using the active environment Scripts directory. Added pre-GUI bootstrap diagnostics in `%LOCALAPPDATA%\Aperture\Logs\maintenance-bootstrap.jsonl`.

## Maintenance Center startup reliability

Restore and backup handoff now starts the Maintenance Center through the active environment's `pythonw.exe` module entry point. Aperture writes a launch log before spawning the companion and waits for a first-window readiness acknowledgement. If startup fails, Aperture remains open and directs the user to `maintenance-launch.jsonl` and `maintenance-bootstrap.jsonl`.

## Restore button responsiveness correction
A Windows-specific open temporary-file handle prevented the Maintenance Center handoff from starting and left empty readiness JSON markers. Restore actions now use an atomic acknowledgement path that is not created by the parent process, and stale handshake markers are cleaned safely.

## RC1 restore handle release fix

- Explicitly closes SQLite cursors and connections before replacing a restored database on Windows.
- Adds bounded retry handling for short-lived antivirus or indexing locks.
- Records `validated-and-closed` and `replace-retry` stages in restore history.
- Keeps the previous database protected by rollback on failure.

### Final runtime freeze
Normal Aperture startup is now independent of PowerShell and console-window lifetime. After import, Aperture opens a Latest import view containing the exact imported assets and records synchronization diagnostics in `import-sync.jsonl`.

## RC1 launcher, full-library, and thumbnail queue correction

- The normal windowless launcher reads the same saved library configuration as the Debug and Select Library launchers.
- All Library loads up to 500 assets per page, covering the validated RC1 library sizes without hiding assets behind an unnoticed pagination state.
- Zero-import results no longer create an empty Latest import view.
- Thumbnail rendering is bounded to eight concurrent workers, preventing intermittent failures caused by launching one thread per asset. Refresh re-queries the database and requeues thumbnails for every displayed asset.
