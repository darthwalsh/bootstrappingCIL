$ErrorActionPreference = "Stop"

$sw = [system.diagnostics.stopwatch]::startNew()

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = Split-Path -Parent $here

Function Root($p) {
  Join-Path $root $p
}

Function Here($p) {
  Join-Path $here $p
}

Function Bin($p) {
  Here (Join-Path 'bin' $p)
}

Function Should-Be($expected) { 
  Process { 
    if ($_ -ne $expected) {
      Get-PSCallStack | ForEach-Object {
        Write-Warning (@($_.Command.PadLeft(16), ($_.Location -replace ' line ', '') , ($_.Arguments -replace '\s+', ' ')) -join ' ')
      }
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
  

  if ($e) {
    $color = "Red"
    $success = "-"
    ++$script:failed
  }
  else {
    $color = "DarkGreen"
    $success = "+"
    ++$script:passed
  }
  
  Write-Host "[$success] $name $($time)ms" -Foreground $color
  if ($e) {
    Write-Host $e.ToString() -Foreground $color
    throw ''
  }
}

Function Describe($name, $action) {
  Write-Host "Describing $name" -Foreground "magenta"
  & $action
}

Function CreateRuntimeConfig($name) {
    @{
      runtimeOptions = @{
        framework = @{
          name    = 'Microsoft.NETCore.App'
          version = "5.0.0"
        }
      }
    } | ConvertTo-Json | Set-Content ($name -replace '\.exe$', '.runtimeconfig.json')
}

$compileI = 0
Function Compile($exe, $target) {
  # Don't overwrite existing files
  $shortname = (Get-ChildItem $target).Name -replace '\W', '_'

  $script:compileI++
  $name = Bin "$($shortname)_$($script:compileI).exe"
  $line = "$exe < $target > $name" # powershell destroys binary data in stream

  if (Get-Command cmd -ErrorAction SilentlyContinue) {
    cmd /c $line
  }
  else {
    CreateRuntimeConfig $exe
    bash -c "dotnet $line"
    CreateRuntimeConfig $name
  }
  
  $LastExitCode | Should-Be 0
  
  $name
}

Function RunExe($exe, $instream = "") {
  if (Get-Command cmd -ErrorAction SilentlyContinue) { 
    $instream | & $exe 
  }
  else { 
    $instream | & dotnet $exe 
  }
}

Function RunTest($exe, $target, $instream, $expected) {
  $target = Here $target
  $exe = Compile $exe $target
    
  $output = RunExe $exe $instream
  if ($output -eq $null) {
    $output = ""
  }
    
  [string]($output) | Should-Be $expected
}

Function Bootstraps($bscilexe, $target) {
  It "bootstraps" {
    $bootstrapped = Compile $bscilexe $target
    
    Get-Content $bscilexe -Raw | Should-Be (Get-Content $bootstrapped -Raw)
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
    
    $output = RunExe $exe
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
    RunTest $bscilexe echo2.bscil2 "hello" "he"
  }
  
  It "runs blank" {
    $exe = Compile $bscilexe (Here blank.bscil2)
    
    $output = RunExe $exe
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

if (Test-Path (Bin)) {
  Remove-Item (Bin) -Recurse -Force
}
New-Item (Bin) -ItemType Directory -Force

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

exit $failed
