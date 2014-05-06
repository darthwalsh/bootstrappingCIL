$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = Split-Path -Parent $here
$bscil1exe = Join-Path -Path $root -ChildPath "bscil1\bscil1.exe"
$bscil1bscil1 = Join-Path -Path $root -ChildPath "bscil1\bscil1.bscil1"
$bscil2bscil1 = Join-Path -Path $root -ChildPath "bscil2\bscil2.bscil1"

Function Compile($exe, $target) {
  # Don't overwrite existing files
  $name = Join-Path -Path $here -ChildPath "$(Get-Random 10000000)delete.exe"
  
  cmd /c "$exe < $target > $name"
  $LastExitCode | Should be 0 | Out-Null
  
  return $name
}

Describe "bscil1" {
  Remove-Item "*delete.exe"
 
  It "runs trivial" {
    $exe = Compile $bscil1exe trivial.bscil1
    [string](& $exe) | Should be ""
  }
  
  It "runs adder" {
    $exe = Compile $bscil1exe adder.bscil1
    [string](& $exe) | Should be "5"
  }
  
  It "runs echo2" {
    $exe = Compile $bscil1exe echo2.bscil1
    
    $output = "hello" | & $exe
    [string]($output) | Should be "he"
  }
  
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

Describe "bscil2" {
  $bscil2exe = Compile $bscil1exe $bscil2bscil1

  It "runs trivial" {
    $exe = Compile $bscil2exe trivial.bscil2
    [string](& $exe) | Should be ""
  }
  
  It "runs echo2" {
    $exe = Compile $bscil2exe echo2.bscil2
    
    $output = "hello" | & $exe
    [string]($output) | Should be "he"
  }
  
  It "runs blank" {
    $exe = Compile $bscil2exe blank.bscil2
    
    $output = & $exe
    [string]($output).Length | Should be 0x52D0
  }
  
  It "runs heart" {
    $exe = Compile $bscil2exe heart.bscil2
    [string](& $exe) | Should be "<3"
  }
}