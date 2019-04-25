#Requires -Version 3.0 -PSEdition Desktop
function Format-MrCounter {

<#
.SYNOPSIS
    Formats the output of the Get-Counter cmdlet into a friendlier format.
 
.DESCRIPTION
    The Format-MrCounter function accepts input from the Get-Counter function
    and formats it into a much more useable and more object oriented format.
 
.PARAMETER InputObject
    Accepts the output of the results from the Get-Counter cmdlet. It expects a
    Microsoft.PowerShell.Commands.GetCounter.PerformanceCounterSampleSet object type.
 
.EXAMPLE
    Get-Counter | Format-MrCounter

.EXAMPLE
    Get-Counter -ComputerName Server01, Server02 | Format-MrCounter

.INPUTS
    Microsoft.PowerShell.Commands.GetCounter.PerformanceCounterSampleSet
 
.OUTPUTS
    Mr.CounterInfo
 
.NOTES
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins
#>

    [CmdletBinding()]
    [OutputType('Mr.CounterInfo')]
    param (
        [Parameter(Mandatory, 
                   ValueFromPipeline)]
        [Microsoft.PowerShell.Commands.GetCounter.PerformanceCounterSampleSet[]]$InputObject
    )

    PROCESS {

        foreach ($Counter in $InputObject.CounterSamples){

            $CounterInfo = $Counter.Path.Split('\\', [System.StringSplitOptions]::RemoveEmptyEntries)

            for ($i = 0; $i -lt $CounterInfo.Count; $i += 3){
                [pscustomobject]@{
                    DateTime = $Counter.Timestamp
                    ComputerName = $CounterInfo[$i]
                    CounterSet = $CounterInfo[$i+1]
                    Counter = $CounterInfo[$i+2]
                    Value = $Counter.CookedValue
                    PSTypeName = 'Mr.CounterInfo'
                } |
                Add-Member -MemberType MemberSet -Name PSStandardMembers -Value (
                    [System.Management.Automation.PSMemberInfo[]]@(
                        New-Object -TypeName System.Management.Automation.PSPropertySet(
                            'DefaultDisplayPropertySet',[string[]]@(
                                'ComputerName', 'CounterSet', 'Counter', 'Value'
                            )
                        )
                    )
                ) -PassThru
            }
        
        }

    }
      
}