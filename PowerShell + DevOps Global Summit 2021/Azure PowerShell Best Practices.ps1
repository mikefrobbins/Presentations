#region Presentation Info

<#
    Azure PowerShell Best Practices
    Presentation from the PowerShell + DevOps Global Summit 2021
    Author:  Mike F. Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins
#>

#endregion

#region Safety to prevent the entire script from being run instead of a selection

throw "You're not supposed to run the entire script"

#endregion

#region Presentation Prep

$VSCodeSettingsPath = 'C:\Users\mirobb\AppData\Roaming\Code\User\settings.json'
$VSCodeSettings = Get-Content -Path $VSCodeSettingsPath
if ($VSCodeSettings -match '"workbench.colorTheme": ".*",') {
    $VSCodeSettings = $VSCodeSettings -replace '"workbench.colorTheme": ".*",', '"workbench.colorTheme": "PowerShell ISE",'
}
if ($VSCodeSettings -match '"window.zoomLevel": \d,') {
    $VSCodeSettings = $VSCodeSettings -replace '"window.zoomLevel": \d,', '"window.zoomLevel": 2,'
}
$VSCodeSettings | Out-File -FilePath $VSCodeSettingsPath

#Set error messages to yellow
$host.PrivateData.ErrorForegroundColor = 'yellow'
1/0

#Set location
$Path = 'C:\Demo'
if (-not(Test-Path -Path $Path -PathType Container)) {
    New-Item -Path $Path -ItemType Directory | Out-Null
}
Set-Location -Path $Path

#Clear the screen
Clear-Host

#endregion

#region Installation

<#
PowerShell 7.x and later is the recommended version of PowerShell for use with the Azure Az PowerShell module on all platforms.
#>

#Install with PowerShellGet from the PowerShell Gallery. There is also an MSI for offline installations.

Install-Module -Name Az -Repository PSGallery -Scope CurrentUser

<#
Preview modules, Azure PowerShell modules that are not generally available (GA) must be installed separately from the Az PowerShell module. There are two types of previews:

Azure PowerShell modules with a version less than 1.0 are new preview modules and won't be flagged as previews in the PowerShell gallery.

Modules that have previously been GA but have released a new preview version are designated as preview in the PowerShell Gallery. These can only be located in the PowerShell Gallery when the -AllowPrerelease parameter is specified with Find-Module or Install-Module.
#>

Find-Module -Name Az.MySql

# Preview versions of existing modules are flagged with preview in the PowerShell gallery.

Find-Module -Name Az.Sql
Find-Module -Name Az.Sql -AllowPrerelease

#endregion

#region AzureRM coexistence

<#
AzureRM deprecation has been announced. The official deprecation date is 29 February 2024
azure.microsoft.com/en-us/updates/update-your-scripts-to-use-az-powershell-modules-by-29-february-2024/
#>

#AzureRM to Az migration toolkit

Find-Module -Name Az.Tools.Migration

#For more information, see aka.ms/azpsmigrate

#endregion

#region Breaking changes

<#
The Az PowerShell module has 2 breaking change released per year which occurs with major version updates.

Prelease modules do not have to adhere to our twice a year breaking change policy. They can introduce breaking changes at any point.

aka.ms/azps-migration-latest
#>

#endregion

#region Troubleshooting

#Use of the Debug parameter to return addition information to assist in troubleshooting problems
Get-AzResource -Name 'DoesNotExist'
Get-AzResource -Name 'DoesNotExist' -Debug

$DebugPreference
$DebugPreference = 'Continue'
Get-AzResource -Name 'DoesNotExist'

#Uninstallation

#Use the same method of installation. Either MSI or PowerShellGet

#First, you'll need a list of all the Az PowerShell module versions installed on your system.

Get-Module -Name Az -ListAvailable -OutVariable AzVersions

#Generate a list of all the Az PowerShell modules that need to be uninstalled

($AzVersions |
  ForEach-Object {
    Import-Clixml -Path (Join-Path -Path $_.ModuleBase -ChildPath PSGetModuleInfo.xml)
  }).Dependencies.Name | Sort-Object -Descending -Unique -OutVariable AzModules

#Uninstall mdoule is limited to 63 modules so a foreach loop is needed to perform the uninstall.

Uninstall-Module -Name $AzModules

<#
See our Azure PowerShell troublshooting page at aka.ms/azpstroubleshooting
#>

<#
Report issues via a GitHub issue
https://github.com/Azure/azure-powershell/issues
#>

#endregion

#region Summary

<#
    In this portion of our presentation, you’ve learned about the best practices for Azure PowerShell.
#>

#endregion

#region Cleanup

#Reset the settings changes for this presentation

$VSCodeSettingsPath = 'C:\Users\mirobb\AppData\Roaming\Code\User\settings.json'
$VSCodeSettings = Get-Content -Path $VSCodeSettingsPath
if ($VSCodeSettings -match '"workbench.colorTheme": ".*",') {
    $VSCodeSettings = $VSCodeSettings -replace '"workbench.colorTheme": ".*",', '"workbench.colorTheme": "Visual Studio Dark",'
}
if ($VSCodeSettings -match '"window.zoomLevel": \d,') {
    $VSCodeSettings = $VSCodeSettings -replace '"window.zoomLevel": \d,', '"window.zoomLevel": 0,'
}
$VSCodeSettings | Out-File -FilePath $VSCodeSettingsPath

#endregion