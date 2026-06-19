# SharePoint Site Inventory Toolkit

A read-only PowerShell toolkit for SharePoint Online site inventory preparation.

## Features

- PnP PowerShell module check
- Site inventory CSV import mode for offline demonstrations
- Ownership and storage review template
- CSV, JSON, and HTML reports

## How to run

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\SharePoint_Site_Inventory_Toolkit.ps1
```

Use a sample CSV:

```powershell
.\SharePoint_Site_Inventory_Toolkit.ps1 -InputCsv .\sites.csv
```

## Safety

Read-only and documentation-focused. It does not modify SharePoint sites.
