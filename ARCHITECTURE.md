# NatureAI Next — Architecture

**Status:** Approved design baseline  
**Document version:** 0.1

## 1. Architectural goals

NatureAI Next uses a modular monolith with strict internal boundaries. This provides desktop deployment simplicity while preserving independently testable components and stable extension points.

The architecture prioritizes:

- complete offline operation;
- responsive desktop behavior;
- deterministic persistence;
- recoverable long-running work;
- replaceable AI backends;
- plugin extensibility;
- scalability to at least 100,000 assets without redesign;
- low coupling to PySide6, SQLite, Torch, and specific model libraries.

## 2. Architectural style

The codebase combines hexagonal architecture, domain-driven boundaries, and event-driven coordination inside one process.

### 2.1 Dependency rule

Dependencies point inward:

```text
UI / CLI / Plugins
        |
Application services and ports
        |
Domain model and policies
        ^
Infrastructure adapters: SQLite, filesystem, imaging, Torch, ONNX, update transport
```

The domain layer imports no PySide6, SQLite, Torch, ONNX Runtime, filesystem UI, or plugin implementation modules.

### 2.2 Modular monolith

The release is a single desktop product and normally one process. Internal modules communicate through explicit Python interfaces and immutable command/result objects. Separate worker processes may be used selectively for crash isolation or libraries that cannot safely share a process, but process boundaries are implementation adapters rather than application contracts.

## 3. Repository layout

```text
natureai-next/
├── PROJECT_SPEC.md
├── ARCHITECTURE.md
├── DATABASE.md
├── AI.md
├── GUI.md
├── PLUGIN_API.md
├── CONFIGURATION.md
├── ROADMAP.md
├── CODING_STANDARD.md
├── pyproject.toml
├── environment/
├── packaging/
├── resources/
├── scripts/
├── src/natureai_next/
│   ├── bootstrap/
│   ├── domain/
│   ├── application/
│   ├── ports/
│   ├── infrastructure/
│   │   ├── database/
│   │   ├── filesystem/
│   │   ├── imaging/
│   │   ├── metadata/
│   │   ├── ai/
│   │   ├── indexing/
│   │   ├── updates/
│   │   └── diagnostics/
│   ├── jobs/
│   ├── plugins/
│   ├── ui/
│   └── shared/
└── tests/
    ├── unit/
    ├── contract/
    ├── integration/
    ├── migration/
    ├── performance/
    └── fixtures/
```

Package boundaries are enforced by import-lint rules and tests.

## 4. Major modules

### 4.1 `bootstrap`

The composition root:

- resolves application and library paths;
- loads configuration;
- initializes logging and diagnostics;
- opens and validates a library;
- runs database migrations;
- discovers compatible plugins;
- creates infrastructure adapters;
- wires application services;
- starts job schedulers;
- launches the PySide6 shell.

No other module constructs the complete object graph.

### 4.2 `domain`

Contains business concepts and policies:

- asset and file identity;
- observation and taxonomy references;
- user metadata precedence;
- collection membership;
- import conflict decisions;
- job state rules;
- suggestion review states;
- value objects for hashes, coordinates, timestamps, confidence scores, and regions.

Domain objects do not perform persistence or UI work.

### 4.3 `application`

Contains use cases and orchestration:

- import planning and execution;
- metadata editing;
- search;
- collection management;
- taxonomy update application;
- AI analysis submission and review;
- export;
- backup and validation;
- settings changes;
- plugin command registration.

Each use case has typed input and output models. Application services own transaction boundaries through a unit-of-work port.

### 4.4 `ports`

Defines Protocols or abstract interfaces for:

- repositories and unit of work;
- file storage and hashing;
- metadata readers;
- image decoders and thumbnail renderers;
- search and vector indexes;
- model registry and inference engines;
- taxonomy package source;
- update transport;
- clock, UUID generation, and diagnostics;
- UI-facing task dispatch.

Ports are stable contracts. Infrastructure and plugins implement ports.

### 4.5 `infrastructure`

Adapters for external technologies:

- SQLite repositories and migrations;
- Windows and portable filesystem handling;
- ExifTool or library-based metadata extraction adapter;
- image decoding and thumbnail generation;
- Torch/CUDA and ONNX inference;
- persisted vector index;
- package download and signature validation;
- structured logging and crash reports.

### 4.6 `jobs`

Persistent background execution framework:

- durable job records;
- bounded worker pools;
- resource classes;
- cancellation tokens;
- progress snapshots;
- retry policy;
- startup recovery;
- dependency chains;
- user notifications.

### 4.7 `plugins`

Plugin discovery, validation, capability registration, lifecycle, and fault containment. The core does not import plugin packages directly.

### 4.8 `ui`

PySide6 presentation layer:

- application shell;
- workspaces;
- models and view models;
- dialogs and panels;
- command routing;
- selection and navigation state;
- UI-specific formatting.

Widgets never issue SQL or call Torch directly.

### 4.9 `shared`

Small dependency-free utilities used by multiple inner modules, such as result types, immutable pagination tokens, error identifiers, and serialization helpers. It must not become a miscellaneous dumping ground.

## 5. Runtime topology

### 5.1 Main process

The main process owns:

- Qt event loop;
- application service graph;
- database connection factory;
- job scheduler;
- plugin manager;
- UI state.

### 5.2 Worker execution

Three execution classes are defined:

1. **I/O workers** for scanning, hashing, file copies, metadata extraction, and export.
2. **CPU workers** for image decoding, thumbnail generation, and CPU-bound transforms.
3. **AI worker** for serialized or carefully batched access to GPU models.

The scheduler prevents unbounded concurrency. Default limits are configuration-driven and hardware-aware.

A process-based worker adapter may be used for unsafe native libraries or memory isolation. It must communicate using versioned messages and may not access UI objects.

### 5.3 Database access

- Connections are never shared across threads.
- Reads may occur concurrently using separate read connections in WAL mode.
- Writes are serialized through short transactions controlled by application services and the job framework.
- Database callbacks never update widgets directly; results return through queued Qt signals or the UI dispatcher.

## 6. Application communication

### 6.1 Commands and queries

User actions become application commands or queries. Examples:

- `ImportFilesCommand`
- `UpdateAssetMetadataCommand`
- `SubmitAnalysisJobCommand`
- `ReviewSuggestionsCommand`
- `SearchAssetsQuery`

Command objects are immutable and validation occurs at the boundary.

### 6.2 Domain events

Domain events represent committed facts, such as:

- `AssetsImported`
- `AssetMetadataChanged`
- `SuggestionsReviewed`
- `TaxonomyActivated`
- `ModelInstalled`

Events are written to an outbox table in the same transaction as state changes. An in-process dispatcher consumes the outbox to invalidate caches, update indexes, refresh views, and invoke plugin subscribers. Handlers must be idempotent.

The outbox is not intended as an external event-sourcing system. Current relational state remains authoritative.

### 6.3 Error model

Expected failures use typed application errors with stable codes and user-safe messages. Unexpected exceptions are logged with correlation identifiers and converted at boundaries.

Errors carry:

- stable error code;
- human-readable summary;
- optional technical detail for logs;
- retryability;
- affected entity identifiers;
- remediation action where known.

## 7. Library layout

A library directory contains:

```text
My NatureAI Library/
├── library.sqlite3
├── originals/            # only when managed storage is used
├── sidecars/             # optional application-owned sidecars
├── derivatives/
│   ├── thumbnails/
│   └── previews/
├── indexes/
│   ├── vectors/
│   └── search/
├── models/               # optional library-pinned models
├── taxonomy/
├── backups/
├── logs/
└── library.json
```

`library.json` contains non-secret bootstrap metadata such as library UUID and minimum application compatibility. It is not a substitute for relational metadata.

Global application data, downloaded shared models, global plugins, and user preferences reside outside the library as defined in `CONFIGURATION.md`.

## 8. Storage modes

### 8.1 Managed originals

Files are copied or moved into a content-organized library directory. The database records the original import path and current managed path.

### 8.2 Referenced originals

Files remain at user-controlled paths. NatureAI tracks identity and availability. Referenced folders may be offline or moved, and relinking is supported.

### 8.3 Hybrid libraries

Managed and referenced assets may coexist. Storage mode is a property of each file instance, not a library-wide irreversible choice.

## 9. Job architecture

### 9.1 Job states

`queued`, `blocked`, `running`, `pausing`, `paused`, `cancelling`, `cancelled`, `succeeded`, `failed`, `interrupted`.

State transitions are validated centrally.

### 9.2 Job requirements

Each job type defines:

- versioned payload schema;
- resource class;
- idempotency key strategy;
- progress model;
- retry policy;
- cancellation checkpoints;
- recovery behavior;
- cleanup behavior;
- result schema.

### 9.3 Resource coordination

The scheduler controls:

- maximum I/O concurrency;
- maximum CPU concurrency;
- one active model-loading/inference coordinator per GPU device by default;
- VRAM budget;
- foreground versus background priority;
- pause-on-battery behavior if enabled.

## 10. Caching

Caches include:

- thumbnails and previews;
- decoded image memory cache;
- query result pages;
- taxonomy lookup cache;
- loaded model cache;
- vector search index.

All caches have:

- explicit ownership;
- bounded size;
- versioned keys;
- deterministic invalidation;
- rebuild behavior.

No cache is the sole copy of user data.

## 11. Update architecture

Three independent update channels exist:

1. application updates;
2. model packages;
3. taxonomy packages.

Update workflows are explicit user actions or configured checks. Packages are downloaded to staging, verified, then atomically activated. Failed activation leaves the prior version intact.

The network adapter is inaccessible to ordinary application services. Only update services receive it through dependency injection.

## 12. Plugin integration

Plugins register capabilities through `PLUGIN_API.md`. Core extension points include:

- metadata readers;
- import validators;
- AI model providers;
- taxonomy providers;
- exporters;
- commands and panels;
- background job types;
- event subscribers.

Plugins cannot replace core transaction management, database migration ownership, security policy, or original-file immutability.

## 13. Observability

Offline observability includes:

- structured rotating logs;
- job history;
- performance counters;
- database integrity reports;
- model and provider diagnostics;
- optional local diagnostic bundle export.

No telemetry is transmitted automatically.

## 14. Testing architecture

- Unit tests target domain policies and application services using in-memory fakes.
- Contract tests ensure every adapter and plugin implementation satisfies its port.
- Migration tests upgrade representative historical databases.
- Integration tests use temporary filesystem libraries and real SQLite.
- GUI tests cover view models and selected Qt workflows.
- Performance tests use synthetic 10k, 100k, and 1M metadata catalogs.
- AI regression tests use a versioned local image fixture set and tolerance-based outputs.

Full end-to-end integration testing is intentionally concentrated late in the roadmap, but compilation, static checks, unit tests, contract tests, and focused integration tests run continuously.

## 15. Architectural decisions

### AD-001: Modular monolith

Chosen over microservices because offline desktop deployment, transactions, packaging, and debugging are simpler. Internal boundaries preserve future extraction options.

### AD-002: SQLite authority

SQLite is the authoritative metadata store. External indexes and derivatives are rebuildable caches.

### AD-003: Persistent job system

Long-running work is represented durably to support cancellation, recovery, and predictable UI behavior.

### AD-004: In-process plugins with trust warning

Initial plugins run in-process for capability and performance. Compatibility validation and fault isolation are mandatory; security sandboxing is not claimed.

### AD-005: Outbox-based internal events

Events are persisted atomically with state changes to prevent missed cache/index updates after crashes.

### AD-006: Application-layer transaction ownership

Use cases own transaction boundaries. Repositories do not commit independently.
