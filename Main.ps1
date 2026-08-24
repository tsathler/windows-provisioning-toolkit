# ============================================================================
#
# WindowsProvisioningToolkit
#
# Main entry point
#
# ============================================================================

param(
    [string]$Profile = 'Portfolio',
    [switch]$Unattended,
    [switch]$DryRun,
    [switch]$NoPause,
    [switch]$SkipHealthCheck,
    [switch]$Resume,
    [string]$Config
)

$ErrorActionPreference = "Stop"

if ($NoPause) {
    $env:WPT_NO_PAUSE = "1"
}

$rootPath = Split-Path -Parent $PSCommandPath
$moduleManifest = Join-Path -Path $rootPath -ChildPath "src\WindowsProvisioningToolkit\WindowsProvisioningToolkit.psd1"

try {
    Import-Module $moduleManifest -Force

    if($Unattended -or $DryRun -or $Resume -or $SkipHealthCheck -or $Config -or $Profile -ne 'Portfolio') {
        if (-not (Test-WPTElevated)) {
            $arguments = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', ('"{0}"' -f $PSCommandPath))
            if ($Profile) { $arguments += @('-Profile', ('"{0}"' -f $Profile)) }
            if ($Unattended) { $arguments += '-Unattended' }
            if ($DryRun) { $arguments += '-DryRun' }
            if ($NoPause) { $arguments += '-NoPause' }
            if ($SkipHealthCheck) { $arguments += '-SkipHealthCheck' }
            if ($Resume) { $arguments += '-Resume' }
            if ($Config) { $arguments += @('-Config', ('"{0}"' -f $Config)) }
            Start-Process -FilePath 'powershell.exe' -ArgumentList $arguments -Verb RunAs -ErrorAction Stop | Out-Null
            exit 0
        }
        $code=Invoke-WPTProvision -Profile $Profile -Unattended:$Unattended -DryRun:$DryRun -NoPause:$NoPause -SkipHealthCheck:$SkipHealthCheck -Resume:$Resume -Config $Config
        exit $code
    }
    Start-WPT -ScriptPath $PSCommandPath
}
catch {
    Write-Host ""
    Write-Host "ERRO ENCONTRADO:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    if (-not $NoPause) {
        Read-Host "Pressione ENTER para fechar"
    }
    exit 1
}
