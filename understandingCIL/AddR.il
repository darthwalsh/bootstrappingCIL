.assembly extern mscorlib {}
.assembly World {}

.class Hello {
.method static void Main() {
.entrypoint                                                   // Main isn't automatically the entry method
ldstr "Hello, World!"                                         // Stack: "Hello, World!", [further down]
ldc.i4.s 44                                                   // Stack: 44, "Hello, World!", [further down]
box [mscorlib]System.Int32                                    // Stack: {}->44, "Hello, World!", [further down]
call string [mscorlib]System.String::Concat(object, object)   // Stack: "Hello, World!44", [further down]
call void [mscorlib]System.Console::WriteLine(string)         // Stack: [further down]
ret
}
}