//push constant
@0
D=A
@SP
A=M
M=D
@SP
M=M+1
//pop local
@SP
A=M-1
D=M
@LCL
A=M
M=D
@SP
M=M-1
//Label
(BasicLoop.LOOP_START)
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
//Push local
@0
D=A
@LCL
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
//pop local
@SP
A=M-1
D=M
@LCL
A=M
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
@BasicLoop.LOOP_START
D;JNE
//Push local
@0
D=A
@LCL
A=M+D
D=M
@SP
A=M
M=D
@SP
M=M+1
