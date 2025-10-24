.MODEL SMALL
.STACK 100h

.DATA
    PROMPT_N  DB 'Please Enter A Number Between 1 And 100: $'
    PROMPT_SUM DB 0DH, 0AH, 'The Sum is: $'
    NEWLINE    DB 0DH, 0AH, '$'
    N_VALUE   DW ?       ; 存储用户输入的 N
    SUM_RESULT DW ?      ; 存储计算结果

.CODE

PRINT_DEC_NUM PROC
    PUSH CX             ; 保存 CX 和 DX 寄存器
    PUSH DX
    PUSH BX
    
    XOR CX, CX          ; CX = 0，用作计数器，计算压入堆栈的数字个数
    MOV BX, 10          ; 除数 BCD 10
    
DIV_LOOP:
    XOR DX, DX          ; 每次除法前必须清零 DX
    DIV BX              ; AX = AX / 10, DX = AX % 10 (余数)
    PUSH DX             ; 将余数（一个十进制数字）压入堆栈
    INC CX              ; 计数器加 1
    CMP AX, 0           ; 商是否为 0？
    JNE DIV_LOOP        ; 如果不为 0，继续循环
    
PRINT_LOOP:
    POP DX              ; 弹出数字
    ADD DL, '0'         ; 将数字 (0-9) 转换为 ASCII 字符 ('0'-'9')
    MOV AH, 2           ; DOS 功能：显示字符
    INT 21H             ; 调用 DOS 中断
    LOOP PRINT_LOOP     ; 循环 CX 次
    
    POP BX
    POP DX
    POP CX
    RET
PRINT_DEC_NUM ENDP

READ_DEC_NUM PROC
    PUSH AX
    PUSH CX
    PUSH DX

    XOR BX, BX          ; BX = 0，用于累积结果
    MOV CX, 10          ; CX = 10，用于乘法

READ_CHAR_LOOP:
    MOV AH, 1           ; DOS 功能：读取一个字符
    INT 21H
    
    CMP AL, 0DH         ; 是回车键吗？
    JE READ_DONE        ; 是，则读取结束
    
    CMP AL, '0'         ; < '0'?
    JL READ_CHAR_LOOP   ; 不是数字，忽略
    CMP AL, '9'         ; > '9'?
    JG READ_CHAR_LOOP   ; 不是数字，忽略
    
    ; 是数字字符
    SUB AL, '0'         ; AL = ASCII 转换为 数字
    XOR AH, AH          ; AH = 0, AX = AL (数字值)
    PUSH AX             ; 暂时保存这个数字
    
    MOV AX, BX          ; AX = 当前累积的值
    MUL CX              ; AX = AX * 10 (DX:AX)
    MOV BX, AX          ; BX = BX * 10
    
    POP AX              ; 恢复刚才输入的数字
    ADD BX, AX          ; BX = (BX * 10) + 新数字
    
    JMP READ_CHAR_LOOP

READ_DONE:
    POP DX
    POP CX
    POP AX
    RET
READ_DEC_NUM ENDP

START:
    MOV AX, @DATA       ; 初始化数据段寄存器
    MOV DS, AX
    
    MOV AH, 9
    LEA DX, PROMPT_N
    INT 21H
    
    CALL READ_DEC_NUM   ; 调用读取过程，结果在 BX 中
    MOV N_VALUE, BX     ; 保存 N 的值
    
    MOV CX, BX          ; CX = N (循环计数器)
    XOR AX, AX          ; AX = 0 (累加器)
    
    CMP CX, 0           ; 检查 N 是否为 0
    JE CALC_DONE        ; 如果 N=0，总和为 0，跳过计算

SUM_LOOP:
    ADD AX, CX          ; AX = AX + CX
    LOOP SUM_LOOP
    
CALC_DONE:
    MOV SUM_RESULT, AX  ; 保存总和
    
    MOV AH, 9
    LEA DX, PROMPT_SUM
    INT 21H
    
    MOV AX, SUM_RESULT  ; 将总和加载到 AX
    CALL PRINT_DEC_NUM  ; 调用打印过程
    
    MOV AH, 9
    LEA DX, NEWLINE
    INT 21H

    MOV AH, 4CH         ; DOS 功能：退出程序
    INT 21H             ; 调用 DOS 中断

END START
