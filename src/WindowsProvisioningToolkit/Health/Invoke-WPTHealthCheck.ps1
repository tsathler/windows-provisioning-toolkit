function New-WPTHealthResult {
    param([string]$Name,[string]$Category='Provisioning',[ValidateSet('PASS','WARN','FAIL')][string]$Status,[string]$Message,[bool]$Required=$false,[string]$Remediation)
    [pscustomobject]@{ Name=$Name; Category=$Category; Status=$Status; Message=$Message; Required=$Required; Remediation=$Remediation }
}

function Get-WPTHealthTasks {
    @(
        @{ Name='Administrator'; Category='System'; Required=$true; Action={ Test-WPTAdministrator }
          Check={ Test-WPTAdministrator } }
        @{ Name='Windows version'; Category='System'; Required=$true; Action={ Test-WPTWindowsVersion }; Check={ Test-WPTWindowsVersion } }
        @{ Name='Memory'; Category='Hardware'; Required=$true; Action={ Test-WPTMemory }; Check={ Test-WPTMemory } }
        @{ Name='Disk space'; Category='Hardware'; Required=$true; Action={ Test-WPTDiskSpace }; Check={ Test-WPTDiskSpace } }
        @{ Name='Winget'; Category='Provisioning'; Required=$true; Action={ Test-WPTWinget }; Check={ Test-WPTWinget } }
        @{ Name='Windows activation'; Category='Provisioning'; Required=$false; Action={ Test-WPTWindowsActivation }; Check={ Test-WPTWindowsActivation } }
        @{ Name='Pending reboot'; Category='Provisioning'; Required=$false; Action={ Test-WPTPendingReboot }; Check={ Test-WPTPendingReboot } }
        @{ Name='Gateway'; Category='Network'; Required=$false; Action={ Test-WPTGateway }; Check={ Test-WPTGateway } }
        @{ Name='DNS'; Category='Network'; Required=$false; Action={ Test-WPTDnsResolution }; Check={ Test-WPTDnsResolution } }
        @{ Name='Internet'; Category='Network'; Required=$true; Action={ Test-WPTInternetConnectionHealth }; Check={ Test-WPTInternetConnectionHealth } }
        @{ Name='TPM'; Category='Security'; Required=$false; Action={ Test-WPTTpm }; Check={ Test-WPTTpm } }
        @{ Name='Secure Boot'; Category='Security'; Required=$false; Action={ Test-WPTSecureBoot }; Check={ Test-WPTSecureBoot } }
        @{ Name='Firewall'; Category='Security'; Required=$false; Action={ Test-WPTFirewall }; Check={ Test-WPTFirewall } }
        @{ Name='Defender'; Category='Security'; Required=$false; Action={ Test-WPTDefender }; Check={ Test-WPTDefender } }
    )
}

function Invoke-WPTHealthCheck {
    param([hashtable]$Config = $(Get-WPTConfig))
    $results = foreach ($task in (Get-WPTHealthTasks)) {
        try { & $task.Action } catch { New-WPTHealthResult $task.Name $task.Category 'WARN' $_.Exception.Message $task.Required 'Review the check manually.' }
    }
    $requiredFailures = @($results | Where-Object { $_.Status -eq 'FAIL' -and $_.Required })
    $warnings = @($results | Where-Object Status -eq 'WARN')
    $status = if ($requiredFailures.Count -gt 0) { 'NOT_READY' } elseif ($warnings.Count -gt 0) { 'READY_WITH_WARNINGS' } else { 'READY' }
    $summary = [pscustomobject]@{ Status=$status; Checks=@($results); Timestamp=(Get-Date).ToString('s'); RequiredFailures=$requiredFailures.Count; Warnings=$warnings.Count }
    $script:WPTLastHealthCheck=$summary
    try { Write-WPTLog -Message "Health Check: $status ($($results.Count) checks)." -Level $(if($status -eq 'NOT_READY'){'ERROR'}elseif($warnings.Count -gt 0){'WARNING'}else{'SUCCESS'}) | Out-Null } catch {}
    $summary
}

function Test-WPTAdministrator {
    try { $ok = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) } catch { $ok=$false }
    New-WPTHealthResult 'Administrator' 'System' $(if($ok){'PASS'}else{'FAIL'}) $(if($ok){'Administrative privileges detected.'}else{'Administrative privileges are required.'}) $true 'Run PowerShell as Administrator.'
}
function Test-WPTWindowsVersion {
    try { $os=Get-CimInstance Win32_OperatingSystem -ErrorAction Stop; New-WPTHealthResult 'Windows version' 'System' 'PASS' "$($os.Caption) $($os.Version) detected." $true }
    catch { New-WPTHealthResult 'Windows version' 'System' 'WARN' 'Windows version could not be detected.' $true }
}
function Test-WPTMemory {
    $min=8; try { $c=Get-WPTConfig; if($c.HealthCheck.MinimumMemoryGB){$min=[double]$c.HealthCheck.MinimumMemoryGB} elseif($c.Settings.HealthCheck.MinimumMemoryGB){$min=[double]$c.Settings.HealthCheck.MinimumMemoryGB}; $gb=[math]::Round((Get-CimInstance Win32_ComputerSystem -ErrorAction Stop).TotalPhysicalMemory/1GB,2); $s=if($gb -ge $min){'PASS'}else{'FAIL'}; return New-WPTHealthResult 'Memory' 'Hardware' $s "Installed memory: ${gb}GB (minimum ${min}GB)." $true 'Add memory or adjust the profile threshold.' } catch { New-WPTHealthResult 'Memory' 'Hardware' 'WARN' 'Memory could not be detected.' $true }
}
function Test-WPTDiskSpace {
    $min=30; try { $c=Get-WPTConfig; if($c.HealthCheck.MinimumFreeDiskGB){$min=[double]$c.HealthCheck.MinimumFreeDiskGB}; $drive=Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='$($env:SystemDrive)'" -ErrorAction Stop; $gb=[math]::Round($drive.FreeSpace/1GB,2); $s=if($gb -ge $min){'PASS'}else{'FAIL'}; New-WPTHealthResult 'Disk space' 'Hardware' $s "Free space: ${gb}GB (minimum ${min}GB)." $true 'Free disk space before provisioning.' } catch { New-WPTHealthResult 'Disk space' 'Hardware' 'WARN' 'Disk space could not be detected.' $true }
}
function Test-WPTWinget { $ok=$null -ne (Get-Command winget -ErrorAction SilentlyContinue); New-WPTHealthResult 'Winget' 'Provisioning' $(if($ok){'PASS'}else{'FAIL'}) $(if($ok){'Winget detected.'}else{'Winget was not detected.'}) $true 'Install App Installer / winget.' }
function Test-WPTWindowsActivation { try { $p=Get-CimInstance SoftwareLicensingProduct -Filter "ApplicationID='55c92734-d682-4d71-983e-d6ec3f16059f' AND LicenseStatus=1" -ErrorAction Stop; $ok=@($p).Count -gt 0; New-WPTHealthResult 'Windows activation' 'Provisioning' $(if($ok){'PASS'}else{'WARN'}) $(if($ok){'Windows is activated.'}else{'Windows activation was not confirmed.'}) $false 'Check Windows activation.' } catch { New-WPTHealthResult 'Windows activation' 'Provisioning' 'WARN' 'Activation could not be checked.' $false }
}
function Test-WPTPendingReboot { $keys=@('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending','HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'); $pending=@($keys|Where-Object{Test-Path $_}).Count -gt 0; New-WPTHealthResult 'Pending reboot' 'Provisioning' $(if($pending){'WARN'}else{'PASS'}) $(if($pending){'A reboot is pending.'}else{'No pending reboot detected.'}) $false 'Restart Windows before provisioning.' }
function Test-WPTGateway { try { $g=Get-NetRoute -DestinationPrefix '0.0.0.0/0' -ErrorAction Stop|Where-Object NextHop|Select-Object -First 1; $ok=$null -ne $g; New-WPTHealthResult 'Gateway' 'Network' $(if($ok){'PASS'}else{'WARN'}) $(if($ok){"Gateway $($g.NextHop) detected."}else{'Default gateway not detected.'}) $false } catch { New-WPTHealthResult 'Gateway' 'Network' 'WARN' 'Gateway could not be checked.' $false }
}
function Test-WPTDnsResolution { try { Resolve-DnsName 'www.microsoft.com' -ErrorAction Stop|Out-Null; New-WPTHealthResult 'DNS' 'Network' 'PASS' 'DNS resolution succeeded.' $false } catch { New-WPTHealthResult 'DNS' 'Network' 'WARN' 'DNS resolution failed.' $false 'Check DNS configuration.' } }
function Test-WPTInternetConnectionHealth { $ok=$false; try{$ok=Test-WPTInternetConnection}catch{}; New-WPTHealthResult 'Internet' 'Network' $(if($ok){'PASS'}else{'FAIL'}) $(if($ok){'Internet connectivity succeeded.'}else{'Internet connectivity failed.'}) $true 'Check network connectivity.' }
function Test-WPTTpm { try{$t=Get-Tpm -ErrorAction Stop; $ok=$t.TpmPresent; New-WPTHealthResult 'TPM' 'Security' $(if($ok){'PASS'}else{'WARN'}) $(if($ok){'TPM detected.'}else{'TPM not detected.'}) $false}catch{New-WPTHealthResult 'TPM' 'Security' 'WARN' 'TPM could not be checked.' $false} }
function Test-WPTSecureBoot { try{$ok=Confirm-SecureBootUEFI -ErrorAction Stop; New-WPTHealthResult 'Secure Boot' 'Security' $(if($ok){'PASS'}else{'WARN'}) $(if($ok){'Secure Boot enabled.'}else{'Secure Boot disabled.'}) $false}catch{New-WPTHealthResult 'Secure Boot' 'Security' 'WARN' 'Secure Boot could not be checked.' $false} }
function Test-WPTFirewall { try{$p=Get-NetFirewallProfile -ErrorAction Stop; $ok=@($p|Where-Object Enabled -eq $false).Count -eq 0; New-WPTHealthResult 'Firewall' 'Security' $(if($ok){'PASS'}else{'WARN'}) $(if($ok){'Firewall enabled.'}else{'One or more firewall profiles are disabled.'}) $false}catch{New-WPTHealthResult 'Firewall' 'Security' 'WARN' 'Firewall could not be checked.' $false} }
function Test-WPTDefender { try{$s=Get-MpComputerStatus -ErrorAction Stop; $ok=$s.AntivirusEnabled -and $s.RealTimeProtectionEnabled; New-WPTHealthResult 'Defender' 'Security' $(if($ok){'PASS'}else{'WARN'}) $(if($ok){'Microsoft Defender is active.'}else{'Microsoft Defender protection is not fully active.'}) $false}catch{New-WPTHealthResult 'Defender' 'Security' 'WARN' 'Defender could not be checked.' $false} }
