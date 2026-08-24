# ============================================================================
#
# WindowsProvisioningToolkit - Software Configuration
#
# Carrega a configuração de softwares do WindowsProvisioningToolkit
#
# ============================================================================


function Get-WPTSoftware {

    $configPath = Join-Path `
        -Path $PSScriptRoot `
        -ChildPath "software.config.json"


    if (-not (Test-Path -LiteralPath $configPath)) {

        throw "Arquivo de configuracao de softwares nao encontrado: $configPath"
    }


    try {

        $software = Get-Content `
            -Path $configPath `
            -Raw `
            -ErrorAction Stop |
        ConvertFrom-Json `
            -ErrorAction Stop

    }
    catch {

        throw "Falha ao carregar software.config.json: $($_.Exception.Message)"
    }


    $softwareList = @($software.Software)

    Test-WPTSoftwareCatalog -SoftwareList $softwareList | Out-Null

    return $softwareList
}

function Test-WPTSoftwareCatalog {

    param(
        [Parameter(Mandatory = $true)]
        [array]$SoftwareList
    )

    if ($null -eq $softwareList -or $softwareList.Count -eq 0) {
        throw "software.config.json nao possui softwares configurados."
    }

    foreach ($softwareItem in $softwareList) {
        if ([string]::IsNullOrWhiteSpace($softwareItem.Name)) {
            throw "Configuracao de software invalida: Name e obrigatorio."
        }

        if (-not $softwareItem.DetectionNames -or @($softwareItem.DetectionNames).Count -eq 0) {
            throw "Configuracao de software invalida para $($softwareItem.Name): DetectionNames e obrigatorio."
        }

        if (-not $softwareItem.Source -or [string]::IsNullOrWhiteSpace($softwareItem.Source.Type)) {
            throw "Configuracao de software invalida para $($softwareItem.Name): Source.Type e obrigatorio."
        }

        if ($softwareItem.Source.Type -eq "Winget" -and [string]::IsNullOrWhiteSpace($softwareItem.Source.PackageId)) {
            throw "Configuracao de software invalida para $($softwareItem.Name): Source.PackageId e obrigatorio para Winget."
        }

        if ($softwareItem.Source.Type -eq "Download" -and [string]::IsNullOrWhiteSpace($softwareItem.Source.Url)) {
            throw "Configuracao de software invalida para $($softwareItem.Name): Source.Url e obrigatorio para Download."
        }
    }

    return $true
}
