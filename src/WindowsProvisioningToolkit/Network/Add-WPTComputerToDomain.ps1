# ============================================================================
#
# WindowsProvisioningToolkit - Add Computer To Domain
#
# Adiciona o computador a um dominio informado pelo usuario
#
# ============================================================================

function Get-WPTComputerDomainState {

    try {
        $computerSystem = Get-CimInstance `
            -ClassName Win32_ComputerSystem `
            -ErrorAction Stop
    }
    catch {
        $computerSystem = Get-WmiObject `
            -Class Win32_ComputerSystem `
            -ErrorAction Stop
    }

    return [pscustomobject]@{
        ComputerName = $env:COMPUTERNAME
        PartOfDomain = [bool]$computerSystem.PartOfDomain
        Domain = $computerSystem.Domain
        Workgroup = $computerSystem.Workgroup
    }
}


function Test-WPTDomainName {

    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$DomainName
    )

    if ([string]::IsNullOrWhiteSpace($DomainName)) {
        throw "O dominio nao pode estar vazio."
    }

    if ($DomainName -notmatch "^[a-zA-Z0-9.-]+$") {
        throw "O dominio informado possui caracteres invalidos."
    }

    if ($DomainName.StartsWith(".") -or $DomainName.EndsWith(".")) {
        throw "O dominio nao pode comecar ou terminar com ponto."
    }

    return $true
}


function Add-WPTComputerToDomain {

    param(
        [string]$DomainName,

        [switch]$Prompt,

        [switch]$Unattended,

        [switch]$SuppressRestartPrompt
    )

    Write-WPTLog `
        -Message "Verificando associacao do computador ao dominio..." `
        -Level "INFO"

    $config = Get-WPTConfig
    $domainConfig = $config.System.Domain
    $defaultDomainName = $domainConfig.DefaultDomainName
    $suggestDefaultDomain = [bool]$domainConfig.SuggestDefaultDomain

    if ($Prompt -and -not $Unattended) {
        $answer = Read-Host "Deseja adicionar este computador ao dominio? (S/N)"

        if ($answer -notmatch "^[Ss]$") {
            Write-WPTLog `
                -Message "Entrada no dominio ignorada pelo usuario." `
                -Level "SKIPPED"

            return "SKIPPED"
        }
    }

    if ([string]::IsNullOrWhiteSpace($DomainName) -and $Unattended) {
        throw "O dominio deve ser informado no modo unattended."
    }

    if ([string]::IsNullOrWhiteSpace($DomainName)) {
        if (
            $suggestDefaultDomain -and
            -not [string]::IsNullOrWhiteSpace($defaultDomainName)
        ) {
            $typedDomain = Read-Host "Digite o dominio [$defaultDomainName]"

            if ([string]::IsNullOrWhiteSpace($typedDomain)) {
                $DomainName = $defaultDomainName
            }
            else {
                $DomainName = $typedDomain
            }
        }
        else {
            $DomainName = Read-Host "Digite o dominio"
        }
    }

    Test-WPTDomainName -DomainName $DomainName | Out-Null

    $domainState = Get-WPTComputerDomainState

    if ($domainState.PartOfDomain) {
        if ($domainState.Domain -ieq $DomainName) {
            Write-WPTLog `
                -Message "Computador ja pertence ao dominio $DomainName." `
                -Level "SKIPPED"

            return "SKIPPED"
        }

        throw "Computador ja pertence ao dominio $($domainState.Domain). Remova ou migre manualmente antes de adicionar a outro dominio."
    }

    Write-WPTLog `
        -Message "Computador ainda nao pertence a um dominio. Dominio atual/workgroup: $($domainState.Domain)." `
        -Level "INFO"

    if (Test-WPTDryRun) {
        Write-WPTLog `
            -Message "[DRY RUN] Computador seria adicionado ao dominio $DomainName. Credenciais nao foram solicitadas e nenhuma alteracao foi feita." `
            -Level "WARNING"

        Set-WPTRestartRequired `
            -Reason "Entrada no dominio $DomainName (simulada)"

        return $true
    }

    if ($Unattended) {
        throw "Credenciais do dominio devem ser fornecidas por um fluxo nao interativo."
    }

    Write-Host ""
    Write-Host "Credenciais administrativas do dominio" -ForegroundColor Cyan
    Write-Host "Informe uma conta autorizada a adicionar computadores ao dominio."
    Write-Host ""

    $credential = Get-Credential `
        -Message "Credenciais para adicionar o computador ao dominio $DomainName"

    if (-not $credential) {
        throw "Credenciais do dominio nao foram fornecidas."
    }

    Write-WPTLog `
        -Message "Adicionando computador ao dominio $DomainName..." `
        -Level "INFO"

    try {
        Add-Computer `
            -DomainName $DomainName `
            -Credential $credential `
            -ErrorAction Stop

        Write-WPTLog `
            -Message "Computador adicionado ao dominio $DomainName com sucesso." `
            -Level "SUCCESS"

        Write-WPTLog `
            -Message "Reinicializacao necessaria para concluir a entrada no dominio." `
            -Level "WARNING"

        Set-WPTRestartRequired `
            -Reason "Entrada no dominio $DomainName"

        if (-not $SuppressRestartPrompt) {
            Show-WPTRestartPrompt
        }

        return $true
    }
    catch {
        Write-WPTLog `
            -Message "Falha ao adicionar computador ao dominio: $($_.Exception.Message)" `
            -Level "ERROR"

        throw
    }
}


function Show-WPTRestartPrompt {

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "        REINICIALIZACAO NECESSARIA" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Algumas alteracoes precisam de reinicializacao."
    Write-Host ""
    Write-Host "[1] Reiniciar agora"
    Write-Host "[2] Reiniciar depois"
    Write-Host ""

    $option = Read-Host "Digite uma opcao"

    if ($option -eq "1") {
        Write-WPTLog `
            -Message "Reinicializacao solicitada pelo usuario." `
            -Level "WARNING"

        if (Test-WPTDryRun) {
            Write-WPTLog `
                -Message "[DRY RUN] Reinicializacao seria executada. Nenhuma alteracao foi feita." `
                -Level "WARNING"

            return
        }

        Restart-Computer
        return
    }

    Write-WPTLog `
        -Message "Reinicializacao adiada pelo usuario." `
        -Level "WARNING"
}
