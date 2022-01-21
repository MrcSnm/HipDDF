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
struct Vector2
{
    int a;
    int b;
}


Vector2[] vArr = [
    Vector2(50, 100),
    Vector2(400, 300)
];
Vector2[] vArr2 = [
    {b: 350, a: 100},
    {a: 400,b: 300}
];

int[] testArray_Multi = 
[
    -1,
    -2,
    -3
];

string filename = __FILE__;

int a = 500;
int b = a;

Vector2 v = Vector2(500, 200);
Vector2 v2 = {a : 3000, b : 5000}
Vector2 v3 = v;

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

Vector2[string] testAAStruc = [
    "hello" : Vector2(50, 100),
    "world" : Vector2(200, 300)
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
    - Define structs and assign them
    - Struct literals
    - Associative array with structs
    - Array of structs
  
#### Current Version: 1.0

## Planned Features:
    0.2 : Associative array support
    0.3 : __LINE__ and __FILE__(?)
    0.4 : Self reference values
    0.5 : Structs definitions
    1.0 : Struct lierals, associative array, array of structs
    1.1 : Array of arrays
    1.2 : Arithmetic operations
    1.3 : Concatenation support for string and arrays