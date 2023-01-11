import std/os
import std/rdstdin
import os, sequtils
import std/strutils
import sequtils

var str1 = "let length = Keyboard.readInt(\"HOW MANY NUMBERS?\"); let a[i] = Keyboard.readInt(\"HOW MANY NUMBERS? \" );"
#echo str.toSeq()
var str = str1.split("\"")
var k = 0
var p = @[""]
while k < str.len:
    if(k + 1 < str.len):
        echo str[k+1]
        if(p == @[""]):
            p = @[str[k+1]]
        else:
            p.add(str[k+1])
    k = k + 2
echo p