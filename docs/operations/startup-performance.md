# Startup performance diagnostics

Aperture records low-overhead startup milestones in `%LOCALAPPDATA%\Aperture\Logs\startup-timing.jsonl`. Each line contains one launch with elapsed times for process start, foundation setup, library opening, desktop service composition, and first visible main-window paint.

Use this file when comparing cold and warm starts. A single slow launch is not necessarily a regression because antivirus scanning, Windows disk caching, GPU initialization, and first-time Python bytecode creation can affect results. Compare at least five cold launches after a restart and five warm launches.

The timing log contains the library display name and elapsed timings. It does not contain photographs, observation content, or database records.

Full database integrity checks, update scans, and maintenance history refreshes are intentionally kept outside the first-paint path. Run integrity checks from the Health Center when needed.
