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

| BSCIL2 op | Byte args |  CIL op  | CIL byte(s)       |
|:---------:|:---------:|:--------:|:-----------------:|
|    l      |     1     | ldc.i4.s |       1F          |
|    d      |     0     | dup      |       25          |
|    p      |     0     | pop      |       26          |
|    b      |     1     | br.s     |       2B          |
|    t      |     0     | ret      |       2A          |
|    n      |     1     | bne.s    |       33          |
|    a      |     0     | add      |       58          |
|    r      |     0     | [read]   | 28 01 00 00 00 06 |
|    w      |     0     | [write]  | 28 02 00 00 00 06 |
|    f      |     0     | [finish] | 28 03 00 00 00 06 |

read, write, and finish are the same as in BSCIL1.
In BSICL2, reading and writing bytes are first-class ops.

Grammar
-------

```
<START>   : <LINE> <START>
          :
          
<LINE>    : <OP> <COMMENT> (CR) (LF)
         
<OP>      : l <HEX>
          : d
          : p
          : b <HEX>
          : t
          : n <HEX>
          : a
          : r
          : w
          : f

<HEX>     : (0-9A-E) (0-9A-E)

<COMMENT> : (not LF) <COMMENT>
          :
```

Examples programs
-----------------

### Trivial

```
r and now this is a comment
```

### Adder

```
l35  pushes '5'
lFF  pushes -1
a    adding gives '4'
w    writes '4' to standard output
r
```