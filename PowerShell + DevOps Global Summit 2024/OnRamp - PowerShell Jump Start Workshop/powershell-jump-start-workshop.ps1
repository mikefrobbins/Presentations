#region Presentation Info

<#
  This is an example of a multi-line comment block.

  PowerShell in a day
  PowerShell + DevOps Global Summit 2024
  Author:  Mike F. Robbins
  Website: https://mikefrobbins.com/
  Twitter: @mikefrobbins
#>

#endregion

#region Safety to prevent the entire script from running instead of a selection

# The throw keyword causes a terminating error. You can use the throw keyword to stop the processing of a command, function, or script.
throw "You're not supposed to run the entire script"

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

#region Installing PowerShell *

#region Installation

#region Install on Windows

# PowerShell 7 installs side-by-side on Windows with Windows PowerShell. It doesn't replace Windows PowerShell 5.1. The name of the executables are different. powershell.exe is Windows PowerShell, and pwsh.exe is PowerShell 7.

<#
    If you don't have PowerShell version 7 installed, open Windows PowerShell and use Windows Package Manager (Winget) to install the latest version of PowerShell.
#>

winget install --id Microsoft.Powershell --source winget

# Install VS Code

winget install --id Microsoft.VisualStudioCode --source winget

<#
    The PowerShell ISE only works with Windows PowerShell. It's also no longer in active feature development. You only need to install it on the computer where you create PowerShell scripts. You don’t need to install them on all the computers where you run PowerShell.
#>

# Reload the environment variables to include the new path
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Install the PowerShell extension for VS Code

code --install-extension ms-vscode.powershell

# Install Windows Terminal

winget install --id Microsoft.WindowsTerminal --source winget

#endregion

#region Install on Linux

<#
    Install PowerShell on Ubuntu Linux using the Advanced Packaging Tool (apt) and the Bash
    command line.
#>

# Update the list of packages
sudo apt-get update

# Install prerequisite packages
sudo apt-get install -y wget apt-transport-https software-properties-common

# Get the version of Ubuntu
source /etc/os-release

# Download the Microsoft repository keys
wget -q https://packages.microsoft.com/config/ubuntu/$VERSION_ID/packages-microsoft-prod.deb

# Register the Microsoft repository keys
sudo dpkg -i packages-microsoft-prod.deb

# Delete the Microsoft repository keys file
rm packages-microsoft-prod.deb

# Update the list of packages after we added packages.microsoft.com
sudo apt-get update

# Install PowerShell
sudo apt-get install -y powershell

# Start PowerShell
pwsh

# Install VS Code

sudo apt-get install wget gpg
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg

sudo apt install apt-transport-https
sudo apt update
sudo apt install code

# Install the PowerShell extension for VS Code

code --install-extension ms-vscode.powershell

#endregion

#region Install on macOS

<#
    On macOS, install PowerShell using the Homebrew package manager.
#>

# Install the Homebrew package manager.
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

# Install the latest stable release of PowerShell:
brew install powershell/tap/powershell

#Start PowerShell to verify that it installed successfully:
pwsh

# Install VS Code

brew install --cask visual-studio-code

# Install the PowerShell extension for VS Code

code --install-extension ms-vscode.powershell

#endregion

#endregion

#region PSVersionTable

# Run the following command to determine the version of PowerShell you're using.
$PSVersionTable
$PSVersionTable.PSVersion

# Use with the less than or equal to comparison operator
$PSVersionTable.PSVersion.Major -le 5

# Real world scenario: Add OS specific variables that exist in PowerShell 7 to Windows PowerShell.
if ($PSVersionTable.PSVersion.Major -le 5) {
    $IsWindows = $true
    $IsLinux = $false
    $IsMacOS = $false
    $IsCoreCLR = $false
}

if ($IsWindows) {
    Set-Location -Path $env:SystemDrive\
}

#endregion

#region Basic navigation

<#
    Tab expansion or tab completion is a feature in PowerShell that allows you to type a few characters of a command, parameter, or path and then press the Tab key to complete the rest of the item. If there are multiple items that match the characters you've typed, pressing the Tab key multiple times will cycle through the available options.
#>

# By default, tab expansion works differently on Windows vs Linux and macOS.

<#
    Intellisense is a feature in PowerShell that provides context-aware code completion suggestions as you type. It helps you write code faster and with fewer errors by suggesting cmdlets, parameters, variables, and other elements based on the context of your script.
#>

# Use the Tab key to complete the path.

# Get the current directory path. Similar to the pwd (print working directory) command in Linux.
Get-Location

# Save the current directory so you can return to it later. Similar to pushd in other command-line environments.
Push-Location

# Tab expansion can be used to complete values for parameters as well. Use ctrl+space to trigger intellisense.

# Create a new directory.
New-Item -Name NewFolder -ItemType Directory

# One of the tricks I use is to run a command without a parameter value to determine if the error will reveal more information.

# Changes the current directory to the one specified. Similar to the cd command.
Set-Location -Path C:\NewFolder

# Create a new file.
New-Item -Name example.txt -ItemType File

# Create multiple files. Once you figure out how to perform a task in PowerShell once, it's easy to replicate it multiple times.
1..100 | ForEach-Object {New-Item -Name example$_.txt -ItemType File}

# Clear the screen
Clear-Host

# Lists the items (files and directories) in the current directory or one you specify. Similar to ls or dir.
Get-ChildItem

# Return to the directory saved by the last Push-Location command.
Pop-Location

# Delete a file or directory. Be cautious with this command, as it can delete files and directories permanently.
Remove-Item -Path C:\NewFolder\example.txt  # Removes a file
Get-ChildItem -Path C:\NewFolder

Remove-Item -Path NewFolder -Recurse -WhatIf  # Removes a directory and its contents
Remove-Item -Path NewFolder -Recurse -Confirm

# List PSDrives
Get-PSDrive

# Navigating the Certificate PSDrive
Get-ChildItem -Path Cert:
Get-ChildItem -Path Cert:\LocalMachine
Get-ChildItem -Path Cert:\LocalMachine\My
Get-ChildItem -Path Cert:\LocalMachine\My | Select-Object -First 1 -Property *

# Real world scenario: Find certificates that are expiring in the next 90 days.
Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object NotAfter -lt (Get-Date).AddDays(90)

#endregion

#region Running native commands

notepad.exe
ping 8.8.8.8

#endregion

#endregion

#region Terminology

#region PowerShell

<#
    PowerShell is an object-oriented scripting language. It represents data and system states using structured objects derived from .NET classes defined in the .NET Framework.

    Windows PowerShell 5.1 is the version of PowerShell that ships with Windows.

    PowerShell version 6, formerly known as PowerShell Core, is no longer supported.

    PowerShell version 7 is the latest version of PowerShell and is cross-platform. It's simply known as "PowerShell" and is the version you should be using.
#>

#endregion

#region Cmdlet

<#
    Compiled commands in PowerShell are known as cmdlets, pronounced as “command-let”, not “CMD-let”. The naming convention for cmdlets follows a singular Verb-Noun format to make them easily discoverable. A cmdlet is a native PowerShell command. They exist only inside PowerShell and are written in a .NET language such as C#.
#>

#endregion

#region Function

<#
    A function is similar to a cmdlet, but rather than being written in a .NET language, functions are written in PowerShell’s scripting language. You may hear functions refered to as script cmdlets.
#>

# Function to determine the square of a number
function Get-Square {
    param (
        $number
    )
    Write-Output ($number * $number)
}

#endregion

#region Module

<#
    A module in PowerShell is a package that contains PowerShell functions, cmdlets, scripts, and other resources. Modules are used to group related functionalities together, making it easier to distribute and reuse code. Users can import modules into their session to extend the capabilities of PowerShell with new commands.
#>

#endregion

#region Variable

<#
    Variables in PowerShell are used to store data that can be used and manipulated throughout a script or session. Variables in PowerShell start with a dollar sign ($), and their values can be assigned using the assignment operator (`=`).
#>

$message = 'Hello, OnRamp attendees!'
Write-Output $message

#endregion

#region Array

<#
    An array is a data structure that stores a collection of items. In PowerShell, arrays are flexible and can hold items of different types. Arrays are zero-indexed, meaning the first item is at index 0.
#>

$array = 1, 2, 'three', 4.5
Write-Output $array

#endregion

#region Hashtable

<#
    A hashtable in PowerShell is a dictionary-like data structure where each value is associated with a unique key. Hashtables are useful for storing and retrieving data where each item can be quickly accessed using its key.
#>

$hashtable = @{Name = 'John'; Age = 30; Department = 'IT'}
Write-Output $hashtable

# Notice how the output of an object is different
$object = New-Object -TypeName PSObject -Property @{'Name' = 'John'; 'Age' = '30'; 'Department' = 'IT'}
Write-Output $object

#endregion

#region Script Block

<#
    A script block is a set of commands or expressions enclosed in curley braces {}. Script blocks can be stored in variables, passed as arguments, or used with cmdlets like ForEach-Object. They are a fundamental construct in PowerShell, enabling the creation of complex scripts and commands.
#>

$scriptBlock = {Get-Process | Where-Object {$_.CPU -gt 100}}
Write-Output $scriptBlock

# Use the ampersand (&) call operator to execute a command stored in a variable
& $scriptBlock

#endregion

#endregion

#region Get-Help

# Beginning with PowerShell version 3, help doesn't ship with PowerShell. The first thing you need to do is to update the help.

#region Updating Help

# Help in PowerShell 7 is independent of the help in Windows PowerShell.

# Update the help files for all modules that are installed on your system and support updatable help
Update-Help

# Update-Help requires admin pivileges on Windows PowerShell

# Update the help for a specific module
Update-Help -Module PowerShellGet

# The Update-Help cmdlet is designed to prevent unnecessary network traffic by limiting the update of help files to once in every 24 hours. If you need to bypass this restriction, you can use the Force parameter.
Update-Help -Module PowerShellGet -Force

#endregion

#region Getting help

# To get help about a specific cmdlet or function
Get-Help -Name Stop-Process

# The different commands that can be used to Get-Help. Man is an alias on Windows, but not Linux or macOS.
Get-Command -Name Get-Help, help, man

# Use the help function and the Name parameter positionally
help Stop-Process

# To see examples of how to use a cmdlet, you can use the Examples parameter
help Stop-Process -Examples

# Finding help about a specific parameter
help Stop-Process -Parameter Name

# To see everything that Get-Help can provide about a command, use the Full parameter. This includes all the details, parameters, inputs, outputs, notes, and examples
help Stop-Process -Full

# If you prefer to read the help documentation in a web browser, you can use the Online parameter, which opens the online version of the help page for the cmdlet
help Stop-Process -Online

#endregion

#region Understanding Help

<#
    Get-Member provides insight into the objects, properties, and methods associated with PowerShell commands. You can pipe any PowerShell command that produces object based output to Get-Member. When you pipe the output of a command to Get-Member, it reveals the structure of the object returned by the command, detailing its properties and methods.

    Properties: The attributes of an object.

    Methods: The actions you can perform on an object.
#>

Get-Help -Name Stop-Process | Get-Member
help Stop-Process | Get-Member

(Get-Help -Name Stop-Process).Syntax

# Context specific help

help Get-ChildItem

Set-Location -Path Cert:
help Get-ChildItem

#endregion

#region About topics

# PowerShell includes _about_ topics that provide detailed help on various PowerShell concepts and features. List all available _about_ topics
help about_*

# Read a specific _about_ topic, such as about_Variables, use:
help about_Variables

# View the online version of the about_Variables help topic
help about_Variables -Online # <<-- This does not work

#endregion

#region Finding commands with Get-Help

help process -OutVariable process
$process.Count
help *process*
help pr*cess
help *pr*cess*
help -process
help *-process
help processes -OutVariable processes
$processes.Count
$processes.Count / $process.Count -as [int]

#endregion

#endregion

#region Get-Command

# Use Get-Help to determine how to use Get-Command

help Get-Command | Get-Member
Get-Help -Name Get-Command | Get-Member
(Get-Help Get-Command).Syntax
(help Get-Command).Syntax

# Shortcut to quickly determine the syntax of a command

Get-Command -Name Stop-Process -Syntax
Get-Command -Name Get-Alias -Syntax

Get-Alias -Definition Get-Command
gcm Stop-Process -Syntax

#region Finding commands

Get-Command -Name Get-Command -Syntax
Get-Command -Name *process*
Get-Command -Name *process* -CommandType Cmdlet, Function, Alias
Get-Command -Noun Process

help Get-Command -Parameter Noun

Get-Command -Noun *Process*
Get-Command -Noun Process*

Get-Command -Module Microsoft.PowerShell.PSResourceGet

#endregion

#region Running commands

# Execution Policy

# User Access Control (UAC)



# Get all the PowerShell version 7 processes that are running
Get-Process -Name pwsh

# Display vs actual properties
Get-Process -Name pwsh | Get-Member

# Filtering with Where-Object
Get-Process | Where-Object {$_.Name -eq 'pwsh'}
Get-Process | Where-Object -FilterScript {$_.Name -eq 'pwsh'}

# Simplified syntax
Get-Process | Where-Object Name -eq pwsh
Get-Process | Where-Object -Property Name -eq pwsh

# Compound Where-Object syntax
Get-Process | Where-Object {$_.Name -eq 'pwsh' -and $_.Parent -like '*WindowsTerminal*'}
Get-Process | Where-Object {$_.Name -eq 'pwsh' -and $_.Parent -match 'WindowsTerminal'}

#endregion

#region Using Microsoft.PowerShell.PSResourceGet commands

<#
    PSResourceGet is a module with commands for discovering, installing, updating and publishing PowerShell artifacts like Modules, DSC Resources, Role Capabilities, and Scripts.
#>

Get-Module -Name Microsoft.PowerShell.PSResourceGet, PowerShellGet -ListAvailable

$env:PSModulePath
$env:PSModulePath -split ';'
$env:PSModulePath -split [System.IO.Path]::PathSeparator

Find-PSResource -Name Microsoft.PowerShell.PSResourceGet

# The following command generates the error: "Update-Module: Module 'Microsoft.PowerShell.PSResourceGet' was not installed by using Install-Module, so it cannot be updated."
Update-Module -Name Microsoft.PowerShell.PSResourceGet
Install-Module -Name Microsoft.PowerShell.PSResourceGet

Get-Module -Name Microsoft.PowerShell.PSResourceGet -ListAvailable
Get-Module -Name Microsoft.PowerShell.PSResourceGet -ListAvailable | Sort-Object -Property Version
Get-Module -Name Microsoft.PowerShell.PSResourceGet -ListAvailable | Sort-Object -Property Version -Descending
Get-Module -Name Microsoft.PowerShell.PSResourceGet -ListAvailable | Sort-Object -Property Version -Descending | Select-Object -First 1
Get-Module -Name Microsoft.PowerShell.PSResourceGet -ListAvailable | Sort-Object -Property Version -Descending | Select-Object -First 1 -Property *
Get-Module -Name Microsoft.PowerShell.PSResourceGet -ListAvailable | Sort-Object -Property Version -Descending | Select-Object -First 1 -Property ModuleBase
Get-Module -Name Microsoft.PowerShell.PSResourceGet -ListAvailable | Sort-Object -Property Version -Descending | Select-Object -First 1 -ExpandProperty ModuleBase


Get-ChildItem -Path (Get-Module -Name Microsoft.PowerShell.PSResourceGet -ListAvailable | Sort-Object -Property Version -Descending | Select-Object -First 1 -ExpandProperty ModuleBase)

Get-ChildItem -Path (Get-Module -Name Microsoft.PowerShell.PSResourceGet -ListAvailable | Sort-Object -Property Version -Descending | Select-Object -First 1 -ExpandProperty ModuleBase) -Force

Import-Clixml -Path (Join-Path -Path (Get-Module -Name Microsoft.PowerShell.PSResourceGet -ListAvailable | Sort-Object -Property Version -Descending | Select-Object -First 1 -ExpandProperty ModuleBase) -ChildPath PSGetModuleInfo.xml)

Import-Clixml -Path (Join-Path -Path (Get-Module -Name Microsoft.PowerShell.PSResourceGet -ListAvailable | Sort-Object -Property Version -Descending | Select-Object -First 1 -ExpandProperty ModuleBase) -ChildPath PSGetModuleInfo.xml) | Select-Object -Property *

#endregion

#endregion

#region Scripting Language

#region Variables

# Commands for working with variables
Get-Command -Noun variable

# Don't use hungarian notation
$strName
$intNumber

# Instead define its type if it will only contain one type of object
[string]$name
[int]$number

# My personal preference
# Use camel case for user defined variables
$resourceGroupName

# Use pascal case for parameters
$ComputerName

# Dollar sign ($) isn't part of the variable name
Get-Process -Name pwsh -OutVariable pwshProcess
Write-Output $pwshProcess



#endregion

#region Arrays

#endregion

#region Hashtables



#endregion

#region If statements

# if statement example
if ($true) {
    Write-Output 'The condition is true'
}

# if else statement example
if ($false) {
    Write-Output 'The condition is true'
} else {
    Write-Output 'The condition is false'
}

# if elseif else statement example
if ($false) {
    Write-Output 'The condition is true'
} elseif ($true) {
    Write-Output 'The condition is true'
} else {
    Write-Output 'The condition is false'
}

# Real world scenario: Determine if a computer is online
if (Test-Connection -ComputerName localhost -Count 1 -Quiet) {
    Write-Output 'The computer is online'
} else {
    Write-Output 'The computer is offline'
}

#endregion

#endregion

#region Writing a Basic script *

#region Parameterizing the script

#endregion

#endregion

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
    $VSCodeSettings = $VSCodeSettings -replace '"window.zoomLevel": \d,', '"window.zoomLevel": 0,'
}

$VSCodeSettings | Out-File -FilePath $VSCodeSettingsPath

#endregion