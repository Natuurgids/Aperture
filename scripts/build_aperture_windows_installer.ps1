[CmdletBinding()]
param(
    [ValidateSet('GUI', 'FullAI')]
    [string]$BuildProfile = 'GUI',

    [string]$Version = '0.18.1',

    [string]$EnvironmentName = 'aperture-build',

    [string]$DefaultLibrary = '',

    [switch]$SkipTests,

    [switch]$Clean
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Step([string]$Message) {
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

function Fail([string]$Message) {
    throw "Aperture installer build failed: $Message"
}

function Resolve-Conda {
    $command = Get-Command conda.exe -ErrorAction SilentlyContinue
    if ($command) { return $command.Source }

    $candidates = @(
        "$env:USERPROFILE\miniconda3\Scripts\conda.exe",
        "$env:USERPROFILE\anaconda3\Scripts\conda.exe",
        "$env:LOCALAPPDATA\miniconda3\Scripts\conda.exe",
        "$env:LOCALAPPDATA\anaconda3\Scripts\conda.exe",
        "C:\ProgramData\miniconda3\Scripts\conda.exe",
        "C:\ProgramData\anaconda3\Scripts\conda.exe"
    )
    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) { return $candidate }
    }
    Fail 'Conda was not found. Install Miniconda and open a new PowerShell window.'
}

function Invoke-Conda([string[]]$Arguments) {
    & $script:Conda @Arguments
    if ($LASTEXITCODE -ne 0) {
        Fail "conda command failed with exit code $LASTEXITCODE: conda $($Arguments -join ' ')"
    }
}

$RepositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '.')).Path
if (-not (Test-Path -LiteralPath (Join-Path $RepositoryRoot 'pyproject.toml'))) {
    Fail 'Run this script from the extracted Aperture repository root, next to pyproject.toml.'
}
if (-not (Test-Path -LiteralPath (Join-Path $RepositoryRoot 'src\natureai_next'))) {
    Fail 'The src\natureai_next package was not found.'
}

$script:Conda = Resolve-Conda
$BuildRoot = Join-Path $RepositoryRoot '.installer-build'
$WrapperRoot = Join-Path $BuildRoot 'wrappers'
$PyInstallerWork = Join-Path $BuildRoot 'pyinstaller-work'
$PyInstallerSpec = Join-Path $BuildRoot 'pyinstaller-spec'
$ApplicationDist = Join-Path $BuildRoot 'application'
$InstallerDist = Join-Path $RepositoryRoot 'dist-installer'

if ($Clean) {
    Write-Step 'Cleaning previous build output'
    Remove-Item -LiteralPath $BuildRoot -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $InstallerDist -Recurse -Force -ErrorAction SilentlyContinue
}
New-Item -ItemType Directory -Force -Path $WrapperRoot, $PyInstallerWork, $PyInstallerSpec, $ApplicationDist, $InstallerDist | Out-Null

Write-Step "Creating or updating Conda build environment '$EnvironmentName'"
$environmentExists = (& $script:Conda env list --json | ConvertFrom-Json).envs | Where-Object { $_ -match "[\\/]$([regex]::Escape($EnvironmentName))$" }
if (-not $environmentExists) {
    Invoke-Conda @('create', '-y', '-n', $EnvironmentName, 'python=3.11', 'pip')
}

Write-Step 'Installing build dependencies and Aperture'
Invoke-Conda @('run', '--no-capture-output', '-n', $EnvironmentName, 'python', '-m', 'pip', 'install', '--upgrade', 'pip', 'build', 'pyinstaller>=6.11,<7')
if ($BuildProfile -eq 'FullAI') {
    Invoke-Conda @('run', '--no-capture-output', '-n', $EnvironmentName, 'python', '-m', 'pip', 'install', '-e', '.[gui,ai]')
} else {
    Invoke-Conda @('run', '--no-capture-output', '-n', $EnvironmentName, 'python', '-m', 'pip', 'install', '-e', '.[gui]')
}

if (-not $SkipTests) {
    Write-Step 'Running practical automated tests'
    Invoke-Conda @('run', '--no-capture-output', '-n', $EnvironmentName, 'python', '-m', 'pip', 'install', '-e', '.[dev]')
    Invoke-Conda @('run', '--no-capture-output', '-n', $EnvironmentName, 'python', '-m', 'pytest', '-m', 'not performance')
}

$launcher = @'
from __future__ import annotations

import json
import os
import sys
from pathlib import Path

from PySide6.QtWidgets import QApplication, QFileDialog, QMessageBox

from natureai_next.bootstrap.cli import main as aperture_main


def _settings_path() -> Path:
    root = Path(os.environ.get("APPDATA", Path.home())) / "NatureAI" / "NatureAI Next"
    root.mkdir(parents=True, exist_ok=True)
    return root / "launcher.json"


def _valid_library(path: Path) -> bool:
    return path.is_dir() and (path / "library.json").is_file() and (path / "library.sqlite3").is_file()


def _saved_library() -> Path | None:
    try:
        value = json.loads(_settings_path().read_text(encoding="utf-8"))
        path = Path(str(value.get("last_library", "")))
        return path if _valid_library(path) else None
    except (OSError, ValueError, TypeError):
        return None


def _choose_library() -> Path | None:
    app = QApplication.instance() or QApplication([])
    while True:
        selected = QFileDialog.getExistingDirectory(None, "Select Aperture Library")
        if not selected:
            return None
        path = Path(selected)
        if _valid_library(path):
            _settings_path().write_text(
                json.dumps({"schema_version": 1, "last_library": str(path)}, indent=2),
                encoding="utf-8",
            )
            return path
        QMessageBox.warning(
            None,
            "Aperture",
            "Select the folder containing library.json and library.sqlite3.",
        )


def run() -> int:
    library = _saved_library() or _choose_library()
    if library is None:
        return 0
    return aperture_main(["--library", str(library), "--log-level", "INFO"])


if __name__ == "__main__":
    raise SystemExit(run())
'@
Set-Content -LiteralPath (Join-Path $WrapperRoot 'aperture_launcher.py') -Value $launcher -Encoding UTF8

$backupRecoveryLauncher = @'
from natureai_next.ui.qt.backup_recovery_app import main

if __name__ == "__main__":
    raise SystemExit(main())
'@
Set-Content -LiteralPath (Join-Path $WrapperRoot 'backup_recovery_launcher.py') -Value $backupRecoveryLauncher -Encoding UTF8

$updaterLauncher = @'
from natureai_next.bootstrap.native_updater import main

if __name__ == "__main__":
    raise SystemExit(main())
'@
Set-Content -LiteralPath (Join-Path $WrapperRoot 'updater_launcher.py') -Value $updaterLauncher -Encoding UTF8

$recoveryLauncher = @'
from natureai_next.bootstrap.native_recovery import main

if __name__ == "__main__":
    raise SystemExit(main())
'@
Set-Content -LiteralPath (Join-Path $WrapperRoot 'recovery_launcher.py') -Value $recoveryLauncher -Encoding UTF8

$icon = Join-Path $RepositoryRoot 'resources\aperture.ico'
$recoveryIcon = Join-Path $RepositoryRoot 'resources\aperture-backup-recovery.ico'
$commonDataArgs = @(
    '--collect-all', 'natureai_next',
    '--collect-all', 'PySide6',
    '--hidden-import', 'PIL._tkinter_finder'
)
if ($BuildProfile -eq 'FullAI') {
    $commonDataArgs += @('--collect-all', 'torch', '--collect-all', 'torchvision', '--collect-all', 'open_clip')
}

function Build-App([string]$Name, [string]$Wrapper, [string]$IconPath, [bool]$Windowed) {
    Write-Step "Building $Name"
    $arguments = @(
        'run', '--no-capture-output', '-n', $EnvironmentName,
        'pyinstaller', '--noconfirm', '--clean', '--onedir',
        '--name', $Name,
        '--distpath', $ApplicationDist,
        '--workpath', $PyInstallerWork,
        '--specpath', $PyInstallerSpec,
        '--paths', (Join-Path $RepositoryRoot 'src')
    )
    if ($Windowed) { $arguments += '--windowed' }
    if (Test-Path -LiteralPath $IconPath) { $arguments += @('--icon', $IconPath) }
    $arguments += $commonDataArgs
    $arguments += $Wrapper
    Invoke-Conda $arguments
}

Build-App -Name 'Aperture' -Wrapper (Join-Path $WrapperRoot 'aperture_launcher.py') -IconPath $icon -Windowed $true
Build-App -Name 'Aperture Maintenance Center' -Wrapper (Join-Path $WrapperRoot 'backup_recovery_launcher.py') -IconPath $recoveryIcon -Windowed $true
Build-App -Name 'ApertureUpdater' -Wrapper (Join-Path $WrapperRoot 'updater_launcher.py') -IconPath $icon -Windowed $true
Build-App -Name 'ApertureRecovery' -Wrapper (Join-Path $WrapperRoot 'recovery_launcher.py') -IconPath $recoveryIcon -Windowed $true

Write-Step 'Finding Inno Setup compiler'
$isccCandidates = @(
    "$env:ProgramFiles(x86)\Inno Setup 6\ISCC.exe",
    "$env:ProgramFiles\Inno Setup 6\ISCC.exe"
)
$Iscc = $isccCandidates | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
if (-not $Iscc) {
    Fail 'Inno Setup 6 was not found. Install it with: winget install --id JRSoftware.InnoSetup -e'
}

$defaultLibraryLine = if ($DefaultLibrary) { "DefaultLibrary=$DefaultLibrary" } else { 'DefaultLibrary=' }
$issPath = Join-Path $BuildRoot 'Aperture.iss'
$iss = @"
#define MyAppName "Aperture"
#define MyAppVersion "$Version"
#define MyAppPublisher "Natuurgids"
#define MyAppExeName "Aperture.exe"

[Setup]
AppId={{A99634D1-01DA-4C3B-B41E-E0FA44F23531}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={localappdata}\Programs\Aperture
DefaultGroupName=Aperture
DisableProgramGroupPage=yes
OutputDir=$($InstallerDist.Replace('\','\\'))
OutputBaseFilename=Aperture-$Version-Setup
Compression=lzma2
SolidCompression=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=lowest
SetupIconFile=$($icon.Replace('\','\\'))
UninstallDisplayIcon={app}\Aperture\Aperture.exe
CloseApplications=yes
RestartApplications=no

[Files]
Source: "$($ApplicationDist.Replace('\','\\'))\Aperture\*"; DestDir: "{app}\Aperture"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "$($ApplicationDist.Replace('\','\\'))\Aperture Maintenance Center\*"; DestDir: "{app}\BackupRecovery"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "$($ApplicationDist.Replace('\','\\'))\ApertureUpdater\*"; DestDir: "{app}\Updater"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "$($ApplicationDist.Replace('\','\\'))\ApertureRecovery\*"; DestDir: "{app}\Recovery"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Aperture"; Filename: "{app}\Aperture\Aperture.exe"; IconFilename: "{app}\Aperture\Aperture.exe"
Name: "{group}\Aperture Maintenance Center"; Filename: "{app}\BackupRecovery\Aperture Maintenance Center.exe"; IconFilename: "{app}\BackupRecovery\Aperture Maintenance Center.exe"
Name: "{autodesktop}\Aperture"; Filename: "{app}\Aperture\Aperture.exe"; Tasks: desktopicon
Name: "{autodesktop}\Aperture Maintenance Center"; Filename: "{app}\BackupRecovery\Aperture Maintenance Center.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Create desktop shortcuts"; GroupDescription: "Additional icons:"; Flags: unchecked

[Run]
Filename: "{app}\Aperture\Aperture.exe"; Description: "Launch Aperture"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}"
"@
Set-Content -LiteralPath $issPath -Value $iss -Encoding UTF8

Write-Step 'Compiling the Windows Setup executable'
& $Iscc $issPath
if ($LASTEXITCODE -ne 0) { Fail "Inno Setup failed with exit code $LASTEXITCODE." }

$setupPath = Join-Path $InstallerDist "Aperture-$Version-Setup.exe"
if (-not (Test-Path -LiteralPath $setupPath -PathType Leaf)) {
    Fail "Expected installer was not created: $setupPath"
}
$hash = (Get-FileHash -LiteralPath $setupPath -Algorithm SHA256).Hash.ToLowerInvariant()
$hashPath = "$setupPath.sha256"
"$hash  $(Split-Path -Leaf $setupPath)" | Set-Content -LiteralPath $hashPath -Encoding ASCII

Write-Step 'Build completed'
Write-Host "Installer: $setupPath"
Write-Host "SHA-256:   $hash"
Write-Host "Hash file: $hashPath"
Write-Warning 'This installer must be validated on Windows 11 before public distribution. FullAI builds can be very large and may require additional PyInstaller exclusions or hidden imports for the selected Torch/OpenCLIP versions.'
