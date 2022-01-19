module hipddf.parser;
import hipddf.types;
import std.conv: to;


enum HipDDFTokenType
{
    assignment,
    comma,
    semicolon,
    openParenthesis,
    closeParenthesis,
    openSquareBrackets,
    closeSquareBrackets,
    openCurlyBrackets,
    closeCurlyBrackets,
    endOfStream,
    symbol,
    stringLiteral,
    numberLiteral,
    unknown
}

struct HipDDFToken
{
    string str;
    HipDDFTokenType type;

    string toString()
    {
        string T;
        swt: final switch(type)
        {
            static foreach(m; __traits(allMembers, HipDDFTokenType))
            {
                case __traits(getMember, HipDDFTokenType, m):
                    T = m.stringof;
                    break swt;
            }
        }
        return str~" ("~T~")";
    }
}

struct HipDDFTokenizer
{
    string str;
    ulong pos;

    /** Returns str[pos] */
    pragma(inline) @nogc nothrow @safe char get(){return str[pos];}
    /** Returns str[pos+1], used for not needing to access every time its members */
    pragma(inline) @nogc nothrow @safe char next(){return str[pos+1];}
    /** Returns str.length - pos */
    pragma(inline) @nogc nothrow @safe int restLength(){return cast(int)(str.length - pos);}


}

nothrow @safe @nogc
private void advanceWhitespace(HipDDFTokenizer* tokenizer)
{
    while(tokenizer.restLength > 0)
    {
        if(isWhitespace(tokenizer.get))
            tokenizer.pos++;
        else if(tokenizer.get == '/' && tokenizer.restLength > 1 && tokenizer.get == '/')
        {
            while(!isEndOfLine(tokenizer.get))
                tokenizer.pos++;
        }
        else if(tokenizer.get == '/' && tokenizer.restLength > 1 && (tokenizer.next == '*' || tokenizer.next == '+'))
        {
            tokenizer.pos+= 2;
            while(tokenizer.restLength && 
            !((tokenizer.get == '*' || tokenizer.get == '+') && (tokenizer.restLength > 1 && tokenizer.next == '/')))
            {
                tokenizer.pos++;
            }
            tokenizer.pos+= 2;
        }
        else
            break;
    }
}

HipDDFToken getToken(HipDDFTokenizer* tokenizer)
{
    HipDDFToken ret;
    advanceWhitespace(tokenizer);
    if(tokenizer.pos == tokenizer.str.length)
        return HipDDFToken("", HipDDFTokenType.endOfStream);
    char C = tokenizer.get;
    ulong start = tokenizer.pos;
    tokenizer.pos++;

    switch(C)
    {
        case '=': {ret.type = HipDDFTokenType.assignment; break;}
        case ',': {ret.type = HipDDFTokenType.comma; break;}
        case ';': {ret.type = HipDDFTokenType.semicolon; break;}
        case '(': {ret.type = HipDDFTokenType.openParenthesis; break;}
        case ')': {ret.type = HipDDFTokenType.openParenthesis; break;}
        case '[': {ret.type = HipDDFTokenType.openSquareBrackets; break;}
        case ']': {ret.type = HipDDFTokenType.closeSquareBrackets; break;}
        case '{': {ret.type = HipDDFTokenType.openCurlyBrackets; break;}
        case '}': {ret.type = HipDDFTokenType.closeCurlyBrackets; break;}
        case '\0': {ret.type = HipDDFTokenType.endOfStream; break;}
        case '"':

            while(tokenizer.restLength && tokenizer.get != '"')
            {
                if(tokenizer.get == '\\')
                    tokenizer.pos++;
                tokenizer.pos++;
            }
            tokenizer.pos++; //Advance the '"'
            ret.str = tokenizer.str[start..tokenizer.pos];
            ret.type = HipDDFTokenType.stringLiteral;
            break;
        default:
            if(isNumeric(C)) //Check numeric literal
            {
                while(tokenizer.get && isNumeric(tokenizer.get))
                    tokenizer.pos++;
                ret.str = tokenizer.str[start..tokenizer.pos];
                ret.type = HipDDFTokenType.numberLiteral;
            }
            else if(isAlpha(C)) //Check symbol
            {
                while(tokenizer.get.isNumeric || tokenizer.get.isAlpha || tokenizer.get =='_')
                    tokenizer.pos++;
                ret.str = tokenizer.str[start..tokenizer.pos];
                ret.type = HipDDFTokenType.symbol;
            }
            else
            {
                ret.type = HipDDFTokenType.unknown;
                ret.str = ""~to!string((cast(int)C));
            }


    }

    return ret;
}

/**
*   This state must be used as a cyclic state for parsing it correctly.
*/
private enum HipDDFState
{
    type,
    symbol,
    assignment
}

/**
*   It must always find in the following order:
*   1: Type
*   2: Symbol
*   3: Assignment
*   4: Data
*   By following this order, the data format will be really simple to follow.
*/
HipDDFObject parseHipDDF(string hdf)
{
    HipDDFObjectInternal* obj = new HipDDFObjectInternal("");
    HipDDFTokenizer tokenizer;
    tokenizer.str = hdf;

    HipDDFToken tk = HipDDFToken("", HipDDFTokenType.unknown);
    HipDDFState state = HipDDFState.type;
    tk = getToken(&tokenizer);

    HipDDFVarInternal variable;
    HipDDFVarInternal lastVar;
    
    while(tk.type != HipDDFTokenType.endOfStream)
    {
        final switch(state)
        {
            case HipDDFState.type:
                //Ask for symbol to be used as a type
                tk = parseType(variable, tk, &tokenizer);
                state = HipDDFState.symbol;
                break;
            case HipDDFState.symbol: //No parsing should be required for the symbol.
                variable.symbol = tk.str;
                state = HipDDFState.assignment;
                assert(requireToken(&tokenizer, HipDDFTokenType.assignment, tk), "Expected variable assignment after the symbol '"~tk.toString);
                break;
            case HipDDFState.assignment:
                tk = parseAssignment(variable, tk, &tokenizer);
                obj.variables[variable.symbol] = variable;
                lastVar = variable;
                variable = HipDDFVarInternal.init;
                state = HipDDFState.type;
                break;
        }
    }
    return cast(HipDDFObject)obj;
}


HipDDFToken parseAssignment(ref HipDDFVarInternal variable, HipDDFToken token, HipDDFTokenizer* tokenizer)
{
    assert(token.type == HipDDFTokenType.assignment, "Tried to parse a non assigment token: "~token.toString);
    for(;;)
    {
        token = getToken(tokenizer);
        switch(token.type)
        {
            case HipDDFTokenType.stringLiteral:
            case HipDDFTokenType.numberLiteral:
                variable.value = token.str;
                if(token.type == HipDDFTokenType.stringLiteral)
                    variable.length = cast(uint)token.str.length;
                token = findToken(tokenizer,  HipDDFTokenType.symbol);
                return token;
            case HipDDFTokenType.openSquareBrackets:
                variable.value = "[";
                token = getToken(tokenizer);
                int arrayCount = 0;
                while(
                    token.type.isLiteral || 
                    token.type == HipDDFTokenType.comma )
                {
                    if(token.type.isLiteral)
                    {
                        variable.value~= token.str;
                        arrayCount++;
                    }
                    else if(token.type == HipDDFTokenType.comma)
                        variable.value~= ",";
                    token = getToken(tokenizer);
                }
                variable.length = arrayCount;
                assert(token.type == HipDDFTokenType.closeSquareBrackets, "Expected ], but received "~token.toString~
                " on variable "~variable.symbol);
                variable.value~="]";
                token = findToken(tokenizer, HipDDFTokenType.symbol);

                return token;
            default: assert(0,  "Unexpected token after assignment: "~token.toString);
        }
    }
    assert(0, "Unknown error occurred for token "~token.toString);
}

/**
*   The token passed is assumed to contain the initial type symbol.
*   It will finish parsing by checking if it is an array, and (futurely) an associative array
*/
HipDDFToken parseType(ref HipDDFVarInternal variable, HipDDFToken token, HipDDFTokenizer* tokenizer)
{
    assert(token.type == HipDDFTokenType.symbol, "Tried to parse a non type token: "~token.toString);
    variable.type = token.str;
    for(;;)
    {
        token = getToken(tokenizer);
        switch(token.type)
        {
            case HipDDFTokenType.openSquareBrackets:
                token = getToken(tokenizer);
                if(token.type == HipDDFTokenType.closeSquareBrackets)
                {
                    variable.type~= "[]";
                    variable.isArray = true;
                }
                else if(token.type == HipDDFTokenType.numberLiteral)
                {
                    variable.type~= "["~token.str;
                    assert(requireToken(tokenizer, HipDDFTokenType.closeSquareBrackets, token), "Expected ], received "~token.toString);
                    variable.type~="]";
                    variable.isArray = true;
                    variable.length = to!uint(token.str);
                }
                assert(token.type == HipDDFTokenType.closeSquareBrackets, "Expected ], received "~token.toString);
                assert(requireToken(tokenizer, HipDDFTokenType.symbol, token), "Expected a variable name, received "~token.toString);
                return token;
            case HipDDFTokenType.symbol:
                return token;
            default: 
                assert(0, "Error occurred with token " ~ token.toString);
        }
    }
    assert(0, "Unknown error occurred: "~token.toString);
}


private HipDDFToken findToken(HipDDFTokenizer* tokenizer, HipDDFTokenType type)
{
    HipDDFToken tk;
    while(tokenizer.restLength > 0)
    {
        tk = getToken(tokenizer);
        if(tk.type == type || tk.type == HipDDFTokenType.endOfStream)
            return tk;
    }
    return HipDDFToken("", HipDDFTokenType.endOfStream);
}

pragma(inline) bool isLiteral(HipDDFTokenType type)
{
    return type == HipDDFTokenType.numberLiteral || type == HipDDFTokenType.stringLiteral;
}
/**
*   Mainly a syntax creator
*/
private pragma(inline) bool requireToken(HipDDFTokenizer* tokenizer, HipDDFTokenType type, out HipDDFToken token)
{
    token = getToken(tokenizer);
    if(token.type != type)
        return false;
    return true;
}

struct HipDDFVarInternal
{
    string type;
    string value;
    string symbol;
    bool isArray;
    uint length;
    pure string toString() const {return type~" "~symbol~" = "~value;}
}

struct HipDDFObjectInternal
{
    string symbol;
    HipDDFVarInternal[string] variables;
}


pragma(inline) bool isAlpha(char c) pure nothrow @safe @nogc{return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z');}
pragma(inline) bool isEndOfLine(char c) pure nothrow @safe @nogc{return c == '\n' || c == '\r';}
pragma(inline) bool isNumeric(char c) pure nothrow @safe @nogc{return (c >= '0' && c <= '9') || (c == '-');}
pragma(inline) bool isWhitespace(char c) pure nothrow @safe @nogc{return (c == ' ' || c == '\t' || c.isEndOfLine);}

pure
{
    //Var value
    string parserVarType(const(void*) hddfvar){return (cast(HipDDFVarInternal*)hddfvar).type;}
    string parserVarValue(const(void*) hddfvar){return (cast(HipDDFVarInternal*)hddfvar).value;}
    string parserVarSymbol(const(void*) hddfvar){return (cast(HipDDFVarInternal*)hddfvar).symbol;}
    bool parserIsVarArray(const(void*) hddfvar){return (cast(HipDDFVarInternal*)hddfvar).isArray;}
    uint parserVarLength(const(void*) hddfvar){return (cast(HipDDFVarInternal*)hddfvar).length;}

    string parserObjSymbol(const(void*) hddfobj){return (cast(HipDDFObjectInternal*)hddfobj).symbol;}

    //Object
    bool parserObjHasVar(const(void*) hddfobj, string name)
    {
        auto obj = cast(HipDDFObjectInternal*)hddfobj;
        return (name in obj.variables) is null;
    }
    T parserObjGet(T)(const(void*)hddfobj, string name)
    {
        auto obj = cast(HipDDFObjectInternal*)hddfobj;
        HipDDFVarInternal* v = name in obj.variables;
        if(v !is null)
        {
            import std.traits:isArray, isStaticArray;
            assert(v.type == T.stringof, "Data expected '"~T.stringof~"' differs from the HipDDF : '"~v.toString~"'");

            static if(!is(T == string) && isArray!T)
            {
                assert(v.isArray,  "Tried to get an array of type "~T.stringof~" from HipDDF which is not an array: '"~v.toString~"'");
                T ret;
                string stringVal = "";
                int i = 1;
                int index = 0;
                import std.stdio;
                debug writeln(v.value);
                //Means that the array has same value on every index
                if(v.value[$-1] != ']')
                    ret = to!(typeof(T.init[0]))(v.value);
                //Parse the values  
                else while(i < cast(int)v.value.length - 1)
                {
                    if(v.value[i] == ',')
                    {
                        if(stringVal)
                        {
                            static if(!isStaticArray!T)
                                ret.length++;
                            ret[index++] = to!(typeof(T.init[0]))(stringVal);
                        }
                        stringVal = "";
                    }
                    i++;
                }
                return ret;
            }
            else
                return to!T(v.value);
        }
        assert(0, "Could not find variable named '"~name~"'");
    }
}