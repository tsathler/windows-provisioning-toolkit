@{
    # ========================================================================
    # Identidade do modulo
    # ========================================================================

    RootModule        = 'WindowsProvisioningToolkit.psm1'
    ModuleVersion      = '0.5.0'
    GUID              = '5f3a1c8e-2b4d-4e6a-9c7f-1a2b3c4d5e6f'

    Author            = 'Thiago Sathler'
    CompanyName       = 'Nao especificado'
    Copyright         = '(c) 2026. Todos os direitos reservados.'

    Description       = 'Automatiza a instalacao de softwares e a configuracao de estacoes Windows, rede, seguranca e dominio.'

    # ========================================================================
    # Requisitos de ambiente
    # ========================================================================

    PowerShellVersion = '5.1'

    # ========================================================================
    # O que o modulo exporta (a API publica)
    # ========================================================================

    FunctionsToExport = @(
        'Start-WPT', 'Invoke-WPTProvision', 'Get-WPTProvisioningPlan', 'Invoke-WPTHealthCheck', 'Invoke-WPTSecurityAssessment', 'Invoke-WPTSecurityRemediation', 'Save-WPTProvisioningState', 'Get-WPTProvisioningState', 'Clear-WPTProvisioningState', 'Resume-WPTProvisioning'
    )

    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()

    # ========================================================================
    # Metadados extras
    # ========================================================================

    PrivateData = @{
        PSData = @{
            Tags       = @('WindowsProvisioningToolkit', 'Provisioning', 'Windows')
            ProjectUri = 'https://github.com/tsathler/windows-provisioning-toolkit'
        }
    }
}
