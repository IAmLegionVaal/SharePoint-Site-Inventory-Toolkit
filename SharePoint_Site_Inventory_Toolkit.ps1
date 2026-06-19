#requires -Version 5.1
<#
.SYNOPSIS
    SharePoint Site Inventory Toolkit.
.DESCRIPTION
    Read-only site inventory and documentation helper for SharePoint support.
#>
[CmdletBinding()]
param([string]$InputCsv,[string]$OutputPath)
$stamp=Get-Date -Format 'yyyyMMdd_HHmmss'
if([string]::IsNullOrWhiteSpace($OutputPath)){$OutputPath=Join-Path ([Environment]::GetFolderPath('Desktop')) 'SharePoint_Site_Reports'}
New-Item -Path $OutputPath -ItemType Directory -Force|Out-Null
$module=Get-Module -ListAvailable PnP.PowerShell -ErrorAction SilentlyContinue|Select-Object -First 1
$checks=@([PSCustomObject]@{Area='Module';Name='PnP.PowerShell';Status=$(if($module){'OK'}else{'Info'});Value=$(if($module){$module.Version}else{'Not installed'});Recommendation='Install when live tenant reporting is required.'})
if($InputCsv -and (Test-Path $InputCsv)){$data=Import-Csv $InputCsv}else{$data=@([PSCustomObject]@{Title='Sample Team Site';Url='https://contoso.sharepoint.com/sites/sample';Template='GROUP#0';StorageUsedGB='2.4';Owner='sample.owner@contoso.com';SharingCapability='ExternalUserSharingOnly'})}
$data|Export-Csv (Join-Path $OutputPath "site_inventory_$stamp.csv") -NoTypeInformation -Encoding UTF8
$data|ConvertTo-Json -Depth 5|Set-Content (Join-Path $OutputPath "site_inventory_$stamp.json") -Encoding UTF8
$checks|Export-Csv (Join-Path $OutputPath "readiness_checks_$stamp.csv") -NoTypeInformation -Encoding UTF8
$template='Validate site owners','Review unused sites','Review storage consumption','Review external sharing','Review sensitivity labels','Review retention requirements'|ForEach-Object{[PSCustomObject]@{ReviewItem=$_;Status='Not assessed';Notes=''}}
$template|Export-Csv (Join-Path $OutputPath "site_review_template_$stamp.csv") -NoTypeInformation -Encoding UTF8
$html="<h1>SharePoint Site Inventory</h1><p>Generated $(Get-Date)</p><h2>Readiness</h2>$($checks|ConvertTo-Html -Fragment)<h2>Sites</h2>$($data|ConvertTo-Html -Fragment)<h2>Review Template</h2>$($template|ConvertTo-Html -Fragment)"
$html|ConvertTo-Html -Title 'SharePoint Site Inventory'|Set-Content (Join-Path $OutputPath "sharepoint_site_inventory_$stamp.html") -Encoding UTF8
Write-Host "Reports saved to: $OutputPath" -ForegroundColor Green
