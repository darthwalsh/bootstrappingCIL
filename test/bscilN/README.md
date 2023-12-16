# Unit tests for BSCIL N

Test project can be written in C#. The classes in bscilN need to be public to be unit-tested.

Requires the bscil N compiled into A.dll. See [bscil.Tests.ps1](..\bscil.Tests.ps1) `Describe "bscilN.unit"` which uses ilasm against the .bscilN source files then copies the binary to A.dll. (The name is required because the test project tries to load assembly "A" ignoring the actual file name used. See [StackOverflow](https://stackoverflow.com/a/77664549/771768).)

Building and running tests using the C# features of vscode is supported, but it will not rebuild the bscilN library. Use the powershell tests script to do that.

Debugging is supported, but there's no way to step into the CIL source code.
