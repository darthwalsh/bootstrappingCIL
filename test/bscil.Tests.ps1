$ErrorActionPreference = "Stop"

BeforeAll {
  $ILASM_EXE = "C:\Windows\Microsoft.NET\Framework\v4.0.30319\ilasm.exe"
  $PEVERIFY_EXE = "C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.8 Tools\PEVerify.exe"

  $sw = [system.diagnostics.stopwatch]::startNew()
  $here = $PSScriptRoot
  $root = Split-Path -Parent $here

  Function Root($p) {
    Join-Path $root $p
  }

  Function Here($p) {
    Join-Path $here $p
  }

  Function BinDir($p) {
    Here (Join-Path 'bin' $p)
  }

  Function Log($s) {
    Write-Host "$($sw.ElapsedMilliseconds)ms $($s.Replace((Root),''))" -Foreground DarkBlue
  }

  Function CreateRuntimeConfig($name) {
    @{
      runtimeOptions = @{
        framework = @{
          name    = 'Microsoft.NETCore.App'
          version = "7.0.0"
        }
      }
    } | ConvertTo-Json | Set-Content ($name -replace '\.exe$', '.runtimeconfig.json')
  }

  $compileI = 0
  Function Compile($target) {
    $target | Should -Not -BeNullOrEmpty

    # Don't overwrite existing files
    $shortname = ($target | Select-Object -First 1 | Get-ChildItem ).Name -replace '\W', '_'
    Log "shortname $shortname"

    $script:compileI++ # MAYBE use a stable name, then check file write time to reuse binary
    $name = BinDir "$($shortname)_$($script:compileI).exe"
    $compiler = Get-Compiler $target
    $line = "$compiler < $target > $name" # MAYBE sc -raw (powershell destroys binary data in stream)

    if ((Get-Description) -in @("ilasm", "bscilN.bscilN", "bscilN.unit")) {
      $line = "$compiler $target -OUTPUT=$name"
    }
    Log("LINE $line")

    Log "exec compile $compiler $name"
    if (Get-Command cmd -ErrorAction SilentlyContinue) {
      $out = cmd /c $line

      # Helper blurb. In ../bootstrappingCIL_TODO commit todo.txt as a baseline, then if the exe is different you will see it
      $repo_with_todo = $root + '_TODO'
      if ((Test-path $repo_with_todo) -and $shortname -eq 'AddR_bscilN') {
        format-hex $name > (Join-path $repo_with_todo todo.txt)
      }

      if ($LastExitCode -ne 0) {
        foreach ($line in $out) {
          Log $line
        }
        throw "Failed to compile $target"
      }

      $out = & $PEVERIFY_EXE $name
      if ($LastExitCode -ne 0) {
        foreach ($line in $out) {
          Write-Host $line -ForegroundColor Yellow
        }
        throw "Invalid MSIL in $name"
      }
    }
    else {
      if ((Get-Description) -ne "ilasm") { # can remove this hack when bscil0 -> bscil1 -> bscilN
        $line = "dotnet $line"
      }
      
      $out = bash -c $line
      if ($LastExitCode -ne 0) {
        foreach ($line in $out) {
          Log $line
        }
        throw "Failed to compile $target"
      }

      write-host "TODO use PEVERIFY on dotnet core" -ForegroundColor Yellow # https://stackoverflow.com/a/71981768/771768
      CreateRuntimeConfig $name
    }
    
    $LastExitCode | Should -Be 0 -Because "Ran line $line"
    
    $name
  }

  Function RunExe($exe, $instream = "") {
    Log "exec $exe"
    if (Get-Command cmd -ErrorAction SilentlyContinue) { 
      $instream | & $exe 
    }
    else { 
      $instream | & dotnet $exe 
    }
    $LastExitCode | Should -Be 0 -Because "Ran $exe"
  }

  Function RunTest($target, $instream, $expected) {
    $target = Here $target
    $exe = Compile $target
      
    $output = RunExe $exe $instream
    if (-not $output) {
      $output = ""
    }
      
    [string]($output) | Should -Be $expected
  }

  Function Get-Description {
    $____Pester.CurrentBlock.Name
  }

  $script:compilers = @{
    bscil0 = Root "bscil0\bscil0.exe"
    "ilasm" = if ($IsWindows) { $ILASM_EXE } else { "ilasm" }
  }
  $script:compilers["bscilN.unit"] = $script:compilers["ilasm"]

  Function Get-Compiler($target = $null) {
    $moniker = Get-Description
    # MAYBE some logic like this needed so 
    # $name, $ext = $moniker -split '\.'
    # if ($target -and $name -ne ($target -split '\.')[-1]) {
    #   Write-Warning "Unexpected earlier version!"

    #   $prev = $name -replace '\d+', { -1 + [int]$_.Value }
    #   $toolMoniker = "$ext.$name"
    #   throw "TODO somehow make $prev   for mon $moniker tar $target "
    # }

    # if (-not $script:compilers.ContainsKey($moniker)) {
    #   $source = Root (Join-Path $name $moniker)
    #   Log "Creating $moniker using $source"
    #   $script:compilers[$moniker] = Compile $source
    # }

    $val = $script:compilers[$moniker]
    if (-not $val) {
      throw "No compiler for $moniker"
    }
    $val
  }

  New-Item (BinDir) -ItemType Directory -Force
}

Function Add-Compiler() {
  It "compiles next tool" {
    $name, $ext = (Get-Description) -split '\.'
    $ext = $ext ?? $name
    $next = if ($ext -eq $name) {
      $name -replace '\d+', { 1 + [int]$_.Value }
    }
    else {
      $name
    }
    $moniker = "$next.$name"
    $source = Root "$next/$moniker"
    Log "ADD $(Get-Description) Generating $moniker from $source"
    $script:compilers[$moniker] = Compile $source
  }
}

Function Add-CompilerN() {
  It "compiles next tool" {
    $moniker = "bscilN.bscilN"
    if ($script:compilers[$moniker]) { return }
    $sourceDir = Root "bscilN"
    $source = @(Root "bscilN/bscilN.bscilN")
    $source += Get-ChildItem $sourceDir/*.bscilN | ForEach-Object FullName
    Log "ADD $(Get-Description) Generating $moniker from $sourceDir"
    $script:compilers[$moniker] = Compile ($source | Select-Object -Unique)
  }
}

Function Bootstraps() {
  It "bootstraps" {
    $version = (Get-Description) -split '\.' | Select-Object -First 1
    $target = (Root "$version\$version.$version")
    $bootstrapped = Compile $target
    
    Get-Content (Get-Compiler) -Raw | Should -Be (Get-Content $bootstrapped -Raw)
  }
}

Function TestBSCIL0() {
  It "runs trivial" {
    RunTest trivial.bscil0 "" ""
  }
  
  It "runs adder" {
    RunTest adder.bscil0 "" "5"
  }
  
  It "runs echo2" {
    RunTest echo2.bscil0 "hello" "he"
  }
}

Function TestBSCIL1() {
  It "runs trivial" {
    RunTest trivial.bscil1 "" ""
  }
  
  It "runs echo2" {
    RunTest echo2.bscil1 "hello" "he"
  }
  
  It "runs blank" {
    $exe = Compile (Here blank.bscil1)
    
    $output = RunExe $exe
    [string]($output).Length | Should -Be 0x52CD
  }
  
  It "runs heart" {
    RunTest heart.bscil1 "" "<3"
  }
  
  It "runs echoTwice" {
    RunTest echoTwice.bscil1 "abc" "cca"
  }
  
  It "runs math" {
    RunTest math.bscil1 "" "6"
  }
  
  It "runs branches" {
    RunTest branches.bscil1 "" "2456"
  }
}

Function TestBSCIL2() {
  It "runs trivial" {
    RunTest trivial.bscil2 "" ""
  }
  
  It "runs echo2" {
    RunTest echo2.bscil2 "hello" "he"
  }
  
  It "runs blank" {
    $exe = Compile (Here blank.bscil2)
    
    $output = RunExe $exe
    [string]($output).Length | Should -Be 0x52CD
  }
  
  It "runs heart" {
    RunTest heart.bscil2 "" "<3"
  }
  
  It "runs echoTwice" {
    RunTest echoTwice.bscil2 "abc" "cca"
  }
  
  It "runs math" {
    RunTest math.bscil2 "" "6"
  }
  
  It "runs branches" {
    RunTest branches.bscil2 "" "2456"
  }
  
  It "runs mem" {
    RunTest mem.bscil2 "4" "34"
  }
}

Function TestBSCILN() {
  # It "runs trivial" {
  #   RunTest trivial.bscilN "" ""
  # }
  
  # It "runs echo2" {
  #   RunTest echo2.bscilN "hello" "he"
  # }

  It "runs AddR" {
    RunTest AddR.bscilN "" "Hello, World!44" #TODO
  }
}

# Describe "bscil0" {
#   TestBSCIL0
#   Bootstraps
#   Add-Compiler
# }

# Describe "bscil1.bscil0" {
#   TestBSCIL1
#   Add-Compiler
# }

# Describe "bscil1.bscil1" {
#   TestBSCIL1
#   Bootstraps
#   Add-Compiler
# }

# Describe "bscil2.bscil1" {
#   TestBSCIL2
# }

Describe "ilasm" {
  # TestBSCILN # Re-enable if writing new test cases
  Add-CompilerN
}

Describe "bscilN.bscilN" {
  TestBSCILN
}

Describe "bscilN.unit" {
  Add-CompilerN
  It "sets up DLL for unit test" {
    $bscilN = $script:compilers["bscilN.bscilN"]
    Copy-Item $bscilN (BinDir "A.dll")
  }
  It "dotnet test" {
    $dotnetOut = dotnet test (Here bscilN)
    if ($LastExitCode) {
      foreach ($line in $dotnetOut) {
        Write-Host $line -ForegroundColor DarkRed
      }
    }
    $LastExitCode | Should -Be 0 -Because "dotnet test exit code"
  }
}
