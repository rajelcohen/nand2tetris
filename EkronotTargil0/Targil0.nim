import std/os
import std/rdstdin
import os, sequtils
import std/strutils
import macros



var countBuy : float 
var countCell : float
countBuy = 0
countCell = 0
var text = ""


proc handlebuy(str1 : string ,str2: string, str3: string): void =
    var str2 = parseFloat(str2)
    var str3 = parseFloat(str3)
    var sum = str2*str3
    countBuy = float(countBuy) + sum
    text.add("### ")
    text.add("BUY ")
    text.add(str1) 
    text.add(" ###")
    text.add("\n")
    text.add($sum)
    text.add("\n")
    
proc handlecell(str1 : string ,str2: string, str3: string): void =
    var str2 = parseFloat(str2)
    var str3 = parseFloat(str3)
    var sum = str2*str3
    countCell = float(countCell) + sum
    text.add("$$$ ")
    text.add("CELL ")
    text.add(str1) 
    text.add(" $$$")
    text.add("\n")
    text.add($sum)
    text.add("\n")

var str = readLine(stdin)
var x = splitFile(str)
var y = x[1]

var fileName = r"C:\Users\rajel\OneDrive\Desktop\" 
fileName.add(y)
fileName.add(".asm")
#echo fileName



let filesInPath = toSeq(walkDir(str, relative=true))
for file in filesInPath:
    var file_ending = file[1].split(".")
    if file_ending[1] == "vm":
            # Write name of file 
            var nameF = file_ending[0]
            text.add(nameF)
            text.add("\n")

            # Open file
            var s = str
            s.add(r"\")
            s.add(file[1])
            var current_file = readFile(s)
            var lines = current_file.splitLines()
            for line in lines:
                var thisLine = line.split(" ")
                if thisLine[0] == "buy":
                    handlebuy(thisLine[1], thisLine[2], thisLine[3])
                elif thisLine[0] == "cell":
                    handlecell(thisLine[1], thisLine[2], thisLine[3])
           

text.add("TOTAL BUY: ")
text.add($countBuy)
text.add("\n")
text.add("TOTAL CELL: ")
text.add($countCell)
text.add("\n")

let f = open(fileName, fmWrite)
f.write(text)

echo text
echo "TOTAL BUY: ", countBuy, "\n"
echo "TOTAL CELL: ", countCell, "\n"




