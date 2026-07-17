[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Library,
    [string]$EnvironmentName = 'natureai-next',
    [switch]$SafeMode,
    [switch]$Diagnostics,
    [ValidateSet('DEBUG', 'INFO', 'WARNING', 'ERROR')]
    [string]$LogLevel = 'INFO'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$arguments = @('run', '--no-capture-output', '-n', $EnvironmentName, 'natureai-next', '--library', $Library, '--log-level', $LogLevel)
if ($SafeMode) { $arguments += '--safe-mode' }
if ($Diagnostics) { $arguments += '--diagnostics' }

& conda @arguments
exit $LASTEXITCODE
