# Troubleshooting

## Aperture does not start

Run `scripts/verify_install.bat`, then use the debug launcher. Confirm the Python 3.11 environment and PySide6 installation. Use the repair script if shortcuts or Windows registration are missing.

## Library is locked

Confirm no other Aperture process is using the library. Stale same-host locks are recovered only when the owning process is no longer alive. Do not delete lock files while another process may be active.

## Thumbnails are missing

Keep originals or referenced storage available, then allow the rebuildable thumbnail cache to regenerate. Missing referenced files must be relinked.

## AI is unavailable

Open Health Check and AI Resources. Verify active model, prompt set, taxonomy resources, provider compatibility, and available memory. Switch to CPU when CUDA validation fails.

## Getting support

Copy system information from Help → About Aperture or Diagnostics. Include the exact Aperture version, action performed, error text, relevant logs, and whether the issue reproduces in a new test library. Do not share private photographs or library databases unless deliberately required.
