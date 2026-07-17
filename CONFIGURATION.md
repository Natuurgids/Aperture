# NatureAI Next — Configuration

**Status:** Approved design baseline  
**Document version:** 0.1

## 1. Configuration principles

- Offline-first defaults.
- Explicit scope: application, user, library, session, or plugin.
- Typed validation at startup and before persistence.
- Human-readable files for supported settings.
- No secrets in ordinary configuration.
- Safe defaults on missing or invalid optional values.
- Unknown settings preserved where possible for forward compatibility.
- Configuration changes never silently alter original files or confirmed metadata.

## 2. Windows paths

Default global locations use Windows known folders rather than hard-coded drive letters.

Conceptual layout:

```text
%LOCALAPPDATA%/NatureAI Next/
├── app-config.toml
├── state/
├── cache/
├── logs/
├── models/
├── taxonomy-packages/
├── updates/
└── plugins/

%APPDATA%/NatureAI Next/
└── user-preferences.toml
```

Exact paths are resolved through a platform-path service. Portable mode may be supported later only through an explicit launch option and must not become the default.

Library-specific configuration is stored in the library database, except minimal `library.json` bootstrap metadata described in `ARCHITECTURE.md`.

## 3. Configuration sources and precedence

Lowest to highest precedence:

1. built-in defaults;
2. installed application policy file;
3. user configuration;
4. library configuration;
5. environment variables for development/automation-approved keys;
6. command-line options;
7. session-only overrides.

A higher scope may override a setting only when the setting declares that scope as valid.

## 4. File formats

- TOML for application and user configuration.
- JSON only for machine-generated manifests and versioned payloads.
- SQLite for library settings that require transactions, auditing, or relational references.

Configuration files contain a schema version. Writes are atomic: write temporary file, flush, validate, replace.

## 5. Typed settings model

Each setting defines:

- canonical dotted key;
- type;
- default;
- allowed scopes;
- validation constraints;
- restart requirement;
- sensitivity classification;
- UI metadata;
- migration behavior.

Production code accesses configuration through a typed settings service, never by parsing TOML ad hoc.

## 6. Core setting groups

### 6.1 Application

Examples:

- interface language;
- theme (`system`, `light`, `dark`);
- update-check policy;
- recent libraries limit;
- log level and retention;
- crash recovery behavior;
- developer mode.

### 6.2 Library

- display name and locale;
- default import storage mode;
- managed originals organization template;
- duplicate handling default;
- default timezone policy;
- active taxonomy releases;
- default country/region context;
- audit retention policy;
- backup destination and schedule metadata, where supported.

### 6.3 Performance

- I/O worker count;
- CPU worker count;
- thumbnail memory cache size;
- thumbnail disk cache size;
- database cache size;
- job batch sizes;
- background priority;
- battery behavior;
- vector search candidate count.

Defaults are derived from hardware within documented upper bounds. User values are validated to prevent resource exhaustion.

### 6.4 AI

- preferred execution provider;
- GPU device;
- VRAM budget or reservation;
- default model variant;
- model idle unload period;
- inference batch policy;
- precision preference where supported;
- automatic embedding policy on import;
- suggestion thresholds by calibrated task identity;
- model and package storage locations.

### 6.5 Import

- copy/move/reference default;
- file format inclusion;
- sidecar handling;
- exact duplicate policy;
- preliminary hash policy;
- post-import AI queue policy;
- preserve folder hierarchy option;
- filename normalization constraints.

### 6.6 Export

- default destination behavior;
- naming template;
- collision policy;
- metadata sidecar formats;
- derivative quality settings;
- include provenance option.

### 6.7 Plugins

- enabled plugins;
- capability grants;
- plugin-specific validated settings;
- trusted publisher policy;
- development plugin paths when developer mode is active.

## 7. Environment variables

Environment variables are primarily for development, CI, packaging, and diagnostics. Supported variables use the `NATUREAI_NEXT_` prefix.

Examples of permitted categories:

- configuration root override;
- log level;
- test library path;
- disable GPU for diagnostics;
- deterministic test mode;
- developer plugin path.

Environment variables must not be the only way to configure a user-facing production feature.

## 8. Command-line options

The desktop executable supports a small stable set:

- open a specified library;
- import specified paths into an opened library;
- safe mode without third-party plugins;
- diagnostics mode;
- configuration root override for testing;
- no-update-check;
- log-level override.

Administrative maintenance commands may exist in a separate CLI entry point while reusing application services.

## 9. Secrets

The baseline application requires no secrets. If a future approved update channel requires credentials, they must be stored using Windows Credential Manager through a secrets port. Secret values are represented in configuration only by opaque references.

Secrets must never appear in logs, diagnostics bundles, job payloads, or plugin settings exports.

## 10. Updates configuration

Update checks are explicit and independently configurable for:

- application;
- models;
- taxonomy.

Each channel defines:

- enabled check policy;
- source channel (`stable`, optionally `preview`);
- last check timestamp;
- downloaded package retention;
- trusted signing identities;
- proxy behavior if later approved.

No update check is required for application startup or normal offline use.

## 11. Validation and recovery

On invalid configuration:

- required invalid values prevent the affected subsystem from starting;
- optional invalid values fall back to safe defaults with a visible diagnostic;
- the original file is preserved;
- automatic migrations create a backup copy;
- errors identify key, source, expected type, and remediation.

The application provides “reset this setting” and “reset this section” operations. Full reset does not delete libraries, models, taxonomies, or plugins.

## 12. Configuration migrations

Configuration schema migrations are versioned and tested. Migrations:

- preserve unknown keys where possible;
- never silently discard user paths;
- are idempotent;
- write atomically;
- record the preceding version in a backup.

## 13. Diagnostics and export

A configuration report may be exported with:

- effective values;
- source of each value;
- validation state;
- restart requirements;
- secrets redacted;
- user paths optionally anonymized.

## 14. Configuration decisions

### CF-001: TOML for human-managed global settings

Readable, typed, and suitable for desktop configuration.

### CF-002: Library settings in SQLite

Library settings require transactions, auditing, and portability with the catalog.

### CF-003: Typed access only

Prevents inconsistent parsing and undocumented keys.

### CF-004: No secrets in plaintext

Future credentials use an operating-system-backed secret store.

### CF-005: Network checks optional

Offline use has no dependency on update availability.

## Aperture branding

The desktop application creates `branding.toml` beside its session settings. The `[branding]` keys are `application_name`, `powered_by`, `organization_name`, `project_website`, `donation_label`, and `donation_url`. These values are intentionally editable for open-source forks. The donation action is hidden when `donation_url` is blank; URLs must use HTTP or HTTPS. NatureAI_Next technical identifiers are not configurable branding.

## Shared launcher configuration

Aperture and the standalone Maintenance Center use the same per-user launcher configuration at `%APPDATA%\NatureAI\NatureAI Next\launcher.json`. The file records the last selected Aperture Library. Settings can change this selection. Maintenance Center uses it automatically and presents a graphical library picker when the saved path is unavailable. The command-line `--library` option remains supported.

## Offline map source configuration

Normal users select continent, country, and downloadable regional packages in **Maintenance Center → Offline maps**. An approved HTTPS catalog URL or local catalog JSON file is configured only under **Advanced map source**. The map renderer accepts verified raster MBTiles packages and never bulk-downloads from public OpenStreetMap tile servers.


## M6.9.6 R3 resource navigation

The desktop navigation contains a **Resources** group for AI Resources, Regional Knowledge, Offline Maps, and Taxonomy Resources. These are separate capability-specific interfaces sharing only download verification, storage, and offline-state infrastructure. Offline Maps uses geographic package selection; Taxonomy Resources uses regional or authoritative taxonomy acquisition. Installed resources and cached catalogs remain visible offline.
