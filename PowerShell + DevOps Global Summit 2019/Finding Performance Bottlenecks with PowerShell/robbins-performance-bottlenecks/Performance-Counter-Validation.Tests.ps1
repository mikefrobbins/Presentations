[CmdletBinding()]
param (
  [Microsoft.Management.Infrastructure.CimSession]$CimSession
)

$Params = @{}

if (-not($PSBoundParameters.CimSession)) {
  $Counters = Get-MrTop10Counter
}
else {
  $Params.CimSession = $CimSession
  $Counters = Get-MrTop10Counter -ComputerName $CimSession.ComputerName
}

$Computer = $Counters[0].ComputerName

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

Describe "Physical Disk Current Disk Queue Length for $Computer" {
  $Counter = 'Current Disk Queue Length'
  $Cases = $Counters.Where({
              $_.Counter -eq $Counter  -and $_.Instance -ne '_total'
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

Describe "Memory Available Bytes for $Computer" {    
  It 'Should Not Be Less than 10% free' {
    ($Counters.Where({$_.Counter -eq 'Available Bytes'}).Value / 1MB) /
    ((Get-CimInstance @Params -ClassName Win32_PhysicalMemory -Property Capacity |
     Measure-Object -Property Capacity -Sum).Sum / 1MB) * 100 -as [int] |
    Should -Not -BeLessThan 10
  }
}

Describe "Memory Pages/sec for $Computer" {    
  It 'Should Not Be Greater than 1000' {
    $Counters.Where({$_.Counter -eq 'Pages/sec'}).Value |
    Should -Not -BeGreaterThan 1000  
  }
}

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

Describe "Network Interface Output Queue Length for $Computer" {
  $Counter = 'Output Queue Length'
  $Cases = $Counters.Where({
              $_.Counter -eq $Counter -and $_.Instance -notmatch 'isatap'}) |
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

Describe "Hyper-V Hypervisor Logical Processor % Total Run Time for $Computer" {
  $Counter = '% Total Run Time'
  $Cases = $Counters.Where({$_.Counter -eq $Counter}) |
           Select-Object -Property Instance |
           ConvertTo-MrHashTable
    
  It 'Should Not Be Greater than 90% for: <Instance>' -TestCases $Cases {  
    param($Instance)
    $Counters.Where({
        $_.Instance -eq $Instance -and $_.Counter -eq $Counter}).Value |
        Should -Not -BeGreaterThan 90
  }
}

Describe "Paging File % Usage for $Computer" {
  $Counter = '% Usage'
  $Cases = $Counters.Where({
              $_.Counter -eq $Counter -and $_.Instance -ne '_total'
           }) |
           Select-Object -Property Instance |
           ConvertTo-MrHashTable
    
  It 'Should Not Be Greater than 10% for: <Instance>' -TestCases $Cases {
    param($Instance)
    $Counters.Where({
      $_.Instance -eq $Instance -and $_.Counter -eq $Counter
    }).Value |
    Should -Not -BeGreaterThan 10
  }
}