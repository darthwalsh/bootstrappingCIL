.assembly extern mscorlib { }
.assembly echo { }

.class BSCIL {
.field private static int32 count
.field private static class [mscorlib]System.IO.Stream input
.field private static class [mscorlib]System.IO.Stream output
.method private hidebysig static int32 read() {
ldsfld class [mscorlib]System.IO.Stream BSCIL::input
callvirt instance int32 [mscorlib]System.IO.Stream::ReadByte()
ret
}

.method private hidebysig static void write(int32 b) {
ldsfld int32 BSCIL::count
ldc.i4.m1
add
stsfld int32 BSCIL::count
ldsfld class [mscorlib]System.IO.Stream BSCIL::output
ldarg.0
conv.u1
callvirt instance void [mscorlib]System.IO.Stream::WriteByte(uint8)
ret
}

.method private hidebysig static void finish() {
ldsfld int32 BSCIL::count      // [count]
 Start:
ldc.i4.m1                      // [-1], [count]
add                            // [count-1]
dup                            // [count-1], [count-1]
ldc.i4.0                       // [0], [count-1], [count-1]
blt.s Done                     // [count-1]
ldc.i4.0                       // [0], [count-1]
call void BSCIL::write(int32)  // [count-1]
br.s Start                     // count-1 is now count
 Done:
pop   
ret   
}     

.method private hidebysig specialname rtspecialname static void .cctor() {
call class [mscorlib]System.IO.Stream [mscorlib]System.Console::OpenStandardInput()
stsfld class [mscorlib]System.IO.Stream BSCIL::input
call class [mscorlib]System.IO.Stream [mscorlib]System.Console::OpenStandardOutput()
stsfld class [mscorlib]System.IO.Stream BSCIL::output
ldc.i4 0x400
stsfld int32 BSCIL::count
ret
}

.method public hidebysig static void  Main() {
.entrypoint
 Start:
call int32 BSCIL::read()
dup
ldc.i4.m1
beq.s Done
call void BSCIL::write(int32)
br.s Start
 Done:
 
call void BSCIL::finish()
ret

nop nop nop nop nop nop nop nop nop nop nop nop nop nop nop nop 
nop nop nop nop nop nop nop nop nop nop nop nop nop nop nop nop 
nop nop nop nop nop nop nop nop nop nop nop nop nop nop nop nop 
nop nop nop nop nop nop nop nop nop nop nop nop nop nop nop nop 
nop nop nop nop nop nop nop nop nop nop nop nop nop nop nop nop 
nop nop nop nop nop nop nop nop nop nop nop nop nop nop nop nop 
nop nop nop nop nop nop nop nop nop nop nop nop nop nop nop nop 
nop nop nop nop nop nop nop nop nop nop nop nop nop nop nop nop 
nop nop nop nop nop nop nop nop nop nop nop nop nop nop nop nop 
nop nop nop nop nop nop nop nop nop nop nop nop nop nop nop nop 
nop nop nop nop nop nop nop nop nop nop nop nop nop nop nop nop 
nop nop nop nop nop nop nop nop nop nop nop nop nop nop nop nop 
nop nop nop nop nop nop nop nop nop nop nop nop nop nop nop nop 
}
}