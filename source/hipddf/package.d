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

    /**
    *   HipDDF sample of how it works. This file is being used as a test too for each supported thing.
    */
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

    // int[][] testMultiArr = [
    //     [1, 2, 3],
    //     [3, 2, 1]
    // ];

    Vector2[string] testAAStruc = [
        "hello" : Vector2(50, 100),
        "world" : Vector2(200, 300)
    ];


    int[4] testArray_Bounded = [
        10,20,30,40
    ];
    int[10] testArray_Value = 5;
};
