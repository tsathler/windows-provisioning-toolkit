# ============================================================================
#
# WindowsProvisioningToolkit - Software Selection
#
# Exibe o menu de selecao de softwares do MVP
#
# ============================================================================

function Show-WPTSoftwareSelectionMenu {

    param(
        [Parameter(Mandatory = $true)]
        [array]$SoftwareList
    )

    $selectedIndexes = New-Object 'System.Collections.Generic.HashSet[int]'

    while ($true) {
        Clear-Host
        Show-WPTBanner

        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "          SELECAO DE SOFTWARE" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host ""

        $lastCategory = $null

        for ($index = 0; $index -lt $SoftwareList.Count; $index++) {
            $category = if ($SoftwareList[$index].Optional) { "Softwares opcionais" } else { "Softwares padrao" }

            if ($category -ne $lastCategory) {
                Write-Host ""
                Write-Host $category -ForegroundColor Yellow
                $lastCategory = $category
            }

            $number = $index + 1
            $marker = if ($selectedIndexes.Contains($index)) { "[X]" } else { "[ ]" }

            Write-Host ("{0} [{1}] {2}" -f $marker, $number, $SoftwareList[$index].Name)
        }

        Write-Host ""
        Write-Host "----------------------------------------"
        Write-Host "[7] Selecionar todos"
        Write-Host "[8] Continuar"
        Write-Host "[0] Cancelar"
        Write-Host ""

        $option = Read-Host "Digite uma opcao"

        if ($option -eq "0") {
            return @()
        }

        if ($option -eq "7") {
            $selectedIndexes.Clear()

            for ($index = 0; $index -lt $SoftwareList.Count; $index++) {
                [void]$selectedIndexes.Add($index)
            }

            continue
        }

        if ($option -eq "8") {
            return @(
                for ($index = 0; $index -lt $SoftwareList.Count; $index++) {
                    if ($selectedIndexes.Contains($index)) {
                        $SoftwareList[$index]
                    }
                }
            )
        }

        $parsedOption = 0

        if ([int]::TryParse($option, [ref]$parsedOption)) {
            $selectedIndex = $parsedOption - 1

            if ($selectedIndex -ge 0 -and $selectedIndex -lt $SoftwareList.Count) {
                if ($selectedIndexes.Contains($selectedIndex)) {
                    [void]$selectedIndexes.Remove($selectedIndex)
                }
                else {
                    [void]$selectedIndexes.Add($selectedIndex)
                }
            }
        }
    }
}
