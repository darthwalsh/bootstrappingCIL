BootStrappingCIL2 Specification

BSCIL2 is a text file of modified CIL assembly.

The primary goal of the language is to be self-documenting. Two features will allow for that.

First, BSCIL won't have any binary characters. 
Binary files don't allow for easy code review in git, so every character in the files needs to be in ASCII.

Second, BSCIL will allow for comments.
For simplicity, instead of having a comment character, the line after the op code will be ignored.

To further simplify this language, all ops will be single characters.

BSCIL2 op code 
p pop

BR


//TODO ops and grammar to follow
