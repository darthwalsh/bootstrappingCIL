$ErrorActionPreference = "Stop"

$sw = [system.diagnostics.stopwatch]::startNew()

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = Split-Path -Parent $here

Function Root($p) {
  Join-Path -Path $root -ChildPath $p
}

Function Here($p) {
  Join-Path -Path $here -ChildPath $p
}

Function Should-Be($expected) { 
  Process { 
    if ($_ -ne $expected) {
      throw "Expected $expected but actually got $_"
    }
  }
}

$passed = 0
$failed = 0

Function It($name, $action) {
  $time = Measure-Command { 
    Try { 
      & $action
    } Catch { 
      $e = $_
    }
  }
  $time = [math]::Ceiling($time.TotalMilliseconds)
  

  if ($e -eq $null) {
    $color = "DarkGreen"
    $success = "+"
    ++$script:passed
  } else {
    $color = "Red"
    $success = "-"
    ++$script:failed
  }
  
  Write-Host "[$success] $name $($time)ms" -Foreground $color
  if ($e -ne $null) {
    Write-Host $e.ToString() -Foreground $color
  }
}

Function Describe($name, $action) {
  Write-Host "Describing $name" -Foreground "magenta"
  & $action
}

Function Compile($exe, $target) {
  # Don't overwrite existing files
  $shortname = (get-childitem -path $target).Name -replace "\.", ""
  $name = Here "$($shortname)_$(Get-Random 1000)delete.exe"
  
  cmd /c "$exe < $target > $name"
  $LastExitCode | Should-Be 0
  
  $name
}

Function RunTest($exe, $target, $instream, $expected) {
    $target = Here $target
    $exe = Compile $exe $target
    
    $output = $instream | & $exe
    if($output -eq $null) {
      $output = ""
    }
    
    [string]($output) | Should-Be $expected
}

Function Bootstraps($bscilexe, $target) {
  It "bootstraps" {
    $bootstrapped = Compile $bscilexe $target
    
    fc.exe /b $bscilexe $bootstrapped
    $LastExitCode | Should-Be 0
  }
}

Function TestBSCIL0($bscilexe) {
  It "runs trivial" {
    RunTest $bscilexe trivial.bscil0 "" ""
  }
  
  It "runs adder" {
    RunTest $bscilexe adder.bscil0 "" "5"
  }
  
  It "runs echo2" {
    RunTest $bscilexe echo2.bscil0 "hello" "he"
  }
}

Function TestBSCIL1($bscilexe) {
  It "runs trivial" {
    RunTest $bscilexe trivial.bscil1 "" ""
  }
  
  It "runs echo2" {
    RunTest $bscilexe echo2.bscil1 "hello" "he"
  }
  
  It "runs blank" {
    $exe = Compile $bscilexe (Here blank.bscil1)
    
    $output = & $exe
    [string]($output).Length | Should-Be 0x52CD
  }
  
  It "runs heart" {
    RunTest $bscilexe heart.bscil1 "" "<3"
  }
  
  It "runs echoTwice" {
    RunTest $bscilexe echoTwice.bscil1 "abc" "cca"
  }
  
  It "runs math" {
    RunTest $bscilexe math.bscil1 "" "6"
  }
  
  It "runs branches" {
    RunTest $bscilexe branches.bscil1 "" "2456"
  }
}

Function TestBSCIL2($bscilexe) {
  It "runs trivial" {
    RunTest $bscilexe trivial.bscil2 "" ""
  }
  
  It "runs echo2" {
    RunTest $bscilexe echo2.bscil2 "hello" "hea"
  }
  
  It "runs blank" {
    $exe = Compile $bscilexe (Here blank.bscil2)
    
    $output = & $exe
    [string]($output).Length | Should-Be 0x52CD
  }
  
  It "runs heart" {
    RunTest $bscilexe heart.bscil2 "" "<3"
  }
  
  It "runs echoTwice" {
    RunTest $bscilexe echoTwice.bscil2 "abc" "cca"
  }
  
  It "runs math" {
    RunTest $bscilexe math.bscil2 "" "6"
  }
  
  It "runs branches" {
    RunTest $bscilexe branches.bscil2 "" "2456"
  }
  
  It "runs mem" {
    RunTest $bscilexe mem.bscil2 "4" "34"
  }
}

Remove-Item "*delete.exe" # Pretty safe to delete files ending in delete?

$bscil0exe = Root "bscil0\bscil0.exe"

Describe "bscil0" {
  TestBSCIL0 $bscil0exe
  
  Bootstraps $bscil0exe (Root "bscil0\bscil0.bscil0")
}

$bscil1exe = Compile $bscil0exe (Root "bscil1\bscil1.bscil0")

Describe "bscil1.bscil0" {
  TestBSCIL1 $bscil1exe 
}

Describe "bscil1.bscil1" {
  $anotherbscil1 = Compile $bscil1exe (Root "bscil1\bscil1.bscil1")
  TestBSCIL1 $anotherbscil1
  
  Bootstraps $anotherbscil1 (Root "bscil1\bscil1.bscil1")
}

$bscil2exe = Compile $bscil1exe (Root "bscil2\bscil2.bscil1")

Describe "bscil2.bscil1" {
  TestBSCIL2 $bscil2exe 
}

$time = $sw.ElapsedMilliseconds
Write-Host "Tests completed in $($time)ms"
Write-Host "Passed: $passed Failed: $failed"


$date = [datetime]::now.ToString("yyyy-MM-dd")
$time = [datetime]::now.ToString("HH:mm:ss")

$xml = '<?xml version="1.0" encoding="utf-8" standalone="no"?>'
$xml += '
<test-results  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="nunit_schema_2.5.xsd" name="CarlTesting"'
$xml += " total=""$($failed + $passed)"" errors=""$failed"" failures=""$failed"""
$xml += ' not-run="0" inconclusive="0" ignored="0" skipped="0" invalid="0"'
$xml += "date=""$date"" time=""$time"">"
$xml +='
	<environment nunit-version="2.5.8.0" clr-version="2.0.50727.1433" os-version="10.0.10240" platform="Microsoft Windows 10 Home|C:\WINDOWS|\Device\Harddisk1\Partition2" cwd="C:\code\bootstrappingCIL\test" machine-name="DISCOVERY" user="cwalsh" user-domain="DISCOVERY" /> <culture-info current-culture="en-US" current-uiculture="en-US" />
</test-results>'

$xml > (Here "Test.xml")
