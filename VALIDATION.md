# Aperture 1.0.0 Validation

## Automated validation

- Library manifest compatibility tests cover UTF-8 with and without BOM.
- Legacy field normalization is covered for `format`, `library_name`, `created_at_utc`, and `database_file`.
- Legacy checksum metadata removal is covered for `sha256` and `size_bytes`.
- Unsupported fields are reported together.
- Malformed JSON produces a clear validation error.
- Library lifecycle regression tests pass.
- Full unit, contract, migration, and integration test suite passes.

## Release boundary

- No database migration.
- Internal `NatureAI_Next` names and resource formats remain unchanged.
- Version 2 features remain deferred.

## RC1 polish update

- automatic verified Miniconda bootstrap when Conda is absent;
- no separate system Python prerequisite;
- complete Maintenance Center shortcut cleanup during uninstall;
- startup milestone timing in structured logs;
- clearer Maintenance Center status and safety wording;
- synchronized installation and troubleshooting documentation.
- Miniconda bootstrap contract verifies official repository-index checksum discovery and no longer depends on a `.sha256` sidecar.

