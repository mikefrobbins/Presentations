#region Presentation Info

<#
    Recreate MOF based DSC resources as Class based DSC resources
    Presentation from PowerShell Saturday Chattanooga 2018
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins
#>

#endregion

#region Safety to prevent the entire script from being run instead of a selection

throw "You're not supposed to run the entire script"

#endregion

#region Presentation Prep

#Set PowerShell ISE Zoom to 150%
$psISE.Options.Zoom = 150

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
    The workstation used throughout this demo is running Windows 10 version 1709
    and the servers are running Windows Server 2016. They're all a member of the
    same Active Directory domain. Each of them runs Windows PowerShell version 5.1
    which ships in the box with all of those operating systems.
#>

#endregion

#region Part 1 - Create a MOF Based DSC Resource to Configure Remote Desktop

<#
    Install the DSC Resource Designer Tool.

    First, download and install the xDscResourceDesigner PowerShell Module
    from the PowerShell Gallery.
#>

#Install-Module -Name xDSCResourceDesigner -Force
Get-Module -Name xDSCResourceDesigner -ListAvailable

<#
    Install-Module exists in the PowerShellGet module which ships as part of Windows
    PowerShell version 5 and higher. The PowerShellGet module can be downloaded as
    an MSI and installed on Windows PowerShell version 3 or higher, although version
    4 or higher is required for part 1 of this demo. I presented a session on PowerShellGet
    at the PowerShell Summit in 2015 if you're interested in learning more.
    https://github.com/PowerShell/PowerShellGet
    http://mikefrobbins.com/2015/04/23/powershellget-the-big-easy-way-to-discover-install-and-update-powershell-modules/
#>

#************************************************************************************
#Execution Policy
#************************************************************************************

<#
    In order to use the DSC Resource Designer tool, the script execution policy must
    be set to Remote Signed or less restrictive.
#>

Get-ExecutionPolicy

<#
    If the execution policy is set to AllSigned or the default of Restricted on the
    workstation you're designing DSC resources on, you'll receive an error message.
#>

$Params = @{
    Name = 'UserAuthentication'
    Type = 'String'
    Attribute = 'Key'
    ValidateSet = 'Secure', 'NonSecure'
}

New-xDscResourceProperty @Params

#Import the module for more information (per the error message).

Import-Module -Name xDSCResourceDesigner

#Set the execution policy to Remote Signed or less

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
Get-ExecutionPolicy

#*********************************************************************************
#DSC Resource Properties
#*********************************************************************************

<#
    Decide which properties your resource will expose. There's a PowerShell team blog
    titled "Writing a custom DSC resource with MOF" that's a good resource for determining
    what properties are required and what each type qualifier is used for.
    https://docs.microsoft.com/en-us/powershell/dsc/authoringresourcemof

    At least one "Key" property is required which uniquely identifies the resource instance.
    A "Write" property is optional when using it in a configuration script
#>

#Create the Skeleton for the DSC Resource. This can be accomplished with multiple lines of code.

$UserAuthParams = @{
    Name = 'UserAuthentication'
    Type = 'String'
    Attribute = 'Key'
    ValidateSet = 'Secure', 'NonSecure'
}

$UserAuthentication = New-xDscResourceProperty @UserAuthParams

$EnsureParams = @{
    Name = 'Ensure'
    Type = 'String'
    Attribute = 'Write'
    ValidateSet = 'Present', 'Absent'
}

$Ensure = New-xDscResourceProperty @EnsureParams

$cMrRdpParams = @{
    Name = 'cMrRDP'
    Property = $UserAuthentication, $Ensure
    Path = "$env:ProgramFiles\windowspowershell\modules\cMrRDP"
}

New-xDscResource @cMrRdpParams

#This could also be accomplished using a PowerShell one-liner.

#New-xDscResource –Name cMrRDP -Property (New-xDscResourceProperty –Name UserAuthentication –Type String –Attribute Key -ValidateSet 'Secure', 'NonSecure'),
#(New-xDscResourceProperty –Name Ensure –Type String –Attribute Write –ValidateSet 'Present', 'Absent') -Path "$env:ProgramFiles\WindowsPowerShell\Modules\cMrRDP"

<#
    I recommend using the multiline option since it's more readable and easier to
    troubleshoot if you happen to run into any problems.

    If you specify the ModuleName parameter when running New-xDscResource, a module manifest
    will be created automatically for you and the folder stucture is slightly different.
#>

#************************************************************************************
#Exploring the Results of using the DSC Resource Kit Designer
#************************************************************************************

<#
    The commands in the previous examples create the directory structure, a schema MOF
    file, a module manifest (PSD1 file), and a PowerShell script module (PSM1 file).
#>

Start-Process "$env:ProgramFiles\WindowsPowerShell\modules\cMrRDP\DSCResources\cMrRDP"

#**********************************************************************************
#### The Module manifest
#**********************************************************************************

#Create a module manifest for the module that was created in the previous step.

$ManifestParams = @{
    Path = "$env:ProgramFiles\WindowsPowershell\Modules\cMrRDP\cMrRDP.psd1"
    Author = 'Mike F Robbins'
    CompanyName = 'mikefrobbins.com'
    RootModule = 'cMrRDP'
    Description = 'Module with DSC Resource for enabling RDP access to a Computer'
    PowerShellVersion = '4.0'
    FunctionsToExport = '*.TargetResource'
    Verbose = $true
}

New-ModuleManifest @ManifestParams

<#
    A module manifest contains metadata about your module.
    All modules should have a module manifest.
#>

psEdit -filenames "$env:ProgramFiles\WindowsPowerShell\modules\cMrRDP\cMrRDP.psd1"

#***********************************************************************************
#The Script Module
#***********************************************************************************

<#
    The script module (PSM1 file) now contains template code that was created by New-xDscResource.
    
    It includes the three required functions:
    Get-TargetResource
    Set-TargetResource
    Test-TargetResource
#>

psEdit -filenames "$env:ProgramFiles\WindowsPowerShell\modules\cMrRDP\DSCResources\cMrRDP\cMrRDP.psm1"

#*************************************************************************************
#The Schema MOF
#*************************************************************************************

<#
    The schema MOF file uses a fairly cryptic syntax as shown in the following example.
    Notice there are both "Key" and "Write" type qualifiers in the MOF file itself which
    correspond to the properties created with the New-xDscResourceProperty command. The
    FriendlyName is what's used to refer to this DSC resource from within a DSC configuration.
#>

psEdit -filenames "$env:ProgramFiles\WindowsPowerShell\modules\cMrRDP\DSCResources\cMrRDP\cMrRDP.schema.mof"

#Write the Code for the three required functions

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

#Show the updated script module (PSM1 file)

psEdit -filenames "$env:ProgramFiles\WindowsPowerShell\modules\cMrRDP\DSCResources\cMrRDP\cMrRDP.psm1"

### Deploying your Custom DSC Resource

$DeployParams = @{
    Path = "$env:ProgramFiles\WindowsPowerShell\modules\cMrRDP"
    Destination = '\\server01\C$\Program Files\WindowsPowerShell\Modules'
    Recurse = $true
    Force = $true
}

Copy-Item @DeployParams

<#
    This custom DSC resource needs to exist on any systems where a DSC configuration
    will be applied that relies this resource. With PowerShell version 4, automated
    deployment is only possible when using pull mode. There are several tutorials on
    the web for distributing a resource so I won’t duplicate that content here.

    Create a simple DSC configuration to test the custom cMrRDP DSC resource.
#>

configuration SetRemoteDesktop {
    Import-DscResource -ModuleName cMrRDP

    node SERVER01 {

        cMrRDP rdp {
            UserAuthentication = 'Secure'
            Ensure = 'Absent'
        }

    }
}

<#
    Run the configuration. This creates a MOF configuration file that is specific
    to the referenced node.
#>

SetRemoteDesktop

#Apply the previously created DSC configuration.

Start-DscConfiguration -ComputerName SERVER01 -Path .\SetRemoteDesktop -Wait -Verbose

#Success! You've now created a MOF based DSC resource from scratch and applied it to a server.

#Cleanup
$Path = 'C:\Demo'
Get-ChildItem -Path $Path | Remove-Item -Recurse

Invoke-Command -ComputerName SERVER01 {
    Remove-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\cMrRDP" -Recurse -ErrorAction SilentlyContinue

    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name 'UserAuthentication' -Value 1
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' -Value 0

    Get-NetFirewallRule -DisplayGroup 'Remote Desktop' |
    Set-NetFirewallRule -Enabled True
}

#endregion

#region Part 2 - Create a Class Based DSC Resource for Configuring Remote Desktop

<#
    The following code example has been saved as MrRemoteDesktop.psm1 in the
    "$env:ProgramFiles\WindowsPowerShell\Modules\MrRemoteDesktop\" folder.
#>

#Create the script module file (consider doing this with Plaster). No designer for Classes.

$Params2 = @{
    Path = "$env:ProgramFiles\WindowsPowerShell\Modules\MrRemoteDesktop\MrRemoteDesktop.psm1"
    ItemType = 'File'
    Force = $true
}

New-Item @Params2

#Write the code for the classes

Set-Content -Encoding UTF8 -Path "$env:ProgramFiles\WindowsPowerShell\Modules\MrRemoteDesktop\MrRemoteDesktop.psm1" -Value @'
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

#Show the script module (PSMa 1 file)
psEdit -filenames "$env:ProgramFiles\WindowsPowerShell\Modules\MrRemoteDesktop\MrRemoteDesktop.psm1"

<#
    You’ll also need a module manifest file. The module manifest shown in the following
    example has been saved as MrRemoteDesktop.psd1 in the same folder as the script module file.
#>

$ManifestParams2 = @{
    Path = "$env:ProgramFiles\WindowsPowershell\Modules\MrRemoteDesktop\MrRemoteDesktop.psd1"
    Author = 'Mike F Robbins'
    CompanyName = 'mikefrobbins.com'
    RootModule = 'MrRemoteDesktop.psm1'
    Description = 'Module with DSC Resource for enabling RDP access to a Computer'
    PowerShellVersion = '5.0'
    DscResourcesToExport = 'RemoteDesktop'
    Verbose = $true
}

New-ModuleManifest @ManifestParams2

<#
    Remote Desktop is currently enabled on the server named Server01. This server has the
    server core (no-GUI) installation of Windows Server 2012 R2 and I don’t want admins
    using remote desktop to connect to it. They should either use PowerShell to remotely
    administer it or install the GUI tools on their workstation or a server that’s dedicated
    for management of other systems (what I call a jump box).

    A configuration to disable RDP is written, the MOF file for Server01 is generated, and
    it’s applied using push mode.
#>

#Deploy the Resource

$DeployParams2 = @{
    Path = "$env:ProgramFiles\WindowsPowerShell\modules\MrRemoteDesktop"
    Destination = '\\server01\C$\Program Files\WindowsPowerShell\Modules'
    Recurse = $true
    Force = $true
}

Copy-Item @DeployParams2

#Create a simple DSC configuration

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

#Apply the configuration

Start-DscConfiguration -Path .\RDP -ComputerName SERVER01 -Wait -Verbose -Force

#Now that the DSC configuration has been applied to Server01, remote desktop on it is disabled.

#endregion

#region Part 3 - Simplifying my Class Based DSC Resource for Configuring Remote Desktop

<#
    I discovered and learned a couple of new things about enumerations in PowerShell
    that can be used to simply the code even further.

    My original code used a couple of enumerations which I’ve removed to show how they
    can be used to further simply the code.
#>

class RemoteDesktop1 {

    [DscProperty(Key)]
    [string]$UserAuthenication

    [DscProperty(Mandatory)]
    [string]$Ensure

    [RemoteDesktop1]Get() {

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

<#
    The code shown in the previous example uses switch statements to translate the numeric
    values returned from the registry into human readable names.
    
    There are several different ways to instantiate a copy of the RemoteDesktop class and
    call the Get() method.
#>

(New-Object -TypeName RemoteDesktop1).Get()

([RemoteDesktop1]::new()).Get()

$RDP = [RemoteDesktop1]::new()
$RDP.Get()

#Remove the switch statements to show that numeric values are indeed returned without them.

class RemoteDesktop2 {

    [DscProperty(Key)]
    [string]$UserAuthenication

    [DscProperty(Mandatory)]
    [string]$Ensure

    [RemoteDesktop2]Get() {

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

([RemoteDesktop2]::new()).Get()

<#
    My code from Part 2 of this demo used enumerations instead of ValidateSet, but I’ve
    since learned that enumerations in PowerShell offer a lot more functionality than
    just input validation.
#>

enum UserAuthenication {
    NonSecure
    Secure
}
enum Ensure {
    Absent
    Present
}

class RemoteDesktop3 {

    [DscProperty(Key)]
    [UserAuthenication]$UserAuthenication

    [DscProperty(Mandatory)]
    [Ensure]$Ensure

    [RemoteDesktop3]Get() {

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

([RemoteDesktop3]::new()).Get()

<#
    By simply using the enumerations, the values are automatically translated from their numeric
    values returned from the registry into their human readable names that are defined in the
    enumeration so there’s no need to perform the translation with switch statements.

    The only problem at this point is the incorrect value is being return by the Ensure enumeration.
    By default the first item in the enumeration is 0, the second one is 1, and so on. I could
    simply swap the order of the two items in the Ensure enumeration to correct this problem.
#>

<#
    enum Ensure {
        Present
        Absent
    }
#>

<#
    A better option is to be more declarative and define the value of each item in the enumerations
    so the order doesn’t matter.
#>

<#
    enum UserAuthenication {
        NonSecure = 0
        Secure = 1
    }
    enum Ensure {
        Absent = 1
        Present = 0
    }
#>

<#
    Although the code was already simple, the end result after refactoring it is even simpler
    code and less of it.
#>

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

#Show the updated script module (PSM1 file)
psEdit -filenames "$env:ProgramFiles\WindowsPowerShell\Modules\MrRemoteDesktop\MrRemoteDesktop.psm1"

#Deploy the resource

$DeployParams3 = @{
    Path = "$env:ProgramFiles\WindowsPowerShell\modules\MrRemoteDesktop"
    Destination = '\\server01\C$\Program Files\WindowsPowerShell\Modules'
    Recurse = $true
    Force = $true
}

Copy-Item @DeployParams3

#Apply the configuration

Start-DscConfiguration -Path .\RDP -ComputerName SERVER01 -Wait -Verbose -Force

<#
    As shown in the previous code example, I also decided to move the code from the
    SetAuthSetting() and SetTSSetting() methods back into the actual Set() method since
    other methods don’t call them which means that there’s no redundant code eliminated
    by separating them and separating them adds complexity.

    The updated version of the PowerShell Desired State Configuration Class Based Resource
    for Configuring Remote Desktop shown in this blog article can be downloaded from my DSC
    repository on GitHub. https://github.com/mikefrobbins/DSC
#>

#endregion

#region Cleanup

$Path = 'C:\Demo'
Get-ChildItem -Path $Path | Remove-Item -Recurse
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

Set-Location -Path C:\
$psISE.Options.Zoom = 100
$host.PrivateData.ErrorForegroundColor = 'red'

#endregion