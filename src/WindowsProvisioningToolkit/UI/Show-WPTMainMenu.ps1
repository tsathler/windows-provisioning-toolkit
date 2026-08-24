# ============================================================================
#
# WindowsProvisioningToolkit - Main Menu
#
# Exibe o menu principal do WindowsProvisioningToolkit
#
# ============================================================================

function Show-WPTMainMenu {

    Clear-Host
    Show-WPTBanner

    Write-Host "[1] Instalacao de Aplicativos"
    Write-Host "[2] Configuracao do Sistema"
    Write-Host "[3] Perfil e Configuracao"
    Write-Host "[4] Alternar Dry Run ($(Get-WPTDryRunStatus))"
    Write-Host "[5] Perfis de Execucao"
    Write-Host "[6] Executar Health Check"
    Write-Host "[7] Avaliacao de Seguranca"
    Write-Host ""
    Write-Host "[0] Sair"
    Write-Host ""

    return Read-Host "Digite uma opcao"
}
