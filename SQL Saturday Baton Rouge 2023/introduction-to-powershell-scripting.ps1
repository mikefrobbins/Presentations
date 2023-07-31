#region Presentation Info

<#
  This is an example of a multi-line comment block.

  Introduction to PowerShell Scripting
  SQL Saturday Baton Rouge 2023
  Author:  Mike F. Robbins
  Website: https://mikefrobbins.com/
  Twitter: @mikefrobbins
#>

#endregion

#region Safety to prevent the entire script from being run instead of a selection

throw "You're not supposed to run the entire script"

#endregion

#region Presentation Prep

# Import the Az PowerShell module
Import-Module -Name Azpreview

$VSCodeSettingsPath = "$HOME/Library/Application Support/Code/User/profiles/-12baa4e9/settings.json"
$VSCodeSettings = Get-Content -Path $VSCodeSettingsPath
$VSCodeSettings | ConvertFrom-Json | Select-Object -Property 'workbench.colorTheme', 'window.zoomLevel'

$VSCodeSettings | Out-File -FilePath $VSCodeSettingsPath

if ($VSCodeSettings -match '"workbench.colorTheme": ".*",') {
    $VSCodeSettings = $VSCodeSettings -replace '"workbench.colorTheme": ".*",', '"workbench.colorTheme": "PowerShell ISE",'
}
if ($VSCodeSettings -match '"window.zoomLevel": \d,') {
    $VSCodeSettings = $VSCodeSettings -replace '"window.zoomLevel": \d,', '"window.zoomLevel": 2,'
}

$VSCodeSettings | Out-File -FilePath $VSCodeSettingsPath

#Clear the screen
Clear-Host

#endregion

#region Getting Started with PowerShell

# User access control (UAC)
# Execution policy is not a security boundary

# Determine the version of PowerShell you have installed:

$PSVersionTable
$PSVersionTable.PSVersion

# Get-Member is one of the three most useful cmdlets in PowerShell
# You can pipe any cmdlet that produces output to Get-Member to see what type of object it produces and what properties and methods are available.

$PSVersionTable | Get-Member
$PSVersionTable.PSVersion | Get-Member
$PSVersionTable.PSVersion | Get-Member -MemberType Properties

# See https://semver.org/ to learn about Semantic versioning

#endregion

#region The Help System

# Powershell verbs are standardized, with only a specific set of approved verbs available to use in order to maintain consistency across commands

Get-Verb
(Get-Verb).Count
Get-Verb | Group-Object -Property Group -NoElement | Sort-Object -Property Count -Descending
Get-Verb | Where-Object -Property Group -eq Other
Get-Verb -Group Other

# Get-Help is one of the three most useful cmdlets in PowerShell

Get-Help -Name Get-Process

# Help does not ship in the box

Update-Help -WhatIf

# Get-Command is another one of the three most useful cmdlets in PowerShell

Get-Command -Name help

help -Name Get-Process

help -Name Get-Help

Get-Command -Name help -Syntax

# Anything surrounded by square brackets is optional.
# Data types are in angle brackets after the parameter name.
# Two square brackets in the datatype field indicates that the parameter accepts multiple values.

# Name is a positional parameter

help Get-Command -Full
help Get-Command -Examples
help Get-Command -Parameter Name
help Get-Command -Online
help Get-Command -Examples -Detailed

#endregion

#region One-liners and the pipeline

# Filter left, format right

# The following command doesn't follow best practices because it filters right

Get-Process | Where-Object -Property Name -eq bird

# If parameters exist that can be used to filter the data before the pipeline, use them

Get-Process -Name bird

# The properties you see by default aren't necessarily the actual properties of the object

Get-Process -Name bird | Get-Member

Get-Process -Name bird | Select-Object -Property *

# Where-Object

Get-Process | Where-Object Path -eq /System/Library/PrivateFrameworks/CloudDocsDaemon.framework/Versions/A/Support/bird

# Compound Where-Object statement

# You cannot use the simplified syntax with the -and operator

Get-Process | Where-Object Path -eq /System/Library/PrivateFrameworks/CloudDocsDaemon.framework/Versions/A/Support/bird -and Handles -gt 100

# You have to use the full syntax with the -and operator

Get-Process | Where-Object {$_.Path -eq '/System/Library/PrivateFrameworks/CloudDocsDaemon.framework/Versions/A/Support/bird' -and $_.PriorityClass -eq 'Normal'}

# If your going to eat an elephant only eat it once

$procs = Get-Process

$procs

$procs | Get-Member

$procs -Name bird

$procs | Where-Object Name -eq bird

($procs | Where-Object Name -eq bird).Kill()
(Get-Process -Name bird).Kill()

#endregion

#region Formatting, aliases, comparision operators, and logical operators

Get-Alias -Name gcm
Get-Alias -Definition Get-Command

Get-Alias -Name sort
Get-Command -Name sort

#endregion

#region Flow Control

# Store a list of the Az PowerShell module names in a variable
$AzModuleNames = (Get-Module -ListAvailable -Name Az.*).Name

# Loop through the list of Az PowerShell module names and get the number of commands in each module
$AzModuleNames|
ForEach-Object {Get-Command -Module $_} |
  Group-Object -Property ModuleName -NoElement |
      Sort-Object -Property Count -Descending

# Get a list of all the commands in the Az PowerShell module
$AzCommands = Get-Command -Module Az.*

# Loop through the list of Az PowerShell commands and get the length of each command name
foreach ($AzCommand in $AzCommands) {
  [pscustomobject]@{
    Name = $AzCommand.Name
    ModuleName = $AzCommand.ModuleName
    CommandType = $AzCommand.CommandType
    Length = $AzCommand.Name.Length
  }
}

# Other loops include: Do (Do While or Do Until), For, While

# Break and Continue are used to exit a loop or skip to the next iteration of a loop

#endregion

#region PowerShell remoting

#endregion

#region Functions

function Get-MrCommandLength {
  [CmdletBinding()]
  param (
    [ValidateNotNullOrEmpty()]
    [string[]]$ModuleName = 'Az.*'
  )

  $Commands = Get-Command -Module $ModuleName

  foreach ($Command in $Commands) {
    [pscustomobject]@{
      Name = $Command.Name
      ModuleName = $Command.ModuleName
      CommandType = $Command.CommandType
      Length = $Command.Name.Length
    }
  }
}

#endregion

#region Script modules

$plasterParams = @{
  TemplatePath      = '/Users/mikefrobbins/Developer/git/Plaster/Template'
  DestinationPath   = '/Users/mikefrobbins/Developer/git'
  Name              = 'MrTestModule'
  Description       = 'Mike Robbins Test Module'
  Version           = '0.1.0'
  Author            = 'Mike F. Robbins'
  CompanyName       = 'mikefrobbins.com'
  Folders           = 'public', 'private'
  Git               = 'Yes'
  GitRepoName       = 'TestModule'
  Options           = ('License', 'Readme', 'GitIgnore', 'GitAttributes')
}

If (-not(Test-Path -Path $plasterParams.DestinationPath -PathType Container)) {
  New-Item -Path $plasterParams.DestinationPath -ItemType Directory | Out-Null
}

Invoke-Plaster @plasterParams


New-Item -Path "/Users/mikefrobbins/Developer/git/TestModule/MrTestModule/public" -Name Get-MrCommandLength.ps1 -ItemType File -Force |
Set-Content -Encoding UTF8 -Value @'
function Get-MrCommandLength {
  [CmdletBinding()]
  param (
    [ValidateNotNullOrEmpty()]
    [string[]]$ModuleName = 'Az.*'
  )

  $Commands = Get-Command -Module $ModuleName

  foreach ($Command in $Commands) {
    [pscustomobject]@{
      Name = $Command.Name
      ModuleName = $Command.ModuleName
      CommandType = $Command.CommandType
      Length = $Command.Name.Length
    }
  }
}
'@

Update-ModuleManifest -Path '/Users/mikefrobbins/Developer/git/TestModule/MrTestModule\MrTestModule.psd1' -FunctionsToExport Get-MrCommandLength

Import-Module -Name '/Users/mikefrobbins/Developer/git/TestModule/MrTestModule\MrTestModule.psd1'
Get-Command -Module MrTestModule


#endregion

#region Cleanup

#Reset the settings changes for this presentation

$VSCodeSettingsPath = "$HOME/Library/Application Support/Code/User/profiles/-12baa4e9/settings.json"
$VSCodeSettings = Get-Content -Path $VSCodeSettingsPath

if ($VSCodeSettings -match '"workbench.colorTheme": ".*",') {
    $VSCodeSettings = $VSCodeSettings -replace '"workbench.colorTheme": ".*",', '"workbench.colorTheme": "Visual Studio Dark",'
}
if ($VSCodeSettings -match '"window.zoomLevel": \d,') {
    $VSCodeSettings = $VSCodeSettings -replace '"window.zoomLevel": \d,', '"window.zoomLevel": 1,'
}

$VSCodeSettings | Out-File -FilePath $VSCodeSettingsPath

Remove-Item -Path ~/Developer/git/TestModule -Recurse -Force

#endregion