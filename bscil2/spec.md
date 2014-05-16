BootStrappingCIL2 Specification
===============================

BSCIL1 is a lot easier to read than binary, but it's still rather hard to use.
Making any changes requires recomputing branch targets--which is where labels come in--but enabling labels has several challenges.

The assembler will need to take multiple passes, because forward jump targets aren't known right away.
A new method will track the current byte address in the output bytes.
Another new method will revert the position in the input file stream, to allow multiple passes.

The stack won't be a very good storage solution to keep track of all the branch labels.
Declaring method local variables would work, but ops to allocate and use blocks of local memory allows for more flexibility.
A local variable will then be used to hold the native address of this block of memory.

Another enhancement will be to remove the need of ASCII tables.
An alternative syntax for loading constants will take a literal character.
The old hex encoding will continue to work so non-text literals aren't needed.

Ops will continue to be single characters.
lowercase characters will now indicate meta ops

Operations
----------

//TODO
| BSCIL2 op | Byte args |  CIL op  | CIL byte(s)    |
|:---------:|:---------:|:--------:|:--------------:|
|    L      |     1     | ldc.i4.s | 1F __          |
|    D      |     0     | dup      | 25             |
|    P      |     0     | pop      | 26             |
|    T      |     0     | ret      | 2A             |
|    E      |     1     | blt.s    | 32 __          |
|    N      |     1     | bne.s    | 33 __          |
|    B      |     4     | br       | 38 __ __ __ __ |
|    A      |     0     | add      | 58             |
|    M      |     0     | mul      | 5A             |
|    r      |     0     | [read]   | 28 01 00 00 06 |
|    w      |     0     | [write]  | 28 02 00 00 06 |
|    f      |     0     | [finish] | 28 03 00 00 06 |

read, write, and finish are the same as in BSCIL1.
In BSICL1, reading and writing bytes are first-class ops.

Grammar
-------

```
<START>   : <LINE> <START>
          :
          
<LINE>    : <OP> <COMMENT> (CR) (LF)
         
<OP>      : L <HEX>
          : L <LITERAL>
          : D
          : P
          : T
          : E <HEX>
          : N <HEX>
          : B <HEX> <HEX> <HEX> <HEX>
          : A
          : r
          : w
          : f

<HEX>     : (0-9A-E) (0-9A-E)

<LITERAL> : '(any ASCII character)

<COMMENT> : (not LF) <COMMENT>
          :
```

Example programs
----------------

*Remember the last line needs to end with a LF*

### Adder

```
L'5  pushes '5'
LFF  pushes -1
A    adding gives '4'
w    writes '4' to standard output
r
```

//TOOD memory aloc, output position, input byte count
