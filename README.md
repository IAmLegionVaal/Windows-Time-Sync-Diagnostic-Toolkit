# Windows Time Sync Diagnostic Toolkit

A read-only PowerShell toolkit for Windows time synchronization review.

## Features

- Windows Time service status
- Current time source and configuration
- Domain/workgroup context
- Time status command output
- CSV, JSON, TXT, and HTML reports

## How to run

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\Windows_Time_Sync_Diagnostic_Toolkit.ps1
```

## Safety

Diagnostic-only. It does not change time sources or synchronization settings.
