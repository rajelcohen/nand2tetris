import std/os
import std/rdstdin
import os, sequtils
import std/strutils


#LABLES FOR TRUE & FALSE
var truelabel = 0
var falselabel = 0
var text = ""
var mone = 0
#echo "type a path" & "\n"
#var path = readLine(stdin)
var path = r"C:\targilim\EkronotTargil2\FibonacciSeries"
var name = path.split(r"\")
var fileName = name[len(name)-1]

# function to connect two arrays:
proc concat[I1, I2: static[int]; T](a: array[I1, T], b: array[I2, T]): array[I1 + I2, T] =
  result[0..a.high] = a
  result[a.len..result.high] = b



let filesInPath = toSeq(walkDir(path, relative=true))

proc funcPush(str: string, arg : string, name: string) : void = 
    #Group 1
    if str == "local":
        var linesTranslate = ["//Push local", "@" & arg, "D=A","@LCL" , "A=M+D", "D=M", "@SP", "A=M", "M=D", "@SP", "M=M+1"]
        for l in linesTranslate:
            text = text & $l & "\n"
    
    if str == "argument":
        var linesTranslate = ["//push argument" , "@" & $arg, "D=A","@ARG" , "A=M+D", "D=M", "@SP", "A=M", "M=D", "@SP", "M=M+1"]
        for l in linesTranslate:
            text = text & $l & "\n"
    
    if str == "this":
        var linesTranslate = ["//push this", "@" & arg, "D=A","@THIS" , "A=M+D", "D=M", "@SP", "A=M", "M=D", "@SP", "M=M+1"]
        for l in linesTranslate:
            text = text & $l & "\n"

    if str == "that":
        var linesTranslate = ["//push that", "@" & arg, "D=A","@THAT" , "A=M+D", "D=M", "@SP", "A=M", "M=D", "@SP", "M=M+1"]
        for l in linesTranslate:
            text = text & $l & "\n"

    
     #Group 2
    if str == "temp":
        var linesTranslate = ["//push temp", "@" & arg ,"D=A", "@5", "A=A+D", "D=M", "@SP", "A=M", "M=D", "@SP", "M=M+1"]
        for l in linesTranslate:
            text = text & $l & "\n"

    #Group 3
    if str == "static":
        var linesTranslate = ["//push statis", "@" & $name & "." & arg,"D=M","@SP","A=M","M=D","@SP","M=M+1"]
        for l in linesTranslate:
            text = text & $l & "\n"

    
    #Group 4
    if str == "pointer":
        if parseInt(arg) == 0:
            var linesTranslate = @["//push pointer0", "@THIS","D=M","@SP","A=M","M=D","@SP","M=M+1"]
            for l in linesTranslate:
                text = text & $l & "\n"
        elif parseInt(arg) == 1:
            var linesTranslate = @["//push pointer1", "@THAT","D=M","@SP","A=M","M=D","@SP","M=M+1"]
            for l in linesTranslate:
                text = text & $l & "\n"

    #Group 5
    if str == "constant":
        var linesTranslate = ["//push constant", "@" & $arg ,"D=A", "@SP", "A=M", "M=D" , "@SP", "M=M+1"]
        for l in linesTranslate:
            text = text & $l & "\n"
    
  
proc funcPop(str: string, arg : string, name: string) : void = 
#Group 1
    if str == "local":
        var linesTranslate = @["//pop local", "@SP","A=M-1","D=M","@LCL","A=M"]
        for i in 1 .. parseInt(arg)-1: 
            linesTranslate.add("A=A+1")  
        linesTranslate.add("M=D")
        linesTranslate.add("@SP")
        linesTranslate.add("M=M-1")
        for l in linesTranslate:
            text = text & $l & "\n"
    
    if str == "argument":
        var linesTranslate = @["//pop arg", "@SP","A= M-1","D=M","@ARG", "A=M"]
        for i in countup(1, parseInt(arg)):
            linesTranslate.add("A=A+1")
        linesTranslate.add("M=D")
        linesTranslate.add("@SP")
        linesTranslate.add("M=M-1")

        for l in linesTranslate:
            text = text & $l & "\n"

    if str == "this":
        var linesTranslate = @["//pop this", "@SP","A=M-1","D=M","@THIS","A=M"]
        for i in countup(1, parseInt(arg)):
            linesTranslate.add("A=A+1")
        linesTranslate.add("M=D")
        linesTranslate.add("@SP")
        linesTranslate.add("M=M-1")
        for l in linesTranslate:
            text = text & $l & "\n"
     
    
    if str == "that":
        var linesTranslate = @["//pop that", "@SP","A=M-1","D=M","@THAT","A=M"]
        for i in countup(1, parseInt(arg)):
            linesTranslate.add("A=A+1")
        linesTranslate.add("M=D")
        linesTranslate.add("@SP")
        linesTranslate.add("M=M-1")
        for l in linesTranslate:
            text = text & $l & "\n"
       

    #Group 2
    if str == "temp":
        #var linesTranslate = @["//pop temp", "@SP","A=M-1","D=M","@5"]
        #for i in countup(1, parseInt(arg)):
        #    linesTranslate.add("A=A+1")
        var linesTranslate = @["//pop temp", "@SP","A=M-1","D=M","@" & $arg]
        for i in 0..4:
            linesTranslate.add("A=A+1")
        linesTranslate.add("M=D")
        linesTranslate.add("@SP")
        linesTranslate.add("M=M-1")
        for l in linesTranslate:
            text = text & $l & "\n"
            
    #Group 3
    if str == "static":
        #var linesTranslate = ["//pop static", "@SP","A=M-1","D=M","@" & $name & "." & arg, "M=D", "@SP", "M=M-1"]
        var linesTranslate = ["//pop static", "@SP","M=M-1","A=M", "D=M","@" & $name & "." & arg, "M=D"]
        for l in linesTranslate:
            text = text & $l & "\n"
    
    #Group 4
    if str == "pointer":
        var linesTranslate = @["//pop pointer", "@SP","A=M-1","D=M"] 
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
    var linesTranslate = ["//Add", "@SP" , "A=M-1","D=M","A=A-1","M=D+M", "@SP", "M=M-1"]
    for l in linesTranslate:
        text = text & $l & "\n"

proc funcSub(): void =
    var linesTranslate = ["//Sub", "@SP" , "A=M-1","D=M","A=A-1","M=M-D", "@SP", "M=M-1"]
    for l in linesTranslate:
        text = text & $l & "\n"


proc funcNeg(): void =
    var linesTranslate = ["//Neg", "@SP" , "A=M-1","M=-M"]
    for l in linesTranslate:
        text = text & $l & "\n"

proc funcEq(): void =
    var linesTranslate = ["//Eq", "@SP" , "A=M-1", "D=M", "A=A-1", "D=D-M", "@IF_TRUE" & $truelabel, "D;JEQ", "D=0", "@SP", "A=M-1", "A=A-1", "M=D", "@IF_FALSE" & $falselabel, "0;JMP","(IF_TRUE" & $truelabel & ")", "D=-1", "@SP", "A=M-1", "A=A-1", "M=D", "(IF_FALSE" & $falselabel & ")", "@SP", "M=M-1"]
    for l in linesTranslate:
        text = text & $l & "\n"
    truelabel += 1
    falselabel += 1

proc funcGt(): void =
    #var linesTranslate = ["//Grater than", "@SP" , "A=M-1", "D=M", "A=A-1", "D=D-M", "@IF_TRUE" & $truelabel, "D;JLT", "D=0", "@SP", "A=M-1", "A=A-1", "M=D", "@IF_FALSE" & $falselabel, "0;JMP","(IF_TRUE" & $truelabel & ")", "D=-1", "@SP", "A=M-1", "A=A-1", "M=D", "(IF_FALSE" & $falselabel & ")", "@SP", "M=M-1"]
    var linesTranslate = ["@SP", "AM=M-1", "D=M", "@SP", "AM=M-1", "D=M-D", "@IF_TRUE" & $truelabel, "D;JLT", "@SP", "A=M", "M=0", "@IF_FALSE" & $falselabel, "0;JMP", "(IF_TRUE" & $truelabel & ")", "@SP", "A=M", "M=-1", "(IF_FALSE" & $falselabel & ")", "@SP", "M=M+1"]
    for l in linesTranslate:
        text = text & $l & "\n"
    truelabel += 1
    falselabel += 1

proc funcLt(): void =
    var linesTranslate = ["//Less than", "@SP" , "A=M-1", "D=M", "A=A-1", "D=D-M", "@IF_TRUE" & $truelabel, "D;JGT", "D=0", "@SP", "A=M-1", "A=A-1", "M=D", "@IF_FALSE" & $falselabel, "0;JMP","(IF_TRUE" & $truelabel & ")", "D=-1", "@SP", "A=M-1", "A=A-1", "M=D", "(IF_FALSE" & $falselabel & ")", "@SP", "M=M-1"]
    for l in linesTranslate: 
        text = text & $l & "\n"
    truelabel += 1
    falselabel += 1


proc funcAnd(): void = 
    var linesTranslate = ["//And", "@SP" , "A=M-1","D=M", "A=A-1","M=D&M", "@SP", "M=M-1"]
    for l in linesTranslate:
        text = text & $l & "\n"

proc funcOr(): void =
    var linesTranslate =  ["//Or", "@SP" , "A=M-1","D=M", "A=A-1","M=D|M", "@SP", "M=M-1"]
    for l in linesTranslate:
        text = text & $l & "\n"

proc funcNot(): void = 
    var linesTranslate = ["//Not", "@SP" , "A=M-1","D=M", "M=!D"]
    for l in linesTranslate:
        text = text & $l & "\n"

proc funcLabel(arg : string, name : string): void = 
    var linesTranslate = ["//Label", "(" & $name & "." & $arg & ")"]
    for l in linesTranslate:
        text = text & $l & "\n"

proc funcGoto(arg : string, name : string): void = 
    var linesTranslate = ["//Goto", "@" & $name & "." & $arg , "0;JMP"]
    for l in linesTranslate:
        text = text & $l & "\n"
    

proc funcIfGoto(arg : string, name: string): void = 
    var linesTranslate = ["//iF Goto", "@SP", "M=M-1", "A=M", "D=M","@" & $name & "." & $arg , "D;JNE"]
    for l in linesTranslate:
        text = text & $l & "\n"

proc funcCall(g : string, n : string): void = 
    var pushreturnaddress = ["//Call", "@" & $g & "." & "ReturnAddress" & $mone, "D=A", "@SP", "A=M", "M=D","@SP", "M=M+1"]
    var pushLCL = ["@LCL", "D=M", "@SP", "A=M", "M=D", "@SP", "M=M+1"]
    var pushARG = ["@ARG", "D=M", "@SP", "A=M", "M=D", "@SP", "M=M+1"]
    var pushTHIS = ["@THIS", "D=M", "@SP", "A=M", "M=D", "@SP", "M=M+1"]
    var pushTHAT = ["@THAT", "D=M", "@SP", "A=M", "M=D", "@SP", "M=M+1"]
    #@newARG = n-5
    var num = parseInt(n) + 5
    var ARGisSPminusnminus5 = ["@SP", "D=M", "@" & $num , "D=D-A","@ARG" , "M=D"]
    var LCLisSP = ["@SP", "D=M", "@LCL", "M=D"]
    var GOTOg = ["@" & $g, "0;JMP"]
    var labelreturnAddress = ["(" & $g & "." & "ReturnAddress" & $mone & ")"]
    let linesTranslate = pushreturnaddress.concat(pushLCL).concat(pushARG).concat(pushTHIS).concat(pushTHAT).concat(ARGisSPminusnminus5).concat(LCLisSP).concat(GOTOg).concat(labelreturnAddress)
    for l in linesTranslate:
        text = text & $l & "\n"

proc funcFunction(g : string, k : string): void =
    var labelG = ["//Function", "(" & $g & ")"]
    var newLocalVariables = ["@" & $k, "D=A", "@" & $g & ".End", "D;JEQ"]
    #(k != 0), SP = 0
    var jumpingforfalse = ["(" & $g & ".Loop)", "@SP", "A=M", "M=0", "@SP", "M=M+1", "@" & $g & ".Loop"]
    # (k != 0)
    var jumpIf = ["D=D-1;JNE"]
    #(k == 0)

    var endofLoop = [ "(" & $g & ".End)" ]

    let linesTranslate = labelG.concat(newLocalVariables).concat(jumpingforfalse).concat(jumpIf).concat(endofLoop)
    for l in linesTranslate:
        text = text & $l & "\n"

proc funcReturn(): void =
    var frame = ["//Return", "@LCL", "D=M"]
    #RET = * (FRAME-5), RAM[13] = (LOCAL - 5)
    var retandram = ["@5", "A=D-A", "D=M", "@13", "M=D"]
    #*ARG = POP()
    var ARGisPop = ["@SP", "M=M-1", "A=M", "D=M", "@ARG", "A=M", "M=D"]
    var SPisARGplus1 = ["@ARG", "D=M", "@SP", "M=D+1"]
    #THAT = *(FRAM-1)
    var THATis = ["@LCL", "M=M-1", "A=M", "D=M", "@THAT", "M=D"]
    #THIS = *(FRAM-2) 
    var THISis = ["@LCL", "M=M-1", "A=M", "D=M", "@THIS", "M=D"]
    #ARG = *(FRAM-3)
    var ARGis = ["@LCL", "M=M-1", "A=M", "D=M", "@ARG", "M=D"]
    #LCL = *(FRAM-4)
    var LCLis = ["@LCL", "M=M-1", "A=M", "D=M" , "@LCL", "M=D"]
    var gotoRET = ["@13", "A=M", "0;JMP"]
    let linesTranslate = frame.concat(retandram).concat(ARGisPop).concat(SPisARGplus1).concat(THATis).concat(THISis).concat(ARGis).concat(LCLis).concat(gotoRET)
    for l in linesTranslate:
        text = text & $l & "\n"

# count how many .vm files are in folder
var count = 0
for readingfile in filesInPath:
    var file_ending = readingfile[1].split(".")
    if file_ending[1] == "vm":
        count = count + 1

#if more than 1 .vm file in folder, add the sys code
if count > 1:
    # insert the sys code:
    text = "@256\nD=A\n@SP\nM=D\n" 
    funcCall("Sys.init", "0")

# translating to asm file  -help of functions-
if count >= 1: 
    var pathOfNewFile = path
    pathOfNewFile.add(r"\")
    pathOfNewFile.add($fileName)
    pathOfNewFile.add(".asm")
    let writingFile = open(pathOfNewFile, fmWrite)

    for readingfile in filesInPath:
        var file_ending = readingfile[1].split(".")
        if file_ending[1] == "vm":
            var s = path
            s.add(r"\")
            s.add(readingfile[1])

            var current_file = readFile(s)
            var lines = current_file.splitLines()
            for line in lines:
                var thisLine = line.split(" ")
                if thisLine[0] != "//":
                    if thisLine[0] == "push":
                        funcPush(thisLine[1], thisLine[2], file_ending[0])
                    elif thisLine[0] == "pop":
                        funcPop(thisLine[1], thisLine[2], file_ending[0] )
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
                    elif thisLine[0] == "label":
                        funcLabel(thisLine[1], file_ending[0])
                    elif thisLine[0] == "goto":
                        funcGoto(thisLine[1], file_ending[0])
                    elif thisLine[0] == "if-goto":
                        funcIfGoto(thisLine[1], file_ending[0])
                    elif thisLine[0] == "call":
                        funcCall(thisLine[1], thisLine[2])
                        mone = mone + 1
                    elif thisLine[0] == "function":
                        funcFunction(thisLine[1], thisLine[2])
                    elif thisLine[0] == "return":
                        funcReturn()

    writingFile.write(text)
    #echo