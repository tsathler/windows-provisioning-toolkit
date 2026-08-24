# ============================================================================
#
# WindowsProvisioningToolkit - PowerShell Module
#
# Carrega automaticamente os componentes do WindowsProvisioningToolkit
#
# ============================================================================

$moduleRoot = $PSScriptRoot

# ============================================================================
# Ordem dos módulos internos
# ============================================================================

$modules = @(
    "Core"
    "Health"
    "Security"
    "System"
    "Network"
    "Software"
    "UI"
)

# ============================================================================
# Carrega os módulos internos
# ============================================================================

foreach ($module in $modules) {

    $modulePath = Join-Path -Path $moduleRoot -ChildPath $module

    if (-not (Test-Path -LiteralPath $modulePath -PathType Container)) {
        continue
    }

    $scriptFiles = Get-ChildItem `
        -Path $modulePath `
        -Filter "*.ps1" `
        -File |
        Sort-Object Name

    foreach ($scriptFile in $scriptFiles) {
        . $scriptFile.FullName
    }
}

# ============================================================================
# Carrega a API pública
# ============================================================================

$publicPath = Join-Path -Path $moduleRoot -ChildPath "Public"

if (Test-Path -LiteralPath $publicPath -PathType Container) {

    $publicFiles = Get-ChildItem `
        -Path $publicPath `
        -Filter "*.ps1" `
        -File |
        Sort-Object Name

    foreach ($scriptFile in $publicFiles) {
        . $scriptFile.FullName
    }
}

# ============================================================================
# Exporta a API pública
# ============================================================================

Export-ModuleMember -Function Start-WPT, Invoke-WPTProvision, Get-WPTProvisioningPlan, Invoke-WPTHealthCheck, Invoke-WPTSecurityAssessment, Invoke-WPTSecurityRemediation, Save-WPTProvisioningState, Get-WPTProvisioningState, Clear-WPTProvisioningState, Resume-WPTProvisioning
