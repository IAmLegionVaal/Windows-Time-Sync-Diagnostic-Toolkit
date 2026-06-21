#requires -Version 5.1
<# Created by Dewald Pretorius. Guarded repair companion for Windows Time. #>
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Medium')]
param(
    [ValidateSet('Diagnose','StartService','RediscoverAndResync')]
    [string]$Action='Diagnose',
    [string]$OutputPath=(Join-Path ([Environment]::GetFolderPath('Desktop')) 'Time_Sync_Repair')
)
$ErrorActionPreference='Stop'
$ExitPrerequisite=3;$ExitActionFailure=5;$ExitVerificationFailure=6
function Test-Administrator {$principal=New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent());$principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)}
New-Item -ItemType Directory -Path $OutputPath -Force|Out-Null
$stamp=Get-Date -Format 'yyyyMMdd_HHmmss';$logPath=Join-Path $OutputPath "Repair_$stamp.log"
function Log([string]$Message){$line='{0:u} {1}' -f (Get-Date),$Message;Write-Host $line;Add-Content -LiteralPath $logPath -Value $line}
function Get-TimeEvidence {
    [ordered]@{
        Service=(Get-Service W32Time -ErrorAction SilentlyContinue|Select-Object Name,Status,StartType)
        Source=((& w32tm.exe /query /source 2>&1)|Out-String).Trim()
        Status=((& w32tm.exe /query /status 2>&1)|Out-String).Trim()
        Computer=(Get-CimInstance Win32_ComputerSystem|Select-Object Domain,PartOfDomain)
    }
}
(Get-TimeEvidence)|ConvertTo-Json -Depth 5|Set-Content -LiteralPath (Join-Path $OutputPath "PreRepair_$stamp.json") -Encoding UTF8
if($Action -eq 'Diagnose'){Log '[COMPLETE] Read-only time synchronization evidence saved.';exit 0}
if(-not(Test-Administrator)){Log '[FAILED] Run from an elevated PowerShell session.';exit $ExitPrerequisite}
try{
    if($Action -eq 'StartService' -and $PSCmdlet.ShouldProcess('Windows Time service','Start and verify')){
        $service=Get-Service W32Time
        if($service.Status -ne 'Running'){Start-Service W32Time}
    }
    elseif($Action -eq 'RediscoverAndResync' -and $PSCmdlet.ShouldProcess('Windows Time service','Rediscover peers and resynchronize')){
        $service=Get-Service W32Time
        if($service.Status -ne 'Running'){Start-Service W32Time}
        & w32tm.exe /resync /rediscover |ForEach-Object{Log $_}
        if($LASTEXITCODE -ne 0){throw "w32tm resync exited with code $LASTEXITCODE."}
    }
}catch{Log "[FAILED] $($_.Exception.Message)";exit $ExitActionFailure}
Start-Sleep -Seconds 2
$after=Get-TimeEvidence
$after|ConvertTo-Json -Depth 5|Set-Content -LiteralPath (Join-Path $OutputPath "PostRepair_$stamp.json") -Encoding UTF8
if($after.Service.Status -ne 'Running'){Log '[VERIFY-FAILED] Windows Time service is not running.';exit $ExitVerificationFailure}
Log "[VERIFY] Source: $($after.Source)"
Log '[COMPLETE] Time synchronization repair completed.'
exit 0
