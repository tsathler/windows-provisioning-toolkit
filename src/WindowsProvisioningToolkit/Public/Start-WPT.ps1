# ============================================================================
#
# WindowsProvisioningToolkit - Start
#
# Ponto de entrada principal da aplicação
#
# ============================================================================

function Start-WPT {

param(
    [string]$ScriptPath = $PSCommandPath
)

<#
.SYNOPSIS
Inicia o processo de configuração do WindowsProvisioningToolkit.

.DESCRIPTION
Coordena a execução dos principais componentes do WindowsProvisioningToolkit.

.OUTPUTS
Boolean
#>

# =========================================================================
# Elevacao
# =========================================================================

if (-not (Test-WPTElevated)) {

        Invoke-WPTElevation `
            -ScriptPath $ScriptPath

        return
    }

# =========================================================================
# Inicializacao
# =========================================================================

Initialize-WPTLogging | Out-Null

Show-WPTBanner

Write-WPTLog `
    -Message "WindowsProvisioningToolkit iniciado." `
    -Level "INFO"


try {

    while ($true) {
        $mainOption = Show-WPTMainMenu

        switch ($mainOption) {
            "1" {
                Invoke-WPTSoftwareInstallationFlow
            }

            "2" {
                Invoke-WPTSystemConfigurationFlow
            }

            "3" {
                Invoke-WPTProfileConfigurationFlow
            }

            "4" {
                Set-WPTDryRun -Enabled (-not (Test-WPTDryRun))
                Read-WPTPause
            }

            "5" {
                Invoke-WPTExecutionProfileFlow
            }

            "6" {
                Write-Host ""
                Write-Host "Executando Health Check. Aguarde..." -ForegroundColor Cyan
                $health = Invoke-WPTHealthCheck
                Write-Host ""
                Write-Host ("Health Check: {0}" -f $health.Status) -ForegroundColor $(if ($health.Status -eq "READY") { "Green" } elseif ($health.Status -eq "READY_WITH_WARNINGS") { "Yellow" } else { "Red" })
                Write-Host ""
                $health.Checks | Format-Table Name, Status, Message -AutoSize | Out-Host
                Read-WPTPause
            }

            "7" {
                Write-Host ""
                Write-Host "Executando Avaliacao de Seguranca. Aguarde..." -ForegroundColor Cyan
                $assessment = Invoke-WPTSecurityAssessment
                $assessment.Checks | Format-Table Name, Status, Message -AutoSize
                Read-WPTPause
            }

            "0" {
                Write-WPTLog `
                    -Message "WindowsProvisioningToolkit finalizado pelo usuario." `
                    -Level "INFO"

                return $true
            }
        }
    }
}
catch {

    Write-WPTLog `
        -Message "Falha na execução do WindowsProvisioningToolkit: $($_.Exception.Message)" `
        -Level "ERROR"


    return $false
}

}

function Invoke-WPTSoftwareInstallationFlow {

    $softwareList = @(Get-WPTSoftware)
    $selectedSoftware = @(Show-WPTSoftwareSelectionMenu -SoftwareList $softwareList)

    if ($selectedSoftware.Count -eq 0) {
        Write-WPTLog `
            -Message "Nenhum software selecionado. Instalacao de aplicativos cancelada." `
            -Level "WARNING"

        return
    }

    foreach ($software in $selectedSoftware) {
        Write-WPTLog `
            -Message "Usuario selecionou: $($software.Name)" `
            -Level "INFO"
    }

    $tasks = @(Get-WPTSoftwareTasks -SoftwareList $selectedSoftware)

    $result = Invoke-WPTTasks `
        -Tasks $tasks

    Show-WPTSummary -Result $result
    Export-WPTExecutionReport -Result $result -Context "Software" | Out-Null

    Read-WPTPause
}

function Invoke-WPTSystemConfigurationFlow {

    while ($true) {
        $systemOption = Show-WPTSystemConfigurationMenu

        switch ($systemOption) {
            "1" {
                Invoke-WPTCredentialDelegationTestFlow
            }

            "2" {
                Invoke-WPTDomainJoinFlow
            }

            "3" {
                Invoke-WPTUserConfigurationFlow
            }

            "4" {
                Invoke-WPTFullSystemConfigurationFlow
            }

            "0" {
                return
            }
        }
    }
}

function Invoke-WPTProfileConfigurationFlow {

    while ($true) {
        $profileOption = Show-WPTProfileConfigurationMenu

        switch ($profileOption) {
            "1" {
                Show-WPTActiveProfile
                Read-WPTPause
            }

            "2" {
                Set-WPTCorporateLocalConfig
                Read-WPTPause
            }

            "3" {
                Clear-WPTCorporateLocalConfig | Out-Null
                Read-WPTPause
            }

            "0" {
                return
            }
        }
    }
}

function Invoke-WPTExecutionProfileFlow {

    while ($true) {
        $profileOption = Show-WPTExecutionProfileMenu

        switch ($profileOption) {
            "1" {
                Invoke-WPTPortfolioExecutionProfile
            }

            "2" {
                Invoke-WPTCorporateBasicExecutionProfile
            }

            "3" {
                Invoke-WPTCorporateFullExecutionProfile
            }

            "4" {
                Invoke-WPTSoftwareOnlyExecutionProfile
            }

            "5" {
                Invoke-WPTSystemOnlyExecutionProfile
            }

            "0" {
                return
            }
        }
    }
}

function Invoke-WPTCredentialDelegationTestFlow {

    Write-WPTLog `
        -Message "Iniciando teste de delegacao de credenciais RDP." `
        -Level "INFO"

    $tasks = @(
        @{
            Name = "Delegacao de credenciais RDP"
            Condition = {
                -not (Test-WPTCredentialDelegation)
            }
            Action = {
                Set-WPTCredentialDelegation
            }
        }
    )

    $result = Invoke-WPTTasks `
        -Tasks $tasks

    Show-WPTSummary -Result $result
    Export-WPTExecutionReport -Result $result -Context "CredentialDelegation" | Out-Null

    Read-WPTPause
}

function Invoke-WPTDomainJoinFlow {

    Write-WPTLog `
        -Message "Iniciando fluxo de entrada no dominio." `
        -Level "INFO"

    Clear-WPTRestartState

    $tasks = @(
        @{
            Name = "Adicionar ao dominio"
            Action = {
                Add-WPTComputerToDomain -Prompt
            }
        }
    )

    $result = Invoke-WPTTasks `
        -Tasks $tasks

    Show-WPTSummary -Result $result

    Show-WPTRestartSummary
    Export-WPTExecutionReport -Result $result -Context "DomainJoin" | Out-Null

    Read-WPTPause
}

function Invoke-WPTFullSystemConfigurationFlow {

    Write-WPTLog `
        -Message "Iniciando configuracao completa do sistema." `
        -Level "INFO"

    $steps = @(
        "Delegacao de credenciais RDP"
        "Adicionar ao dominio: perguntar antes"
        "Configuracao do usuario atual"
    )

    if (-not (Confirm-WPTExecutionPlan -Title "Configuracao completa do sistema" -Steps $steps)) {
        Write-WPTLog `
            -Message "Configuracao completa do sistema cancelada pelo usuario." `
            -Level "SKIPPED"

        return
    }

    Clear-WPTRestartState

    $tasks = @(New-WPTSystemConfigurationTasks -IncludeDomain -IncludeUser)

    $result = Invoke-WPTTasks `
        -Tasks $tasks

    Show-WPTSummary -Result $result

    Show-WPTRestartSummary
    Export-WPTExecutionReport -Result $result -Context "FullSystemConfiguration" | Out-Null

    Read-WPTPause
}

function Invoke-WPTPortfolioExecutionProfile {

    $steps = @(
        "Delegacao de credenciais RDP"
        "Configuracao do usuario atual"
    )

    Invoke-WPTSystemTaskProfile `
        -Title "Portfolio" `
        -Context "ExecutionProfile-Portfolio" `
        -Steps $steps `
        -Tasks @(New-WPTSystemConfigurationTasks -IncludeUser)
}

function Invoke-WPTCorporateBasicExecutionProfile {

    $steps = @(
        "Delegacao de credenciais RDP"
        "Adicionar ao dominio: perguntar antes"
    )

    Invoke-WPTSystemTaskProfile `
        -Title "Corporate basico" `
        -Context "ExecutionProfile-CorporateBasic" `
        -Steps $steps `
        -Tasks @(New-WPTSystemConfigurationTasks -IncludeDomain)
}

function Invoke-WPTCorporateFullExecutionProfile {

    $steps = @(
        "Delegacao de credenciais RDP"
        "Adicionar ao dominio: perguntar antes"
        "Configuracao do usuario atual"
    )

    Invoke-WPTSystemTaskProfile `
        -Title "Corporate completo" `
        -Context "ExecutionProfile-CorporateFull" `
        -Steps $steps `
        -Tasks @(New-WPTSystemConfigurationTasks -IncludeDomain -IncludeUser)
}

function Invoke-WPTSoftwareOnlyExecutionProfile {

    $steps = @(
        "Selecao manual de aplicativos"
        "Instalacao somente dos aplicativos selecionados"
    )

    if (-not (Confirm-WPTExecutionPlan -Title "Somente aplicativos" -Steps $steps)) {
        Write-WPTLog `
            -Message "Perfil Somente aplicativos cancelado pelo usuario." `
            -Level "SKIPPED"

        return
    }

    Invoke-WPTSoftwareInstallationFlow
}

function Invoke-WPTSystemOnlyExecutionProfile {

    $steps = @(
        "Selecionar uma configuracao de sistema"
        "Executar somente tarefas de sistema"
    )

    if (-not (Confirm-WPTExecutionPlan -Title "Somente sistema" -Steps $steps)) {
        Write-WPTLog `
            -Message "Perfil Somente sistema cancelado pelo usuario." `
            -Level "SKIPPED"

        return
    }

    Invoke-WPTSystemConfigurationFlow
}

function Invoke-WPTSystemTaskProfile {

param(
    [Parameter(Mandatory = $true)]
    [string]$Title,

    [Parameter(Mandatory = $true)]
    [string]$Context,

    [Parameter(Mandatory = $true)]
    [string[]]$Steps,

    [Parameter(Mandatory = $true)]
    [array]$Tasks
)

    Write-WPTLog `
        -Message "Iniciando perfil de execucao: $Title." `
        -Level "INFO"

    if (-not (Confirm-WPTExecutionPlan -Title $Title -Steps $Steps)) {
        Write-WPTLog `
            -Message "Perfil de execucao cancelado pelo usuario: $Title." `
            -Level "SKIPPED"

        return
    }

    Clear-WPTRestartState

    $result = Invoke-WPTTasks `
        -Tasks $Tasks

    Show-WPTSummary -Result $result

    Show-WPTRestartSummary
    Export-WPTExecutionReport -Result $result -Context $Context | Out-Null

    Read-WPTPause
}

function New-WPTSystemConfigurationTasks {

param(
    [switch]$IncludeDomain,
    [switch]$IncludeUser
)

    $tasks = @(
        @{
            Name = "Delegacao de credenciais RDP"
            Condition = {
                -not (Test-WPTCredentialDelegation)
            }
            Action = {
                Set-WPTCredentialDelegation
            }
        }
    )

    if ($IncludeDomain) {
        $tasks += @{
            Name = "Adicionar ao dominio"
            Action = {
                Add-WPTComputerToDomain `
                    -Prompt `
                    -SuppressRestartPrompt
            }
        }
    }

    if ($IncludeUser) {
        $tasks += @{
            Name = "Configuracao do usuario"
            Action = {
                Invoke-WPTUserConfiguration
            }
        }
    }

    return $tasks
}

function Confirm-WPTExecutionPlan {

param(
    [Parameter(Mandatory = $true)]
    [string]$Title,

    [Parameter(Mandatory = $true)]
    [string[]]$Steps
)

    $config = Get-WPTConfig
    $dryRunStatus = Get-WPTDryRunStatus

    Clear-Host
    Show-WPTBanner

    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "        RESUMO PRE-EXECUCAO" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host ("Perfil escolhido: {0}" -f $Title)
    Write-Host ("Perfil ativo:     {0}" -f $config.Profile.Name)
    Write-Host ("Dry Run:          {0}" -f $dryRunStatus)
    Write-Host ""
    Write-Host "Sera executado:"

    foreach ($step in $Steps) {
        Write-Host ("- {0}" -f $step)
    }

    Write-Host ""

    if ($Steps -match "dominio") {
        Write-Host "Entrada no dominio depende de confirmacao durante a execucao." -ForegroundColor Yellow
        Write-Host ""
    }

    $confirmation = Read-Host "Deseja continuar? (S/N)"

    return ($confirmation -match "^[sS]$")
}

function Invoke-WPTUserConfigurationFlow {

    Write-WPTLog `
        -Message "Iniciando fluxo de configuracao do usuario." `
        -Level "INFO"

    $tasks = @(
        @{
            Name = "Configuracao do usuario"
            Action = {
                Invoke-WPTUserConfiguration
            }
        }
    )

    $result = Invoke-WPTTasks `
        -Tasks $tasks

    Show-WPTSummary -Result $result
    Export-WPTExecutionReport -Result $result -Context "UserConfiguration" | Out-Null

    Read-WPTPause
}

function Show-WPTSummary {

param(
    [Parameter(Mandatory = $true)]
    [hashtable]$Result
)

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "         EXECUCAO FINALIZADA" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    if (Test-WPTDryRun) {
        Write-Host "[DRY RUN] Simulacao ativa. Nenhuma alteracao destrutiva foi aplicada." -ForegroundColor Yellow
        Write-Host ""
    }

    foreach ($detail in $Result.Details) {
        switch ($detail.Status) {
            "SUCCESS" {
                Write-Host ("[SUCCESS] {0}" -f $detail.Name) -ForegroundColor Green
            }
            "SKIPPED" {
                Write-Host ("[SKIP]    {0}" -f $detail.Name) -ForegroundColor DarkGray
            }
            "FAILURE" {
                Write-Host ("[ERROR]   {0}" -f $detail.Name) -ForegroundColor Red
            }
        }
    }

    Write-Host ""
    Write-Host "----------------------------------------"
    Write-Host ("Total:      {0}" -f $Result.Total)
    Write-Host ("Sucesso:    {0}" -f $Result.Success)
    Write-Host ("Ignorados:  {0}" -f $Result.Skipped)
    Write-Host ("Erros:      {0}" -f $Result.Failure)
    Write-Host ""
}

function Show-WPTRestartSummary {

    $restartState = Get-WPTRestartState

    if (-not $restartState.Required) {
        return
    }

    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "        REINICIALIZACAO NECESSARIA" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""

    foreach ($reason in $restartState.Reasons) {
        Write-Host ("[WARNING] {0}" -f $reason) -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "Reinicie o computador depois de concluir as configuracoes." -ForegroundColor Yellow
    Write-Host ""
}
