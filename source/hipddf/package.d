module hipddf;
/** 
 * HipDDF = Hipreme D Data Format, based on the D syntax 
 *
 *  Version: 0.1:
 *      - Supports basic types, and initial support to array.
 *
 *  Planned to future:
 *      0.2 : Associative array support
 *      1.0 : Data parsing only
 *      1.1 : Concatenation support for string and arrays
 *      1.2 : Arithmetic operations
 *      1.3 : Self reference values
 *      1.4 : Aliases 
 */


public import hipddf.parser : parseHipDDF;
public import hipddf.types;


enum HipDDFSample = q{
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
};
