import std/os
import std/rdstdin
import os, sequtils
import std/strutils


#LABLES FOR TRUE & FALSE
var truelabel = 0
var falselabel = 0
var text = ""
#echo "type a path" & "\n"
#var path = readLine(stdin)
var path = r"C:\Users\rajel\OneDrive\Desktop\Ekronot\VMtranslator\PointerTest"
var name = path.split(r"\")
var fileName = name[len(name)-1]



let filesInPath = toSeq(walkDir(path, relative=true))

proc funcPush(str: string, arg : string) : void = 
    #Group 1
    if str == "local":
        var linesTranslate = ["@" & arg, "D=A","@LCL" , "A=M+D", "D=M", "@SP", "A=M", "M=D", "@SP", "M=M+1"]
        for l in linesTranslate:
            text = text & $l & "\n"
    
    if str == "argument":
        var linesTranslate = ["@" & arg, "D=A","@ARG" , "A=M+D", "D=M", "@SP", "A=M", "M=D", "@SP", "M=M+1"]
        for l in linesTranslate:
            text = text & $l & "\n"
    
    if str == "this":
        var linesTranslate = ["@" & arg, "D=A","@THIS" , "A=M+D", "D=M", "@SP", "A=M", "M=D", "@SP", "M=M+1"]
        for l in linesTranslate:
            text = text & $l & "\n"

    if str == "that":
        var linesTranslate = ["@" & arg, "D=A","@THAT" , "A=M+D", "D=M", "@SP", "A=M", "M=D", "@SP", "M=M+1"]
        for l in linesTranslate:
            text = text & $l & "\n"

    
     #Group 2
    if str == "temp":
        var linesTranslate = ["@" & arg ,"D=A", "@5", "A=A+D", "D=M", "@SP", "A=M", "M=D", "@SP", "M=M+1"]
        for l in linesTranslate:
            text = text & $l & "\n"

    #Group 3
    if str == "static":
        var linesTranslate = ["@" & fileName & "." & arg,"D=M","@SP","A=M","M=D","@SP","M=M+1"]
        for l in linesTranslate:
            text = text & $l & "\n"

    
    #Group 4
    if str == "pointer":
        if parseInt(arg) == 0:
            var linesTranslate = @["@THIS","D=M","@SP","A=M","M=D","@SP","M=M+1"]
            for l in linesTranslate:
                text = text & $l & "\n"
        elif parseInt(arg) == 1:
            var linesTranslate = @["@THAT","D=M","@SP","A=M","M=D","@SP","M=M+1"]
            for l in linesTranslate:
                text = text & $l & "\n"

    #Group 5
    if str == "constant":
        var linesTranslate = ["@" & arg ,"D=A", "@SP", "A=M", "M=D" , "@SP", "M=M+1"]
        for l in linesTranslate:
            text = text & $l & "\n"
    
  
proc funcPop(str: string, arg : string) : void = 
#Group 1
    if str == "local":
        var linesTranslate = @["@SP","A=M-1","D=M","@LCL","A=M"]
        for i in countup(1, parseInt(arg)):
            linesTranslate.add("A=A+1")
        linesTranslate.add("M=D")
        linesTranslate.add("@SP")
        linesTranslate.add("M=M-1")
        for l in linesTranslate:
            text = text & $l & "\n"
    
    if str == "argument":
        var linesTranslate = @["@SP","A= M-1","D=M","@ARG", "A=M"]
        for i in countup(1, parseInt(arg)):
            linesTranslate.add("A=A+1")
        linesTranslate.add("M=D")
        linesTranslate.add("@SP")
        linesTranslate.add("M=M-1")

        for l in linesTranslate:
            text = text & $l & "\n"

    if str == "this":
        var linesTranslate = @["@SP","A=M-1","D=M","@THIS","A=M"]
        for i in countup(1, parseInt(arg)):
            linesTranslate.add("A=A+1")
        linesTranslate.add("M=D")
        linesTranslate.add("@SP")
        linesTranslate.add("M=M-1")
        for l in linesTranslate:
            text = text & $l & "\n"
     
    
    if str == "that":
        var linesTranslate = @["@SP","A=M-1","D=M","@THAT","A=M"]
        for i in countup(1, parseInt(arg)):
            linesTranslate.add("A=A+1")
        linesTranslate.add("M=D")
        linesTranslate.add("@SP")
        linesTranslate.add("M=M-1")
        for l in linesTranslate:
            text = text & $l & "\n"
       

    #Group 2
    if str == "temp":
        var linesTranslate = @["@SP","A=M-1","D=M","@5"]
        for i in countup(1, parseInt(arg)):
            linesTranslate.add("A=A+1")
        linesTranslate.add("M=D")
        linesTranslate.add("@SP")
        linesTranslate.add("M=M-1")
        for l in linesTranslate:
            text = text & $l & "\n"
            
    #Group 3
    if str == "static":
        var linesTranslate = ["@SP","A=M-1","D=M","@" & fileName & "." & arg, "M=D", "@SP", "M=M-1"]
        for l in linesTranslate:
            text = text & $l & "\n"
    
    #Group 4
    if str == "pointer":
        var linesTranslate = @["@SP","A=M-1","D=M"] 
        if parseInt(arg) == 0:
            linesTranslate.add("@THIS")
        elif parseInt(arg) == 1:
            linesTranslate.add("@THAT")
        linesTranslate.add("M=D")
        linesTranslate.add("@SP")
        linesTranslate.add("M=M-1")
        for l in linesTranslate:
            text = text & $l & "\n"


proc funcAdd(): void = 
    var linesTranslate = ["@SP" , "A=M-1","D=M","A=A-1","M=D+M", "@SP", "M=M-1"]
    for l in linesTranslate:
        text = text & $l & "\n"

proc funcSub(): void =
    var linesTranslate = ["@SP" , "A=M-1","D=M","A=A-1","M=M-D", "@SP", "M=M-1"]
    for l in linesTranslate:
        text = text & $l & "\n"


proc funcNeg(): void =
    var linesTranslate = ["@SP" , "A=M-1","M=-M"]
    for l in linesTranslate:
        text = text & $l & "\n"

proc funcEq(): void =
    var linesTranslate = ["@SP" , "A=M-1", "D=M", "A=A-1", "D=D-M", "@IF_TRUE" & $truelabel, "D;JEQ", "D=0", "@SP", "A=M-1", "A=A-1", "M=D", "@IF_FALSE" & $falselabel, "0;JMP","(IF_TRUE" & $truelabel & ")", "D=-1", "@SP", "A=M-1", "A=A-1", "M=D", "(IF_FALSE" & $falselabel & ")", "@SP", "M=M-1"]
    for l in linesTranslate:
        text = text & $l & "\n"
    truelabel += 1
    falselabel += 1

proc funcGt(): void =
    var linesTranslate = ["@SP" , "A=M-1", "D=M", "A=A-1", "D=D-M", "@IF_TRUE" & $truelabel, "D;JLT", "D=0", "@SP", "A=M-1", "A=A-1", "M=D", "@IF_FALSE" & $falselabel, "0;JMP","(IF_TRUE" & $truelabel & ")", "D=-1", "@SP", "A=M-1", "A=A-1", "M=D", "(IF_FALSE" & $falselabel & ")", "@SP", "M=M-1"]
    for l in linesTranslate:
        text = text & $l & "\n"
    truelabel += 1
    falselabel += 1

proc funcLt(): void =
    var linesTranslate = ["@SP" , "A=M-1", "D=M", "A=A-1", "D=D-M", "@IF_TRUE" & $truelabel, "D;JGT", "D=0", "@SP", "A=M-1", "A=A-1", "M=D", "@IF_FALSE" & $falselabel, "0;JMP","(IF_TRUE" & $truelabel & ")", "D=-1", "@SP", "A=M-1", "A=A-1", "M=D", "(IF_FALSE" & $falselabel & ")", "@SP", "M=M-1"]
    for l in linesTranslate: 
        text = text & $l & "\n"
    truelabel += 1
    falselabel += 1


proc funcAnd(): void = 
    var linesTranslate = ["@SP" , "A=M-1","D=M", "A=A-1","M=D&M", "@SP", "M=M-1"]
    for l in linesTranslate:
        text = text & $l & "\n"

proc funcOr(): void =
    var linesTranslate =  ["@SP" , "A=M-1","D=M", "A=A-1","M=D|M", "@SP", "M=M-1"]
    for l in linesTranslate:
        text = text & $l & "\n"

proc funcNot(): void = 
    var linesTranslate = ["@SP" , "A=M-1","D=M", "M=!D"]
    for l in linesTranslate:
        text = text & $l & "\n"


for readingfile in filesInPath:
    var file_ending = readingfile[1].split(".")
    if file_ending[1] == "vm":
        var pathOfNewFile = path
        pathOfNewFile.add(r"\")
        pathOfNewFile.add(file_ending[0])
        pathOfNewFile.add(".asm")
        let writingFile = open(pathOfNewFile, fmWrite)

        var s = path
        s.add(r"\")
        s.add(readingfile[1])

        var current_file = readFile(s)
        var lines = current_file.splitLines()
        for line in lines:
            var thisLine = line.split(" ")
            if thisLine[0] != "//":
                if thisLine[0] == "push":
                    funcPush(thisLine[1], thisLine[2])
                elif thisLine[0] == "pop":
                    funcPop(thisLine[1], thisLine[2])
                elif thisLine[0] == "add":
                    funcAdd()
                elif thisLine[0] == "sub":
                    funcSub()
                elif thisLine[0] == "eq":
                    funcEq()   
                elif thisLine[0] == "neg":
                    funcNeg()
                elif thisLine[0] == "gt":
                    funcGt()
                elif thisLine[0] == "lt":
                    funcLt()
                elif thisLine[0] == "and":
                    funcAnd()
                elif thisLine[0] == "or":
                    funcOr()
                elif thisLine[0] == "not":
                    funcNot()
        
        writingFile.write(text)
        #echo text