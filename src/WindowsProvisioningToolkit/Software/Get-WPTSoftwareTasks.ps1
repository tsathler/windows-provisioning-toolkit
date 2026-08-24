# ============================================================================
#
# WindowsProvisioningToolkit - Software Tasks
#
# Gera tarefas de instalacao de softwares a partir do software.config.json
#
# ============================================================================

function Get-WPTSoftwareTasks {

    param(
        [array]$SoftwareList = @(Get-WPTSoftware | Where-Object { -not $_.Optional })
    )

    $testSoftwareInstalled = ${function:Test-WPTSoftwareInstalled}
    $installSoftware = ${function:Install-WPTSoftware}
    $writeLog = ${function:Write-WPTLog}

    foreach ($software in $softwareList) {

        $softwareName = $software.Name
        $softwareData = $software

        @{
            Name = $softwareName

            Condition = {
                & $writeLog `
                    -Message "Verificando instalacao de $softwareName..." `
                    -Level "INFO"

                $isInstalled = & $testSoftwareInstalled -Software $softwareData

                if ($isInstalled) {
                    & $writeLog `
                        -Message "$softwareName ja esta instalado." `
                        -Level "SKIPPED"

                    return $false
                }

                & $writeLog `
                    -Message "$softwareName nao encontrado." `
                    -Level "INFO"

                return $true
            }.GetNewClosure()

            Action = {
                & $installSoftware -Software $softwareData

                if (-not (& $testSoftwareInstalled -Software $softwareData)) {
                    throw "$softwareName nao foi encontrado apos a instalacao."
                }

                if ($softwareData.VerifyNotInstalled) {
                    foreach ($blockedSoftware in $softwareData.VerifyNotInstalled) {
                        if (& $testSoftwareInstalled -SoftwareName $blockedSoftware) {
                            throw "$blockedSoftware foi encontrado, mas nao deveria ter sido instalado."
                        }

                        & $writeLog `
                            -Message "$blockedSoftware nao instalado." `
                            -Level "INFO"
                    }
                }
            }.GetNewClosure()
        }
    }
}
