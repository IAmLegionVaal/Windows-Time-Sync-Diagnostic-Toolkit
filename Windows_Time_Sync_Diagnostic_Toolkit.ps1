#requires -Version 5.1
<#
.SYNOPSIS
    Windows Time Sync Diagnostic Toolkit.
.DESCRIPTION
    Read-only Windows time synchronization context reporter.
#>
[CmdletBinding()]
param([string]$OutputPath)
$stamp=Get-Date -Format 'yyyyMMdd_HHmmss'
if([string]::IsNullOrWhiteSpace($OutputPath)){$OutputPath=Join-Path ([Environment]::GetFolderPath('Desktop')) 'Time_Sync_Reports'}
New-Item -Path $OutputPath -ItemType Directory -Force|Out-Null
$svc=Get-Service W32Time -ErrorAction SilentlyContinue|Select-Object Name,DisplayName,Status,StartType
$cs=Get-CimInstance Win32_ComputerSystem
$summary=[PSCustomObject]@{Computer=$env:COMPUTERNAME;Domain=$cs.Domain;PartOfDomain=$cs.PartOfDomain;LocalTime=Get-Date;TimeZone=(Get-TimeZone).Id;ServiceStatus=$svc.Status;Generated=Get-Date}
$summary|Export-Csv (Join-Path $OutputPath "time_summary_$stamp.csv") -NoTypeInformation -Encoding UTF8
$summary|ConvertTo-Json|Set-Content (Join-Path $OutputPath "time_summary_$stamp.json") -Encoding UTF8
$svc|Export-Csv (Join-Path $OutputPath "time_service_$stamp.csv") -NoTypeInformation -Encoding UTF8
try{w32tm.exe /query /status|Out-File (Join-Path $OutputPath "time_status_$stamp.txt") -Encoding UTF8}catch{}
try{w32tm.exe /query /source|Out-File (Join-Path $OutputPath "time_source_$stamp.txt") -Encoding UTF8}catch{}
try{w32tm.exe /query /configuration|Out-File (Join-Path $OutputPath "time_configuration_$stamp.txt") -Encoding UTF8}catch{}
$html="<h1>Windows Time Sync - $env:COMPUTERNAME</h1><p>Generated $(Get-Date)</p><h2>Summary</h2>$(@($summary)|ConvertTo-Html -Fragment)<h2>Service</h2>$($svc|ConvertTo-Html -Fragment)"
$html|ConvertTo-Html -Title 'Windows Time Sync'|Set-Content (Join-Path $OutputPath "time_sync_$stamp.html") -Encoding UTF8
$summary|Format-List
Write-Host "Reports saved to: $OutputPath" -ForegroundColor Green
