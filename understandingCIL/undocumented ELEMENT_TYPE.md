`ELEMENT_TYPE`` is definied in [ECMA-335 II.23.1.16](https://github.com/stakx/ecma-335/blob/1bb96e3992a4d3a4915c97189d291e254dd40a15/docs/ii.23.1.16-element-types-used-in-signatures.md)
skips over defintions for values 0x17 and 0x1A. 

[`dnlib`](https://github.com/0xd4d/dnlib/blob/34267646667b97717067c9f408c2b6333f438331/src/DotNet/ElementType.cs#L54-L61) has some references to these, but better is the [comment in dotnet runtime](https://github.com/dotnet/runtime/blob/7ac5caf91252c6d6689351d436aa6c118339e95b/src/coreclr/inc/corpriv.h#L247):
```
// Obsoleted ELEMENT_TYPE values which are not supported anymore.
// They are not part of CLI ECMA spec, they were only experimental before v1.0 RTM.
// They are needed for indexing arrays initialized using file:corTypeInfo.h
//    0x17 ... VALUEARRAY <type> <bound>
//    0x1a ... CPU native floating-point type
``````
