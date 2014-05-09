$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = Split-Path -Parent $here

Function Root($p) {
  return Join-Path -Path $root -ChildPath $p
}

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

Function Bootstraps($bscilexe, $target) {
  It "bootstraps" {
    $bootstrapped = Compile $bscilexe $target
    
    fc.exe /b $bscilexe $bootstrapped
    $LastExitCode | Should be 0
  }
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

Remove-Item "*delete.exe" # Pretty safe to delete files ending in delete?

$bscil1exe = Root "bscil1\bscil1.exe"

Describe "bscil1" {
  TestBSCIL1 $bscil1exe
  
  Bootstraps $bscil1exe (Root "bscil1\bscil1.bscil1")
}

$bscil2exe = Compile $bscil1exe (Root "bscil2\bscil2.bscil1")

Describe "bscil2.bscil1" {
  TestBSCIL2 $bscil2exe 
}

Describe "bscil2.bscil2" {
  $anotherbscil2 = Compile $bscil2exe (Root "bscil2\bscil2.bscil2")
  TestBSCIL2 $anotherbscil2
  
  Bootstraps $anotherbscil2 (Root "bscil2\bscil2.bscil2")
}
