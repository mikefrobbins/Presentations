#region Presentation Info
    
<#
    PowerShell + SQL Server = Better Together
    Presentation from SQL Saturday Birmingham 2019
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins    
#>    

#endregion

#region Safety to prevent the entire script from being run instead of a selection

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

#region Extending PowerShell with Modules and Snapins

#I've installed the SQLServer PowerShell module:
#Install-Module -Name SQLServer

#And the RSAT tools on my VM named Win10-1809
#Start-Process https://mikefrobbins.com/2018/10/03/use-powershell-to-install-the-remote-server-administration-tools-rsat-on-windows-10-version-1809/
#Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability -Online

#I've also install two modules that I wrote which are also available in the PowerShell Gallery
#Install-Module -Name MrToolkit, MrSQL
Import-Module -Name ActiveDirectory, SQLServer
Import-Module -Name MrToolKit
Import-Module -Name MrSQL

#Execution Policy

#Show the current execution policy
Get-ExecutionPolicy

#Change execution policy to remote signed
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned

#Get a list of modules that are currently imported and available for use
Get-Module

#Get a list of modules that exist in the $env:PSModulePath
Get-Module -ListAvailable
(Get-Module -ListAvailable).Count

#Beginning with PowerShell v3, modules that exist in the $PSModule path
#are automatically imported when one of its cmdlets is used
$env:PSModulePath -split ';'

($env:PSModulePath -split ';')[0]
($env:PSModulePath -split ';')[1]
($env:PSModulePath -split ';')[2]

#Deserialized objects

#One-To-Many Remoting
Invoke-Command -ComputerName dc01, sql05, sql08, sql12, sql14, sql16, sql17 {
    $PSVersionTable.PSVersion
}

Invoke-Command -ComputerName sql12, sql14, sql16, sql17 {
    Get-Module -Name SQLPS -ListAvailable
} | Format-Table -Property ModuleType, Version, Name, ExportedCommands, PSComputerName

#One-To-One Remoting

Enter-PSSession -ComputerName sql08
Set-Location -Path C:\

$env:COMPUTERNAME

Import-Module -Name SQLPS
Get-Module -Name SQLPS -ListAvailable

#Show the snap-in's that are loaded and available for use
Get-PSSnapin

#Show the snap-in's that are installed that are available to be added to the current PowerShell session
Get-PSSnapin -Registered

#Add the SQL snap-in's to the current PowerShell session
Add-PSSnapin -Name SqlServer*

#Determine what commands exist in the SQL snapin's
Get-Command -Module SQLServer*

#Exit the one-to-one remoting session
Exit-PSSession

Enter-PSSession -ComputerName sql12
Set-Location -Path C:\
Import-Module -Name SQLPS
Get-Module -Name SQLPS -ListAvailable
Get-Command -Module SQLPS
(Get-Command -Module SQLPS).Count
Exit-PSSession

#Note the warning message and the current location is changed
Enter-PSSession -ComputerName sql14
Set-Location -Path C:\
Import-Module -Name SQLPS
Get-Module -Name SQLPS -ListAvailable
Get-Command -Module SQLPS
(Get-Command -Module SQLPS).Count
Exit-PSSession

Enter-PSSession -ComputerName sql16
Set-Location -Path C:\
Import-Module -Name SQLPS
Get-Module -Name SQLPS -ListAvailable
Get-Command -Module SQLPS
(Get-Command -Module SQLPS).Count
Exit-PSSession

Enter-PSSession -ComputerName sql17
Set-Location -Path C:\
Import-Module -Name SQLPS
Get-Module -Name SQLPS -ListAvailable
Get-Command -Module SQLPS
(Get-Command -Module SQLPS).Count
Exit-PSSession

#What commands exist in the SQLServer PowerShell module?
Get-Command -Module SQLServer
(Get-Command -Module SQLServer).Count

Get-Command -Module dbatools
(Get-Command -Module dbatools).Count

#endregion

#region Running TSQL code and Stored Procedures from PowerShell

#Using the Invoke-Sqlcmd cmdlet to run your existing TSQL code
#is one of the ways for accessing SQL server with Powershell

Invoke-Sqlcmd -ServerInstance sql08 -Database master -Query '
select name, database_id, compatibility_level, recovery_model_desc from sys.databases'

#Filtering

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

#Run a stored procedure from PowerShell
Invoke-Sqlcmd -ServerInstance sql12 -Database master -Query 'EXEC sp_databases'

#This will generate an error because there are 2 columns with the name SPID
Invoke-Sqlcmd -ServerInstance sql12 -Database master -Query 'EXEC sp_who2'

#endregion

#region Working with SQL Server thorugh the use of SMO (SQL Management Objects)

$SQL = New-Object –TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList 'sql12'

$SQL.EnumProcesses() |
Select-Object -Property Name, Spid, Command, Status, Login, Database, BlockingSpid |
Format-Table -AutoSize

#endregion

#region Providers

Get-PSProvider
Get-PSDrive
Get-ChildItem -Path SQLServer:\SQL\SQL12\Default\Databases

#Notice that the previous output using the SQL PS Provider is very similar to the output when using SMO

$SQL.Databases

#Look at the object type returned by that previous command:
($SQL.Databases | Get-Member).TypeName[0]

#It's the same object type as what the SQL PowerShell provider returns

(Get-ChildItem -Path SQLServer:\SQL\SQL12\Default\Databases | Get-Member).TypeName[0]

#Why was the output different between the two?
#Because the SQL Provider is filtering out the system databases until the Force parameter is used

Get-ChildItem -Path SQLServer:\SQL\SQL12\Default\Databases -Force

#endregion

#region SQL cmdlets

Get-SqlDatabase -ServerInstance SQL12

#That cmdlet also returns the same type of object

(Get-SqlDatabase -ServerInstance SQL12 | Get-Member).TypeName[0]

Get-SqlAgentJob -ServerInstance SQL12

Get-Command -Noun SqlAgentJob

Get-SqlAgentJob -ServerInstance SQL12 | Get-Member -MemberType Method

(Get-SqlAgentJob -ServerInstance SQL12 -Name Backup.Subplan_1).Start()

#endregion

#region dbatools

Get-DbaDatabase -SqlInstance SQL12

(Get-DbaDatabase -SqlInstance SQL12 | Get-Member).TypeName[0]

Invoke-DbaQuery -SqlInstance SQL12 -Database master -Query "
    select name from sys.databases
"

Get-DbaDbBackupHistory -SqlInstance SQL12 -Database AdventureWorks2012

#endregion

#region .NET Framework


Get-Module -Name MrSQL -ListAvailable

Invoke-MrSqlDataReader -ServerInstance sql05 -Database msdb -Query "
    SELECT backupset.backup_set_id, backupset.last_family_number, backupset.database_name, backupset.recovery_model, backupset.type,
    backupset.position, backupmediafamily.physical_device_name, backupset.backup_start_date, backupset.backup_finish_date
    FROM backupset
    INNER JOIN backupmediafamily
    ON backupset.media_set_id = backupmediafamily.media_set_id
    WHERE database_name = 'pubs'
    ORDER BY backup_start_date"

function Get-DatabaseList {
    [CmdletBinding()]
    param (
        [string[]]$ComputerName
    )
    foreach ($Computer in $ComputerName){
        Invoke-MrSqlDataReader -ServerInstance $Computer -Database msdb -Query "
            select name from sys.databases
        " | Select-Object -Property @{label='ComputerName';expression={$Computer}}, Name
    }
}

Get-DatabaseList -ComputerName sql05, sql08, sql12, sql14, sql16, sql17

#Not interested in writing your own code to leverage the .NET Framework?
#Try Invoke-SqlCmd2 which can be found in my SQL repo on GitHub

Invoke-Sqlcmd2 -ServerInstance SQL05 -Database msdb -Query "
    SELECT backupset.backup_set_id, backupset.last_family_number, backupset.database_name, backupset.recovery_model, backupset.type,
    backupset.position, backupmediafamily.physical_device_name, backupset.backup_start_date, backupset.backup_finish_date
    FROM backupset
    INNER JOIN backupmediafamily
    ON backupset.media_set_id = backupmediafamily.media_set_id
    WHERE database_name = 'pubs'
    ORDER BY backup_start_date"

#endregion

#region Create AD User from SQL Database

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