#region Presentation Info
    
<#
    Multiline Comment Example
    PowerShell 101: The No-Nonsense Beginner’s Guide to PowerShell
    Presentation from PowerShell on the River 2019
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins    
#>    

#endregion


#region Safety

#Example of single line comment
#Safety to prevent the entire script from being run instead of a selection
throw "You're not supposed to run the entire script"

#endregion


#region Presentation Prep

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


#region Introduction

#What is PowerShell?

#Windows PowerShell, at least as of version 5.1, is an easy to use command-line shell and scripting environment
#for automating administrative tasks of Windows based systems.

#PowerShell Core is a cross platform, easy to use, command-line shell and scripting environment.

#endregion


#region Getting Started with PowerShell

#What do I need to get started with PowerShell?

#All modern versions of Windows operating systems ship with Windows PowerShell preinstalled
#Newer versions of Windows PowerShell are distributed as part of the Windows Management Framework (WMF)

#PowerShell Core is distributed on GitHub and is open source. It runs on Windows, macOS, and Linux

#Where to Find PowerShell

#How to launch PowerShell (Begin the presentation in the PowerShell console)

#Show why it's necessary to run PowerShell elevated
#which requires local admin privileges (attempt to
#start/stop a service) from a non-elevated session
Get-Service -Name W32Time | Stop-Service

#What version of PowerShell am I running?
$PSVersionTable
$PSVersionTable.PSVersion

#If this doesn't work, you have Windows PowerShell version 1 and need to update

#The ISE (Integrated Scripting Environment) is depricated and Microsoft is no longer actively developing it.
#VSCode (Visual Studio Code) and the PowerShell extension for it is where Microsoft is focusing all of their current and future effort.
#VSCode is a cross platform, open source editor.

#Launch VSCode (Visual Studio Code) from the PowerShell console by typing in "code" (code.cmd) without the quotes

#Execution Policy

#Show the current execution policy
Get-ExecutionPolicy

#Change execution policy to remote signed
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned

#endregion


#region The Help System

#Discoverability

#Command in PowerShell are called cmdlets
#They are in the form of Verb-Noun

#Verbs are from an approved list
Get-Verb

#And nouns should always be singular

#The Three Core Cmdlets in PowerShell
#Get-Help
#Get-Command
#Get-Member

#Get-Command is designed to help you find commands
#Name is a parameter and 'Get-Command' is the value provided
Get-Help -Name 'Get-Command'
Get-Command -Noun Service
Get-Command -Name Get-Service
(Get-Command -Name Get-Service).Parameters.Keys

#Update-Help
#Save-Help -DestinationPath \\dc01\PSHelp
Update-Help -SourcePath \\dc01\PSHelp

#Get-Help helps you learn how to use commands once you find them
#Parameter Sets
#Syntax
Get-Help -Name 'Get-Command'
Get-Command | Get-Random | Get-Help

#Help is a function that pipes Get-Help to more.exe

#List the about help topics
help about_* 
help about_Execution_Policies
help service
help Get-Service

#Highlight a command and press Cntl + F1 to display its help
Get-EventLog -LogName 'Windows PowerShell' -Newest 3

#Shortcut for figuring out how to use commands
gcm Get-Service -Syntax

#endregion


#region Discovering Objects, Properties, and Methods

#Get-Member helps you discover what objects (properties and methods) are available for commands
#Any command that produces object based output can be piped to Get-Member
Get-Service -Name W32Time
Get-Service -Name W32Time | Get-Member
Get-Service -Name W32Time | Get-Member -Force
Get-Service -Name w32time | Get-Member -MemberType Properties
Get-Service -Name w32time | Get-Member | Get-Member
(Get-Service -Name w32time | Get-Member).TypeName[0]
Get-Service -Name W32Time | Format-List -Property *
Get-Service -Name W32Time | Select-Object -Property *
Get-Service -Name W32Time | Format-List -Property * | Get-Member
Get-Service -Name W32Time | Select-Object -Property * | Get-Member

#Sometimes you have to use force (the force parameter)
$profile
$profile | Format-List -Property *
$profile | Format-List -Property * -Force
$profile | Select-Object -Property *

#To learn more about Get-Help, Get-Command, and Get-Member see the video from my
#PowerShell Fundamentals for Beginners Presentation from a couple of years ago:
#http://mikefrobbins.com/2013/03/21/florida-powershell-user-group-march-meeting-video-and-presentation-materials/

#endregion


#region One-Liners and the Pipeline

#Best Practice: Avoid aliases and positional parameters in anything other than one-liners
#Use full cmdlet and parameter names in any code that you're sharing
Get-Alias -Definition Get-Command, Get-Member, help, ForEach-Object, Where-Object

#Not Specifying a Verb in PowerShell is an Expensive Shortcut
Service
Trace-Command -Expression {Service} -Name CommandDiscovery -PSHost | Out-Null
Trace-Command -Expression {Get-Service} -Name CommandDiscovery -PSHost | Out-Null

#For more information, see: https://mikefrobbins.com/2017/09/27/not-specifying-a-verb-in-powershell-is-an-expensive-shortcut/

Get-WindowsOptionalFeature -FeatureName TelnetClient -Online

#What cmdlets have parameters that accept ServiceController objects?
#This does NOT mean that they accept Service Controllers via the pipeline
Get-Command -ParameterType ServiceController

#Find out if Stop-Service accepts ServiceController objects via the pipeline
help Stop-Service -ShowWindow
help Stop-Service -Parameter InputObject
help Stop-Service -Parameter Name

#ByValue (ServiceController). Notice the WhatIf parameter
Get-Service -Name BITS, W32Time | Stop-Service -WhatIf

#Confirm parameter
Get-Service -Name BITS, W32Time | Stop-Service -Confirm

#ByValue (String)
'bits', 'w32time' | Get-Member
'bits', 'w32time' | Stop-Service -WhatIf

#ByPropertyName
$Object = New-Object -TypeName PSObject -Property @{'Name' = 'w32time', 'bits'}
$Object
$Object | Get-Member
$Object | Stop-Service -WhatIf

#PassThru parameter
Stop-Service -Name BITS

#Only items that produce output can be piped to Get-Member
Stop-Service -Name BITS | Get-Member

Stop-Service -Name BITS -PassThru
Stop-Service -Name BITS -PassThru | Get-Member

#Stop the Windows time service using the stop method
Get-Service w32time
(Get-Service w32time).Stop()
Get-Service w32time
(Get-Service w32time).Start()
Get-Service w32time

Get-SqlAgentJob -ServerInstance SQL12

Get-Command -Noun SqlAgentJob

Get-SqlAgentJob -ServerInstance SQL12 | Get-Member -MemberType Method

(Get-SqlAgentJob -ServerInstance SQL12 -Name Backup.Subplan_1).Start()

#endregion


#region Filtering and Formating

#Filtering
Get-Service | Where-Object CanPauseAndContinue
Get-Service | Where-Object CanPauseAndContinue -eq $true

Get-SqlLogin -ServerInstance sql17 |
Where-Object {-not $_.PasswordExpirationEnabled} |
Select-Object -Property Name, LoginType

Get-SqlLogin -ServerInstance sql17 |
Get-Member -Name PasswordExpirationEnabled

Get-SqlLogin -ServerInstance sql17  |
Where-Object {-not $_.PasswordExpirationEnabled} |
Select-Object -Property Name, LoginType, PasswordExpirationEnabled

Get-SqlLogin -ServerInstance sql17 |
Where-Object {$_.PasswordExpirationEnabled -eq $false} |
Select-Object -Property Name, LoginType, PasswordExpirationEnabled

#"If you're going to eat an elephant, only eat it once." - Ed Wilson
$SqlLogins = Get-SqlLogin -ServerInstance sql17

$SqlLogins |
Where-Object {$_.PasswordExpirationEnabled -eq $false} |
Select-Object -Property Name, LoginType, PasswordExpirationEnabled

#Filter Left, Format right
#Filter as close to the source as possible

Get-Service | Where-Object Name -like Win*
Get-Service -Name Win*

Measure-Command {
    Get-Service | Where-Object Name -like Win*
}

Measure-Command {
    Get-Service -Name Win*
}

Measure-Command {
    1..1000 |
    ForEach-Object {
        Get-Service | Where-Object Name -like Win*
    }
}

Measure-Command {
    1..1000 |
    ForEach-Object {
        Get-Service -Name Win*
    }
}

Invoke-Sqlcmd -ServerInstance SQL12 -Database AdventureWorks2012 -Query '
select * from Person.Person' |
Where-Object LastName -eq 'Browning' |
Select-Object -Property BusinessEntityID, FirstName, MiddleName, LastName

Invoke-Sqlcmd -ServerInstance SQL12 -Database AdventureWorks2012 -Query "
select BusinessEntityID, FirstName, MiddleName, LastName from Person.Person where LastName = 'Browning'"

Measure-Command {
    Invoke-Sqlcmd -ServerInstance SQL12 -Database AdventureWorks2012 -Query '
    select * from Person.Person' |
    Where-Object LastName -eq 'Browning' |
    Select-Object -Property BusinessEntityID, FirstName, MiddleName, LastName
} -OutVariable Opt1

Measure-Command {
    Invoke-Sqlcmd -ServerInstance SQL12 -Database AdventureWorks2012 -Query "
    select BusinessEntityID, FirstName, MiddleName, LastName from Person.Person where LastName = 'Browning'"
} -OutVariable Opt2

$Opt1.Milliseconds / $Opt2.Milliseconds -as [int]

#endregion


#region PowerShell Remoting

#One-To-One Remoting
Enter-PSSession -ComputerName DC01
$env:COMPUTERNAME
Get-ADGroupMember -Identity 'Domain Admins'
Get-ADGroupMember -Identity 'Domain Admins' | Get-Member
Exit-PSSession

#One-To-Many Remoting
Invoke-Command -ComputerName sql16, sql17 {
    Get-LocalGroupMember -Group Administrators
}

#Deserialized objects
Invoke-Command -ComputerName sql16, sql17 {
    Get-LocalGroupMember -Group Administrators
} | Get-Member

Invoke-Command -ComputerName DC01, SQL08, SQL12, SQL14, SQL16, SQL17 {
    $PSVersionTable.PSVersion
}

Invoke-Command -ComputerName DC01, SQL08, SQL12, SQL14, SQL16, SQL17 {
    $PSVersionTable.PSVersion
} | Sort-Object -Property Major, Minor, PSComputerName

Invoke-Command -ComputerName DC01, SQL08, SQL12, SQL14, SQL16, SQL17 {
    $PSVersionTable.PSVersion
} | Sort-Object -Property Major, Minor, PSComputerName -Descending

Invoke-Command -ComputerName DC01, SQL08, SQL12, SQL14, SQL16, SQL17 {
    $PSVersionTable.PSVersion
} | Group-Object -Property Major

Invoke-Command -ComputerName DC01, SQL08, SQL12, SQL14, SQL16, SQL17 {
    $PSVersionTable.PSVersion
} | Group-Object -Property Major -NoElement

$PSDefaultParameterValues

$PSDefaultParameterValues += @{
    'Group-Object:NoElement' = $true
}

$PSDefaultParameterValues

Invoke-Command -ComputerName DC01, SQL08, SQL12, SQL14, SQL16, SQL17 {
    $PSVersionTable.PSVersion
} | Group-Object -Property Major

Invoke-Command -ComputerName DC01, SQL08, SQL12, SQL14, SQL16, SQL17 {
    $PSVersionTable.PSVersion
} | Sort-Object -Property Major, Minor, PSComputerName -Descending |
Format-Table -GroupBy Major

#endregion


#region Extending PowerShell with Modules and Snapins

#Get a list of modules that are currently imported and available for use
Get-Module

#Get a list of modules that exist in the $env:PSModulePath
Get-Module -ListAvailable

#Beginning with PowerShell v3, modules that exist in the $PSModule path
#are automatically imported when one of its cmdlets is used
$env:PSModulePath -split ';'

($env:PSModulePath -split ';')[0]
($env:PSModulePath -split ';')[1]
($env:PSModulePath -split ';')[2]

#Install the SQL Server PowerShell module from the PowerShell Gallery
#Install-Module -Name SQLServer -Force

#Manually import the SQL Server PowerShell module
Import-Module -Name SQLServer

#What commands exist in the SQLServer module?
Get-Command -Module SQLServer

#Query the AdventureWorks2012 database on SQL12
Invoke-Sqlcmd -ServerInstance sql12 -Database AdventureWorks2012 -Query '
select Employee.LoginID,
       Person.FirstName as givenname,
       Person.LastName as surname,
       Employee.JobTitle as title,
       Address.AddressLine1 as streetaddress,
       Address.City,
       Address.PostalCode,
       PersonPhone.PhoneNumber as officephone
from HumanResources.Employee
    join Person.Person
    on Employee.BusinessEntityID = Person.BusinessEntityID
    join Person.PersonPhone
    on Person.BusinessEntityID = PersonPhone.BusinessEntityID
    join Person.BusinessEntityAddress
    on PersonPhone.BusinessEntityID = BusinessEntityAddress.BusinessEntityID
    join Person.Address
    on BusinessEntityAddress.AddressID = Address.AddressID' | 
Select-Object -Property @{label='Name';expression={"$($_.givenname) $($_.surname)"}},
                        @{label='SamAccountName';expression={$_.loginid.tolower() -replace '^.*\\'}},
                        @{label='UserPrincipalName';expression={"$($_.loginid.tolower() -replace '^.*\\')@mikefrobbins.com"}},
                        @{label='DisplayName';expression={"$($_.givenname) $($_.surname)"}},
                        title,
                        givenname,
                        surname,
                        officephone,
                        streetaddress,
                        postalcode,
                        city |
Format-Table -AutoSize

#Return the number of users in the AdventureWorks OU in Active Directory
(Get-ADUser -Filter * -SearchBase 'OU=AdventureWorks Users,OU=Users,OU=Test,DC=mikefrobbins,DC=com').count

#Create 290 Active Directory users based on infomation in the  SQL AdventureWorks2012 database
Measure-Command {Invoke-Sqlcmd -ServerInstance sql12 -Database AdventureWorks2012 -Query '
select Employee.LoginID,
       Person.FirstName as givenname,
       Person.LastName as surname,
       Employee.JobTitle as title,
       Address.AddressLine1 as streetaddress,
       Address.City,
       Address.PostalCode,
       PersonPhone.PhoneNumber as officephone
from HumanResources.Employee
    join Person.Person
    on Employee.BusinessEntityID = Person.BusinessEntityID
    join Person.PersonPhone
    on Person.BusinessEntityID = PersonPhone.BusinessEntityID
    join Person.BusinessEntityAddress
    on PersonPhone.BusinessEntityID = BusinessEntityAddress.BusinessEntityID
    join Person.Address
    on BusinessEntityAddress.AddressID = Address.AddressID' | 
Select-Object -Property @{label='Name';expression={"$($_.givenname) $($_.surname)"}},
                        @{label='SamAccountName';expression={$_.loginid.tolower() -replace '^.*\\'}},
                        @{label='UserPrincipalName';expression={"$($_.loginid.tolower() -replace '^.*\\')@mikefrobbins.com"}},
                        @{label='DisplayName';expression={"$($_.givenname) $($_.surname)"}},
                        title,
                        givenname,
                        surname,
                        officephone,
                        streetaddress,
                        postalcode,
                        city | 
New-ADUser -Path 'OU=AdventureWorks Users,OU=Users,OU=Test,DC=mikefrobbins,DC=com'}

#Return a list of users in the AdventureWorks OU in Active Directory
(Get-ADUser -Filter * -SearchBase 'OU=AdventureWorks Users,OU=Users,OU=Test,DC=mikefrobbins,DC=com').Count

#endregion

#region PSKoans

#Install the PSKoans module from the PowerShell Gallery
Install-Module -Name Pester -Force -SkipPublisherCheck
Install-Module -Name PSKoans -Force

Measure-Karma

Measure-Karma -Meditate

#endregion


#region Bonus

#Pipe to clip.exe
(Get-Service -Name w32time).DisplayName | clip.exe

#endregion