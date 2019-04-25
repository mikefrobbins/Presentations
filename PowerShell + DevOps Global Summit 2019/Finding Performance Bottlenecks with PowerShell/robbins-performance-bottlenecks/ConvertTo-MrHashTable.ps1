#Requires -Version 3.0
function ConvertTo-MrHashTable {

<#
.SYNOPSIS
  Converts object based output to a Hashtable .
 
.DESCRIPTION
  The ConvertTo-MrHashTable function converts the properties and values
  from any PowerShell command that produces object based output to a
  Hashtable.
 
.PARAMETER InputObject
  The object(s) to convert to a hashtable. This parameter is mandatory.
 
.EXAMPLE
  Get-Culture | ConvertTo-MrHashTable

.EXAMPLE
  ConvertTo-MrHashTable -InputObject (Get-Culture)

.INPUTS
  PSCustomObject
 
.OUTPUTS
  PSCustomObject
 
.NOTES
  Author:  Mike F Robbins
  Website: http://mikefrobbins.com
  Twitter: @mikefrobbins
#>

  [CmdletBinding()]
  param (
    [Parameter(Mandatory,
               ValueFromPipeline)]
    [PSCustomObject[]]$InputObject
  )

  PROCESS {
    foreach ($Object in $InputObject) {
      $Hashtable = @{}
            
      foreach ($Property in Get-Member -InputObject $Object -MemberType Properties) {
        $Hashtable.($Property.Name) = $Object.($Property.Name)
      }

      Write-Output $Hashtable
    }
  }
}