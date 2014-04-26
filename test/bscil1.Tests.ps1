$bscil = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$bscil1 = Join-Path -Path $bscil -ChildPath "bscil1\bscil1.exe"

Describe "bscil1" {
  It "runs trivial" {
    If (Test-Path ./trivial.exe) {
	  Remove-Item ./trivial.exe
    }
    
    cmd /c "$bscil1 < trivial.bscil1 > trivial.exe"
    
    [string](./trivial.exe) | Should be ""
  }
  
  It "runs adder" {
    If (Test-Path ./adder.exe) {
	  Remove-Item ./adder.exe
    }
    
    cmd /c "$bscil1 < adder.bscil1 > adder.exe"
    
    [string](./adder.exe) | Should be "5"
  }
}