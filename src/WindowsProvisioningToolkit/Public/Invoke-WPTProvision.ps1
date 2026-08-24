function Invoke-WPTProvision {
    [CmdletBinding()]
    param([string]$Profile='Portfolio',[switch]$Unattended,[switch]$DryRun,[switch]$NoPause,[switch]$SkipHealthCheck,[switch]$Resume,[string]$Config)
    if($NoPause){$env:WPT_NO_PAUSE='1'}
    Initialize-WPTLogging|Out-Null
    if($Resume){$result=Resume-WPTProvisioning -Profile $Profile -Unattended:$Unattended}
    else {
        $plan=@(Get-WPTProvisioningPlan -Profile $Profile -ConfigPath $Config -Unattended:$Unattended)
        if($SkipHealthCheck){$plan=@($plan|Where-Object Name -ne 'HealthCheck')}
        if(-not $Unattended){Show-WPTProvisioningPlan -Plan $plan}
        $result=Invoke-WPTProvisioningPlan -Plan $plan -Profile $Profile -DryRun:$DryRun -Unattended:$Unattended
    }
    try{Export-WPTExecutionReport -Result $result -Context 'Provisioning'|Out-Null}catch{}
    if($result.Failure -gt 0){return 4}; if((Get-WPTRestartState).Required){return 5}; return 0
}
