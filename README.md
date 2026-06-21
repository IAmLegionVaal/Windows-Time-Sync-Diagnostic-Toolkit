# Windows Time Sync Diagnostic Toolkit

Created by **Dewald Pretorius**.

A PowerShell 5.1 toolkit for Windows time synchronization diagnostics and guarded recovery.

## Files

- `Windows_Time_Sync_Diagnostic_Toolkit.ps1` — read-only service, source, configuration, domain, and status reports.
- `Repair.ps1` — starts Windows Time or requests peer rediscovery and resynchronization with confirmation, evidence, logs, and verification.

```powershell
.\Repair.ps1 -Action Diagnose
.\Repair.ps1 -Action StartService -WhatIf
.\Repair.ps1 -Action RediscoverAndResync -Confirm
```

Repair actions require elevation and do not manually replace domain time sources or write registry configuration. Post-action evidence records the service state and selected time source.

Source-reviewed for Windows PowerShell 5.1; not runtime-tested in every domain, workgroup, or virtualized time configuration.
