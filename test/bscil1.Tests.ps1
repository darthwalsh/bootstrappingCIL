$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$bscil1exe = Join-Path -Path $root -ChildPath "bscil1\bscil1.exe"
$bscil1bscil1 = Join-Path -Path $root -ChildPath "bscil1\bscil1.bscil1"

Function Compile($exe, $target) {
  If (Test-Path ./the.exe) {
    Remove-Item ./the.exe
  }  
  
  cmd /c "$exe < $target > the.exe"
  $LastExitCode | Should be 0
}

Describe "bscil1" {
  It "runs trivial" {
    Compile $bscil1exe trivial.bscil1
    [string](./the.exe) | Should be ""
  }
  
  It "runs adder" {
    Compile $bscil1exe adder.bscil1
    [string](./the.exe) | Should be "5"
  }
  
  It "bootstraps" {
    Compile $bscil1exe $bscil1bscil1
    
    fc.exe /b $bscil1exe the.exe
    $LastExitCode | Should be 0
  }
}