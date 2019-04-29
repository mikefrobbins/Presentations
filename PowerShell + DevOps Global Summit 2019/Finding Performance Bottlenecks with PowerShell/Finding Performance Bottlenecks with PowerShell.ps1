#region Presentation Info
    
<#
    Finding Performance Bottlenecks with PowerShell
    Presentation from the PowerShell + DevOps Global Summit 2019
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

#Set location
$Path = 'C:\Demo'
if (-not(Test-Path -Path $Path -PathType Container)) {
    New-Item -Path $Path -ItemType Directory | Out-Null
}
Set-Location -Path $Path

#Clear the screen
Clear-Host

#endregion

#region Demo Environment

<#
    A workstation running Windows 10 version 1809 and a domain controller running Windows Server
    2019 (server core installation) is used throughout this demo. They're running Windows PowerShell
    version 5.1 which ships in the box with those operating systems. PowerShell must be run elevated
    as an administrator and the execution policy must be set to remote signed or less restrictive
    for some of the examples in this demo to complete successfully.
#>

Get-ExecutionPolicy
#Set-ExecutionPolicy -ExecutionPolicy RemoteSigned

<#
    Windows PowerShell, not PowerShell Core
    Some of the cmdlets used in this demo do not exist in PowerShell Core.
    Specifically, the Get-Counter cmdlet.
#>

#Cntl + Shift + T and open a PowerShell Core terminal
Set-Location -Path C:\
$PSVersionTable.PSVersion
Get-Command -Module Microsoft.PowerShell.Diagnostics

Get-Counter -Counter '\Processor(*)\% Processor Time'
Get-CimInstance -ClassName Win32_PerfFormattedData_Counters_ProcessorInformation -Filter "Name = '_Total'"

$Counter = New-Object -TypeName System.Diagnostics.PerformanceCounter('Processor Information', '% Processor Time', '_Total')
$Counter

while($true){
    $Counter.NextValue()
    Start-Sleep -Milliseconds 150
}

"\\$env:COMPUTERNAME\$($Counter.CategoryName -replace '\s.*$')($($Counter.InstanceName))\$($Counter.CounterName) :`r`n $($Counter.NextValue())"

#endregion

#region Introduction

<#
    Creating a baseline of the performance for the systems in your environment can be extremely useful,
    but it’s rarely something that’s done in information technology (IT) because no one cares about
    infrastructure until there’s a problem.
#>


#endregion

#region Performance Counters

<#
    Even if you don’t have a baseline, performance counters can still be beneficial when trying to
    determine where performance problems reside. While you do need something to compare the current
    results to, generic industry standard recommendations can be found on the Internet.
#>


<#
    The Get-Counter PowerShell cmdlet is used to query performance counters on Windows systems.
    One of the reasons I chose to speak on this topic is because the Get-Counter cmdlet is not very
    intuitive and the results for it aren’t what I would call a great object-oriented design.
#>

#endregion

#region Finding Performance Counter Sets

<#
    If you don’t already know what performance counters you want to query, you’ll need to find
    them somehow. While you could search the Internet, finding performance counters with PowerShell
    itself is easy enough. A good place to start would be to read the help for the Get-Counter cmdlet.
#>

Help Get-Counter -ShowWindow
Get-Command -Name Get-Counter -Syntax

#Types of objects produced by Get-Counter
(Get-Counter -Counter '\LogicalDisk(_Total)\% Free Space' | Get-Member).TypeName[0]
((Get-Counter -Counter '\LogicalDisk(_Total)\% Free Space').CounterSamples | Get-Member).TypeName[0]
(Get-Counter -ListSet LogicalDisk | Get-Member).TypeName[0]

#Get counter sets on the local computer

Get-Counter -ListSet *

<#
    As with any other commands in PowerShell that produce object-based output, a list of the properties
    for Get-Counter can be determined by piping it to Get-Member. It’s a good idea to start here no matter
    how much you know about PowerShell because what you think are the property names as shown
    in the output of a command aren’t always the actual property names.
#>

Get-Counter -ListSet * | Get-Member -MemberType Properties
(Get-Counter -ListSet * | Get-Member -MemberType Properties).Count

<#
    If you select all of the properties for the first result, you’ll get an idea of what type
    of values are returned for each property. Get-Counter just happens to return all of its
    properties by default regardless of whether or not you select all of them from the pipeline.
#>

Get-Counter -ListSet * | Select-Object -First 1 -Property *

<#
    CounterSetName is one of the properties returned when using the ListSet parameter of Get-Counter. Its
    property returns the category for a group of performance counters. A list of all the CounterSetNames
    can easily be determined by simply returning that single property.
#>

Clear-Host
(Get-Counter -ListSet *).CounterSetName

#I recommend sorting the results

Clear-Host
(Get-Counter -ListSet *).CounterSetName | Sort-Object

<#
    The results can be limited by filtering left if you have an idea of the specific set
    of performance counters that you’re looking for. In the following example, the results
    are limited to the ones that are related to disks.
#>

Clear-Host
(Get-Counter -ListSet *disk*).CounterSetName

#endregion

#region Finding Performance Counter Names

<#
    Once you’ve narrowed your choice down to a specific category with CounterSetName,
    the performance counter names themselves can be determine by returning the Counter property.
#>

Clear-Host
(Get-Counter -ListSet PhysicalDisk).Counter

#The Paths property returns the same thing as the Counter property

Clear-Host
(Get-Counter -ListSet PhysicalDisk).Paths
(Get-Counter -ListSet PhysicalDisk).Counter

Clear-Host
Get-Counter -ListSet PhysicalDisk

Clear-Host
Compare-Object -ReferenceObject (Get-Counter -ListSet PhysicalDisk).Counter -DifferenceObject (Get-Counter -ListSet PhysicalDisk).Paths

#Counter is an alias property of Paths
Get-Counter -ListSet PhysicalDisk | Get-Member -MemberType Properties

#More trickery
(Get-Counter -ListSet PhysicalDisk | Where-Object Counter -like '*Queue*').Counter
(Get-Counter -ListSet PhysicalDisk | Where-Object Paths -like '*Queue*').Counter
(Get-Counter -ListSet PhysicalDisk).Count
(Get-Counter -ListSet PhysicalDisk).Counter | Where-Object {$_ -like '*Queue*'}
(Get-Counter -ListSet PhysicalDisk).Counter.Count

#endregion

#region The Top 10 Performance Counters

<#
    • '\PhysicalDisk(*)\% Idle Time'
    • '\PhysicalDisk(*)\Avg. Disk sec/Read'
    • '\PhysicalDisk(*)\Avg. Disk sec/Write'
    • '\PhysicalDisk(*)\Current Disk Queue Length'
    • '\Memory\Available Bytes'
    • '\Memory\Pages/sec'
    • '\Network Interface(*)\Bytes Total/sec'
    • '\Network Interface(*)\Output Queue Length'
    • '\Hyper-V Hypervisor Logical Processor(*)\% Total Run Time'
    • '\Paging File(*)\% Usage'
#>

#Source: Top 10 most important performance counters for Windows and their recommended values
#https://blogs.technet.microsoft.com/bulentozkir/2014/02/14/top-10-most-important-performance-counters-for-windows-and-their-recommended-values/

#endregion

#region Querying Performance Counters

#Get-Counter by itself returns a default set of results for the local computer
Get-Counter

<#
    There aren’t many choices when it comes to properties for querying a specific performance counter
    with Get-Counter.
#>

Clear-Host
Get-Counter -Counter '\PhysicalDisk(*)\% Idle Time' | Get-Member -MemberType Properties

<#
    There’s a Timestamp property which is self-explanatory.
#>

(Get-Counter -Counter '\PhysicalDisk(*)\% Idle Time').Timestamp

<#
    There’s a CounterSamples property which returns each instance of the results
    for that particular performance counter as a separate result
#>
    
(Get-Counter -Counter '\PhysicalDisk(*)\% Idle Time').CounterSamples
(Get-Counter -Counter '\PhysicalDisk(*)\% Idle Time').CounterSamples.Count
((Get-Counter -Counter '\PhysicalDisk(*)\% Idle Time').CounterSamples | Get-Member).TypeName[0]

<#
    Then there’s the Readings property which returns all instances of a particular
    performance counter as a single result.
#>

(Get-Counter -Counter '\PhysicalDisk(*)\% Idle Time').Readings
(Get-Counter -Counter '\PhysicalDisk(*)\% Idle Time').Readings.Count
((Get-Counter -Counter '\PhysicalDisk(*)\% Idle Time').Readings | Get-Member).TypeName[0]

<#
    Clearly, CounterSamples is the easier of the two when choosing between the properties that return
    the actual results of a performance counter because each instance is returned as a separate result.
#>

#Query all instances of one performance counter
Get-Counter -Counter '\LogicalDisk(*)\% Free Space'

#Paths with Instances
(Get-Counter -ListSet LogicalDisk).PathsWithInstances
(Get-Counter -ListSet LogicalDisk).PathsWithInstances | Where-Object {$_ -like '*% Free Space*'}
((Get-Counter -ListSet LogicalDisk).PathsWithInstances | Where-Object {$_ -like '*% Free Space*'}) -replace '^.*\(|\).*$'
Get-Counter -Counter '\LogicalDisk(C:)\% Free Space', '\LogicalDisk(D:)\% Free Space'
Get-Counter -Counter '\LogicalDisk(*)\% Free Space' | Where-Object CounterSamples -NotLike '*_Total*'
(Get-Counter -Counter '\LogicalDisk(*)\% Free Space').CounterSamples
(Get-Counter -Counter '\LogicalDisk(*)\% Free Space').CounterSamples | Where-Object InstanceName -NotLike '_Total'

#Query all of the logical disk performance counters
Get-Counter -ListSet LogicalDisk
(Get-Counter -ListSet LogicalDisk).Counter | Get-Counter
Get-Counter -ListSet LogicalDisk | Get-Counter

#Store the counter(s) in a variable
$LogicalDisk = '\LogicalDisk(*)\% Free Space'
$LogicalDisk | Get-Counter -MaxSamples 5

#Store the counters in a variable and then query them
$LogicalDisk = (Get-Counter -ListSet LogicalDisk).Counter
Get-Counter -Counter $LogicalDisk

#Query all of them three times, every two seconds
Get-Counter -ListSet LogicalDisk | Get-Counter -SampleInterval 2 -MaxSamples 3

#Query all of them continuously
Get-Counter -ListSet LogicalDisk | Get-Counter -Continuous

#Trying to use both the Continuous and MaxSamples parameters results in an error
Get-Counter -ListSet LogicalDisk | Get-Counter -Continuous -MaxSamples 10

#Why aren't those parameters in different parameter sets if they're mutually exclusive?
Get-Command -Name Get-Counter -Syntax

#The default and minimum value for SampleInterval is 1. The default and minimum value for MaxSamples is also 1.
Get-Counter -ListSet LogicalDisk | Get-Counter -SampleInterval 0 -MaxSamples 10
Get-Counter -ListSet LogicalDisk | Get-Counter -SampleInterval 1 -MaxSamples 10 -OutVariable Results
$Results

#Query Performance Counter Information on a remote system
(Get-Counter -ComputerName DC01 -ListSet 'tcpv4').Counter | Get-Counter

#Query Performance Counters as a job
Start-Job {Get-Counter -Counter '\LogicalDisk(_Total)\% Free Space' -MaxSamples 10}
Get-Job
Get-Job | Receive-Job -Keep
Get-Job | Receive-Job -Keep | Get-Member
(Get-Job | Receive-Job -Keep | Get-Member).TypeName[0]
Get-Job | Receive-Job -Keep | Export-Counter -Path $Path\job-results.blg -Force

#Different ways to query a remote system
Get-Counter -ComputerName DC01 -Counter '\LogicalDisk(*)\% Free Space'
Get-Counter -Counter '\\DC01\LogicalDisk(*)\% Free Space'

Get-Command -Name Get-Counter -Syntax

#Determine free disk space percentage with performance counters
Get-Counter -Counter '\LogicalDisk(_Total)\% Free Space' -ComputerName DC01
$DiskSpace = Get-Counter -Counter '\LogicalDisk(*)\% Free Space' -ComputerName DC01
$DiskSpace
$DiskSpace.CounterSamples | Where-Object CookedValue -lt 15
$DiskSpace.CounterSamples | Where-Object CookedValue -lt 75

#Find the top processes with performance counters
$Process = Get-Counter -Counter '\Process(*)\% Processor Time' -ErrorAction SilentlyContinue
$Process.CounterSamples | Sort-Object -Property CookedValue -Descending | Select-Object -First 6

<#
    One of the problems with the results of the CounterSamples property is the computer name and the
    performance counter being queried are returned jumbled together.

    It can become messy when you’re trying to use a regular expression (regex) to parse the individual
    information from the Path property.
#>

(Get-Counter -Counter '\PhysicalDisk(*)\% Idle Time').CounterSamples |
Select-Object -Property @{label='ComputerName';expression={
$_.Path -replace '^\\\\|\\.*$'}},
@{label='Object';expression={
$_.Path -replace "^\\\\$env:COMPUTERNAME\\|\(.*$"}},
@{label='Counter';expression={$_.Path -replace '^.*\\'}},
@{label='Instance';expression={$_.InstanceName}},
@{label='Value';expression={$_.CookedValue}},
@{label='TimeStamp';expression={$_.TimeStamp}} |
Format-Table -AutoSize

<#
    Luckily the format for the results is the same for all performance counters, or at least I haven’t run
    into one that’s different. Or so I thought...
#>

#Local versus remote differences

Get-Counter
Get-Counter -ComputerName DC01

Invoke-Command -ComputerName DC01 {
    Get-Counter
}

#My regular expression doesn't work properly because of the extra backslash after the computer name when querying remote computers

(Get-Counter -ComputerName DC01 -Counter '\PhysicalDisk(*)\% Idle Time').CounterSamples |
Select-Object -Property @{label='ComputerName';expression={
$_.Path -replace '^\\\\|\\.*$'}},
@{label='Object';expression={
$_.Path -replace "^\\\\$env:COMPUTERNAME\\|\(.*$"}},
@{label='Counter';expression={$_.Path -replace '^.*\\'}},
@{label='Instance';expression={$_.InstanceName}},
@{label='Value';expression={$_.CookedValue}},
@{label='TimeStamp';expression={$_.TimeStamp}} |
Format-Table -AutoSize

#endregion

#region Creating a Reusable Tool

<#
    Just in case you didn’t read the help for Get-Counter, let’s take a look at the help for the Counter
    parameter. The one specific thing to notice is that more than one performance counter can be queried
    at the same time without having to call Get-Counter for each individual one.
#>

#help Get-Counter -Parameter Counter 
Get-Command -Name Get-Counter -Syntax

<#
    The Get-MrTop10Counter function stores the top 10 performance counters in a hash table.
    It queries the values for each of them while only running the Get-Counter cmdlet once. The ability
    to query these performance counters for a remote computer has also been added to this function.

    <See the Get-MrTop10Count.ps1 file in the presentation folder>

    In the following example, the Get-MrTop10Counter function is being run against the local computer.
#>

Get-MrTop10Counter | Where-Object Instance -like '*c:' |
Format-Table -AutoSize

<#
    It’s difficult to determine if the value returned by a specific performance counter is normal or not
    without having something to compare it to. This is why it’s best to have a baseline as I previously
    mentioned, but values that are considerably outside of the normal range for a specific counter can
    be found on the Internet.
#>

#endregion

#region Automate the Validation of Performance Counters

<#
    While querying performance counters with PowerShell is relatively easy as shown in the previous
    portion of this demo, who really wants to query each one of them and validate they’re within an
    acceptable range manually? I’m assuming that no one does.
#>

#endregion

#region Pester

<#
    In this section, I’ll use Pester to automate the testing of whether or not the performance counter
    values returned by Get-MrTop10Counter are within their recommended ranges.

    Pester is an open-source Behavior-Driven Development (BDD) based framework for PowerShell.

    While a version of Pester ships with Windows 10, it’s an older and out of date version that must be
    updated before attempting to run the examples shown in this demo.

    I recommend installing the latest version of Pester from the PowerShell Gallery. While Update-
    Module may work depending on whether or not you’ve previously updated Pester, the following
    command will work regardless of which version you currently have installed as long as the computer
    it’s being run on is connected to the Internet and has PowerShell verison 5 or higher installed.
#>

Install-Module -Name Pester -Force -SkipPublisherCheck

#More information about Pester can be found on its Wiki: https://github.com/pester/Pester/wiki

#endregion

#region Validation Tests

<#
    We’ll start out by writing a simple validation test for the Current Disk Queue Length for the “C”
    drive on your local computer.
#>

Describe 'Current Disk Queue Length' {
    It 'Should not be higher than 2' {
        (Get-Counter -Counter '\PhysicalDisk(* c:)\Current Disk Queue Length'
        ).CounterSamples.CookedValue |
        Should -Not -BeGreaterThan 2
    }
}

#endregion

#region Testing Collections

<#
    A helper function to convert the results of a command to a hash table is needed in the next section.
    Luckily, I had previously written a function to accomplish this exact task for similar scenario at
    some point in the past and saved it in my PowerShell repository on GitHub.
    
    This helper function, ConvertTo-MrHashTable, is also included in the presentation folder.
    
    As many computers do, the computer used in this demo has multiple hard drives. I’ll need to
    iterate through each one of them individually with my infrastructure test. While I could use a
    foreach loop to prevent writing the same redundant code for each one of them over and over again,
    Pester has a TestCases parameter which is specifically designed for this exact scenario.
#>

$Counters = Get-MrTop10Counter
Describe 'Physical Disk Current Disk Queue Length' {
    $Counter = 'Current Disk Queue Length'
    $Cases = $Counters.Where({
        $_.Counter -eq $Counter -and $_.Instance -ne '_total'
    }) |
    Select-Object -Property Instance |
    ConvertTo-MrHashTable

    It 'Should Not Be Greater than 2 for: <Instance>' -TestCases $Cases {
        param($Instance)
        $Counters.Where({
            $_.Instance -eq $Instance -and $_.Counter -eq $Counter
        }).Value |
        Should -Not -BeGreaterThan 2
    }
}

<#
    The total for all instances (all hard drives) in the computer has been excluded because for this
    particular test, we’re concerned about testing each hard drive individually and not the total for
    all of them combined.
#>

#endregion

#region Advanced Validation Tests

<#
    Now it’s time to write these same types of infrastructure validation tests for all of the top 10
    performance counters that Get-MrTop10Counter queries. Writing validation tests for some of the
    counters is more complicated than others.
    
    Validating that the percent idle time for a physical disk is
    not less than sixty percent is simple because the results are returned as a percentage by default.
#>

$Counters = Get-MrTop10Counter

Describe "Physical Disk % Idle Time for $Computer" {
    $Counter = '% Idle Time'
    $Cases = $Counters.Where({
        $_.Counter -eq $Counter -and $_.Instance -ne '_total'
    }) |
    Select-Object -Property Instance |
    ConvertTo-MrHashTable

    It 'Should Not Be Less than 60% for: <Instance>' -TestCases $Cases {
        param($Instance)
        $Counters.Where({
            $_.Instance -eq $Instance -and $_.Counter -eq $Counter
        }).Value |
        Should -Not -BeLessThan 60
    }
}

<#
    Validating the average time that disk transfers took is another story since the counters return seconds
    instead of milliseconds and it’s not uncommon to see the results returned in scientific notation
    instead of a numeric datatype that can be used for normal calculations.
#>

.00000009 * 1000
.00000009 * 1000 -as [decimal]

Describe "Physical Disk Avg. Disk sec/Read for $Computer" {
    $Counter = 'Avg. Disk sec/Read'
    $Cases = $Counters.Where({
        $_.Counter -eq $Counter -and $_.Instance -ne '_total'
    }) |
    Select-Object -Property Instance |
    ConvertTo-MrHashTable

    It 'Should Not Be Greater than 20ms for: <Instance>' -TestCases $Cases {
        param($Instance)
        $Counters.Where({
            $_.Instance -eq $Instance -and $_.Counter -eq $Counter
        }).Value * 1000 -as [decimal] |
        Should -Not -BeGreaterThan 20
    }
}

Describe "Physical Disk Avg. Disk sec/Write for $Computer" {
    $Counter = 'Avg. Disk sec/Write'
    $Cases = $Counters.Where({
        $_.Counter -eq $Counter -and $_.Instance -ne '_total'
    }) |
    Select-Object -Property Instance |
    ConvertTo-MrHashTable

    It 'Should Not Be Greater than 20ms for: <Instance>' -TestCases $Cases {
        param($Instance)
        $Counters.Where({
            $_.Instance -eq $Instance -and $_.Counter -eq $Counter
        }).Value * 1000 -as [decimal] |
        Should -Not -BeGreaterThan 20
    }
}

<#
    Determining if at least ten percent of memory is available is another tricky one because the
    performance counter returns the currently available bytes of memory, but you need to know how
    much physical memory is installed in the machine to be able to calculate the percentage. Figuring
    this out on a remote system only complicates matters even further.
#>

Describe "Memory Available Bytes for $Computer" {
    It 'Should Not Be Less than 10% free' {
        ($Counters.Where({$_.Counter -eq 'Available Bytes'}).Value / 1MB) /
        ((Get-CimInstance @Params -ClassName Win32_PhysicalMemory -Property Capacity |
        Measure-Object -Property Capacity -Sum).Sum / 1MB) * 100 -as [int] |
        Should -Not -BeLessThan 10
    }
}

<#
    Verifying that a network card’s available bandwidth isn’t saturated is also complicated. The
    performance counter returns total bytes a second. You’ll need to determine the current link speed of
    the network adapter in order to be able to calculate that it’s not more than sixty-five percent utilized.
    If that weren’t complicated enough, the performance counter returns parentheses as brackets in the
    network cards description.
#>

Describe "Network Interface Bytes Total/sec for $Computer" {
    $Counter = 'Bytes Total/sec'
    $Cases = $Counters.Where({
    $_.Counter -eq $Counter -and $_.Instance -notmatch 'isatap'}) |
    Select-Object -Property Instance |
    ConvertTo-MrHashTable

    It 'Should Not Be Greater than 65% for: <Instance>' -TestCases $Cases {
        param($Instance)
        ($Counters.Where({
            $_.Instance -eq $Instance -and $_.Counter -eq $Counter
        }).Value) /
        ((Get-NetAdapter @Params -InterfaceDescription (
            $Instance -replace '\[', '(' -replace '\]', ')' -replace '_', '#')).Speed
        ) * 100 |
        Should -Not -BeGreaterThan 65
    }
}

<#
    To run these tests on a remote system, both a Common Information Model (CIM) session needs to
    be established to it and PowerShell needs to be run with enough privileges to query performance
    counters on the remote system.
    The code for the tests used to validate all of the top 10 performance counters, Performance-Counter-
    Validation.Tests.ps1, is included in the presentations folder. Since these tests
    have been saved as a PowerShell script with a .tests.ps1 extension, they can be run against the local
    system by simply running Invoke-Pester as shown in the following example.
#>

Invoke-Pester -Script .\Performance-Counter-Validation.Tests.ps1

<#
    As shown in the previous example, these tests can easily be run against the local computer to get
    an idea of where performance bottlenecks reside. To run it against a remote system, simply create a
    CIM session, run the script itself, and specify the CimSession parameter.
#>

$CimSession = New-CimSession -ComputerName DC01
.\Performance-Counter-Validation.Tests.ps1 -CimSession $CimSession

#You’re looking for anything that the tests return in red instead of green.

#endregion

#region Summary

<#
    In this demo you’ve learned how to find performance bottlenecks of Windows based systems
    with PowerShell. You’ll now be able to find specific performance counters for yourself, query those
    performance counters and validate that they’re within acceptable ranges.
#>

#endregion

#Bonus Content

#Export-Counter
#binary performance log

#Exported files must contain at least two data samples
Get-Counter -Counter "\Processor(*)\% Processor Time" | Export-Counter -Path $Path\Counters.blg -Force
Import-Counter -Path $Path\Counters.blg

#Export Counter Samples and reimport them
Get-Counter -Counter "\Processor(*)\% Processor Time" -MaxSamples 2 | Export-Counter -Path $Path\Counters.blg -Force
Import-Counter -Path $Path\Counters.blg

#Convert the format of an existing exported performance log
Get-Counter -Counter "\Processor(*)\% Processor Time" -MaxSamples 10 | Export-Counter -Path $Path\Counters.blg -Force
Import-Counter -Path $Path\Counters.blg | Export-Counter -Path $Path\Counters.csv -Force -FileFormat csv
Import-Counter -Path $Path\Counters.blg | Export-Counter -Path $Path\Counters.tsv -Force -FileFormat tsv
Import-Counter -Path $Path\Counters.blg
Import-Counter -Path $Path\Counters.csv
Import-Counter -Path $Path\Counters.tsv
Import-Counter -Path $Path\Counters.blg, $Path\Counters.csv, $Path\Counters.tsv

#
$Counter = '\\DC01\Process(Idle)\% Processor Time'
$Results = Get-Counter -Counter $Counter
$Results.CounterSamples | Select-Object -Property *

Get-Counter -Counter '\Processor(*)\% Processor Time'


$Counters = '\PhysicalDisk(*)\% Idle Time',
'\PhysicalDisk(*)\Avg. Disk sec/Read',
'\PhysicalDisk(*)\Avg. Disk sec/Write',
'\PhysicalDisk(*)\Current Disk Queue Length',
'\Memory\Available Bytes',
'\Memory\Pages/sec',
'\Network Interface(*)\Bytes Total/sec',
'\Network Interface(*)\Output Queue Length',
'\Paging File(*)\% Usage'

Get-Counter -Counter $Counters -Continuous | Export-Counter -Path $Path\Counters.blg -MaxSize 1MB -Force
Import-Counter -Path Threads.csv | Export-Counter -Path ThreadTest.blg -Circular -MaxSize 1MB



$Counters = '\PhysicalDisk(*)\% Idle Time',
'\PhysicalDisk(*)\Avg. Disk sec/Read',
'\PhysicalDisk(*)\Avg. Disk sec/Write',
'\PhysicalDisk(*)\Current Disk Queue Length',
'\Memory\Available Bytes',
'\Memory\Pages/sec',
'\Network Interface(*)\Bytes Total/sec',
'\Network Interface(*)\Output Queue Length',
'\Paging File(*)\% Usage'

Get-Counter -Counter $Counters -SampleInterval 1 -MaxSamples 3

Get-Counter -Counter $Counters -SampleInterval 1 -MaxSamples 12 | Export-Counter -Path C:\Demo\Results.blg -Force

Import-Counter -Path C:\Demo\Results.blg

Import-Counter -Path C:\Demo\Results.blg -Counter '\Memory\Available Bytes'

Start-Process -FilePath C:\Demo\Results.blg

Import-Counter -Path C:\Demo\Results.blg -ListSet * | Select-Object -ExpandProperty PathsWithInstances -OutVariable Counters
Get-Counter -Counter $Counters



Import-Counter -Path C:\Demo\Results.blg -Summary

Get-ChildItem -Path C:\Demo\*.blg | Import-Counter

