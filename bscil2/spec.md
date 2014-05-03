BootStrappingCIL2 Specification
===============================

BSCIL2 is a text file of modified CIL assembly.

The primary goal of this iteration of the language is to be self-documenting. Two features will allow for that.

First, BSCIL won't have any binary characters. 
Binary files don't allow for easy code review in git, so every character in the files needs to be in ASCII.

Second, BSCIL will allow for comments.
For simplicity, instead of having a comment character, the line after the op code will be ignored.

To further simplify this release, all ops will be single characters.
Some ops will be followed by two hexadecimal characters 

Operations
----------

| BSCIL2 op | Byte args |  CIL op  | CIL byte(s)    |
|:---------:|:---------:|:--------:|:--------------:|
|    L      |     1     | ldc.i4.s | 1F __          |
|    D      |     0     | dup      | 25             |
|    P      |     0     | pop      | 26             |
|    B      |     4     | br       | 38 __ __ __ __ |
|    T      |     0     | ret      | 2A             |
|    N      |     1     | bne.s    | 33 __          |
|    A      |     0     | add      | 58             |
|    M      |     0     | mul      | 5A             |
|    R      |     0     | [read]   | 28 01 00 00 06 |
|    W      |     0     | [write]  | 28 02 00 00 06 |
|    F      |     0     | [finish] | 28 03 00 00 06 |

read, write, and finish are the same as in BSCIL1.
In BSICL2, reading and writing bytes are first-class ops.

Grammar
-------

```
<START>   : <LINE> <START>
          :
          
<LINE>    : <OP> <COMMENT> (CR) (LF)
         
<OP>      : L <HEX>
          : D
          : P
          : B <HEX> <HEX> <HEX> <HEX>
          : T
          : N <HEX>
          : A
          : R
          : W
          : F

<HEX>     : (0-9A-E) (0-9A-E)

<COMMENT> : (not LF) <COMMENT>
          :
```

Examples programs
-----------------

### Trivial

```
R and now this is a comment
```

### Adder

```
L35  pushes '5'
LFF  pushes -1
A    adding gives '4'
W    writes '4' to standard output
R
```