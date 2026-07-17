# Deployment, upgrades, repair, and uninstall

Aperture 0.17.6 adds a deployment preflight that runs before the Windows installer changes the Conda environment, shortcuts, PATH, or Installed Apps registration. The report is written to `.installation/deployment-preflight.json`.

## Supported operations

- Clean install with `scripts/install_windows.ps1`.
- In-place upgrade by running the newer release's installer against the existing `natureai-next` environment.
- Repair through Windows Installed Apps or the Start-menu **Repair Aperture** shortcut.
- Uninstall with user libraries, photographs, models, backups, and exports preserved by default.

## Upgrade procedure

1. Back up the active library in Aperture.
2. Close Aperture and its admin console.
3. Extract the new release to a stable folder.
4. Run `scripts\install_windows.ps1` with the same environment name and profile.
5. Run `scripts\verify_install.bat`.
6. Open the library and run **Settings → Health Center**.

The installer reuses the existing isolated environment unless `-RecreateEnvironment` is explicitly supplied. Do not use that switch during a routine upgrade.

## Diagnostics

Run:

```powershell
.\scripts\collect_installer_diagnostics.ps1
```

The command creates a ZIP containing platform details, preflight results, Conda environment inventory, runtime verification, and installation reports. It does not collect libraries or photographs.

## Data-preservation boundary

Installation and uninstallation operate on application packages, launchers, shortcuts, PATH entries, and Windows registration. Library folders and user media are outside that boundary and are never removed by default.
