[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param(
    [ValidatePattern('^[A-Za-z0-9._-]+$')]
    [string]$EnvironmentName = 'natureai-next',

    [switch]$RemoveEnvironment,
    [switch]$RemoveInstallationReports,
    [switch]$RemoveApplicationData,

    [string]$InstallationRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-NatureAIEnvironmentPath {
    param([Parameter(Mandatory)][string]$EnvironmentName)

    $candidateRoots = @(
        (Join-Path $env:LOCALAPPDATA 'miniconda3'),
        (Join-Path $env:LOCALAPPDATA 'anaconda3'),
        (Join-Path $env:USERPROFILE 'miniconda3'),
        (Join-Path $env:USERPROFILE 'anaconda3'),
        'C:\ProgramData\miniconda3',
        'C:\ProgramData\anaconda3'
    )

    foreach ($root in $candidateRoots) {
        $candidate = Join-Path $root (Join-Path 'envs' $EnvironmentName)
        if ((Test-Path -LiteralPath $candidate -PathType Container) -and
            (Test-Path -LiteralPath (Join-Path $candidate 'python.exe') -PathType Leaf) -and
            (Test-Path -LiteralPath (Join-Path $candidate 'conda-meta') -PathType Container)) {
            return [System.IO.Path]::GetFullPath($candidate)
        }
    }

    $pathEntries = @([Environment]::GetEnvironmentVariable('Path', 'User') -split ';')
    foreach ($entry in $pathEntries) {
        if (-not $entry) { continue }
        $candidate = $entry.TrimEnd('\\')
        if ((Split-Path -Leaf $candidate) -eq 'Scripts') {
            $candidate = Split-Path -Parent $candidate
        }
        if ((Split-Path -Leaf $candidate) -eq $EnvironmentName -and
            (Test-Path -LiteralPath (Join-Path $candidate 'python.exe') -PathType Leaf)) {
            return [System.IO.Path]::GetFullPath($candidate)
        }
    }

    return $null
}

function Stop-NatureAIProcesses {
    param([Parameter(Mandatory)][string]$EnvironmentPath)

    $normalized = [System.IO.Path]::GetFullPath($EnvironmentPath).TrimEnd('\\')
    $running = @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object {
        $exe = [string]$_.ExecutablePath
        $cmd = [string]$_.CommandLine
        ($exe -and $exe.StartsWith($normalized, [System.StringComparison]::OrdinalIgnoreCase)) -or
        ($cmd -and $cmd.IndexOf($normalized, [System.StringComparison]::OrdinalIgnoreCase) -ge 0)
    })

    if ($running.Count -gt 0) {
        $details = ($running | ForEach-Object { "$($_.Name) (PID $($_.ProcessId))" }) -join ', '
        throw "Aperture is still running from the NatureAI_Next environment: $details. Close Aperture and try again."
    }
}

function Remove-DirectoryWithRetry {
    param([Parameter(Mandatory)][string]$Path)

    for ($attempt = 1; $attempt -le 5; $attempt++) {
        try {
            if (Test-Path -LiteralPath $Path) {
                Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction Stop
            }
            return
        }
        catch {
            if ($attempt -eq 5) { throw }
            Start-Sleep -Milliseconds (500 * $attempt)
        }
    }
}

function Remove-NatureAIUserPath {
    param([Parameter(Mandatory)][string]$EnvironmentPath)
    $targets = @(
        (Join-Path $EnvironmentPath 'Scripts'),
        $EnvironmentPath
    ) | ForEach-Object { [System.IO.Path]::GetFullPath($_).TrimEnd('\') }
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    if (-not $userPath) { return }
    $kept = @()
    foreach ($entry in ($userPath -split ';')) {
        if (-not $entry.Trim()) { continue }
        $normalized = $null
        try { $normalized = [System.IO.Path]::GetFullPath($entry).TrimEnd('\') } catch { $normalized = $entry.TrimEnd('\') }
        if (-not ($targets | Where-Object { $_.Equals($normalized, [System.StringComparison]::OrdinalIgnoreCase) })) {
            $kept += $entry
        }
    }
    [Environment]::SetEnvironmentVariable('Path', ($kept -join ';'), 'User')
}

$RepositoryRoot = if ($InstallationRoot) { [System.IO.Path]::GetFullPath($InstallationRoot) } else { (Resolve-Path (Join-Path $PSScriptRoot '..')).Path }
$environmentRecord = Resolve-NatureAIEnvironmentPath -EnvironmentName $EnvironmentName
if ($environmentRecord) { Remove-NatureAIUserPath -EnvironmentPath ([string]$environmentRecord) }

Write-Host 'NatureAI Next uninstaller' -ForegroundColor Cyan
Write-Host 'This script never removes NatureAI libraries, photographs, model archives, backups, or exports.' -ForegroundColor Yellow

if ($RemoveEnvironment) {
    if ($PSCmdlet.ShouldProcess("Conda environment '$EnvironmentName'", 'Remove entire environment')) {
        if (-not $environmentRecord) {
            Write-Host "The NatureAI_Next environment '$EnvironmentName' was not found; continuing cleanup." -ForegroundColor Yellow
        }
        else {
            Stop-NatureAIProcesses -EnvironmentPath ([string]$environmentRecord)
            Remove-DirectoryWithRetry -Path ([string]$environmentRecord)
        }
    }
}
else {
    if ($PSCmdlet.ShouldProcess("NatureAI Next package in '$EnvironmentName'", 'Uninstall package')) {
        if (-not $environmentRecord) {
            throw "NatureAI_Next environment '$EnvironmentName' was not found."
        }
        Stop-NatureAIProcesses -EnvironmentPath ([string]$environmentRecord)
        $environmentPython = Join-Path ([string]$environmentRecord) 'python.exe'
        & $environmentPython -m pip uninstall --yes natureai-next
        if ($LASTEXITCODE -ne 0) {
            throw "Unable to uninstall NatureAI_Next from '$EnvironmentName'."
        }
    }
}


$launcherRoot = Join-Path $env:LOCALAPPDATA 'NatureAI\NatureAI Next\Launchers'
$desktopDirectory = [Environment]::GetFolderPath('Desktop')
$shortcutNames = @(
    'Aperture.lnk',
    'Aperture (Debug).lnk',
    'Aperture - Select Library.lnk',
    'Aperture Maintenance Center.lnk',
    'Repair Aperture.lnk',
    'Uninstall Aperture.lnk',
    'NatureAI Next.lnk',
    'NatureAI Next (Debug).lnk',
    'NatureAI Next - Select Library.lnk',
    'NatureAI Next Admin Console.lnk',
    'Repair NatureAI Next.lnk',
    'Uninstall NatureAI Next.lnk'
)
foreach ($shortcutName in $shortcutNames) {
    $shortcutPath = Join-Path $desktopDirectory $shortcutName
    if (Test-Path -LiteralPath $shortcutPath -PathType Leaf) {
        if ($PSCmdlet.ShouldProcess($shortcutPath, 'Remove NatureAI Next desktop shortcut')) {
            Remove-Item -LiteralPath $shortcutPath -Force
        }
    }
}
$startMenuDirectories = @(
    (Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Aperture'),
    (Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\NatureAI Next')
)
foreach ($startMenuDirectory in $startMenuDirectories)
{
    if (Test-Path -LiteralPath $startMenuDirectory -PathType Container) {
        if ($PSCmdlet.ShouldProcess($startMenuDirectory, 'Remove Aperture / NatureAI Next Start Menu shortcuts')) {
            Remove-Item -LiteralPath $startMenuDirectory -Recurse -Force
        }
    }
}
if (Test-Path -LiteralPath $launcherRoot -PathType Container) {
    if ($PSCmdlet.ShouldProcess($launcherRoot, 'Remove machine-local NatureAI Next launchers')) {
        Remove-Item -LiteralPath $launcherRoot -Recurse -Force
    }
}


$registrationRoot = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\NatureAI Next'
if (Test-Path -LiteralPath $registrationRoot) {
    if ($PSCmdlet.ShouldProcess($registrationRoot, 'Remove NatureAI Next Installed Apps registration')) {
        Remove-Item -LiteralPath $registrationRoot -Recurse -Force
    }
}

if ($RemoveInstallationReports) {
    $reportDirectory = Join-Path $RepositoryRoot '.installation'
    if (Test-Path -LiteralPath $reportDirectory) {
        if ($PSCmdlet.ShouldProcess($reportDirectory, 'Remove installation reports')) {
            Remove-Item -LiteralPath $reportDirectory -Recurse -Force
        }
    }
}

if ($RemoveApplicationData) {
    $localData = Join-Path $env:LOCALAPPDATA 'NatureAI\NatureAI Next'
    $roamingData = Join-Path $env:APPDATA 'NatureAI\NatureAI Next'
    foreach ($path in @($localData, $roamingData)) {
        if (Test-Path -LiteralPath $path) {
            if ($PSCmdlet.ShouldProcess($path, 'Remove application configuration, logs, caches, plugins, and installed model registry data')) {
                Remove-Item -LiteralPath $path -Recurse -Force
            }
        }
    }
}

Write-Host 'Uninstall operation completed.' -ForegroundColor Green
Write-Host 'Source folders can be deleted manually after confirming no needed files remain.'
Write-Host 'NatureAI libraries and source photographs were not touched.'
