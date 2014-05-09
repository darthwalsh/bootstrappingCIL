$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = Split-Path -Parent $here
$bscil1exe = Join-Path -Path $root -ChildPath "bscil1\bscil1.exe"
$bscil1bscil1 = Join-Path -Path $root -ChildPath "bscil1\bscil1.bscil1"

Remove-Item "*delete.exe"

Function Compile($exe, $target) {
  # Don't overwrite existing files
  $shortname = (get-childitem -path $target).Name -replace "\.", ""
  $name = Join-Path -Path $here -ChildPath "$($shortname)_$(Get-Random 1000)delete.exe"
  
  cmd /c "$exe < $target > $name"
  $LastExitCode | Should be 0 | Out-Null
  
  return $name
}

Function RunTest($exe, $target, $instream, $expected) {
    $exe = Compile $exe $target
    
    $output = $instream | & $exe
    [string]($output) | Should be $expected
}

Function TestBSCIL1($bscilexe) {
  It "runs trivial" {
    RunTest $bscilexe trivial.bscil1 "" ""
  }
  
  It "runs adder" {
    RunTest $bscilexe adder.bscil1 "" "5"
  }
  
  It "runs echo2" {
    RunTest $bscilexe echo2.bscil1 "hello" "he"
  }
}

Describe "bscil1" {
  TestBSCIL1 $bscil1exe
  
  It "bootstraps" {
    $exe = Compile $bscil1exe $bscil1bscil1
    
    fc.exe /b $bscil1exe $exe
    $LastExitCode | Should be 0
    
    # Redundant, but check that new executable runs
    $exe2 = Compile $exe $bscil1bscil1
    
    fc.exe /b $exe $exe2
    $LastExitCode | Should be 0
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
    $exe = Compile $bscilexe blank.bscil2
    
    $output = & $exe
    [string]($output).Length | Should be 0x52D0
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
}

$bscil2bscil1 = Join-Path -Path $root -ChildPath "bscil2\bscil2.bscil1"
$bscil2bscil2 = Join-Path -Path $root -ChildPath "bscil2\bscil2.bscil2"

Describe "bscil2.bscil1" {
  TestBSCIL2 (Compile $bscil1exe $bscil2bscil1)
}

Describe "bscil2.bscil2" {
  TestBSCIL2 (Compile (Compile $bscil1exe $bscil2bscil1) $bscil2bscil2)
}
