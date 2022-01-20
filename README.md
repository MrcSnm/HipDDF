# HipDDF
Hipreme D Data Format. Data format based on the D programming language.

This repository is not update directly. It is an adaptation from the HipDDF inside the [Hipreme Engine](https://github.com/MrcSnm/HipremeEngine). As the Hipreme Engine uses its own standard lib. So, there's
little adaptation to the original version.

## Why should I use it?:

    1. Type safe data format with the D programming language syntax. Defining the data will be more straightforward as there will be no brain context switch.
    2. If you wish to save your data into your binary directly, you could easily adapt your code to accept it as a D source instead.



An example of how a hipddf should look like is:

```d
/**
*   HipDDF sample of how it works. This file is being used as a test too for each supported thing.
*/
int[] testArray_Multi = 
[
    -1,
    -2,
    -3
];

int a = 500;
int b = a;

string multiLineStringTest = "
Lorem ipsum this is really boring.
" //Look! Optional semicolon (maybe only for now)

int lineCheckerTest = __LINE__;
int[] testArray_Single = [1, 4, 30, 90, 99];
string abilityType = "Test helper";

int[string] testAA = [
    "ABC" : 500,
    "Hundred" : 100
];

int[4] testArray_Bounded = [
    10,20,30,40
];
int[10] testArray_Value = 5;
```

For actually using it, just do:

```d
import hipddf;
import std.stdio;

void main()
{
    enum hipddfSample = q{int[50] test = 5;};
    HipDDFObject obj = parseHipDDF(hipddfSample);
    writeln(obj.get!(int[50])("test"));
}
```

## Supported Features:
    - Basic Types
    - Arrays
    - Associative Arrays
    - __FILE__ and __LINE__
    - Assign variable to an existing symbol (order of definition matters)
  
#### Current Version: 0.4

## Planned Features:
    0.2 : Associative array support
    0.3 : __LINE__ and __FILE__(?)
    0.4 : Self reference values
    0.5 : Arithmetic operations
    0.6 : Concatenation support for string and arrays
    1.0 : Aliases 
    1.1 : Struct declarations