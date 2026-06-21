#requires -Version 5.1
<# Created by Dewald Pretorius. Read-only SharePoint Online inventory validator. #>
[CmdletBinding()]
param(
 [ValidateRange(1,100)][int]$StorageWarningPercent=85,
 [string]$OutputPath=(Join-Path ([Environment]::GetFolderPath('Desktop')) 'SharePoint_Site_Inventory_Reports')
)
$ErrorActionPreference='Stop';$ExitHealthy=0;$ExitWarning=1;$ExitPrerequisite=3;$ExitFailure=5
try{
 New-Item -ItemType Directory -Path $OutputPath -Force|Out-Null;$stamp=Get-Date -Format yyyyMMdd_HHmmss
 if(-not(Get-Command Get-PnPTenantSite -ErrorAction SilentlyContinue)){Write-Error 'PnP.PowerShell and an existing tenant-admin connection are required.';exit $ExitPrerequisite}
 $connection=Get-PnPConnection -ErrorAction SilentlyContinue;if(-not $connection){Write-Error 'Connect-PnPOnline to the tenant admin site before running.';exit $ExitPrerequisite}
 $sites=@(Get-PnPTenantSite -Detailed -ErrorAction Stop|Select-Object Url,Title,Template,Owner,StorageUsageCurrent,StorageQuota,LastContentModifiedDate,Status,@{n='StoragePercent';e={if($_.StorageQuota){[math]::Round(($_.StorageUsageCurrent/$_.StorageQuota)*100,2)}else{0}}})
 $warnings=@($sites|Where-Object{$_.StoragePercent -ge $StorageWarningPercent -or $_.Status -ne 'Active'})
 $sites|Export-Csv -LiteralPath (Join-Path $OutputPath "sites_$stamp.csv") -NoTypeInformation -Encoding UTF8
 [ordered]@{Generated=(Get-Date);SiteCount=$sites.Count;WarningCount=$warnings.Count;Threshold=$StorageWarningPercent;Status=$(if($warnings.Count){'Warning'}else{'Healthy'});Warnings=$warnings}|ConvertTo-Json -Depth 7|Set-Content -LiteralPath (Join-Path $OutputPath "site_validation_$stamp.json") -Encoding UTF8
 if($warnings.Count){Write-Warning "$($warnings.Count) sites require review.";exit $ExitWarning}
 Write-Host 'SharePoint inventory validation passed.' -ForegroundColor Green;exit $ExitHealthy
}catch{Write-Error $_.Exception.Message;exit $ExitFailure}
