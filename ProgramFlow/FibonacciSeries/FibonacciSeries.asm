//push argument
@1
D=A
@ARG
A=M+D
D=M
@SP
A=M
M=D
@SP
M=M+1
//pop pointer
@SP
A=M-1
D=M
@THAT
M=D
@SP
M=M-1
//push constant
@0
D=A
@SP
A=M
M=D
@SP
M=M+1
//pop that
@SP
A=M-1
D=M
@THAT
A=M
M=D
@SP
M=M-1
//push constant
@1
D=A
@SP
A=M
M=D
@SP
M=M+1
//pop that
@SP
A=M-1
D=M
@THAT
A=M
A=A+1
M=D
@SP
M=M-1
//push argument
@0
D=A
@ARG
A=M+D
D=M
@SP
A=M
M=D
@SP
M=M+1
//push constant
@2
D=A
@SP
A=M
M=D
@SP
M=M+1
//Sub
@SP
A=M-1
D=M
A=A-1
M=M-D
@SP
M=M-1
//pop arg
@SP
A= M-1
D=M
@ARG
A=M
M=D
@SP
M=M-1
//Label
(FibonacciSeries.MAIN_LOOP_START)
//push argument
@0
D=A
@ARG
A=M+D
D=M
@SP
A=M
M=D
@SP
M=M+1
//iF Goto
@SP
M=M-1
A=M
D=M
@FibonacciSeries.COMPUTE_ELEMENT
D;JNE
//Goto
@FibonacciSeries.END_PROGRAM
0;JMP
//Label
(FibonacciSeries.COMPUTE_ELEMENT)
//push that
@0
D=A
@THAT
A=M+D
D=M
@SP
A=M
M=D
@SP
M=M+1
//push that
@1
D=A
@THAT
A=M+D
D=M
@SP
A=M
M=D
@SP
M=M+1
//Add
@SP
A=M-1
D=M
A=A-1
M=D+M
@SP
M=M-1
//pop that
@SP
A=M-1
D=M
@THAT
A=M
A=A+1
A=A+1
M=D
@SP
M=M-1
//push pointer1
@THAT
D=M
@SP
A=M
M=D
@SP
M=M+1
//push constant
@1
D=A
@SP
A=M
M=D
@SP
M=M+1
//Add
@SP
A=M-1
D=M
A=A-1
M=D+M
@SP
M=M-1
//pop pointer
@SP
A=M-1
D=M
@THAT
M=D
@SP
M=M-1
//push argument
@0
D=A
@ARG
A=M+D
D=M
@SP
A=M
M=D
@SP
M=M+1
//push constant
@1
D=A
@SP
A=M
M=D
@SP
M=M+1
//Sub
@SP
A=M-1
D=M
A=A-1
M=M-D
@SP
M=M-1
//pop arg
@SP
A= M-1
D=M
@ARG
A=M
M=D
@SP
M=M-1
//Goto
@FibonacciSeries.MAIN_LOOP_START
0;JMP
//Label
(FibonacciSeries.END_PROGRAM)
