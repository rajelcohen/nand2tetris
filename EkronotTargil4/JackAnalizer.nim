import std/os
import std/rdstdin
import os, sequtils
import std/strutils
import re
import tables
import strformat
import strutils

#--------------- "global" declarations --------------------------

#options for path - choose form one:
#path for arrayTest:
#var path = r"C:\Users\rajel\OneDrive\Desktop\projects\10\ArrayTest"

#path for SquareTest
#r"C:\Users\rajel\OneDrive\Desktop\projects\11\Square"
#path for ExpressionLessSquareTest
var path = r"C:\Users\rajel\OneDrive\Desktop\projects\11\ComplexArrays"

#path for test
#var path = r"C:\Users\rajel\OneDrive\Desktop\projects\11\Average"

#path for my own folder
#var path = r"C:\Users\rajel\OneDrive\Desktop\New folder"


#go over all files in folder
let filesInPath = toSeq(walkDir(path, relative=true))
var tokens = @[""]
var vmCode = @[""]
var stringTokens = @[""]
var stokens = stringTokens
var sTokensParsing = @[""]
var numOfArguments = 0
var labelNum = 0


#-------------------------- Targil 5 - Code Generation: ----------------------------

#--------------------------- Tables: -----------------------------------------------

type
    Identifier = object
        name: string
        typeOf: string
        kind: string
        index: int

#Constructor - table for class
var classTable : seq[Identifier]

#Constructor - table for method
var methodTable : seq[Identifier]

#varCount - function that returns index for new Identifier, gets tableName and kind
proc varCount(mykind : string, table : string): int = 
    var counter = -1

    if table == "classTable":
        for j in 0 ..< classTable.len:
            if classTable[j].kind == mykind:
                counter = classTable[j].index
        
    if table == "methodTable":
        for j in 0 ..< methodTable.len:
            if methodTable[j].kind == mykind:
                counter = methodTable[j].index
 
    return counter + 1;

#define - function that returns new Identifier given name, type, kind and Index
proc defineIdentifier(myName : string, myKind: string, myType : string, myIndex : int): Identifier = 
    var newIdentifier = Identifier(name : myName, typeOf: myType, kind: myKind, index: myIndex)
    return newIdentifier

#kindOf - function returns the kind of given table and name
proc kindOf(myName : string, table : string): string = 
    var k = ""
    if table == "classTable":
        for j in 0 ..< classTable.len:
            if classTable[j].name == myName:
                return classTable[j].kind
    
    if table == "methodTable":
        for j in 0 ..< methodTable.len:
            if methodTable[j].name == myName:
                return methodTable[j].kind
    
    return "not found"

#typeOf - function that returns type given table and name
proc typeOf(myName : string, table : string): string = 
    var k = ""
    if table == "classTable":
        for j in 0 ..< classTable.len:
            if classTable[j].name == myName:
                return classTable[j].typeOf
    
    if table == "methodTable":
        for j in 0 ..< methodTable.len:
            if methodTable[j].name == myName:
                return methodTable[j].typeOf

    return "not found"

#indexOf - function that returns index given table and name
proc indexOf(myName : string, table : string): int = 
    var k = ""
    if table == "classTable":
        for j in 0 ..< classTable.len:
            if classTable[j].name == myName:
                return classTable[j].index
    
    if table == "methodTable":
        for j in 0 ..< methodTable.len:
            if methodTable[j].name == myName:
                return methodTable[j].index

    return -1

#------------------------------ Tokenizing: -----------------------------------

#function that returns true if string is num
proc isintegerConstant(currentToken : string): bool = 
    if currentToken == "":
        return false #  make sure the string is not empty
    var i = 0
    for j in 0 ..< currentToken.len:
        if (currentToken[i] != '0' and currentToken[i] != '1' and currentToken[i] != '2' and currentToken[i] != '3' and currentToken[i] != '4' and currentToken[i] != '5' and currentToken[i] != '6' and currentToken[i] != '7' and currentToken[i] != '8' and currentToken[i] != '9'):
            return false
        i = i+1;
    
    return true

#function returns true if == id
proc isIdentifier (currentToken : string): bool = 
    if isintegerConstant($currentToken[0]) == true:
        return false
    for i in currentToken:
        if isintegerConstant($i) == false and isAlphaAscii(i) == false and $i != "_":
            return false
    return true

#function returns true if == keyword
proc isKeyword(currentToken : string):bool = 
    if currentToken == "class" or currentToken == "constructor" or currentToken == "function" or currentToken == "procedure" or currentToken == "method" or currentToken == "field" or currentToken == "static" or currentToken == "var" or currentToken == "int" or currentToken == "char" or currentToken == "boolean" or currentToken == "void" or currentToken == "true" or currentToken == "true;" or currentToken == "true)" or currentToken == "true);" or currentToken == "false" or currentToken == "false;" or currentToken == "false)" or currentToken == "false);" or currentToken == "null" or currentToken == "null;" or currentToken == "null)" or currentToken == "null);" or currentToken == "this" or currentToken == "this;" or currentToken == "this)" or currentToken == "this);" or currentToken == "let" or currentToken == "do" or currentToken == "if" or currentToken == "else" or currentToken == "while" or currentToken == "return" or currentToken == "return;":
             return true
    else:
        return false

#function returns true if == {true,false,null,this}
proc isKeywordConstant(currentToken : string):bool = 
    if currentToken == "true" or currentToken == "false" or currentToken == "null" or currentToken == "this":
             return true
    else:
        return false

#function that returns true if string is symbol
proc isSymbol(currentToken : string): bool = 
    if currentToken == "":
        return false;
    if currentToken == $'{' or currentToken == $'}' or currentToken == $'(' or currentToken == $')' or currentToken == $'[' or currentToken == $']' or currentToken == $'.' or currentToken == $',' or currentToken == $';' or currentToken == $'+' or currentToken == $'-' or currentToken == $'-' or currentToken == $'*' or currentToken == $'/' or currentToken ==  $'&' or currentToken == $'|' or currentToken == $'<' or currentToken == $'>' or currentToken == $'=' or currentToken == $'~' or currentToken == $'$':
        return true;
    return false;

#function returns true if is token has "..."
proc isStringConstant(currentToken : string):bool = 
    if currentToken[0] == '\"':
        return true
    else:
        return false

# function to delete all comments between /*e
proc replaceComments1(strIn: string): string =
    return strIn.replace(re"/\*(.|\n)*?\*/", "")

#return strIn.replace(re"/\*.*?\*/", "")

# function to delete all comments after //
proc replaceComments2(strIn: string): string = 
        return strIn.replace(re"//.*", "")

#function gets string, returns array deviding into sybol/not symbol
proc devideSymbol(str : string) : seq =
    var length = str.len
    var i = 0
    var pre = @[""]
    var word = ""
    while i < length:
        if(isSymbol($str[i]) == false):
            if word != "":
                word = word & $str[i]
            else:
                word = $str[i]
        else:
            if(i == 0):
                pre = @[$str[i]]
            else:
                if(word != ""):
                    pre.add(word);
                pre.add($str[i])
                word = ""
        i = i + 1

    if(word != ""):
         pre.add(word);
    if(pre[0] == ""):
        return pre[1..pre.high]
    else:
        return pre

#function gets string returns seq without /r or /n or /t
proc replaceRowSkippers(str : string): seq=
    var p = @[str.replace(re"\r","~y").replace(re"\n","~y").replace(re"\t","~y")]
    var s = str.replace(re"\r","~y").replace(re"\n","~y").replace(re"\t","~y").split("~y")
    var index = s.find("")
    while index != -1:
        s.delete(index)
        index = s.find("")
    return s

#get string and returns seq of quotation mark separation with "\"
proc quotationMarksep(str: string) : seq=
    var length = str.len
    var i = 0
    var pre = @[""]
    var word = ""
    while i < length:
        if($str[i] != $'\"'):
            if word != "":
                word = word & $str[i]
            else:
                word = $str[i]
            i = i + 1
            
        elif($str[i] == $'\"'):
            if(i == 0):
                pre = @[$'\"']
                i = i + 1

            else:
                if(word != ""):
                    pre.add(word);
                pre.add($'\"')
                i = i + 1
                word = ""
        
    if(word != ""):
         pre.add(word);
    return pre[0..pre.high]

# function that recieves string and inserts all the devided tokens into array, returns array
proc devideAndInsert(strIn: string): void =
    # fill the stringTokens array
    var str = strIn.split("\"")
    var k = 0
    while k < str.len:
        if(k + 1 < str.len):
            if(stringTokens == @[""]):
                stringTokens = @[str[k+1]]
            else:
                stringTokens.add(str[k+1])
        k = k + 2
    
    stokens = stringTokens
    sTokensParsing = stringTokens

    # split string into words between spaces
    tokens = strIn.split(" ").toSeq()

    #remove all ""
    var index = tokens.find("")
    while index != -1:
        tokens.delete(index)
        index = tokens.find("")

    #remove all \r\n
    k = 0
    #each word in token
    while(k < tokens.len):
        var p = @[""]
        var indexr = tokens[k].find(re"\r")
        var indexn = tokens[k].find(re"\n")
        var indext = tokens[k].find(re"\t")
        if indexr != -1 or indexn != -1 or indext != -1:
            p = replaceRowSkippers($tokens[k])
            tokens.delete(k)
            tokens.insert(p, k)
            k = k + p.len
        else:
            k = k + 1;


    #check for all string 1. separate quotation marks - 2. connect bewteen quotation marks
    k = 0
    var pre = @[""]
    var j = 0
    #1 - each word in token
    while(k < tokens.len):
        var i = tokens[k].find($'\"') 
        if i != -1:
            pre = quotationMarksep(tokens[k])
            tokens.delete(k)
            tokens.insert(pre, k)
            k = k + pre.len
        else:
            k = k + 1;
    
    

    #2 - connect all between quotation marks
    k = 0
    j = 0
    var p = 0
    var h = 0
    pre = @[""]
    var t = ""
    while(k < tokens.len):
        if(tokens[k] == $'\"'):
            j = k
            p = j
            t = t & tokens[k]
            k = k + 1
            while(k < tokens.len and tokens[k] !=  $'\"'):
                t = t & tokens[k] & " "
                k = k + 1
            h = k
            t = t[0..(t.high-1)] & tokens[k]
            var b = j
            while j <= h:
                tokens.delete(b)
                j = j + 1

            pre.add(t)
            pre.delete(0)
            tokens.insert(pre, p)
            k = k + 1
            t = ""
        else:
            k = k + 1
    
    
    
    
    #check all that have symbol
    k = 0
    pre = @[""]
    j = 0
    #each word in token
    while(k < tokens.len):
        #each char in word
        j = 0
        for p in tokens[k]:
            if(isSymbol($p) == true and tokens[k].len > 1):
                j = j + 1
        if j != 0:
            pre = devideSymbol(tokens[k])
            tokens.delete(k)
            tokens.insert(pre, k)
            k = k + pre.len
        else:
            k = k + 1;
    

    #remove all ""
    index = tokens.find("")
    while index != -1:
        tokens.delete(index)
        index = tokens.find("")
        
#function gets from tokens and returns str with html form of FileNameT.jack        
proc tokenType(): string = 
    var k = 0
    var str = "<tokens>\n"
    var checker = 0
    while(k < tokens.len):
        checker = 0
        
        if isKeyword(tokens[k]) == true:
            str = str & "<keyword> " & tokens[k] & " </keyword>\n"
            checker = 1
            k = k + 1
        
        if checker == 0 and isSymbol(tokens[k]) == true:
            var sym = ""
            if tokens[k] == "<":
                sym = "&lt;"
            if tokens[k] == ">":
                sym = "&gt;"
            if tokens[k] == "&":
                sym = "&amp;"
            if sym == "":
                sym = tokens[k]
            str = str & "<symbol> " & sym & " </symbol>\n"
            checker = 1
            k = k + 1

        if checker == 0 and isintegerConstant(tokens[k]) == true:
            str = str & "<integerConstant> " & tokens[k] & " </integerConstant>\n"
            checker = 1
            k = k + 1
        
        if checker == 0 and isStringConstant(tokens[k]) == true:
            var u = stokens[0].high
            str = str & "<stringConstant> " & stokens[0][0..u] & " </stringConstant>\n"
            stokens.delete(0)
            checker = 1
            k = k + 1

        if checker == 0:
            str = str & "<identifier> " & tokens[k] & " </identifier>\n"
            k = k + 1

        
    str = str & "</tokens>\n"
    return str

#general function of tokenize
proc tokenize(readingfile: string, writingFile: File): string = 
    var wfile = writingFile 
    # first - take down comments
    var file = replaceComments1(readingfile)
    file = replaceComments2(file)

    # second - devide and insert into array
    devideAndInsert(file)

    # three - go over each one, and give it a type of token
    var str = tokenType()
    #var str = "hi"
    return str

#--------------------------------------- Parsing: -------------------------------------------------

#"global" declarations
proc statementsFunc(str : string, level : int): string
proc expressionFunc(str : string, level : int): string 
proc findRealName(name : string) : string 
var currentToken = 0
var currentTokenString = 0
var className = ""
var currentFunctionName = ""
var subroutineType = ""

#----------- Expressions:

#expressionList
proc expressionListFunc(str : string, level : int): string = 
    var s = str
    var l = level
    var counter = 0
    var i  = 0
    #<expressionList>
    while i < l:
        s = s & "  "
        i = i + 1
    s = s & "<expressionList>\n"
    i = 0
    
    #()? -> if will go into options of expressionList
    if(tokens[currentToken] == "(" or tokens[currentToken] == "-" or tokens[currentToken] == "~" or  isintegerConstant(tokens[currentToken]) == true or isStringConstant(tokens[currentToken]) == true or isKeywordConstant(tokens[currentToken]) == true or isIdentifier(tokens[currentToken]) == true):
        
        #expression
        s = expressionFunc(s, l + 1)
        numOfArguments = numOfArguments + 1

        #(',' expression)*
        while(tokens[currentToken] == ","):

            while i < (l + 1):
                s = s & "  "
                i = i + 1
            s = s & "<symbol> " & tokens[currentToken] & " </symbol>\n"
            i = 0
            currentToken = currentToken + 1

            s = expressionFunc(s, l + 1)
            numOfArguments = numOfArguments + 1

    #</expressionList>
    while i < l:
        s = s & "  "
        i = i + 1
    s = s & "</expressionList>\n"
    i = 0

    return s

#term
proc termFunc(str : string, level : int): string = 

    var s = str
    var l = level
    var counter = 0
    var i  = 0

    #<term>
    while i < l:
        s = s & "  "
        i = i + 1
    s = s & "<term>\n"
    i = 0

    #level = l + 1
    #int | string | keyword

    #int
    if isintegerConstant(tokens[currentToken]) == true:
        #vmCode
        vmCode = vmCode & "push constant " & tokens[currentToken] & "\n"

        #parsing
        counter = 1
        while i < (l+1):
            s = s & "  "
            i = i + 1
        s = s & "<integerConstant> " & tokens[currentToken] & " </integerConstant>\n"
        currentToken = currentToken + 1
        counter = 1
        i = 0

    #string
    if counter == 0 and isStringConstant(tokens[currentToken]) == true:
        #vmCode
        vmCode = vmCode & "push constant " & $(sTokensParsing[currentTokenString].len) & "\n"
        vmCode = vmCode & "call String.new 1 \n"
        for i in 0..sTokensParsing[currentTokenString].len-1:
            var c = sTokensParsing[currentTokenString][i]
            vmCode = vmCode & "push constant " & $(int(c)) & "\n"
            vmCode = vmCode & "call String.appendChar 2\n" 


        #parsing
        while i < (l+1):
            s = s & "  "
            i = i + 1
        
        s = s & "<stringConstant> " & sTokensParsing[currentTokenString] & " </stringConstant>\n"
        currentToken = currentToken + 1
        currentTokenString = currentTokenString + 1
        counter = 1
        i = 0

    #keyword
    if counter == 0 and isKeywordConstant(tokens[currentToken]) == true:
        #vmCode
        if tokens[currentToken] == "true":
            vmCode = vmCode & "push constant 0\n"
            vmCode = vmCode & "not\n"
        if tokens[currentToken] == "false" or tokens[currentToken] == "null":
            vmCode = vmCode & "push constant 0\n"
        if tokens[currentToken] == "this":
            vmCode = vmCode & "push pointer 0\n"
        
        #parsing
        while i < (l+1):
            s = s & "  "
            i = i + 1
        s = s & "<keyword> " & tokens[currentToken] & " </keyword>\n"
        currentToken = currentToken + 1
        counter = 1
        i = 0

    #| UnaryOp Term
    if counter == 0 and (tokens[currentToken] == "~" or tokens[currentToken] == "-"):
        #vmcode
        var thisUop = tokens[currentToken]

        #parsing
        while i < (l+1):
            s = s & "  "
            i = i + 1
        s = s & "<symbol> " & tokens[currentToken] & " </symbol>\n"
        currentToken = currentToken + 1
        counter = 1
        i = 0

        s = termFunc(s, l + 1)

        if thisUop == "-":
            vmCode = vmCode & "neg\n"
        if thisUop == "~":
            vmCode = vmCode & "not\n"

    # if tokens[currentToken] == id -> id|id[expression]|id(exprList)|id.id(expressionList)
    if counter == 0 and isIdentifier(tokens[currentToken]) == true:
        var id = tokens[currentToken]
        #parsing
        var n = 0
        #'id'
        while i < (l+1):
            s = s & "  "
            i = i + 1
        s = s & "<identifier> " & tokens[currentToken] & " </identifier>\n"
        currentToken = currentToken + 1
        i = 0

        #'[expression]
        if tokens[currentToken] == "[":
            #vmcode
            
            #parsing
            #'['
            while i < (l+1):
                s = s & "  "
                i = i + 1
            s = s & "<symbol> " & tokens[currentToken] & " </symbol>\n"
            currentToken = currentToken + 1
            i = 0

            s = expressionFunc(s, l+1)

            vmCode = vmCode & "push " & findRealName(id) & "\n"
            vmCode = vmCode & "add\n"

            #']'
            while i < (l+1):
                s = s & "  "
                i = i + 1
            s = s & "<symbol> " & tokens[currentToken] & " </symbol>\n"
            currentToken = currentToken + 1
            i = 0
            counter =1

            vmCode = vmCode & "pop pointer 1\n"
            vmCode = vmCode & "push that 0\n"
            
        #|(expressionList)
        if counter == 0 and tokens[currentToken] == "(":
            #vmCode
            vmCode = vmCode & "push pointer 0\n"

            #'('
            while i < (l+1):
                s = s & "  "
                i = i + 1
            s = s & "<symbol> " & tokens[currentToken] & " </symbol>\n"
            currentToken = currentToken + 1
            i = 0

            s = expressionListFunc(s, l+1)

            #call class numArg+1 (+1 because of the "this")
            if numOfArguments > 0:
                vmCode = vmCode & "call " & className & "." & tokens[currentToken] & " " & $(numOfArguments + 1) & "\n"
            else:
                vmCode = vmCode & "call " & className & "." & tokens[currentToken] & " " & "1\n" 

            numOfArguments = 0

            #')'
            while i < (l+1):
                s = s & "  "
                i = i + 1
            s = s & "<symbol> " & tokens[currentToken] & " </symbol>\n"
            currentToken = currentToken + 1
            i = 0
            counter = 1

        #.id"(" expressionList ")"
        if counter == 0 and tokens[currentToken] == ".":
            #vmcode
            if(kindOf(id,"classTable") != "not found" or kindOf(id,"methodTable") != "not found" ):
                var realName = findRealName(id)
                vmCode = vmCode & "push " & realName & "\n"

            #parsing
            #'.'
            while i < (l+1):
                s = s & "  "
                i = i + 1
            s = s & "<symbol> " & tokens[currentToken] & " </symbol>\n"
            currentToken = currentToken + 1
            i = 0

            #'id'
            while i < (l+1):
                s = s & "  "
                i = i + 1
            s = s & "<identifier> " & tokens[currentToken] & " </identifier>\n"
            var subId = tokens[currentToken]
            currentToken = currentToken + 1
            counter = 1
            i = 0

            #'('
            while i < (l+1):
                s = s & "  "
                i = i + 1
            s = s & "<symbol> " & tokens[currentToken] & " </symbol>\n"
            currentToken = currentToken + 1
            i = 0

            s = expressionListFunc(s, l + 1)

            #')'
            while i < (l+1):
                s = s & "  "
                i = i + 1
            s = s & "<symbol> " & tokens[currentToken] & " </symbol>\n"
            currentToken = currentToken + 1
            i = 0

            if(kindOf(id,"classTable") != "not found" or kindOf(id,"methodTable") != "not found" ):
                if kindOf(id,"classTable") != "not found": 
                    vmCode = vmCode & "call " & $typeOf(id,"classTable") & "." & subId & " " & $(numOfArguments + 1) & "\n"
                else:
                    vmCode = vmCode & "call " & $typeOf(id,"methodTable") & "." & subId & " " & $(numOfArguments + 1) & "\n"

            #not found in tables
            else:
                vmCode = vmCode & "call " & id & "." & subId & " " & $(numOfArguments) & "\n"

            numOfArguments = 0
            
        if counter == 0:
            vmCode = vmCode & "push " & findRealName(id) & "\n"

    # if tokens[currentToken] ==  "(" -> "(" expression ")"
    if counter == 0 and tokens[currentToken] ==  "(":
        #'('
        while i < (l+1):
            s = s & "  "
            i = i + 1
        s = s & "<symbol> " & tokens[currentToken] & " </symbol>\n"
        currentToken = currentToken + 1
        i = 0

        #expression
        s = expressionFunc(s, l + 1)

        #')'
        while i < (l+1):
            s = s & "  "
            i = i + 1
        s = s & "<symbol> " & tokens[currentToken] & " </symbol>\n"
        currentToken = currentToken + 1
        i = 0

    #</term>
    while i < l:
        s = s & "  "
        i = i + 1
    s = s & "</term>\n"
    i = 0
    return s

#expression
proc expressionFunc(str : string, level : int): string = 
    var s = str
    var l = level
    var i  = 0

    #<expression>
    while i < l:
        s = s & "  "
        i = i + 1
    s = s & "<expression>\n"
    i = 0

    #level = l + 1
    #term
    s = termFunc(s, l + 1)

    #(op term)*
    while(tokens[currentToken] == "+" or tokens[currentToken] == "-" or tokens[currentToken] == "*" or tokens[currentToken] == "/" or tokens[currentToken] == "&" or tokens[currentToken] == "|" or tokens[currentToken] == "<" or tokens[currentToken] == ">" or tokens[currentToken] == "="  or tokens[currentToken] == "$"):
        var op = tokens[currentToken]

        #parsing
        while i < (l + 1):
            s = s & "  "
            i = i + 1
        var y = tokens[currentToken]
        if tokens[currentToken] == "<":
            y = "&lt;"
        if tokens[currentToken] == ">":
            y = "&gt;"
        if tokens[currentToken] == "&":
            y = "&amp;"
        
        s = s & "<symbol> " & y & " </symbol>\n"
        currentToken = currentToken + 1
        i = 0

        s = termFunc(s, l + 1)

        if op == "+":
            vmCode = vmCode & "add\n"
        if op == "-":
            vmCode = vmCode & "sub\n"
        if op == "*":
            vmCode = vmCode & "call Math.multiply 2\n"
        if op == "/":
            vmCode = vmCode & "call Math.divide 2\n"
        if op == "&":
            vmCode = vmCode & "and\n"
        if op == "|":
            vmCode = vmCode & "or\n"
        if op == "<":
            vmCode = vmCode & "lt\n"
        if op == ">":
            vmCode = vmCode & "gt\n"
        if op == "=":
            vmCode = vmCode & "eq\n"


    #</expression>
    while i < l:
        s = s & "  "
        i = i + 1
    s = s & "</expression>\n"
    i = 0
    return s

#subroutineCall
proc subroutineCallFunc (str : string, level : int): string = 
    var s = str
    var l = level
    var i  = 0
    var id = tokens[currentToken]
    #level = l + 1 -> no <subroutineCall>

    #id (subroutine|className|varName)
    while i < (l+1):
        s = s & "  "
        i = i + 1
    s = s & "<identifier> " & tokens[currentToken] & " </identifier>\n"
    currentToken = currentToken + 1
    i = 0

    #if tokens[currentToken] == "(" -> (expressionList)
    if tokens[currentToken] == "(":
        #(expression)
        #"("
        while i < (l+1):
            s = s & "  "
            i = i + 1
        s = s & "<symbol> " & tokens[currentToken] & " </symbol>\n"
        currentToken = currentToken + 1
        i = 0
        vmCode = vmCode & "push pointer 0\n"
        s = expressionListFunc(s, l + 1)

        #")"
        while i < (l+1):
            s = s & "  "
            i = i + 1
        s = s & "<symbol> " & tokens[currentToken] & " </symbol>\n"
        currentToken = currentToken + 1
        i = 0

        if numOfArguments > 0:
            vmCode = vmCode & "call " & className & "." & id & " " & $(numOfArguments + 1) & "\n"
        else:
            vmCode = vmCode & "call " & className & "." & id & " " & $1 & "\n"

        numOfArguments = 0

    #else tokens[currentToken] == "." -> .id "(" expressionList ")"
    else:
        #"."
        while i < (l+1):
            s = s & "  "
            i = i + 1
        s = s & "<symbol> " & tokens[currentToken] & " </symbol>\n"
        currentToken = currentToken + 1
        i = 0

        var subId = tokens[currentToken]
        #"id
        while i < (l+1):
            s = s & "  "
            i = i + 1
        s = s & "<identifier> " & tokens[currentToken] & " </identifier>\n"
        currentToken = currentToken + 1
        i = 0

        if kindOf(id, "classTable") != "not found" or kindOf(id, "methodTable") != "not found":
            vmCode = vmCode & "push " & findRealName(id) & "\n" 


        #"("
        while i < (l+1):
            s = s & "  "
            i = i + 1
        s = s & "<symbol> " & tokens[currentToken] & " </symbol>\n"
        currentToken = currentToken + 1
        i = 0


        #expressionList
        s = expressionListFunc(s, l + 1)

        #")"
        while i < (l+1):
            s = s & "  "
            i = i + 1
        s = s & "<symbol> " & tokens[currentToken] & " </symbol>\n"
        currentToken = currentToken + 1
        i = 0

        if kindOf(id, "classTable") != "not found" or kindOf(id, "methodTable") != "not found":
            
            if kindOf(id,"classTable") != "not found": 
                vmCode = vmCode & "call " & $typeOf(id, "classTable") & "." & subId & " " & $(numOfArguments + 1) & "\n"
            else:
                vmCode = vmCode & "call " & $typeOf(id, "methodTable") & "." & subId & " " & $(numOfArguments + 1) & "\n"

        else:
            vmCode = vmCode & "call " & id & "." & subId & " " &  $(numOfArguments) & "\n"

        numOfArguments = 0

    

    return s

#----------- Statements:

#letStatement
proc letStatementFunc(str : string, level : int): string = 
    var s = str
    var l = level
    var i  = 0
    var isArray = 0
     #<letStatement>
    while i < l:
        s = s & "  "
        i = i + 1
    s = s & "<letStatement>\n"
    i = 0

    #level = l + 1
    #'let'
    while i < (l+1):
        s = s & "  "
        i = i + 1
    s = s & "<keyword> " & tokens[currentToken] & " </keyword>\n"
    currentToken = currentToken + 1
    i = 0

    #varname
    var id = tokens[currentToken]
    while i < (l+1):
        s = s & "  "
        i = i + 1
    s = s & "<identifier> " & tokens[currentToken] & " </identifier>\n"
    currentToken = currentToken + 1
    i = 0

    #('[' expression ']')?
    if tokens[currentToken] == "[":
        #'['
        while i < (l+1):
            s = s & "  "
            i = i + 1
        s = s & "<symbol> " & tokens[currentToken] & " </symbol>\n"
        currentToken = currentToken + 1
        i = 0

        #expression
        s = expressionFunc(s, l + 1)

        vmCode = vmCode & "push " & findRealName(id) & "\n"
        vmCode = vmCode & "add\n"

        #']'
        while i < (l+1):
            s = s & "  "
            i = i + 1
        s = s & "<symbol> " & tokens[currentToken] & " </symbol>\n"
        currentToken = currentToken + 1
        i = 0
        isArray = 1

    #'='
    while i < (l+1):
        s = s & "  "
        i = i + 1
    s = s & "<symbol> " & tokens[currentToken] & " </symbol>\n"
    currentToken = currentToken + 1
    i = 0

 


    #expression
    s = expressionFunc(s, l + 1)

    if isArray == 1:
        vmCode = vmCode & "pop temp 0\n"


    #';'
    while i < (l+1):
        s = s & "  "
        i = i + 1
    s = s & "<symbol> " & tokens[currentToken] & " </symbol>\n"
    currentToken = currentToken + 1
    i = 0

    if isArray == 0:
        vmCode = vmCode & "pop " & findRealName(id) & "\n"
    else:
        vmCode = vmCode & "pop pointer 1\n"
        vmCode = vmCode & "push temp 0\n"
        vmCode = vmCode & "pop that 0\n"

    #</letStatement>
    while i < l:
        s = s & "  "
        i = i + 1
    s = s & "</letStatement>\n"
    i = 0

    return s

#ifStatement
proc ifStatementFunc(str : string, level : int): string = 
    var s = str
    var l = level
    var i  = 0
    var labelElse = "IFFALSE" & $labelNum
    var labelContinue = "CONTINUE" & $labelNum
    labelNum = labelNum + 1
     #<ifStatement>
    while i < l:
        s = s & "  "
        i = i + 1
    s = s & "<ifStatement>\n"
    i = 0

    #level = l + 1
    #'if
    while i < (l+1):
        s = s & "  "
        i = i + 1
    s = s & "<keyword> " & tokens[currentToken] & " </keyword>\n"
    currentToken = currentToken + 1
    i = 0

    #(expression)
    while i < (l+1):
        s = s & "  "
        i = i + 1
    s = s & "<symbol> " & tokens[currentToken] & " </symbol>\n"
    currentToken = currentToken + 1
    i = 0

    s = expressionFunc(s, l + 1)

    vmCode = vmCode & "not\n"
    vmCode = vmCode & "if-goto " & labelElse & "\n"

    while i < (l+1):
        s = s & "  "
        i = i + 1
    s = s & "<symbol> " & tokens[currentToken] & " </symbol>\n"
    currentToken = currentToken + 1
    i = 0

    #{statements}

    while i < (l+1):
        s = s & "  "
        i = i + 1
    s = s & "<symbol> " & tokens[currentToken] & " </symbol>\n"
    currentToken = currentToken + 1
    i = 0

    s = statementsFunc(s, l + 1)

    vmCode = vmCode & "goto " & labelContinue & "\n" 

    while i < (l+1):
        s = s & "  "
        i = i + 1
    s = s & "<symbol> " & tokens[currentToken] & " </symbol>\n"
    currentToken = currentToken + 1
    i = 0

    vmCode = vmCode & "label " & labelElse & "\n"

    #(else{statements})?
    if tokens[currentToken] == "else":
        #else
        while i < (l+1):
            s = s & "  "
            i = i + 1
        s = s & "<keyword> " & tokens[currentToken] & " </keyword>\n"
        currentToken = currentToken + 1
        i = 0

        #'{'
        while i < (l+1):
            s = s & "  "
            i = i + 1
        s = s & "<symbol> " & tokens[currentToken] & " </symbol>\n"
        currentToken = currentToken + 1
        i = 0

        #statements
        s = statementsFunc(s, l + 1)

        #'}'
        while i < (l+1):
            s = s & "  "
            i = i + 1
        s = s & "<symbol> " & tokens[currentToken] & " </symbol>\n"
        currentToken = currentToken + 1
        i = 0
    
    vmCode = vmCode & "label " & labelContinue & "\n"

     
    #</ifStatement>
    while i < l:
        s = s & "  "
        i = i + 1
    s = s & "</ifStatement>\n"
    i = 0

    return s

#whileStatement
proc whileStatementFunc(str : string, level : int): string = 
    var s = str
    var l = level
    var i  = 0
    var labelTrue = "WhileTrue" & $labelNum
    var labelFalse = "WhileFalse" & $labelNum
    labelNum = labelNum + 1

    #<whileStatement>
    while i < l:
        s = s & "  "
        i = i + 1
    s = s & "<whileStatement>\n"
    i = 0

    # level = l + 1
    #'while'
    while i < (l+1):
        s = s & "  "
        i = i + 1
    s = s & "<keyword> " & tokens[currentToken] & " </keyword>\n"
    currentToken = currentToken + 1
    i = 0

    #(expression)
    while i < (l+1):
        s = s & "  "
        i = i + 1
    s = s & "<symbol> " & tokens[currentToken] & " </symbol>\n"
    currentToken = currentToken + 1
    i = 0

    vmCode = vmCode & "label " & labelTrue & "\n"

    s = expressionFunc(s, l + 1)

    vmCode = vmCode & "not\n"
    vmCode = vmCode & "if-goto " & labelFalse & "\n"

    while i < (l+1):
        s = s & "  "
        i = i + 1
    s = s & "<symbol> " & tokens[currentToken] & " </symbol>\n"
    currentToken = currentToken + 1
    i = 0

    if tokens[currentToken] == "{":
        #{statements}

        while i < (l+1):
            s = s & "  "
            i = i + 1
        s = s & "<symbol> " & tokens[currentToken] & " </symbol>\n"
        currentToken = currentToken + 1
        i = 0

        s = statementsFunc(s, l + 1)

        vmCode = vmCode & "goto " & labelTrue & " \n"
        vmCode = vmCode & "label " & labelFalse & "\n"

        while i < (l+1):
            s = s & "  "
            i = i + 1
        s = s & "<symbol> " & tokens[currentToken] & " </symbol>\n"
        currentToken = currentToken + 1
        i = 0
    
    else:
        #;

        while i < (l+1):
            s = s & "  "
            i = i + 1
        s = s & "<symbol> " & tokens[currentToken] & " </symbol>\n"
        currentToken = currentToken + 1
        i = 0

    #</whileStatement>
    while i < l:
        s = s & "  "
        i = i + 1
    s = s & "</whileStatement>\n"
    i = 0

    return s

#doStatement -> do subroutineCall ( while(expression) )? ;
proc doStatementFunc(str : string, level : int): string = 
    var s = str
    var l = level
    var i  = 0
     #<doStatement>
    while i < l:
        s = s & "  "
        i = i + 1
    s = s & "<doStatement>\n"
    i = 0

    # level = l + 1
    #'do'
    while i < (l+1):
        s = s & "  "
        i = i + 1
    s = s & "<keyword> " & tokens[currentToken] & " </keyword>\n"
    currentToken = currentToken + 1
    i = 0

    #subroutineCall"{}"
    s = subroutineCallFunc(s, l)



    #';'
    while i < (l+1):
        s = s & "  "
        i = i + 1
    s = s & "<symbol> " & tokens[currentToken] & " </symbol>\n"
    currentToken = currentToken + 1
    i = 0

    vmCode = vmCode & "pop temp 0\n"

    #</doStatement>
    while i < l:
        s = s & "  "
        i = i + 1
    s = s & "</doStatement>\n"
    i = 0

    return s

#returnStatement
proc returnStatementFunc(str : string, level : int): string = 
    var s = str
    var l = level
    var i  = 0
     #<returnStatement>
    while i < l:
        s = s & "  "
        i = i + 1
    s = s & "<returnStatement>\n"
    i = 0

    #level  l + 1
    #'return'
    while i < (l+1):
        s = s & "  "
        i = i + 1
    s = s & "<keyword> " & tokens[currentToken] & " </keyword>\n"
    currentToken = currentToken + 1
    i = 0

    #expression?
    if isintegerConstant(tokens[currentToken]) == true or isStringConstant(tokens[currentToken]) == true or isKeywordConstant(tokens[currentToken]) == true or tokens[currentToken] == "(" or  tokens[currentToken] == "-" or  tokens[currentToken] == "~" or  isIdentifier(tokens[currentToken]) == true:
        s = expressionFunc(s, l + 1)
        vmCode = vmCode & "return\n"
    else:
        vmCode = vmCode & "push constant 0\n"
        vmCode = vmCode & "return\n"

    #';'
    while i < (l+1):
        s = s & "  "
        i = i + 1
    s = s & "<symbol> " & tokens[currentToken] & " </symbol>\n"
    currentToken = currentToken + 1
    i = 0

    #</returnStatement>
    while i < l:
        s = s & "  "
        i = i + 1
    s = s & "</returnStatement>\n"
    i = 0

    return s

#statement
proc statementFunc(str : string, level : int): string = 
    var s = str
    var l = level
    var i  = 0
    
    #level = l + 1
    #letStatement | ifStatement | whileStatement | doStatement | returnStatement
    if tokens[currentToken] == "let":
        s = letStatementFunc(s, l + 1)
    if tokens[currentToken] == "if":
        s = ifStatementFunc(s, l + 1)
    if tokens[currentToken] == "while":
        s = whileStatementFunc(s, l + 1)
    if tokens[currentToken] == "do":
        s = doStatementFunc(s, l + 1)
    if tokens[currentToken] == "return":
        s = returnStatementFunc(s, l + 1)

    return s
  
#statements
proc statementsFunc (str : string, level : int): string = 
    var s = str
    var l = level
    var i  = 0

    #<statements>
    while i < l:
        s = s & "  "
        i = i + 1
    s = s & "<statements>\n"
    i = 0

    #level = l + 1
    
    while tokens[currentToken] == "let" or tokens[currentToken] == "if" or tokens[currentToken] == "while" or tokens[currentToken] == "do" or tokens[currentToken] == "return":
        s = statementFunc(s, l)   

     #</statements>
    while i < l:
        s = s & "  "
        i = i + 1
    s = s & "</statements>\n"
    i = 0

    return s

#---------- Program Structure:

#type
proc typeFunc(str: string, level : int): string = 
    var s = str
    var l = level
    var i  = 0

    while i < l:
        s = s & "  "
        i = i + 1

    
    #int | char | boolean
    if tokens[currentToken] == "int" or tokens[currentToken] == "char" or tokens[currentToken] == "boolean":
        s = s & "<keyword> " & tokens[currentToken] & " </keyword>\n"
    # | className
    else:
        s = s & "<identifier> " & tokens[currentToken] & " </identifier>\n"
    
    currentToken = currentToken + 1
    return s

#level 1
#classVarDec
proc classVarDecFunc(str: string):string = 
    var s = str
    var myKind = ""
    var myType = ""
    #<classVarDec>
    s = s & "  <classVarDec>\n"

    #static or field
    s = s & "    <keyword> " & tokens[currentToken] & " </keyword>\n"
    myKind = tokens[currentToken]
    currentToken = currentToken + 1

    #type varName
    #level 2
    myType = tokens[currentToken]
    s = typeFunc(s, 2)
    s = s & "    <identifier> " & tokens[currentToken] & " </identifier>\n"
    var myIndex = varCount(myKind, "classTable")
    var newI = defineIdentifier(tokens[currentToken], myKind, myType, myIndex)
    classTable.add(newI)
    currentToken = currentToken + 1

    #(',' varName)*
    while tokens[currentToken] == ",":
        s = s & "    <symbol> " & tokens[currentToken] & " </symbol>\n"
        currentToken = currentToken + 1
        s = s & "    <identifier> " & tokens[currentToken] & " </identifier>\n"
        myIndex = varCount(myKind, "classTable")
        newI = defineIdentifier(tokens[currentToken], myKind, myType, myIndex)
        classTable.add(newI)
        currentToken = currentToken + 1

    # ';'
    s = s & "    <symbol> " & tokens[currentToken] & " </symbol>\n"
    currentToken = currentToken + 1

    #</classVarDec>
    s = s & "  </classVarDec>\n"
    return s;

#parameterList
proc parameterListFunc(str : string, level : int): string = 
    
    var s = str
    var myKind = "argument"
    var myType = ""
    var l = level
    var i  = 0
    var myIndex = 0

    #type
    myType = tokens[currentToken]
    s = typeFunc(s, l)

    #varName
    while i < l:
        s = s & "  "
        i = i + 1
    s = s & "<identifier> " & tokens[currentToken] & " </identifier>\n"

    #add new Identifier to methodTable
    myIndex = varCount(myKind, "methodTable")
    var newI = defineIdentifier(tokens[currentToken], myKind, myType, myIndex)
    methodTable.add(newI)



    currentToken = currentToken + 1
    i = 0

    #(, type varName)*
    while(tokens[currentToken] == ","):
        while i < l:
             s = s & "  "
             i = i + 1
        s = s & "<symbol> " & tokens[currentToken] & " </symbol>\n"
        currentToken = currentToken + 1
        i = 0

        myType = tokens[currentToken]

        s = typeFunc(s, l)
        while i < l:
            s = s & "  "
            i = i + 1
        s = s & "<identifier> " & tokens[currentToken] & " </identifier>\n"

         #add new Identifier to methodTable
        myIndex = varCount(myKind, "methodTable")
        newI = defineIdentifier(tokens[currentToken], myKind, myType, myIndex)
        methodTable.add(newI)

        currentToken = currentToken + 1
        i = 0
    return s

#varDec
proc varDecFunc(str : string, level : int): string = 
    var s = str
    var l = level
    var i  = 0
    var myName = ""
    var myKind = "var"
    var myType = ""
    
    #<varDec>
    while i < l:
        s = s & "  "
        i = i + 1
    s = s & "<varDec>\n"
    i = 0

    #level = l + 1
    #var
    while i < (l + 1):
        s = s & "  "
        i = i + 1
    s = s & "<keyword> " & tokens[currentToken] & " </keyword>\n"
    currentToken = currentToken + 1
    i = 0

    #type
    myType = tokens[currentToken]
    s = typeFunc(s, l + 1)

    #varName
    while i < (l + 1):
        s = s & "  "
        i = i + 1
    s = s & "<identifier> " & tokens[currentToken] & " </identifier>\n"
    myName = tokens[currentToken]
    currentToken = currentToken + 1
    i = 0

    #add new Identifier to methodTable
    var myIndex = varCount(myKind, "methodTable")
    var newI = defineIdentifier(myName, myKind, myType, myIndex)
    methodTable.add(newI)

    #(',' varName)*
    while tokens[currentToken] == ",":
        while i < (l + 1):
            s = s & "  "
            i = i + 1
        s = s & "<symbol> " & tokens[currentToken] & " </symbol>\n"
        currentToken = currentToken + 1
        i = 0

        while i < (l + 1):
            s = s & "  "
            i = i + 1
        s = s & "<identifier> " & tokens[currentToken] & " </identifier>\n"
        
        #add new Identifie to methodTable
        myName = tokens[currentToken]
        myIndex = varCount(myKind, "methodTable")
        newI = defineIdentifier(myName, myKind, myType, myIndex)
        methodTable.add(newI)

        currentToken = currentToken + 1
        i = 0

    i = 0
    # ';'
    while i < (l + 1):
        s = s & "  "
        i = i + 1
    s = s & "<symbol> " & tokens[currentToken] & " </symbol>\n"
    currentToken = currentToken + 1
    i = 0
    
    #</varDec>
    while i < l:
        s = s & "  "
        i = i + 1
    s = s & "</varDec>\n"
    i = 0
    return s

#subroutineBody
proc subroutineBodyFunc(str : string, level : int): string = 
    var s = str
    var l = level
    var i  = 0
    
    #<subroutineBody>
    while i < l:
        s = s & "  "
        i = i + 1
    s = s & "<subroutineBody>\n"
    i = 0

    #level = l + 1
    #{ 
    while i < (l+1) :
        s = s & "  "
        i = i + 1
    s = s & "<symbol> " & tokens[currentToken] & " </symbol>\n"
    currentToken = currentToken + 1
    i = 0


    #varDec*
    while tokens[currentToken] == "var":
       s = varDecFunc(s, l + 1)    

    var nlocal = varCount("var", "methodTable")
    vmCode = vmCode & "function " & currentFunctionName & " " & $nlocal & "\n"
    
    if subroutineType == "constructor":
        var fieldg = varCount("field", "classTable")
        vmCode = vmCode & "push constant " & $fieldg & "\n"
        vmCode = vmCode & "call Memory.alloc 1\n"
        vmCode = vmCode & "pop pointer 0\n"

    if subroutineType == "method":
        vmCode = vmCode & "push argument 0\n"
        vmCode = vmCode & "pop pointer 0\n"


    # statements 
    s = statementsFunc(s, l + 1)

    #}
    #level = l + 1
    while i < (l+1) :
        s = s & "  "
        i = i + 1
    s = s & "<symbol> " & tokens[currentToken] & " </symbol>\n"
    currentToken = currentToken + 1
    i = 0

    #</subroutineBody>
    while i < l:
        s = s & "  "
        i = i + 1
    s = s & "</subroutineBody>\n"
    
    return s

#level 1
#subroutineDec
proc subRoutineDecFunc(str: string):string = 
    #delete all Identifiers in methodTable

    var s = str
    #<classVarDec>
    #level = 1
    s = s & "  <subroutineDec>\n"
    var myName = ""
    var myKind = ""
    var myType = ""
    var myIndex = ""
  


    #level = 2
    #constructor | function | method | procedure
    s = s & "    <keyword> " & tokens[currentToken] & " </keyword>\n"
    subroutineType = tokens[currentToken]

    if tokens[currentToken] == "method":
        myName = "this"
        myKind = "argument"
        myType = className
      

    currentToken = currentToken + 1

  

    #void | type
    if tokens[currentToken] == "void":
        s = s & "    <keyword> " & tokens[currentToken] & " </keyword>\n"
        currentToken = currentToken + 1

    else:
        s = typeFunc(s, 2)


    #subroutineName
    currentFunctionName = className & "." & tokens[currentToken]
    s = s & "    <identifier> " & tokens[currentToken] & " </identifier>\n"
    currentToken = currentToken + 1

    #if this is a method, then add Identifier "this" to methodTable
    if myName == "this":
        var myIndex = varCount(myKind, "methodTable")
        var newI = defineIdentifier(myName, myKind, myType, myIndex)
        methodTable.add(newI)

    #level = 2
    #'(' parameterList? ')'
    s = s & "    <symbol> " & tokens[currentToken] & " </symbol>\n"
    currentToken = currentToken + 1

    s = s & "    <parameterList>\n"



    #level = 3
    if(tokens[currentToken] != ")"):
        s = parameterListFunc(s, 3)
    
    
    s = s & "    </parameterList>\n"


    #level = 2
    s = s & "    <symbol> " & tokens[currentToken] & " </symbol>\n"
    currentToken = currentToken + 1

    #level = 3
    #subroutineBodyFunc
    s = subroutineBodyFunc(s, 2)



    s = s & "  </subroutineDec>\n"
    return s

#class
proc classFunc(str : string): string=
    #clear all of classTable
    classTable.setLen(0)
    vmCode = @[""]
    labelNum = 0

    #level 0
    #<class>
    var s = "<class>\n"
    #level = 1
    #class className {
    s = s & "  <keyword> " & tokens[0] & " </keyword>\n"
    s = s & "  <identifier> " & tokens[1] & " </identifier>\n"
    className = tokens[1]
    s = s & "  <symbol> " & "{" & " </symbol>\n"
    currentToken = 3

    

    #level 1
    #classVarDec*
    while tokens[currentToken] == "static" or tokens[currentToken] == "field":
        s = classVarDecFunc(s)


    #level 1
    #subroutineDec*
    while tokens[currentToken] == "constructor" or tokens[currentToken] == "function" or tokens[currentToken] == "method" or tokens[currentToken] == "procedure":
        methodTable.setLen(0)
        s = subRoutineDecFunc(s)

    #level = 1
    s = s & "  <symbol> " & "}" & " </symbol>\n"
    currentToken = currentToken + 1

    #level = 0
    s = s & "</class>\n"

    return s

#function that starts parsing, returns string with html of FileName.jack
proc parsing(str : string): string = 
    var s = str
    s = classFunc(s)
    return s

#--------------------------- Functions to write VM code: -----------------------------------------------

proc findRealName(name : string) : string = 
    #first check in methodTable
    var realName = ""
    if kindOf(name, "methodTable") != "not found":
        if kindOf(name, "methodTable") == "static":
            realName = "static " & $(indexOf(name, "methodTable")) 
        if kindOf(name, "methodTable") == "field":
            realName = "this " & $(indexOf(name, "methodTable")) 
        if kindOf(name, "methodTable") == "argument":
            realName = "argument " & $(indexOf(name, "methodTable")) 
        if kindOf(name, "methodTable") == "var":
            realName = "local " & $(indexOf(name, "methodTable")) 
        return realName
    if kindOf(name, "classTable") != "not found":
        if kindOf(name, "classTable") == "static":
            realName = "static " & $(indexOf(name, "classTable")) 
        if kindOf(name, "classTable") == "field":
            realName = "this " & $(indexOf(name, "classTable")) 
        if kindOf(name, "classTable") == "argument":
            realName = "argument " & $(indexOf(name, "classTable")) 
        if kindOf(name, "classTable") == "var":
            realName = "local " & $(indexOf(name, "classTable")) 
        return realName

proc isExp(currentT : int) : bool = 
    var i = currentT
    if isintegerConstant(tokens[i]) == true:
        return true
    if kindOf(tokens[i], "classTable") != "not found" or kindOf(tokens[i], "methodTable") != "not found":
        return true
    if tokens[i] == "-" or  tokens[i] == "~":
        return true
    if isIdentifier(tokens[i]) == true and tokens[i + 1] == "(":
        return true
    return false

proc writeExpression(currentT : int) : void =
    var i = currentT

    #if is constant
    if isintegerConstant(tokens[i]) == true:
        vmCode = vmCode & "push " & tokens[i] & "\n"
        i = i + 1
    if kindOf(tokens[i], "classTable") != "not found" or kindOf(tokens[i], "methodTable") != "not found":
        vmCode = vmCode & "push " & findRealName(tokens[i]) 

#------------------------------------- Main -----------------------------------------

# for each file, if ends with jack, open, tokenize, and return file with "My"+ filename + "T"
for readingfile in filesInPath:
    var file_ending = readingfile[1].split(".")
    if file_ending[1] == "jack":
        #open files for read amd write
        var s = path
        s.add(r"\")
        s.add(readingfile[1])
        var current_file = readFile(s)
        var pathOfNewFile = path
        pathOfNewFile.add(r"\")
        var fileName = readingfile[1].split(".")
        let name = fileName[0]
        pathOfNewFile.add("My")
        pathOfNewFile.add($name)
        var pathOfParsingFile = pathOfNewFile
        pathOfNewFile.add("T.xml")
        let writingFile = open(pathOfNewFile, fmWrite)
        pathOfParsingFile.add(".xml")
        let parsingFile = open(pathOfParsingFile, fmWrite)
        let pathofVmCodeFile = path & r"\" & name & ".vm"
        let vmCodeFile =  open(pathofVmCodeFile, fmWrite)


        #step 1 - tozenike
        #send both files to tokenize 
        #current_file ->tokenize in -> writingFile
        var str = tokenize(current_file, writingFile)
        writingFile.write(str)
        
        #step 2 - parsing
        #send to  parsing, use tokens array and file
        str = parsing(str)
        parsingFile.write(str)

        #step 3 - vm code
        vmCodeFile.write(vmCode)
        echo stringTokens
        #echo vmCode


    stringTokens = @[""]
