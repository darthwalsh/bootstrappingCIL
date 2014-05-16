BootStrappingCIL1 Design
========================

Language1 is designed to still be rather simple, but address several shortcomings of BSCIL0.

Only the minimal number of op codes are supported, for simplicity.
Branches addresses and load constants are taken in as two hex characters, for simplicity.
Op codes are all single letters, and must be capital letters.
One unexpected input is encountered, the rest of the program is ignored.

As with BSCIL1, a regex can produce most of the literal print code by copying the desired output as hex bytes, and then replaced with the regex:

```
/([A-F\d]{2})\s*/L$1\r\nW\r\n/g
```

For example, to print the bytes 00 6F 75 74 you want the BSCIL1:
L00
W
L6F
W
L75
W
L74
W
