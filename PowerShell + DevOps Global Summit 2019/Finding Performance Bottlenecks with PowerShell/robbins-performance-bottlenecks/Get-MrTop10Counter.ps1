#Requires -Version 3.0
function Get-MrTop10Counter {

<#
.SYNOPSIS
  Gets performance counter data from local and remote computers.
 
.DESCRIPTION
  The Get-MrTop10Counter function gets live, real-time performance counter
  data directly from the performance monitoring instrumentation in Windows.
 
.PARAMETER ComputerName
  Gets data from the specified computers. Type the NetBIOS name, an Internet
  Protocol (IP) address, or the fully qualified domain names of the computers.
  The default value is the local computer.
 
.EXAMPLE
  Get-MrTop10Counter -ComputerName Server01, Server02

.INPUTS
  None
 
.OUTPUTS
  PSCustomObject
 
.NOTES
  Author:  Mike F Robbins
  Website: http://mikefrobbins.com
  Twitter: @mikefrobbins
#>

  [CmdletBinding()]
  param (
    [ValidateNotNullOrEmpty()]
    [string]$ComputerName = $env:COMPUTERNAME
  )

  $Params = @{
    Counter = '\PhysicalDisk(*)\% Idle Time',
              '\PhysicalDisk(*)\Avg. Disk sec/Read',
              '\PhysicalDisk(*)\Avg. Disk sec/Write',
              '\PhysicalDisk(*)\Current Disk Queue Length',
              '\Memory\Available Bytes',
              '\Memory\Pages/sec',
              '\Network Interface(*)\Bytes Total/sec',
              '\Network Interface(*)\Output Queue Length',
              '\Hyper-V Hypervisor Logical Processor(*)\% Total Run Time',
              '\Paging File(*)\% Usage'
        
    ErrorAction = 'SilentlyContinue'
  }
 
  if ($PSBoundParameters.ComputerName) {
    $Params.ComputerName = $ComputerName
  }

  $Counters = (Get-Counter @Params).CounterSamples

  foreach ($Counter in $Counters){
    [pscustomobject]@{
      ComputerName = $ComputerName
      CounterSetName = $Counter.Path -replace "^\\\\$ComputerName\\|\(.*$"
      Counter = $Counter.Path -replace '^.*\\'
      Instance = $Counter.InstanceName
      Value = $Counter.CookedValue
      TimeStamp = $Counter.Timestamp
    }
  }
}