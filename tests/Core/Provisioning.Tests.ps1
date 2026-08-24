$modulePath = Join-Path -Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) -ChildPath "src\WindowsProvisioningToolkit\WindowsProvisioningToolkit.psd1"
Import-Module $modulePath -Force

Describe "Provisionamento declarativo" {
    It "gera um plano com HealthCheck primeiro" {
        $plan = @(Get-WPTProvisioningPlan -Profile Portfolio)
        $plan[0].Name | Should Be "HealthCheck"
        ($plan[1].DependsOn -contains "HealthCheck") | Should Be $true
    }

    It "retorna resultado padronizado de health check" {
        $result = Invoke-WPTHealthCheck
        (@('READY','READY_WITH_WARNINGS','NOT_READY') -contains $result.Status) | Should Be $true
        ($result.Checks[0].PSObject.Properties.Name -contains 'Remediation') | Should Be $true
    }

    It "salva e carrega checkpoint" {
        $module = Get-Module WindowsProvisioningToolkit
        $root = Join-Path $env:TEMP ("wpt-state-" + [guid]::NewGuid())
        New-Item $root -ItemType Directory -Force | Out-Null
        try {
            & $module { $env:WPT_CONFIG_ROOT = $args[0] } $root
            $cfg = [ordered]@{Application=[ordered]@{Name='WPT';Version='0.5.0'};Profile=[ordered]@{Name='Portfolio';Mode='Standard'};Paths=[ordered]@{Data=$root;Logs=(Join-Path $root 'Logs');Reports=(Join-Path $root 'Reports')};Settings=[ordered]@{RequireAdmin=$false};System=[ordered]@{Domain=[ordered]@{DefaultDomainName='';SuggestDefaultDomain=$false;AutoJoin=$false}}}
            $cfg | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $root 'Standard.json')
            Save-WPTProvisioningState -State @{Profile='Portfolio';Completed=@('HealthCheck');Pending=@('ConfigureSystem')} | Out-Null
            (Get-WPTProvisioningState).Profile | Should Be 'Portfolio'
        } finally { & $module { Remove-Item Env:\WPT_CONFIG_ROOT -ErrorAction SilentlyContinue }; Remove-Item $root -Recurse -Force -ErrorAction SilentlyContinue }
    }
}
