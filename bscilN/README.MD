# bscilN

The end goal with language version N (maybe 5 or so) is to have a full working CIL assembler written in an intermediate language.

To help me get back into the project, I'm taking on the last phase of the project, writing a CIL assembler in CIL. This will also help in determining which language features are needed. (i.e. multiple functions will probably be needed, but is it possible without classes or generics?)

## References

- [CIL grammar like YACC](https://github.com/dotnet/runtime/blob/v6.0.0/src/coreclr/ilasm/prebuilt/asmparse.grammar). 
- [Op code definitions](https://github.com/dotnet/runtime/blob/v6.0.0/src/coreclr/inc/opcode.def)

## TODOs

Explanation of variable TODO categories:

### `TODO(no-reloc-section)`

I'd prefer to remove the `.reloc` section because it seems like noise. If you just set NumberOfSections to 1 that runs successfully on `mono`, but that causes error in `dotnet` Core or Framework:

    An attempt was made to load a program with an incorrect format.

Also setting `BaseRelocationTable` RVA and Size to 0 seems semantically correct, otherwise  `ildasm` chokes on reading the non-existing table.  will correctly parse the PE even with no .reloc section. But that doesn't affect the dotnet error.

Staring at the code for 5 hours, I think the failure happens [here](https://github.com/dotnet/runtime/blob/aec1f696a2bc54884dcbad589111d025267063f9/src/coreclr/vm/peimage.cpp#L481), where *something* didn't load correctly. (If not there, [this blog](https://mattwarren.org/2017/02/07/The-68-things-the-CLR-does-before-executing-a-single-line-of-your-code/) has good documentation of the CLR loading steps.)
  
To understand more, it would help to [enable logging]( https://github.com/steveharter/dotnet_coreclr/blob/b096f349a409c6461bc26e2db841a82125fcf48b/Documentation/project-docs/clr-configuration-knobs.md), using `LogToConsole`. (This needs a DEBUG build of coreclr, or [defining `LOGGING`]( https://github.com/dotnet/runtime/blob/aec1f696a2bc54884dcbad589111d025267063f9/src/coreclr/utilcode/log.cpp#L10) macro variable.)

That would answer questions, like how different `src/` implementations are parsing the PE file:
- Platform Adaptation Layer [coreclr/pal/inc/rt/ntimage.h](https://github.com/dotnet/runtime/blob/2f0341dc46d40b2c7c0654d8afcac9ae417d19c5/src/coreclr/pal/inc/rt/ntimage.h#L185)
- ReadyToRun (like NGEN) [coreclr/inc/readytorun.h](https://github.com/dotnet/runtime/blob/f179b7634370fc9181610624cc095370ec53e072/src/coreclr/inc/readytorun.h#L32)
- mono [mono/mono/utils/mono-proclib.h](https://github.com/dotnet/runtime/blob/2f0341dc46d40b2c7c0654d8afcac9ae417d19c5/src/mono/mono/utils/mono-proclib.h#L130)


 
