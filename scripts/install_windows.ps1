[CmdletBinding()]
param(
    [ValidatePattern('^[A-Za-z0-9._-]+$')]
    [string]$EnvironmentName = 'natureai-next',

    [ValidateSet('Core', 'GUI', 'Full', 'FullAI')]
    [string]$InstallProfile = 'FullAI',

    [ValidateSet('CUDA124', 'CPU')]
    [string]$TorchBuild = 'CUDA124',

    [switch]$IncludeDevelopmentTools,
    [switch]$Editable,
    [switch]$RecreateEnvironment,
    [switch]$RunValidation,
    [switch]$SkipSmokeTest,
    [switch]$SkipDependencyInstallation,
    [switch]$SkipPackageInstallation,
    [switch]$SkipDeploymentPreflight,
    [switch]$SkipCondaBootstrap,
    [string]$MinicondaInstallerPath,
    [string]$MinicondaSha256,

    [string]$DefaultLibrary,
    [bool]$CreateDesktopShortcuts = $true,
    [bool]$CreateStartMenuShortcuts = $true,
    [bool]$AddEnvironmentToUserPath = $true
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

function Write-Step {
    param([Parameter(Mandatory)][string]$Message)
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

function Fail {
    param([Parameter(Mandatory)][string]$Message)
    throw "NatureAI Next installation failed: $Message"
}

function Resolve-CondaExecutable {
    foreach ($name in @('conda.exe', 'conda')) {
        $command = Get-Command $name -ErrorAction SilentlyContinue
        if ($null -ne $command -and $command.CommandType -eq 'Application') {
            return $command.Source
        }
    }

    $candidates = @(
        (Join-Path $env:USERPROFILE 'miniconda3\Scripts\conda.exe'),
        (Join-Path $env:USERPROFILE 'anaconda3\Scripts\conda.exe'),
        (Join-Path $env:LOCALAPPDATA 'miniconda3\Scripts\conda.exe'),
        (Join-Path $env:LOCALAPPDATA 'anaconda3\Scripts\conda.exe'),
        'C:\ProgramData\miniconda3\Scripts\conda.exe',
        'C:\ProgramData\anaconda3\Scripts\conda.exe'
    )

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }

    return $null
}

function Install-MinicondaBootstrap {
    if ($SkipCondaBootstrap) {
        Fail 'Miniconda or Anaconda was not found. Install Miniconda first or rerun without -SkipCondaBootstrap.'
    }

    Write-Step 'Installing the Aperture Python runtime (Miniconda)'
    $targetDirectory = Join-Path $env:LOCALAPPDATA 'miniconda3'
    $installer = $MinicondaInstallerPath
    $downloadedInstaller = $false
    if (-not $installer) {
        $installerName = 'Miniconda3-latest-Windows-x86_64.exe'
        $installer = Join-Path $env:TEMP $installerName
        $repositoryUrl = 'https://repo.anaconda.com/miniconda/'
        $installerUrl = $repositoryUrl + $installerName
        try {
            Invoke-WebRequest -UseBasicParsing -Uri $installerUrl -OutFile $installer
            $downloadedInstaller = $true
            if (-not $MinicondaSha256) {
                # The Miniconda repository publishes SHA-256 values in its directory index.
                # A .sha256 sidecar is not guaranteed to exist, so parse the authoritative
                # index instead of treating a missing sidecar as a failed installer download.
                $indexResponse = Invoke-WebRequest -UseBasicParsing -Uri $repositoryUrl
                $escapedName = [regex]::Escape($installerName)
                $pattern = $escapedName + '.*?([0-9a-fA-F]{64})'
                $match = [regex]::Match($indexResponse.Content, $pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
                if (-not $match.Success) {
                    Fail 'Miniconda was downloaded, but its published SHA-256 could not be read from the official repository index.'
                }
                $MinicondaSha256 = $match.Groups[1].Value.ToLowerInvariant()
            }
        }
        catch {
            Fail ("Miniconda could not be downloaded or verified. Provide an offline installer with -MinicondaInstallerPath. {0}" -f $_.Exception.Message)
        }
    }
    if (-not (Test-Path -LiteralPath $installer -PathType Leaf)) {
        Fail "Miniconda installer was not found: $installer"
    }
    if ($MinicondaSha256) {
        $actual = (Get-FileHash -LiteralPath $installer -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($actual -ne $MinicondaSha256.ToLowerInvariant()) {
            Fail 'The Miniconda installer checksum did not match.'
        }
    }
    else {
        Write-Warning 'No Miniconda checksum was supplied for the offline installer.'
    }

    $arguments = @('/InstallationType=JustMe', '/RegisterPython=0', '/AddToPath=0', '/S', "/D=$targetDirectory")
    $process = Start-Process -FilePath $installer -ArgumentList $arguments -Wait -PassThru
    if ($process.ExitCode -ne 0) {
        Fail "Miniconda installation failed with exit code $($process.ExitCode)."
    }
    $conda = Join-Path $targetDirectory 'Scripts\conda.exe'
    if (-not (Test-Path -LiteralPath $conda -PathType Leaf)) {
        Fail 'Miniconda completed but conda.exe was not found.'
    }
    if ($downloadedInstaller) {
        Remove-Item -LiteralPath $installer -Force -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath ($installer + '.sha256') -Force -ErrorAction SilentlyContinue
    }
    return $conda
}

function Ensure-CondaExecutable {
    $conda = Resolve-CondaExecutable
    if ($null -eq $conda) {
        $conda = Install-MinicondaBootstrap
    }
    return $conda
}

function Invoke-Conda {
    param([Parameter(Mandatory)][string[]]$Arguments)
    & $script:CondaExecutable @Arguments
    if ($LASTEXITCODE -ne 0) {
        Fail ("conda command failed with exit code {0}: conda {1}" -f $LASTEXITCODE, ($Arguments -join ' '))
    }
}

function Invoke-InEnvironment {
    param([Parameter(Mandatory)][string[]]$Arguments)
    Invoke-Conda -Arguments (@('run', '--no-capture-output', '-n', $EnvironmentName) + $Arguments)
}

function Get-EnvironmentRecord {
    $json = & $script:CondaExecutable env list --json
    if ($LASTEXITCODE -ne 0) {
        Fail 'Unable to query Conda environments.'
    }
    $data = $json | ConvertFrom-Json
    foreach ($path in @($data.envs)) {
        if ((Split-Path -Leaf $path) -eq $EnvironmentName) {
            return $path
        }
    }
    return $null
}


function Add-NatureAIUserPath {
    param([Parameter(Mandatory)][string]$EnvironmentPath)

    $required = @(
        (Join-Path $EnvironmentPath 'Scripts'),
        $EnvironmentPath
    )
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $entries = @()
    if ($userPath) {
        $entries = @($userPath -split ';' | Where-Object { $_ -and $_.Trim() })
    }
    foreach ($path in $required) {
        $normalized = [System.IO.Path]::GetFullPath($path).TrimEnd('\')
        $exists = $false
        foreach ($entry in $entries) {
            try {
                if ([System.IO.Path]::GetFullPath($entry).TrimEnd('\').Equals($normalized, [System.StringComparison]::OrdinalIgnoreCase)) {
                    $exists = $true
                    break
                }
            } catch { }
        }
        if (-not $exists) { $entries += $normalized }
        if (-not (($env:Path -split ';') | Where-Object { $_.TrimEnd('\').Equals($normalized, [System.StringComparison]::OrdinalIgnoreCase) })) {
            $env:Path = "$normalized;$env:Path"
        }
    }
    [Environment]::SetEnvironmentVariable('Path', ($entries -join ';'), 'User')
    Write-Host "User PATH includes: $($required -join ', ')"
    Write-Host 'Open a new PowerShell window before using NatureAI commands by name.'
}

function New-WindowsShortcut {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$TargetPath,
        [string]$Arguments = '',
        [string]$WorkingDirectory = '',
        [string]$Description = '',
        [string]$IconLocation = ''
    )

    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($Path)
    $shortcut.TargetPath = $TargetPath
    $shortcut.Arguments = $Arguments
    if ($WorkingDirectory) { $shortcut.WorkingDirectory = $WorkingDirectory }
    if ($Description) { $shortcut.Description = $Description }
    if ($IconLocation) { $shortcut.IconLocation = $IconLocation }
    $shortcut.Save()
}


function Register-WindowsApplication {
    param(
        [Parameter(Mandatory)][string]$RepositoryRoot,
        [Parameter(Mandatory)][string]$EnvironmentPath,
        [Parameter(Mandatory)][string]$LauncherRoot,
        [Parameter(Mandatory)][string]$Version
    )

    $desktopExecutable = Join-Path $EnvironmentPath 'Scripts\natureai-next.exe'
    $apertureIcon = Join-Path $RepositoryRoot 'resources\aperture.ico'
    $displayIcon = if (Test-Path -LiteralPath $apertureIcon -PathType Leaf) { $apertureIcon } else { $desktopExecutable }
    $registrationRoot = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\NatureAI Next'
    $installedUninstaller = Join-Path $LauncherRoot 'uninstall_windows.ps1'
    $repairScript = Join-Path $LauncherRoot 'repair_shortcuts.ps1'
    $sourceUninstaller = Join-Path $RepositoryRoot 'scripts\uninstall_windows.ps1'

    Copy-Item -LiteralPath $sourceUninstaller -Destination $installedUninstaller -Force

    $repairContent = @'
[CmdletBinding()]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$installScript = '__INSTALL_SCRIPT__'
$environmentName = '__ENVIRONMENT_NAME__'
if (-not (Test-Path -LiteralPath $installScript -PathType Leaf)) {
    throw "The NatureAI Next release folder is unavailable: $installScript"
}
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $installScript `
    -EnvironmentName $environmentName `
    -InstallProfile Core `
    -SkipDependencyInstallation `
    -SkipPackageInstallation `
    -SkipSmokeTest
exit $LASTEXITCODE
'@
    $repairContent = $repairContent.Replace('__INSTALL_SCRIPT__', (Join-Path $RepositoryRoot 'scripts\install_windows.ps1').Replace("'", "''"))
    $repairContent = $repairContent.Replace('__ENVIRONMENT_NAME__', $EnvironmentName.Replace("'", "''"))
    Set-Content -LiteralPath $repairScript -Value $repairContent -Encoding UTF8

    $powerShellExecutable = Join-Path $PSHOME 'powershell.exe'
    if (-not (Test-Path -LiteralPath $powerShellExecutable -PathType Leaf)) { $powerShellExecutable = 'powershell.exe' }
    $uninstallCommand = '"{0}" -NoProfile -ExecutionPolicy Bypass -File "{1}" -EnvironmentName "{2}" -InstallationRoot "{3}"' -f $powerShellExecutable, $installedUninstaller, $EnvironmentName, $RepositoryRoot
    $quietUninstallCommand = $uninstallCommand + ' -Confirm:$false'
    $modifyCommand = '"{0}" -NoProfile -ExecutionPolicy Bypass -File "{1}"' -f $powerShellExecutable, $repairScript

    New-Item -Path $registrationRoot -Force | Out-Null
    New-ItemProperty -Path $registrationRoot -Name 'DisplayName' -Value 'Aperture' -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $registrationRoot -Name 'DisplayVersion' -Value $Version -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $registrationRoot -Name 'Publisher' -Value 'natuurgids.org' -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $registrationRoot -Name 'InstallLocation' -Value $RepositoryRoot -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $registrationRoot -Name 'DisplayIcon' -Value "$displayIcon,0" -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $registrationRoot -Name 'UninstallString' -Value $uninstallCommand -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $registrationRoot -Name 'QuietUninstallString' -Value $quietUninstallCommand -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $registrationRoot -Name 'ModifyPath' -Value $modifyCommand -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $registrationRoot -Name 'NoModify' -Value 0 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $registrationRoot -Name 'NoRepair' -Value 0 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $registrationRoot -Name 'EstimatedSize' -Value 0 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $registrationRoot -Name 'InstallDate' -Value (Get-Date -Format 'yyyyMMdd') -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $registrationRoot -Name 'WindowsInstaller' -Value 0 -PropertyType DWord -Force | Out-Null

    $startMenuDirectory = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Aperture'
    New-Item -ItemType Directory -Force -Path $startMenuDirectory | Out-Null
    New-WindowsShortcut `
        -Path (Join-Path $startMenuDirectory 'Repair Aperture.lnk') `
        -TargetPath $powerShellExecutable `
        -Arguments "-NoProfile -ExecutionPolicy Bypass -File `"$repairScript`"" `
        -WorkingDirectory $LauncherRoot `
        -Description 'Repair Aperture Windows shortcuts and registration' `
        -IconLocation "$displayIcon,0"
    New-WindowsShortcut `
        -Path (Join-Path $startMenuDirectory 'Uninstall Aperture.lnk') `
        -TargetPath $powerShellExecutable `
        -Arguments "-NoProfile -ExecutionPolicy Bypass -File `"$installedUninstaller`" -EnvironmentName `"$EnvironmentName`" -InstallationRoot `"$RepositoryRoot`"" `
        -WorkingDirectory $LauncherRoot `
        -Description 'Uninstall Aperture' `
        -IconLocation "$displayIcon,0"

    Write-Host "Registered application: $registrationRoot"
}

# Legacy shortcut labels retained for upgrade/uninstall compatibility: NatureAI Next - Select Library; Repair NatureAI Next; Uninstall NatureAI Next
function Install-WindowsLaunchers {
    param(
        [Parameter(Mandatory)][string]$EnvironmentPath,
        [string]$InitialLibrary,
        [bool]$DesktopShortcuts,
        [bool]$StartMenuShortcuts
    )

    $launcherRoot = Join-Path $env:LOCALAPPDATA 'NatureAI\NatureAI Next\Launchers'
    $configurationRoot = Join-Path $env:APPDATA 'NatureAI\NatureAI Next'
    New-Item -ItemType Directory -Force -Path $launcherRoot | Out-Null
    New-Item -ItemType Directory -Force -Path $configurationRoot | Out-Null

    $desktopExecutable = Join-Path $EnvironmentPath 'Scripts\natureai-next.exe'
    $apertureIcon = Join-Path $RepositoryRoot 'resources\aperture.ico'
    $displayIcon = if (Test-Path -LiteralPath $apertureIcon -PathType Leaf) { $apertureIcon } else { $desktopExecutable }
    $adminExecutable = Join-Path $EnvironmentPath 'Scripts\natureai-next-admin.exe'
    $maintenanceExecutable = Join-Path $EnvironmentPath 'Scripts\aperture-maintenance-center.exe'
    if (-not (Test-Path -LiteralPath $desktopExecutable -PathType Leaf)) {
        Fail "Desktop executable was not found at $desktopExecutable."
    }
    if (-not (Test-Path -LiteralPath $adminExecutable -PathType Leaf)) {
        Fail "Administrative executable was not found at $adminExecutable."
    }
    if (-not (Test-Path -LiteralPath $maintenanceExecutable -PathType Leaf)) {
        Fail "Maintenance Center executable was not found at $maintenanceExecutable."
    }

    $commonPath = Join-Path $launcherRoot 'launcher_common.ps1'
    $commonScript = @'
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$script:LauncherConfigurationRoot = Join-Path $env:APPDATA 'NatureAI\NatureAI Next'
$script:LauncherConfigurationPath = Join-Path $script:LauncherConfigurationRoot 'launcher.json'

function Test-NatureAILibrary {
    param([Parameter(Mandatory)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) { return $false }
    return (
        (Test-Path -LiteralPath (Join-Path $Path 'library.json') -PathType Leaf) -and
        (Test-Path -LiteralPath (Join-Path $Path 'library.sqlite3') -PathType Leaf)
    )
}

function Save-NatureAILibrary {
    param([Parameter(Mandatory)][string]$Path)
    if (-not (Test-NatureAILibrary -Path $Path)) {
        throw "Not a valid NatureAI Next library: $Path"
    }
    New-Item -ItemType Directory -Force -Path $script:LauncherConfigurationRoot | Out-Null
    $temporaryPath = "$script:LauncherConfigurationPath.tmp"
    @{ schema_version = 1; last_library = (Resolve-Path -LiteralPath $Path).Path } |
        ConvertTo-Json |
        Set-Content -LiteralPath $temporaryPath -Encoding UTF8
    Move-Item -LiteralPath $temporaryPath -Destination $script:LauncherConfigurationPath -Force
}

function Read-NatureAILibrary {
    if (-not (Test-Path -LiteralPath $script:LauncherConfigurationPath -PathType Leaf)) { return $null }
    try {
        $value = Get-Content -LiteralPath $script:LauncherConfigurationPath -Raw | ConvertFrom-Json
        $path = [string]$value.last_library
        if ($path -and (Test-NatureAILibrary -Path $path)) { return $path }
    }
    catch { return $null }
    return $null
}

function Select-NatureAILibrary {
    Add-Type -AssemblyName System.Windows.Forms
    while ($true) {
        $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
        $dialog.Description = 'Select a NatureAI Next library folder'
        $dialog.ShowNewFolderButton = $false
        $result = $dialog.ShowDialog()
        if ($result -ne [System.Windows.Forms.DialogResult]::OK) { return $null }
        $selected = $dialog.SelectedPath
        if (Test-NatureAILibrary -Path $selected) {
            Save-NatureAILibrary -Path $selected
            return $selected
        }
        [System.Windows.Forms.MessageBox]::Show(
            'The selected folder is not an initialized Aperture library. Select the folder containing library.json and library.sqlite3.',
            'Aperture',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
    }
}

function Resolve-NatureAILibrary {
    param([switch]$ForceSelection)
    if (-not $ForceSelection) {
        $saved = Read-NatureAILibrary
        if ($saved) { return $saved }
    }
    return Select-NatureAILibrary
}
'@
    Set-Content -LiteralPath $commonPath -Value $commonScript -Encoding UTF8

    $apertureExecutable = Join-Path $EnvironmentPath 'Scripts\aperture.exe'
    if (-not (Test-Path -LiteralPath $apertureExecutable -PathType Leaf)) {
        Fail "Aperture GUI launcher was not installed: $apertureExecutable"
    }

    $debugPath = Join-Path $launcherRoot 'start_natureai_next_debug.ps1'
    $debugScript = @'
. (Join-Path $PSScriptRoot 'launcher_common.ps1')
$library = Resolve-NatureAILibrary
if (-not $library) { exit 0 }
$executable = '__DESKTOP_EXECUTABLE__'
& $executable --library $library --log-level DEBUG
$exitCode = $LASTEXITCODE
Write-Host "NatureAI Next exited with code $exitCode."
if ($exitCode -ne 0) { Read-Host 'Press Enter to close' | Out-Null }
exit $exitCode
'@
    $debugScript = $debugScript.Replace('__DESKTOP_EXECUTABLE__', $desktopExecutable.Replace("'", "''"))
    Set-Content -LiteralPath $debugPath -Value $debugScript -Encoding UTF8

    $selectPath = Join-Path $launcherRoot 'select_natureai_library.ps1'
    $selectScript = @'
. (Join-Path $PSScriptRoot 'launcher_common.ps1')
$library = Resolve-NatureAILibrary -ForceSelection
if ($library) {
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show(
        "Default library set to:`n$library",
        'Aperture',
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    ) | Out-Null
}
'@
    Set-Content -LiteralPath $selectPath -Value $selectScript -Encoding UTF8

    $adminPath = Join-Path $launcherRoot 'start_admin_console.cmd'
    $adminScript = @"
@echo off
set "PATH=$EnvironmentPath\Scripts;$EnvironmentPath;%PATH%"
title Aperture Admin Console - NatureAI_Next
cd /d "%USERPROFILE%"
echo Aperture Admin Console - powered by NatureAI_Next
echo Type natureai-next-admin --help to list commands.
echo.
cmd /k
"@
    Set-Content -LiteralPath $adminPath -Value $adminScript -Encoding ASCII

    if ($InitialLibrary) {
        $resolvedLibrary = [System.IO.Path]::GetFullPath($InitialLibrary)
        if (-not ((Test-Path -LiteralPath (Join-Path $resolvedLibrary 'library.json') -PathType Leaf) -and
                  (Test-Path -LiteralPath (Join-Path $resolvedLibrary 'library.sqlite3') -PathType Leaf))) {
            Fail "Default library is not an initialized NatureAI Next library: $resolvedLibrary"
        }
        $configurationPath = Join-Path $configurationRoot 'launcher.json'
        $temporaryPath = "$configurationPath.tmp"
        @{ schema_version = 1; last_library = $resolvedLibrary } |
            ConvertTo-Json |
            Set-Content -LiteralPath $temporaryPath -Encoding UTF8
        Move-Item -LiteralPath $temporaryPath -Destination $configurationPath -Force
    }

    $powerShellExecutable = Join-Path $PSHOME 'powershell.exe'
    if (-not (Test-Path -LiteralPath $powerShellExecutable -PathType Leaf)) {
        $powerShellExecutable = 'powershell.exe'
    }
    $apertureIcon = Join-Path $RepositoryRoot 'resources\aperture.ico'
    $shortcutIcon = if (Test-Path -LiteralPath $apertureIcon -PathType Leaf) { $apertureIcon } else { $desktopExecutable }
    $recoveryIcon = Join-Path $RepositoryRoot 'resources\aperture-backup-recovery.ico'
    if (-not (Test-Path -LiteralPath $recoveryIcon -PathType Leaf)) { $recoveryIcon = $shortcutIcon }
    $shortcutDefinitions = @(
        @{ Name = 'Aperture'; Target = $apertureExecutable; Arguments = ''; Description = 'Start Aperture — powered by NatureAI_Next' },
        @{ Name = 'Aperture (Debug)'; Target = $powerShellExecutable; Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$debugPath`""; Description = 'Start Aperture with NatureAI_Next debug logging' },
        @{ Name = 'Aperture - Select Library'; Target = $powerShellExecutable; Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$selectPath`""; Description = 'Choose the default NatureAI_Next library for Aperture' },
        @{ Name = 'Aperture Maintenance Center'; Target = $maintenanceExecutable; Arguments = ''; Description = 'Update, back up, restore, repair, and inspect Aperture'; Icon = $recoveryIcon },
        @{ Name = 'NatureAI Next Admin Console'; Target = $adminPath; Arguments = ''; Description = 'Open the NatureAI Next administrative console' }
    )

    if ($DesktopShortcuts) {
        $desktopDirectory = [Environment]::GetFolderPath('Desktop')
        foreach ($definition in $shortcutDefinitions[0..3]) {
            $definitionIcon = if ($definition.ContainsKey('Icon')) { $definition.Icon } else { $displayIcon }
            New-WindowsShortcut -Path (Join-Path $desktopDirectory ($definition.Name + '.lnk')) -TargetPath $definition.Target -Arguments $definition.Arguments -WorkingDirectory $launcherRoot -Description $definition.Description -IconLocation "$definitionIcon,0"
        }
    }

    if ($StartMenuShortcuts) {
        $startMenuDirectory = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Aperture'
        New-Item -ItemType Directory -Force -Path $startMenuDirectory | Out-Null
        foreach ($definition in $shortcutDefinitions) {
            $definitionIcon = if ($definition.ContainsKey('Icon')) { $definition.Icon } else { $displayIcon }
            New-WindowsShortcut -Path (Join-Path $startMenuDirectory ($definition.Name + '.lnk')) -TargetPath $definition.Target -Arguments $definition.Arguments -WorkingDirectory $launcherRoot -Description $definition.Description -IconLocation "$definitionIcon,0"
        }
    }

    Write-Host "Launchers:    $launcherRoot"
    if ($InitialLibrary) { Write-Host "Default library: $InitialLibrary" }
    else { Write-Host 'Default library: select on first launch' }
}

$RepositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$preflightReportPath = Join-Path $RepositoryRoot '.installation\deployment-preflight.json'
if (-not $SkipDeploymentPreflight) {
    Write-Step 'Validating release package before installation'
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $preflightReportPath) | Out-Null
    $preflightConda = Ensure-CondaExecutable
    & $preflightConda run --no-capture-output -n base python (Join-Path $PSScriptRoot 'deployment_preflight.py') --release-root $RepositoryRoot --output $preflightReportPath
    if ($LASTEXITCODE -ne 0) { Fail 'Release package preflight failed. No installation changes were made.' }
}
$PyProject = Join-Path $RepositoryRoot 'pyproject.toml'
$RequirementsRoot = Join-Path $RepositoryRoot 'requirements'
if (-not (Test-Path -LiteralPath $PyProject -PathType Leaf)) {
    Fail "pyproject.toml was not found at $PyProject."
}
if (-not (Test-Path -LiteralPath $RequirementsRoot -PathType Container)) {
    Fail "requirements directory was not found at $RequirementsRoot."
}
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Fail 'PowerShell 5.1 or newer is required.'
}
if ($env:OS -ne 'Windows_NT') {
    Fail 'This installer is intended for Windows.'
}
if ($InstallProfile -eq 'Full') {
    $InstallProfile = 'FullAI'
}

$script:CondaExecutable = Resolve-CondaExecutable
if ($null -eq $script:CondaExecutable) { $script:CondaExecutable = Install-MinicondaBootstrap }
Write-Step "Using Conda: $script:CondaExecutable"
& $script:CondaExecutable --version
if ($LASTEXITCODE -ne 0) {
    Fail 'Conda could not be executed.'
}

$environmentPath = Get-EnvironmentRecord
if ($null -ne $environmentPath -and $RecreateEnvironment) {
    Write-Step "Removing existing isolated environment '$EnvironmentName'"
    Invoke-Conda -Arguments @('env', 'remove', '--yes', '--name', $EnvironmentName)
    $environmentPath = $null
}

if ($null -eq $environmentPath) {
    Write-Step "Creating isolated Python 3.11 environment '$EnvironmentName'"
    Invoke-Conda -Arguments @(
        'create', '--yes', '--name', $EnvironmentName,
        '--override-channels', '--channel', 'conda-forge', '--strict-channel-priority',
        'python=3.11', 'pip=24.*', 'setuptools', 'wheel'
    )
}
else {
    Write-Step "Reusing existing isolated environment '$EnvironmentName'"
}

$environmentPath = Get-EnvironmentRecord
if ($null -eq $environmentPath) {
    Fail "The Conda environment '$EnvironmentName' could not be resolved after creation."
}
$environmentPython = Join-Path $environmentPath 'python.exe'
if (-not (Test-Path -LiteralPath $environmentPython -PathType Leaf)) {
    Fail "Python was not found at $environmentPython."
}

Write-Step 'Verifying Python 3.11'
Invoke-InEnvironment -Arguments @(
    'python', '-c',
    'import sys; assert sys.version_info[:2] == (3, 11), "Expected Python 3.11, got " + sys.version; print(sys.version)'
)

Push-Location $RepositoryRoot
try {
    if (-not $SkipDependencyInstallation) {
    Write-Step 'Installing core and GUI dependencies'
    $baseRequirements = if ($InstallProfile -eq 'Core') { 'core.txt' } else { 'gui.txt' }
    Invoke-InEnvironment -Arguments @(
        'python', '-m', 'pip', 'install',
        '--requirement', (Join-Path 'requirements' $baseRequirements)
    )

    if ($InstallProfile -eq 'FullAI') {
        Write-Step 'Installing compiled HNSWLib through Conda Forge'
        Invoke-Conda -Arguments @(
            'install', '--yes', '--name', $EnvironmentName,
            '--override-channels', '--channel', 'conda-forge', '--strict-channel-priority',
            'hnswlib=0.8.0'
        )

        Write-Step "Installing PyTorch runtime ($TorchBuild)"
        Invoke-InEnvironment -Arguments @(
            'python', '-m', 'pip', 'uninstall', '--yes',
            'torch', 'torchvision', 'torchaudio'
        )

        if ($TorchBuild -eq 'CUDA124') {
            Invoke-InEnvironment -Arguments @(
                'python', '-m', 'pip', 'install',
                'torch==2.5.1', 'torchvision==0.20.1', 'torchaudio==2.5.1',
                '--index-url', 'https://download.pytorch.org/whl/cu124'
            )
        }
        else {
            Invoke-InEnvironment -Arguments @(
                'python', '-m', 'pip', 'install',
                'torch==2.5.1', 'torchvision==0.20.1', 'torchaudio==2.5.1',
                '--index-url', 'https://download.pytorch.org/whl/cpu'
            )
        }

        Write-Step 'Installing OpenCLIP'
        Invoke-InEnvironment -Arguments @(
            'python', '-m', 'pip', 'install',
            '--constraint', (Join-Path 'requirements' 'constraints-py311.txt'),
            'open-clip-torch==2.30.0'
        )
    }

    if ($IncludeDevelopmentTools) {
        Write-Step 'Installing development and validation tools'
        Invoke-InEnvironment -Arguments @(
            'python', '-m', 'pip', 'install',
            '--requirement', (Join-Path 'requirements' 'dev.txt')
        )
    }
    }

    if (-not $SkipPackageInstallation) {
    Write-Step 'Installing NatureAI Next'
    $packageArguments = @('python', '-m', 'pip', 'install', '--no-deps', '--force-reinstall')
    if ($Editable) {
        $packageArguments += '--editable'
    }
    $packageArguments += '.'
    Invoke-InEnvironment -Arguments $packageArguments
    }
}
finally {
    Pop-Location
}

Write-Step 'Writing installation report'
$reportDirectory = Join-Path $RepositoryRoot '.installation'
New-Item -ItemType Directory -Force -Path $reportDirectory | Out-Null
$reportPath = Join-Path $reportDirectory 'environment.txt'
$freezePath = Join-Path $reportDirectory 'pip-freeze.txt'
$reportScriptPath = Join-Path $reportDirectory 'write_environment_report.py'
$reportScript = @'
import platform
import sys

import natureai_next

print(f"NatureAI Next: {natureai_next.__version__}")
print(f"Python: {sys.version}")
print(f"Executable: {sys.executable}")
print(f"Platform: {platform.platform()}")
'@
Set-Content -LiteralPath $reportScriptPath -Value $reportScript -Encoding UTF8

$report = & $environmentPython $reportScriptPath
if ($LASTEXITCODE -ne 0) {
    Fail 'The installed package could not be imported.'
}
$report | Set-Content -LiteralPath $reportPath -Encoding UTF8
$report | Write-Host

$freeze = & $environmentPython -m pip freeze --all
if ($LASTEXITCODE -ne 0) {
    Fail 'Unable to capture the installed package inventory.'
}
$freeze | Set-Content -LiteralPath $freezePath -Encoding UTF8

if (-not $SkipSmokeTest) {
    Write-Step 'Running installation smoke tests'
    Invoke-InEnvironment -Arguments @('natureai-next', '--help')
    Invoke-InEnvironment -Arguments @('natureai-next-admin', '--help')
    Invoke-InEnvironment -Arguments @('natureai-next-resources', '--help')

    $verifyArguments = @('python', 'scripts\verify_install.py')
    if ($InstallProfile -in @('GUI', 'FullAI')) {
        $verifyArguments += '--require-gui'
    }
    if ($InstallProfile -eq 'FullAI') {
        $verifyArguments += '--require-ai'
    }
    Push-Location $RepositoryRoot
    try {
        Invoke-InEnvironment -Arguments $verifyArguments
    }
    finally {
        Pop-Location
    }
}

if ($RunValidation) {
    if (-not $IncludeDevelopmentTools) {
        Fail '-RunValidation requires -IncludeDevelopmentTools.'
    }
    Write-Step 'Running repository validation'
    Push-Location $RepositoryRoot
    try {
        Invoke-InEnvironment -Arguments @('python', 'scripts\validate.py')
    }
    finally {
        Pop-Location
    }
}

if ($AddEnvironmentToUserPath) {
    Write-Step 'Adding NatureAI Next commands to the current user PATH'
    Add-NatureAIUserPath -EnvironmentPath $environmentPath
}

Write-Step 'Installing Windows launchers and shortcuts'
Install-WindowsLaunchers -EnvironmentPath $environmentPath -InitialLibrary $DefaultLibrary -DesktopShortcuts $CreateDesktopShortcuts -StartMenuShortcuts $CreateStartMenuShortcuts

Write-Step 'Registering NatureAI Next with Windows Installed Apps'
$installedVersion = (& $environmentPython -c 'import natureai_next; print(natureai_next.__version__)').Trim()
if ($LASTEXITCODE -ne 0 -or -not $installedVersion) { Fail 'Unable to determine the installed NatureAI Next version.' }
$launcherRoot = Join-Path $env:LOCALAPPDATA 'NatureAI\NatureAI Next\Launchers'
Register-WindowsApplication -RepositoryRoot $RepositoryRoot -EnvironmentPath $environmentPath -LauncherRoot $launcherRoot -Version $installedVersion

Write-Step 'Installation completed'
Write-Host "Environment: $EnvironmentName"
Write-Host "Profile:     $InstallProfile"
Write-Host "Repository:  $RepositoryRoot"
Write-Host "Report:      $reportPath"
Write-Host "Inventory:   $freezePath"
Write-Host ''
Write-Host 'The installer does not modify or remove NatureAI Legacy.' -ForegroundColor Green
Write-Host 'Libraries, photographs, models, backups, and exports remain outside the Conda environment.' -ForegroundColor Green
