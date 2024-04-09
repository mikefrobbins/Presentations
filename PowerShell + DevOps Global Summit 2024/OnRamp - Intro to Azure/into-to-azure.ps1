# Install the Az PowerShell module
Install-Module -Name Az -WhatIf
Get-Module -Name Az -ListAvailable

# Import the Az preview module
Install-Module -Name azpreview -WhatIf
Get-Module -Name azpreview -ListAvailable

Get-Module -Name azpreview -ListAvailable |
Sort-Object -Property Version -Descending |
Select-Object -First 1

Get-Module -Name azpreview -ListAvailable |
Sort-Object -Property Version -Descending |
Select-Object -First 1 -ExpandProperty ModuleBase -OutVariable modulePath



# Login to Azure
Connect-AzAccount -WhatIf

# Make sure you're using the correct subscription
Get-AzContext

# List all available subscriptions
Get-AzContext -ListAvailable

Get-AzSubscription

Get-AzTenant

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

# Filter the list of Azure regions
$locations | Where-Object GeographyGroup -match 'US'

# Filter the list of Azure regions and select specific properties
$locations | Where-Object GeographyGroup -match 'US' | Select-Object -Property Location, PhysicalLocation, PairedRegion

# Expand the PairedRegion property
$locations | Where-Object GeographyGroup -match 'US' | Select-Object -Property Location, PhysicalLocation -ExpandProperty PairedRegion

# Examine the PairedRegion property
$locations | Select-Object -First 1 -Property PairedRegion
$locations | Get-Member | Where-Object Name -eq PairedRegion

# Access the PairedRegion property
$locations.PairedRegion
$locations.PairedRegion.Name

# Expand the PairedRegion property and create a custom object
$locations | Where-Object GeographyGroup -match 'US' | Select-Object -Property Location, PhysicalLocation, @{Name='PairedRegion'; Expression={$_.PairedRegion.Name}}

# Define VM Name, Resource Group Name, and Region (location)
$location = 'westus3'
$resourceGroupName = 'OnRamp2024'
$vmName = 'testvm-rhel'
$cred = Get-Credential

# Create a new resource group
New-AzResourceGroup -Name $resourceGroupName -location $location
Get-AzResourceGroup -ResourceGroupName $resourceGroupName

# Define a hash table of tags
$tags = @{'environment'='demo'; 'project'='onramp2024'}

# Apply tags to the resource group
Set-AzResourceGroup -Name $resourceGroupName -Tag $tags
Get-AzResourceGroup -ResourceGroupName $resourceGroupName

# Create resource group if it doesn't already exist
if (-not(Get-AzResourceGroup -ResourceGroupName $resourceGroupName -ErrorAction SilentlyContinue -OutVariable rgInfo)) {
    New-AzResourceGroup -Name $resourceGroupName -Location $location
} else {
    $resources = Get-AzResource -ResourceGroupName $rg.ResourceGroupName
    Write-Warning -Message "$resourceGroup already exist and may contain other resources!"
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

# Get the public IP address
$vmInfo | Get-AzPublicIpAddress -OutVariable ip

# SSH into the VM
ssh myadmin@$($ip.IpAddress)
cat /etc/redhat-release
exit

# Remove the resource group and all resources
if ($resources.count -gt 0) {
    Write-Warning -Message "Unable to remove $resourceGroupName. It contains other resources."
} else {
    Remove-AzResourceGroup -ResourceGroupName $resourceGroupName
}


# Verify variables are populated
if (-not($Cred)) {
    $cred = Get-Credential
}

if (-not($location)) {
    $location = 'westus3'
}

# Create multiple VMs in Azure for different environments
$environments = @('dev', 'test', 'demo', 'qa', 'prod')

$environments | Foreach-Object -Parallel {
    $resourceGroupName = "OnRamp2024-$_"

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

#What cmdlets exist for working with background jobs?
Get-Command -Noun Job

# Show variable scope problem
foreach ($environment in $environments) {
    Start-Job -Name $environment {
        $resourceGroupName = "OnRamp2024-$environment"
        Write-Output $resourceGroupName
    }
}

# Show the output of the jobs
Get-Job | Receive-Job -Keep

# Remove the jobs
Get-Job | Remove-Job

# Use the Using variable scope modifier
foreach ($environment in $environments) {
    Start-Job -Name $environment {
        $resourceGroupName = "OnRamp2024-$Using:environment"
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
