$modulePath = Join-Path -Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) -ChildPath "src\WindowsProvisioningToolkit\WindowsProvisioningToolkit.psd1"

Import-Module $modulePath -Force

Describe "Catalogo e tarefas de software" {

    It "carrega softwares obrigatorios e opcionais" {
        $module = Get-Module WindowsProvisioningToolkit
        $software = & $module { @(Get-WPTSoftware) }

        ($software | Where-Object { -not $_.Optional }).Count | Should BeGreaterThan 0
        ($software | Where-Object { $_.Optional }).Count | Should Be 3
    }

    It "nao inclui opcionais quando tarefas sao criadas sem selecao" {
        $module = Get-Module WindowsProvisioningToolkit
        $tasks = & $module { @(Get-WPTSoftwareTasks) }

        ($tasks.Name -contains "CPU-Z") | Should Be $false
        ($tasks.Name -contains "HWMonitor") | Should Be $false
    }

    It "marca software instalado como SKIPPED sem instalar" {
        $module = Get-Module WindowsProvisioningToolkit
        $result = & $module {
            $script:LogFilePath = Join-Path $env:TEMP "windows-provisioning-toolkit-pester-software.log"
            Mock Test-WPTSoftwareInstalled { $true } -ModuleName WindowsProvisioningToolkit
            Mock Install-WPTSoftware { throw "Instalacao nao deveria ocorrer" } -ModuleName WindowsProvisioningToolkit
            $cpu = Get-WPTSoftware | Where-Object { $_.Name -eq "CPU-Z" }
            $task = @(Get-WPTSoftwareTasks -SoftwareList @($cpu))[0]
            $task["Name"] | Should Be "CPU-Z" | Out-Null
            Invoke-WPTTask -TaskName $task.Name -Condition $task.Condition -Action $task.Action
        }

        $result | Should Be "SKIPPED"
    }

    It "rejeita configuracao sem PackageId Winget" {
        $module = Get-Module WindowsProvisioningToolkit
        $threw = & $module {
            try {
                Test-WPTSoftwareCatalog -SoftwareList @([pscustomobject]@{
                    Name = "Invalid"
                    DetectionNames = @("Invalid")
                    Source = [pscustomobject]@{ Type = "Winget" }
                })
                $false
            }
            catch { $true }
        }

        $threw | Should Be $true
    }
}
