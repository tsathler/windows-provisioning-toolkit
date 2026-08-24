function Invoke-WPTSecurityAssessment {
    $checks=@(Test-WPTTpm; Test-WPTSecureBoot; Test-WPTFirewall; Test-WPTDefender)
    try{$b=Get-BitLockerVolume -MountPoint $env:SystemDrive -ErrorAction Stop; $checks+=New-WPTHealthResult 'BitLocker' 'Security' $(if($b.VolumeStatus -eq 'FullyEncrypted'){'PASS'}else{'WARN'}) "BitLocker status: $($b.VolumeStatus)." $false}catch{$checks+=New-WPTHealthResult 'BitLocker' 'Security' 'WARN' 'BitLocker could not be checked.' $false}
    try{$s=Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -ErrorAction Stop; $checks+=New-WPTHealthResult 'SMBv1' 'Security' $(if($s.State -eq 'Disabled'){'PASS'}else{'WARN'}) "SMBv1 state: $($s.State)." $false}catch{}
    $failCount=@($checks | Where-Object { $_.Status -eq 'FAIL' }).Count
    $warnCount=@($checks | Where-Object { $_.Status -eq 'WARN' }).Count
    $assessmentStatus=if($failCount -gt 0){'FAIL'}elseif($warnCount -gt 0){'WARN'}else{'PASS'}
    $result=[pscustomobject]@{Status=$assessmentStatus;Checks=$checks;Timestamp=(Get-Date).ToString('s')}; $script:WPTLastSecurityAssessment=$result; $result
}
function Invoke-WPTSecurityRemediation {
    param([hashtable]$Config=$(Get-WPTConfig),[switch]$Confirm)
    $changes=@(); $s=$Config.Security
    if($s.EnableFirewall){ if(-not $Confirm){return [pscustomobject]@{Status='SKIPPED';Changes=@('Firewall remediation requires confirmation.')}}; if(-not(Test-WPTDryRun)){Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True -ErrorAction Stop};$changes+='EnableFirewall' }
    if($s.DisableSMBv1){ if(-not(Test-WPTDryRun)){Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart -ErrorAction Stop};$changes+='DisableSMBv1' }
    [pscustomobject]@{Status='SUCCESS';Changes=$changes}
}
