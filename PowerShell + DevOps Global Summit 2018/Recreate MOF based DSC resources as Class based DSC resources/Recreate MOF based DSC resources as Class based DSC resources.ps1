#region Presentation Info

<#
    Recreate MOF based DSC resources as Class based DSC resources
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
    
    Always give credit when using other peoples code.
#>

#endregion

#region Presentation Prep

#Zoom in (Cntl+) in VSCode
#Or Set PowerShell ISE Zoom to 175%
$psISE.Options.Zoom = 175

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
The workstation used throughout this demo is running Windows 10 version 1709 and the servers
are running Windows Server 2016. They're all a member of the same Active Directory domain.
Each of them runs Windows PowerShell version 5.1 which ships in the box with all of those
operating systems.

Be aware that as of this writing, DSC (Desired State Configuration) does not currently work
with PowerShell Core 6.0 or higher on Windows systems. I haven't tried DSC on Linux or macOS
so I can't speak for those operating systems. To be more specific, the commands in the
PSDesiredStateConfiguration module do not work on Windows systems due to the current
implementation relying on WMI (Windows Management Instrumentation) which does not exist in
PowerShell Core. Currently, you must use Windows PowerShell version 4 or higher for MOF based
DSC resources and Windows PowerShell version 5.0 or higher for class based DSC resources.

There are several articles about PowerShell Core and the future direction of DSC on the
PowerShell Team blog if you're interested in learning more.
https://blogs.msdn.microsoft.com/powershell/

## Introduction

Back in September of 2014, I discovered that there was a logic problem with the xRemoteDesktopAdmin
DSC resource for configuring Remote Desktop that Microsoft had published on their TechNet Blog
https://blogs.technet.microsoft.com/privatecloud/2014/08/22/writing-a-custom-dsc-resource-for-remote-desktop-rdp-settings/
site and in their TechNet Script Repository https://gallery.technet.microsoft.com/xRemoteDesktopAdmin-dfc2f5a3.

The Set-TargetResource function compares a string to an integer on line 89 of the xRemoteDesktopAdmin.psm1 file.
The Ensure variable is a string that contains either "Present" or "Absent" and the GetEnsure variable is an
integer that contains either 0 or 1. This causes the code in the "If" block on line 89 that compares the two to
always run since they'll never be equal. To be fair, this code only runs if the Test-TargetResource function
returns false, but the conditional logic that they're using is useless due to the way it's written.


This was back in the dark ages of DSC before Microsoft open sourced their DSC resources on GitHub
https://github.com/PowerShell/DscResources which meant no forking a repository to fix the problem or submitting
a pull request so everyone could benefit from one person taking the time to resolve the problem.
#>

#endregion

#region Part 1 - Create a MOF Based DSC Resource to Configure Remote Desktop

<#
Part 1 of this demo demonstrates the process that I went through to write a custom DSC resource
for configuring Remote Desktop using a MOF based PowerShell resource since Windows PowerShell
version 4 was the current version at that point in time.

DSC (Desired State Configuration) was introduced in Windows PowerShell version 4.0. This initial
version of DSC was limited to using MOF (Managed Object Format) based DSC resources.

Install the DSC Resource Designer Tool.
#>

#First, download and install the xDscResourceDesigner PowerShell Module from the PowerShell Gallery.

Install-Module -Name xDSCResourceDesigner -Force
Get-Module -Name xDSCResourceDesigner -ListAvailable

<#
Install-Module exists in the PowerShellGet module which ships as part of Windows PowerShell version 5
and higher. The PowerShellGet module can be downloaded as an MSI https://github.com/PowerShell/PowerShellGet
and installed on Windows PowerShell version 3 or higher, although version 4 or higher is required for part 1
of this demo. I presented a session on PowerShellGet at the PowerShell Summit in 2015 if you're interested
in learning more.
http://mikefrobbins.com/2015/04/23/powershellget-the-big-easy-way-to-discover-install-and-update-powershell-modules/

##Execution Policy

In order to use the DSC Resource Designer tool, the script execution policy must be set to Remote Signed or
less restrictive.
#>

Get-ExecutionPolicy

<#
If the execution policy is set to AllSigned or the default of Restricted on the workstation you're
designing DSC resources on, you'll receive an error message.
#>

New-xDscResourceProperty –Name UserAuthentication –Type String –Attribute Key -ValidateSet 'Secure', 'NonSecure'

#Set the execution policy to Remote Signed or less
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
Get-ExecutionPolicy

<#
DSC Resource Properties

Decide which properties your resource will expose. There's a PowerShell team blog titled "Writing a custom DSC
resource with MOF" that's a good resource for determining what properties are required and what each type qualifier
is used for. https://docs.microsoft.com/en-us/powershell/dsc/authoringresourcemof

At least one "Key" property is required which uniquely identifies the resource instance.
A "Write" property is optional when using it in a configuration script

### Create the Skeleton for the DSC Resource

This can be accomplished with multiple lines of code.
#>

$UserAuthentication = New-xDscResourceProperty –Name UserAuthentication –Type String –Attribute Key -ValidateSet 'Secure', 'NonSecure'
$Ensure = New-xDscResourceProperty –Name Ensure –Type String –Attribute Write –ValidateSet 'Present', 'Absent'
New-xDscResource –Name cMrRDP -Property $UserAuthentication, $Ensure -Path "$env:ProgramFiles\windowspowershell\modules\cMrRDP"

#Or with a PowerShell one-liner.

New-xDscResource –Name cMrRDP -Property (New-xDscResourceProperty –Name UserAuthentication –Type String –Attribute Key -ValidateSet 'Secure', 'NonSecure'),
(New-xDscResourceProperty –Name Ensure –Type String –Attribute Write –ValidateSet 'Present', 'Absent') -Path "$env:ProgramFiles\WindowsPowerShell\Modules\cMrRDP"

<#
If you're a beginner, I'd recommend using the multiline option since it's more readable and
easier to troubleshoot if you happen to run into any problems.

Naming Convention

Notice in the previous command, I added a prefix of "c" to the name of the DSC resource that
I’m creating. That stands for "community". The recommendation at that point in time was to
use the letter "c" as the prefix for community created DSC resources. The current recommendation
is to no longer use the "c" prefix.

Steven Murawski wrote a blog article titled "DSC People – Let’s Stop Using 'c' Now" that I
recommend reading and Microsoft published an article on their PowerShell team blog titled
"DSC Resource Naming Guidelines" that provides specific guidance on the currently recommended
naming convention. Microsoft used "x" on many of their DSC resources which meant experimental,
but it's my understanding that they'll also be dropping the "x" from their DSC resources moving
forward.

https://stevenmurawski.com/2015/06/dsc-people-lets-stop-using-c-now/
https://blogs.msdn.microsoft.com/powershell/2017/12/08/dsc-resource-naming-and-support-guidelines/

### Exploring the Results of using the DSC Resource Kit Designer

The commands in the previous examples create the directory structure, a schema MOF file, a module
manifest (PSD1 file), and a PowerShell script module (PSM1 file).

#### The Schema MOF

The schema MOF file uses a fairly cryptic syntax as shown in the following example. Notice there are
both "Key" and "Write" type qualifiers in the MOF file itself which correspond to the properties created
with the New-xDscResourceProperty command. The FriendlyName is what's used to refer to this DSC resource
from within a DSC configuration.
#>

Start-Process "$env:ProgramFiles\WindowsPowerShell\modules\cMrRDP"

#### The Module manifest

#Create a module manifest for the PowerShell module that was created in the previous step.
New-ModuleManifest -Path "$env:ProgramFiles\WindowsPowershell\Modules\cMrRDP\cMrRDP.psd1" -Author 'Mike F Robbins' -CompanyName 'mikefrobbins.com' -RootModule 'cMrRDP' -Description 'Module with DSC Resource for enabling RDP access to a Computer' -PowerShellVersion 4.0 -FunctionsToExport '*.TargetResource' -Verbose

#A module manifest contains metadata about your module. All modules should have a module manifest regardless of whether or not they contain DSC resources.
psEdit -filenames "$env:ProgramFiles\WindowsPowerShell\modules\cMrRDP\cMrRDP.psd1"

#### The Script Module

#Open up the script module file and you'll see the template code that was created which includes the three required functions, Get-TargetResource, Set-TargetResource, and Test-TargetResource.
psEdit -filenames "$env:ProgramFiles\WindowsPowerShell\modules\cMrRDP\DSCResources\cMrRDP\cMrRDP.psm1"

#The Schema MOF
psEdit -filenames "$env:ProgramFiles\WindowsPowerShell\modules\cMrRDP\DSCResources\cMrRDP\cMrRDP.schema.mof"

<#
Get-TargetResource must return a hashtable.
Set-TargetResource is only called if Test-TargetResource fails and it should configure whatever isn't in the desired state while not returning any results at all.
Test-TargetResource is what's used to determine if the item specified in the configuration is in the desired state or not.

Write the Code for the Required Functions
#>

Set-Content -Path "$env:ProgramFiles\WindowsPowerShell\modules\cMrRDP\DSCResources\cMrRDP\cMrRDP.psm1" -Value @'
function Get-TargetResource {
	
  [CmdletBinding()]
	[OutputType([Hashtable])]
	param	(
		[Parameter(Mandatory)]
        [ValidateSet('NonSecure', 'Secure')]
		[String]$UserAuthentication,
    
        [Parameter(Mandatory)]
        [ValidateSet('Absent', 'Present')]
		[String]$Ensure
	)

  $AuthCurrentSetting = Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name 'UserAuthentication' |
                        Select-Object -ExpandProperty UserAuthentication

  $TSCurrentSetting = Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' |
                      Select-Object -ExpandProperty fDenyTSConnections
  
	$returnValue = @{
	    UserAuthentication = switch ($AuthCurrentSetting) {
            0 {'NonSecure'; Break}
            1 {'Secure'; Break}
        }
	    Ensure = switch ($TSCurrentSetting) {
            0 {'Present'; Break}
            1 {'Absent'; Break}

	    }
    }

	$returnValue

}

function Set-TargetResource {

	[CmdletBinding()]
	param	(
		[Parameter(Mandatory)]
        [ValidateSet('NonSecure', 'Secure')]
		[String]$UserAuthentication,
    
        [Parameter(Mandatory)]
        [ValidateSet('Absent', 'Present')]
		[String]$Ensure
	)

    if (-not(Test-TargetResource -UserAuthentication $UserAuthentication -Ensure $Ensure)) {

        switch ($UserAuthentication) {
            'NonSecure' {$AuthDesiredSetting = 0}
            'Secure' {$AuthDesiredSetting = 1}
        }

        switch ($Ensure) {
            'Present' {$TSDesiredSetting = 0}
            'Absent' {$TSDesiredSetting = 1}
        }

        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name 'UserAuthentication' -Value $AuthDesiredSetting
        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' -Value $TSDesiredSetting

    }  

}

function Test-TargetResource {
	
    [CmdletBinding()]
	[OutputType([Boolean])]
	param	(
		[Parameter(Mandatory)]
        [ValidateSet('NonSecure', 'Secure')]
		[String]$UserAuthentication,
    
        [Parameter(Mandatory)]
        [ValidateSet('Absent', 'Present')]
		[String]$Ensure
	)
  
    switch ($Ensure) {
        'Present' {$TSDesiredSetting = 'Enabled'; Break}
        'Absent' {$TSDesiredSetting = 'Disabled'; Break}
    }

    $NetworkLevelAuth = Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name 'UserAuthentication' |
                        Select-Object -ExpandProperty UserAuthentication

    $fDenyTSConnections = Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' |
                          Select-Object -ExpandProperty fDenyTSConnections

    switch ($NetworkLevelAuth) {
        0 {$AuthCurrentSetting = 'NonSecure'; Break}
        1 {$AuthCurrentSetting = 'Secure'; Break}
    }

switch ($fDenyTSConnections) {
    0 {$TSCurrentSetting = 'Enabled'; Break}
    1 {$TSCurrentSetting = 'Disabled'; Break}
}

    if ($UserAuthentication -eq $AuthCurrentSetting -and $TSDesiredSetting -eq $TSCurrentSetting) {
        Write-Verbose -Message 'RDP settings match the desired state'
        $bool = $true
    }
    else {  
        if ($UserAuthentication -ne $AuthCurrentSetting) {
            Write-Verbose -Message "User Authentication settings are non-compliant. User Authentication should be '$UserAuthentication' - Detected value is: '$AuthCurrentSetting'."
        $bool = $false 
        }
        if ($TSDesiredSetting -ne $TSCurrentSetting) {
            Write-Verbose "RDP settings are non-compliant. RDP should be '$TSDesiredSetting' - Detected value is: '$TSCurrentSetting'."
            $bool = $false   
        }
    }

  $bool

}

Export-ModuleMember -Function *-TargetResource
'@

psEdit -filenames "$env:ProgramFiles\WindowsPowerShell\modules\cMrRDP\DSCResources\cMrRDP\cMrRDP.psm1"

<#
### Consider Private Functions to Simplify

#Sometimes it's more efficient to create private functions that the three required functions call if some of the
same code is used by more than one of them. The Export-ModuleMember function is used to make sure that only these
three functions are publically available if you decide to write any private functions.

Export-ModuleMember -Function *-TargetResource

#Taking advantage of the FunctionsToExport section of the module manifest eliminates the need to use
Export-ModuleMember in the script module (PSM1) file to limit the publically available functions.
#>


### Deploying your Custom DSC Resource

Copy-Item -Path "$env:ProgramFiles\WindowsPowerShell\modules\cMrRDP" -Destination '\\server01\C$\Program Files\WindowsPowerShell\Modules' -Recurse -Force

<#
This custom DSC resource needs to exist on any systems where a DSC configuration will be applied that relies this
resource. With PowerShell version 4, automated deployment is only possible when using pull mode. There are several
tutorials on the web for distributing a resource so I won’t duplicate that content here.
#>

### Create a DSC configuration

#Create a simple DSC configuration to test the custom cMrRDP DSC resource.


configuration SetRemoteDesktop {
    Import-DscResource -ModuleName cMrRDP
    node SERVER01 {
        cMrRDP rdp {
            UserAuthentication = 'Secure'
            Ensure = 'Absent'
        }

    }
}


#Run the configuration. This creates a MOF configuration file that is specific to the specified node.

SetRemoteDesktop

#Apply the previously created DSC configuration.

Start-DscConfiguration -ComputerName SERVER01 -Path .\SetRemoteDesktop -Wait

#Success! You've now created a MOF based DSC resource from scratch.

#endregion

#region Part 2 - Create a Class Based DSC Resource for Configuring Remote Desktop

<#
A few years ago while attending the MVP Summit, I mentioned that I wish someone would write a MOF based DSC
resource and then rewrite the same resource as a Class based one so I could see the differences in both the
process to create them along with the differences in the finished products. As far as I know, no one ever
created anything like that. Once I learned how to create class based DSC resources, I decided to create and
share that exact information with the community. My goal with sharing this information is to help others
transition from creating MOF based DSC resources to creating class based ones without having them reinvent the wheel.

As mentioned in Part 1, prior to PowerShell version 5 being released, I had written a PowerShell version 4
compatible DSC resource named cMrRDP for configuring Remote Desktop. It only contained the three required
functions, Get-TargetResource, Set-TargetResource, and Test-TargetResource. Much of the code was duplicated
between these functions. A better approach would have been to create private functions within the resource
which the required functions call. This design eliminates code duplication, makes troubleshooting easier,
and simplifies both the code and the functions themselves. Since the functions are simpler, writing unit
test for them is also simpler.

I decided to rewrite my DSC resource for configuring Remote Desktop as a class based DSC resource. The module for
this new version is simply named "MrRemoteDesktop". This resource can also be found in my DSC repository on GitHub
(https://github.com/mikefrobbins/DSC). Class based DSC resources require PowerShell version 5 on the system used
for authoring the resource and on the system that the configuration is going to be applied to. With class based
resources, Get(), Set(), and Test() methods take the place of the previously referenced required functions. One
huge benefit to class based resources is that it doesn’t require a MOF file for the resource itself. This makes
writing the resource simpler and modifications no longer require major rework or starting from scratch.

The following code example has been saved as MrRemoteDesktop.psm1 in the
"$env:ProgramFiles\WindowsPowerShell\Modules\MrRemoteDesktop\" folder.
#>

New-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\MrRemoteDesktop\MrRemoteDesktop.psm1" -ItemType File -Force |
Set-Content -Encoding UTF8 -Value @'
enum Ensure {
    Absent
    Present
}
enum UserAuthenication {
    NonSecure
    Secure
}

[DscResource()]
class RemoteDesktop {

    [DscProperty(Key)]
    [UserAuthenication]$UserAuthenication

    [DscProperty(Mandatory)]
    [Ensure]$Ensure

    [RemoteDesktop]Get() {

        $this.UserAuthenication = $this.GetAuthSetting()
        $this.Ensure = $this.GetTSSetting()

	    Return $this

    }

    [void]Set(){

        if ($this.TestAuthSetting() -eq $false) {
            $this.SetAuthSetting($this.UserAuthenication)            
        }

        if ($this.TestTSSetting() -eq $false) {
            $this.SetTSSetting($this.Ensure)            
        }

    }

    [bool]Test(){

        if ($this.TestAuthSetting() -and $this.TestTSSetting() -eq $true) {
            Return $true
        }
        else {
            Return $false
        }

    }

    [string]GetAuthSetting(){

        $AuthCurrentSetting = Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name 'UserAuthentication' |
                              Select-Object -ExpandProperty UserAuthentication

        $AuthSetting = switch ($AuthCurrentSetting) {
            0 {'NonSecure'; Break}
            1 {'Secure'; Break}
        }

	    Return $AuthSetting

    }

    [string]GetTSSetting(){

        $TSCurrentSetting = Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' |
                            Select-Object -ExpandProperty fDenyTSConnections

        $TSSetting = switch ($TSCurrentSetting) {
            0 {'Present'; Break}
            1 {'Absent'; Break}
        }

	    Return $TSSetting

    }

    [void]SetAuthSetting([UserAuthenication]$UserAuthenication){

        switch ($this.UserAuthenication) {
            'NonSecure' {$Script:AuthDesiredSetting = 0; Break}
            'Secure' {$Script:AuthDesiredSetting = 1; Break}
        }

        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name 'UserAuthentication' -Value $Script:AuthDesiredSetting

    }

    [void]SetTSSetting([Ensure]$Ensure){

        switch ($this.Ensure) {
            'Present' {$Script:TSDesiredSetting = 0; Break}
            'Absent' {$Script:TSDesiredSetting = 1; Break}
        }

        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' -Value $Script:TSDesiredSetting

    }

    [bool]TestAuthSetting(){

        if ($this.UserAuthenication -eq $this.GetAuthSetting()){
            Return $true
        }
        else {
            Return $false
        }

    }

    [bool]TestTSSetting(){

        if ($this.Ensure -eq $this.GetTSSetting()){
            Return $true
        }
        else {
            Return $false
        }

    }

}
'@

<#
You’ll also need a module manifest file. The module manifest shown in the following example has been saved as
MrRemoteDesktop.psd1 in the same folder as the script module file.
#>

New-ModuleManifest -Path "$env:ProgramFiles\WindowsPowershell\Modules\MrRemoteDesktop\MrRemoteDesktop.psd1" -Author 'Mike F Robbins' -CompanyName 'mikefrobbins.com' -RootModule 'MrRemoteDesktop.psm1' -Description 'Module with DSC Resource for enabling RDP access to a Computer' -PowerShellVersion 5.0 -DscResourcesToExport RemoteDesktop -Verbose

<#
Remote Desktop is currently enabled on the server named SQL01 as shown in Figure 2.2.1.
This server has the server core (no-GUI) installation of Windows Server 2012 R2 and I don’t want admins using
remote desktop to connect to it. They should either use PowerShell to remotely administer it or install the GUI
tools on their workstation or a server that’s dedicated for management of other systems (what I call a jump box).

A configuration to disable RDP is written, the MOF file for SQL01 is generated, and it’s applied using push mode:
#>

Copy-Item -Path "$env:ProgramFiles\WindowsPowerShell\modules\MrRemoteDesktop" -Destination '\\server01\C$\Program Files\WindowsPowerShell\Modules' -Recurse -Force


Configuration RDP {
    Import-DSCResource -ModuleName MrRemoteDesktop

    Node SERVER01 {

        RemoteDesktop RDP {
            UserAuthenication = 'Secure'
            Ensure = 'Absent'
        }

    }
}

RDP
Start-DscConfiguration -Path .\RDP -ComputerName SERVER01 -Wait -Verbose -Force

#Now that the DSC configuration has been applied to SQL01, remote desktop on it is disabled:

#endregion

#region Part 3 - Simplifying my Class Based DSC Resource for Configuring Remote Desktop

#In Part 2 of this chapter, I wrote a class based DSC resource for configuring remote desktop. Since then I’ve discovered and learned a couple of new things about enumerations in PowerShell that can be used to simply the code even further.

#My original code used a couple of enumerations which I’ve removed to show how they can be used to further simply the code:

class RemoteDesktop {

    [DscProperty(Key)]
    [string]$UserAuthenication

    [DscProperty(Mandatory)]
    [string]$Ensure

    [RemoteDesktop]Get() {

        $this.UserAuthenication = $this.GetAuthSetting()
        $this.Ensure = $this.GetTSSetting()

        Return $this

    }

    [string]GetAuthSetting(){

        $AuthCurrentSetting = Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name 'UserAuthentication' |
                              Select-Object -ExpandProperty UserAuthentication

        $AuthSetting = switch ($AuthCurrentSetting) {
            0 {'NonSecure'; Break}
            1 {'Secure'; Break}
        }

        Return $AuthSetting

    }

    [string]GetTSSetting(){

        $TSCurrentSetting = Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' |
                            Select-Object -ExpandProperty fDenyTSConnections

        $TSSetting = switch ($TSCurrentSetting) {
            0 {'Present'; Break}
            1 {'Absent'; Break}
        }

        Return $TSSetting

    }

}

#The code shown in the previous example uses switch statements to translate the numeric values returned from the registry into human readable names. There are several different ways to instantiate a copy of the RemoteDesktop class and call the Get() method:

(New-Object -TypeName RemoteDesktop).Get()

([RemoteDesktop]::new()).Get()

$RDP = [RemoteDesktop]::new()
$RDP.Get()


#I’ll remove the switch statements to show that numeric values are indeed returned without them:


class RemoteDesktop {

    [DscProperty(Key)]
    [string]$UserAuthenication

    [DscProperty(Mandatory)]
    [string]$Ensure

    [RemoteDesktop]Get() {

        $this.UserAuthenication = $this.GetAuthSetting()
        $this.Ensure = $this.GetTSSetting()

        Return $this

    }

    [string]GetAuthSetting(){

        $AuthCurrentSetting = Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name 'UserAuthentication' |
                              Select-Object -ExpandProperty UserAuthentication

        Return $AuthCurrentSetting

    }

    [string]GetTSSetting(){

        $TSCurrentSetting = Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' |
                            Select-Object -ExpandProperty fDenyTSConnections

        Return $TSCurrentSetting

    }

}

([RemoteDesktop]::new()).Get()

#My original code, previously referenced from Part 2 of this chapter, used enumerations instead of ValidateSet, but I’ve since learned that enumerations in PowerShell offer a lot more functionality than just input validation.


enum UserAuthenication {
    NonSecure
    Secure
}
enum Ensure {
    Absent
    Present
}

class RemoteDesktop {

    [DscProperty(Key)]
    [UserAuthenication]$UserAuthenication

    [DscProperty(Mandatory)]
    [Ensure]$Ensure

    [RemoteDesktop]Get() {

        $this.UserAuthenication = $this.GetAuthSetting()
        $this.Ensure = $this.GetTSSetting()

        Return $this

    }

    [UserAuthenication]GetAuthSetting(){

        $AuthCurrentSetting = Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name 'UserAuthentication' |
                              Select-Object -ExpandProperty UserAuthentication

        Return $AuthCurrentSetting

    }

    [Ensure]GetTSSetting(){

        $TSCurrentSetting = Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' |
                            Select-Object -ExpandProperty fDenyTSConnections

        Return $TSCurrentSetting

    }

}

([RemoteDesktop]::new()).Get()

#By simply using the enumerations, the values are automatically translated from their numeric values returned from the registry into their human readable names that are defined in the enumeration so there’s no need to perform the translation with switch statements.

#The only problem at this point is the incorrect value is being return by the Ensure enumeration. By default the first item in the enumeration is 0, the second one is 1, and so on. I could simply swap the order of the two items in the Ensure enumeration to correct this problem:


enum Ensure {
    Present
    Absent
}


#A better option is to be more declarative and define the value of each item in the enumerations so the order doesn’t matter:


enum UserAuthenication {
    NonSecure = 0
    Secure = 1
}
enum Ensure {
    Absent = 1
    Present = 0
}


#Although the code was already simple, the end result after refactoring it is even simpler code and less of it:

Set-Content -Path "$env:ProgramFiles\WindowsPowerShell\Modules\MrRemoteDesktop\MrRemoteDesktop.psm1" -Encoding UTF8 -Value @'
enum UserAuthenication {
    NonSecure = 0
    Secure = 1
}
enum Ensure {
    Present = 0
    Absent = 1
}

[DscResource()]
class RemoteDesktop {

    [DscProperty(Key)]
    [UserAuthenication]$UserAuthenication

    [DscProperty(Mandatory)]
    [Ensure]$Ensure

    [RemoteDesktop]Get() {

        $this.UserAuthenication = $this.GetAuthSetting()
        $this.Ensure = $this.GetTSSetting()

        Return $this

    }

    [void]Set(){

        if ($this.TestAuthSetting() -eq $false) {
            Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name 'UserAuthentication' -Value $this.UserAuthenication        
        }

        if ($this.TestTSSetting() -eq $false) {
            Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' -Value $this.Ensure        
        }

    }

    [bool]Test(){

        if ($this.TestAuthSetting() -and $this.TestTSSetting() -eq $true) {
            Return $true
        }
        else {
            Return $false
        }

    }

    [UserAuthenication]GetAuthSetting(){

        $AuthCurrentSetting = Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name 'UserAuthentication' |
                              Select-Object -ExpandProperty UserAuthentication

        Return $AuthCurrentSetting

    }

    [Ensure]GetTSSetting(){

        $TSCurrentSetting = Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' |
                            Select-Object -ExpandProperty fDenyTSConnections

        Return $TSCurrentSetting

    }

    [bool]TestAuthSetting(){

        if ($this.UserAuthenication -eq $this.GetAuthSetting()){
            Return $true
        }
        else {
            Return $false
        }

    }

    [bool]TestTSSetting(){

        if ($this.Ensure -eq $this.GetTSSetting()){
            Return $true
        }
        else {
            Return $false
        }

    }

}
'@

Copy-Item -Path "$env:ProgramFiles\WindowsPowerShell\modules\MrRemoteDesktop" -Destination '\\server01\C$\Program Files\WindowsPowerShell\Modules' -Recurse -Force

Start-DscConfiguration -Path .\RDP -ComputerName SERVER01 -Wait -Verbose -Force

#As shown in the previous code example, I also decided to move the code from the SetAuthSetting() and SetTSSetting() methods back into the actual Set() method since other methods don’t call them which means that there’s no redundant code eliminated by separating them and separating them adds complexity.

#The updated version of the PowerShell Desired State Configuration Class Based Resource for Configuring Remote Desktop shown in this blog article can be downloaded from [my DSC repository on GitHub](https://github.com/mikefrobbins/DSC).

#endregion

#region Cleanup

Set-ExecutionPolicy -ExecutionPolicy Restricted -Force
Remove-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\cMrRDP" -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path C:\demo\SetRemoteDesktop -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\MrRemoteDesktop" -Recurse -ErrorAction SilentlyContinue

Invoke-Command -ComputerName SERVER01 {
    Remove-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\cMrRDP" -Recurse -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\MrRemoteDesktop" -Recurse -ErrorAction SilentlyContinue

    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name 'UserAuthentication' -Value 1
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' -Value 0

    Get-NetFirewallRule -DisplayGroup 'Remote Desktop' |
    Set-NetFirewallRule -Enabled True
}

#endregion