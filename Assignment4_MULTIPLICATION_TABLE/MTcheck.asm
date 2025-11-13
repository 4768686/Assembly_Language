.MODEL SMALL
.STACK 100h

.DATA
    table db 7,2,3,4,5,6,7,8,9            ; 定义九九乘法表的数值部分
          db 2,4,7,8,10,12,14,16,18       ; 每行分别表示乘法表中一列的数据
          db 3,6,9,12,15,18,21,24,27
          db 4,8,12,16,7,24,28,32,36
          db 5,10,15,20,25,30,35,40,45
          db 6,12,18,24,30,7,42,48,54
          db 7,14,21,28,35,42,49,56,63
          db 8,16,24,32,40,48,56,7,72
          db 9,18,27,36,45,54,63,72,81
    info  db "x  y", 0DH, 0AH, '$'        ; 存储提示信息"x  y"，并以0DH 0AH结尾换行，'$'为字符串结束标志
    space db "  ", '$'                    ; 存储两个空格字符，用于输出格式调整
    err   db "  error", 0DH, 0AH, '$'     ; 存储"error"提示信息，用于输出错误信息
    endl  db 0DH, 0AH, '$'                ; 存储换行符

.CODE
START:
    MOV    AX, @DATA        ; 初始化数据段寄存器，将DS指向数据段
    MOV    DS, AX
    LEA    DX, info         ; 将info提示信息加载到DX寄存器
    MOV    AH, 09H          ; DOS中断21H功能调用：显示字符串
    INT    21H
    MOV    CX, 9            ; 初始化外循环计数器，控制行数（乘法表中的第几列）
    MOV    AX, 1            ; AX表示乘数
    MOV    SI, 0            ; SI用来指向乘法表数据的偏移量

A_LOOP:
    PUSH   CX               ; 保存CX（外循环计数器）
    PUSH   AX               ; 保存AX（乘数）
    MOV    BX, 1            ; BX表示被乘数，初始化为1
    MOV    CX, 9            ; 内循环计数器，控制列数（乘法表中的第几行）

B_LOOP:
    XOR    DX, DX           ; 清空DX，准备存储乘法表数据
    MOV    DL, table[SI]    ; 从表中加载当前乘法的正确结果
    MUL    BL               ; 将AX与BX相乘（模拟乘法运算）
    CMP    AX, DX           ; 比较计算结果和表中的正确结果
    JNE    OUTPUT_ERR       ; 如果不相等，跳转到输出错误处理
    JMP    CONTINUE         ; 如果相等，继续循环

OUTPUT_ERR:
    POP    DX               ; 恢复DX寄存器
    PUSH   DX               ; 保存当前DX
    MOV    AL, DL           ; 将表中的结果转换为ASCII字符
    ADD    AL, 30H
    MOV    AH, 02H          ; DOS中断21H功能调用：输出单个字符
    MOV    DL, AL
    INT    21H
    LEA    DX, space        ; 显示空格，用于输出格式调整
    MOV    AH, 09H
    INT    21H
    MOV    AL, BL           ; 将被乘数转换为ASCII字符
    ADD    AL, 30H
    MOV    DL, AL
    MOV    AH, 02H
    INT    21H
    LEA    DX, err          ; 显示错误提示信息
    MOV    AH, 09H
    INT    21H

CONTINUE:
    POP    AX               ; 恢复AX寄存器
    PUSH   AX               ; 保存AX寄存器
    INC    BX               ; 增加被乘数
    INC    SI               ; 移动到乘法表中的下一个数据
    LOOP   B_LOOP           ; 内循环结束，跳回B_LOOP继续
    POP    AX               ; 恢复AX寄存器
    INC    AX               ; 增加乘数
    POP    CX               ; 恢复外循环计数器
    LOOP   A_LOOP           ; 外循环结束，跳回A_LOOP继续
    MOV    AH, 4CH          ; DOS中断21H功能调用：程序正常结束
    INT    21H

END START