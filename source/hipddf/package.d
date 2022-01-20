module hipddf;
/** 
 * HipDDF = Hipreme D Data Format, based on the D syntax 
 *
 *  Version: 0.3:
 *      - Supports basic types, and arrays.
 *      - Associative array support
 *      - __FILE__ and __LINE__ keywords
 *
 *  Planned to future:
 *      1.0 : Data parsing only
 *      1.1 : Concatenation support for string and arrays
 *      1.2 : Arithmetic operations
 *      1.3 : Self reference values
 *      1.4 : Aliases 
 */


public import hipddf.parser : parseHipDDF;
public import hipddf.types;


enum HipDDFSample = q{
    /**
    *   HipDDF sample of how it works. This file is being used as a test too for each supported thing.
    */
    int[] testArray_Multi = 
    [
        -1,
        -2,
        -3
    ];

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
};
