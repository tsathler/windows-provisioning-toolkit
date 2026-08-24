function Import-WPTProfile {
    param([string]$Profile='Portfolio',[string]$ConfigPath)
    $config=Get-WPTConfig
    if($ConfigPath){ $config=Import-WPTJsonConfig -Path $ConfigPath; Test-WPTConfig -Config $config|Out-Null }
    $config.Profile.Name=$Profile
    if(-not $config.ContainsKey('Provisioning')){$config.Provisioning=@{}}
    $config
}
function Get-WPTProvisioningPlan {
    param([string]$Profile='Portfolio',[string]$ConfigPath,[switch]$Unattended)
    $c=Import-WPTProfile -Profile $Profile -ConfigPath $ConfigPath
    $tasks=@([pscustomobject]@{Name='HealthCheck';Category='Health';Enabled=if($c.Security.HealthCheck -ne $null){[bool]$c.Security.HealthCheck}else{$true};DependsOn=@();RequiresAdmin=[bool]$c.Settings.RequireAdmin;Action={Invoke-WPTHealthCheck}})
    $tasks+= [pscustomobject]@{Name='ConfigureSystem';Category='System';Enabled=$true;DependsOn=@('HealthCheck');RequiresAdmin=$true;Action={
        $systemResult=Invoke-WPTTasks -Tasks @(Get-WPTSystemTasks)
        if($systemResult.Failure -gt 0){throw "Uma ou mais tarefas de sistema falharam."}
        $systemResult
    }}
    if($c.System.Domain.AutoJoin){
        if($Unattended){
            $tasks+=[pscustomobject]@{Name='DomainJoin';Category='Network';Enabled=$true;DependsOn=@('ConfigureSystem');RequiresAdmin=$true;Action={Add-WPTComputerToDomain -DomainName $c.System.Domain.DefaultDomainName -Unattended -SuppressRestartPrompt}}
        }
        else {
            $tasks+=[pscustomobject]@{Name='DomainJoin';Category='Network';Enabled=$true;DependsOn=@('ConfigureSystem');RequiresAdmin=$true;Action={Add-WPTComputerToDomain -Prompt -SuppressRestartPrompt}}
        }
    }
    $tasks
}
function Show-WPTProvisioningPlan { param([array]$Plan); Write-Host 'Provisioning Plan'; $i=1; foreach($t in $Plan|Where-Object Enabled){Write-Host ("{0}. {1}" -f $i,$t.Name);$i++}; Write-Host ("{0} tasks planned." -f ($i-1)) }
function Invoke-WPTProvisioningPlan {
    param([Parameter(Mandatory=$true)][array]$Plan,[string]$Profile='Portfolio',[switch]$DryRun,[switch]$Unattended)
    if($DryRun){Set-WPTDryRun -Enabled $true}
    $done=@();$details=@();$failed=$false
    foreach($task in $Plan|Where-Object Enabled){
        if(@($task.DependsOn|Where-Object{$done -notcontains $_}).Count -gt 0){$details+=[pscustomobject]@{Name=$task.Name;Status='SKIPPED'};continue}
        if($task.Name -eq 'HealthCheck'){$health=& $task.Action; $status=if($health.Status -eq 'NOT_READY'){'FAILURE'}else{'SUCCESS'}; if($status -eq 'FAILURE'){$failed=$true}}
        else { $status=Invoke-WPTTask -TaskName $task.Name -Action { & $task.Action }; if($status -eq 'FAILURE'){$failed=$true} }
        $details+=[pscustomobject]@{Name=$task.Name;Status=$status}; if($status -eq 'SUCCESS'){$done+=$task.Name}; if($failed -or (Get-WPTRestartState).Required){ Save-WPTProvisioningState -State @{Profile=$Profile;Completed=$done;Pending=@($Plan|Where-Object{$done -notcontains $_.Name}|ForEach-Object Name);RebootRequired=(Get-WPTRestartState).Required;NextTask=(@($Plan|Where-Object{$done -notcontains $_.Name}|Select-Object -First 1).Name) } | Out-Null; break }
    }
    @{Total=$details.Count;Success=@($details|Where-Object Status -eq 'SUCCESS').Count;Failure=@($details|Where-Object Status -eq 'FAILURE').Count;Skipped=@($details|Where-Object Status -eq 'SKIPPED').Count;Details=$details;Completed=$done}
}
