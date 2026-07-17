# Aperture 2.0.0 RC2.2 release notes

RC2.2 hardens long-running resource processing and addresses the single-core render bottleneck observed during field testing.

## Implemented

- Map tile rendering now uses a bounded NatureAI Nest process pool. Tile generation runs across multiple CPU cores while MBTiles publication remains serialized in the parent process.
- Render worker count adapts to logical processor count and can be overridden with `NATUREAI_RENDER_WORKERS`.
- Map processing uses an adaptive workspace policy. Verified archives are held in memory when the available-memory budget permits; otherwise processing uses a hybrid disk workspace.
- MBTiles output is durably checkpointed every 32 completed tiles and on completion.
- The Activity Center now treats cleanup as history cleanup only. Open, interrupted, failed, cancelled, queued, and running tasks remain available for resume/retry.
- The Activity Center displays an Open Tasks count and explains that resumable work survives history cleanup.
- Durable job pools now size themselves from available logical processors and identify the engine as `NatureAI_Nest`.

## Safety model

Parallel workers generate independent tile payloads. Only the parent process writes to the MBTiles database, preserving a single atomic publication path and avoiding concurrent SQLite writers.

This is a release-candidate build for user testing. It is not release-approved until field validation is complete.
