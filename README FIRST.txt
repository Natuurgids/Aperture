APERTURE 1.0.0 RC1 - START HERE

FULL INSTALLATION
1. Extract this ZIP completely.
2. Close Aperture and Aperture Maintenance Center.
3. Double-click "Install Aperture.cmd".
4. Choose the drive where Aperture should store observations and AI data.
5. Aperture creates a standard folder named Aperture-Library automatically.

The library contains the SQLite database, metadata, thumbnails, backups, and any managed photographs. It grows over time, so select a drive with sufficient free space.

UNATTENDED EXAMPLES
Install Aperture.cmd /silent /drive=D /profile=FullAI /useexisting
Install Aperture.cmd /silent /drive=D /profile=GUI /createnew
Install Aperture.cmd /silent /library="E:\Research\Aperture-Library" /profile=FullAI

SUPPORTED OPTIONS
/silent
/drive=D
/profile=Core|GUI|Full|FullAI
/torch=CUDA124|CPU
/library="full path"
/useexisting
/createnew
/repair
/skippreflight

MAINTENANCE
Use "Repair Aperture.cmd" to repair Windows integration.
Use "Uninstall Aperture.cmd" to remove the package or environment.
Libraries, photographs, backups, and exports are not removed by the normal uninstall choices.

## Python runtime bootstrap

A separate Python installation is not required. If Miniconda or Anaconda is not present, the Aperture installer downloads the official Miniconda Windows installer, verifies its published SHA-256 checksum, installs it for the current user, and then creates the isolated `natureai-next` Python 3.11 environment. For offline deployment, pass `-MinicondaInstallerPath` and optionally `-MinicondaSha256` to `scripts\install_windows.ps1`. Use `-SkipCondaBootstrap` only when deployment policy requires Conda to be installed separately.



### Conda channel isolation

The installer creates and maintains the Aperture environment with `--override-channels` and the `conda-forge` channel only. This avoids interactive Anaconda default-channel Terms of Service prompts during unattended installation.
