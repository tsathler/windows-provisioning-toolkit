# ============================================================================
#
# WindowsProvisioningToolkit - Execution Report
#
# Exporta resumo da execucao para consulta posterior
#
# ============================================================================

function Export-WPTExecutionReport {

    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Result,

        [string]$Context = "WindowsProvisioningToolkit"
    )

    $config = Get-WPTConfig
    $reportDirectory = $config.Paths.Reports

    if ([string]::IsNullOrWhiteSpace($reportDirectory)) {
        $reportDirectory = Join-Path `
            -Path $config.Paths.Data `
            -ChildPath "Reports"
    }

    if (-not (Test-Path -LiteralPath $reportDirectory)) {
        New-Item `
            -Path $reportDirectory `
            -ItemType Directory `
            -Force `
            -ErrorAction Stop |
        Out-Null
    }

    $timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
    $safeContext = $Context -replace "[^a-zA-Z0-9_-]", "_"
    $reportPath = Join-Path `
        -Path $reportDirectory `
        -ChildPath "WindowsProvisioningToolkit_${safeContext}_$timestamp.json"

    $restartState = Get-WPTRestartState

    $report = [pscustomobject]@{
        Application = $config.Application.Name
        Version = $config.Application.Version
        Profile = $config.Profile.Name
        Context = $Context
        ComputerName = $env:COMPUTERNAME
        UserName = [Security.Principal.WindowsIdentity]::GetCurrent().Name
        DryRun = Test-WPTDryRun
        Timestamp = (Get-Date).ToString("s")
        RestartRequired = $restartState.Required
        RestartReasons = @($restartState.Reasons)
        HealthCheck = if(Get-Variable -Name WPTLastHealthCheck -Scope Script -ErrorAction SilentlyContinue){$script:WPTLastHealthCheck}else{$null}
        SecurityAssessment = if(Get-Variable -Name WPTLastSecurityAssessment -Scope Script -ErrorAction SilentlyContinue){$script:WPTLastSecurityAssessment}else{$null}
        Summary = [pscustomobject]@{
            Total = $Result.Total
            Success = $Result.Success
            Skipped = $Result.Skipped
            Failure = $Result.Failure
        }
        Details = @($Result.Details)
    }

    $report |
        ConvertTo-Json -Depth 8 |
        Set-Content `
            -LiteralPath $reportPath `
            -Encoding UTF8 `
            -ErrorAction Stop

    Write-WPTLog `
        -Message "Relatorio de execucao exportado: $reportPath" `
        -Level "SUCCESS"

    return $reportPath
}
