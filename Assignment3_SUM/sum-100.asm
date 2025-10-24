.MODEL SMALL
.STACK 100h

.DATA
    SUM_RESULT DW ?     ; 定义一个16位变量来存储结果

.CODE
PRINT_DEC_NUM PROC
    PUSH CX             ; 保存 CX 和 DX 寄存器
    PUSH DX
    
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
    
    POP DX              ; 恢复 DX 和 CX 寄存器
    POP CX
    RET
PRINT_DEC_NUM ENDP

START:
    MOV AX, @DATA       ; 初始化数据段寄存器
    MOV DS, AX
    
    MOV CX, 100         ; CX = 100 (循环计数器)
    XOR AX, AX          ; AX = 0 (累加器)
    
SUM_LOOP:
    ADD AX, CX          ; AX = AX + CX
    LOOP SUM_LOOP       ; CX 减 1，如果 CX != 0 则跳转到 SUM_LOOP
    
    MOV SUM_RESULT, AX  ; 将最终结果 (5050) 存入变量
    
    CALL PRINT_DEC_NUM  ; 调用打印过程

    MOV AH, 4CH         ; DOS 功能：退出程序
    INT 21H             ; 调用 DOS 中断

END START
