# HipDDF
Hipreme D Data Format. Data format based on the D programming language.

This repository is not update directly. It is an adaptation from the HipDDF inside the [Hipreme Engine](https://github.com/MrcSnm/HipremeEngine). As the Hipreme Engine uses its own standard lib. So, there's
little adaptation to the original version.


An example of how a hipddf should look like is:

```d
int[] testArray_Multi = 
[
    -1,
    -2,
    -3
];

int[] testArray_Single = [1, 4, 30, 90, 99];
string abilityType = "Test helper";

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
    - 
#### Current Version: 0.1

## Planned Features:
    0.2 : Associative array support
    0.3 : Data parsing only
    0.4 : Concatenation support for string and arrays
    0.5 : Arithmetic operations
    0.6 : Self reference values
    1.0 : Aliases 
    1.1 : Struct declarations