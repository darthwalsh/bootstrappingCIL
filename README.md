bootstrappingCIL
================

Bootstrapping the Common Intermediate Language

Common Intermediate Language (CIL) is the assembly language of the .NET framework.
Unlike other compiled programming languages that transform high-level code into the exact bytes that will run on the CPU,
 CIL describes operations in a hypothetical virtual machine.
 
"Bootstrapping" is a common term used to describe the origin of a compiler for a language, written in that language itself.
While this may seem like a chicken-and-egg situation, evolution is again the answer.
The solution is to make a very simple tool written directly in binary, and then use that iteratively to produce more advanced tools.

The process of writing and running a .NET program has several steps.

First, a high level program like C# or VB is compiled to CIL.
Next, the generated CIL is assembled to a binary Portable Executable (PE) file. (This is the transformation to bootstrap.)
Finally, to run the binary an execution engine converts CIL to native machine code as the program runs.

To be clear, we'll consider the PE file to be the end goal, and we're not trying to simulate the operations in the execution engine. Also, the goal of bootstrapping the CIL means each iteration of better tools show move closer to proper CIL, and not to a higher-level.

I don't think it is reasonable to ask people interested in this project to just trust some executables off the internet.
For that reason we'll try to limit the number and complexity of any committed binary executables.
From the start, I want to make each program open for review, and include documentation to explain what all the bytes of the program are doing.
But at the same time, .NET is not the right technology to bootstrap to remove all trust dependencies (start from an FPGA if that is your goal).

This should be an education exploration. Buckle up, and let's get started!
