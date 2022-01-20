module test;
version(HipDDFTest):
import hipddf;
import std.stdio;

struct Vector2
{
    int x;
    int y;
}

void main()
{
    HipDDFObject obj = parseHipDDF(HipDDFSample);
    writeln(obj.get!(string)("multiLineStringTest"));
    writeln(obj.get!(int[string])("testAA"));
    writeln(obj.get!(int)("lineCheckerTest"));
    writeln(obj.get!(string)("filename"));
    writeln(obj.get!(Vector2)("v"));
}