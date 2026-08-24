# ============================================================================
#
# WindowsProvisioningToolkit - Configuration
#
# Carrega configuracoes Portfolio e Corporate local quando existir
#
# ============================================================================

function Merge-WPTConfig {

    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Base,

        [Parameter(Mandatory = $true)]
        [hashtable]$Override
    )

    foreach ($key in $Override.Keys) {
        if (
            $Base.ContainsKey($key) -and
            ($Base[$key] -is [hashtable]) -and
            ($Override[$key] -is [hashtable])
        ) {
            Merge-WPTConfig `
                -Base $Base[$key] `
                -Override $Override[$key]
        }
        else {
            $Base[$key] = $Override[$key]
        }
    }
}


function ConvertTo-WPTHashtable {

    param(
        [Parameter(Mandatory = $true)]
        $InputObject
    )

    if ($InputObject -is [System.Collections.IDictionary]) {
        $hash = @{}

        foreach ($key in $InputObject.Keys) {
            $hash[$key] = ConvertTo-WPTHashtable -InputObject $InputObject[$key]
        }

        return $hash
    }

    if ($InputObject -is [pscustomobject]) {
        $hash = @{}

        foreach ($property in $InputObject.PSObject.Properties) {
            $hash[$property.Name] = ConvertTo-WPTHashtable -InputObject $property.Value
        }

        return $hash
    }

    if ($InputObject -is [array]) {
        return @(
            foreach ($item in $InputObject) {
                ConvertTo-WPTHashtable -InputObject $item
            }
        )
    }

    return $InputObject
}


function Import-WPTJsonConfig {

    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Arquivo de configuracao nao encontrado: $Path"
    }

    $content = Get-Content `
        -LiteralPath $Path `
        -Raw `
        -ErrorAction Stop

    if ([string]::IsNullOrWhiteSpace($content)) {
        return @{}
    }

    return ConvertTo-WPTHashtable `
        -InputObject ($content | ConvertFrom-Json -ErrorAction Stop)
}


function Get-WPTConfigRoot {

    if (-not [string]::IsNullOrWhiteSpace($env:WPT_CONFIG_ROOT)) {
        return $env:WPT_CONFIG_ROOT
    }

    return Join-Path `
        -Path (Split-Path -Parent $PSScriptRoot) `
        -ChildPath "Config"
}


function Get-WPTConfig {

    $configRoot = Get-WPTConfigRoot

    $standardPath = Join-Path `
        -Path $configRoot `
        -ChildPath "Standard.json"

    $corporateLocalPath = Join-Path `
        -Path $configRoot `
        -ChildPath "Corporate.local.json"

    $config = Import-WPTJsonConfig -Path $standardPath

    if (Test-Path -LiteralPath $corporateLocalPath) {
        $corporateConfig = Import-WPTJsonConfig -Path $corporateLocalPath

        Merge-WPTConfig `
            -Base $config `
            -Override $corporateConfig
    }

    Test-WPTConfig -Config $config | Out-Null
    return $config
}

function Test-WPTConfig {
    param([Parameter(Mandatory = $true)][hashtable]$Config)

    foreach ($section in @('Application', 'Profile', 'Paths', 'Settings', 'System')) {
        if (-not $Config.ContainsKey($section)) {
            throw "Configuracao invalida: secao obrigatoria ausente: $section"
        }
    }

    if (-not $Config.ContainsKey('HealthCheck')) { $Config.HealthCheck = @{} }
    if (-not $Config.ContainsKey('Execution')) { $Config.Execution = @{ AllowAutomaticReboot=$false; StopOnHealthFailure=$true; ContinueOnWarning=$true } }
    if (-not $Config.ContainsKey('Security')) { $Config.Security = @{} }

    foreach ($pathName in @('Data', 'Logs', 'Reports')) {
        if ([string]::IsNullOrWhiteSpace([string]$Config.Paths[$pathName])) {
            throw "Configuracao invalida: caminho obrigatorio ausente: Paths.$pathName"
        }
    }

    if ([string]::IsNullOrWhiteSpace([string]$Config.Application.Version)) {
        throw "Configuracao invalida: Application.Version nao informado."
    }

    return $true
}
