module hipddf.types;
import std.traits:isArray;

import hipddf.parser:
    parserVarType,
    parserVarValue,
    parserVarSymbol,
    parserIsVarArray,
    parserVarLength,
    parserObjSymbol,
    parserObjHasVar,
    parserObjGet;


struct _HipDDFVar
{
    string type() const {return parserVarType(cast(void*)&this);}
    string value() const {return parserVarValue(cast(void*)&this);}
    string symbol() const {return parserVarSymbol(cast(void*)&this);}
    bool isArray() const {return parserIsVarArray(cast(void*)&this);}
    uint length() const {return parserVarLength(cast(void*)&this);}
    string toString() const {return type~" "~symbol~" = "~value;}
}
alias HipDDFVar = _HipDDFVar*;


struct _HipDDFObject
{
    string symbol() const {return parserObjSymbol(cast(void*)&this);}
    bool hasVar(string name) const {return parserObjHasVar(cast(void*)&this, name);}
    T get(T)(string name) const {return parserObjGet!T(cast(void*)&this, name);}
}
alias HipDDFObject = _HipDDFObject*;