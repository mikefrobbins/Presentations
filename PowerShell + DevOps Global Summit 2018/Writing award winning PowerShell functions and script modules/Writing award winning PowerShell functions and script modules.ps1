#region Presentation Info
    
<#
    Writing award winning PowerShell functions and script modules
    Presentation from the PowerShell + DevOps Global Summit 2018
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins    
#>    

#endregion

#region Safety to prevent the entire script from being run instead of a selection

throw "You're not supposed to run the entire script"

<#
    The code in this region was stolen, I mean borrowed from Thomas Rayner (@MrThomasRayner).
    For more information, see:
    http://mikefrobbins.com/2017/11/02/safety-to-prevent-entire-script-from-running-in-the-powershell-ise/
#>

#endregion

#region Presentation Prep

#Set PowerShell ISE Zoom to 175%
$psISE.Options.Zoom = 175

<#
    Presentation Tip: when using the #PowerShell console, modify the error color for better
    readability AND audience members with Color Blindness. - Michael Bender
    https://twitter.com/MichaelBender/status/983485482423078913
#>

#Set error messages to yellow
$host.PrivateData.ErrorForegroundColor = 'yellow'

#Set location
$Path = 'C:\Demo'
if (-not(Test-Path -Path $Path -PathType Container)) {
    New-Item -Path $Path -ItemType Directory | Out-Null
}
Set-Location -Path $Path

#Import my MrToolkit module (https://github.com/mikefrobbins/PowerShell)
Import-Module U:\GitHub\PowerShell\MrToolkit\MrToolkit.psd1

#Clear the screen
Clear-Host

Get-HotFix | Where-Object InstalledOn -gt (Get-Date).AddDays(-1)

#endregion

#region Demo Environment

<#
    A single workstation running Windows 10 version 1709 is used throughout this demo.
    It's running Windows PowerShell version 5.1 which ships in the box with that OS.
    
    PowerShell Core version 6.0.2 has also been installed as some differences are
    mentioned during this demo.

    One thing to keep in mind is that PowerShell Core is not an upgrade or replacement
    to Windows PowerShell. It installs side by side on Windows based systems.
#>

#endregion

#region Introduction

#*************************************
#        PowerPoint Slide 7
#*************************************

#endregion

#region Thought Process

#*************************************
#        PowerPoint Slide 8
#*************************************

#endregion

#region Create a Script or a Function?

#*************************************
#        PowerPoint Slide 9
#*************************************

#endregion

#region What is a Function?

#*************************************
#        PowerPoint Slide 10
#*************************************

#endregion

#region Function Naming

#*************************************
#        PowerPoint Slide 11
#*************************************

#Create a dynamic PowerShell module with an unapproved verb to show the warning.
New-Module -Name MyModule -ScriptBlock {

    function Return-MrOsVersion {
        Get-CimInstance -ClassName Win32_OperatingSystem |
        Select-Object -Property @{label='OperatingSystem';expression={$_.Caption}}
    }

    Export-ModuleMember -Function Return-MrOsVersion

} | Import-Module

<#
    List of Approved Verbs for Windows PowerShell Commands:
    https://msdn.microsoft.com/en-us/library/ms714428.aspx

    For the most up to date list, run Get-Verb from within PowerShell.
#>

Get-Verb | Sort-Object -Property Verb

<#
    In PowerShell Core, Get-Verb returns a different type of object, two additional
    properties, and a Group parameter that allows filtering by group. There are also
    two new verbs in PowerShell Core (Build and Deploy) that didn't previously exist
    in Windows PowerShell. Be sure to check PowerShell Core and Windows PowerShell
    if you want to ensure compatibility with both.
#>

#Example of a simple function.

function Get-Version {
    $PSVersionTable.PSVersion
}

Get-Version

<#
    There's a good chance of name collisions with functions named something like
    Get-Version. Prefix your noun to help prevent naming collisions.
#>

function Get-PSVersion {
    $PSVersionTable.PSVersion
}

Get-PSVersion

<#
    Even prefixing the noun with something like PS still has a good chance of having
    a name collision. I typically prefix my function nouns with my initials. Develop
    a standard and stick to it (Be consistent).
#>

function Get-MrPSVersion {
    $PSVersionTable.PSVersion
}

Get-MrPSVersion

#Once loaded into memory, you can see the functions on the Function PSDrive.

Get-ChildItem -Path Function:\Get-*Version

<#
    You could close and reopen PowerShell if you want to remove functions from your
    current session. A simpler alternative is to remove them from the Function PSDrive.
#>

Get-ChildItem -Path Function:\Get-*Version | Remove-Item

#Verify that they were indeed removed.

Get-ChildItem -Path Function:\Get-*Version

#If the functions were loaded as part of a module, simply unload the module to remove them.

Get-ChildItem -Path Function:\Return*
Remove-Module -Name MyModule
Get-ChildItem -Path Function:\Return*

<#
    If you make a change to a module, you can simply run Import-Module with the Force
    parameter for the changes to take effect without having to remove and reimport it.

    Strongly Encouraged Development Guidelines contains information about the guidelines
    you should follow when writing PowerShell cmdlets. These are also great guidelines
    to follow when writing functions since your goal should be to make them look and feel
    like native commands. Whatever you do, don't use the Azure cmdlets as your guideline.
    https://msdn.microsoft.com/en-us/library/dd878270.aspx
#>

#endregion

#region Dot-Sourcing functions

<#
    To avoid Scoping gotcha's, test your functions from the PowerShell console instead
    of just inside the ISE, VSCode, or other ISE/IDE's.
#>

#Creating and dot-sourcing a function
$psISE.CurrentPowerShellTab.Files.Add((New-Item -Path $Path\Get-MrComputerName.ps1 -ItemType File))

#Add code for the Get-MrPSVersion function to the ps1 file
Set-Content -Path "$Path\Get-MrComputerName.ps1" -Value @'
function Get-MrComputerName {
    $env:COMPUTERNAME
}
'@

#Demonstrate running the the script. Why doesn't anything happen?
.\Get-MrComputerName.ps1

#Try to call the function
Get-MrComputerName

#Check to see if the function exists on the Function PSDrive
Get-ChildItem -Path Function:\Get-MrComputerName

#The function needs to be dot-sourced to load it into the global scope
#The relative path can be used
. .\Get-MrComputerName.ps1

<#
#The fully qualified path can also be used
. C:\Demo\Get-MrComputerName.ps1

#The variable containing the path to the demo folder along with the filename can also be used
. $Path\Get-MrComputerName.ps1
#>

#Try to call the function again
Get-MrComputerName

#Show that the function exists on the Function PS Drive
Get-ChildItem -Path Function:\Get-MrComputerName

#Remove the function from the Function PSDrive
Get-ChildItem -Path Function:\Get-MrComputerName | Remove-Item

#Show that the function no longer exists on the Function PS Drive
Get-ChildItem -Path Function:\Get-MrComputerName

#endregion

#region Variables

#*************************************
#        PowerPoint Slide 13 & 14
#*************************************

#endregion

#region Parameter Naming

#*************************************
#        PowerPoint Slide 15
#*************************************

function Test-MrParameter {

    param (
        $ComputerName
    )

    Write-Output $ComputerName

}

Test-MrParameter -ComputerName Server01, Server02

<#
    Why did I use ComputerName instead of Computer, ServerName, or Host for my parameter
    name? Because I wanted my function standardized like the built-in cmdlets.
#>

function Get-MrParameterCount {
    param (
        [string[]]$ParameterName
    )

    foreach ($Parameter in $ParameterName) {
        $Results = Get-Command -ParameterName $Parameter -ErrorAction SilentlyContinue

        [pscustomobject]@{
            ParameterName   = $Parameter
            NumberOfCmdlets = $Results.Count
        }
    }
}

Get-MrParameterCount -ParameterName ComputerName, Computer, ServerName, Host, Machine
Get-MrParameterCount -ParameterName Path, FilePath

<#
    As you can see in the previous set of results, there are several built-in commands with
    a ComputerName parameter, but depending on what modules are loaded there are little to
    none with any of the other names that were tested.

    Now back to the Test-MrParameter function.
#>

function Test-MrParameter {

    param (
        $ComputerName
    )

    Write-Output $ComputerName

}

<#
    This function doesn't have any common parameters. The parameters of a command can be
    viewed with intellisense in the ISE (Integrated Scripting Environment), or VSCode
    (Visual Studio Code), or by using tabbed expansion to tab through the available parameters.
#>

Test-MrParameter -<tab>

<#
    There are also a couple of different ways to view all of the available parameters
    for a command using Get-Command.
#>

Get-Command -Name Test-MrParameter -Syntax
(Get-Command -Name Test-MrParameter).Parameters.Keys

<#
    To learn more about parameters see the about_Functions_Advanced_Parameters help topic.
    https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters
#>

#endregion

#region Advanced Functions

<#
    Turning a function into an advanced function sounds really complicated, but it's so
    simply that there's almost no reason not to turn all functions into advanced functions.
    Adding CmdletBinding turns a function into an advanced function.
#>

function Test-MrCmdletBinding {

    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param (
        $ComputerName
    )

    Write-Output $ComputerName

}

<#
    That simple declaration adds common parameters to the Test-MrCmdletBinding function
    shown in the previous example. CmdletBinding does require a param block, but the
    param block can be empty.

    There are now additional (common) parameters. As previously mentioned, the parameters
    can be seen using intellisense.
#>

Test-MrCmdletBinding -<tab>

#And a couple of different ways with Get-Command.

Get-Command -Name Test-MrCmdletBinding -Syntax
(Get-Command -Name Test-MrCmdletBinding).Parameters.Keys

<#
    Recommended Reading:
    about_Functions_CmdletBindingAttribute
    https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_cmdletbindingattribute

    about_CommonParameters
    https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_commonparameters

    about_Functions_Advanced
    https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced

    about_Functions_Advanced_Methods
    https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_methods
#>

#endregion

#region Preventing Resume Generating Events

<#
    If your function modifies anything at all, support for WhatIf and Confirm should
    be added to it. SupportsShouldProcess adds WhatIf & Confirm parameters.
    Keep in mind, this is only needed for commands that make changes.
#>

function Test-MrSupportsShouldProcess {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        $ComputerName
    )

    Write-Output $ComputerName

}

#As shown in the following example, there are now WhatIf & Confirm parameters.

Test-MrSupportsShouldProcess -<tab>

Get-Command -Name Test-MrSupportsShouldProcess -Syntax
(Get-Command -Name Test-MrSupportsShouldProcess).Parameters.Keys

<#
    If all the commands within your function support WhatIf and Confirm, there is
    nothing more to do, but if there are commands within your function that don't
    support these, additional logic is required.

    There's a free ebook on PowerShell Advanced Functions which can be downloaded
    from my blog that contains an excellent section (written by Jeff Hicks) if
    you're interested in learning more about SupportsShouldProcess.
    http://mikefrobbins.com/2015/04/17/free-ebook-on-powershell-advanced-functions/
#>

#endregion

#region Parameter Validation

<#
    Validate input early on. Why allow your code to continue on a path when it's
    not possible to complete successfully without valid input?
#>

#Type Constraints

#Always type the variables that are being used for your parameters (specify a datatype).

function Test-MrParameterValidation {

    [CmdletBinding()]
    param (
        [string]$ComputerName
    )

    Write-Output $ComputerName

}

Test-MrParameterValidation -ComputerName Server01
Test-MrParameterValidation -ComputerName Server01, Server02
Test-MrParameterValidation

<#
    As shown in the previous figure, Typing the ComputerName parameter as a string only
    allows one value to be specified for it. Specifying more than one value generates
    an error. The problem though, is this doesn't prevent someone from specifying a null
    or empty value for that parameter or omitting it altogether.

    For more information see "Use a Type Constraint in Windows PowerShell".
    https://technet.microsoft.com/en-us/magazine/ff642464.aspx
#>


#Mandatory Parameters

<#
    In order to make sure a value is specified for the ComputerName parameter,
    make it a mandatory parameter.
#>

function Test-MrParameterValidation {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$ComputerName
    )

    Write-Output $ComputerName

}

Test-MrParameterValidation

<#
    Now when the ComputerName parameter isn't specified, it prompts for a value.
    Notice that it only prompts for one value since the Type is a string. When the
    ComputerName parameter is specified without a value, with a null value, or with an
    empty string as its value, an error is generated.

    More than one value can be accepted by the ComputerName parameter by Typing it as
    an array of strings.
#>

function Test-MrParameterValidation {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string[]]$ComputerName
    )

    Write-Output $ComputerName

}

Test-MrParameterValidation

<#
    At least one value is required since the ComputerName parameter is mandatory. Now
    that it accepts an array of strings, it will continue to prompt for values when
    the ComputerName parameter is omitted until no value is provided, followed by
    pressing <enter>.
#>


#Default Values

#Default values can NOT be used with mandatory parameters.

function Test-MrParameterValidation {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string[]]$ComputerName = $env:COMPUTERNAME #<<-- This will not work with a mandatory parameter
    )

    Write-Output $ComputerName

}

Test-MrParameterValidation

<#
    Notice that the default value wasn't used in the previous example when the
    ComputerName parameter was omitted. Instead, it prompted for a value.

    To use a default value, specify the ValidateNotNullOrEmpty parameter validation
    attribute instead of making the parameter mandatory.
#>

function Test-MrParameterValidation {

    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName = $env:COMPUTERNAME
    )

    Write-Output $ComputerName

}

Test-MrParameterValidation
Test-MrParameterValidation -ComputerName Server01, Server02

<#
    Notice that $env:COMPUTERNAME was used as the default value instead of localhost
    or . which makes the command more dynamic and it's considered to be a best practice.
#>

#ValidatePattern

#ValidatePattern validates the input against a regular expression.

function Test-ValidatePattern {
    [CmdletBinding()]
    param (
        [ValidatePattern('^(?!^(PRN|AUX|CLOCK\$|NUL|CON|COM\d|LPT\d|\..*)(\..+)?$)[^\x00-\x1f\\?*:\"";|/]+$')]
        [string]$FileName
    )
    Write-Output $FileName
}

#If the value doesn’t match the regular expression, an error is generated.

Test-ValidatePattern -FileName '.con'

<#
    As you can see in the previous example, the error messages that ValidatePattern generates are
    cryptic unless you read regular expressions and since most people don’t, I typically avoid
    using it. The same type of input validation can be performed using ValidateScript  while
    providing the user of your function with a meaningful error message.
#>

#ValidateScript

#ValidateScript uses a script to validate the value:

function Test-ValidateScript {
    [CmdletBinding()]
    param (
        [ValidateScript({
            If ($_ -match '^(?!^(PRN|AUX|CLOCK\$|NUL|CON|COM\d|LPT\d|\..*)(\..+)?$)[^\x00-\x1f\\?*:\"";|/]+$') {
                $True
            }
            else {
                Throw "$_ is either not a valid filename or it is not recommended."
            }
        })]
        [string]$FileName
    )
    Write-Output $FileName
}

#Notice the meaningful error message.

Test-ValidateScript -FileName '.con'

#Enumerations

#The following example demonstrates using an enumeration to validate parameter input.

function Test-MrConsoleColorValidation {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [System.ConsoleColor[]]$Color = [System.Enum]::GetValues([System.ConsoleColor])
    )
    Write-Output $Color
}

Test-MrConsoleColorValidation -<tab>
Test-MrConsoleColorValidation
Test-MrConsoleColorValidation -Color Blue, DarkBlue
Test-MrConsoleColorValidation -Color Pink

<#
    Notice that a error is returned when an invalid value is provided that does not
    exist in the enumeration.

    I'm often asked the question "How do you find enumerations?" The following command
    can be used to find them.
#>

[AppDomain]::CurrentDomain.GetAssemblies().Where({-not($_.IsDynamic)}).ForEach({
$_.GetExportedTypes().Where({$_.IsPublic -and $_.IsEnum})})

<#
    A simplier may to find them is to download Get-Type from the TechNet script
    repository (written by Warren Frame).
    https://gallery.technet.microsoft.com/scriptcenter/Get-Type-Get-exported-fee19cf7
#>

Get-Type -BaseType System.Enum

#Valid values for the DayOfWeek enumeration.

[System.Enum]::GetValues([System.DayOfWeek])

#Type Accelerators

<#
    How much code have you seen written to validate IP addresses? Maybe it wasn't necessarily
    a lot of code, but something that took a lot of time such as formulating a complicated
    regular expression. Type accelerators to the rescue! They make the entire process of
    validating both IPv4 and IPv6 addresses simple.
#>

function Test-MrIPAddress {
    [CmdletBinding()]
    param (
        [ipaddress]$IPAddress
    )
    Write-Output $IPAddress
}

Test-MrIPAddress -IPAddress 10.1.1.255
Test-MrIPAddress -IPAddress 10.1.1.256
Test-MrIPAddress -IPAddress 2001:db8::ff00:42:8329
Test-MrIPAddress -IPAddress 2001:db8:::ff00:42:8329

psEdit -filenames U:\GitHub\PowerShell\MrToolkit\Test-MrIpAddress.ps1

#You might ask, how do I find Type Accelerators? With the following code.

[psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')::Get |
Sort-Object -Property Value

<#
    If you have the PowerShell Community Extensions module installed, you can
    also use the following. https://www.powershellgallery.com/packages/Pscx
#>

[accelerators]::get

#endregion

#region Multiple Parameter Sets

<#
    Sometimes you need to add more than one parameter set to a function you're creating.
    If that's not something you're familiar with, it can be a little confusing at first.
    In the following example, I want to either specify the Name or Module parameter,
    but not both at the same time. I also want the Path parameter to be available when
    using either of the parameter sets.
#>

function Test-MrMultiParamSet {
    [CmdletBinding(DefaultParameterSetName='Name')]
    param (
        [Parameter(Mandatory,
                   ParameterSetName='Name')]
        [string[]]$Name,

        [Parameter(Mandatory,
                   ParameterSetName='Module')]
        [string[]]$Module,

        [string]$Path
    )
    $PSCmdlet.ParameterSetName
}

<#
    Taking a look at the syntax shows the function shown in the previous example does
    indeed have two different parameter sets and the Path parameter exists in both of
    them. The only problem is both the Name and Module parameters are mandatory and it
    would be nice to have Name available positionally.
#>

Get-Command -Name Test-MrMultiParamSet -Syntax
Test-MrMultiParamSet -Name 'Testing Name Parameter Set' -Path C:\Demo\
Test-MrMultiParamSet -Module 'Testing Name Parameter Set' -Path C:\Demo\
Test-MrMultiParamSet 'Testing Name Parameter Set' -Path C:\Demo\

#Simply specifying Name as being in position zero solves that problem.

function Test-MrMultiParamSet {
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    param (
        [Parameter(Mandatory,
            ParameterSetName = 'Name',
            Position = 0)]
        [string[]]$Name,

        [Parameter(Mandatory,
            ParameterSetName = 'Module')]
        [string[]]$Module,

        [string]$Path
    )
    $PSCmdlet.ParameterSetName
}

<#
    Notice that “Name” is now enclosed in square brackets when viewing the syntax for
    the function. This means that it’s a positional parameter and specifying the parameter
    name is not required as long as its value is specified in the correct position. Keep
    in mind that you should always use full command and parameter names in any code that
    you share.
#>

Get-Command -Name Test-MrMultiParamSet -Syntax
Test-MrMultiParamSet 'Testing Name Parameter Set' -Path C:\Demo\

<#
    While continuing to work on the parameters for this function, I decided to make
    the Path parameter available positionally as well as adding pipeline input support
    for it. I’ve seen others add those requirements similar to what’s shown in the
    following example.
#>

function Test-MrMultiParamSet {
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    param (
        [Parameter(Mandatory,
            ParameterSetName = 'Name',
            Position = 0)]
        [string[]]$Name,

        [Parameter(Mandatory,
            ParameterSetName = 'Module')]
        [string[]]$Module,

        [Parameter(ParameterSetName = 'Name')]
        [Parameter(ParameterSetName = 'Module')]
        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName,
                   Position = 1)]
        [string]$Path        
    )
    $PSCmdlet.ParameterSetName
}

<#
    This might initially seem to work, but what appears to happen is that it ignores
    the Parameter blocks for both the Name and Module parameter set names for the Path
    parameter because they are effectively blank. This is because another totally
    separate parameter block is specified for the Path parameter. Looking at the help
    for the Path parameter shows that it accepts pipeline input, but looking at the
    individual parameter sets seems to suggest that it doesn’t. It’s confused to say
    the least.
#>

'C:\Demo' | Test-MrMultiParamSet Test01
help Test-MrMultiParamSet -Parameter Path
(Get-Command -Name Test-MrMultiParamSet).ParameterSets.Parameters.Where({$_.Name -eq 'Path'})

<#
    There’s honestly no reason to specify the individual parameter sets for the Path
    parameter if all of the options are going to be the same for all of the parameter
    sets.
#>

function Test-MrMultiParamSet {
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    param (
        [Parameter(Mandatory,
            ParameterSetName = 'Name',
            Position = 0)]
        [string[]]$Name,

        [Parameter(Mandatory,
            ParameterSetName = 'Module')]
        [string[]]$Module,

        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName,
                   Position = 1)]
        [string]$Path        
    )
    $PSCmdlet.ParameterSetName
}

<#
    Removing those two empty parameter declarations above the Path parameter that reference
    the individual parameter sets clears up the problems.
#>

'C:\Demo' | Test-MrMultiParamSet Test01
help Test-MrMultiParamSet -Parameter Path
(Get-Command -Name Test-MrMultiParamSet).ParameterSets.Parameters.Where({$_.Name -eq 'Path'})

<#
    If you want to specify different options for the Path parameter to be used in different
    parameter sets, then you would need to explicitly specify those options as shown in the
    following example. To demonstrate this, I’ve omitted pipeline input by property name when
    the Module parameter set is used.
#>

function Test-MrMultiParamSet {
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    param (
        [Parameter(Mandatory,
            ParameterSetName = 'Name',
            Position = 0)]
        [string[]]$Name,

        [Parameter(Mandatory,
            ParameterSetName = 'Module')]
        [string[]]$Module,

        [Parameter(ParameterSetName = 'Name',
                   Mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName,
                   Position = 1)]
        [Parameter(ParameterSetName = 'Module',
                   Mandatory,
                   ValueFromPipeline,
                   Position = 1)]
        [string]$Path        
    )
    $PSCmdlet.ParameterSetName
}

#Now everything looks correct.

'C:\Demo' | Test-MrMultiParamSet Test01
help Test-MrMultiParamSet -Parameter Path
(Get-Command -Name Test-MrMultiParamSet).ParameterSets.Parameters.Where({$_.Name -eq 'Path'})

<#
    For more information about using multiple parameter sets in your functions, see the
    about_Functions_Advanced_Parameters help topic.
    https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters
#>

#endregion

#region Return Keyword

<#
    The return keyword is probably the most over used keyword in PowerShell that’s used in
    unnecessary scenarios. You’ll often find it used to simply return the output of a function.
#>

function New-MrGuid {
    $Guid = [System.Guid]::NewGuid()
    Return $Guid
}

New-MrGuid

<#
    In that scenario, using the return keyword is totally unnecessary. If you do want to
    return the value of the variable, simply let PowerShell take care of returning the output.
#>

function New-MrGuid {
    $Guid = [System.Guid]::NewGuid()
    $Guid
}

New-MrGuid

<#
    Although I didn’t specify it in the previous example, I typically use Write-Output
    instead of just specifying the variable itself.
#>

function New-MrGuid {
    $Guid = [System.Guid]::NewGuid()
    Write-Output $Guid
}

New-MrGuid

<#
    In the previous example, there’s no reason to store the value in a variable, simply
    create the new GUID and let PowerShell handle returning the output all in one command.
#>

function New-MrGuid {
    [System.Guid]::NewGuid()
}

New-MrGuid

<#
    The return keyword does have a couple of valid use cases though. The following
    function does not use the return keyword.
#>

function Test-Return {
    [CmdletBinding()]
    param (
        [int[]]$Number
    )
    foreach ($N in $Number) {
        if ($N -ge 4) {
            $N
        }
    }
}

#Without the return keyword any number greater than or equal to four is returned.

Test-Return -Number 3, 5, 7, 9

#Notice that the return keyword has been added to the function without any other changes.

function Test-Return {
    [CmdletBinding()]
    param (
        [int[]]$Number
    )
    foreach ($N in $Number) {
        if ($N -ge 4) {
            Return $N
        }
    }
}

<#
    With the return keyword, the first value that is greater than or equal to 4 will be
    returned and then the foreach loop will exit without testing the numbers 7 or 9.
#>

Test-Return -Number 3, 5, 7, 9

<#
    Not only does it exit the foreach loop, but the entire function so if additional code
    existed after the foreach loop, it wouldn’t be executed either. A slightly modified
    version of the previous function will be used to demonstrate this.
#>

#For the first test, the return keyword is omitted.

function Test-Return {
    [CmdletBinding()]
    param (
        [int[]]$Number
    )
    $i = 0
    foreach ($N in $Number) {
        if ($N -ge 4) {
            $i++
            $N
        }
    }
    Write-Verbose -Message "A total of $i items were returned."
}

<#
    The verbose output after the foreach loop is included in the output when specifying
    the verbose parameter.
#>

Test-Return -Number (1..10) -Verbose

#The return keyword has been added to the following function.

function Test-Return {
    [CmdletBinding()]
    param (
        [int[]]$Number
    )
    $i = 0
    foreach ($N in $Number) {
        if ($N -ge 4) {
            $i++
            Return $N
        }
    }
    Write-Verbose -Message "A total of $i items were returned."
}

Test-Return -Number (1..10) -Verbose

<#
    Notice that although the verbose parameter was specified, the verbose output is not included
    because the return keyword causes the function to exit before it gets to that point.

    Of course, if the portion of the code with the return keyword isn’t run, the verbose
    output will be included in the output when the verbose parameter is specified.
#>

Test-Return -Number (1..3) -Verbose

<#
    Classes - The return keyword is required when using them (this is the other use case).

    For more information about the return keyword, see the about_Return help topic.
    https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_return
#>

#endregion

#region Verbose Output

<#
    Inline comments should be used sparingly because no one other than someone digging
    through the code itself will ever see them as shown in the following example.
#>

function Test-MrVerboseOutput {

    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName = $env:COMPUTERNAME
    )

    foreach ($Computer in $ComputerName) {
        #Attempting to perform some action on $Computer
        #Don't use inline comments like this, use write verbose instead.
        Write-Output $Computer
    }

}

Test-MrVerboseOutput -ComputerName Server01, Server02 -Verbose

#A better option is to use Write-Verbose instead of writing inline comments.

function Test-MrVerboseOutput {

    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName = $env:COMPUTERNAME
    )

    foreach ($Computer in $ComputerName) {
        Write-Verbose -Message "Attempting to perform some action on $Computer"
        Write-Output $Computer
    }

}

Test-MrVerboseOutput -ComputerName Server01, Server02
Test-MrVerboseOutput -ComputerName Server01, Server02 -Verbose

<#
    As shown in the previous figure, when the Verbose parameter isn't specified, the
    comment isn't in the output and when it is specified, the comment is displayed.

    To learn more, see the Write-Verbose help topic
    https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/write-verbose
#>

#endregion

#region Pipeline Input

#By Value

#Pipeline input by value is what I call by type.

function Test-MrPipelineInput {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [string[]]$ComputerName
    )

    PROCESS {   
        Write-Output $ComputerName    
    }

}

'Server01', 'Server02' | Test-MrPipelineInput
'Server01', 'Server02' | Get-Member

<#
    As shown in the previous example, when Pipeline input by value is used, the Type
    that is specified for the parameter can be piped in.

    When a different type of object is piped in, it doesn't work successfully though
    as shown in the following example.
#>

$Object = New-Object -TypeName PSObject -Property @{'ComputerName' = 'Server01', 'Server02'}
$Object | Get-Member
$Object | Test-MrPipelineInput


#Pipeline Input by Property Name

<#
    Pipeline input by property name is a little more straight forward as it looks for
    input that matches the actual property name such as ComputerName in the following
    example.
#>

function Test-MrPipelineInput {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName)]
        [string[]]$ComputerName
    )

    PROCESS {   
        Write-Output $ComputerName    
    }

}

'Server01', 'Server02' | Test-MrPipelineInput


$Object | Test-MrPipelineInput


#Pipeline Input by Value and by Property Name

<#
    Both By Value and By Property Name can both be added to the same parameter.
    In this scenario, By Value is always attempted first and By Property Name
    will only ever be attempted if By Value doesn't work.
#>

function Test-MrPipelineInput {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        [string[]]$ComputerName
    )

    PROCESS {  
        Write-Output $ComputerName
    }

}

'Server01', 'Server02' | Test-MrPipelineInput
$Object | Test-MrPipelineInput

#### Important Considerations when using Pipeline Input

#The begin block does not have access to the items that are piped to a command.

function Test-MrPipelineInput {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [string[]]$ComputerName
    )

    BEGIN {
        Write-Output "Test $ComputerName"
    }

}

'Server01', 'Server02' | Test-MrPipelineInput
$Object | Test-MrPipelineInput

<#
    Notice that the actual computer name does not follow word Test in the output shown
    in the previous figure.
#>

#endregion

#region Error Handling

<#
    Use try / catch where you think an error may occur. Only terminating errors are
    caught. Turn a non-terminating error into a terminating one. Don't change
    $ErrorActionPreference unless absolutely necessary and change it back if you do.
    Use -ErrorAction on a per command basis instead.

    In the following example, an unhandled exception is generated when a computer
    cannot be contacted.
#>

function Test-MrErrorHandling {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        [string[]]$ComputerName
    )

    PROCESS {
        foreach ($Computer in $ComputerName) {
            Test-WSMan -ComputerName $Computer
        }
    }

}

Test-MrErrorHandling -ComputerName DoesNotExist

<#
    Simply adding a try/catch block still causes an unhandled exception to occur
    because the command doesn't generate a terminating error.
#>

function Test-MrErrorHandling {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        [string[]]$ComputerName
    )

    PROCESS {
        foreach ($Computer in $ComputerName) {
            try {
                Test-WSMan -ComputerName $Computer
            }
            catch {
                Write-Warning -Message "Unable to connect to Computer: $Computer"
            }
        }
    }

}

Test-MrErrorHandling -ComputerName DoesNotExist

<#
    Specify the ErrorAction parameter with Stop as the value turns a non-terminating
    error into a terminating one. Don't modify the global $ErrorActionPreference variable.
    If you do change it such as in a scenario when you're using a non-PowerShell command
    that doesn't support ErrorAction on the command itself, change it back immediately
    after that command.
#>

function Test-MrErrorHandling {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        [string[]]$ComputerName
    )

    PROCESS {
        foreach ($Computer in $ComputerName) {
            try {
                Test-WSMan -ComputerName $Computer -ErrorAction Stop
            }
            catch {
                Write-Warning -Message "Unable to connect to Computer: $Computer"
            }
        }
    }

}

Test-MrErrorHandling -ComputerName DoesNotExist

<#
    For more information, see the about_Try_Catch_Finally help topic.
    https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_try_catch_finally
#>

#endregion

#region Comment Based Help is Dead, Long live Comment Based Help

#The following example demonstrates how to add comment based help to your functions.

function Get-MrAutoStoppedService {

    <#
.SYNOPSIS
    Returns a list of services that are set to start automatically, are not
    currently running, excluding the services that are set to delayed start.

.DESCRIPTION
    Get-MrAutoStoppedService is a function that returns a list of services from
    the specified remote computer(s) that are set to start automatically, are not
    currently running, and it excludes the services that are set to start automatically
    with a delayed startup.

.PARAMETER ComputerName
    The remote computer(s) to check the status of the services on.

.PARAMETER Credential
    Specifies a user account that has permission to perform this action. The default
    is the current user.

.EXAMPLE
     Get-MrAutoStoppedService -ComputerName 'Server1', 'Server2'

.EXAMPLE
     'Server1', 'Server2' | Get-MrAutoStoppedService

.EXAMPLE
     Get-MrAutoStoppedService -ComputerName 'Server1', 'Server2' -Credential (Get-Credential)

.INPUTS
    String

.OUTPUTS
    PSCustomObject

.NOTES
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins
#>

    [CmdletBinding()]
    param (

    )

    #Function Body

}

<#
    This provides the users of your function with a consistent help experience with
    your functions that's just like using the default built-in cmdlets.
#>

help Get-MrAutoStoppedService -Full

<#
    You don't have to memorize all of this. Use Cntl + J for Snipets in the PowerShell ISE.

    For more information see the about_Comment_Based_Help help topic.
    https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help
#>

#endregion

#region MAML Based Help

<#
    MAML (Microsoft Assistance Markup Language) based help is another more professional
    type of help that can be written for your functions instead of comment based help.
    Writing MAML has previously been very difficult, but a new open source project named
    platyPS (pronounced Platypus) seems to make it much simpler. It's also makes converting
    your existing comment based help to MAML very easy.
    https://github.com/PowerShell/platyPS

    Installed it from the PowerShell Gallery if you're interested in giving it a try.
#>

Install-Module -Name platyPS -Force

<#
    There are really two reasons to use MAML based help instead of comment based help.
    One is to provide updatable help and the other is to be able to provide help in
    multiple languages.

    I've spoken to other MVP's about using MAML based help. Many said they don't create
    help in multiple languages and that they would publish an update to their module to
    update the help if necessary.

    I think MAML based help is something worth looking into and if you're a company who
    is creating modules for products that you're selling, then you should definitely be
    using it.

    If you're interested in learning more about MAML, consider attending the following
    session.

    PlatyPS: PowerShell Help meets Markdown - Wednesday, April 11th at 9am
    https://powershelldevopsglobalsummit2018.sched.com/event/CnMg/platyps-powershell-help-meets-markdown
#>

#endregion

#region Monolithic Script Module

<#
    A script module in PowerShell is simply a file containing one or more
    functions that's saved as a PSM1 file instead of a PS1 file.

    How do you create a script module file? Not with the New-Module cmdlet.
#>

help New-Module

#Create a directory for the script module
New-Item -Path $Path -Name MyModule -ItemType Directory

#Create the script module (PSM1 file)
New-Item -Path "$Path\MyModule" -Name MyModule.psm1 -ItemType File

#Add the two previously used functions to our script module
Set-Content -Path "$Path\MyModule\MyModule.psm1" -Encoding UTF8 -Value @'
function Get-MrPSVersion {
    $PSVersionTable
}

function Get-MrComputerName {
    $env:COMPUTERNAME
}
'@

#Open the new script module file in the ISE
psEdit -filenames $Path\MyModule\MyModule.psm1

#Try to call one of the functions
Get-MrComputerName

<#
    In order to take advantage of module autoloading, a script module needs
    to be saved in a folder with the same base name as the PSM1
    file and in a location specified in $env:PSModulePath.

    Show where the module currently resides at.
#>
explorer.exe $Path\MyModule

#Show the PSModulePath on my computer
$env:PSModulePath -split ';'

#Show the default locations that exist in the PSModulePath
($env:PSModulePath -split ';').Where({$_ -like '*WindowsPowerShell*'})

#Current user path
($env:PSModulePath -split ';').Where({$_ -like "*WindowsPowerShell*"})[0]

#All user path (added in PowerShell verison 4.0)
($env:PSModulePath -split ';').Where({$_ -like "*WindowsPowerShell*"})[1]

<#No user modules should be placed in the Windows\System32 path.
Only Microsot should place modules there.
#>
($env:PSModulePath -split ';').Where({$_ -like "*WindowsPowerShell*"})[2]

<#If the PSModuleAutoLoadingPreference has been changed from the default,
it can impact module autoloading.
#>
$PSModuleAutoloadingPreference

help about_Preference_Variables
<##
$PSModuleAutoloadingPreference
------------------------------
      Enables and disables automatic importing of modules in the session. 
      "All" is the default. Regardless of the value of this variable, you
      can use the Import-Module cmdlet to import a module.

      Valid values are:

        All    Modules are imported automatically on first-use. To import a
               module, get (Get-Command) or use any command in the module. 

        ModuleQualified
               Modules are imported automatically only when a user uses the
               module-qualified name of a command in the module. For example,
               if the user types "MyModule\MyCommand", Windows PowerShell
               imports the MyModule module.

        None   Automatic importing of modules is disabled in the session. To
               import a module, use the Import-Module cmdlet.       

      For more information about automatic importing of modules, see about_Modules
      (http://go.microsoft.com/fwlink/?LinkID=144311).
##>

#******************************************************************
#Close out of all open script and/or module files
#******************************************************************

#Move our newly created module to a location that exist in $env:PSModulePath
Move-Item -Path $Path\MyModule -Destination $env:ProgramFiles\WindowsPowerShell\Modules

#Try to call one of the functions
Get-MrComputerName

#endregion

#region Module Manifests

<#
    All script modules should have a module manifest which is a PSD1 file that
    contains meta data about the module itself. New-ModuleManifest is used to
    create a module manifest. Path is the only value that's required. However,
    the module won't work if root module is not specified. It's a good idea to
    specify Author and Description because they are required if you decide to
    upload your module to a Nuget repository with PowerShellGet.

    The version of a module without a manifest is 0.0 (This is a dead givaway
    that the module doesn't have a manifest).
#>
Get-Module -Name MyModule

<#
    The module manifest can be initially created with all this information
    instead of updating it. You don't really want to recreate the manifest once
    it's created because the GUID will change
#>

$ManifestParams = @{
    Path = "$env:ProgramFiles\WindowsPowerShell\Modules\MyModule\MyModule.psd1"
    RootModule = 'MyModule'
    Author = 'Mike F Robbins'
    Description = 'MyModule'
    CompanyName = 'mikefrobbins.com'

}

New-ModuleManifest @ManifestParams

#Check to see if any commands are exported
Import-Module -Name MyModule -Force
Get-Command -Module MyModule
Get-Module -Name MyModule

#How to Create PowerShell Script Modules and Module Manifests
#http://mikefrobbins.com/2013/07/04/how-to-create-powershell-script-modules-and-module-manifests/

#endregion

#region Line Continuation

<#
    Back tick for line continuation versus splatting

    Notice in the previous section that what's called splatting was used to creat the
    module manifest otherwise the command would have been really long. Some people
    prefer to use the backtick or grave accent character to break up long lines of code.
#>

New-ModuleManifest -Path "$env:ProgramFiles\WindowsPowerShell\Modules\MyModule\MyModule.psd1" `
                   -RootModule MyModule `
                   -Author 'Mike F Robbins' `
                   -Description MyModule `
                   -CompanyName mikefrobbins.com

<#
    I avoid using the backtick character for line continuation.

    To learn more about splatting, see the following help topic.
    https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_splatting
#>

#endregion

#region Plaster & Non-Monolithic Script Module Design

<#
    I have a function in my MrToolkit module named New-MrScriptModule that creates the
    scaffolding for a new PowerShell script module. It creates a PSM1 file and a module
    manifest (PSD1 file) along with the folder structure for a script module. To reduce
    the learning curve of Plaster as much as possible, I’m simply going to replace that
    existing functionality with Plaster in this section.
    http://mikefrobbins.com/2016/06/30/powershell-function-for-creating-a-script-module-template/

    For those of you who aren’t familiar with Plaster, per their GitHub readme, “Plaster
    is a template-based file and project generator written in PowerShell. Its purpose is
    to streamline the creation of PowerShell module projects, Pester tests, DSC configurations,
    and more. File generation is performed using crafted templates which allow the user
    to fill in details and choose from options to get their desired output.”
    https://github.com/PowerShell/Plaster/blob/master/README.md

    First, start out by installing the Plaster module.
#>

Install-Module -Name Plaster -Force

<#
    Create the initial Plaster template along with the metadata section which contains
    data about the manifest itself.
#>

$manifestProperties = @{
    Path         = "$Path\PlasterTemplate\PlasterManifest.xml"
    TemplateName = 'ScriptModuleTemplate'
    TemplateType = 'Project'
    Author       = 'Mike F Robbins'
    Description  = 'Scaffolds the files required for a PowerShell script module'
    Tags         = 'PowerShell, Module, ModuleManifest'
}

$Folder = Split-Path -Path $manifestProperties.Path -Parent
if (-not(Test-Path -Path $Folder -PathType Container)) {
    New-Item -Path $Folder -ItemType Directory | Out-Null
}

New-PlasterManifest @manifestProperties

#That creates an XML file that looks like the one in the following example.
psEdit -filenames $Path\PlasterTemplate\PlasterManifest.xml

#Create a standard PSM1 file in the Plaster template folder that will be used for all newly created modules. 

New-Item -Path "$Path\PlasterTemplate" -Name Module.psm1 |
Set-Content -Encoding UTF8 -Value @'
#Dot source all functions in all ps1 files located in the module folder
Get-ChildItem -Path $PSScriptRoot\*.ps1 -Exclude *.tests.ps1, *profile.ps1 |
ForEach-Object {
    . $_.FullName
}
'@

psEdit -filenames $Path\PlasterTemplate\Module.psm1

<#
    Complete the Plaster template by adding parameter and content sections as shown
    below. The parameters section is for adding values that may be different each
    time a new PowerShell script module is created.
#>

Set-Content -Path $Path\PlasterTemplate\PlasterManifest.xml -Value @'
<?xml version="1.0" encoding="utf-8"?>
<plasterManifest schemaVersion="1.1" templateType="Project"
  xmlns="http://www.microsoft.com/schemas/PowerShell/Plaster/v1">
  <metadata>
    <name>ScriptModuleTemplate</name>
    <id>ee4fdc83-1b9a-47ae-b4e6-336053283a86</id>
    <version>1.0.0</version>
    <title>ScriptModuleTemplate</title>
    <description>Scaffolds the files required for a PowerShell script module</description>
    <author>Mike F Robbins</author>
    <tags>PowerShell, Module, ModuleManifest</tags>
  </metadata>
  <parameters>
    <parameter name='Name' type='text' prompt='Name of the module' />
    <parameter name='Description' type='text' prompt='Brief description of module (required for publishing to the PowerShell Gallery)' />
    <parameter name='Version' type='text' default='0.1.0' prompt='Enter the version number of the module' />
    <parameter name='Author' type='user-fullname' prompt="Module author's name" store='text' />
    <parameter name='CompanyName' type='text' prompt='Name of your Company' default='mikefrobbins.com' />
    <parameter name='PowerShellVersion' default='3.0' type='text' prompt='Minimum PowerShell version' />
  </parameters>
  <content>
    <message>
    Creating folder structure
    </message>
    <file source='' destination='${PLASTER_PARAM_Name}'/>
    <message>
      Deploying common files
    </message>
    <file source='module.psm1' destination='${PLASTER_PARAM_Name}\${PLASTER_PARAM_Name}.psm1'/>
    <message>
      Creating Module Manifest
    </message>
    <newModuleManifest destination='${PLASTER_PARAM_Name}\${PLASTER_PARAM_Name}.psd1' moduleVersion='$PLASTER_PARAM_Version' rootModule='${PLASTER_PARAM_Name}.psm1' author='$PLASTER_PARAM_Author' companyName='$PLASTER_PARAM_CompanyName' description='$PLASTER_PARAM_Description' powerShellVersion='$PLASTER_PARAM_PowerShellVersion' encoding='UTF8-NoBOM'/>
  </content>
</plasterManifest>
'@

<#
    Now I’m all set to create a new PowerShell script module.

    A hash table is used to create the module without being prompted. The parameter
    names are TemplatePath, DestinationPath, and any parameters defined in the template.
    You must specify all of the parameters, even the ones that you’ve specified defaults
    for otherwise you’ll be prompted to either enter a value or confirm the default.

    The verbose parameter provides additional information which can be helpful in
    troubleshooting problems.
#>

$plasterParams = @{
    TemplatePath      = "$Path\PlasterTemplate"
    DestinationPath   = 'C:\Demo'
    Name              = 'MrTestModule'
    Description       = 'Mike Robbins Test Module'
    Version           = '0.9.0'
    Author            = 'Mike F Robbins'
    CompanyName       = 'mikefrobbins.com'
    PowerShellVersion = '3.0'
}
If (-not(Test-Path -Path $plasterParams.DestinationPath -PathType Container)) {
    New-Item -Path $plasterParams.DestinationPath -ItemType Directory | Out-Null
}
Invoke-Plaster @plasterParams -Verbose

explorer.exe $Path\PlasterTemplate

<#
    Sometimes learning new things can seem overwhelming based on examples you’ll
    find on the Internet. I’m not sure about others, but I’ve learned to keep it
    super simple to start with and add additional complexity one step at a time
    to reduce the learning curve. No one starts out as an expert at anything.

    This is only the tip of the iceberg for Plaster. Other recommended resources
    include the documentation and examples in the Plaster GitHub repository and
    the following blog articles.

    Using Plaster to create a PowerShell Script Module template
    http://mikefrobbins.com/2018/02/15/using-plaster-to-create-a-powershell-script-module-template/

    Levelling up your PowerShell modules with Plaster by Kieran Jacobsen
    https://poshsecurity.com/blog/levelling-up-your-powershell-modules-with-plaster

    Using Plaster To Create a New PowerShell Module by Rob Sewell
    https://sqldbawithabeard.com/2017/11/09/using-plaster-to-create-a-new-powershell-module/

    PowerShell: Adventures in Plaster by Kevin Marquette
    https://kevinmarquette.github.io/2017-05-12-Powershell-Plaster-adventures-in/

    Working with Plaster by David Christian
    http://overpoweredshell.com/Working-with-Plaster/

    There’s also a video on Working with Plaster that David Christian presented for
    one of our Mississippi PowerShell User Group meetings.
    http://mspsug.com/2017/06/20/video-working-with-plaster-a-powershell-scaffolding-module/

    The Plaster template shown in this example (and ongoing updates to it) can be
    downloaded from my PlasterTemplate repository on GitHub.
    https://github.com/mikefrobbins/PlasterTemplate

    If you're interested in learning more about Plaster, consider attending the
    following session.

    Creating PowerShell Projects and more with Plaster - Wednesday, April 12th at 3pm
    https://powershelldevopsglobalsummit2018.sched.com/event/CrVY/creating-powershell-projects-and-more-with-plaster
#>

#endregion

#region PSScriptAnalyzer

<#
    Are you interested in learning if your PowerShell code follows what the
    community considers to be best practices? Well, you’re in luck because
    Microsoft has a open source PowerShell module named PSScriptAnalyzer
    that does just that. According to the GitHub page for PSScriptAnalyzer,
    it’s a static code checker for PowerShell modules and scripts that checks
    the quality of PowerShell code by running a set of rules that are based
    on best practices identified by the PowerShell team and community. In
    addition to testing your code with the PSScriptAnalyzer built in rules,
    you can also create your own custom rules if your organization has specific
    guidelines for writing PowerShell code.

    Installing the PSScriptAnalyzer module is easy when installing it from the
    PowerShell gallery.
#>

Install-Module -Name PSScriptAnalyzer -Force

<#
    Use Script Analyzer to test my newly created MrTestModule module to determine
    if I’ve missed following any of the best practices.
#>

Invoke-ScriptAnalyzer -Path "$Path\MrTestModule"

<#
    It’s very easy to over look things so I’m glad to see something like
    PSScriptAnalyzer that I can use to validate that my PowerShell code meets the
    industry standards for best practices before sharing it online.

    PSScriptAnalyzer https://github.com/PowerShell/PSScriptAnalyzer

    If you're interested in learning more about PSScriptAnalyzer, consider
    attending the following session.

    A Crash Course in Writing Your Own PSScriptAnalyzer Rules - Thursday, April 12th at 10am
    https://powershelldevopsglobalsummit2018.sched.com/event/Cqi6/a-crash-course-in-writing-your-own-psscriptanalyzer-rules
#>

#endregion

#region Format Data

#Create a function in a PS1 file named Get-MrSystemInfo

New-Item -Path "$Path\MrTestModule" -Name Get-MrSystemInfo.ps1 -ItemType File -Force |
Set-Content -Encoding UTF8 -Value @'
function Get-MrSystemInfo {
    [CmdletBinding()]
    param ()

    $OSInfo = Get-CimInstance -ClassName Win32_OperatingSystem
    $LogicalDisk = Get-CimInstance -ClassName Win32_LogicalDisk

    foreach ($OS in $OSInfo) {
    
        foreach ($Disk in $LogicalDisk) {

            [pscustomobject]@{
                OSName = $OS.Caption
                OSVersion = $OS.Version
                AvailableRAM = $OS.FreePhysicalMemory
                Drive = $Disk.DeviceID
                Size = $Disk.Size
                FreeSpace = $Disk.FreeSpace
            }
    
        }
    
    }

}
'@

#Open the new script module file in the ISE
psEdit -filenames "$Path\MrTestModule\Get-MrSystemInfo.ps1"

Test-MrFunctionsToExport -ManifestPath $Path\MrTestModule\MrTestModule.psd1
Get-MrFunctionsToExport -Path $Path\MrTestModule

#Add this newly created function to the list of functions to export in the manifest
Update-ModuleManifest -Path "$Path\MrTestModule\MrTestModule.psd1" -FunctionsToExport Get-MrSystemInfo

Test-MrFunctionsToExport -ManifestPath $Path\MrTestModule\MrTestModule.psd1

#Import the module
Import-Module "$Path\MrTestModule\MrTestModule.psd1"

#Show the output
Get-MrSystemInfo

#Add the Type information to the customobject
Set-Content -Path "$Path\MrTestModule\Get-MrSystemInfo.ps1" -Value @'
function Get-MrSystemInfo {
    [CmdletBinding()]
    param ()

    $OSInfo = Get-CimInstance -ClassName Win32_OperatingSystem
    $LogicalDisk = Get-CimInstance -ClassName Win32_LogicalDisk

    foreach ($OS in $OSInfo) {
    
        foreach ($Disk in $LogicalDisk) {

            [pscustomobject]@{
                OSName = $OS.Caption
                OSVersion = $OS.Version
                AvailableRAM = $OS.FreePhysicalMemory
                Drive = $Disk.DeviceID
                Size = $Disk.Size
                FreeSpace = $Disk.FreeSpace
                PSTypeName = 'Mr.SystemInfo'
            }
    
        }
    
    }

}
'@

#Create a format.ps1xml file

New-Item -Path "$Path\MrTestModule" -Name MrTestModule.format.ps1xml -ItemType File -Force |
Set-Content -Encoding UTF8 -Value @'
<?xml version="1.0" encoding="utf-8" ?>
<Configuration>
    <ViewDefinitions>
        <View>
            <Name>Mr.SystemInfo</Name>
            <ViewSelectedBy>
                <TypeName>Mr.SystemInfo</TypeName>
            </ViewSelectedBy>
            <TableControl>
                <TableRowEntries>
                    <TableRowEntry>
                        <TableColumnItems>
                            <TableColumnItem>
                                <PropertyName>OSName</PropertyName>
                            </TableColumnItem>
                            <TableColumnItem>
                                <PropertyName>OSVersion</PropertyName>
                            </TableColumnItem>
                            <TableColumnItem>
                                <PropertyName>AvailableRAM</PropertyName>
                            </TableColumnItem>
                            <TableColumnItem>
                                <PropertyName>Drive</PropertyName>
                            </TableColumnItem>
                            <TableColumnItem>
                                <PropertyName>Size</PropertyName>
                            </TableColumnItem>
                            <TableColumnItem>
                                <PropertyName>FreeSpace</PropertyName>
                            </TableColumnItem>
                        </TableColumnItems>
                    </TableRowEntry>
                 </TableRowEntries>
            </TableControl>
        </View>
    </ViewDefinitions>
</Configuration>
'@

#Add the format file to the module manifest
Update-ModuleManifest -Path "$Path\MrTestModule\MrTestModule.psd1" -FormatsToProcess MrTestModule.format.ps1xml

#Reimport the module
Import-Module "$Path\MrTestModule\MrTestModule.psd1" -Force

#Show the output
Get-MrSystemInfo

#Format.ps1xml https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_format.ps1xml

#endregion

#region Extended Type Data

#Create a types.ps1xml file

New-Item -Path "$Path\MrTestModule" -Name MrTestModule.types.ps1xml -ItemType File -Force |
Set-Content -Encoding UTF8 -Value @'
<Types>
    <Type>
      <Name>Mr.SystemInfo</Name>
      <Members>
        <MemberSet>
          <Name>PSStandardMembers</Name>
          <Members>
            <PropertySet>
              <Name>DefaultDisplayPropertySet</Name>
              <ReferencedProperties>
                <Name>OSName</Name>
                <Name>OSVersion</Name>
                <Name>AvailableRAM(GB)</Name>
                <Name>Drive</Name>
                <Name>Size(GB)</Name>
                <Name>FreeSpace(GB)</Name>
              </ReferencedProperties>
            </PropertySet>
          </Members>
        </MemberSet>
      </Members>
    </Type>
    <Type>
      <Name>Mr.SystemInfo</Name>
      <Members>
        <ScriptProperty>
          <Name>AvailableRAM(GB)</Name>
          <GetScriptBlock>
            "{0:N2}" -f ($this.AvailableRAM / 1MB)
          </GetScriptBlock>
        </ScriptProperty>
      </Members>
    </Type>
    <Type>
      <Name>Mr.SystemInfo</Name>
      <Members>
        <ScriptProperty>
          <Name>Size(GB)</Name>
          <GetScriptBlock>
            "{0:N2}" -f ($this.Size / 1GB)
          </GetScriptBlock>
        </ScriptProperty>
      </Members>
    </Type>
    <Type>
      <Name>Mr.SystemInfo</Name>
      <Members>
        <ScriptProperty>
          <Name>FreeSpace(GB)</Name>
          <GetScriptBlock>
            "{0:N2}" -f ($this.FreeSpace / 1GB)
          </GetScriptBlock>
        </ScriptProperty>
      </Members>
    </Type>
</Types>
'@

#Update the format.ps1xml file to reflect the new calculated properties

New-Item -Path "$Path\MrTestModule" -Name MrTestModule.format.ps1xml -ItemType File -Force |
Set-Content -Encoding UTF8 -Value @'
<?xml version="1.0" encoding="utf-8" ?>
<Configuration>
    <ViewDefinitions>
        <View>
            <Name>Mr.SystemInfo</Name>
            <ViewSelectedBy>
                <TypeName>Mr.SystemInfo</TypeName>
            </ViewSelectedBy>
            <TableControl>
                <TableRowEntries>
                    <TableRowEntry>
                        <TableColumnItems>
                            <TableColumnItem>
                                <PropertyName>OSName</PropertyName>
                            </TableColumnItem>
                            <TableColumnItem>
                                <PropertyName>OSVersion</PropertyName>
                            </TableColumnItem>
                            <TableColumnItem>
                                <PropertyName>AvailableRAM(GB)</PropertyName>
                            </TableColumnItem>
                            <TableColumnItem>
                                <PropertyName>Drive</PropertyName>
                            </TableColumnItem>
                            <TableColumnItem>
                                <PropertyName>Size(GB)</PropertyName>
                            </TableColumnItem>
                            <TableColumnItem>
                                <PropertyName>FreeSpace(GB)</PropertyName>
                            </TableColumnItem>
                        </TableColumnItems>
                    </TableRowEntry>
                 </TableRowEntries>
            </TableControl>
        </View>
    </ViewDefinitions>
</Configuration>
'@

#Add the types file to the module manifest
Update-ModuleManifest -Path "$Path\MrTestModule\MrTestModule.psd1" -TypesToProcess MrTestModule.types.ps1xml

#Reimport the module
Import-Module "$Path\MrTestModule\MrTestModule.psd1" -Force

#Show the output
Get-MrSystemInfo

Get-MrSystemInfo | Select-Object -Property *
Get-MrSystemInfo | Get-Member

<#
    Extended Type Data
    https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_types.ps1xml
#>

#endregion

#region It works on my machine

<#
    Test your code using PowerShell.exe -NoProfile or Pwsh.exe -NoProfile

    Use a Requires statement to specify the minimum PowerShell version and
    the modules that are required by your function.
#>

#endregion

#region Source Control

#Git

#GitHub
#Readme
#License type

#endregion

#region Pester

#Install Pester
Install-Module -Name Pester -Force -SkipPublisherCheck -AllowClobber

#Create a simple Test-ToUpper function.
function Test-ToUpper {
    [CmdletBinding()]
    param (
        [string]$Text
    )
    $Text.ToUpper()
}

#Use-Culture from Lee Holmes' PowerShell Cookbook is used in the following example.
Install-Module -Name PowerShellCookbook

#Create a Pester test to not only test using my culture, but also with the Turkish culture.

Describe 'Test-ToUpper' {
    It 'Converts to Upper Case' {
        Test-ToUpper -Text 'SQLEngine' | Should BeExactly 'SQLENGINE'
    }
    It 'Converts to Upper Case using Turkish Culture' {
        Use-Culture -Culture tr-TR -ScriptBlock {
            Test-ToUpper -Text 'SQLEngine'
        } | Should BeExactly 'SQLENGINE'
    }
}

<#
    Using Pester to Test PowerShell Code with Other Cultures
    http://mikefrobbins.com/2015/10/22/using-pester-to-test-powershell-code-with-other-cultures/

    If you're interested in learning more about Pester, consider attending the following sessions.

    Pesterize Your Code!! - Wednesday, April 11th at 12pm
    https://powershelldevopsglobalsummit2018.sched.com/event/Cq9W/pesterize-your-code

    Beyond Pester 101: Applying testing principles to PowerShell - Wednesday, April 11th at 3pm
    https://powershelldevopsglobalsummit2018.sched.com/event/Cqc5/beyond-pester-101-applying-testing-principles-to-powershell
#>

#endregion

#region Other Best Practices

<#
    Don't hard code Format-* commands into your functions because it limits
    their functionality and their reusability.

    Semicolons at the end of lines.

    Write-Host

    Single quotes versus double quotes

    Coding style
    Indentation style
#>

#endregion

#region Bonus Content

#Is PowerShell case insensitive?

#The region keyword

<#
    While working with the xSQLServer DSC resource, I discovered that it wouldn’t work properly
    if a feature was specified in your DSC configuration in a case other than upper case. I
    determined this was due to the contains method being case sensitive.
#>

$Features = 'SQLENGINE', 'SSMS', 'ADV_SSMS'
$Features.Contains('SQLENGINE')
$Features.Contains('SQLEngine')

<#
    There are two ways to solve this problem. Either convert what the user enters to the same
    case specified in your code or use the contains keyword instead.
#>

$Features.Contains('SQLEngine'.ToUpper())
$Features -contains 'SQLEngine'

<#
    Case sensitivity isn’t exclusive to the contains method as most if not all of the methods
    that can be called are case sensitive as shown here where I’ll use the replace method.
#>

$Features.Replace('SQLEngine', 'SQL')
$Features.Replace('SQLENGINE', 'SQL')

#PowerShell functions to show
psEdit -filenames U:\GitHub\PowerShell\MrToolkit\Get-MrService.ps1
psEdit -filenames U:\GitHub\PowerShell\MrToolkit\Get-MrVmHost.ps1

#Mention Simon Wåhlin's code for putting a module back together and testing it
#https://github.com/SimonWahlin

#endregion

#region Additional Resources

<#
    The PowerShell Best Practices and Style Guide
    https://github.com/PoshCode/PowerShellPracticeAndStyle

    Walkthrough: An example of how I write PowerShell functions
    http://mikefrobbins.com/2015/06/19/walkthrough-an-example-of-how-i-write-powershell-functions/

    Free eBook on PowerShell Advanced Functions
    http://mikefrobbins.com/2015/04/17/free-ebook-on-powershell-advanced-functions/

    Free eBooks on PowerShell.org
    http://powershell.org/freebooks/
#>

#endregion

#region Cleanup

$Path = 'C:\Demo'
Remove-Module -Name MyModule, MrTestModule, MrToolkit -ErrorAction SilentlyContinue
Remove-Item -Path $env:ProgramFiles\WindowsPowerShell\Modules\MyModule -Recurse -Confirm:$false -ErrorAction SilentlyContinue
Get-ChildItem -Path $Path | Remove-Item -Recurse
Set-Location -Path C:\
$psISE.Options.Zoom = 100
$host.PrivateData.ErrorForegroundColor = 'red'

#endregion