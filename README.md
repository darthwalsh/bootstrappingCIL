bootstrappingCIL
================

Bootstrapping
-------------

From a Command Prompt at the project root:

    bootstrappingCIL> bscil0\bscil0.exe < bscil1\bscil1.bscil0 > bscil1\bscil1.exe
    bootstrappingCIL> bscil1\bscil1.exe < bscil2\bscil2.bscil1 > bscil2\bscil2.exe
    
And verifying each language can self-host:

    bootstrappingCIL> bscil0\bscil0.exe < bscil0\bscil0.bscil0 > bs0.exe
    bootstrappingCIL> fc /b bscil0\bscil0.exe bs0.exe
    
    bootstrappingCIL> bscil1\bscil1.exe < bscil1\bscil1.bscil1 > bscil1.exe
    bootstrappingCIL> bscil1.exe < bscil1\bscil1.bscil1 > bs1.exe
    bootstrappingCIL> fc /b bscil1.exe bs1.exe


Running Tests
-------------

    .\test\bscil.Tests.ps1

Windows test status: [![Build status](https://ci.appveyor.com/api/projects/status/cnd0aqt66wc98ncm)](https://ci.appveyor.com/project/darthwalsh/bootstrappingcil)

Background
----------

The process of writing and running a .NET program has several steps.

First, a high-level program like C# or VB is compiled to Common Intermediate Language (CIL).
Next, the generated CIL is assembled to a binary Portable Executable (PE) file.
Finally, to run the binary an execution engine converts CIL to native machine code as the program runs.

Common Intermediate Language (CIL) is the assembly language of the .NET framework, and represents the op codes in the executable.
Unlike other assembly languages like x86 or ARM that exactly describe the instructions that will run on the CPU,
 CIL describes operations in a hypothetical virtual machine 
 
"Bootstrapping" is a term used to describe the origin of a compiler for a language, written in that language itself.
While being able to run a C# compiler written in C# may seem like a chicken-and-egg situation, evolution is again the answer.
The solution is to make a very simple tool written in an existing language, and then use that iteratively to produce more advanced tools.

The goal of this project is to write an assembler that transforms CIL assembly files into PE files.
We're not trying to simulate the operations in the execution engine, so producing a valid PE file is the goal. 
Also, the goal of bootstrapping the CIL means each iteration of better tools show move closer to proper CIL, and not add higher-level C# features.

I don't think it is reasonable to ask people interested in this project to just trust some executables off the internet.
For that reason we'll try to limit the number and complexity of any committed binary executables.
From the start, I want to make each program open for review, and include documentation to explain what all the bytes of the program are doing.
But at the same time, .NET is not the right technology to bootstrap to remove all trust dependencies (start from an FPGA if that is your goal).

This should be an educational exploration. Buckle up, and let's get started!

Acknowledgments
---------------

CI testing runs on [AppVeyor](http://www.appveyor.com/) for Windows Cloud testing.

[EMCA-335](http://www.ecma-international.org/publications/files/ECMA-ST/ECMA-335.pdf) describes in great detail the binary file format assemblers must produce.

Visual Studio's ildasm.exe is helpful to view PE files, but this project doesn't copy any code from other tools.

You, for reading!


Future work
-----------

- [ ] Use [Peverify](https://learn.microsoft.com/en-us/dotnet/framework/tools/peverify-exe-peverify-tool) to validate output binary not only runs, but is verifiable. (dotnet core version is [available](https://stackoverflow.com/a/71981768/771768)!)
