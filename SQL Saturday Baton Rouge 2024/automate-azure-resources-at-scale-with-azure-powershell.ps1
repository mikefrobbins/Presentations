#region Presentation Info

<#
  This is an example of a multi-line comment block.

  Automate Azure resources at scale with Azure PowerShell
  SQL Saturday Baton Rouge 2024
  Author:  Mike F. Robbins
  Website: https://mikefrobbins.com/
  Twitter: @mikefrobbins
#>

#endregion

#region Presentation Prep

# Locate the VS Code settings.json file
if (Test-Path -Path "$HOME/Library/Application Support/Code/User/profiles/-12baa4e9/settings.json" -PathType Leaf) {
    $VSCodeSettingsPath = "$HOME/Library/Application Support/Code/User/profiles/-12baa4e9/settings.json"
} elseif (Test-Path -Path "$env:APPDATA\Code\User\settings.json" -PathType Leaf) {
    $VSCodeSettingsPath = "$env:APPDATA\Code\User\settings.json"
} else {
  throw 'Unable to locate VS Code settings file'
}

# Return the current color theme and zoom level for VS Code
$VSCodeSettings = Get-Content -Path $VSCodeSettingsPath
$VSCodeSettings | ConvertFrom-Json | Select-Object -Property 'workbench.colorTheme', 'window.zoomLevel'

# Update the color theme to ISE and zoom level to 2
if ($VSCodeSettings -match '"workbench.colorTheme": ".*",') {
    $VSCodeSettings = $VSCodeSettings -replace '"workbench.colorTheme": ".*",', '"workbench.colorTheme": "PowerShell ISE",'
}
if ($VSCodeSettings -match '"window.zoomLevel": \d,') {
    $VSCodeSettings = $VSCodeSettings -replace '"window.zoomLevel": \d,', '"window.zoomLevel": 2,'
}

# Apply the settings
$VSCodeSettings | Out-File -FilePath $VSCodeSettingsPath

# Clear the screen
Clear-Host

#endregion

#region Safety to prevent the entire script from running instead of a selection

# The throw keyword causes a terminating error. You can use the throw keyword to stop the processing of a command, function, or script.
throw "You're not supposed to run the entire script"

#endregion

# Sign up for a free Azure subscription
Start-Process https://azure.microsoft.com/free

# Student - Sign up for a free Azure subscription
'https://azure.microsoft.com/free/students', 'https://azure.microsoft.com/pricing/offers/ms-azr-0170p' | ForEach-Object {Start-Process $_}

# Install the Az PowerShell module
Find-Module -Name Az
# Install-Module -Name Az
Find-PSResource -Name Az
# Install-PSResource -Name Az

# Import the Az preview module
Find-Module -Name azpreview
# Install-Module -Name azpreview
Find-PSResource -Name azpreview
# Install-PSResource -Name azpreview

# Azure PowerShell docs
Start-Process 'https://aka.ms/azps'

# Retrieve the latest version of the Az preview module
Get-Module -Name az, azpreview -ListAvailable

Get-Module -Name az, azpreview -ListAvailable |
Sort-Object -Property Version -Descending |
Select-Object -First 1

Get-Module -Name az, azpreview -ListAvailable -ov o |
Select-Object -Property Name -Unique |
ForEach-Object {
    $o | Where-Object Name -eq $_.Name |
    Sort-Object -Property Version -Descending |
    Select-Object -First 1
}

# Login to Azure
Connect-AzAccount -WhatIf

# Make sure you're using the correct subscription
Get-AzContext

# List all available contexts
Get-AzContext -ListAvailable

# List all available subscriptions
Get-AzSubscription

# List the resource groups that exist in my subscription
Get-AzResourceGroup

# Select specific properties of the resource groups
Get-AzResourceGroup | Select-Object -Property ResourceGroupName, Location



# Get a list of Azure regions
Get-AzLocation

# Get a list of Azure regions and select specific properties
Get-AzLocation | Select-Object -Property Location

# Store output in a variable
$locations = Get-AzLocation
Get-AzLocation -OutVariable regions
$locations
$regions

# Filter the list of Azure regions
$locations | Where-Object GeographyGroup -match 'US'

# Filter the list of Azure regions and select specific properties
$locations | Where-Object GeographyGroup -match 'US' | Select-Object -Property Location, PhysicalLocation, PairedRegion

# Examine the PairedRegion property
$locations | Select-Object -First 1 -Property PairedRegion
$locations | Get-Member | Where-Object Name -eq PairedRegion

# Expand the PairedRegion property
$locations | Where-Object GeographyGroup -match 'US' | Select-Object -Property Location, PhysicalLocation -ExpandProperty PairedRegion

# Access the PairedRegion property
$locations.PairedRegion
$locations.PairedRegion.Name

# Expand the PairedRegion property and create a custom object
$locations | Where-Object GeographyGroup -match 'US' | Select-Object -Property Location, PhysicalLocation, @{Name='PairedRegion'; Expression={$_.PairedRegion.Name}}, @{Name='PairedRegionPhysicalLocation'; Expression={$_.PairedRegion.PhysicalLocation}}

$locations | Where-Object GeographyGroup -match 'US' | Select-Object -First 1

$locations |
Where-Object GeographyGroup -match 'US' |
Select-Object -Property Location,
                        PhysicalLocation,
                        @{
                            Name='PairedRegion'
                            Expression={$_.PairedRegion.Name}
                        },
                        @{
                            Name='PairedRegionPhysicalLocation'
                            Expression={(
                                $locations |
                                Where-Object location -eq $_.PairedRegion.Name).PhysicalLocation
                            }
                        }

# Define VM Name, Resource Group Name, and Region (location)
$location = 'westus3'
$resourceGroupName = 'SQLSatBR'
$vmName = 'testvm-rhel'
$cred = Get-Credential -UserName 'myadmin'

# Create a new resource group
New-AzResourceGroup -Name $resourceGroupName -location $location
Get-AzResourceGroup -ResourceGroupName $resourceGroupName

# Define a hash table of tags
$tags = @{'environment'='demo'; 'project'='sqlsatbr1076'; 'year'='2024'}

# Apply tags to the resource group
Set-AzResourceGroup -Name $resourceGroupName -Tag $tags
Get-AzResourceGroup -ResourceGroupName $resourceGroupName

# Create resource group if it doesn't already exist
if (-not(Get-AzResourceGroup -ResourceGroupName $resourceGroupName -ErrorAction SilentlyContinue -OutVariable rgInfo)) {
    New-AzResourceGroup -Name $resourceGroupName -Location $location
} else {
    $resources = Get-AzResource -ResourceGroupName $resourceGroupName
    Write-Warning -Message "$resourceGroupName already exist and may contain other resources!"
}

# Create Azure VM
$vmParams = @{
    ResourceGroupName = $resourceGroupName
    Name = $vmName
    Credential = $cred
    Location = $location
    Image = 'RHELRaw8LVMGen2'
    OpenPorts = 22
    PublicIpAddressName = $vmName
}
New-AzVM @vmParams -OutVariable vmInfo

Get-AzVM
Get-AzVM -ResourceGroupName $resourceGroupName
Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName

Get-AzVM | Select-Object -Property *

$vmInfo
$vmInfo | Get-Member
$vmInfo.NetworkProfile
$vmInfo.NetworkProfile.NetworkInterfaces
$vmInfo.NetworkProfile.NetworkInterfaces.Id

# Get the public IP address
$vmInfo | Get-AzPublicIpAddress -OutVariable ip
Write-Output $ip
$ip
$ip | gm
$ip | Select-Object -Property *
$ip.IpAddress

# SSH into the VM
ssh myadmin@$($ip.IpAddress)

# cat /etc/redhat-release
# sudo yum install https://github.com/PowerShell/PowerShell/releases/download/v7.4.4/powershell-7.4.4-1.rh.x86_64.rpm
# exit

# Remove the resource group and all resources
if ($resources.count -gt 0) {
    Write-Warning -Message "Unable to remove $resourceGroupName. It contains other resources."
} else {
    Remove-AzResourceGroup -ResourceGroupName $resourceGroupName
}

# Show the VM no longer exists
Get-AzVM

# Verify variables are populated
if (-not($Cred)) {
    $cred = Get-Credential
}
if (-not($location)) {
    $location = 'westus3'
}

# Create multiple VMs in Azure for different environments
$environments = @('dev', 'test', 'demo', 'qa', 'prod')

# Create five VMs in parallel
$environments | Foreach-Object -Parallel {
    $resourceGroupName = "SQLSatBR-$_"

    New-AzResourceGroup -Name $resourceGroupName -Location $Using:location

    $vmParams = @{
        ResourceGroupName = $resourceGroupName
        Name = "$_-vm-rhel"
        Credential = $Using:cred
        Location = $Using:location
        Image = 'RHELRaw8LVMGen2'
    }
    New-AzVM @vmParams
} -ThrottleLimit 5

# Show the VMs
Get-AzVM
Get-AzVM -ResourceGroupName SQLSatBR-D*
Get-AzResource -ResourceGroupName SQLSatBR*

# What cmdlets exist for working with background jobs?
Get-Command -Noun Job

# Show variable scope problem
foreach ($environment in $environments) {
    Start-Job -Name $environment {
        $resourceGroupName = "SQLSatBR-$environment"
        Write-Output $resourceGroupName
    }
}

# Show the output of the jobs
Get-Job | Receive-Job -Keep

# Show my profile defaults to using the Keep parameter for Receive-Job
Start-Process 'https://github.com/mikefrobbins/SystemConfiguration/blob/main/PowerShell/Microsoft.PowerShell_profile.ps1'

# Remove the jobs
Get-Job | Remove-Job

# Use the Using variable scope modifier
foreach ($environment in $environments) {
    Start-Job -Name $environment {
        $resourceGroupName = "SQLSatBR-$Using:environment"
        Write-Output $resourceGroupName
    }
}

# Show the output of the jobs
Get-Job | Receive-Job -Keep

# Remove the jobs
Get-Job | Remove-Job

# Remove the OnRamp resource groups
foreach ($environment in $environments) {
    Start-Job -Name $environment {
        $resourceGroupName = "OnRamp2024-$Using:environment"
        Remove-AzResourceGroup -ResourceGroupName $resourceGroupName -Force
    }
}

# Show the jobs
Get-Job

# Show the output of the jobs
Get-Job | Receive-Job -Keep

# Show the VMs no longer exist
Get-AzVM

# Show the resource groups no longer exist
Get-AzResourceGroup | Select-Object -Property ResourceGroupName

#region Cleanup

#Reset the settings changes for this presentation

if (Test-Path -Path "$HOME/Library/Application Support/Code/User/profiles/-12baa4e9/settings.json" -PathType Leaf) {
    $VSCodeSettingsPath = "$HOME/Library/Application Support/Code/User/profiles/-12baa4e9/settings.json"
} elseif (Test-Path -Path "$env:APPDATA\Code\User\settings.json" -PathType Leaf) {
    $VSCodeSettingsPath = "$env:APPDATA\Code\User\settings.json"
} else {
    throw 'Unable to locate VS Code settings file'
}

$VSCodeSettings = Get-Content -Path $VSCodeSettingsPath
$VSCodeSettings | ConvertFrom-Json | Select-Object -Property 'workbench.colorTheme', 'window.zoomLevel'

if ($VSCodeSettings -match '"workbench.colorTheme": ".*",') {
    $VSCodeSettings = $VSCodeSettings -replace '"workbench.colorTheme": ".*",', '"workbench.colorTheme": "Visual Studio Dark",'
}
  if ($VSCodeSettings -match '"window.zoomLevel": \d,') {
    $VSCodeSettings = $VSCodeSettings -replace '"window.zoomLevel": \d,', '"window.zoomLevel": 1,'
}

$VSCodeSettings | Out-File -FilePath $VSCodeSettingsPath

#endregion
